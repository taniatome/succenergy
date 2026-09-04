import { auth } from '../config/firebase.js';
import { logger } from '../config/logger.js';
import type { ExerciseResult } from '../models/exercise.model.js';
import { accountRepository } from '../repositories/account.repository.js';
import type { AccountRepository } from '../repositories/account.repository.js';
import { adminRepository } from '../repositories/admin.repository.js';
import type {
  AdminRepository,
  DirectoryEntry,
  PlatformStats,
} from '../repositories/admin.repository.js';
import { RowNotFoundError } from '../repositories/errors.js';
import { exerciseAdminRepository } from '../repositories/exercise_admin.repository.js';
import type {
  ExerciseAdminRepository,
  LibraryPatch,
  StepInput,
} from '../repositories/exercise_admin.repository.js';
import { exerciseRepository } from '../repositories/exercise.repository.js';
import type { ExerciseRepository } from '../repositories/exercise.repository.js';
import type {
  CreateExerciseInput,
  DirectoryQuery,
  UpdateExerciseInput,
} from '../schemas/admin.schema.js';
import { ApiError } from '../utils/api_error.js';
import { toIso } from './caller.js';

/** One directory row as the console reads it. */
export interface DirectoryResult extends Omit<DirectoryEntry, 'joinedAt' | 'lastSeenAt'> {
  joinedAt: string;
  lastSeenAt: string | null;
}

/** A page of the directory, with the cursor for the next one. */
export interface DirectoryPage {
  users: DirectoryResult[];

  /** Send back as `beforeCreatedAt` and `beforeId`. Null on the last page. */
  nextCursor: { beforeCreatedAt: string; beforeId: string } | null;
}

function toDirectoryResult(entry: DirectoryEntry): DirectoryResult {
  return {
    ...entry,
    joinedAt: entry.joinedAt.toISOString(),
    lastSeenAt: toIso(entry.lastSeenAt),
  };
}

/** A validated step to the repository's shape, filling every column. */
function toStepInput(
  step: NonNullable<CreateExerciseInput['steps']>[number],
): StepInput {
  return {
    type: step.type,
    promptEn: step.promptEn ?? null,
    promptPt: step.promptPt ?? null,
    helpEn: step.helpEn ?? null,
    helpPt: step.helpPt ?? null,
    options: step.options ?? [],
    scaleLowLabelEn: step.scaleLowLabelEn ?? null,
    scaleLowLabelPt: step.scaleLowLabelPt ?? null,
    scaleHighLabelEn: step.scaleHighLabelEn ?? null,
    scaleHighLabelPt: step.scaleHighLabelPt ?? null,
    saveAs: step.saveAs ?? null,
  };
}

/**
 * The management console.
 *
 * Every method here reads or writes across accounts, which is why every route
 * above it carries `requireAdmin`. Nothing in this service is reachable
 * without the custom claim, and the claim is set out of band — there is no
 * endpoint that grants it.
 */
export class AdminService {
  private readonly directory: AdminRepository;
  private readonly library: ExerciseRepository;
  private readonly libraryWrites: ExerciseAdminRepository;
  private readonly accounts: AccountRepository;

  constructor(
    directory: AdminRepository = adminRepository,
    library: ExerciseRepository = exerciseRepository,
    libraryWrites: ExerciseAdminRepository = exerciseAdminRepository,
    accounts: AccountRepository = accountRepository,
  ) {
    this.directory = directory;
    this.library = library;
    this.libraryWrites = libraryWrites;
    this.accounts = accounts;
  }

  // --- Users --------------------------------------------------------------

  async listUsers(request: DirectoryQuery): Promise<DirectoryPage> {
    const before =
      request.beforeCreatedAt !== undefined && request.beforeId !== undefined
        ? { createdAt: new Date(request.beforeCreatedAt), id: request.beforeId }
        : undefined;

    const entries = await this.directory.listUsers({
      limit: request.limit,
      ...(before === undefined ? {} : { before }),
    });

    const last = entries.at(-1);

    return {
      users: entries.map(toDirectoryResult),
      // A full page means there may be another; a short one is the end.
      nextCursor:
        entries.length === request.limit && last !== undefined
          ? {
              beforeCreatedAt: last.joinedAt.toISOString(),
              beforeId: last.id,
            }
          : null,
    };
  }

  async getUser(uid: string): Promise<DirectoryResult> {
    const entry = await this.directory.findUser(uid);
    if (!entry) {
      throw ApiError.notFound('User not found');
    }
    return toDirectoryResult(entry);
  }

  /**
   * Deletes an account on the owner's behalf.
   *
   * The same two steps as a self-service delete, in the same order and for
   * the same reasons: the data first, because that is the part that must not
   * survive, then the Auth record, which revokes every outstanding token.
   */
  async deleteUser(uid: string): Promise<{ documentsDeleted: number }> {
    const result = await this.accounts.deleteAllData(uid);

    try {
      await auth.deleteUser(uid);
    } catch (cause) {
      logger.error({ uid, err: cause }, 'Admin delete left the auth record');
      throw new ApiError(
        500,
        'partial_deletion',
        'Account data was deleted but the sign-in record could not be removed.',
        { cause },
      );
    }

    logger.info({ uid, ...result }, 'Admin deleted account');
    return result;
  }

  // --- Library ------------------------------------------------------------

  /** The whole library, withdrawn exercises included. */
  async listExercises(): Promise<ExerciseResult[]> {
    const records = await this.library.list({ includeInactive: true });
    return records.map((record) => ({
      ...record,
      totalScreens: record.steps.length + 1,
    }));
  }

  async createExercise(input: CreateExerciseInput): Promise<ExerciseResult> {
    const id = await this.libraryWrites.create({
      principle: input.principle,
      titleEn: input.titleEn ?? null,
      titlePt: input.titlePt ?? null,
      summaryEn: input.summaryEn ?? null,
      summaryPt: input.summaryPt ?? null,
      durationMinutes: input.durationMinutes ?? 0,
      closingReflectionPromptEn: input.closingReflectionPromptEn ?? null,
      closingReflectionPromptPt: input.closingReflectionPromptPt ?? null,
      suggestedActionEn: input.suggestedActionEn ?? null,
      suggestedActionPt: input.suggestedActionPt ?? null,
      isActive: input.isActive ?? true,
      position: input.position ?? 0,
      steps: input.steps.map(toStepInput),
    });

    return this.requireExercise(id);
  }

  async updateExercise(
    exerciseId: string,
    input: UpdateExerciseInput,
  ): Promise<ExerciseResult> {
    // Spread the scalar fields, then map the steps: the validated step shape
    // has optional fields where the repository's has explicit nulls, so the
    // two are not assignable and the mapper is the conversion.
    const { steps, ...scalars } = input;
    const patch: LibraryPatch = { ...scalars };
    if (steps !== undefined) {
      patch.steps = steps.map(toStepInput);
    }

    await this.guard(() => this.libraryWrites.update(exerciseId, patch));
    return this.requireExercise(exerciseId);
  }

  async deactivateExercise(exerciseId: string): Promise<ExerciseResult> {
    await this.guard(() => this.libraryWrites.deactivate(exerciseId));
    return this.requireExercise(exerciseId);
  }

  async reorderExercise(
    exerciseId: string,
    position: number,
  ): Promise<ExerciseResult> {
    await this.guard(() => this.libraryWrites.reorder(exerciseId, position));
    return this.requireExercise(exerciseId);
  }

  // --- Stats --------------------------------------------------------------

  async stats(): Promise<PlatformStats & { libraryEmpty: boolean }> {
    const [stats, libraryEmpty] = await Promise.all([
      this.directory.stats(),
      this.directory.isLibraryEmpty(),
    ]);
    return { ...stats, libraryEmpty };
  }

  private async requireExercise(exerciseId: string): Promise<ExerciseResult> {
    const record = await this.library.find(exerciseId);
    if (!record) {
      throw ApiError.notFound('Exercise not found');
    }
    return { ...record, totalScreens: record.steps.length + 1 };
  }

  private async guard<T>(run: () => Promise<T>): Promise<T> {
    try {
      return await run();
    } catch (cause) {
      if (cause instanceof RowNotFoundError) {
        throw ApiError.notFound('Exercise not found');
      }
      throw cause;
    }
  }
}

export const adminService = new AdminService();

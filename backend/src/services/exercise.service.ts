import type { ExerciseResult } from '../models/exercise.model.js';
import type { ExerciseResponseResult } from '../models/exercise_response.model.js';
import { RowNotFoundError } from '../repositories/errors.js';
import { exerciseRepository } from '../repositories/exercise.repository.js';
import type { ExerciseRepository } from '../repositories/exercise.repository.js';
import { exerciseResponseRepository } from '../repositories/exercise_response.repository.js';
import type { ExerciseResponseRepository } from '../repositories/exercise_response.repository.js';
import type {
  ExerciseRecord,
  ExerciseResponseRecord,
} from '../repositories/exercise_rows.js';
import type { SubmitExerciseInput } from '../schemas/exercise.schema.js';
import { ApiError } from '../utils/api_error.js';
import type { Caller } from './caller.js';

/**
 * The exercise library, and the sessions run against it.
 *
 * `totalScreens` is derived rather than stored: it is the steps plus the
 * closing reflection, and the app's session chrome counts on the two agreeing.
 */
function toExerciseResult(record: ExerciseRecord): ExerciseResult {
  return { ...record, totalScreens: record.steps.length + 1 };
}

function toResponseResult(
  record: ExerciseResponseRecord,
): ExerciseResponseResult {
  return {
    id: record.id,
    exerciseId: record.exerciseId,
    principle: record.principle,
    stepResponses: record.stepResponses,
    reflection: record.reflection,
    suggestedAction: record.suggestedAction,
    completedAt: record.completedAt.toISOString(),
  };
}

export class ExerciseService {
  private readonly library: ExerciseRepository;
  private readonly responses: ExerciseResponseRepository;

  constructor(
    library: ExerciseRepository = exerciseRepository,
    responses: ExerciseResponseRepository = exerciseResponseRepository,
  ) {
    this.library = library;
    this.responses = responses;
  }

  // --- Library ------------------------------------------------------------

  /**
   * The library.
   *
   * An empty list is a valid answer, not an error: the exercise library starts
   * empty in production and is filled from the admin console or the client's
   * own content. The app shows its empty state rather than a failure.
   */
  async listLibrary(): Promise<ExerciseResult[]> {
    const records = await this.library.list();
    return records.map(toExerciseResult);
  }

  async getExercise(exerciseId: string): Promise<ExerciseResult> {
    const record = await this.library.find(exerciseId);
    if (!record) {
      throw ApiError.notFound('Exercise not found');
    }
    return toExerciseResult(record);
  }

  // --- Responses ----------------------------------------------------------

  async listResponses(
    caller: Caller,
    exerciseId?: string,
  ): Promise<ExerciseResponseResult[]> {
    const records = await this.responses.list(caller.uid, exerciseId);
    return records.map(toResponseResult);
  }

  async getResponse(
    caller: Caller,
    responseId: string,
  ): Promise<ExerciseResponseResult> {
    const record = await this.responses.find(caller.uid, responseId);
    if (!record) {
      throw ApiError.notFound('Exercise response not found');
    }
    return toResponseResult(record);
  }

  /**
   * Records a completed session.
   *
   * The principle and the suggested action come from the exercise row rather
   * than the request. The client says which exercise it ran; everything about
   * that exercise is read here, so practice cannot be filed under a principle
   * the person did not do and the action captured is the one the library
   * actually offered.
   */
  async submit(
    caller: Caller,
    input: SubmitExerciseInput,
  ): Promise<ExerciseResponseResult> {
    let context: Awaited<ReturnType<ExerciseRepository['findContext']>>;

    try {
      context = await this.library.findContext(input.exerciseId);
    } catch (cause) {
      if (cause instanceof RowNotFoundError) {
        throw ApiError.notFound('Exercise not found');
      }
      throw cause;
    }

    const created = await this.responses.create(caller.uid, {
      exerciseId: input.exerciseId,
      principle: context.principle,
      stepResponses: input.stepResponses,
      reflection: input.reflection,
      suggestedAction: context.suggestedActionEn,
    });

    return toResponseResult(created);
  }
}

export const exerciseService = new ExerciseService();

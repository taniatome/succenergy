import { withTransaction } from '../config/database.js';
import type { Principle } from '../models/principle.model.js';
import { RowNotFoundError } from './errors.js';
import { EXERCISE_PATCH_COLUMNS } from './exercise_rows.js';
import { buildPatch } from './patch_builder.js';

/** One step of a new or replaced exercise. */
export interface StepInput {
  type: 'free_text' | 'single_choice' | 'scale';
  promptEn: string | null;
  promptPt: string | null;
  helpEn: string | null;
  helpPt: string | null;
  options: unknown[];
  scaleLowLabelEn: string | null;
  scaleLowLabelPt: string | null;
  scaleHighLabelEn: string | null;
  scaleHighLabelPt: string | null;
  saveAs: string | null;
}

/** A library exercise, as the console composes it. */
export interface LibraryInput {
  principle: Principle;
  titleEn: string | null;
  titlePt: string | null;
  summaryEn: string | null;
  summaryPt: string | null;
  durationMinutes: number;
  closingReflectionPromptEn: string | null;
  closingReflectionPromptPt: string | null;
  suggestedActionEn: string | null;
  suggestedActionPt: string | null;
  isActive: boolean;
  position: number;
  steps: StepInput[];
}

export type LibraryPatch = Partial<Omit<LibraryInput, 'steps'>> & {
  steps?: StepInput[];
};

/**
 * Library writes, for the admin console only.
 *
 * Separate from `exercise.repository.ts`, which reads the library for the
 * app: a repository that both serves every user and can rewrite the content
 * is one accident away from an app route calling a write. These methods are
 * only reachable from `/v1/admin`, behind the custom claim.
 */
export class ExerciseAdminRepository {
  /**
   * Creates the exercise and its steps in one transaction.
   *
   * An exercise with no steps is not a usable exercise, so a half-written one
   * must not be left in the library for the app to serve.
   */
  async create(input: LibraryInput): Promise<string> {
    return withTransaction(async (client) => {
      const { rows } = await client.query<{ id: string }>(
        `insert into exercises (
           principle, title_en, title_pt, summary_en, summary_pt,
           duration_minutes, closing_reflection_prompt_en,
           closing_reflection_prompt_pt, suggested_action_en,
           suggested_action_pt, is_active, position
         )
         values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
         returning id`,
        [
          input.principle,
          input.titleEn,
          input.titlePt,
          input.summaryEn,
          input.summaryPt,
          input.durationMinutes,
          input.closingReflectionPromptEn,
          input.closingReflectionPromptPt,
          input.suggestedActionEn,
          input.suggestedActionPt,
          input.isActive,
          input.position,
        ],
      );

      const id = rows[0]?.id;
      if (id === undefined) {
        throw new RowNotFoundError('exercise', 'inserted');
      }

      await ExerciseAdminRepository.writeSteps(client, id, input.steps);
      return id;
    });
  }

  /**
   * Applies a patch, replacing the steps only when they were supplied.
   *
   * Steps are replaced wholesale rather than merged: they are an ordered list
   * the console edits as a whole, and a merge would leave a removed step in
   * place. Absent steps mean "leave them alone", which is what editing only
   * a title has to do.
   */
  async update(exerciseId: string, patch: LibraryPatch): Promise<void> {
    await withTransaction(async (client) => {
      const columns: Record<string, unknown> = {};

      for (const field of Object.keys(EXERCISE_PATCH_COLUMNS)) {
        const value = (patch as Record<string, unknown>)[field];
        if (value !== undefined) {
          columns[field] = value;
        }
      }

      const built = buildPatch(EXERCISE_PATCH_COLUMNS, columns);

      if (built.clause !== '') {
        const { rowCount } = await client.query(
          `update exercises set ${built.clause}
            where id = $${String(built.nextIndex)}`,
          [...built.values, exerciseId],
        );
        if (rowCount === 0) {
          throw new RowNotFoundError('exercise', exerciseId);
        }
      }

      if (patch.steps !== undefined) {
        await client.query('delete from exercise_steps where exercise_id = $1', [
          exerciseId,
        ]);
        await ExerciseAdminRepository.writeSteps(client, exerciseId, patch.steps);
      }
    });
  }

  /**
   * Withdraws an exercise without deleting it.
   *
   * A soft delete because responses reference `exercise_id` with no foreign
   * key precisely so history survives — a hard delete would leave every past
   * session pointing at nothing, and the schema comment asks for this.
   */
  async deactivate(exerciseId: string): Promise<void> {
    await withTransaction(async (client) => {
      const { rowCount } = await client.query(
        'update exercises set is_active = false where id = $1',
        [exerciseId],
      );
      if (rowCount === 0) {
        throw new RowNotFoundError('exercise', exerciseId);
      }
    });
  }

  async reorder(exerciseId: string, position: number): Promise<void> {
    await withTransaction(async (client) => {
      const { rowCount } = await client.query(
        'update exercises set position = $1 where id = $2',
        [position, exerciseId],
      );
      if (rowCount === 0) {
        throw new RowNotFoundError('exercise', exerciseId);
      }
    });
  }

  /** Inserts the ordered steps, position taken from array order. */
  private static async writeSteps(
    client: { query: (text: string, values: unknown[]) => Promise<unknown> },
    exerciseId: string,
    steps: readonly StepInput[],
  ): Promise<void> {
    for (const [index, step] of steps.entries()) {
      await client.query(
        `insert into exercise_steps (
           exercise_id, position, type, prompt_en, prompt_pt, help_en, help_pt,
           options, scale_low_label_en, scale_low_label_pt,
           scale_high_label_en, scale_high_label_pt, save_as
         )
         values ($1, $2, $3, $4, $5, $6, $7, $8::jsonb, $9, $10, $11, $12, $13)`,
        [
          exerciseId,
          index,
          step.type,
          step.promptEn,
          step.promptPt,
          step.helpEn,
          step.helpPt,
          JSON.stringify(step.options),
          step.scaleLowLabelEn,
          step.scaleLowLabelPt,
          step.scaleHighLabelEn,
          step.scaleHighLabelPt,
          step.saveAs,
        ],
      );
    }
  }
}

export const exerciseAdminRepository = new ExerciseAdminRepository();

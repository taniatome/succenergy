import { query } from '../config/database.js';
import type { Principle } from '../models/principle.model.js';
import { RowNotFoundError } from './errors.js';
import {
  EXERCISE_COLUMNS,
  EXERCISE_STEP_COLUMNS,
  toExerciseRecord,
  toStepEntry,
} from './exercise_rows.js';
import type {
  ExerciseRecord,
  ExerciseRow,
  ExerciseStepRow,
} from './exercise_rows.js';

/**
 * The `exercises` and `exercise_steps` tables — the shared library.
 *
 * Not per-user, so no statement here filters on a uid: the same exercises are
 * offered to everyone, and what a particular person answered lives in
 * `exercise_responses`. That is also why the library routes sit at
 * `/v1/exercises` rather than under `/v1/me`.
 *
 * Withdrawn exercises are hidden rather than deleted, so responses to them
 * keep their context. `includeInactive` is for the admin console only.
 */
export class ExerciseRepository {
  /**
   * The library, with steps, in two queries rather than one per exercise.
   *
   * Ordered by principle position rather than name, so the cycle reads in
   * the order the methodology teaches it rather than alphabetically.
   */
  async list(options: { includeInactive?: boolean } = {}): Promise<ExerciseRecord[]> {
    const exercises = options.includeInactive
      ? await query<ExerciseRow>(
          `select ${EXERCISE_COLUMNS} from exercises order by position, id`,
        )
      : await query<ExerciseRow>(
          `select ${EXERCISE_COLUMNS} from exercises
            where is_active
            order by position, id`,
        );

    if (exercises.rows.length === 0) {
      return [];
    }

    const steps = await query<ExerciseStepRow>(
      `select ${EXERCISE_STEP_COLUMNS} from exercise_steps
        order by exercise_id, position`,
    );

    return exercises.rows.map((row) =>
      toExerciseRecord(
        row,
        steps.rows.filter((step) => step.exercise_id === row.id).map(toStepEntry),
      ),
    );
  }

  /** One exercise with its steps, active or not. */
  async find(exerciseId: string): Promise<ExerciseRecord | null> {
    const exercises = await query<ExerciseRow>(
      `select ${EXERCISE_COLUMNS} from exercises where id = $1`,
      [exerciseId],
    );

    const row = exercises.rows[0];
    if (!row) {
      return null;
    }

    const steps = await query<ExerciseStepRow>(
      `select ${EXERCISE_STEP_COLUMNS} from exercise_steps
        where exercise_id = $1 order by position`,
      [exerciseId],
    );

    return toExerciseRecord(row, steps.rows.map(toStepEntry));
  }

  /**
   * The exercise's principle and the action it offers, for a submission.
   *
   * Read rather than trusted: the client sends only which exercise it ran, so
   * the principle a response is filed under and the action it captured both
   * come from the library row. A client cannot file practice under a
   * principle it did not do.
   */
  async findContext(
    exerciseId: string,
  ): Promise<{ principle: Principle; suggestedActionEn: string | null }> {
    const { rows } = await query<{
      principle: string;
      suggested_action_en: string | null;
    }>(
      'select principle, suggested_action_en from exercises where id = $1',
      [exerciseId],
    );

    const row = rows[0];
    if (!row) {
      throw new RowNotFoundError('exercise', exerciseId);
    }
    return {
      principle: row.principle as Principle,
      suggestedActionEn: row.suggested_action_en,
    };
  }
}

export const exerciseRepository = new ExerciseRepository();

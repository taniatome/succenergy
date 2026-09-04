import { query } from '../config/database.js';
import type { Principle } from '../models/principle.model.js';
import { RowNotFoundError } from './errors.js';
import {
  EXERCISE_RESPONSE_COLUMNS,
  toResponseRecord,
} from './exercise_rows.js';
import type {
  ExerciseResponseRecord,
  ExerciseResponseRow,
} from './exercise_rows.js';

/** A completed session, as the service hands it down. */
export interface ExerciseResponseInput {
  exerciseId: string;

  /** Read from the library row, never taken from the client. */
  principle: Principle;

  stepResponses: Record<string, string>;

  /** The closing reflection, in the person's own words. */
  reflection: string;

  /** The action the session offered, captured as it was shown. */
  suggestedAction: string | null;
}

/**
 * The `exercise_responses` table — what a person answered, per run.
 *
 * Per-user, so every statement carries the uid. `exercise_id` has no foreign
 * key on purpose: a response is history and must survive its exercise being
 * withdrawn from the library.
 */
export class ExerciseResponseRepository {
  /** The user's responses, newest first, optionally for one exercise. */
  async list(uid: string, exerciseId?: string): Promise<ExerciseResponseRecord[]> {
    const { rows } =
      exerciseId === undefined
        ? await query<ExerciseResponseRow>(
            `select ${EXERCISE_RESPONSE_COLUMNS} from exercise_responses
              where user_id = $1
              order by completed_at desc`,
            [uid],
          )
        : await query<ExerciseResponseRow>(
            `select ${EXERCISE_RESPONSE_COLUMNS} from exercise_responses
              where user_id = $1 and exercise_id = $2
              order by completed_at desc`,
            [uid, exerciseId],
          );

    return rows.map(toResponseRecord);
  }

  async find(uid: string, responseId: string): Promise<ExerciseResponseRecord | null> {
    const { rows } = await query<ExerciseResponseRow>(
      `select ${EXERCISE_RESPONSE_COLUMNS} from exercise_responses
        where id = $1 and user_id = $2`,
      [responseId, uid],
    );

    const row = rows[0];
    return row ? toResponseRecord(row) : null;
  }

  /**
   * Records a completed run.
   *
   * The reflection is written to its own column rather than folded into
   * `step_responses`: it is not one of the exercise's declared steps, and the
   * mock layer collected it and threw it away. It is persisted here, and this
   * is now the only record of it.
   */
  async create(
    uid: string,
    input: ExerciseResponseInput,
  ): Promise<ExerciseResponseRecord> {
    const { rows } = await query<ExerciseResponseRow>(
      `insert into exercise_responses (
         user_id, exercise_id, principle, step_responses, reflection,
         suggested_action
       )
       values ($1, $2, $3, $4::jsonb, $5, $6)
       returning ${EXERCISE_RESPONSE_COLUMNS}`,
      [
        uid,
        input.exerciseId,
        input.principle,
        JSON.stringify(input.stepResponses),
        input.reflection,
        input.suggestedAction,
      ],
    );

    const row = rows[0];
    if (!row) {
      throw new RowNotFoundError('exercise_response', 'inserted');
    }
    return toResponseRecord(row);
  }

  /** Completed runs per principle, for the Progress breakdown. */
  async countByPrinciple(uid: string): Promise<Record<string, number>> {
    const { rows } = await query<{ principle: string; total: string }>(
      `select principle, count(*) as total from exercise_responses
        where user_id = $1
        group by principle`,
      [uid],
    );

    return Object.fromEntries(rows.map((row) => [row.principle, Number(row.total)]));
  }
}

export const exerciseResponseRepository = new ExerciseResponseRepository();

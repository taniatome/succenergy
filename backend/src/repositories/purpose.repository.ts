import { query } from '../config/database.js';
import type { LocalizedText } from '../models/localized_text.model.js';
import { localizedOwn } from './row_mappers.js';

interface PurposeRow {
  prompt_id: string;
  answer: string | null;
  updated_at: Date;
}

/** One saved answer, with the time it was last written. */
export interface PurposeAnswerRecord {
  promptId: string;
  answer: LocalizedText;
  updatedAt: Date;
}

/**
 * The `purpose_answers` table — the Purpose section's standing prompts.
 *
 * Keyed `(user_id, prompt_id)`, so a person can only have one answer per
 * prompt and re-answering is an upsert rather than a second row. The answer
 * is the person's own words in one language, so it is read through
 * `localizedOwn`.
 */
export class PurposeRepository {
  async list(uid: string): Promise<PurposeAnswerRecord[]> {
    const { rows } = await query<PurposeRow>(
      `select prompt_id, answer, updated_at from purpose_answers
        where user_id = $1
        order by prompt_id`,
      [uid],
    );

    return rows.map((row) => ({
      promptId: row.prompt_id,
      answer: localizedOwn(row.answer),
      updatedAt: row.updated_at,
    }));
  }

  /**
   * Writes an answer, replacing any previous one for that prompt.
   *
   * `updated_at` is set explicitly here rather than left to the trigger,
   * because the trigger fires on update and this statement is an insert on
   * first answer — without it a first answer would carry the column default
   * and a re-answer the trigger's value, which is the same thing by two
   * routes and one of them silently.
   */
  async upsert(
    uid: string,
    promptId: string,
    answer: string,
  ): Promise<PurposeAnswerRecord> {
    const { rows } = await query<PurposeRow>(
      `insert into purpose_answers (user_id, prompt_id, answer, updated_at)
       values ($1, $2, $3, now())
       on conflict (user_id, prompt_id) do update
         set answer = excluded.answer, updated_at = now()
       returning prompt_id, answer, updated_at`,
      [uid, promptId, answer],
    );

    const row = rows[0];
    return {
      promptId,
      answer: localizedOwn(row?.answer ?? answer),
      updatedAt: row?.updated_at ?? new Date(),
    };
  }
}

export const purposeRepository = new PurposeRepository();

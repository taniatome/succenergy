import { query } from '../config/database.js';
import type { OnboardingResponseDocument } from '../models/onboarding_response.model.js';
import { UserNotFoundError } from './errors.js';
import { toOnboardingDocument } from './user_rows.js';
import type { OnboardingRow } from './user_rows.js';

/**
 * The `onboarding_responses` table: one row per user, written whole.
 */
export class OnboardingRepository {
  /**
   * Writes the onboarding response, replacing any previous one.
   *
   * The assessment is submitted whole from the summary screen and is editable
   * afterwards from Profile, so a full replace is the correct semantic — a
   * merge would leave a removed focus area in place. Every column is listed
   * in the `do update`, including the ones being set back to null.
   */
  async save(
    uid: string,
    document: OnboardingResponseDocument,
  ): Promise<OnboardingResponseDocument> {
    const { rows } = await query<OnboardingRow>(
      `insert into onboarding_responses (
         user_id,
         ambition_en, ambition_pt,
         challenge_en, challenge_pt,
         main_goals_en, main_goals_pt,
         success_vision_en, success_vision_pt,
         focus_area_keys, priority_keys, motivation_balance,
         completed_at, updated_at
       )
       values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, now())
       on conflict (user_id) do update set
         ambition_en        = excluded.ambition_en,
         ambition_pt        = excluded.ambition_pt,
         challenge_en       = excluded.challenge_en,
         challenge_pt       = excluded.challenge_pt,
         main_goals_en      = excluded.main_goals_en,
         main_goals_pt      = excluded.main_goals_pt,
         success_vision_en  = excluded.success_vision_en,
         success_vision_pt  = excluded.success_vision_pt,
         focus_area_keys    = excluded.focus_area_keys,
         priority_keys      = excluded.priority_keys,
         motivation_balance = excluded.motivation_balance,
         completed_at       = excluded.completed_at
       returning *`,
      [
        uid,
        document.ambition.en ?? null,
        document.ambition.pt ?? null,
        document.challenge.en ?? null,
        document.challenge.pt ?? null,
        document.mainGoals.en ?? null,
        document.mainGoals.pt ?? null,
        document.successVision.en ?? null,
        document.successVision.pt ?? null,
        document.focusAreaKeys,
        document.priorityKeys,
        document.motivationBalance,
        document.completedAt,
      ],
    );

    const row = rows[0];
    if (!row) {
      // Unreachable: the upsert always returns a row or raises.
      throw new UserNotFoundError(uid);
    }

    return toOnboardingDocument(row);
  }
}

export const onboardingRepository = new OnboardingRepository();

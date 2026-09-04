import type { PoolClient } from 'pg';

import { query, withTransaction } from '../config/database.js';
import type { SubscriptionDocument } from '../models/subscription.model.js';
import type { UserDocument } from '../models/user.model.js';
import type { Queryable, UserProfile, UserWriteResult } from './user_contracts.js';
import { UserNotFoundError } from './errors.js';
import { buildPatch } from './patch_builder.js';
import { toDateColumn } from './row_mappers.js';
import {
  ONBOARDING_ALIASED_COLUMNS,
  onboardingFromAliases,
  SUBSCRIPTION_ALIASED_COLUMNS,
  SUBSCRIPTION_COLUMNS,
  subscriptionFromAliases,
  toSubscriptionDocument,
  toUserDocument,
  USER_COLUMNS,
  USER_PATCH_COLUMNS,
} from './user_rows.js';
import type {
  PatchColumnKey,
  SubscriptionRow,
  UserPatch,
  UserRow,
} from './user_rows.js';

/**
 * The `users` table and the two rows joined onto it.
 *
 * Nothing above this layer imports from `pg` or from `config/database.js`.
 * The snake_case columns stop here and in `user_rows.ts`, and every value is
 * an `$n` placeholder — where `update` builds a SET clause dynamically, the
 * column names come from the fixed map in `user_rows.ts`.
 */

export type { UserPatch } from './user_rows.js';
export type { UserProfile, UserWriteResult } from './user_contracts.js';
export { UserNotFoundError } from './errors.js';
const SUBSCRIPTION_BY_USER_SQL =
  `select ${SUBSCRIPTION_COLUMNS} from subscriptions where user_id = $1`;

/** The subscription row, read through either the pool or a transaction. */
async function readSubscription(
  runner: Queryable,
  uid: string,
): Promise<SubscriptionDocument | null> {
  const { rows } = await runner.query<SubscriptionRow>(SUBSCRIPTION_BY_USER_SQL, [
    uid,
  ]);
  const row = rows[0];
  return row ? toSubscriptionDocument(row) : null;
}

export class UserRepository {
  /**
   * The user row plus the onboarding and subscription rows that belong to it,
   * in one query. Left joins, so an absent child is `null` rather than a
   * missing profile.
   */
  async findProfile(uid: string): Promise<UserProfile | null> {
    const { rows } = await query<UserRow & Record<string, unknown>>(
      `select ${USER_COLUMNS},
              ${ONBOARDING_ALIASED_COLUMNS},
              ${SUBSCRIPTION_ALIASED_COLUMNS}
         from users u
         left join onboarding_responses o on o.user_id = u.id
         left join subscriptions s on s.user_id = u.id
        where u.id = $1`,
      [uid],
    );

    const row = rows[0];
    if (!row) {
      return null;
    }

    return {
      user: toUserDocument(row),
      onboarding:
        row.ob_user_id === null ? null : onboardingFromAliases(row),
      subscription:
        row.sub_user_id === null ? null : subscriptionFromAliases(row),
    };
  }

  /** The subscription row alone, for the writes that return it alongside. */
  findSubscription(uid: string): Promise<SubscriptionDocument | null> {
    return readSubscription({ query }, uid);
  }

  /**
   * Creates the user, and the subscription row alongside it, if the uid is
   * not already taken.
   *
   * `on conflict (id) do nothing` makes this atomic rather than optimistic:
   * the database decides once, and `created` says which side of that
   * decision the caller is on. Both are the same person retrying.
   */
  async create(
    uid: string,
    document: UserDocument,
  ): Promise<UserWriteResult & { created: boolean }> {
    return withTransaction(async (client) => {
      const inserted = await client.query<UserRow>(
        `insert into users (
           id, email, name, preferred_language, activity, date_of_birth,
           country_code, accepted_terms, confirmed_info_true,
           current_principle, cycle_day, day_streak,
           tone, rhythm, reminders_enabled
         )
         values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
         on conflict (id) do nothing
         returning *`,
        [
          uid,
          document.email,
          document.name,
          document.preferredLanguage,
          document.activity,
          toDateColumn(document.dateOfBirth),
          document.countryCode,
          document.acceptedTerms,
          document.confirmedInfoTrue,
          document.currentPrinciple,
          document.cycleDay,
          document.dayStreak,
          document.coachingPreferences.tone,
          document.coachingPreferences.rhythm,
          document.coachingPreferences.remindersEnabled,
        ],
      );

      const row = inserted.rows[0];
      const created = row !== undefined;

      if (created) {
        // The subscription an account starts with. Its own statement rather
        // than a trigger, so what a new account gets is visible here.
        await client.query(
          `insert into subscriptions (user_id) values ($1)
           on conflict (user_id) do nothing`,
          [uid],
        );
      }

      const user =
        row === undefined
          ? toUserDocument(await this.readExisting(client, uid))
          : toUserDocument(row);

      // Read inside the same transaction as the insert, so the subscription
      // returned is the one this call created rather than whatever a later
      // write left.
      return { user, subscription: await readSubscription(client, uid), created };
    });
  }

  /**
   * The row an `on conflict do nothing` insert declined to write. Absent
   * means the account was deleted between the two statements.
   */
  private async readExisting(client: PoolClient, uid: string): Promise<UserRow> {
    const { rows } = await client.query<UserRow>('select * from users where id = $1', [uid]);
    const found = rows[0];
    if (!found) {
      throw new UserNotFoundError(uid);
    }
    return found;
  }

  /**
   * Applies a partial update and returns the row as it now stands.
   *
   * `update … returning *` gives back exactly what was written, so there is
   * no second read for a concurrent write to slip into. `updated_at` is left
   * to the table's trigger, so a future call site cannot forget it.
   */
  async update(uid: string, patch: UserPatch): Promise<UserWriteResult> {
    const columns: Partial<Record<PatchColumnKey, unknown>> = {};

    if (patch.name !== undefined) {
      columns.name = patch.name;
    }
    if (patch.preferredLanguage !== undefined) {
      columns.preferredLanguage = patch.preferredLanguage;
    }
    if (patch.activity !== undefined) {
      columns.activity = patch.activity;
    }
    if (patch.dateOfBirth !== undefined) {
      columns.dateOfBirth = toDateColumn(patch.dateOfBirth);
    }
    if (patch.countryCode !== undefined) {
      columns.countryCode = patch.countryCode;
    }

    // Flattened here, not by the service. Only the keys actually present are
    // assigned, so patching `tone` leaves `rhythm` and `reminders_enabled`
    // exactly as they were.
    const preferences = patch.coachingPreferences;
    if (preferences?.tone !== undefined) {
      columns.tone = preferences.tone;
    }
    if (preferences?.rhythm !== undefined) {
      columns.rhythm = preferences.rhythm;
    }
    if (preferences?.remindersEnabled !== undefined) {
      columns.remindersEnabled = preferences.remindersEnabled;
    }

    const built = buildPatch(USER_PATCH_COLUMNS, columns);

    if (built.clause === '') {
      // Nothing to write. Return the row rather than issuing an update with
      // an empty SET clause, which is a syntax error.
      const profile = await this.findProfile(uid);
      if (!profile) {
        throw new UserNotFoundError(uid);
      }
      return { user: profile.user, subscription: profile.subscription };
    }

    const { rows } = await query<UserRow>(
      `update users set ${built.clause}
        where id = $${String(built.nextIndex)}
        returning *`,
      [...built.values, uid],
    );

    const row = rows[0];
    if (!row) {
      throw new UserNotFoundError(uid);
    }

    return {
      user: toUserDocument(row),
      subscription: await this.findSubscription(uid),
    };
  }

}

export const userRepository = new UserRepository();

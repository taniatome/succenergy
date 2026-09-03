import { query, withTransaction } from '../config/database.js';
import type { LocaleCode } from '../models/locale.model.js';
import type { LocalizedText } from '../models/localized_text.model.js';
import type { OnboardingResponseDocument } from '../models/onboarding_response.model.js';
import type { Principle } from '../models/principle.model.js';
import type {
  SubscriptionDocument,
  SubscriptionStatus,
  SubscriptionStore,
  SubscriptionTier,
} from '../models/subscription.model.js';
import type {
  CheckInRhythm,
  CoachingPreferences,
  CoachingTone,
  UserActivity,
  UserDocument,
} from '../models/user.model.js';

/**
 * The only layer that touches Postgres.
 *
 * Nothing above this file imports from `pg` or from `config/database.js`, so
 * the database can be swapped or mocked without a service or controller
 * knowing. Reads return documents in the camelCase shape the models declare;
 * the snake_case columns stop here.
 *
 * Two rules, both absolute:
 *
 *   * **Parameterised queries only.** No value is ever concatenated into SQL.
 *     Where a statement is built dynamically — `update` below — the column
 *     names come from a fixed map in this file and the values are always
 *     `$n` placeholders.
 *   * **One mapper per entity.** `toUserDocument`, `toOnboardingDocument` and
 *     `toSubscriptionDocument` are the only places a column name meets a
 *     field name.
 */

/** Raised when a uid has no user row. Mapped to a 404 by the service. */
export class UserNotFoundError extends Error {
  readonly uid: string;

  constructor(uid: string) {
    super('User row not found');
    this.name = 'UserNotFoundError';
    this.uid = uid;
  }
}

// --- Row shapes ------------------------------------------------------------
//
// What `pg` hands back, before mapping. `timestamptz` arrives as a Date;
// `date` arrives as a `YYYY-MM-DD` string, because `config/database.ts`
// disables node-postgres' Date parser for it — see the note there.

interface UserRow {
  id: string;
  email: string;
  name: string | null;
  preferred_language: string;
  activity: string | null;
  date_of_birth: string | null;
  country_code: string | null;
  accepted_terms: boolean;
  confirmed_info_true: boolean;
  current_principle: string;
  cycle_day: number;
  day_streak: number;
  tone: string;
  rhythm: string;
  reminders_enabled: boolean;
  created_at: Date;
  updated_at: Date;
}

interface OnboardingRow {
  ambition_en: string | null;
  ambition_pt: string | null;
  challenge_en: string | null;
  challenge_pt: string | null;
  main_goals_en: string | null;
  main_goals_pt: string | null;
  success_vision_en: string | null;
  success_vision_pt: string | null;
  focus_area_keys: string[];
  priority_keys: string[];
  motivation_balance: number | null;
  completed_at: Date | null;
  updated_at: Date;
}

interface SubscriptionRow {
  tier: string;
  status: string;
  store: string | null;
  revenue_cat_app_user_id: string | null;
  entitlement_id: string | null;
  trial_started_at: Date | null;
  trial_ends_at: Date | null;
  current_period_end: Date | null;
  updated_at: Date;
}

/** The joined profile read: the user and the two rows that hang off them. */
export interface UserProfile {
  user: UserDocument;
  onboarding: OnboardingResponseDocument | null;
  subscription: SubscriptionDocument | null;
}

/**
 * A profile patch, in the shape the domain uses.
 *
 * The service hands over camelCase fields and a nested `coachingPreferences`;
 * flattening that to the three scalar columns is this layer's job, not the
 * service's. That flattening was leaking upwards under Firestore, where the
 * service had to build dotted field paths so a nested map was not replaced
 * wholesale. It does not leak any more.
 */
export interface UserPatch {
  name?: string;
  preferredLanguage?: LocaleCode;
  activity?: UserActivity;
  dateOfBirth?: Date | null;
  countryCode?: string | null;
  coachingPreferences?: Partial<CoachingPreferences>;
}

// --- Mapping ---------------------------------------------------------------

/** Rebuilds an `{ en, pt }` map from a pair of columns, dropping absent sides. */
function localized(en: string | null, pt: string | null): LocalizedText {
  const text: LocalizedText = {};
  if (en !== null) {
    text.en = en;
  }
  if (pt !== null) {
    text.pt = pt;
  }
  return text;
}

/**
 * A `date` column to a UTC `Date`.
 *
 * The API speaks full ISO 8601 timestamps, and a calendar date has no time or
 * zone, so it is pinned to UTC midnight. Doing it here rather than letting
 * node-postgres parse it into *local* midnight is what stops a date of birth
 * shifting a day when the server is not on UTC.
 */
function fromDateColumn(value: string | null): Date | null {
  return value === null ? null : new Date(`${value}T00:00:00.000Z`);
}

/** A `Date` to the `YYYY-MM-DD` a `date` column takes, in UTC. Same reason. */
function toDateColumn(value: Date | null | undefined): string | null {
  return value === null || value === undefined
    ? null
    : value.toISOString().slice(0, 10);
}

function toUserDocument(row: UserRow): UserDocument {
  return {
    name: row.name ?? '',
    email: row.email,
    preferredLanguage: row.preferred_language as LocaleCode,
    activity: (row.activity ?? 'professional') as UserActivity,
    dateOfBirth: fromDateColumn(row.date_of_birth),
    countryCode: row.country_code,
    acceptedTerms: row.accepted_terms,
    confirmedInfoTrue: row.confirmed_info_true,
    currentPrinciple: row.current_principle as Principle,
    cycleDay: row.cycle_day,
    dayStreak: row.day_streak,
    coachingPreferences: {
      tone: row.tone as CoachingTone,
      rhythm: row.rhythm as CheckInRhythm,
      remindersEnabled: row.reminders_enabled,
    },
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function toOnboardingDocument(row: OnboardingRow): OnboardingResponseDocument {
  return {
    ambition: localized(row.ambition_en, row.ambition_pt),
    focusAreaKeys: row.focus_area_keys,
    challenge: localized(row.challenge_en, row.challenge_pt),
    priorityKeys: row.priority_keys,
    mainGoals: localized(row.main_goals_en, row.main_goals_pt),
    motivationBalance: row.motivation_balance ?? 0,
    successVision: localized(row.success_vision_en, row.success_vision_pt),
    completedAt: row.completed_at,
    updatedAt: row.updated_at,
  };
}

function toSubscriptionDocument(row: SubscriptionRow): SubscriptionDocument {
  return {
    tier: row.tier as SubscriptionTier,
    status: row.status as SubscriptionStatus,
    trialStartedAt: row.trial_started_at,
    trialEndsAt: row.trial_ends_at,
    currentPeriodEnd: row.current_period_end,
    // Null in the column, `'none'` in the model: the column is empty until a
    // real purchase happens, and the models carry an explicit value for that.
    provider: (row.store ?? 'none') as SubscriptionStore,
    revenueCatAppUserId: row.revenue_cat_app_user_id,
    entitlementId: row.entitlement_id,
    updatedAt: row.updated_at,
  };
}

// --- Column lists ----------------------------------------------------------
//
// Written out rather than `select *` so that adding a column does not
// silently change what a mapper receives, and so the aliases in the joined
// read are visible next to the columns they rename.

const USER_COLUMNS = `
  u.id, u.email, u.name, u.preferred_language, u.activity, u.date_of_birth,
  u.country_code, u.accepted_terms, u.confirmed_info_true, u.current_principle,
  u.cycle_day, u.day_streak, u.tone, u.rhythm, u.reminders_enabled,
  u.created_at, u.updated_at`;

const ONBOARDING_ALIASED_COLUMNS = `
  o.user_id            as ob_user_id,
  o.ambition_en        as ob_ambition_en,
  o.ambition_pt        as ob_ambition_pt,
  o.challenge_en       as ob_challenge_en,
  o.challenge_pt       as ob_challenge_pt,
  o.main_goals_en      as ob_main_goals_en,
  o.main_goals_pt      as ob_main_goals_pt,
  o.success_vision_en  as ob_success_vision_en,
  o.success_vision_pt  as ob_success_vision_pt,
  o.focus_area_keys    as ob_focus_area_keys,
  o.priority_keys      as ob_priority_keys,
  o.motivation_balance as ob_motivation_balance,
  o.completed_at       as ob_completed_at,
  o.updated_at         as ob_updated_at`;

const SUBSCRIPTION_ALIASED_COLUMNS = `
  s.user_id                 as sub_user_id,
  s.tier                    as sub_tier,
  s.status                  as sub_status,
  s.store                   as sub_store,
  s.revenue_cat_app_user_id as sub_revenue_cat_app_user_id,
  s.entitlement_id          as sub_entitlement_id,
  s.trial_started_at        as sub_trial_started_at,
  s.trial_ends_at           as sub_trial_ends_at,
  s.current_period_end      as sub_current_period_end,
  s.updated_at              as sub_updated_at`;

/**
 * The columns of `update`'s allow-list, camelCase field to column name.
 *
 * The **only** source of a column name in a dynamically built statement. A
 * field the client sends that is not a key here cannot reach the SQL, which
 * is what makes building the SET clause from a patch safe.
 */
const USER_PATCH_COLUMNS = {
  name: 'name',
  preferredLanguage: 'preferred_language',
  activity: 'activity',
  dateOfBirth: 'date_of_birth',
  countryCode: 'country_code',
  tone: 'tone',
  rhythm: 'rhythm',
  remindersEnabled: 'reminders_enabled',
} as const;

type PatchColumnKey = keyof typeof USER_PATCH_COLUMNS;

/** Every table a user's own data can be in, for the deletion audit count. */
const USER_DATA_COUNT_SQL = `
  select
    (select count(*) from onboarding_responses where user_id = $1)
  + (select count(*) from goals where user_id = $1)
  + (select count(*) from milestones m
       join goals g on g.id = m.goal_id where g.user_id = $1)
  + (select count(*) from action_items a
       join goals g on g.id = a.goal_id where g.user_id = $1)
  + (select count(*) from exercise_responses where user_id = $1)
  + (select count(*) from coaching_sessions where user_id = $1)
  + (select count(*) from chat_messages c
       join coaching_sessions cs on cs.id = c.session_id where cs.user_id = $1)
  + (select count(*) from purpose_answers where user_id = $1)
  + (select count(*) from notifications where user_id = $1)
  + (select count(*) from subscriptions where user_id = $1)
  + (select count(*) from progress_snapshots where user_id = $1)
  as dependent_rows`;

export class UserRepository {
  /**
   * The caller's profile: the user row plus the onboarding and subscription
   * rows that belong to it, in **one** query.
   *
   * Three round trips to fetch three rows keyed by the same uid is three
   * times the latency for no benefit — under Firestore they were three
   * documents in three places and there was no choice. Left joins, so a user
   * with no onboarding response is still returned, with `onboarding: null`.
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
        row.ob_user_id === null
          ? null
          : toOnboardingDocument({
              ambition_en: row.ob_ambition_en as string | null,
              ambition_pt: row.ob_ambition_pt as string | null,
              challenge_en: row.ob_challenge_en as string | null,
              challenge_pt: row.ob_challenge_pt as string | null,
              main_goals_en: row.ob_main_goals_en as string | null,
              main_goals_pt: row.ob_main_goals_pt as string | null,
              success_vision_en: row.ob_success_vision_en as string | null,
              success_vision_pt: row.ob_success_vision_pt as string | null,
              focus_area_keys: row.ob_focus_area_keys as string[],
              priority_keys: row.ob_priority_keys as string[],
              motivation_balance: row.ob_motivation_balance as number | null,
              completed_at: row.ob_completed_at as Date | null,
              updated_at: row.ob_updated_at as Date,
            }),
      subscription:
        row.sub_user_id === null
          ? null
          : toSubscriptionDocument({
              tier: row.sub_tier as string,
              status: row.sub_status as string,
              store: row.sub_store as string | null,
              revenue_cat_app_user_id: row.sub_revenue_cat_app_user_id as string | null,
              entitlement_id: row.sub_entitlement_id as string | null,
              trial_started_at: row.sub_trial_started_at as Date | null,
              trial_ends_at: row.sub_trial_ends_at as Date | null,
              current_period_end: row.sub_current_period_end as Date | null,
              updated_at: row.sub_updated_at as Date,
            }),
    };
  }

  /**
   * Creates the user, and the subscription row alongside it, if the uid is
   * not already taken.
   *
   * `on conflict (id) do nothing returning *` makes this **atomic** rather
   * than optimistic. Under Firestore two first requests for the same unknown
   * uid raced, one lost, and the loser re-read and hoped; here the database
   * decides, once, and `created` says which side of that decision the caller
   * is on. Both are the same person retrying, and both get the same row.
   *
   * The read on conflict is inside the same transaction as the insert, so the
   * row returned is the one that won rather than whatever a later write left.
   */
  async create(
    uid: string,
    document: UserDocument,
  ): Promise<{ user: UserDocument; created: boolean }> {
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

      if (row) {
        // The subscription an account starts with. Its own statement rather
        // than a trigger, so what a new account gets is visible in the code
        // that creates it.
        await client.query(
          `insert into subscriptions (user_id) values ($1)
           on conflict (user_id) do nothing`,
          [uid],
        );

        return { user: toUserDocument(row), created: true };
      }

      const existing = await client.query<UserRow>(
        'select * from users where id = $1',
        [uid],
      );

      const found = existing.rows[0];
      if (!found) {
        // The insert conflicted and the row is gone: the account was deleted
        // between the two statements. Nothing sensible to return.
        throw new UserNotFoundError(uid);
      }

      return { user: toUserDocument(found), created: false };
    });
  }

  /**
   * Applies a partial update and returns the row as it now stands.
   *
   * One statement: `update … returning *` gives back exactly what was
   * written, so there is no second read for a concurrent write to slip into
   * and no locally merged approximation of the result.
   *
   * `updated_at` is not set here. The trigger on the table does it, so it
   * cannot be forgotten by a future call site that patches a column directly.
   */
  async update(uid: string, patch: UserPatch): Promise<UserDocument> {
    const columns: string[] = [];
    const values: unknown[] = [];

    const assign = (key: PatchColumnKey, value: unknown): void => {
      values.push(value);
      columns.push(`${USER_PATCH_COLUMNS[key]} = $${String(values.length)}`);
    };

    if (patch.name !== undefined) {
      assign('name', patch.name);
    }
    if (patch.preferredLanguage !== undefined) {
      assign('preferredLanguage', patch.preferredLanguage);
    }
    if (patch.activity !== undefined) {
      assign('activity', patch.activity);
    }
    if (patch.dateOfBirth !== undefined) {
      assign('dateOfBirth', toDateColumn(patch.dateOfBirth));
    }
    if (patch.countryCode !== undefined) {
      assign('countryCode', patch.countryCode);
    }

    // Flattened here, not by the service. Only the keys actually present are
    // assigned, so patching `tone` leaves `rhythm` and `reminders_enabled`
    // exactly as they were.
    const preferences = patch.coachingPreferences;
    if (preferences) {
      if (preferences.tone !== undefined) {
        assign('tone', preferences.tone);
      }
      if (preferences.rhythm !== undefined) {
        assign('rhythm', preferences.rhythm);
      }
      if (preferences.remindersEnabled !== undefined) {
        assign('remindersEnabled', preferences.remindersEnabled);
      }
    }

    if (columns.length === 0) {
      // Nothing to write. Return the row rather than issuing an update with
      // an empty SET clause, which is a syntax error.
      const profile = await this.findProfile(uid);
      if (!profile) {
        throw new UserNotFoundError(uid);
      }
      return profile.user;
    }

    values.push(uid);

    const { rows } = await query<UserRow>(
      `update users set ${columns.join(', ')}
        where id = $${String(values.length)}
        returning *`,
      values,
    );

    const row = rows[0];
    if (!row) {
      throw new UserNotFoundError(uid);
    }

    return toUserDocument(row);
  }

  // --- Onboarding ---------------------------------------------------------

  /**
   * Writes the onboarding response, replacing any previous one.
   *
   * The assessment is submitted whole from the summary screen and is editable
   * afterwards from Profile, so a full replace is the correct semantic — a
   * merge would leave a removed focus area in place. Every column is listed
   * in the `do update`, including the ones being set back to null.
   *
   * Returns the stored row, so the response carries the database's own
   * `updated_at` rather than the value the caller guessed.
   */
  async saveOnboarding(
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

  // --- Deletion -----------------------------------------------------------

  /**
   * Deletes the account and everything belonging to it.
   *
   * One statement. Every child table references `users(id)` with
   * `on delete cascade`, so the database removes goals, milestones, actions,
   * exercise responses, sessions, chat messages, purpose answers,
   * notifications, the subscription, the onboarding response and the progress
   * snapshots without this code naming any of them. The hand-walked
   * subcollection sweep Firestore required is gone, and with it the risk of a
   * table added later being silently orphaned.
   *
   * The dependent rows are counted first, in the same transaction, so the
   * response can say how much was removed. That is an auditable number that
   * reveals nothing about what the rows contained.
   */
  async deleteAllData(uid: string): Promise<{ documentsDeleted: number }> {
    return withTransaction(async (client) => {
      const counted = await client.query<{ dependent_rows: string }>(
        USER_DATA_COUNT_SQL,
        [uid],
      );

      // `count(*)` is bigint, which node-postgres returns as a string so that
      // a value beyond Number.MAX_SAFE_INTEGER cannot be silently mangled.
      const dependentRows = Number(counted.rows[0]?.dependent_rows ?? '0');

      const deleted = await client.query('delete from users where id = $1', [uid]);

      return { documentsDeleted: (deleted.rowCount ?? 0) + dependentRows };
    });
  }
}

export const userRepository = new UserRepository();

import type { LocaleCode } from '../models/locale.model.js';
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
import { fromDateColumn, localizedPair } from './row_mappers.js';

/**
 * The rows, column lists and mappers behind `user.repository.ts`.
 *
 * Separated from the queries so each file stays readable: this one is the
 * shape of the data, that one is what is done with it. Both are still the
 * only layer that names a column.
 *
 * `timestamptz` arrives as a Date; `date` arrives as a `YYYY-MM-DD` string,
 * because `config/database.ts` disables node-postgres' Date parser for it —
 * see the note there.
 */

export interface UserRow {
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

export interface OnboardingRow {
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

export interface SubscriptionRow {
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

/** A profile patch, in the shape the domain uses. */
export interface UserPatch {
  name?: string;
  preferredLanguage?: LocaleCode;
  activity?: UserActivity;
  dateOfBirth?: Date | null;
  countryCode?: string | null;
  coachingPreferences?: Partial<CoachingPreferences>;
}

// --- Mappers ---------------------------------------------------------------

export function toUserDocument(row: UserRow): UserDocument {
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

export function toOnboardingDocument(
  row: OnboardingRow,
): OnboardingResponseDocument {
  return {
    ambition: localizedPair(row.ambition_en, row.ambition_pt),
    focusAreaKeys: row.focus_area_keys,
    challenge: localizedPair(row.challenge_en, row.challenge_pt),
    priorityKeys: row.priority_keys,
    mainGoals: localizedPair(row.main_goals_en, row.main_goals_pt),
    motivationBalance: row.motivation_balance ?? 0,
    successVision: localizedPair(row.success_vision_en, row.success_vision_pt),
    completedAt: row.completed_at,
    updatedAt: row.updated_at,
  };
}

export function toSubscriptionDocument(row: SubscriptionRow): SubscriptionDocument {
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

export const USER_COLUMNS = `
  u.id, u.email, u.name, u.preferred_language, u.activity, u.date_of_birth,
  u.country_code, u.accepted_terms, u.confirmed_info_true, u.current_principle,
  u.cycle_day, u.day_streak, u.tone, u.rhythm, u.reminders_enabled,
  u.created_at, u.updated_at`;

export const ONBOARDING_ALIASED_COLUMNS = `
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

export const SUBSCRIPTION_ALIASED_COLUMNS = `
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

export const SUBSCRIPTION_COLUMNS = `
  tier, status, store, revenue_cat_app_user_id, entitlement_id,
  trial_started_at, trial_ends_at, current_period_end, updated_at`;

/**
 * The columns of `update`'s allow-list, camelCase field to column name.
 *
 * The **only** source of a column name in a dynamically built statement. A
 * field the client sends that is not a key here cannot reach the SQL, which
 * is what makes building the SET clause from a patch safe.
 */
export const USER_PATCH_COLUMNS = {
  name: 'name',
  preferredLanguage: 'preferred_language',
  activity: 'activity',
  dateOfBirth: 'date_of_birth',
  countryCode: 'country_code',
  tone: 'tone',
  rhythm: 'rhythm',
  remindersEnabled: 'reminders_enabled',
} as const;

export type PatchColumnKey = keyof typeof USER_PATCH_COLUMNS;

/** Rebuilds the aliased onboarding half of the joined profile read. */
export function onboardingFromAliases(
  row: Record<string, unknown>,
): OnboardingResponseDocument {
  return toOnboardingDocument({
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
  });
}

/** Rebuilds the aliased subscription half of the joined profile read. */
export function subscriptionFromAliases(
  row: Record<string, unknown>,
): SubscriptionDocument {
  return toSubscriptionDocument({
    tier: row.sub_tier as string,
    status: row.sub_status as string,
    store: row.sub_store as string | null,
    revenue_cat_app_user_id: row.sub_revenue_cat_app_user_id as string | null,
    entitlement_id: row.sub_entitlement_id as string | null,
    trial_started_at: row.sub_trial_started_at as Date | null,
    trial_ends_at: row.sub_trial_ends_at as Date | null,
    current_period_end: row.sub_current_period_end as Date | null,
    updated_at: row.sub_updated_at as Date,
  });
}

import type { LocaleCode } from './locale.model.js';
import type { Principle } from './principle.model.js';
import type { SubscriptionResult } from './subscription.model.js';

/**
 * Table `users`, keyed by the Firebase Auth uid.
 *
 * Columns are snake_case and the repository maps them; the names below are
 * the camelCase side. Field names follow `lib/data/models/user.dart` so the API and the app agree
 * without a translation layer. Multi-word enum values go over the wire in
 * snake_case, matching the activity values the client's data model specifies.
 */

/** How direct the coach should be with this user. Dart: CoachingTone. */
export const COACHING_TONES = ['direct', 'warm', 'challenging'] as const;
export type CoachingTone = (typeof COACHING_TONES)[number];

/** How often the coach checks in. Dart: CheckInRhythm.everyOtherDay. */
export const CHECK_IN_RHYTHMS = ['daily', 'every_other_day', 'weekly'] as const;
export type CheckInRhythm = (typeof CHECK_IN_RHYTHMS)[number];

/**
 * What the person does, chosen at registration.
 *
 * Sets the monthly price after the trial, so it is captured on the account
 * rather than asked for again at the paywall. Dart: UserActivity.
 */
export const USER_ACTIVITIES = ['student_minorities', 'professional'] as const;
export type UserActivity = (typeof USER_ACTIVITIES)[number];

/** Coaching preferences, nested as the client's data model specifies. */
export interface CoachingPreferences {
  tone: CoachingTone;
  rhythm: CheckInRhythm;
  remindersEnabled: boolean;
}

/** The stored user document. Timestamps are native `Date`s, as Postgres returns them. */
export interface UserDocument {
  /** Dart `User.name`. Written by the client at registration. */
  name: string;
  email: string;

  /** Language the app is being used in. Drives bilingual content selection. */
  preferredLanguage: LocaleCode;

  activity: UserActivity;

  /** Captured at registration; null on accounts created before the field. */
  dateOfBirth: Date | null;

  /** ISO 3166-1 alpha-2 code chosen at registration. Dart `countryCode`. */
  countryCode: string | null;

  /** The two consent boxes ticked at registration, recorded separately. */
  acceptedTerms: boolean;
  confirmedInfoTrue: boolean;

  /** Where the user sits in the seven-principle cycle. */
  currentPrinciple: Principle;

  /** Day number within the current cycle, shown under the greeting. */
  cycleDay: number;

  dayStreak: number;

  coachingPreferences: CoachingPreferences;

  createdAt: Date;
  updatedAt: Date;
}

/** What the API returns. Dates are ISO 8601 strings. */
export interface UserResponse {
  id: string;
  name: string;
  email: string;
  preferredLanguage: LocaleCode;
  activity: UserActivity;
  dateOfBirth: string | null;
  countryCode: string | null;
  acceptedTerms: boolean;
  confirmedInfoTrue: boolean;
  currentPrinciple: Principle;
  cycleDay: number;
  dayStreak: number;
  coachingPreferences: CoachingPreferences;

  /** Dart `User.joinedAt`, which is the account creation time. */
  joinedAt: string;
  updatedAt: string;

  /**
   * The account's subscription, or null when it has none.
   *
   * Explicitly null rather than an omitted field. The app's launch gate has
   * to tell "this account has no subscription" apart from "the subscription
   * was not fetched", and an absent key cannot say which.
   */
  subscription: SubscriptionResult | null;
}

export const DEFAULT_COACHING_PREFERENCES: CoachingPreferences = {
  tone: 'direct',
  rhythm: 'daily',
  remindersEnabled: true,
};

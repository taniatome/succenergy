import type { Timestamp } from 'firebase-admin/firestore';

import type { LocalizedText } from './localized_text.model.js';

/**
 * `users/{uid}/onboarding/response`
 *
 * The seven answers captured across the pre-registration quiz (Q1-Q3) and the
 * post-registration assessment (Q4-Q7). Shown back on the closing summary and
 * on the editable coaching profile section of Profile.
 *
 * Free-text answers are locale maps: text the user types is written to both
 * entries because their own words are shown back verbatim. The list answers
 * are localisation keys, not display text, which is why the Dart fields are
 * named `focusAreaKeys` and `priorityKeys` and these match.
 */
export interface OnboardingResponseDocument {
  /** Q1 — what the user wants to achieve. */
  ambition: LocalizedText;

  /** Q2 — up to two life areas, as localisation keys. */
  focusAreaKeys: string[];

  /** Q3 — what is challenging them now. */
  challenge: LocalizedText;

  /** Q4 — three priorities, as localisation keys. */
  priorityKeys: string[];

  /** Q5 — main goals in their own words. */
  mainGoals: LocalizedText;

  /** Q6 — motivation balance, inner drive (0) to people they carry (1). */
  motivationBalance: number;

  /** Q7 — what success looks like. */
  successVision: LocalizedText;

  /** Null while the assessment is still partial, e.g. quiz answers only. */
  completedAt: Timestamp | null;

  updatedAt: Timestamp;
}

export interface OnboardingResponseBody {
  ambition: LocalizedText;
  focusAreaKeys: string[];
  challenge: LocalizedText;
  priorityKeys: string[];
  mainGoals: LocalizedText;
  motivationBalance: number;
  successVision: LocalizedText;
}

export interface OnboardingResponseResult extends OnboardingResponseBody {
  completedAt: string | null;
  updatedAt: string;

  /** Derived, mirroring Dart `OnboardingResponse.isComplete`. */
  isComplete: boolean;
}

/** Maximum free-text length, matching AppConstants.maxFreeTextLength. */
export const MAX_FREE_TEXT_LENGTH = 400;

/** Questions asked before registration, in the entry quiz. */
export const QUIZ_QUESTION_COUNT = 3;

/** Questions asked after registration, in the onboarding assessment. */
export const ONBOARDING_QUESTION_COUNT = 4;

/** Up to two focus areas, per the Dart Q2 selector. */
export const MAX_FOCUS_AREAS = 2;

/** Exactly three priorities, per the Dart Q4 selector. */
export const PRIORITY_COUNT = 3;

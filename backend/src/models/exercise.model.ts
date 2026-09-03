import type { LocalizedText } from './localized_text.model.js';
import type { Principle } from './principle.model.js';

/**
 * Tables `exercises` and `exercise_steps` — the shared, admin-managed
 * exercise library.
 *
 * Not per-user: the same exercises are offered to everyone, and what a
 * particular person answered lives in `exercise_responses`.
 * Exercise sessions in the app are driven entirely from `steps`; no exercise
 * content is ever hardcoded into a widget, so every prompt is bilingual here.
 */

/** The input a single exercise step asks for. Dart: ExerciseStepType. */
export const EXERCISE_STEP_TYPES = ['free_text', 'single_choice', 'scale'] as const;
export type ExerciseStepType = (typeof EXERCISE_STEP_TYPES)[number];

/** One prompt inside a guided exercise. Mirrors the Dart `ExerciseStep`. */
export interface ExerciseStepEntry {
  id: string;
  type: ExerciseStepType;
  prompt: LocalizedText;

  /** The supporting line beneath the prompt. */
  help: LocalizedText;

  /** Choices for a single_choice step, each a locale map. */
  options: LocalizedText[];

  /** Labels at each end of a scale step. */
  scaleLowLabel: LocalizedText;
  scaleHighLabel: LocalizedText;

  /**
   * Optional key this step's answer is filed under in a response document.
   * Defaults to the step id when absent; present so a later exercise can
   * feed a named field without renaming its step.
   */
  saveAs?: string;
}

export interface ExerciseDocument {
  principle: Principle;
  title: LocalizedText;

  /** The one-line description shown on the library card. Dart `summary`. */
  summary: LocalizedText;

  durationMinutes: number;
  steps: ExerciseStepEntry[];

  /** Prompt on the closing reflection screen, which follows the last step. */
  closingReflectionPrompt: LocalizedText;

  /**
   * The action offered at the end of a session, which the user can convert
   * into a goal action item. Dart `suggestedAction`.
   */
  suggestedAction: LocalizedText;

  /** Withdrawn exercises are hidden from the library without being deleted. */
  isActive: boolean;

  /** Sort position within the principle. */
  order: number;
}

export interface ExerciseResult extends ExerciseDocument {
  id: string;

  /** Steps plus the closing reflection screen. Dart `totalScreens`. */
  totalScreens: number;
}

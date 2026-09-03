import type { LocalizedText } from './localized_text.model.js';
import type { Principle } from './principle.model.js';

/**
 * Table `exercise_responses`.
 *
 * One row per completed run of an exercise, rather than one per answered
 * step: a session is reviewed as a whole, so the whole session is one read.
 * `stepResponses` is keyed by the step id (or its `saveAs`) and holds what the
 * user entered — free text, the chosen option label, or a scale value
 * rendered as text, matching the Dart `ExerciseResponse.value`.
 */
export interface ExerciseResponseDocument {
  exerciseId: string;

  /** Denormalised from the exercise so progress can group without a join. */
  principle: Principle;

  /** Step id to the answer given. */
  stepResponses: Record<string, string>;

  /**
   * The closing reflection, kept out of `stepResponses` because it is not one
   * of the exercise's declared steps. The Dart model reserves the step id
   * 'reflection' for the same reason.
   */
  reflection: string;

  /**
   * The action the session offered, captured as shown so a later wording
   * change to the exercise does not rewrite history.
   */
  suggestedAction: LocalizedText;

  completedAt: Date;
}

export interface ExerciseResponseResult
  extends Omit<ExerciseResponseDocument, 'completedAt'> {
  id: string;
  completedAt: string;
}

/**
 * The reserved key the closing reflection is stored under when responses are
 * flattened for the app, matching `ExerciseResponse.reflectionStepId`.
 */
export const REFLECTION_STEP_ID = 'reflection';

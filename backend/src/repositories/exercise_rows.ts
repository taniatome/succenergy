import type {
  ExerciseDocument,
  ExerciseStepEntry,
  ExerciseStepType,
} from '../models/exercise.model.js';
import type { ExerciseResponseDocument } from '../models/exercise_response.model.js';
import type { LocalizedText } from '../models/localized_text.model.js';
import type { Principle } from '../models/principle.model.js';
import { localizedOwn, localizedPair } from './row_mappers.js';

/**
 * The rows and mappers behind the exercise library and the answers saved
 * against it.
 *
 * The library is admin-managed and shown to everyone, so its text is stored
 * in paired `_en` / `_pt` columns and read through `localizedPair`. What a
 * person wrote in a session is their own words in one language, so it is read
 * through `localizedOwn`.
 */

export interface ExerciseRow {
  id: string;
  principle: string;
  title_en: string | null;
  title_pt: string | null;
  summary_en: string | null;
  summary_pt: string | null;
  duration_minutes: number;
  closing_reflection_prompt_en: string | null;
  closing_reflection_prompt_pt: string | null;
  suggested_action_en: string | null;
  suggested_action_pt: string | null;
  is_active: boolean;
  position: number;
}

export interface ExerciseStepRow {
  id: string;
  exercise_id: string;
  position: number;
  type: string;
  prompt_en: string | null;
  prompt_pt: string | null;
  help_en: string | null;
  help_pt: string | null;
  options: unknown;
  scale_low_label_en: string | null;
  scale_low_label_pt: string | null;
  scale_high_label_en: string | null;
  scale_high_label_pt: string | null;
  save_as: string | null;
}

export interface ExerciseResponseRow {
  id: string;
  user_id: string;
  exercise_id: string;
  principle: string;
  step_responses: unknown;
  reflection: string | null;
  suggested_action: string | null;
  completed_at: Date;
}

/** An exercise with its steps, as the repository assembles it. */
export interface ExerciseRecord extends ExerciseDocument {
  id: string;
}

/** A saved response with its id. */
export interface ExerciseResponseRecord extends ExerciseResponseDocument {
  id: string;
}

export const EXERCISE_COLUMNS = `
  id, principle, title_en, title_pt, summary_en, summary_pt,
  duration_minutes, closing_reflection_prompt_en, closing_reflection_prompt_pt,
  suggested_action_en, suggested_action_pt, is_active, position`;

export const EXERCISE_STEP_COLUMNS = `
  id, exercise_id, position, type, prompt_en, prompt_pt, help_en, help_pt,
  options, scale_low_label_en, scale_low_label_pt, scale_high_label_en,
  scale_high_label_pt, save_as`;

export const EXERCISE_RESPONSE_COLUMNS = `
  id, user_id, exercise_id, principle, step_responses, reflection,
  suggested_action, completed_at`;

/**
 * The `options` jsonb, defensively.
 *
 * The column is admin-editable in Supabase's table view, so a hand-edit can
 * put anything there. Entries that are not locale maps are dropped rather
 * than crashing the library read for every user.
 */
function toOptions(value: unknown): LocalizedText[] {
  if (!Array.isArray(value)) {
    return [];
  }
  return value.filter(
    (entry): entry is LocalizedText =>
      typeof entry === 'object' && entry !== null && !Array.isArray(entry),
  );
}

export function toStepEntry(row: ExerciseStepRow): ExerciseStepEntry {
  const entry: ExerciseStepEntry = {
    id: row.id,
    type: row.type as ExerciseStepType,
    prompt: localizedPair(row.prompt_en, row.prompt_pt),
    help: localizedPair(row.help_en, row.help_pt),
    options: toOptions(row.options),
    scaleLowLabel: localizedPair(row.scale_low_label_en, row.scale_low_label_pt),
    scaleHighLabel: localizedPair(
      row.scale_high_label_en,
      row.scale_high_label_pt,
    ),
  };

  // Absent rather than null: the model declares `saveAs` optional and the app
  // falls back to the step id when it is not there.
  if (row.save_as !== null) {
    entry.saveAs = row.save_as;
  }
  return entry;
}

export function toExerciseRecord(
  row: ExerciseRow,
  steps: ExerciseStepEntry[],
): ExerciseRecord {
  return {
    id: row.id,
    principle: row.principle as Principle,
    title: localizedPair(row.title_en, row.title_pt),
    summary: localizedPair(row.summary_en, row.summary_pt),
    durationMinutes: row.duration_minutes,
    steps,
    closingReflectionPrompt: localizedPair(
      row.closing_reflection_prompt_en,
      row.closing_reflection_prompt_pt,
    ),
    suggestedAction: localizedPair(
      row.suggested_action_en,
      row.suggested_action_pt,
    ),
    isActive: row.is_active,
    order: row.position,
  };
}

/** The `step_responses` jsonb, keeping only string answers. */
function toStepResponses(value: unknown): Record<string, string> {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) {
    return {};
  }
  const out: Record<string, string> = {};
  for (const [key, answer] of Object.entries(value)) {
    if (typeof answer === 'string') {
      out[key] = answer;
    }
  }
  return out;
}

export function toResponseRecord(
  row: ExerciseResponseRow,
): ExerciseResponseRecord {
  return {
    id: row.id,
    exerciseId: row.exercise_id,
    principle: row.principle as Principle,
    stepResponses: toStepResponses(row.step_responses),
    reflection: row.reflection ?? '',
    suggestedAction: localizedOwn(row.suggested_action),
    completedAt: row.completed_at,
  };
}

/** The allow-list for the admin exercise patch. */
export const EXERCISE_PATCH_COLUMNS = {
  principle: 'principle',
  titleEn: 'title_en',
  titlePt: 'title_pt',
  summaryEn: 'summary_en',
  summaryPt: 'summary_pt',
  durationMinutes: 'duration_minutes',
  closingReflectionPromptEn: 'closing_reflection_prompt_en',
  closingReflectionPromptPt: 'closing_reflection_prompt_pt',
  suggestedActionEn: 'suggested_action_en',
  suggestedActionPt: 'suggested_action_pt',
  isActive: 'is_active',
  position: 'position',
} as const;

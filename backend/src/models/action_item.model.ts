import type { LocalizedText } from './localized_text.model.js';

/**
 * A single concrete step inside a goal's action plan.
 *
 * Table `action_items`, keyed to `goals` with `on delete cascade`, presented
 * as the Dart `Goal.actions` list. The item flagged `isToday` is what the
 * Dashboard surfaces as the one action for the day.
 */
export interface ActionItemEntry {
  id: string;

  /** Denormalised onto the item, as the Dart model carries it. */
  goalId: string;

  title: LocalizedText;
  isDone: boolean;
  isToday: boolean;
}

export type ActionItemResult = ActionItemEntry;

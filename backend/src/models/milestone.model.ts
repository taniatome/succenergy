import type { LocalizedText } from './localized_text.model.js';

/**
 * A dated checkpoint on the way to a goal.
 *
 * Table `milestones`, keyed to `goals` with `on delete cascade`. Presented as
 * a list on the goal, because the Dart `Goal` carries `milestones` as one and
 * every screen that shows a milestone already has the goal loaded.
 */
export interface MilestoneEntry {
  id: string;
  title: LocalizedText;
  dueDate: Date;

  /** Null while the milestone is still ahead of the user. */
  reachedAt: Date | null;
}

export interface MilestoneResult {
  id: string;
  title: LocalizedText;
  dueDate: string;
  reachedAt: string | null;

  /** Derived, mirroring Dart `Milestone.isReached`. */
  isReached: boolean;
}

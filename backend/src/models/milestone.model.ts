import type { Timestamp } from 'firebase-admin/firestore';

import type { LocalizedText } from './localized_text.model.js';

/**
 * A dated checkpoint on the way to a goal.
 *
 * Embedded in the goal document rather than kept in a subcollection, because
 * the Dart `Goal` carries `milestones` as a list and every screen that shows
 * a milestone already has the goal loaded.
 */
export interface MilestoneEntry {
  id: string;
  title: LocalizedText;
  dueDate: Timestamp;

  /** Null while the milestone is still ahead of the user. */
  reachedAt: Timestamp | null;
}

export interface MilestoneResult {
  id: string;
  title: LocalizedText;
  dueDate: string;
  reachedAt: string | null;

  /** Derived, mirroring Dart `Milestone.isReached`. */
  isReached: boolean;
}

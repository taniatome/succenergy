import type { ActionItemEntry } from './action_item.model.js';
import type { LocalizedText } from './localized_text.model.js';
import type { MilestoneEntry, MilestoneResult } from './milestone.model.js';
import type { Principle } from './principle.model.js';

/**
 * Table `goals`, with `milestones` and `action_items` as child tables.
 *
 * The Dart `Goal` carries milestones and actions as lists, so the repository
 * that builds this document will join them back into arrays. Status is
 * derived from `completedAt` rather than stored alongside it, so the two can
 * never disagree — there is no `is_completed` column.
 */

export const GOAL_STATUSES = ['active', 'completed'] as const;
export type GoalStatus = (typeof GOAL_STATUSES)[number];

export interface GoalDocument {
  title: LocalizedText;

  /** Dart `Goal.why` — the reason the goal matters. */
  why: LocalizedText;

  principle: Principle;
  targetDate: Date;
  milestones: MilestoneEntry[];
  actions: ActionItemEntry[];

  /** Null while the goal is active. The single source of completion. */
  completedAt: Date | null;

  createdAt: Date;
  updatedAt: Date;
}

export interface GoalResult {
  id: string;
  title: LocalizedText;
  why: LocalizedText;
  principle: Principle;
  targetDate: string;
  milestones: MilestoneResult[];
  actions: ActionItemEntry[];
  completedAt: string | null;
  createdAt: string;
  updatedAt: string;

  /** Derived fields, mirroring the Dart getters. */
  status: GoalStatus;
  isCompleted: boolean;
  progress: number;
  actionsDone: number;
}

/** Completion from 0 to 1, derived from milestones reached. */
export function goalProgress(
  milestones: readonly MilestoneEntry[],
  completedAt: Date | null,
): number {
  if (completedAt !== null) {
    return 1;
  }
  if (milestones.length === 0) {
    return 0;
  }
  const reached = milestones.filter((milestone) => milestone.reachedAt !== null).length;
  return reached / milestones.length;
}

import { goalProgress } from '../models/goal.model.js';
import type { GoalResult } from '../models/goal.model.js';
import type { MilestoneEntry, MilestoneResult } from '../models/milestone.model.js';
import type { GoalRecord } from '../repositories/goal_rows.js';
import { toIso } from './caller.js';

/**
 * Stored goals to the API shape.
 *
 * `status`, `isCompleted`, `progress` and `actionsDone` are derived here from
 * the same rules the Dart getters use, so the two cannot disagree and no
 * screen has to compute them from a list it may have filtered.
 *
 * Plain functions rather than static methods: they are passed straight to
 * `map`, and a method handed over as a callback loses its receiver.
 */
export function toMilestoneResult(milestone: MilestoneEntry): MilestoneResult {
  return {
    id: milestone.id,
    title: milestone.title,
    dueDate: toIso(milestone.dueDate),
    reachedAt: toIso(milestone.reachedAt),
    isReached: milestone.reachedAt !== null,
  };
}

export function toGoalResult(record: GoalRecord): GoalResult {
  return {
    id: record.id,
    title: record.title,
    why: record.why,
    principle: record.principle,
    targetDate: record.targetDate.toISOString(),
    milestones: record.milestones.map(toMilestoneResult),
    actions: record.actions,
    completedAt: toIso(record.completedAt),
    createdAt: record.createdAt.toISOString(),
    updatedAt: record.updatedAt.toISOString(),
    status: record.completedAt === null ? 'active' : 'completed',
    isCompleted: record.completedAt !== null,
    progress: goalProgress(record.milestones, record.completedAt),
    actionsDone: record.actions.filter((action) => action.isDone).length,
  };
}

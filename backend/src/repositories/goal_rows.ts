import type { ActionItemEntry } from '../models/action_item.model.js';
import type { GoalDocument } from '../models/goal.model.js';
import type { MilestoneEntry } from '../models/milestone.model.js';
import type { Principle } from '../models/principle.model.js';
import { fromDateColumn, localizedOwn } from './row_mappers.js';

/**
 * The rows and mappers behind `goal.repository.ts`.
 *
 * Goal, milestone and action titles live in a single column each — they are
 * the person's own words, in the language they wrote them — so they are read
 * through `localizedOwn`, which puts the same text under both codes. The
 * paired `_en` / `_pt` treatment is for the admin-managed library only.
 */

export interface GoalRow {
  id: string;
  user_id: string;
  title: string;
  why: string | null;
  principle: string;
  target_date: string | null;
  completed_at: Date | null;
  created_at: Date;
  updated_at: Date;
}

export interface MilestoneRow {
  id: string;
  goal_id: string;
  title: string;
  due_date: string | null;
  reached_at: Date | null;
  position: number;
}

export interface ActionRow {
  id: string;
  goal_id: string;
  title: string;
  is_done: boolean;
  is_today: boolean;
  position: number;
}

/** A goal with its children, as the repository assembles it. */
export interface GoalRecord extends GoalDocument {
  id: string;
}

export const GOAL_COLUMNS = `
  id, user_id, title, why, principle, target_date, completed_at,
  created_at, updated_at`;

export const MILESTONE_COLUMNS = `
  id, goal_id, title, due_date, reached_at, position`;

export const ACTION_COLUMNS = `
  id, goal_id, title, is_done, is_today, position`;

// The same columns qualified, for the reads that join back through `goals`
// to prove ownership. Written out rather than derived from the lists above:
// a column list is SQL, and SQL is not assembled by string manipulation here.
export const MILESTONE_COLUMNS_M = `
  m.id, m.goal_id, m.title, m.due_date, m.reached_at, m.position`;

export const ACTION_COLUMNS_A = `
  a.id, a.goal_id, a.title, a.is_done, a.is_today, a.position`;

/**
 * A goal with no target date reads as due now.
 *
 * The column is nullable because the database does not insist on a plan
 * having a deadline, but the Dart model's `targetDate` is not — so a row
 * without one is given its creation date rather than forcing every screen to
 * handle a null it will never see in practice.
 */
export function toMilestoneEntry(row: MilestoneRow): MilestoneEntry {
  return {
    id: row.id,
    title: localizedOwn(row.title),
    dueDate: fromDateColumn(row.due_date) ?? new Date(0),
    reachedAt: row.reached_at,
  };
}

export function toActionEntry(row: ActionRow): ActionItemEntry {
  return {
    id: row.id,
    goalId: row.goal_id,
    title: localizedOwn(row.title),
    isDone: row.is_done,
    isToday: row.is_today,
  };
}

export function toGoalRecord(
  row: GoalRow,
  milestones: MilestoneEntry[],
  actions: ActionItemEntry[],
): GoalRecord {
  return {
    id: row.id,
    title: localizedOwn(row.title),
    why: localizedOwn(row.why),
    principle: row.principle as Principle,
    targetDate: fromDateColumn(row.target_date) ?? row.created_at,
    milestones,
    actions,
    completedAt: row.completed_at,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

/**
 * The allow-list for `updateGoal`'s dynamic SET clause.
 *
 * The **only** source of a column name in a built statement. A field the
 * client sends that is not a key here cannot reach the SQL.
 */
export const GOAL_PATCH_COLUMNS = {
  title: 'title',
  why: 'why',
  principle: 'principle',
  targetDate: 'target_date',
} as const;

export const MILESTONE_PATCH_COLUMNS = {
  title: 'title',
  dueDate: 'due_date',
  position: 'position',
} as const;

export const ACTION_PATCH_COLUMNS = {
  title: 'title',
  isDone: 'is_done',
  isToday: 'is_today',
  position: 'position',
} as const;

import { query } from '../config/database.js';
import type { Principle } from '../models/principle.model.js';
import { RowNotFoundError } from './errors.js';
import {
  ACTION_COLUMNS,
  ACTION_COLUMNS_A,
  GOAL_COLUMNS,
  GOAL_PATCH_COLUMNS,
  MILESTONE_COLUMNS,
  MILESTONE_COLUMNS_M,
  toActionEntry,
  toGoalRecord,
  toMilestoneEntry,
} from './goal_rows.js';
import type {
  ActionRow,
  GoalRecord,
  GoalRow,
  MilestoneRow,
} from './goal_rows.js';
import { buildPatch } from './patch_builder.js';
import { toDateColumn } from './row_mappers.js';

/** What `create` and `update` accept, in the domain's own shape. */
export interface GoalInput {
  title: string;
  why: string | null;
  principle: Principle;
  targetDate: Date | null;
}

export type GoalPatch = Partial<GoalInput>;

/**
 * The `goals` table, read with its milestones and actions attached.
 *
 * **Ownership is never inferred from the goal id.** Every statement here
 * carries `user_id` as well, so a caller who guesses another account's goal
 * id reads and writes nothing. The milestone and action tables have no
 * `user_id` of their own, so the child repository joins back through `goals`
 * for the same reason.
 */
export class GoalRepository {
  /**
   * Every goal the user has, with children, in three queries rather than one
   * per goal.
   *
   * A join would return the goal columns once per milestone-action pair and
   * leave this code de-duplicating them; three reads keyed on the same user
   * and assembled in memory is less work for the database and less code here.
   */
  async list(uid: string): Promise<GoalRecord[]> {
    const goals = await query<GoalRow>(
      `select ${GOAL_COLUMNS} from goals
        where user_id = $1
        order by completed_at nulls first, created_at desc`,
      [uid],
    );

    if (goals.rows.length === 0) {
      return [];
    }

    const [milestones, actions] = await Promise.all([
      query<MilestoneRow>(
        `select ${MILESTONE_COLUMNS_M}
           from milestones m
           join goals g on g.id = m.goal_id
          where g.user_id = $1
          order by m.position, m.due_date`,
        [uid],
      ),
      query<ActionRow>(
        `select ${ACTION_COLUMNS_A}
           from action_items a
           join goals g on g.id = a.goal_id
          where g.user_id = $1
          order by a.position`,
        [uid],
      ),
    ]);

    return goals.rows.map((row) =>
      toGoalRecord(
        row,
        milestones.rows
          .filter((m) => m.goal_id === row.id)
          .map(toMilestoneEntry),
        actions.rows.filter((a) => a.goal_id === row.id).map(toActionEntry),
      ),
    );
  }

  /** One goal with its children, or null when it is not this user's. */
  async find(uid: string, goalId: string): Promise<GoalRecord | null> {
    const goals = await query<GoalRow>(
      `select ${GOAL_COLUMNS} from goals where id = $1 and user_id = $2`,
      [goalId, uid],
    );

    const row = goals.rows[0];
    if (!row) {
      return null;
    }

    const [milestones, actions] = await Promise.all([
      query<MilestoneRow>(
        `select ${MILESTONE_COLUMNS} from milestones
          where goal_id = $1 order by position, due_date`,
        [goalId],
      ),
      query<ActionRow>(
        `select ${ACTION_COLUMNS} from action_items
          where goal_id = $1 order by position`,
        [goalId],
      ),
    ]);

    return toGoalRecord(
      row,
      milestones.rows.map(toMilestoneEntry),
      actions.rows.map(toActionEntry),
    );
  }

  /** The same read, raising rather than returning null. */
  async require(uid: string, goalId: string): Promise<GoalRecord> {
    const found = await this.find(uid, goalId);
    if (!found) {
      throw new RowNotFoundError('goal', goalId);
    }
    return found;
  }

  async create(uid: string, input: GoalInput): Promise<GoalRecord> {
    const { rows } = await query<GoalRow>(
      `insert into goals (user_id, title, why, principle, target_date)
       values ($1, $2, $3, $4, $5)
       returning ${GOAL_COLUMNS}`,
      [uid, input.title, input.why, input.principle, toDateColumn(input.targetDate)],
    );

    const row = rows[0];
    if (!row) {
      throw new RowNotFoundError('goal', 'inserted');
    }
    return toGoalRecord(row, [], []);
  }

  /**
   * Applies a partial update.
   *
   * `updated_at` is left to the table's trigger. The user id rides in the
   * `where` beside the goal id, so a patch aimed at someone else's goal
   * matches no row and raises rather than writing.
   */
  async update(uid: string, goalId: string, patch: GoalPatch): Promise<GoalRecord> {
    const columns: Partial<Record<keyof typeof GOAL_PATCH_COLUMNS, unknown>> = {};

    if (patch.title !== undefined) {
      columns.title = patch.title;
    }
    if (patch.why !== undefined) {
      columns.why = patch.why;
    }
    if (patch.principle !== undefined) {
      columns.principle = patch.principle;
    }
    if (patch.targetDate !== undefined) {
      columns.targetDate = toDateColumn(patch.targetDate);
    }

    const built = buildPatch(GOAL_PATCH_COLUMNS, columns);
    if (built.clause === '') {
      return this.require(uid, goalId);
    }

    const { rowCount } = await query(
      `update goals set ${built.clause}
        where id = $${String(built.nextIndex)}
          and user_id = $${String(built.nextIndex + 1)}`,
      [...built.values, goalId, uid],
    );

    if (rowCount === 0) {
      throw new RowNotFoundError('goal', goalId);
    }
    return this.require(uid, goalId);
  }

  /**
   * Closes a goal, or reopens it.
   *
   * `completed_at` is the single source of completion — there is no
   * `is_completed` column for it to disagree with — so closing stamps the
   * server's clock and reopening sets it back to null.
   */
  async setCompleted(
    uid: string,
    goalId: string,
    completed: boolean,
  ): Promise<GoalRecord> {
    const { rowCount } = await query(
      `update goals set completed_at = case when $1 then now() else null end
        where id = $2 and user_id = $3`,
      [completed, goalId, uid],
    );

    if (rowCount === 0) {
      throw new RowNotFoundError('goal', goalId);
    }
    return this.require(uid, goalId);
  }

  /**
   * Removes the goal. Milestones and actions go with it: both reference
   * `goals(id)` with `on delete cascade`, so this statement names neither.
   */
  async remove(uid: string, goalId: string): Promise<void> {
    const { rowCount } = await query(
      'delete from goals where id = $1 and user_id = $2',
      [goalId, uid],
    );

    if (rowCount === 0) {
      throw new RowNotFoundError('goal', goalId);
    }
  }
}

export const goalRepository = new GoalRepository();

import { query } from '../config/database.js';
import { RowNotFoundError } from './errors.js';
import { ACTION_PATCH_COLUMNS, MILESTONE_PATCH_COLUMNS } from './goal_rows.js';
import { buildPatch } from './patch_builder.js';
import { toDateColumn } from './row_mappers.js';

/** A milestone as the service hands it down. */
export interface MilestoneInput {
  title: string;
  dueDate: Date | null;
  position: number;
}

export type MilestonePatch = Partial<MilestoneInput>;

/** An action item as the service hands it down. */
export interface ActionInput {
  title: string;
  isToday: boolean;
  position: number;
}

export type ActionPatch = Partial<ActionInput & { isDone: boolean }>;

/**
 * The `milestones` and `action_items` tables — a goal's plan.
 *
 * Neither table carries a `user_id`, so **every** statement here proves
 * ownership by joining back through `goals`. A goal id from the URL is never
 * trusted on its own: the writes take the uid as well and match no row when
 * the goal belongs to someone else, so a guessed id changes nothing and
 * raises rather than silently succeeding.
 *
 * Nothing here returns the goal. The service re-reads it through the goal
 * repository afterwards, because the app works in whole goals and a partial
 * echo of one child would have to be merged into the goal it came from.
 */
export class GoalPlanRepository {
  /** `exists` over `goals`, the clause every write below carries. */
  private static readonly OWNED = `
    exists (select 1 from goals g where g.id = $GOAL and g.user_id = $USER)`;

  private static owned(goalIndex: number, userIndex: number): string {
    return GoalPlanRepository.OWNED.replace('$GOAL', `$${String(goalIndex)}`).replace(
      '$USER',
      `$${String(userIndex)}`,
    );
  }

  /** The next free position at the end of a goal's list. */
  private async nextPosition(table: 'milestones' | 'action_items', goalId: string) {
    const sql =
      table === 'milestones'
        ? 'select coalesce(max(position) + 1, 0) as next from milestones where goal_id = $1'
        : 'select coalesce(max(position) + 1, 0) as next from action_items where goal_id = $1';
    const { rows } = await query<{ next: number }>(sql, [goalId]);
    return rows[0]?.next ?? 0;
  }

  // --- Milestones ----------------------------------------------------------

  async addMilestone(
    uid: string,
    goalId: string,
    input: MilestoneInput,
  ): Promise<void> {
    const position = input.position || (await this.nextPosition('milestones', goalId));

    const { rowCount } = await query(
      `insert into milestones (goal_id, title, due_date, position)
       select $1, $2, $3, $4 where ${GoalPlanRepository.owned(1, 5)}`,
      [goalId, input.title, toDateColumn(input.dueDate), position, uid],
    );

    if (rowCount === 0) {
      throw new RowNotFoundError('goal', goalId);
    }
  }

  async updateMilestone(
    uid: string,
    goalId: string,
    milestoneId: string,
    patch: MilestonePatch,
  ): Promise<void> {
    const columns: Partial<Record<keyof typeof MILESTONE_PATCH_COLUMNS, unknown>> = {};

    if (patch.title !== undefined) {
      columns.title = patch.title;
    }
    if (patch.dueDate !== undefined) {
      columns.dueDate = toDateColumn(patch.dueDate);
    }
    if (patch.position !== undefined) {
      columns.position = patch.position;
    }

    const built = buildPatch(MILESTONE_PATCH_COLUMNS, columns);
    if (built.clause === '') {
      return;
    }

    const idIndex = built.nextIndex;
    const { rowCount } = await query(
      `update milestones set ${built.clause}
        where id = $${String(idIndex)}
          and goal_id = $${String(idIndex + 1)}
          and ${GoalPlanRepository.owned(idIndex + 1, idIndex + 2)}`,
      [...built.values, milestoneId, goalId, uid],
    );

    if (rowCount === 0) {
      throw new RowNotFoundError('milestone', milestoneId);
    }
  }

  /**
   * Marks a milestone reached, or puts it back ahead of the person.
   *
   * `reached_at` is the single source of that state, so reaching stamps the
   * server's clock and un-reaching sets it back to null.
   */
  async setMilestoneReached(
    uid: string,
    goalId: string,
    milestoneId: string,
    reached: boolean,
  ): Promise<void> {
    const { rowCount } = await query(
      `update milestones
          set reached_at = case when $1 then now() else null end
        where id = $2 and goal_id = $3 and ${GoalPlanRepository.owned(3, 4)}`,
      [reached, milestoneId, goalId, uid],
    );

    if (rowCount === 0) {
      throw new RowNotFoundError('milestone', milestoneId);
    }
  }

  async removeMilestone(
    uid: string,
    goalId: string,
    milestoneId: string,
  ): Promise<void> {
    const { rowCount } = await query(
      `delete from milestones
        where id = $1 and goal_id = $2 and ${GoalPlanRepository.owned(2, 3)}`,
      [milestoneId, goalId, uid],
    );

    if (rowCount === 0) {
      throw new RowNotFoundError('milestone', milestoneId);
    }
  }

  // --- Action items --------------------------------------------------------

  async addAction(uid: string, goalId: string, input: ActionInput): Promise<void> {
    const position = input.position || (await this.nextPosition('action_items', goalId));

    const { rowCount } = await query(
      `insert into action_items (goal_id, title, is_today, position)
       select $1, $2, $3, $4 where ${GoalPlanRepository.owned(1, 5)}`,
      [goalId, input.title, input.isToday, position, uid],
    );

    if (rowCount === 0) {
      throw new RowNotFoundError('goal', goalId);
    }
  }

  async updateAction(
    uid: string,
    goalId: string,
    actionId: string,
    patch: ActionPatch,
  ): Promise<void> {
    const columns: Partial<Record<keyof typeof ACTION_PATCH_COLUMNS, unknown>> = {};

    if (patch.title !== undefined) {
      columns.title = patch.title;
    }
    if (patch.isDone !== undefined) {
      columns.isDone = patch.isDone;
    }
    if (patch.isToday !== undefined) {
      columns.isToday = patch.isToday;
    }
    if (patch.position !== undefined) {
      columns.position = patch.position;
    }

    const built = buildPatch(ACTION_PATCH_COLUMNS, columns);
    if (built.clause === '') {
      return;
    }

    const idIndex = built.nextIndex;
    const { rowCount } = await query(
      `update action_items set ${built.clause}
        where id = $${String(idIndex)}
          and goal_id = $${String(idIndex + 1)}
          and ${GoalPlanRepository.owned(idIndex + 1, idIndex + 2)}`,
      [...built.values, actionId, goalId, uid],
    );

    if (rowCount === 0) {
      throw new RowNotFoundError('action_item', actionId);
    }
  }

  async removeAction(uid: string, goalId: string, actionId: string): Promise<void> {
    const { rowCount } = await query(
      `delete from action_items
        where id = $1 and goal_id = $2 and ${GoalPlanRepository.owned(2, 3)}`,
      [actionId, goalId, uid],
    );

    if (rowCount === 0) {
      throw new RowNotFoundError('action_item', actionId);
    }
  }
}

export const goalPlanRepository = new GoalPlanRepository();

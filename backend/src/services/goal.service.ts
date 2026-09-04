import type { GoalResult } from '../models/goal.model.js';
import { RowNotFoundError } from '../repositories/errors.js';
import { goalPlanRepository } from '../repositories/goal_plan.repository.js';
import type { GoalPlanRepository } from '../repositories/goal_plan.repository.js';
import { goalRepository } from '../repositories/goal.repository.js';
import type { GoalRepository } from '../repositories/goal.repository.js';
import type {
  CreateActionInput,
  CreateGoalInput,
  CreateMilestoneInput,
  UpdateActionInput,
  UpdateGoalInput,
  UpdateMilestoneInput,
} from '../schemas/goal.schema.js';
import { ApiError } from '../utils/api_error.js';
import { parseIso, type Caller } from './caller.js';
import { toGoalResult } from './goal_mappers.js';

/**
 * Goals, their milestones and their action plans.
 *
 * Every mutation answers with the whole goal rather than the row it touched.
 * The app works in whole goals — checking an action off re-renders the
 * progress ring, the milestone timeline and the actions-done count — so
 * returning a fragment would only make the client merge it back.
 */
export class GoalService {
  private readonly goals: GoalRepository;
  private readonly plans: GoalPlanRepository;

  constructor(
    goals: GoalRepository = goalRepository,
    plans: GoalPlanRepository = goalPlanRepository,
  ) {
    this.goals = goals;
    this.plans = plans;
  }

  // --- Goals --------------------------------------------------------------

  async list(caller: Caller): Promise<GoalResult[]> {
    const records = await this.goals.list(caller.uid);
    return records.map(toGoalResult);
  }

  async get(caller: Caller, goalId: string): Promise<GoalResult> {
    const record = await this.goals.find(caller.uid, goalId);
    if (!record) {
      throw ApiError.notFound('Goal not found');
    }
    return toGoalResult(record);
  }

  async create(caller: Caller, input: CreateGoalInput): Promise<GoalResult> {
    const created = await this.goals.create(caller.uid, {
      title: input.title,
      why: input.why ?? null,
      principle: input.principle,
      targetDate: parseIso(input.targetDate),
    });
    return toGoalResult(created);
  }

  async update(
    caller: Caller,
    goalId: string,
    input: UpdateGoalInput,
  ): Promise<GoalResult> {
    return this.guard(async () => {
      const updated = await this.goals.update(caller.uid, goalId, {
        ...(input.title === undefined ? {} : { title: input.title }),
        ...(input.why === undefined ? {} : { why: input.why }),
        ...(input.principle === undefined ? {} : { principle: input.principle }),
        ...(input.targetDate === undefined
          ? {}
          : { targetDate: parseIso(input.targetDate) }),
      });
      return toGoalResult(updated);
    });
  }

  async setCompleted(
    caller: Caller,
    goalId: string,
    completed: boolean,
  ): Promise<GoalResult> {
    return this.guard(async () =>
      toGoalResult(
        await this.goals.setCompleted(caller.uid, goalId, completed),
      ),
    );
  }

  async remove(caller: Caller, goalId: string): Promise<void> {
    await this.guard(() => this.goals.remove(caller.uid, goalId));
  }

  // --- Milestones ---------------------------------------------------------

  async addMilestone(
    caller: Caller,
    goalId: string,
    input: CreateMilestoneInput,
  ): Promise<GoalResult> {
    return this.after(caller, goalId, () =>
      this.plans.addMilestone(caller.uid, goalId, {
        title: input.title,
        dueDate: parseIso(input.dueDate),
        position: input.position ?? 0,
      }),
    );
  }

  async updateMilestone(
    caller: Caller,
    goalId: string,
    milestoneId: string,
    input: UpdateMilestoneInput,
  ): Promise<GoalResult> {
    return this.after(caller, goalId, () =>
      this.plans.updateMilestone(caller.uid, goalId, milestoneId, {
        ...(input.title === undefined ? {} : { title: input.title }),
        ...(input.dueDate === undefined
          ? {}
          : { dueDate: parseIso(input.dueDate) }),
        ...(input.position === undefined ? {} : { position: input.position }),
      }),
    );
  }

  async setMilestoneReached(
    caller: Caller,
    goalId: string,
    milestoneId: string,
    reached: boolean,
  ): Promise<GoalResult> {
    return this.after(caller, goalId, () =>
      this.plans.setMilestoneReached(caller.uid, goalId, milestoneId, reached),
    );
  }

  async removeMilestone(
    caller: Caller,
    goalId: string,
    milestoneId: string,
  ): Promise<GoalResult> {
    return this.after(caller, goalId, () =>
      this.plans.removeMilestone(caller.uid, goalId, milestoneId),
    );
  }

  // --- Action items -------------------------------------------------------

  async addAction(
    caller: Caller,
    goalId: string,
    input: CreateActionInput,
  ): Promise<GoalResult> {
    return this.after(caller, goalId, () =>
      this.plans.addAction(caller.uid, goalId, {
        title: input.title,
        isToday: input.isToday ?? false,
        position: input.position ?? 0,
      }),
    );
  }

  async updateAction(
    caller: Caller,
    goalId: string,
    actionId: string,
    input: UpdateActionInput,
  ): Promise<GoalResult> {
    return this.after(caller, goalId, () =>
      this.plans.updateAction(caller.uid, goalId, actionId, input),
    );
  }

  async setActionDone(
    caller: Caller,
    goalId: string,
    actionId: string,
    isDone: boolean,
  ): Promise<GoalResult> {
    return this.after(caller, goalId, () =>
      this.plans.updateAction(caller.uid, goalId, actionId, { isDone }),
    );
  }

  async removeAction(
    caller: Caller,
    goalId: string,
    actionId: string,
  ): Promise<GoalResult> {
    return this.after(caller, goalId, () =>
      this.plans.removeAction(caller.uid, goalId, actionId),
    );
  }

  // --- Plumbing -----------------------------------------------------------

  /** Runs a plan write, then answers with the goal as it now stands. */
  private async after(
    caller: Caller,
    goalId: string,
    write: () => Promise<void>,
  ): Promise<GoalResult> {
    return this.guard(async () => {
      await write();
      return toGoalResult(await this.goals.require(caller.uid, goalId));
    });
  }

  /**
   * Turns "no such row for this user" into a 404.
   *
   * A goal that belongs to someone else and a goal that does not exist are
   * the same answer on purpose: the difference would confirm that an id is
   * real, which is not something a caller gets to learn by guessing.
   */
  private async guard<T>(run: () => Promise<T>): Promise<T> {
    try {
      return await run();
    } catch (cause) {
      if (cause instanceof RowNotFoundError) {
        throw ApiError.notFound(
          cause.entity === 'goal' ? 'Goal not found' : 'Item not found',
        );
      }
      throw cause;
    }
  }
}

export const goalService = new GoalService();

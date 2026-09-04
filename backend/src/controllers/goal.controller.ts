import type { Request, Response } from 'express';

import {
  createActionSchema,
  createGoalSchema,
  createMilestoneSchema,
  setCompletedSchema,
  setDoneSchema,
  setReachedSchema,
  updateActionSchema,
  updateGoalSchema,
  updateMilestoneSchema,
} from '../schemas/goal.schema.js';
import { goalService } from '../services/goal.service.js';
import { callerFrom } from './user.controller.js';

/**
 * HTTP layer only: parse, delegate, respond.
 *
 * Path parameters are read here and passed down as plain strings. Whether a
 * given goal belongs to the caller is not checked here and never could be —
 * that is a question about rows, and it is answered in the `where` clause of
 * every statement the repository runs.
 */

/** Path parameters are strings or absent; Express types them as optional. */
function param(req: Request, name: string): string {
  return req.params[name] ?? '';
}

/** GET /v1/me/goals */
export async function listGoals(req: Request, res: Response): Promise<void> {
  const goals = await goalService.list(callerFrom(req));
  res.json({ data: goals });
}

/** POST /v1/me/goals */
export async function createGoal(req: Request, res: Response): Promise<void> {
  const input = createGoalSchema.parse(req.body);
  const goal = await goalService.create(callerFrom(req), input);
  res.status(201).json({ data: goal });
}

/** GET /v1/me/goals/:goalId */
export async function getGoal(req: Request, res: Response): Promise<void> {
  const goal = await goalService.get(callerFrom(req), param(req, 'goalId'));
  res.json({ data: goal });
}

/** PATCH /v1/me/goals/:goalId */
export async function updateGoal(req: Request, res: Response): Promise<void> {
  const input = updateGoalSchema.parse(req.body);
  const goal = await goalService.update(
    callerFrom(req),
    param(req, 'goalId'),
    input,
  );
  res.json({ data: goal });
}

/** DELETE /v1/me/goals/:goalId */
export async function deleteGoal(req: Request, res: Response): Promise<void> {
  await goalService.remove(callerFrom(req), param(req, 'goalId'));
  res.json({ data: { deleted: true } });
}

/** PATCH /v1/me/goals/:goalId/complete */
export async function completeGoal(req: Request, res: Response): Promise<void> {
  const { completed } = setCompletedSchema.parse(req.body);
  const goal = await goalService.setCompleted(
    callerFrom(req),
    param(req, 'goalId'),
    completed,
  );
  res.json({ data: goal });
}

/** POST /v1/me/goals/:goalId/milestones */
export async function addMilestone(req: Request, res: Response): Promise<void> {
  const input = createMilestoneSchema.parse(req.body);
  const goal = await goalService.addMilestone(
    callerFrom(req),
    param(req, 'goalId'),
    input,
  );
  res.status(201).json({ data: goal });
}

/** PATCH /v1/me/goals/:goalId/milestones/:milestoneId */
export async function updateMilestone(req: Request, res: Response): Promise<void> {
  const input = updateMilestoneSchema.parse(req.body);
  const goal = await goalService.updateMilestone(
    callerFrom(req),
    param(req, 'goalId'),
    param(req, 'milestoneId'),
    input,
  );
  res.json({ data: goal });
}

/** PATCH /v1/me/goals/:goalId/milestones/:milestoneId/reach */
export async function reachMilestone(req: Request, res: Response): Promise<void> {
  const { reached } = setReachedSchema.parse(req.body);
  const goal = await goalService.setMilestoneReached(
    callerFrom(req),
    param(req, 'goalId'),
    param(req, 'milestoneId'),
    reached,
  );
  res.json({ data: goal });
}

/** DELETE /v1/me/goals/:goalId/milestones/:milestoneId */
export async function deleteMilestone(req: Request, res: Response): Promise<void> {
  const goal = await goalService.removeMilestone(
    callerFrom(req),
    param(req, 'goalId'),
    param(req, 'milestoneId'),
  );
  res.json({ data: goal });
}

/** POST /v1/me/goals/:goalId/actions */
export async function addAction(req: Request, res: Response): Promise<void> {
  const input = createActionSchema.parse(req.body);
  const goal = await goalService.addAction(
    callerFrom(req),
    param(req, 'goalId'),
    input,
  );
  res.status(201).json({ data: goal });
}

/** PATCH /v1/me/goals/:goalId/actions/:actionId */
export async function updateAction(req: Request, res: Response): Promise<void> {
  const input = updateActionSchema.parse(req.body);
  const goal = await goalService.updateAction(
    callerFrom(req),
    param(req, 'goalId'),
    param(req, 'actionId'),
    input,
  );
  res.json({ data: goal });
}

/** PATCH /v1/me/goals/:goalId/actions/:actionId/toggle */
export async function toggleAction(req: Request, res: Response): Promise<void> {
  const { isDone } = setDoneSchema.parse(req.body);
  const goal = await goalService.setActionDone(
    callerFrom(req),
    param(req, 'goalId'),
    param(req, 'actionId'),
    isDone,
  );
  res.json({ data: goal });
}

/** DELETE /v1/me/goals/:goalId/actions/:actionId */
export async function deleteAction(req: Request, res: Response): Promise<void> {
  const goal = await goalService.removeAction(
    callerFrom(req),
    param(req, 'goalId'),
    param(req, 'actionId'),
  );
  res.json({ data: goal });
}

import { Router } from 'express';

import {
  addAction,
  addMilestone,
  completeGoal,
  createGoal,
  deleteAction,
  deleteGoal,
  deleteMilestone,
  getGoal,
  listGoals,
  reachMilestone,
  toggleAction,
  updateAction,
  updateGoal,
  updateMilestone,
} from '../controllers/goal.controller.js';
import { requireAuth } from '../middleware/auth.js';
import { asyncHandler } from '../utils/async_handler.js';

/**
 * `/v1/me/goals` — the caller's own goals, their milestones and their plans.
 *
 * requireAuth is applied to the router rather than to each route, so a route
 * added later cannot be left public by omission. Every handler is wrapped in
 * asyncHandler so a rejected promise reaches the error middleware instead of
 * hanging the request.
 *
 * There is no `/v1/goals/:id`: a caller only ever addresses their own, and
 * the uid comes from the verified token rather than the path.
 */
export const goalRouter = Router();

goalRouter.use(requireAuth);

goalRouter.get('/', asyncHandler(listGoals));
goalRouter.post('/', asyncHandler(createGoal));

goalRouter.get('/:goalId', asyncHandler(getGoal));
goalRouter.patch('/:goalId', asyncHandler(updateGoal));
goalRouter.delete('/:goalId', asyncHandler(deleteGoal));
goalRouter.patch('/:goalId/complete', asyncHandler(completeGoal));

goalRouter.post('/:goalId/milestones', asyncHandler(addMilestone));
goalRouter.patch('/:goalId/milestones/:milestoneId', asyncHandler(updateMilestone));
goalRouter.delete('/:goalId/milestones/:milestoneId', asyncHandler(deleteMilestone));
goalRouter.patch(
  '/:goalId/milestones/:milestoneId/reach',
  asyncHandler(reachMilestone),
);

goalRouter.post('/:goalId/actions', asyncHandler(addAction));
goalRouter.patch('/:goalId/actions/:actionId', asyncHandler(updateAction));
goalRouter.delete('/:goalId/actions/:actionId', asyncHandler(deleteAction));
goalRouter.patch('/:goalId/actions/:actionId/toggle', asyncHandler(toggleAction));

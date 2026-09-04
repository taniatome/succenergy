import { Router } from 'express';

import {
  broadcast,
  createExercise,
  deleteExercise,
  deleteUser,
  getStats,
  getUser,
  listExercises,
  listUsers,
  reorderExercise,
  updateExercise,
} from '../controllers/admin.controller.js';
import { requireAdmin } from '../middleware/admin.js';
import { requireAuth } from '../middleware/auth.js';
import { asyncHandler } from '../utils/async_handler.js';

/**
 * `/v1/admin` — the management console.
 *
 * Both middlewares are applied to the router, in order: a verified token
 * first, then the admin claim on it. Applying them here rather than per route
 * is what makes it impossible to add an admin endpoint that is reachable
 * without the claim — the omission would have to be a deletion, not a
 * forgotten line.
 *
 * The claim is set out of band with the Admin SDK. No endpoint grants it, so
 * a compromised client cannot escalate into this router.
 */
export const adminRouter = Router();

adminRouter.use(requireAuth);
adminRouter.use(requireAdmin);

adminRouter.get('/users', asyncHandler(listUsers));
adminRouter.get('/users/:uid', asyncHandler(getUser));
adminRouter.delete('/users/:uid', asyncHandler(deleteUser));

adminRouter.get('/exercises', asyncHandler(listExercises));
adminRouter.post('/exercises', asyncHandler(createExercise));
adminRouter.patch('/exercises/:exerciseId', asyncHandler(updateExercise));
adminRouter.delete('/exercises/:exerciseId', asyncHandler(deleteExercise));
adminRouter.patch('/exercises/:exerciseId/reorder', asyncHandler(reorderExercise));

adminRouter.get('/stats', asyncHandler(getStats));
adminRouter.post('/notifications', asyncHandler(broadcast));

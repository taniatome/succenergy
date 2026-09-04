import { Router } from 'express';

import {
  getExercise,
  getResponse,
  listExercises,
  listResponses,
  submitExercise,
} from '../controllers/exercise.controller.js';
import { requireAuth } from '../middleware/auth.js';
import { asyncHandler } from '../utils/async_handler.js';

/**
 * `/v1/exercises` — the shared library.
 *
 * Authenticated but not per-user: the same exercises are offered to everyone,
 * so nothing here filters on a uid. It still requires a token, because the
 * library is the client's content and not public.
 */
export const exerciseRouter = Router();

exerciseRouter.use(requireAuth);

exerciseRouter.get('/', asyncHandler(listExercises));
exerciseRouter.get('/:exerciseId', asyncHandler(getExercise));

/**
 * `/v1/me/exercise-responses` — what this caller answered.
 *
 * A separate router because it is per-user, and mounted under `/me` where
 * everything per-user lives.
 */
export const exerciseResponseRouter = Router();

exerciseResponseRouter.use(requireAuth);

exerciseResponseRouter.get('/', asyncHandler(listResponses));
exerciseResponseRouter.post('/', asyncHandler(submitExercise));
exerciseResponseRouter.get('/:responseId', asyncHandler(getResponse));

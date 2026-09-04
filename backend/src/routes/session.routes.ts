import { Router } from 'express';

import {
  addMessage,
  endSession,
  getSession,
  listMessages,
  listSessions,
  startSession,
} from '../controllers/session.controller.js';
import { requireAuth } from '../middleware/auth.js';
import { asyncHandler } from '../utils/async_handler.js';

/**
 * `/v1/me/sessions` — the caller's coaching conversations.
 *
 * The data layer for the AI Coach. The Claude pass adds what generates a
 * reply; these routes are already the shape it will use.
 */
export const sessionRouter = Router();

sessionRouter.use(requireAuth);

sessionRouter.get('/', asyncHandler(listSessions));
sessionRouter.post('/', asyncHandler(startSession));

sessionRouter.get('/:sessionId', asyncHandler(getSession));
sessionRouter.post('/:sessionId/end', asyncHandler(endSession));

sessionRouter.get('/:sessionId/messages', asyncHandler(listMessages));
sessionRouter.post('/:sessionId/messages', asyncHandler(addMessage));

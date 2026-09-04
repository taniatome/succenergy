import { Router } from 'express';

import {
  listPurposeAnswers,
  savePurposeAnswer,
} from '../controllers/purpose.controller.js';
import { requireAuth } from '../middleware/auth.js';
import { asyncHandler } from '../utils/async_handler.js';

/** `/v1/me/purpose` — the caller's answers to the standing Purpose prompts. */
export const purposeRouter = Router();

purposeRouter.use(requireAuth);

purposeRouter.get('/', asyncHandler(listPurposeAnswers));
purposeRouter.post('/:promptId', asyncHandler(savePurposeAnswer));

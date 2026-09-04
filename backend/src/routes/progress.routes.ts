import { Router } from 'express';

import { getProgress, recordSnapshot } from '../controllers/progress.controller.js';
import { requireAuth } from '../middleware/auth.js';
import { asyncHandler } from '../utils/async_handler.js';

/** `/v1/me/progress` — the caller's derived progress summary. */
export const progressRouter = Router();

progressRouter.use(requireAuth);

progressRouter.get('/', asyncHandler(getProgress));
progressRouter.post('/snapshot', asyncHandler(recordSnapshot));

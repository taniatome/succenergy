import { Router } from 'express';

import {
  exerciseResponseRouter,
  exerciseRouter,
} from './exercise.routes.js';
import { goalRouter } from './goal.routes.js';
import { progressRouter } from './progress.routes.js';
import { purposeRouter } from './purpose.routes.js';
import { healthRouter } from './health.routes.js';
import { userRouter } from './user.routes.js';

/**
 * Router assembly, versioned under /v1.
 *
 * The version prefix is applied here rather than inside each router, so a /v2
 * is a second mount rather than an edit to every file.
 */
export const apiRouter = Router();

// Public.
apiRouter.use('/health', healthRouter);

// Authenticated. Each router applies requireAuth itself, so a route added to
// one cannot silently inherit public access from the mount point.
// Mounted before `/me` so `/me/goals` is not swallowed by the user router's
// own `/:anything` handlers if any are added later.
apiRouter.use('/exercises', exerciseRouter);
apiRouter.use('/me/goals', goalRouter);
apiRouter.use('/me/exercise-responses', exerciseResponseRouter);
apiRouter.use('/me/purpose', purposeRouter);
apiRouter.use('/me/progress', progressRouter);
apiRouter.use('/me', userRouter);

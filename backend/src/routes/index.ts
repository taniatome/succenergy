import { Router } from 'express';

import { healthRouter } from './health.routes.js';

/**
 * Router assembly, versioned under /v1.
 *
 * The version prefix is applied here rather than inside each router, so a /v2
 * is a second mount rather than an edit to every file.
 */
export const apiRouter = Router();

// Public.
apiRouter.use('/health', healthRouter);

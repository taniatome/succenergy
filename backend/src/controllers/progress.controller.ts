import type { Request, Response } from 'express';

import { progressService } from '../services/progress.service.js';
import { callerFrom } from './user.controller.js';

/** GET /v1/me/progress */
export async function getProgress(req: Request, res: Response): Promise<void> {
  const progress = await progressService.summary(callerFrom(req));
  res.json({ data: progress });
}

/**
 * POST /v1/me/progress/snapshot
 *
 * Takes no body. The figures are read server-side from what the account
 * actually shows, so the call is a request to record the day rather than a
 * report of what happened in it.
 */
export async function recordSnapshot(req: Request, res: Response): Promise<void> {
  const snapshot = await progressService.recordSnapshot(callerFrom(req));
  res.status(201).json({ data: snapshot });
}

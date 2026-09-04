import type { Request, Response } from 'express';

import {
  promptIdSchema,
  savePurposeAnswerSchema,
} from '../schemas/purpose.schema.js';
import { purposeService } from '../services/purpose.service.js';
import { callerFrom } from './user.controller.js';

/** GET /v1/me/purpose */
export async function listPurposeAnswers(
  req: Request,
  res: Response,
): Promise<void> {
  const answers = await purposeService.list(callerFrom(req));
  res.json({ data: answers });
}

/**
 * POST /v1/me/purpose/:promptId
 *
 * An upsert, so it answers 200 rather than 201: re-answering a prompt is the
 * normal case and there is no new resource to report.
 */
export async function savePurposeAnswer(
  req: Request,
  res: Response,
): Promise<void> {
  const promptId = promptIdSchema.parse(req.params.promptId);
  const { answer } = savePurposeAnswerSchema.parse(req.body);

  const saved = await purposeService.save(callerFrom(req), promptId, answer);
  res.json({ data: saved });
}

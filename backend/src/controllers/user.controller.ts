import type { Request, Response } from 'express';

import { requireUser } from '../middleware/auth.js';
import {
  bootstrapProfileSchema,
  saveOnboardingSchema,
  updateProfileSchema,
} from '../schemas/user.schema.js';
import type { Caller } from '../services/user.service.js';
import { userService } from '../services/user.service.js';

/**
 * HTTP layer only: parse, delegate, respond.
 *
 * No Firestore, no business rules. Every handler here reads as three lines
 * because anything more would be logic that belongs in the service.
 */

/** Narrows the verified request user to what the service needs. */
function callerFrom(req: Request): Caller {
  const user = requireUser(req);
  return { uid: user.uid, email: user.email };
}

/**
 * GET /v1/me
 *
 * Creates the profile when the uid is unknown, so the app never has to call a
 * registration endpoint after signing up client-side.
 */
export async function getMe(req: Request, res: Response): Promise<void> {
  const caller = callerFrom(req);

  // Registration details may ride along on the first call. Query rather than
  // body, because GET bodies are not reliably forwarded by proxies.
  const bootstrap = bootstrapProfileSchema.parse(req.query);

  const profile = await userService.getOrCreateProfile(caller, bootstrap);
  res.json({ data: profile });
}

/** PATCH /v1/me */
export async function updateMe(req: Request, res: Response): Promise<void> {
  const caller = callerFrom(req);
  const input = updateProfileSchema.parse(req.body);

  const profile = await userService.updateProfile(caller, input);
  res.json({ data: profile });
}

/**
 * DELETE /v1/me
 *
 * Returns 200 with a count rather than 204, so the caller has confirmation of
 * how much was removed instead of an empty body it has to trust.
 */
export async function deleteMe(req: Request, res: Response): Promise<void> {
  const caller = callerFrom(req);

  const result = await userService.deleteAccount(caller);
  res.json({ data: { deleted: true, documentsDeleted: result.documentsDeleted } });
}

/** GET /v1/me/onboarding */
export async function getOnboarding(req: Request, res: Response): Promise<void> {
  const caller = callerFrom(req);

  const response = await userService.getOnboarding(caller);
  res.json({ data: response });
}

/** POST /v1/me/onboarding */
export async function saveOnboarding(req: Request, res: Response): Promise<void> {
  const caller = callerFrom(req);
  const input = saveOnboardingSchema.parse(req.body);

  const response = await userService.saveOnboarding(caller, input);
  res.status(201).json({ data: response });
}

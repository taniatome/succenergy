import type { Request, Response } from 'express';

import { requireUser } from '../middleware/auth.js';
import {
  createProfileSchema,
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
 * A pure read. 404 `profile_not_found` when the uid has no document, which
 * tells the client to call POST first.
 */
export async function getMe(req: Request, res: Response): Promise<void> {
  const caller = callerFrom(req);

  const profile = await userService.getProfile(caller);
  res.json({ data: profile });
}

/**
 * POST /v1/me
 *
 * First contact: creates the profile for the authenticated uid, with whatever
 * registration collected in the body. 201 on creation, 200 when the document
 * already exists, so a retry is harmless rather than a conflict.
 */
export async function createMe(req: Request, res: Response): Promise<void> {
  const caller = callerFrom(req);
  const input = createProfileSchema.parse(req.body);

  const { profile, created } = await userService.createProfile(caller, input);
  res.status(created ? 201 : 200).json({ data: profile });
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

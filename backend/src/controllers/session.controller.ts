import type { Request, Response } from 'express';

import {
  addMessageSchema,
  endSessionSchema,
  startSessionSchema,
} from '../schemas/session.schema.js';
import { sessionService } from '../services/session.service.js';
import { callerFrom } from './user.controller.js';

function sessionId(req: Request): string {
  return req.params.sessionId ?? '';
}

/** GET /v1/me/sessions */
export async function listSessions(req: Request, res: Response): Promise<void> {
  const sessions = await sessionService.list(callerFrom(req));
  res.json({ data: sessions });
}

/**
 * POST /v1/me/sessions
 *
 * 201 on a new session, 200 when one was already open and is being resumed,
 * so the caller can tell them apart the same way POST /v1/me does.
 */
export async function startSession(req: Request, res: Response): Promise<void> {
  const input = startSessionSchema.parse(req.body ?? {});
  const { session, created } = await sessionService.start(callerFrom(req), input);
  res.status(created ? 201 : 200).json({ data: session });
}

/** GET /v1/me/sessions/:sessionId */
export async function getSession(req: Request, res: Response): Promise<void> {
  const session = await sessionService.get(callerFrom(req), sessionId(req));
  res.json({ data: session });
}

/** POST /v1/me/sessions/:sessionId/end */
export async function endSession(req: Request, res: Response): Promise<void> {
  const input = endSessionSchema.parse(req.body ?? {});
  const session = await sessionService.end(callerFrom(req), sessionId(req), input);
  res.json({ data: session });
}

/** GET /v1/me/sessions/:sessionId/messages */
export async function listMessages(req: Request, res: Response): Promise<void> {
  const messages = await sessionService.messages(callerFrom(req), sessionId(req));
  res.json({ data: messages });
}

/** POST /v1/me/sessions/:sessionId/messages */
export async function addMessage(req: Request, res: Response): Promise<void> {
  const input = addMessageSchema.parse(req.body);
  const message = await sessionService.addMessage(
    callerFrom(req),
    sessionId(req),
    input,
  );
  res.status(201).json({ data: message });
}

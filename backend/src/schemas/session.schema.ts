import { z } from 'zod';

import { MESSAGE_AUTHORS } from '../models/chat_message.model.js';
import { PRINCIPLES } from '../models/principle.model.js';

/**
 * Request validation for the coaching session endpoints.
 *
 * The message shape is fixed now and must not change: the Claude pass
 * replaces what produces a coach reply, not how one is stored.
 */
export const startSessionSchema = z
  .object({ principle: z.enum(PRINCIPLES).optional() })
  .strict();

export type StartSessionInput = z.infer<typeof startSessionSchema>;

export const endSessionSchema = z
  .object({ summary: z.string().trim().max(500).optional() })
  .strict();

export type EndSessionInput = z.infer<typeof endSessionSchema>;

/**
 * A message, from either author.
 *
 * `author` is on the body rather than inferred from the token, because both
 * sides of a conversation are written by the same authenticated caller — the
 * person's turn, and the reply generated for them.
 */
export const addMessageSchema = z
  .object({
    author: z.enum(MESSAGE_AUTHORS),
    text: z.string().trim().min(1).max(4000),
  })
  .strict();

export type AddMessageInput = z.infer<typeof addMessageSchema>;

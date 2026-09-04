import { z } from 'zod';

import { MAX_FREE_TEXT_LENGTH } from '../models/onboarding_response.model.js';

/**
 * `POST /v1/me/purpose/:promptId`.
 *
 * The prompt id is a localisation key the app resolves, not display text, so
 * it is constrained to the shape of one. An answer that is only whitespace is
 * rejected rather than stored: the app treats an empty answer as unanswered,
 * and a row holding a space would look answered and read blank.
 */
export const promptIdSchema = z
  .string()
  .trim()
  .min(1)
  .max(120)
  .regex(/^[a-zA-Z0-9_.-]+$/, 'must be a localisation key, not display text');

export const savePurposeAnswerSchema = z
  .object({ answer: z.string().trim().min(1).max(MAX_FREE_TEXT_LENGTH) })
  .strict();

export type SavePurposeAnswerInput = z.infer<typeof savePurposeAnswerSchema>;

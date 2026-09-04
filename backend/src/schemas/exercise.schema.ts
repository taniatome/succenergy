import { z } from 'zod';

import { MAX_FREE_TEXT_LENGTH } from '../models/onboarding_response.model.js';

/**
 * Request validation for the exercise endpoints.
 *
 * `principle` is absent by design. It is read from the exercise row the
 * session ran, so a client cannot file practice under a principle it did not
 * do — the same rule that keeps `email` out of `POST /v1/me`.
 */

/** A step answer: free text, a chosen option's label, or a scale value. */
const answerSchema = z.string().trim().max(MAX_FREE_TEXT_LENGTH);

export const submitExerciseSchema = z
  .object({
    exerciseId: z.string().trim().min(1).max(200),

    /** Step id (or its `saveAs`) to what the person entered. */
    stepResponses: z.record(answerSchema).default({}),

    reflection: answerSchema.default(''),

    /**
     * Accepted but not trusted for storage: the library row is the source, so
     * a later wording change cannot rewrite history and a client cannot
     * invent the action it was offered.
     */
    suggestedAction: answerSchema.optional(),
  })
  .strict();

export type SubmitExerciseInput = z.infer<typeof submitExerciseSchema>;

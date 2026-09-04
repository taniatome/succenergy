import { z } from 'zod';

import { PRINCIPLES } from '../models/principle.model.js';

/**
 * Request validation for the goal endpoints.
 *
 * Goal, milestone and action titles are the person's own words in one
 * language, so they arrive as plain strings rather than locale maps — the
 * repository stores them in a single column and the response echoes them back
 * under both codes. Library content is the bilingual case, and it is not
 * written here.
 */

/** User-authored text. Length is bounded; characters are not. */
const titleSchema = z.string().trim().min(1).max(200);
const bodySchema = z.string().trim().max(2000);

const isoDateSchema = z
  .string()
  .trim()
  .datetime({ offset: true, message: 'must be an ISO 8601 date-time' });

/**
 * A target date that has already passed is a typo, not a plan.
 *
 * Checked on create only. An existing goal keeps whatever date it has —
 * editing the title of a goal whose deadline slipped must not be refused
 * because of the deadline.
 */
const futureDateSchema = isoDateSchema.refine(
  (value) => new Date(value).getTime() > Date.now(),
  { message: 'must be in the future' },
);

export const createGoalSchema = z
  .object({
    title: titleSchema,
    why: bodySchema.optional(),
    principle: z.enum(PRINCIPLES),
    targetDate: futureDateSchema,
  })
  .strict();

export type CreateGoalInput = z.infer<typeof createGoalSchema>;

export const updateGoalSchema = z
  .object({
    title: titleSchema.optional(),
    why: bodySchema.nullable().optional(),
    principle: z.enum(PRINCIPLES).optional(),
    targetDate: isoDateSchema.nullable().optional(),
  })
  .strict()
  .refine((value) => Object.keys(value).length > 0, {
    message: 'at least one field must be provided',
  });

export type UpdateGoalInput = z.infer<typeof updateGoalSchema>;

/** `PATCH /v1/me/goals/:goalId/complete` — closing a goal, or reopening it. */
export const setCompletedSchema = z.object({ completed: z.boolean() }).strict();

export const createMilestoneSchema = z
  .object({
    title: titleSchema,
    dueDate: isoDateSchema.nullable().optional(),
    position: z.number().int().min(0).optional(),
  })
  .strict();

export type CreateMilestoneInput = z.infer<typeof createMilestoneSchema>;

export const updateMilestoneSchema = z
  .object({
    title: titleSchema.optional(),
    dueDate: isoDateSchema.nullable().optional(),
    position: z.number().int().min(0).optional(),
  })
  .strict()
  .refine((value) => Object.keys(value).length > 0, {
    message: 'at least one field must be provided',
  });

export type UpdateMilestoneInput = z.infer<typeof updateMilestoneSchema>;

/** `PATCH …/milestones/:milestoneId/reach`. */
export const setReachedSchema = z.object({ reached: z.boolean() }).strict();

export const createActionSchema = z
  .object({
    title: titleSchema,
    isToday: z.boolean().optional(),
    position: z.number().int().min(0).optional(),
  })
  .strict();

export type CreateActionInput = z.infer<typeof createActionSchema>;

export const updateActionSchema = z
  .object({
    title: titleSchema.optional(),
    isDone: z.boolean().optional(),
    isToday: z.boolean().optional(),
    position: z.number().int().min(0).optional(),
  })
  .strict()
  .refine((value) => Object.keys(value).length > 0, {
    message: 'at least one field must be provided',
  });

export type UpdateActionInput = z.infer<typeof updateActionSchema>;

/**
 * `PATCH …/actions/:actionId/toggle`.
 *
 * The new state is sent rather than flipped server-side: two taps racing on a
 * flip both invert, and the second undoes the first. Sending the intended
 * value makes the call idempotent.
 */
export const setDoneSchema = z.object({ isDone: z.boolean() }).strict();

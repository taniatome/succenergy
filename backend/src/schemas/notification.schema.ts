import { z } from 'zod';

import { NOTIFICATION_TYPES } from '../models/notification.model.js';
import { CHECK_IN_RHYTHMS } from '../models/user.model.js';

/**
 * Request validation for the notification endpoints.
 *
 * Preference keys are localisation keys the app resolves, so they are
 * constrained to that shape — a client cannot invent a key containing display
 * text, and the jsonb column cannot fill up with prose.
 */
const preferenceKeySchema = z
  .string()
  .trim()
  .min(1)
  .max(120)
  .regex(/^[a-zA-Z0-9_.-]+$/, 'must be a localisation key, not display text');

export const updatePreferencesSchema = z
  .object({
    remindersEnabled: z.boolean().optional(),
    rhythm: z.enum(CHECK_IN_RHYTHMS).optional(),

    /** Only the switches being changed. Absent keys keep their stored value. */
    types: z.record(preferenceKeySchema, z.boolean()).optional(),
  })
  .strict()
  .refine((value) => Object.keys(value).length > 0, {
    message: 'at least one field must be provided',
  });

export type UpdatePreferencesInput = z.infer<typeof updatePreferencesSchema>;

/** `POST /v1/admin/notifications` — a notification composed in the console. */
export const broadcastSchema = z
  .object({
    audience: z.enum(['all', 'trial', 'paying']),
    type: z.enum(NOTIFICATION_TYPES),
    title: z.string().trim().min(1).max(120),
    body: z.string().trim().min(1).max(500),
  })
  .strict();

export type BroadcastInput = z.infer<typeof broadcastSchema>;

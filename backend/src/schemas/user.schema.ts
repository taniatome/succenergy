import { z } from 'zod';

import { SUPPORTED_LOCALES } from '../models/locale.model.js';
import {
  MAX_FOCUS_AREAS,
  MAX_FREE_TEXT_LENGTH,
  PRIORITY_COUNT,
} from '../models/onboarding_response.model.js';
import { PRINCIPLES } from '../models/principle.model.js';
import {
  CHECK_IN_RHYTHMS,
  COACHING_TONES,
  USER_ACTIVITIES,
} from '../models/user.model.js';

/**
 * Request validation for the user endpoints.
 *
 * Everything a client sends is parsed here before a service sees it, so no
 * layer below has to defend against a missing or mistyped field.
 */

/** Bilingual free text. At least one language, both capped. */
const localizedTextSchema = z
  .object({
    en: z.string().trim().max(MAX_FREE_TEXT_LENGTH).optional(),
    pt: z.string().trim().max(MAX_FREE_TEXT_LENGTH).optional(),
  })
  .strict()
  .refine(
    (value) => SUPPORTED_LOCALES.some((locale) => (value[locale] ?? '').length > 0),
    { message: 'at least one language must carry text' },
  );

/**
 * A localisation key, not display text: the app resolves these, so anything
 * with whitespace or punctuation is a client sending the wrong thing.
 */
const localizationKeySchema = z
  .string()
  .trim()
  .min(1)
  .max(120)
  .regex(/^[a-zA-Z0-9_.-]+$/, 'must be a localisation key, not display text');

const isoDateSchema = z
  .string()
  .trim()
  .datetime({ offset: true, message: 'must be an ISO 8601 date-time' });

/** Names are user content, so length is bounded but characters are not. */
const displayNameSchema = z.string().trim().min(1).max(80);

const countryCodeSchema = z
  .string()
  .trim()
  .length(2, 'must be an ISO 3166-1 alpha-2 code')
  .regex(/^[A-Za-z]{2}$/)
  .transform((value) => value.toUpperCase());

/**
 * PATCH /v1/me
 *
 * Only fields the user owns. Absent from this schema, and therefore not
 * patchable: email, which is Firebase Auth's to change; the subscription,
 * which only verified provider webhooks may write; and cycleDay, dayStreak
 * and currentPrinciple, which the backend derives from recorded activity
 * rather than accepting from a client.
 */
export const updateProfileSchema = z
  .object({
    name: displayNameSchema.optional(),
    preferredLanguage: z.enum(SUPPORTED_LOCALES).optional(),
    activity: z.enum(USER_ACTIVITIES).optional(),
    dateOfBirth: isoDateSchema.nullable().optional(),
    countryCode: countryCodeSchema.nullable().optional(),
    coachingPreferences: z
      .object({
        tone: z.enum(COACHING_TONES).optional(),
        rhythm: z.enum(CHECK_IN_RHYTHMS).optional(),
        remindersEnabled: z.boolean().optional(),
      })
      .strict()
      .optional(),
  })
  .strict()
  .refine((value) => Object.keys(value).length > 0, {
    message: 'at least one field must be provided',
  });

export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;

/**
 * POST /v1/me/onboarding
 *
 * All seven answers in one call. The assessment is submitted as a whole from
 * the summary screen, so a partial write would leave a profile the coach
 * cannot reason about.
 */
export const saveOnboardingSchema = z
  .object({
    ambition: localizedTextSchema,
    focusAreaKeys: z.array(localizationKeySchema).min(1).max(MAX_FOCUS_AREAS),
    challenge: localizedTextSchema,
    priorityKeys: z.array(localizationKeySchema).min(1).max(PRIORITY_COUNT),
    mainGoals: localizedTextSchema,
    motivationBalance: z.number().min(0).max(1),
    successVision: localizedTextSchema,
  })
  .strict();

export type SaveOnboardingInput = z.infer<typeof saveOnboardingSchema>;

/**
 * The identity fields a client may supply on first contact, so the user
 * document created for an unknown uid carries what registration collected.
 * Everything is optional: the token alone is enough to create an account.
 */
export const bootstrapProfileSchema = z
  .object({
    name: displayNameSchema.optional(),
    preferredLanguage: z.enum(SUPPORTED_LOCALES).optional(),
    activity: z.enum(USER_ACTIVITIES).optional(),
    dateOfBirth: isoDateSchema.nullable().optional(),
    countryCode: countryCodeSchema.nullable().optional(),
    acceptedTerms: z.literal(true).optional(),
    confirmedInfoTrue: z.literal(true).optional(),
  })
  .strict();

export type BootstrapProfileInput = z.infer<typeof bootstrapProfileSchema>;

/** Exported for the seed script and later passes. */
export const principleSchema = z.enum(PRINCIPLES);
export const localizedText = localizedTextSchema;

import { z } from 'zod';

import { EXERCISE_STEP_TYPES } from '../models/exercise.model.js';
import { PRINCIPLES } from '../models/principle.model.js';

/** Request validation for the management console. */

/** Library text: bilingual, because the library is shown to everyone. */
const libraryText = z.string().trim().max(500).nullable().optional();
const longLibraryText = z.string().trim().max(2000).nullable().optional();

const stepSchema = z
  .object({
    type: z.enum(EXERCISE_STEP_TYPES),
    promptEn: libraryText,
    promptPt: libraryText,
    helpEn: libraryText,
    helpPt: libraryText,
    options: z.array(z.record(z.string().trim().max(200))).max(8).optional(),
    scaleLowLabelEn: libraryText,
    scaleLowLabelPt: libraryText,
    scaleHighLabelEn: libraryText,
    scaleHighLabelPt: libraryText,
    saveAs: z
      .string()
      .trim()
      .max(80)
      .regex(/^[a-zA-Z0-9_.-]+$/)
      .nullable()
      .optional(),
  })
  .strict();

export const createExerciseSchema = z
  .object({
    principle: z.enum(PRINCIPLES),
    titleEn: libraryText,
    titlePt: libraryText,
    summaryEn: longLibraryText,
    summaryPt: longLibraryText,
    durationMinutes: z.number().int().min(0).max(240).optional(),
    closingReflectionPromptEn: longLibraryText,
    closingReflectionPromptPt: longLibraryText,
    suggestedActionEn: longLibraryText,
    suggestedActionPt: longLibraryText,
    isActive: z.boolean().optional(),
    position: z.number().int().min(0).optional(),

    /** An exercise with no steps is not a usable exercise. */
    steps: z.array(stepSchema).min(1).max(20),
  })
  .strict();

export type CreateExerciseInput = z.infer<typeof createExerciseSchema>;

export const updateExerciseSchema = createExerciseSchema
  .partial()
  .extend({ steps: z.array(stepSchema).min(1).max(20).optional() })
  .strict()
  .refine((value) => Object.keys(value).length > 0, {
    message: 'at least one field must be provided',
  });

export type UpdateExerciseInput = z.infer<typeof updateExerciseSchema>;

export const reorderSchema = z
  .object({ position: z.number().int().min(0).max(9999) })
  .strict();

/**
 * Directory paging.
 *
 * A keyset cursor rather than a page number: an offset page shifts under the
 * reader as accounts are created. `before` is the last row of the previous
 * page — its creation time and id together, so ties are broken and the order
 * is total.
 */
export const directoryQuerySchema = z
  .object({
    limit: z.coerce.number().int().min(1).max(100).default(25),
    beforeCreatedAt: z.string().trim().datetime({ offset: true }).optional(),
    beforeId: z.string().trim().max(200).optional(),
  })
  .refine(
    (value) =>
      (value.beforeCreatedAt === undefined) === (value.beforeId === undefined),
    { message: 'beforeCreatedAt and beforeId must be sent together' },
  );

export type DirectoryQuery = z.infer<typeof directoryQuerySchema>;

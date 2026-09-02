import { config as loadDotenv } from 'dotenv';
import { z } from 'zod';

loadDotenv();

/**
 * Treats empty strings as absent.
 *
 * `.env.example` ships every name with an empty value, so a copied file
 * would otherwise satisfy a required-string check with `''` and fail later
 * somewhere less obvious.
 */
const blankToUndefined = (value: unknown): unknown =>
  typeof value === 'string' && value.trim() === '' ? undefined : value;

const optionalString = z.preprocess(blankToUndefined, z.string().min(1).optional());

const requiredString = (name: string) =>
  z.preprocess(
    blankToUndefined,
    z.string({ required_error: `${name} is required` }).min(1, `${name} must not be empty`),
  );

const envSchema = z
  .object({
    NODE_ENV: z.preprocess(
      blankToUndefined,
      z.enum(['development', 'test', 'production']).default('development'),
    ),

    PORT: z.preprocess(
      blankToUndefined,
      z.coerce.number().int().positive().max(65535).default(8080),
    ),

    GCP_PROJECT_ID: requiredString('GCP_PROJECT_ID'),
    FIREBASE_PROJECT_ID: requiredString('FIREBASE_PROJECT_ID'),

    /** Comma-separated. Empty means no browser origin is allowed. */
    CORS_ALLOWED_ORIGINS: z.preprocess(
      blankToUndefined,
      z
        .string()
        .default('')
        .transform((raw) =>
          raw
            .split(',')
            .map((origin) => origin.trim())
            .filter((origin) => origin.length > 0),
        ),
    ),

    LOG_LEVEL: z.preprocess(
      blankToUndefined,
      z
        .enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent'])
        .default('info'),
    ),

    FIRESTORE_EMULATOR_HOST: optionalString,
    FIREBASE_AUTH_EMULATOR_HOST: optionalString,

    TEST_USER_EMAIL: optionalString,
    TEST_USER_PASSWORD: optionalString,
  })
  .superRefine((value, ctx) => {
    const firestore = Boolean(value.FIRESTORE_EMULATOR_HOST);
    const auth = Boolean(value.FIREBASE_AUTH_EMULATOR_HOST);

    // Half-emulated is the worst outcome available: one half of the app would
    // read local data while the other half authenticated against production.
    if (firestore !== auth) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: [firestore ? 'FIREBASE_AUTH_EMULATOR_HOST' : 'FIRESTORE_EMULATOR_HOST'],
        message:
          'FIRESTORE_EMULATOR_HOST and FIREBASE_AUTH_EMULATOR_HOST must be set together or not at all',
      });
    }

    if (value.NODE_ENV === 'production' && (firestore || auth)) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['NODE_ENV'],
        message: 'emulator hosts must not be set when NODE_ENV is production',
      });
    }
  });

export type Env = z.infer<typeof envSchema>;

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  // Boot-time failure, before the logger exists. Names and messages only —
  // never the offending values, which may be credentials.
  const lines = parsed.error.issues.map((issue) => {
    const key = issue.path.join('.') || '(root)';
    return `  - ${key}: ${issue.message}`;
  });

  process.stderr.write(
    [
      '',
      'Invalid environment configuration. The server will not start.',
      ...lines,
      '',
      'Copy backend/.env.example to backend/.env and fill in the values.',
      '',
    ].join('\n'),
  );

  process.exit(1);
}

export const env: Env = parsed.data;

/** True when both emulator hosts are set, i.e. local development. */
export const isEmulated = Boolean(
  env.FIRESTORE_EMULATOR_HOST && env.FIREBASE_AUTH_EMULATOR_HOST,
);

export const isProduction = env.NODE_ENV === 'production';

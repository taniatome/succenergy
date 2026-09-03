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

    /**
     * Postgres connection string, local development only.
     *
     * In production the string comes from Secret Manager instead — see
     * `config/database.ts` — so that it is not readable from the Cloud Run
     * service's own configuration.
     */
    DATABASE_URL: optionalString,

    FIREBASE_AUTH_EMULATOR_HOST: optionalString,

    TEST_USER_EMAIL: optionalString,
    TEST_USER_PASSWORD: optionalString,
  })
  .superRefine((value, ctx) => {
    const production = value.NODE_ENV === 'production';

    // Outside production the connection string comes from the environment.
    // In production it comes from Secret Manager, and setting it here would
    // put a database credential into the Cloud Run service configuration,
    // readable by anyone with view access.
    if (!production && !value.DATABASE_URL) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['DATABASE_URL'],
        message: 'DATABASE_URL is required outside production',
      });
    }

    if (production && value.DATABASE_URL) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['DATABASE_URL'],
        message:
          'DATABASE_URL must not be set when NODE_ENV is production; the connection string comes from Secret Manager',
      });
    }

    // A production instance quietly authenticating against an emulator is
    // worse than one that will not start.
    if (production && value.FIREBASE_AUTH_EMULATOR_HOST) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['FIREBASE_AUTH_EMULATOR_HOST'],
        message: 'must not be set when NODE_ENV is production',
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

/**
 * True when the Auth emulator is in use, i.e. local development.
 *
 * Firebase Auth is the only Firebase service left — Firestore is gone, and
 * Postgres has no emulator, it is simply a different `DATABASE_URL`. So this
 * is now a single flag rather than a pair that had to agree.
 */
export const isEmulated = Boolean(env.FIREBASE_AUTH_EMULATOR_HOST);

export const isProduction = env.NODE_ENV === 'production';

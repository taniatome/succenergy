import { SecretManagerServiceClient } from '@google-cloud/secret-manager';

import { env, isEmulated } from './env.js';

/**
 * Secret Manager accessor.
 *
 * Secrets are referenced by name and resolved at runtime. The Claude key,
 * the embeddings key and the RevenueCat webhook secret arrive in later
 * passes, and each is a one-line addition to SECRET_NAMES rather than a code
 * change anywhere else.
 *
 * Values are cached for the lifetime of the process. Cloud Run instances are
 * short-lived enough that rotation takes effect on the next cold start; if a
 * secret ever needs rotating without a redeploy, call `clearSecretCache`.
 */

/**
 * Registry of secrets this service may read, keyed by the identifier used in
 * code. The value is the Secret Manager secret name, not the secret itself.
 */
export const SECRET_NAMES = {
  /**
   * The Supabase Postgres connection string, read by `config/database.ts` in
   * production.
   *
   * PLACEHOLDER NAME — MUST BE CONFIRMED BEFORE THE PRODUCTION DEPLOY.
   * The client is adding the entry to Secret Manager; if she names it
   * anything other than `supabase-database-url`, change the string here to
   * match. A wrong name fails the boot with a clear message rather than
   * running degraded, but it fails the deploy, so confirm it first.
   *
   * Use the **transaction pooler** string, port 6543. The direct connection
   * is IPv6-only and Cloud Run egresses over IPv4.
   *
   * The runtime service account needs `roles/secretmanager.secretAccessor`
   * on this secret specifically, never project-wide.
   */
  DATABASE_URL: 'supabase-database-url',

  // ANTHROPIC_API_KEY: 'anthropic-api-key',
  // EMBEDDINGS_API_KEY: 'embeddings-api-key',
  // REVENUECAT_WEBHOOK_SECRET: 'revenuecat-webhook-secret',
} as const satisfies Record<string, string>;

export type SecretKey = keyof typeof SECRET_NAMES;

const cache = new Map<string, string>();

let client: SecretManagerServiceClient | undefined;

function getClient(): SecretManagerServiceClient {
  client ??= new SecretManagerServiceClient();
  return client;
}

/**
 * Reads a secret by its registry key.
 *
 * Locally, values may be supplied as `SECRET_<KEY>` environment variables so
 * development does not require Secret Manager access. That shortcut is only
 * honoured under the emulators — in production the value comes from Secret
 * Manager or the request fails.
 */
export async function getSecret(key: SecretKey, version = 'latest'): Promise<string> {
  const secretName: string = SECRET_NAMES[key];
  const cacheKey = `${secretName}/${version}`;

  const cached = cache.get(cacheKey);
  if (cached !== undefined) {
    return cached;
  }

  if (isEmulated) {
    const local = process.env[`SECRET_${key}`];
    if (local !== undefined && local.trim() !== '') {
      cache.set(cacheKey, local);
      return local;
    }
  }

  const resourcePath = `projects/${env.GCP_PROJECT_ID}/secrets/${secretName}/versions/${version}`;
  const [response] = await getClient().accessSecretVersion({ name: resourcePath });

  const payload = response.payload?.data;
  if (payload === null || payload === undefined) {
    // Names only. The value is what we failed to read; it must not be logged
    // even in the failure path.
    throw new Error(`Secret "${secretName}" resolved to an empty payload`);
  }

  const value = Buffer.from(payload).toString('utf8').trim();
  cache.set(cacheKey, value);
  return value;
}

/** Drops cached values so the next read goes back to Secret Manager. */
export function clearSecretCache(): void {
  cache.clear();
}

/** Registry keys, for a boot-time check that every secret resolves. */
export function registeredSecretKeys(): SecretKey[] {
  return Object.keys(SECRET_NAMES) as SecretKey[];
}

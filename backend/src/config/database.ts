import pg from 'pg';
import type { Pool, PoolClient, PoolConfig, QueryResult, QueryResultRow } from 'pg';

import { env, isProduction } from './env.js';
import { logger } from './logger.js';
import { getSecret, SECRET_NAMES } from './secrets.js';

/**
 * The Postgres connection.
 *
 * The only file in the codebase that constructs a pool. Repositories take
 * `query` and `withTransaction` from here and never see a pool, a client or a
 * connection string.
 *
 * Supabase Postgres is the single database: application data and, from
 * the RAG migration, the vector store the coach retrieves from.
 */

const { Pool: PgPool, types } = pg;

/**
 * `date` columns come back as strings, not Dates.
 *
 * node-postgres parses a bare `date` into a JS Date at *local* midnight. On a
 * machine east of UTC, `1991-04-17` then serialises back as `1991-04-16T…Z` —
 * a date of birth silently a day early. Keeping the wire value verbatim moves
 * that conversion into the repository, where it is explicit and UTC.
 */
const DATE_OID = 1082;
types.setTypeParser(DATE_OID, (value: string) => value);

/**
 * Cloud Run scales to zero and starts instances freely, and Supabase's pool
 * on this compute tier is 15 connections in total. A large per-instance pool
 * exhausts the server pool the moment more than a couple of instances are
 * warm, so each instance keeps a small one and shares the rest.
 */
const MAX_POOL_CLIENTS = 5;

/** A connection that cannot be established in this long is not coming. */
const CONNECTION_TIMEOUT_MS = 10_000;

/** Idle clients are returned to the pooler rather than held open. */
const IDLE_TIMEOUT_MS = 30_000;

/**
 * Resolves the connection string.
 *
 * Production reads it from Secret Manager, so the value never appears in the
 * service's own configuration where anyone with Cloud Run view access could
 * read it. Locally it comes from `DATABASE_URL`.
 *
 * Exported because `scripts/migrate.ts` needs the same string and must not
 * resolve it a second way.
 */
export async function resolveConnectionString(): Promise<string> {
  if (isProduction) {
    return getSecret('DATABASE_URL');
  }

  const local = env.DATABASE_URL;
  if (local === undefined || local.trim() === '') {
    throw new Error(
      'DATABASE_URL is not set. Copy backend/.env.example to backend/.env and fill it in.',
    );
  }

  return local;
}

/**
 * Connection options shared by the pool and by the migration script.
 *
 * TLS is on by default, because the only connection that matters is the one
 * to Supabase and it crosses the public internet. `rejectUnauthorized: false`
 * is what Supabase's pooler needs: it presents a certificate signed by an
 * internal CA that is not in Node's trust store. The connection is still
 * encrypted.
 *
 * `?sslmode=disable` in the connection string turns it off, which is the only
 * way a local Postgres in Docker will connect — those images ship without a
 * certificate and refuse the SSL handshake outright. It is opt-in, per
 * connection string, and a Supabase string never carries it.
 */
export function connectionConfig(connectionString: string): PoolConfig {
  const sslDisabled = /[?&]sslmode=disable(&|$)/.test(connectionString);

  return {
    connectionString,
    ssl: sslDisabled ? false : { rejectUnauthorized: false },
    application_name: 'succenergy-api',
  };
}

let pool: Pool | undefined;

/**
 * Opens the pool. Called once from `initDatabase`.
 *
 * Errors on an idle client are logged rather than thrown: node-postgres emits
 * them on the pool, and an unhandled `error` event on an EventEmitter takes
 * the process down. A dropped idle connection is normal against a pooler that
 * recycles them.
 */
function createPool(connectionString: string): Pool {
  const created = new PgPool({
    ...connectionConfig(connectionString),
    max: MAX_POOL_CLIENTS,
    connectionTimeoutMillis: CONNECTION_TIMEOUT_MS,
    idleTimeoutMillis: IDLE_TIMEOUT_MS,
  });

  created.on('error', (err) => {
    logger.error({ err }, 'Idle Postgres client errored');
  });

  return created;
}

function requirePool(): Pool {
  if (!pool) {
    throw new Error('Database pool is not initialised. Call initDatabase() first.');
  }
  return pool;
}

/**
 * Connects and proves the database is reachable, or fails the boot.
 *
 * A service that starts without its database serves 500s until someone
 * notices. Failing here means the revision never goes healthy and Cloud Run
 * keeps the previous one serving.
 *
 * The failure message names the variable or secret that has to be right, and
 * never the value — same rule as `config/env.ts`, for the same reason.
 */
export async function initDatabase(): Promise<void> {
  if (pool) {
    return;
  }

  let connectionString: string;

  try {
    connectionString = await resolveConnectionString();
  } catch (cause) {
    fatal(
      isProduction
        ? [
            `Could not read the database connection string from Secret Manager.`,
            `  - secret: ${SECRET_NAMES.DATABASE_URL}`,
            '  - the runtime service account needs roles/secretmanager.secretAccessor on it',
          ]
        : ['  - DATABASE_URL: not set, or empty'],
      cause,
    );
  }

  const candidate = createPool(connectionString);

  try {
    const client = await candidate.connect();
    try {
      await client.query('select 1');
    } finally {
      client.release();
    }
  } catch (cause) {
    await candidate.end().catch(() => undefined);
    fatal(
      [
        '  - the host, port, user or password in the connection string is wrong,',
        '    the database is down, or this network cannot reach it',
        '  - Supabase: use the transaction pooler string on port 6543, not the',
        '    direct connection, which is IPv6-only',
      ],
      cause,
    );
  }

  pool = candidate;
  logger.info({ maxPoolClients: MAX_POOL_CLIENTS }, 'Connected to Postgres');
}

/**
 * Boot-time failure, in the same shape as `config/env.ts`.
 *
 * Names and causes only. The connection string is a credential and must not
 * reach stderr even in the failure path, so the underlying error's message is
 * printed but the string it describes is not interpolated anywhere.
 */
function fatal(lines: string[], cause: unknown): never {
  const reason = cause instanceof Error ? cause.message : String(cause);

  process.stderr.write(
    [
      '',
      'Cannot reach the database. The server will not start.',
      ...lines,
      `  - reported: ${reason}`,
      '',
    ].join('\n') + '\n',
  );

  process.exit(1);
}

/**
 * Runs a parameterised query.
 *
 * Every caller passes values as `$1`, `$2` … parameters. No SQL is ever built
 * by concatenating a value into a string — that is the one rule this module
 * exists to make easy to follow.
 */
export async function query<T extends QueryResultRow = QueryResultRow>(
  text: string,
  values: readonly unknown[] = [],
): Promise<QueryResult<T>> {
  return requirePool().query<T>(text, values as unknown[]);
}

/**
 * Runs `fn` inside a transaction, committing on return and rolling back on
 * throw.
 *
 * The client is always released, including when the rollback itself fails —
 * a leaked client would remove one of five from the pool permanently.
 */
export async function withTransaction<T>(
  fn: (client: PoolClient) => Promise<T>,
): Promise<T> {
  const client = await requirePool().connect();

  try {
    await client.query('begin');
    const result = await fn(client);
    await client.query('commit');
    return result;
  } catch (error) {
    await client.query('rollback').catch((rollbackError: unknown) => {
      logger.error({ err: rollbackError }, 'Rollback failed');
    });
    throw error;
  } finally {
    client.release();
  }
}

/**
 * Round-trips a single statement so `/v1/health/ready` can report database
 * connectivity rather than guessing from process state.
 */
export async function checkDatabaseConnectivity(): Promise<void> {
  await query('select 1');
}

/**
 * Drains the pool on shutdown.
 *
 * Cloud Run sends SIGTERM and waits; closing connections deliberately gives
 * the pooler them back rather than leaving them to time out, which matters
 * when the server-side pool is fifteen wide.
 */
export async function closeDatabase(): Promise<void> {
  if (!pool) {
    return;
  }

  const draining = pool;
  pool = undefined;
  await draining.end();
}

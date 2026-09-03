/**
 * Applies pending SQL migrations. **Local development only.**
 *
 *   npm run migrate
 *
 * Production migrations run through **Supabase's GitHub integration**, which
 * applies everything in `supabase/migrations/` on push. This script is a
 * convenience for a local database — a Docker container or a personal Supabase
 * project — so a developer does not need the Supabase CLI to get a schema.
 * It is not, and must not become, the deployment path.
 *
 * ## Why it writes to Supabase's own tracking table
 *
 * The integration records what it has applied in
 * `supabase_migrations.schema_migrations`, keyed by the **version** — the
 * timestamp prefix of the filename. If this script kept its own separate
 * table, the two would be invisible to each other and a migration applied by
 * one would be re-applied by the other. Against a real database that means
 * running `create table` twice and, for anything not written idempotently, a
 * failed deploy or a corrupted schema.
 *
 * So there is **one tracker**, and it is Supabase's. This script reads and
 * writes the same table in the same format, which makes the two mutually
 * visible: it skips whatever the integration has already applied, and the
 * integration skips whatever it has.
 *
 * ## Behaviour
 *
 *   * Migrations are `<version>_<name>.sql` files in `supabase/migrations/`,
 *     applied in filename order. The version is the leading digits, which is
 *     how the Supabase CLI derives it too.
 *   * Each migration runs inside its own transaction together with the row
 *     that records it. A migration that fails partway leaves the database
 *     exactly as it was and is not marked applied.
 *   * A transaction-scoped advisory lock serialises concurrent runs. It is
 *     transaction-scoped rather than session-scoped because Supabase's
 *     transaction pooler does not keep a session across statements.
 *   * Checksums of what *this script* applied are kept alongside, so editing
 *     an already-applied migration is caught locally. Advisory only: a
 *     migration the integration applied has no checksum here and is not
 *     complained about.
 *   * It refuses to run with `NODE_ENV=production`, and prints the host it is
 *     about to migrate so a misdirected `DATABASE_URL` is visible before
 *     anything is written.
 */

import { createHash } from 'node:crypto';
import { readdir, readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import pg from 'pg';

// Checked before `config/database.js` is imported, not inside main(). That
// module pulls in `config/env.js`, which validates the environment at import
// time and calls process.exit on failure — so a static import would have this
// script refused for the wrong reason, with a message about environment
// variables rather than about which tool owns production migrations.
if (process.env.NODE_ENV === 'production') {
  process.stderr.write(
    [
      '',
      'Refusing to run migrations with NODE_ENV=production.',
      '',
      "Production migrations go through Supabase's GitHub integration, which",
      'applies supabase/migrations/ on push. This script is a local development',
      'convenience; running it against production would make two writers to the',
      'same schema.',
      '',
    ].join('\n') + '\n',
  );
  process.exit(1);
}

const { connectionConfig, resolveConnectionString } = await import(
  '../src/config/database.js'
);

const { Client } = pg;

/**
 * `supabase/migrations/` at the repository root, not under `backend/`.
 *
 * That location is fixed by the GitHub integration, which reads from there and
 * nowhere else. This script follows it rather than keeping a second copy.
 */
const MIGRATIONS_DIR = join(
  dirname(fileURLToPath(import.meta.url)),
  '..',
  '..',
  'supabase',
  'migrations',
);

/** The schema and table the Supabase CLI and the GitHub integration use. */
const TRACKING_SCHEMA = 'supabase_migrations';
const TRACKING_TABLE = `${TRACKING_SCHEMA}.schema_migrations`;

/** Ours, for the edit guard. Kept in the same schema so it is obviously related. */
const CHECKSUM_TABLE = `${TRACKING_SCHEMA}.local_checksums`;

/**
 * Arbitrary but fixed. Any process holding this key is migrating; the number
 * itself has no meaning beyond being unlikely to collide with another
 * application's advisory locks.
 */
const ADVISORY_LOCK_KEY = 4_612_920_383;

interface Migration {
  filename: string;
  /** Timestamp prefix. What Supabase keys its tracking table by. */
  version: string;
  /** The rest of the filename, which Supabase stores alongside the version. */
  name: string;
  sql: string;
  checksum: string;
}

function checksumOf(sql: string): string {
  // Line endings are normalised first: the same file checked out on Windows
  // and on Cloud Build must not look like two different migrations.
  return createHash('sha256').update(sql.replace(/\r\n/g, '\n')).digest('hex');
}

/**
 * Splits `20260903120000_initial_schema.sql` into version and name, the same
 * way the Supabase CLI does: leading digits are the version, the remainder
 * after the underscore is the name.
 */
function parseFilename(filename: string): { version: string; name: string } | null {
  const match = /^(\d+)_(.+)\.sql$/.exec(filename);
  if (!match?.[1] || !match[2]) {
    return null;
  }
  return { version: match[1], name: match[2] };
}

async function loadMigrations(): Promise<Migration[]> {
  const entries = await readdir(MIGRATIONS_DIR);
  const filenames = entries.filter((name) => name.endsWith('.sql')).sort();

  const migrations: Migration[] = [];

  for (const filename of filenames) {
    const parsed = parseFilename(filename);

    if (!parsed) {
      // Not a hard failure here, because the integration would simply ignore
      // it too — but it is always a mistake, so it is said out loud.
      throw new Error(
        `${filename} is not named <timestamp>_<name>.sql. Supabase's GitHub ` +
          'integration derives the migration version from the leading digits ' +
          'and skips files without them, so this one would never be applied ' +
          'in production.',
      );
    }

    const sql = await readFile(join(MIGRATIONS_DIR, filename), 'utf8');
    migrations.push({
      filename,
      version: parsed.version,
      name: parsed.name,
      sql,
      checksum: checksumOf(sql),
    });
  }

  return migrations;
}

/** Host and port only. The user carries the Supabase project ref; the password is a password. */
function describeTarget(connectionString: string): string {
  try {
    const url = new URL(connectionString);
    return `${url.hostname}:${url.port || '5432'}${url.pathname}`;
  } catch {
    return '(unparseable connection string)';
  }
}

async function main(): Promise<void> {
  const migrations = await loadMigrations();

  if (migrations.length === 0) {
    console.log('\nNo migrations found in supabase/migrations.\n');
    return;
  }

  const connectionString = await resolveConnectionString();

  console.log(`\nTarget: ${describeTarget(connectionString)}`);
  console.log('This is the local-development runner. Production migrations go');
  console.log("through Supabase's GitHub integration.\n");

  const client = new Client(connectionConfig(connectionString));
  await client.connect();

  try {
    // Created outside the per-migration transactions, so the very first run
    // has somewhere to record what it applies.
    //
    // The shape matches what the Supabase CLI creates, so that a database
    // bootstrapped here is one the integration can later write to. On a real
    // Supabase project the schema and table already exist and both statements
    // are no-ops — deliberately, because this table is Supabase's and altering
    // it is not this script's business. `trackingColumns` below adapts to
    // whatever is actually there rather than changing it.
    //
    // No RLS on either table: the `supabase_migrations` schema is not one of
    // the schemas PostgREST exposes, so an anon or authenticated key cannot
    // reach it through the API at all.
    await client.query(`create schema if not exists ${TRACKING_SCHEMA}`);
    await client.query(`
      create table if not exists ${TRACKING_TABLE} (
        version    text primary key,
        statements text[],
        name       text
      )
    `);

    await client.query(`
      create table if not exists ${CHECKSUM_TABLE} (
        version    text primary key,
        checksum   text not null,
        applied_at timestamptz not null default now()
      )
    `);

    // Which of the columns we would write actually exist. Older CLI versions
    // created the table with `version` alone, and inserting into a column that
    // is not there fails the whole run.
    const { rows: trackingColumns } = await client.query<{ column_name: string }>(
      `select column_name from information_schema.columns
        where table_schema = $1 and table_name = 'schema_migrations'`,
      [TRACKING_SCHEMA],
    );
    const hasNameColumn = trackingColumns.some((row) => row.column_name === 'name');

    const { rows: applied } = await client.query<{ version: string }>(
      `select version from ${TRACKING_TABLE}`,
    );
    const appliedVersions = new Set(applied.map((row) => row.version));

    const { rows: checksums } = await client.query<{ version: string; checksum: string }>(
      `select version, checksum from ${CHECKSUM_TABLE}`,
    );
    const checksumByVersion = new Map(checksums.map((row) => [row.version, row.checksum]));

    // Only migrations this script applied have a checksum. One the integration
    // applied has none, and is not second-guessed.
    const changed = migrations.filter(
      (migration) =>
        checksumByVersion.has(migration.version) &&
        checksumByVersion.get(migration.version) !== migration.checksum,
    );

    if (changed.length > 0) {
      throw new Error(
        [
          'These migrations were edited after being applied:',
          ...changed.map((migration) => `  - ${migration.filename}`),
          '',
          'An applied migration must not change, or two databases end up with',
          'different schemas and no way to tell — and the GitHub integration',
          'will not re-apply it either. Add a new timestamped file.',
        ].join('\n'),
      );
    }

    const pending = migrations.filter(
      (migration) => !appliedVersions.has(migration.version),
    );

    if (pending.length === 0) {
      console.log(
        `Database is up to date. ${String(applied.length)} migration(s) already applied.\n`,
      );
      return;
    }

    console.log(`Applying ${String(pending.length)} migration(s):\n`);

    for (const migration of pending) {
      const startedAt = Date.now();

      try {
        await client.query('begin');
        await client.query('select pg_advisory_xact_lock($1)', [ADVISORY_LOCK_KEY]);

        // Re-checked inside the lock: a concurrent run, or the integration,
        // may have applied this between the listing above and now.
        const { rowCount } = await client.query(
          `select 1 from ${TRACKING_TABLE} where version = $1`,
          [migration.version],
        );

        if (rowCount === 0) {
          await client.query(migration.sql);

          // The same columns the CLI writes, minus `statements`, which is
          // its own record of how it split the file and is read by nothing.
          // Column names come from this file, never from input.
          if (hasNameColumn) {
            await client.query(
              `insert into ${TRACKING_TABLE} (version, name) values ($1, $2)`,
              [migration.version, migration.name],
            );
          } else {
            await client.query(`insert into ${TRACKING_TABLE} (version) values ($1)`, [
              migration.version,
            ]);
          }
          await client.query(
            `insert into ${CHECKSUM_TABLE} (version, checksum) values ($1, $2)
             on conflict (version) do update set checksum = excluded.checksum`,
            [migration.version, migration.checksum],
          );

          await client.query('commit');
          console.log(
            `  applied  ${migration.filename}  (${String(Date.now() - startedAt)}ms)`,
          );
        } else {
          await client.query('commit');
          console.log(`  skipped  ${migration.filename}  (already applied)`);
        }
      } catch (error) {
        await client.query('rollback').catch(() => undefined);
        throw new Error(
          `${migration.filename} failed and was rolled back: ${
            error instanceof Error ? error.message : String(error)
          }`,
        );
      }
    }

    console.log('\nDone.\n');
  } finally {
    await client.end();
  }
}

try {
  await main();
  process.exit(0);
} catch (error) {
  // The message only. A connection failure from `pg` can carry the host it
  // tried, and the connection string is a credential.
  console.error(
    `\nMigration failed: ${error instanceof Error ? error.message : String(error)}\n`,
  );
  process.exit(1);
}

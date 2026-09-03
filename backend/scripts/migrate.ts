/**
 * Applies pending SQL migrations.
 *
 *   npm run migrate
 *
 * Migrations are plain numbered `.sql` files in `backend/migrations/`, applied
 * in filename order. No migration framework: the client has Supabase connected
 * to a GitHub repo and has not yet said whether migrations should run through
 * that integration. Plain SQL files work either way — through the integration,
 * through this script, or pasted into the SQL editor — and stay readable to
 * someone who wants to see what the schema is.
 *
 * Behaviour:
 *
 *   * Applied filenames are recorded in `schema_migrations`. A file already
 *     recorded is skipped, so the script is safe to re-run and re-running it
 *     on an up-to-date database does nothing.
 *   * Each migration runs inside its own transaction together with the row
 *     that records it. A migration that fails partway leaves the database
 *     exactly as it was and is not marked applied.
 *   * A transaction-scoped advisory lock serialises concurrent runs. It is
 *     transaction-scoped rather than session-scoped because Supabase's
 *     transaction pooler does not keep a session across statements.
 *   * A file whose contents changed after being applied is reported and the
 *     run stops. Editing an applied migration means two databases silently
 *     disagree about their schema; the fix is a new numbered file.
 */

import { createHash } from 'node:crypto';
import { readdir, readFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import pg from 'pg';

import { connectionConfig, resolveConnectionString } from '../src/config/database.js';

const { Client } = pg;

const MIGRATIONS_DIR = join(dirname(fileURLToPath(import.meta.url)), '..', 'migrations');

/**
 * Arbitrary but fixed. Any process holding this key is migrating; the number
 * itself has no meaning beyond being unlikely to collide with another
 * application's advisory locks.
 */
const ADVISORY_LOCK_KEY = 4_612_920_383;

interface Migration {
  filename: string;
  sql: string;
  checksum: string;
}

function checksumOf(sql: string): string {
  // Line endings are normalised first: the same file checked out on Windows
  // and on Cloud Build must not look like two different migrations.
  return createHash('sha256').update(sql.replace(/\r\n/g, '\n')).digest('hex');
}

async function loadMigrations(): Promise<Migration[]> {
  const entries = await readdir(MIGRATIONS_DIR);
  const filenames = entries.filter((name) => name.endsWith('.sql')).sort();

  return Promise.all(
    filenames.map(async (filename) => {
      const sql = await readFile(join(MIGRATIONS_DIR, filename), 'utf8');
      return { filename, sql, checksum: checksumOf(sql) };
    }),
  );
}

async function main(): Promise<void> {
  const migrations = await loadMigrations();

  if (migrations.length === 0) {
    console.log('\nNo migrations found in backend/migrations.\n');
    return;
  }

  const client = new Client(connectionConfig(await resolveConnectionString()));
  await client.connect();

  try {
    // Created outside the per-migration transactions, so the very first run
    // has somewhere to record what it applies.
    await client.query(`
      create table if not exists schema_migrations (
        filename   text primary key,
        checksum   text not null,
        applied_at timestamptz not null default now()
      )
    `);

    // RLS on this one too, for the same reason as every table the migrations
    // create: the backend bypasses it as the service role, and nothing
    // holding an anon or authenticated key learns even the schema history.
    await client.query('alter table schema_migrations enable row level security');

    const { rows: applied } = await client.query<{ filename: string; checksum: string }>(
      'select filename, checksum from schema_migrations',
    );
    const appliedByName = new Map(applied.map((row) => [row.filename, row.checksum]));

    const changed = migrations.filter(
      (migration) =>
        appliedByName.has(migration.filename) &&
        appliedByName.get(migration.filename) !== migration.checksum,
    );

    if (changed.length > 0) {
      throw new Error(
        [
          'These migrations were edited after being applied:',
          ...changed.map((migration) => `  - ${migration.filename}`),
          '',
          'An applied migration must not change, or two databases end up with',
          'different schemas and no way to tell. Add a new numbered file.',
        ].join('\n'),
      );
    }

    const pending = migrations.filter(
      (migration) => !appliedByName.has(migration.filename),
    );

    if (pending.length === 0) {
      console.log(
        `\nDatabase is up to date. ${String(applied.length)} migration(s) already applied.\n`,
      );
      return;
    }

    console.log(`\nApplying ${String(pending.length)} migration(s):\n`);

    for (const migration of pending) {
      const startedAt = Date.now();

      try {
        await client.query('begin');
        await client.query('select pg_advisory_xact_lock($1)', [ADVISORY_LOCK_KEY]);

        // Re-checked inside the lock: a concurrent run may have applied this
        // between the listing above and now.
        const { rowCount } = await client.query(
          'select 1 from schema_migrations where filename = $1',
          [migration.filename],
        );

        if (rowCount === 0) {
          await client.query(migration.sql);
          await client.query(
            'insert into schema_migrations (filename, checksum) values ($1, $2)',
            [migration.filename, migration.checksum],
          );
          await client.query('commit');
          console.log(`  applied  ${migration.filename}  (${String(Date.now() - startedAt)}ms)`);
        } else {
          await client.query('commit');
          console.log(`  skipped  ${migration.filename}  (applied concurrently)`);
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

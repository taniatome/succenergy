import { createApp } from './app.js';
import { closeDatabase, initDatabase } from './config/database.js';
import { env, isEmulated } from './config/env.js';
import { logger } from './config/logger.js';
import { SERVICE_VERSION } from './config/version.js';

/**
 * Entry point: bootstrap and graceful shutdown.
 *
 * Importing config/env.js is what validates the environment, and it exits the
 * process on failure, so nothing below runs against a half-configured
 * service.
 *
 * The database connects before the server listens. A service that starts
 * without its database serves 500s until someone notices; failing here means
 * the revision never goes healthy and Cloud Run keeps the previous one
 * serving. `initDatabase` exits the process itself, with the same
 * names-not-values message style as `config/env.ts`.
 */

await initDatabase();

const app = createApp();

const server = app.listen(env.PORT, () => {
  logger.info(
    {
      port: env.PORT,
      environment: env.NODE_ENV,
      version: SERVICE_VERSION,
      mode: isEmulated ? 'emulator' : 'cloud',
    },
    'Succenergy API listening',
  );

  if (isEmulated) {
    logger.info(
      'Running against the Firebase Auth emulator. Start it with: npm run emulators',
    );
  }
});

/**
 * Cloud Run sends SIGTERM and then waits before killing the container, so
 * in-flight requests finish rather than being cut off mid-write. The timer is
 * a backstop for a connection that never closes on its own.
 */
const SHUTDOWN_GRACE_MS = 10_000;

let shuttingDown = false;

function shutdown(signal: string): void {
  if (shuttingDown) {
    return;
  }
  shuttingDown = true;

  logger.info({ signal }, 'Shutting down');

  const forceExit = setTimeout(() => {
    logger.warn('Forcing exit: connections did not close in time');
    process.exit(1);
  }, SHUTDOWN_GRACE_MS);

  // Does not hold the event loop open once everything else has finished.
  forceExit.unref();

  // The HTTP server first, so no new request can arrive and try to check out
  // a client from a pool that is being drained; then the pool, so the
  // connections go back to Supabase's pooler rather than timing out there.
  server.close((err) => {
    if (err) {
      logger.error({ err }, 'Error while closing server');
    }

    void closeDatabase()
      .catch((poolError: unknown) => {
        logger.error({ err: poolError }, 'Error while draining the database pool');
      })
      .finally(() => {
        clearTimeout(forceExit);
        logger.info('Shutdown complete');
        process.exit(err ? 1 : 0);
      });
  });
}

process.on('SIGTERM', () => {
  shutdown('SIGTERM');
});
process.on('SIGINT', () => {
  shutdown('SIGINT');
});

// A process in an unknown state serves unknown responses. Log, then let Cloud
// Run replace the instance rather than carrying on.
process.on('unhandledRejection', (reason) => {
  logger.fatal({ err: reason }, 'Unhandled promise rejection');
  shutdown('unhandledRejection');
});

process.on('uncaughtException', (err) => {
  logger.fatal({ err }, 'Uncaught exception');
  shutdown('uncaughtException');
});

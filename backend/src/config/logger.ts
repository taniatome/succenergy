import { pino } from 'pino';

import { env } from './env.js';

/**
 * The process logger.
 *
 * Structured JSON in production, which is what Cloud Logging parses; pretty
 * single lines are left to the developer's terminal via `pino-pretty` if they
 * want them, rather than being a production dependency.
 *
 * `messageKey: 'message'` and the level mapping below are what Cloud Logging
 * expects, so severity shows correctly in the console instead of every line
 * arriving as INFO.
 */
export const logger = pino({
  level: env.LOG_LEVEL,
  messageKey: 'message',
  base: { service: 'succenergy-api' },

  formatters: {
    level: (label) => ({ severity: label.toUpperCase(), level: label }),
  },

  timestamp: pino.stdTimeFunctions.isoTime,

  // Applies to direct logger calls; request logging has its own serialisers.
  redact: {
    paths: ['email', '*.email', 'password', '*.password', 'token', '*.token'],
    censor: '[redacted]',
    remove: true,
  },

  // Cloud Run collects stdout. Nothing is written to a file.
  enabled: env.LOG_LEVEL !== 'silent',
});

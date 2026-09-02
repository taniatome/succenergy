import { randomUUID } from 'node:crypto';
import { pinoHttp } from 'pino-http';
import type { IncomingMessage, ServerResponse } from 'node:http';

import { env, isProduction } from '../config/env.js';
import { logger } from '../config/logger.js';

/**
 * Request logging with PII stripped.
 *
 * The client's security checklist forbids private user information in logs.
 * That rules out the defaults: pino-http would otherwise serialise every
 * header — Authorization and Cookie included — and the full request URL,
 * which can carry identifiers in its query string.
 *
 * What is logged: method, route path, status, duration, a request id, and the
 * caller's uid. A uid is an opaque identifier we need to trace a problem back
 * to an account; an email address, a name or anything the user typed is not,
 * and none of it appears here.
 */
export const requestLogger = pinoHttp({
  logger,

  genReqId: (req, res) => {
    const existing = req.headers['x-request-id'];
    const id =
      typeof existing === 'string' && existing.length > 0 && existing.length <= 200
        ? existing
        : randomUUID();
    res.setHeader('x-request-id', id);
    return id;
  },

  // Health checks are called on a timer by Cloud Run and would otherwise be
  // the overwhelming majority of the log volume.
  autoLogging: {
    ignore: (req: IncomingMessage) => {
      const url = req.url ?? '';
      return url === '/v1/health' || url.startsWith('/v1/health?');
    },
  },

  customLogLevel: (_req, res, err) => {
    if (err || res.statusCode >= 500) {
      return 'error';
    }
    if (res.statusCode >= 400) {
      return 'warn';
    }
    return 'info';
  },

  customProps: (req: IncomingMessage) => {
    const uid = (req as { user?: { uid?: string } }).user?.uid;
    return uid ? { uid } : {};
  },

  serializers: {
    // Replaces pino-http's default serialisers wholesale rather than
    // redacting fields out of them, so a future pino-http release cannot
    // introduce a new field that leaks by default.
    req: (req: IncomingMessage & { method?: string; url?: string }) => ({
      method: req.method,
      // Path only. A query string may carry identifiers.
      path: (req.url ?? '').split('?')[0],
    }),
    res: (res: ServerResponse) => ({ statusCode: res.statusCode }),
    err: (err: Error & { status?: number; code?: string }) => ({
      type: err.name,
      message: err.message,
      code: err.code,
      status: err.status,
      // Stack traces only outside production, where they are read by a
      // developer at a terminal rather than shipped to a log sink.
      stack: isProduction ? undefined : err.stack,
    }),
  },

  // Belt and braces: if a serialiser is ever widened, these never print.
  redact: {
    paths: [
      'req.headers.authorization',
      'req.headers.cookie',
      'req.headers["x-api-key"]',
      'res.headers["set-cookie"]',
      'req.body',
      'email',
      '*.email',
      'password',
      '*.password',
    ],
    censor: '[redacted]',
    remove: true,
  },

  quietReqLogger: true,
  level: env.LOG_LEVEL,
});

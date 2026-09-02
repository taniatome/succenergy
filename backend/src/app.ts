import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import type { Express } from 'express';

import { env, isProduction } from './config/env.js';
import { errorHandler } from './middleware/error_handler.js';
import { notFoundHandler } from './middleware/not_found.js';
import { requestLogger } from './middleware/request_logger.js';
import { apiRouter } from './routes/index.js';
import { ApiError } from './utils/api_error.js';

/**
 * Express app assembly.
 *
 * Order matters and is the whole point of this file: security headers, then
 * CORS, then logging, then body parsing, then routes, then the 404, then the
 * error handler last so everything above can throw into it.
 */
export function createApp(): Express {
  const app = express();

  // Cloud Run terminates TLS and forwards the original protocol and client IP
  // in X-Forwarded-*. Without this, req.protocol reads 'http' behind the proxy
  // and the HTTPS redirect below would loop.
  app.set('trust proxy', true);

  // Express advertises itself in a header by default; there is no reason to
  // tell a caller what is serving them.
  app.disable('x-powered-by');

  app.use(
    helmet({
      // An API serves JSON, never markup, so the browser-document policies
      // are set to their strictest rather than tuned.
      contentSecurityPolicy: {
        directives: { defaultSrc: ["'none'"], frameAncestors: ["'none'"] },
      },
      crossOriginResourcePolicy: { policy: 'same-site' },
      referrerPolicy: { policy: 'no-referrer' },
      // HSTS is meaningful only over HTTPS, which in practice means Cloud Run.
      hsts: isProduction
        ? { maxAge: 31_536_000, includeSubDomains: true, preload: false }
        : false,
    }),
  );

  // HTTPS everywhere in production, per the client's security requirements.
  // Cloud Run already serves HTTPS; this closes the case where a custom
  // domain or a future proxy forwards a plain-HTTP request.
  if (isProduction) {
    app.use((req, res, next) => {
      if (req.secure || req.header('x-forwarded-proto') === 'https') {
        next();
        return;
      }
      res.redirect(308, `https://${req.hostname}${req.originalUrl}`);
    });
  }

  app.use(
    cors({
      /**
       * The mobile app is a native client and sends no Origin, so it is
       * unaffected by CORS entirely. This list exists for the browser-based
       * admin console; an empty list means no browser origin is allowed.
       */
      origin: (origin, callback) => {
        if (!origin) {
          callback(null, true);
          return;
        }
        if (env.CORS_ALLOWED_ORIGINS.includes(origin)) {
          callback(null, true);
          return;
        }
        callback(ApiError.forbidden('Origin not allowed'));
      },
      methods: ['GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Authorization', 'Content-Type', 'X-Request-Id'],
      exposedHeaders: ['X-Request-Id'],
      credentials: false,
      maxAge: 600,
    }),
  );

  app.use(requestLogger);

  // Coaching answers are long free text but bounded; a megabyte of JSON is
  // several times the largest legitimate request and well short of anything
  // that would pressure memory.
  app.use(express.json({ limit: '1mb' }));

  app.use('/v1', apiRouter);

  // Cloud Run's default health probe hits the root path.
  app.get('/', (_req, res) => {
    res.json({ service: 'succenergy-api', health: '/v1/health' });
  });

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}

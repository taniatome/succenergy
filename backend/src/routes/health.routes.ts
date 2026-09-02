import { Router } from 'express';

import { checkFirestoreConnectivity } from '../config/firebase.js';
import { env, isEmulated } from '../config/env.js';
import { SERVICE_VERSION } from '../config/version.js';
import { asyncHandler } from '../utils/async_handler.js';

/**
 * Public health routes. The only endpoints that do not require a token.
 *
 * Nothing here reveals anything about the deployment beyond version and
 * whether dependencies answer — no project ids, no hostnames, no counts.
 */
export const healthRouter = Router();

/**
 * GET /v1/health — liveness.
 *
 * Answers from process state alone, so Cloud Run does not restart a healthy
 * instance because Firestore had a slow minute.
 */
healthRouter.get('/', (_req, res) => {
  res.json({
    status: 'ok',
    version: SERVICE_VERSION,
    timestamp: new Date().toISOString(),
  });
});

/**
 * GET /v1/health/ready — readiness.
 *
 * Round-trips a Firestore read. 503 when the dependency is unreachable, so a
 * load balancer can hold traffic off an instance that cannot serve it.
 */
healthRouter.get(
  '/ready',
  asyncHandler(async (_req, res) => {
    const startedAt = Date.now();
    let firestoreOk = false;

    try {
      await checkFirestoreConnectivity();
      firestoreOk = true;
    } catch {
      // Reported as a status, not raised: readiness is a question, and the
      // reason belongs in our logs rather than in a public response.
      firestoreOk = false;
    }

    res.status(firestoreOk ? 200 : 503).json({
      status: firestoreOk ? 'ready' : 'unavailable',
      version: SERVICE_VERSION,
      timestamp: new Date().toISOString(),
      checks: {
        firestore: {
          status: firestoreOk ? 'ok' : 'unreachable',
          latencyMs: Date.now() - startedAt,
          mode: isEmulated ? 'emulator' : 'cloud',
        },
      },
      environment: env.NODE_ENV,
    });
  }),
);

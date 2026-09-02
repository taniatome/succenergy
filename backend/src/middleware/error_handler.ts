import { ZodError } from 'zod';
import type { ErrorRequestHandler } from 'express';

import { isProduction } from '../config/env.js';
import { logger } from '../config/logger.js';
import { ApiError } from '../utils/api_error.js';

/** The one response shape every failure takes. */
interface ErrorBody {
  error: {
    code: string;
    message: string;
    details?: unknown;
    requestId?: string;
  };
}

/**
 * Turns a Zod failure into field names and messages.
 *
 * Only the path and the rule that failed. The rejected value is never
 * included — it is exactly the user content the client's checklist keeps out
 * of responses and logs.
 */
function zodDetails(error: ZodError): { field: string; message: string }[] {
  return error.issues.map((issue) => ({
    field: issue.path.join('.') || '(root)',
    message: issue.message,
  }));
}

/**
 * Central error handling.
 *
 * Two rules, both from the client's security requirements: no stack traces
 * reach a client, and an unrecognised error becomes a bare 500 rather than
 * having its message forwarded. A message is only shown when we chose it, by
 * throwing an ApiError.
 */
export const errorHandler: ErrorRequestHandler = (err, req, res, _next) => {
  const requestId = typeof req.id === 'string' ? req.id : undefined;

  // Express has already begun writing; anything further would corrupt it.
  if (res.headersSent) {
    logger.error({ err, requestId }, 'Error raised after response started');
    return;
  }

  let status = 500;
  let body: ErrorBody;

  if (err instanceof ZodError) {
    status = 422;
    body = {
      error: {
        code: 'validation_failed',
        message: 'Request validation failed',
        details: zodDetails(err),
      },
    };
  } else if (ApiError.isApiError(err)) {
    status = err.status;
    body = {
      error: {
        code: err.code,
        message: err.message,
        ...(err.details === undefined ? {} : { details: err.details }),
      },
    };
  } else {
    body = {
      error: {
        code: 'internal_error',
        message: 'Internal server error',
      },
    };
  }

  if (requestId) {
    body.error.requestId = requestId;
  }

  // 5xx is our fault and gets the full error; 4xx is the caller's and is
  // already visible in the request log line.
  if (status >= 500) {
    logger.error({ err, requestId, status }, 'Request failed');
  } else {
    logger.warn(
      { requestId, status, code: body.error.code },
      'Request rejected',
    );
  }

  // Errors are never cacheable, and an intermediary caching a 401 would lock
  // a user out until it expired.
  res.setHeader('Cache-Control', 'no-store');
  res.status(status).json(body);

  if (!isProduction && status >= 500) {
    // Local convenience only: the stack goes to the terminal, not the client.
    logger.debug({ stack: err instanceof Error ? err.stack : undefined }, 'Stack');
  }
};

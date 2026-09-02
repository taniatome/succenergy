import type { RequestHandler } from 'express';

import { ApiError } from '../utils/api_error.js';

/**
 * Terminates unmatched routes.
 *
 * Mounted last, before the error handler. Without it Express replies with its
 * own HTML 404, which would be the one response in the service not shaped
 * like every other error.
 */
export const notFoundHandler: RequestHandler = (req, _res, next) => {
  // Method and path only: the path is already in the request log, and echoing
  // a query string back would put whatever was in it into the response.
  next(ApiError.notFound(`No route for ${req.method} ${req.path}`));
};

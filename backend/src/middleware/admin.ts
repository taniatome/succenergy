import { ApiError } from '../utils/api_error.js';
import { requireUser } from './auth.js';
import type { RequestHandler } from 'express';

/**
 * Restricts a route to accounts carrying the admin custom claim.
 *
 * Mounted after `requireAuth`, never instead of it. The claim is set out of
 * band with the Admin SDK against explicitly authorised accounts — there is
 * no endpoint that grants it, so a compromised client cannot escalate.
 */
export const requireAdmin: RequestHandler = (req, _res, next) => {
  const user = requireUser(req);

  if (!user.isAdmin) {
    // Same message either way. Whether a given account is an administrator is
    // not something an unauthorised caller gets to learn.
    throw ApiError.forbidden('Administrator access required');
  }

  next();
};

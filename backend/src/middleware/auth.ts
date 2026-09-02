import { auth } from '../config/firebase.js';
import { ApiError } from '../utils/api_error.js';
import { asyncHandler } from '../utils/async_handler.js';
import type { RequestHandler } from 'express';

/**
 * The verified caller, attached to the request by `requireAuth`.
 *
 * Deliberately narrow: uid, the admin flag and the email needed to create a
 * user document on first contact. The rest of the decoded token is not
 * carried around, so it cannot leak into a log line by accident.
 */
export interface AuthenticatedUser {
  uid: string;
  email: string | null;
  emailVerified: boolean;
  isAdmin: boolean;
}

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      user?: AuthenticatedUser;
    }
  }
}

/** Custom claim that grants administrator access. Set out of band, never by the API. */
export const ADMIN_CLAIM = 'admin';

const BEARER_PREFIX = /^Bearer\s+(.+)$/i;

function extractToken(header: string | undefined): string {
  if (!header) {
    throw ApiError.unauthorized('Missing Authorization header');
  }

  const match = BEARER_PREFIX.exec(header.trim());
  const token = match?.[1]?.trim();

  if (!token) {
    throw ApiError.unauthorized('Authorization header must be "Bearer <token>"');
  }

  return token;
}

/**
 * Verifies a Firebase ID token and attaches the caller to the request.
 *
 * The backend never issues tokens — register, login and password reset all
 * happen client-side through the Firebase Auth SDK. This only checks them.
 *
 * `checkRevoked` is on, so a token stops working the moment the account is
 * disabled or its sessions are revoked, which is what makes account deletion
 * take effect immediately rather than at the token's natural expiry.
 */
export const requireAuth: RequestHandler = asyncHandler(async (req, _res, next) => {
  const token = extractToken(req.header('authorization'));

  try {
    const decoded = await auth.verifyIdToken(token, true);

    req.user = {
      uid: decoded.uid,
      email: decoded.email ?? null,
      emailVerified: decoded.email_verified ?? false,
      isAdmin: decoded[ADMIN_CLAIM] === true,
    };
  } catch (cause) {
    // The reason a token failed is useful to us and useful to an attacker, so
    // it goes to the log with the cause attached and never into the response.
    throw new ApiError(401, 'unauthorized', 'Invalid or expired token', { cause });
  }

  next();
});

/**
 * The authenticated caller, for handlers mounted behind `requireAuth`.
 *
 * Throws rather than returning undefined: reaching here without a user means
 * a router was assembled wrongly, and failing loudly beats acting on nobody.
 */
export function requireUser(req: { user?: AuthenticatedUser }): AuthenticatedUser {
  if (!req.user) {
    throw ApiError.internal('Route requires authentication but requireAuth did not run');
  }
  return req.user;
}

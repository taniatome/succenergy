/**
 * An error with an HTTP status attached.
 *
 * Anything thrown that is not an ApiError is treated by the error handler as
 * an unexpected failure and reported to the client as a bare 500, so the only
 * way detail reaches a caller is by choosing to put it here.
 */
export class ApiError extends Error {
  readonly status: number;

  /** Stable, machine-readable code the app can branch on. */
  readonly code: string;

  /**
   * Safe-to-expose context, e.g. which fields failed validation.
   * Never populate this with anything drawn from user content or credentials.
   */
  readonly details?: unknown;

  /** The underlying error, for logs only. Never serialised to a response. */
  override readonly cause?: unknown;

  constructor(
    status: number,
    code: string,
    message: string,
    options: { details?: unknown; cause?: unknown } = {},
  ) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.code = code;
    if (options.details !== undefined) {
      this.details = options.details;
    }
    if (options.cause !== undefined) {
      this.cause = options.cause;
    }
    Error.captureStackTrace?.(this, ApiError);
  }

  static badRequest(message: string, details?: unknown): ApiError {
    return new ApiError(400, 'bad_request', message, { details });
  }

  static validation(message: string, details?: unknown): ApiError {
    return new ApiError(422, 'validation_failed', message, { details });
  }

  static unauthorized(message = 'Authentication required'): ApiError {
    return new ApiError(401, 'unauthorized', message);
  }

  static forbidden(message = 'Not permitted'): ApiError {
    return new ApiError(403, 'forbidden', message);
  }

  static notFound(message = 'Not found'): ApiError {
    return new ApiError(404, 'not_found', message);
  }

  static conflict(message: string): ApiError {
    return new ApiError(409, 'conflict', message);
  }

  static internal(message = 'Internal server error', cause?: unknown): ApiError {
    return new ApiError(500, 'internal_error', message, { cause });
  }

  static serviceUnavailable(message: string, cause?: unknown): ApiError {
    return new ApiError(503, 'service_unavailable', message, { cause });
  }

  static isApiError(value: unknown): value is ApiError {
    return value instanceof ApiError;
  }
}

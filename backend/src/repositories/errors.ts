/**
 * Repository-level "the row is not there".
 *
 * Raised by the data layer and mapped to a 404 by the service that catches
 * it. A repository does not know about HTTP status codes, and a service
 * should not have to read a Postgres error code to tell a missing row from a
 * real failure.
 */
export class RowNotFoundError extends Error {
  /** The table the row was expected in, for the log line. */
  readonly entity: string;

  /** The identifier that found nothing. Never a value drawn from user input. */
  readonly id: string;

  constructor(entity: string, id: string) {
    super(`${entity} row not found`);
    this.name = 'RowNotFoundError';
    this.entity = entity;
    this.id = id;
  }
}

/** Raised when a uid has no user row. */
export class UserNotFoundError extends RowNotFoundError {
  constructor(uid: string) {
    super('user', uid);
    this.name = 'UserNotFoundError';
  }

  get uid(): string {
    return this.id;
  }
}

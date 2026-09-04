/**
 * The verified caller, as the auth middleware resolved it.
 *
 * Every service takes this rather than an Express request: it is the whole of
 * what a service is allowed to know about who is asking, and it means no
 * Express type crosses into the service layer.
 */
export interface Caller {
  uid: string;
  email: string | null;
}

/** ISO 8601 string to `Date`, tolerating absent and unparseable input. */
export function parseIso(value: string | null | undefined): Date | null {
  if (value === null || value === undefined || value === '') {
    return null;
  }
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

/** A nullable `Date` to the ISO string the API sends. */
export function toIso(value: Date | null): string | null {
  return value === null ? null : value.toISOString();
}

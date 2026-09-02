import { Timestamp } from 'firebase-admin/firestore';

/**
 * Conversion between Firestore timestamps and the ISO 8601 strings the API
 * speaks. Kept in one place so no layer has to remember which side of the
 * boundary it is on.
 */

export function toIso(value: Timestamp | null | undefined): string | null {
  return value ? value.toDate().toISOString() : null;
}

/** For fields the schema guarantees are present. */
export function toIsoRequired(value: Timestamp): string {
  return value.toDate().toISOString();
}

export function fromIso(value: string | null | undefined): Timestamp | null {
  if (value === null || value === undefined || value === '') {
    return null;
  }
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return null;
  }
  return Timestamp.fromDate(parsed);
}

/** Calendar date in `YYYY-MM-DD`, used as the progress snapshot document id. */
export function toDateKey(value: Timestamp): string {
  return value.toDate().toISOString().slice(0, 10);
}

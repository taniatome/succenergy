import { SUPPORTED_LOCALES } from '../models/locale.model.js';
import type { LocalizedText } from '../models/localized_text.model.js';

/**
 * Column-to-field conversions shared by every repository.
 *
 * Each repository owns its own entity mappers; these are the primitives those
 * mappers are built from, gathered here so a `date` column is read the same
 * way in all of them. Nothing in this file knows about a table.
 */

/** Rebuilds an `{ en, pt }` map from a pair of columns, dropping absent sides. */
export function localizedPair(
  en: string | null,
  pt: string | null,
): LocalizedText {
  const text: LocalizedText = {};
  if (en !== null) {
    text.en = en;
  }
  if (pt !== null) {
    text.pt = pt;
  }
  return text;
}

/**
 * A single column to the locale map the Dart models expect.
 *
 * Library content — the admin-managed exercises — is stored in paired `_en` /
 * `_pt` columns and read by [localizedPair]. Content a person wrote is stored
 * in one column in the language they wrote it, and read by this: the same
 * words go into both entries, so the app reads back verbatim whichever
 * language it asks for. Mirrors `asTyped` on the Dart side.
 */
export function localizedOwn(value: string | null): LocalizedText {
  if (value === null) {
    return {};
  }
  return Object.fromEntries(SUPPORTED_LOCALES.map((locale) => [locale, value]));
}

/**
 * A `date` column to a UTC `Date`.
 *
 * The API speaks full ISO 8601 timestamps, and a calendar date has no time or
 * zone, so it is pinned to UTC midnight. Doing it here rather than letting
 * node-postgres parse it into *local* midnight is what stops a date of birth
 * shifting a day when the server is not on UTC.
 */
export function fromDateColumn(value: string | null): Date | null {
  return value === null ? null : new Date(`${value}T00:00:00.000Z`);
}

/** A `Date` to the `YYYY-MM-DD` a `date` column takes, in UTC. Same reason. */
export function toDateColumn(value: Date | null | undefined): string | null {
  return value === null || value === undefined
    ? null
    : value.toISOString().slice(0, 10);
}

/** A nullable timestamp to the ISO string the API sends, or null. */
export function toIso(value: Date | null): string | null {
  return value === null ? null : value.toISOString();
}

/**
 * `count(*)` to a number.
 *
 * Postgres counts are `bigint`, which node-postgres returns as a string so a
 * value beyond `Number.MAX_SAFE_INTEGER` cannot be silently mangled. Every
 * count this application takes is far below that, so converting here is safe
 * and keeps the coercion out of the call sites.
 */
export function countOf(value: string | number | null | undefined): number {
  if (value === null || value === undefined) {
    return 0;
  }
  const parsed = typeof value === 'number' ? value : Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
}

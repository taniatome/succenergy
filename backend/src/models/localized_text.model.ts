import { SUPPORTED_LOCALES, type LocaleCode } from './locale.model.js';

/**
 * Text stored in both languages.
 *
 * Bilingual content is stored as an `{ en, pt }` map rather than a single
 * resolved string, so the app requests by locale and the backend never
 * guesses which language a reader wants. Mirrors the `Map<String, String>`
 * fields on the Dart models.
 */
export type LocalizedText = Partial<Record<LocaleCode, string>>;

/** Resolves a locale map, falling back to English, matching the Dart helpers. */
export function textFor(field: LocalizedText | undefined, locale: LocaleCode): string {
  if (!field) {
    return '';
  }
  return field[locale] ?? field.en ?? '';
}

/**
 * Wraps text the user just typed so it reads the same in both languages.
 * Mirrors `OnboardingResponse.asTyped` — the user's own words are shown back
 * verbatim, so they are not translated into the other entry.
 */
export function asTyped(value: string): LocalizedText {
  return Object.fromEntries(SUPPORTED_LOCALES.map((locale) => [locale, value]));
}

/** True when at least one language carries non-empty text. */
export function hasText(field: LocalizedText | undefined): boolean {
  if (!field) {
    return false;
  }
  return SUPPORTED_LOCALES.some((locale) => (field[locale] ?? '').trim().length > 0);
}

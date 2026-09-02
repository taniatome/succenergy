/**
 * Supported locale codes, in the order the language screen shows them.
 * Matches AppConstants.supportedLocales.
 */
export const SUPPORTED_LOCALES = ['en', 'pt'] as const;

export type LocaleCode = (typeof SUPPORTED_LOCALES)[number];

export const DEFAULT_LOCALE: LocaleCode = 'en';

export function isLocaleCode(value: unknown): value is LocaleCode {
  return typeof value === 'string' && (SUPPORTED_LOCALES as readonly string[]).includes(value);
}

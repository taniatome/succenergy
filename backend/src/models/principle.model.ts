/**
 * The seven Succenergy principles, in cycle order.
 *
 * Single source of truth for the cycle: every other model that carries a
 * principle imports from here rather than restating the list. Mirrors
 * `lib/data/models/principle.dart` — same names, same order, so the wire
 * value is the Dart enum name.
 *
 * The cycle repeats: Purpose leads to a goal, a plan, action, tracking,
 * progress and completion, then opens the next Purpose.
 */
export const PRINCIPLES = [
  'purpose',
  'passion',
  'planning',
  'praxis',
  'persistence',
  'progress',
  'perfection',
] as const;

export type Principle = (typeof PRINCIPLES)[number];

/** Principles in one full cycle. Matches AppConstants.principleCount. */
export const PRINCIPLE_COUNT = PRINCIPLES.length;

export function isPrinciple(value: unknown): value is Principle {
  return typeof value === 'string' && (PRINCIPLES as readonly string[]).includes(value);
}

/** Position in the cycle, one-based, as shown to the user. */
export function principlePosition(principle: Principle): number {
  return PRINCIPLES.indexOf(principle) + 1;
}

/** The principle that follows this one, wrapping at the end of the cycle. */
export function nextPrinciple(principle: Principle): Principle {
  const index = PRINCIPLES.indexOf(principle);
  return PRINCIPLES[(index + 1) % PRINCIPLE_COUNT] as Principle;
}

/**
 * Localisation key for the principle name, matching the Dart `labelKey`.
 * The backend never sends principle display text — the app resolves it.
 */
export function principleLabelKey(principle: Principle): string {
  return `principle.${principle}`;
}

/** Localisation key for the one-line description, matching `descriptionKey`. */
export function principleDescriptionKey(principle: Principle): string {
  return `principle.${principle}.desc`;
}

export const FIRST_PRINCIPLE: Principle = 'purpose';

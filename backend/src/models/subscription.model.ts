import type { Timestamp } from 'firebase-admin/firestore';

/**
 * `users/{uid}/subscription/current`
 *
 * A fixed document id rather than a collection of subscription records: there
 * is one current state per account, and billing history lives with the
 * provider. Written only by this backend from verified provider webhooks —
 * never by the client, which is why nothing here is patchable through /v1/me.
 */

/**
 * The three plan tiers. The app is free to download; nothing inside it opens
 * until the trial is taken, and the monthly rate afterwards follows the
 * activity chosen at registration.
 */
export const SUBSCRIPTION_TIERS = ['trial', 'student', 'professional'] as const;
export type SubscriptionTier = (typeof SUBSCRIPTION_TIERS)[number];

export const SUBSCRIPTION_STATUSES = [
  'none',
  'trialing',
  'active',
  'past_due',
  'canceled',
  'expired',
] as const;
export type SubscriptionStatus = (typeof SUBSCRIPTION_STATUSES)[number];

/** Who charged the card. `none` until a real purchase happens. */
export const SUBSCRIPTION_PROVIDERS = ['none', 'stripe', 'revenuecat'] as const;
export type SubscriptionProvider = (typeof SUBSCRIPTION_PROVIDERS)[number];

export interface SubscriptionDocument {
  tier: SubscriptionTier;
  status: SubscriptionStatus;

  trialStartedAt: Timestamp | null;
  trialEndsAt: Timestamp | null;
  currentPeriodEnd: Timestamp | null;

  provider: SubscriptionProvider;

  /** The provider's customer identifier. Not a secret, but not shown either. */
  providerCustomerId: string | null;

  updatedAt: Timestamp;
}

export interface SubscriptionResult {
  tier: SubscriptionTier;
  status: SubscriptionStatus;
  trialStartedAt: string | null;
  trialEndsAt: string | null;
  currentPeriodEnd: string | null;
  provider: SubscriptionProvider;
  updatedAt: string;

  /** Derived: whether the app should open past the paywall. */
  isActive: boolean;
}

/** Length of the introductory trial, matching AppConstants.trialDays. */
export const TRIAL_DAYS = 7;

/** The subscription an account starts with, before the trial is taken. */
export const INITIAL_SUBSCRIPTION = {
  tier: 'trial',
  status: 'none',
  trialStartedAt: null,
  trialEndsAt: null,
  currentPeriodEnd: null,
  provider: 'none',
  providerCustomerId: null,
} as const;

export function isSubscriptionActive(status: SubscriptionStatus): boolean {
  return status === 'trialing' || status === 'active';
}

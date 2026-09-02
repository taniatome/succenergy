import type { Timestamp } from 'firebase-admin/firestore';

/**
 * `users/{uid}/subscription/current`
 *
 * A fixed document id rather than a collection of subscription records: there
 * is one current state per account, and billing history lives with the store.
 * Written only by this backend from verified RevenueCat webhooks — never by
 * the client, which is why nothing here is patchable through /v1/me.
 *
 * Purchases go through native Apple and Google in-app purchase with
 * RevenueCat in front of them. There is no Stripe: the app is distributed
 * through the two stores, and both require their own billing for digital
 * goods.
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

/**
 * Which store the purchase originated from. `none` until a real purchase
 * happens.
 *
 * The store rather than the payment processor, because that is the fact that
 * actually differs per account and the one support needs when a receipt has
 * to be traced — RevenueCat is in front of both and would be the same value
 * on every row.
 */
export const SUBSCRIPTION_STORES = ['none', 'app_store', 'play_store'] as const;
export type SubscriptionStore = (typeof SUBSCRIPTION_STORES)[number];

export interface SubscriptionDocument {
  tier: SubscriptionTier;
  status: SubscriptionStatus;

  trialStartedAt: Timestamp | null;
  trialEndsAt: Timestamp | null;
  currentPeriodEnd: Timestamp | null;

  provider: SubscriptionStore;

  /**
   * RevenueCat's app user id for this account. Not a secret, but not shown
   * either. Set to the Firebase uid when the SDK is wired up, so the two
   * systems agree on who a purchase belongs to without a mapping table.
   */
  revenueCatAppUserId: string | null;

  /**
   * The RevenueCat entitlement that grants access, e.g. `coach_full`.
   *
   * Access is gated on this rather than on `tier` or on a product id: an
   * entitlement is what RevenueCat actually reports as active, and it stays
   * stable while the products and prices behind it change per store and per
   * activity.
   */
  entitlementId: string | null;

  updatedAt: Timestamp;
}

export interface SubscriptionResult {
  tier: SubscriptionTier;
  status: SubscriptionStatus;
  trialStartedAt: string | null;
  trialEndsAt: string | null;
  currentPeriodEnd: string | null;
  provider: SubscriptionStore;
  entitlementId: string | null;
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
  revenueCatAppUserId: null,
  entitlementId: null,
} as const;

export function isSubscriptionActive(status: SubscriptionStatus): boolean {
  return status === 'trialing' || status === 'active';
}

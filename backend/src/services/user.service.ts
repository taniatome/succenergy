import { logger } from '../config/logger.js';
import { DEFAULT_LOCALE } from '../models/locale.model.js';
import { FIRST_PRINCIPLE } from '../models/principle.model.js';
import {
  isSubscriptionActive,
  type SubscriptionDocument,
  type SubscriptionResult,
} from '../models/subscription.model.js';
import { DEFAULT_COACHING_PREFERENCES } from '../models/user.model.js';
import type { UserDocument, UserResponse } from '../models/user.model.js';
import { UserNotFoundError, userRepository } from '../repositories/user.repository.js';
import type {
  UserPatch,
  UserRepository,
  UserWriteResult,
} from '../repositories/user.repository.js';
import type { CreateProfileInput, UpdateProfileInput } from '../schemas/user.schema.js';
import { ApiError } from '../utils/api_error.js';
import { parseIso, toIso, type Caller } from './caller.js';

/**
 * The profile: read, create, patch.
 *
 * No Express types cross this boundary in either direction, and it knows
 * nothing about the database — no SQL, no column names, no `pg`. Onboarding
 * lives in `onboarding.service.ts` and account deletion in
 * `account.service.ts`, because both are their own concern and this file is
 * the profile's.
 */
export class UserService {
  private readonly users: UserRepository;

  constructor(users: UserRepository = userRepository) {
    this.users = users;
  }

  // --- Mapping ------------------------------------------------------------

  /**
   * Stored documents to API response.
   *
   * The one place `Date`s become ISO strings, so a raw Date cannot reach a
   * client by being forgotten at a call site.
   */
  toResponse(
    uid: string,
    document: UserDocument,
    subscription: SubscriptionDocument | null,
  ): UserResponse {
    return {
      id: uid,
      name: document.name,
      email: document.email,
      preferredLanguage: document.preferredLanguage,
      activity: document.activity,
      dateOfBirth: toIso(document.dateOfBirth),
      countryCode: document.countryCode,
      acceptedTerms: document.acceptedTerms,
      confirmedInfoTrue: document.confirmedInfoTrue,
      currentPrinciple: document.currentPrinciple,
      cycleDay: document.cycleDay,
      dayStreak: document.dayStreak,
      coachingPreferences: document.coachingPreferences,

      // The Dart model calls the account creation time joinedAt.
      joinedAt: document.createdAt.toISOString(),
      updatedAt: document.updatedAt.toISOString(),

      subscription: UserService.toSubscriptionResult(subscription),
    };
  }

  /**
   * The subscription, or an explicit null.
   *
   * `isActive` is derived here rather than stored, from the same rule the API
   * applies everywhere else, so the app never has to know which statuses
   * count as open.
   */
  private static toSubscriptionResult(
    subscription: SubscriptionDocument | null,
  ): SubscriptionResult | null {
    if (subscription === null) {
      return null;
    }
    return {
      tier: subscription.tier,
      status: subscription.status,
      trialStartedAt: toIso(subscription.trialStartedAt),
      trialEndsAt: toIso(subscription.trialEndsAt),
      currentPeriodEnd: toIso(subscription.currentPeriodEnd),
      provider: subscription.provider,
      entitlementId: subscription.entitlementId,
      updatedAt: subscription.updatedAt.toISOString(),
      isActive: isSubscriptionActive(subscription.status),
    };
  }

  // --- Profile ------------------------------------------------------------

  /**
   * The caller's profile. A pure read: it never writes.
   *
   * A uid with no row is a 404 rather than an implicit create, because a GET
   * that creates a resource is neither safe nor idempotent. The
   * `profile_not_found` code tells the client to call `POST /v1/me` instead
   * of having to infer it from a bare 404.
   */
  async getProfile(caller: Caller): Promise<UserResponse> {
    const existing = await this.users.findProfile(caller.uid);
    if (!existing) {
      throw new ApiError(
        404,
        'profile_not_found',
        'No profile exists for this account yet. Create one with POST /v1/me.',
      );
    }

    return this.toResponse(caller.uid, existing.user, existing.subscription);
  }

  /**
   * Creates the profile for the caller's uid.
   *
   * Registration happens client-side against Firebase Auth, so the first
   * authenticated request is the first this backend has heard of an account.
   *
   * One call, not a read-then-write: the repository's insert is
   * `on conflict do nothing`, so an existing row is returned as-is rather
   * than treated as a conflict or overwritten. A client may retry a call
   * whose response it never saw, and a retry must be harmless. `created` lets
   * the controller answer 201 on a real creation and 200 on a repeat.
   */
  async createProfile(
    caller: Caller,
    input: CreateProfileInput = {},
  ): Promise<{ profile: UserResponse; created: boolean }> {
    const document = this.buildNewUser(caller, input);

    let written: UserWriteResult & { created: boolean };

    try {
      written = await this.users.create(caller.uid, document);
    } catch (cause) {
      throw ApiError.internal('Could not create user profile', cause);
    }

    if (written.created) {
      logger.info({ uid: caller.uid }, 'Created user profile');
    }

    return {
      profile: this.toResponse(caller.uid, written.user, written.subscription),
      created: written.created,
    };
  }

  /**
   * The row a brand-new account starts with.
   *
   * Everything the client did not supply takes a defined default rather than
   * being left absent, so no reader downstream has to handle a missing field.
   * The cycle starts on Purpose at day one, which is where the methodology
   * begins.
   *
   * `createdAt` and `updatedAt` are placeholders: the columns have
   * `default now()` and the repository does not send them, so what comes back
   * is the database's own clock rather than this process's.
   */
  private buildNewUser(caller: Caller, input: CreateProfileInput): UserDocument {
    const now = new Date();

    return {
      name: input.name ?? '',
      email: caller.email ?? '',
      preferredLanguage: input.preferredLanguage ?? DEFAULT_LOCALE,
      activity: input.activity ?? 'professional',
      dateOfBirth: parseIso(input.dateOfBirth),
      countryCode: input.countryCode ?? null,
      acceptedTerms: input.acceptedTerms ?? false,
      confirmedInfoTrue: input.confirmedInfoTrue ?? false,
      currentPrinciple: FIRST_PRINCIPLE,
      cycleDay: 1,
      dayStreak: 0,
      coachingPreferences: { ...DEFAULT_COACHING_PREFERENCES },
      createdAt: now,
      updatedAt: now,
    };
  }

  /**
   * Applies a profile patch.
   *
   * The patch goes down as the domain shape, nested coaching preferences
   * included. Flattening it to columns is the repository's job.
   */
  async updateProfile(
    caller: Caller,
    input: UpdateProfileInput,
  ): Promise<UserResponse> {
    const patch = UserService.buildPatch(input);

    if (Object.keys(patch).length === 0) {
      throw ApiError.badRequest('No updatable fields provided');
    }

    try {
      const updated = await this.users.update(caller.uid, patch);
      return this.toResponse(caller.uid, updated.user, updated.subscription);
    } catch (cause) {
      if (cause instanceof UserNotFoundError) {
        throw ApiError.notFound('User profile not found');
      }
      throw cause;
    }
  }

  private static buildPatch(input: UpdateProfileInput): UserPatch {
    const patch: UserPatch = {};

    if (input.name !== undefined) {
      patch.name = input.name;
    }
    if (input.preferredLanguage !== undefined) {
      patch.preferredLanguage = input.preferredLanguage;
    }
    if (input.activity !== undefined) {
      patch.activity = input.activity;
    }
    if (input.dateOfBirth !== undefined) {
      patch.dateOfBirth = parseIso(input.dateOfBirth);
    }
    if (input.countryCode !== undefined) {
      patch.countryCode = input.countryCode;
    }
    if (input.coachingPreferences) {
      patch.coachingPreferences = input.coachingPreferences;
    }

    return patch;
  }
}

export const userService = new UserService();

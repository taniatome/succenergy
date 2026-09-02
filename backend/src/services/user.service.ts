import { Timestamp } from 'firebase-admin/firestore';

import { auth } from '../config/firebase.js';
import { logger } from '../config/logger.js';
import { DEFAULT_LOCALE } from '../models/locale.model.js';
import { hasText } from '../models/localized_text.model.js';
import type {
  OnboardingResponseDocument,
  OnboardingResponseResult,
} from '../models/onboarding_response.model.js';
import { FIRST_PRINCIPLE } from '../models/principle.model.js';
import { DEFAULT_COACHING_PREFERENCES } from '../models/user.model.js';
import type { UserDocument, UserResponse } from '../models/user.model.js';
import { UserNotFoundError, userRepository } from '../repositories/user.repository.js';
import type { UserRepository } from '../repositories/user.repository.js';
import type {
  BootstrapProfileInput,
  SaveOnboardingInput,
  UpdateProfileInput,
} from '../schemas/user.schema.js';
import { ApiError } from '../utils/api_error.js';
import { fromIso, toIso, toIsoRequired } from '../utils/timestamps.js';

/**
 * User business logic.
 *
 * No Express types cross this boundary in either direction: the service takes
 * validated input and returns response shapes, and knows nothing about
 * requests, headers or status codes beyond the ApiErrors it throws.
 */

/** The caller, as the auth middleware resolved it. */
export interface Caller {
  uid: string;
  email: string | null;
}

export class UserService {
  private readonly users: UserRepository;

  constructor(users: UserRepository = userRepository) {
    this.users = users;
  }

  // --- Mapping ------------------------------------------------------------

  /**
   * Stored document to API response.
   *
   * The one place Timestamps become ISO strings, so a Timestamp cannot reach
   * a client by being forgotten at a call site.
   */
  private toResponse(uid: string, document: UserDocument): UserResponse {
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
      joinedAt: toIsoRequired(document.createdAt),
      updatedAt: toIsoRequired(document.updatedAt),
    };
  }

  private toOnboardingResult(
    document: OnboardingResponseDocument,
  ): OnboardingResponseResult {
    return {
      ambition: document.ambition,
      focusAreaKeys: document.focusAreaKeys,
      challenge: document.challenge,
      priorityKeys: document.priorityKeys,
      mainGoals: document.mainGoals,
      motivationBalance: document.motivationBalance,
      successVision: document.successVision,
      completedAt: toIso(document.completedAt),
      updatedAt: toIsoRequired(document.updatedAt),
      isComplete: UserService.isOnboardingComplete(document),
    };
  }

  /**
   * Mirrors Dart `OnboardingResponse.isComplete` exactly, so the app and the
   * API never disagree about whether a profile still needs finishing.
   */
  private static isOnboardingComplete(
    document: Pick<
      OnboardingResponseDocument,
      'ambition' | 'focusAreaKeys' | 'priorityKeys' | 'successVision'
    >,
  ): boolean {
    return (
      hasText(document.ambition) &&
      document.focusAreaKeys.length > 0 &&
      document.priorityKeys.length > 0 &&
      hasText(document.successVision)
    );
  }

  // --- Profile ------------------------------------------------------------

  /**
   * The caller's profile, creating the document if this uid is new.
   *
   * Registration happens client-side against Firebase Auth, so the first
   * authenticated request is the first this backend has heard of an account.
   * Creating on read rather than requiring a separate registration call means
   * there is no window in which a signed-in user has no profile.
   */
  async getOrCreateProfile(
    caller: Caller,
    bootstrap: BootstrapProfileInput = {},
  ): Promise<UserResponse> {
    const existing = await this.users.findById(caller.uid);
    if (existing) {
      return this.toResponse(caller.uid, existing);
    }

    const document = this.buildNewUser(caller, bootstrap);

    try {
      await this.users.create(caller.uid, document);
    } catch (cause) {
      // Two first requests can race. The loser re-reads rather than failing:
      // both callers are the same person and both want the same document.
      const raced = await this.users.findById(caller.uid);
      if (raced) {
        return this.toResponse(caller.uid, raced);
      }
      throw ApiError.internal('Could not create user profile', cause);
    }

    logger.info({ uid: caller.uid }, 'Created user profile on first request');
    return this.toResponse(caller.uid, document);
  }

  /**
   * The document a brand-new account starts with.
   *
   * Everything the client did not supply takes a defined default rather than
   * being left absent, so no reader downstream has to handle a missing field.
   * The cycle starts on Purpose at day one, which is where the methodology
   * begins.
   */
  private buildNewUser(caller: Caller, bootstrap: BootstrapProfileInput): UserDocument {
    const now = Timestamp.now();

    return {
      name: bootstrap.name ?? '',
      email: caller.email ?? '',
      preferredLanguage: bootstrap.preferredLanguage ?? DEFAULT_LOCALE,
      activity: bootstrap.activity ?? 'professional',
      dateOfBirth: fromIso(bootstrap.dateOfBirth),
      countryCode: bootstrap.countryCode ?? null,
      acceptedTerms: bootstrap.acceptedTerms ?? false,
      confirmedInfoTrue: bootstrap.confirmedInfoTrue ?? false,
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
   * Coaching preferences are flattened to dotted field paths rather than
   * written as a nested object, because Firestore replaces a nested map
   * wholesale — patching only `tone` would otherwise drop `rhythm` and
   * `remindersEnabled`.
   */
  async updateProfile(caller: Caller, input: UpdateProfileInput): Promise<UserResponse> {
    const patch: Record<string, unknown> = {};

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
      patch.dateOfBirth = fromIso(input.dateOfBirth);
    }
    if (input.countryCode !== undefined) {
      patch.countryCode = input.countryCode;
    }

    const preferences = input.coachingPreferences;
    if (preferences) {
      if (preferences.tone !== undefined) {
        patch['coachingPreferences.tone'] = preferences.tone;
      }
      if (preferences.rhythm !== undefined) {
        patch['coachingPreferences.rhythm'] = preferences.rhythm;
      }
      if (preferences.remindersEnabled !== undefined) {
        patch['coachingPreferences.remindersEnabled'] = preferences.remindersEnabled;
      }
    }

    if (Object.keys(patch).length === 0) {
      throw ApiError.badRequest('No updatable fields provided');
    }

    try {
      const updated = await this.users.update(caller.uid, patch);

      // The repository merges dotted paths as literal keys, which is right
      // for Firestore and wrong for a response body, so preferences are
      // rebuilt from the values just written.
      if (preferences) {
        updated.coachingPreferences = {
          ...updated.coachingPreferences,
          ...preferences,
        };
      }

      return this.toResponse(caller.uid, updated);
    } catch (cause) {
      if (cause instanceof UserNotFoundError) {
        throw ApiError.notFound('User profile not found');
      }
      throw cause;
    }
  }

  // --- Onboarding ---------------------------------------------------------

  async getOnboarding(caller: Caller): Promise<OnboardingResponseResult> {
    const document = await this.users.findOnboarding(caller.uid);
    if (!document) {
      throw ApiError.notFound('Onboarding response not found');
    }
    return this.toOnboardingResult(document);
  }

  /**
   * Saves the onboarding response.
   *
   * `completedAt` is stamped by the server rather than accepted from the
   * client, and only once the answers actually satisfy the completeness rule
   * the app uses — so a partial submission cannot mark a profile finished.
   */
  async saveOnboarding(
    caller: Caller,
    input: SaveOnboardingInput,
  ): Promise<OnboardingResponseResult> {
    const now = Timestamp.now();
    const complete = UserService.isOnboardingComplete(input);

    const document: OnboardingResponseDocument = {
      ambition: input.ambition,
      focusAreaKeys: input.focusAreaKeys,
      challenge: input.challenge,
      priorityKeys: input.priorityKeys,
      mainGoals: input.mainGoals,
      motivationBalance: input.motivationBalance,
      successVision: input.successVision,
      completedAt: complete ? now : null,
      updatedAt: now,
    };

    // The onboarding document lives under the user document, so the user has
    // to exist first — which for a first-time caller it may not yet.
    await this.getOrCreateProfile(caller);
    await this.users.saveOnboarding(caller.uid, document);

    logger.info(
      { uid: caller.uid, isComplete: complete },
      'Saved onboarding response',
    );

    return this.toOnboardingResult(document);
  }

  // --- Deletion -----------------------------------------------------------

  /**
   * Deletes the account and everything belonging to it.
   *
   * Order is deliberate. Firestore first, because that is where the coaching
   * memory the client's checklist names lives and it is the part that must
   * not survive; the Auth record second, which revokes every outstanding
   * token and makes the deletion take effect immediately rather than at the
   * next token expiry.
   *
   * If the Firestore sweep fails, the Auth record is left alone so the user
   * can still authenticate and retry. If the Auth deletion fails after the
   * data is gone, that is reported as a partial failure rather than a
   * success: an Auth record with no data behind it would let the next request
   * create a fresh empty profile and look like the delete had not run.
   */
  async deleteAccount(caller: Caller): Promise<{ documentsDeleted: number }> {
    let result: { documentsDeleted: number };

    try {
      result = await this.users.deleteAllData(caller.uid);
    } catch (cause) {
      logger.error({ uid: caller.uid, err: cause }, 'Failed to delete user data');
      throw ApiError.internal('Could not delete account data', cause);
    }

    try {
      await auth.deleteUser(caller.uid);
    } catch (cause) {
      logger.error(
        { uid: caller.uid, err: cause },
        'User data deleted but auth record remains',
      );
      throw new ApiError(
        500,
        'partial_deletion',
        'Account data was deleted but the sign-in record could not be removed. Please retry.',
        { cause },
      );
    }

    logger.info(
      { uid: caller.uid, documentsDeleted: result.documentsDeleted },
      'Deleted account and all data',
    );

    return result;
  }
}

export const userService = new UserService();

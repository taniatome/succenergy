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
import type { UserPatch, UserRepository } from '../repositories/user.repository.js';
import type {
  CreateProfileInput,
  SaveOnboardingInput,
  UpdateProfileInput,
} from '../schemas/user.schema.js';
import { ApiError } from '../utils/api_error.js';

/**
 * User business logic.
 *
 * No Express types cross this boundary in either direction: the service takes
 * validated input and returns response shapes, and knows nothing about
 * requests, headers or status codes beyond the ApiErrors it throws. It knows
 * nothing about the database either — no SQL, no column names, no `pg`.
 */

/** The caller, as the auth middleware resolved it. */
export interface Caller {
  uid: string;
  email: string | null;
}

/** ISO 8601 string to `Date`, tolerating absent and unparseable input. */
function parseIso(value: string | null | undefined): Date | null {
  if (value === null || value === undefined || value === '') {
    return null;
  }
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

const toIso = (value: Date | null): string | null =>
  value === null ? null : value.toISOString();

export class UserService {
  private readonly users: UserRepository;

  constructor(users: UserRepository = userRepository) {
    this.users = users;
  }

  // --- Mapping ------------------------------------------------------------

  /**
   * Stored document to API response.
   *
   * The one place `Date`s become ISO strings, so a raw Date cannot reach a
   * client by being forgotten at a call site.
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
      joinedAt: document.createdAt.toISOString(),
      updatedAt: document.updatedAt.toISOString(),
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
      updatedAt: document.updatedAt.toISOString(),
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
   * The caller's profile. A pure read: it never writes.
   *
   * A uid with no row is a 404 rather than an implicit create, because a GET
   * that creates a resource is neither safe nor idempotent — retries,
   * prefetches and intermediaries all assume a GET has no side effects. The
   * `profile_not_found` code tells the client to call `POST /v1/me` instead of
   * having to infer it from a bare 404.
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

    return this.toResponse(caller.uid, existing.user);
  }

  /**
   * Creates the profile for the caller's uid.
   *
   * Registration happens client-side against Firebase Auth, so the first
   * authenticated request is the first this backend has heard of an account.
   *
   * One call, not a read-then-write: the repository's insert is
   * `on conflict do nothing`, so an existing row is returned as-is rather
   * than treated as a conflict or overwritten. The client may retry a call
   * whose response it never saw, and a retry must be harmless. `created` lets
   * the controller answer 201 on a real creation and 200 on a repeat, so the
   * caller can tell them apart.
   */
  async createProfile(
    caller: Caller,
    input: CreateProfileInput = {},
  ): Promise<{ profile: UserResponse; created: boolean }> {
    const document = this.buildNewUser(caller, input);

    let user: UserDocument;
    let created: boolean;

    try {
      ({ user, created } = await this.users.create(caller.uid, document));
    } catch (cause) {
      throw ApiError.internal('Could not create user profile', cause);
    }

    if (created) {
      logger.info({ uid: caller.uid }, 'Created user profile');
    }

    return { profile: this.toResponse(caller.uid, user), created };
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
   * from the insert is the database's own clock rather than this process's.
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
   * included. Flattening it to columns is the repository's job — under
   * Firestore this method had to build dotted field paths by hand, because a
   * nested map was otherwise replaced wholesale and patching `tone` would
   * drop `rhythm` and `remindersEnabled`. That was database detail in a
   * service, and it is gone.
   */
  async updateProfile(caller: Caller, input: UpdateProfileInput): Promise<UserResponse> {
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

    if (Object.keys(patch).length === 0) {
      throw ApiError.badRequest('No updatable fields provided');
    }

    try {
      const updated = await this.users.update(caller.uid, patch);
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
    const profile = await this.users.findProfile(caller.uid);
    if (!profile?.onboarding) {
      throw ApiError.notFound('Onboarding response not found');
    }
    return this.toOnboardingResult(profile.onboarding);
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
    const complete = UserService.isOnboardingComplete(input);

    const document: OnboardingResponseDocument = {
      ambition: input.ambition,
      focusAreaKeys: input.focusAreaKeys,
      challenge: input.challenge,
      priorityKeys: input.priorityKeys,
      mainGoals: input.mainGoals,
      motivationBalance: input.motivationBalance,
      successVision: input.successVision,
      completedAt: complete ? new Date() : null,
      updatedAt: new Date(),
    };

    // The onboarding row references the user row, so the user has to exist
    // first. A client that reached the assessment has already been through
    // registration, but creating here rather than 404-ing keeps a submitted
    // assessment from being lost to a missed POST /v1/me.
    await this.createProfile(caller);
    const stored = await this.users.saveOnboarding(caller.uid, document);

    logger.info({ uid: caller.uid, isComplete: complete }, 'Saved onboarding response');

    return this.toOnboardingResult(stored);
  }

  // --- Deletion -----------------------------------------------------------

  /**
   * Deletes the account and everything belonging to it.
   *
   * Order is deliberate. The database first, because that is where the
   * coaching memory the client's checklist names lives and it is the part
   * that must not survive; the Auth record second, which revokes every
   * outstanding token and makes the deletion take effect immediately rather
   * than at the next token expiry.
   *
   * If the delete fails, the Auth record is left alone so the user can still
   * authenticate and retry. If the Auth deletion fails after the data is
   * gone, that is reported as a partial failure rather than a success: an
   * Auth record with no data behind it would let the next request create a
   * fresh empty profile and look like the delete had not run.
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

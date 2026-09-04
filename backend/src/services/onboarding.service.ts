import { logger } from '../config/logger.js';
import { hasText } from '../models/localized_text.model.js';
import type {
  OnboardingResponseDocument,
  OnboardingResponseResult,
} from '../models/onboarding_response.model.js';
import { onboardingRepository } from '../repositories/onboarding.repository.js';
import type { OnboardingRepository } from '../repositories/onboarding.repository.js';
import { userRepository } from '../repositories/user.repository.js';
import type { UserRepository } from '../repositories/user.repository.js';
import type { SaveOnboardingInput } from '../schemas/user.schema.js';
import { ApiError } from '../utils/api_error.js';
import { toIso, type Caller } from './caller.js';
import { userService, type UserService } from './user.service.js';

/**
 * The onboarding assessment: the three questions asked before registration
 * and the four asked after it, submitted and read as one set.
 */
export class OnboardingService {
  private readonly users: UserRepository;
  private readonly answers: OnboardingRepository;
  private readonly profiles: UserService;

  constructor(
    users: UserRepository = userRepository,
    answers: OnboardingRepository = onboardingRepository,
    profiles: UserService = userService,
  ) {
    this.users = users;
    this.answers = answers;
    this.profiles = profiles;
  }

  async getOnboarding(caller: Caller): Promise<OnboardingResponseResult> {
    const profile = await this.users.findProfile(caller.uid);
    if (!profile?.onboarding) {
      throw ApiError.notFound('Onboarding response not found');
    }
    return OnboardingService.toResult(profile.onboarding);
  }

  /**
   * Saves the assessment.
   *
   * `completedAt` is stamped by the server rather than accepted from the
   * client, and only once the answers actually satisfy the completeness rule
   * the app uses — so a partial submission cannot mark a profile finished.
   */
  async saveOnboarding(
    caller: Caller,
    input: SaveOnboardingInput,
  ): Promise<OnboardingResponseResult> {
    const complete = OnboardingService.isComplete(input);

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
    await this.profiles.createProfile(caller);
    const stored = await this.answers.save(caller.uid, document);

    logger.info(
      { uid: caller.uid, isComplete: complete },
      'Saved onboarding response',
    );

    return OnboardingService.toResult(stored);
  }

  private static toResult(
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
      isComplete: OnboardingService.isComplete(document),
    };
  }

  /**
   * Mirrors Dart `OnboardingResponse.isComplete` exactly, so the app and the
   * API never disagree about whether a profile still needs finishing.
   */
  private static isComplete(
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
}

export const onboardingService = new OnboardingService();

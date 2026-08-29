import '../models/onboarding_response.dart';
import '../models/user.dart';

/// Profile, coaching preferences and the onboarding answers behind them.
abstract class UserRepository {
  Future<User> loadUser();

  Future<User> updateProfile({
    String? name,
    String? email,
    CoachingTone? tone,
    CheckInRhythm? rhythm,
    bool? remindersEnabled,
  });

  Future<OnboardingResponse> loadOnboardingResponse();

  Future<void> saveOnboardingResponse(OnboardingResponse response);

  /// The user's saved answers to the five Purpose prompts, keyed by prompt id.
  Future<Map<String, Map<String, String>>> loadPurposeAnswers();

  Future<void> savePurposeAnswer({
    required String promptId,
    required String answer,
  });

  /// Accounts listed in the management console.
  Future<List<User>> loadDirectory();

  /// Platform-level counters for the management console, keyed by
  /// localisation key and already formatted for display.
  Future<Map<String, String>> loadPlatformStats();
}

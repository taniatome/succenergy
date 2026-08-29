import '../../models/onboarding_response.dart';
import '../../models/user.dart';
import '../../repositories/user_repository.dart';
import '../mock_data.dart';

/// In-memory profile store seeded from the demo persona.
class MockUserRepository implements UserRepository {
  User _user = MockData.user;
  OnboardingResponse _response = MockData.onboardingResponse;
  final Map<String, Map<String, String>> _purposeAnswers =
      Map<String, Map<String, String>>.from(MockData.purposeAnswers);

  @override
  Future<User> loadUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _user;
  }

  @override
  Future<User> updateProfile({
    String? name,
    String? email,
    CoachingTone? tone,
    CheckInRhythm? rhythm,
    bool? remindersEnabled,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _user = _user.copyWith(
      name: name,
      email: email,
      tone: tone,
      rhythm: rhythm,
      remindersEnabled: remindersEnabled,
    );
    return _user;
  }

  @override
  Future<OnboardingResponse> loadOnboardingResponse() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _response;
  }

  @override
  Future<void> saveOnboardingResponse(OnboardingResponse response) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _response = response;
  }

  @override
  Future<Map<String, Map<String, String>>> loadPurposeAnswers() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return Map<String, Map<String, String>>.unmodifiable(_purposeAnswers);
  }

  @override
  Future<void> savePurposeAnswer({
    required String promptId,
    required String answer,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (answer.trim().isEmpty) {
      _purposeAnswers.remove(promptId);
      return;
    }
    _purposeAnswers[promptId] = OnboardingResponse.asTyped(answer.trim());
  }

  @override
  Future<List<User>> loadDirectory() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return MockData.adminUsers;
  }

  @override
  Future<Map<String, String>> loadPlatformStats() async {
    await Future<void>.delayed(const Duration(milliseconds: 140));
    return MockData.adminStats;
  }
}

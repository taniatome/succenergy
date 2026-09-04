import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/onboarding_response.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';
import 'json_reader.dart';
import 'onboarding_mapper.dart';
import 'purpose_mapper.dart';
import 'user_profile_mapper.dart';

/// The profile, the assessment and the Purpose answers.
///
/// The Purpose prompts live on this interface rather than one of their own,
/// which is why swapping them means swapping this: the app keeps them beside
/// the profile because they are answers *about* the person rather than a
/// feature with a screen of its own.
class ApiUserRepository implements UserRepository {
  const ApiUserRepository(this._api);

  final ApiClient _api;

  static const String _mePath = '/me';

  @override
  Future<User> loadUser() async {
    final Map<String, Object?> profile = await _api.get(_mePath);
    return UserProfileMapper.fromJson(profile, uid: Json.text(profile['id']));
  }

  @override
  Future<User> updateProfile({
    String? name,
    String? email,
    CoachingTone? tone,
    CheckInRhythm? rhythm,
    bool? remindersEnabled,
  }) async {
    // `email` is absent from the body on purpose: it belongs to Firebase Auth
    // and the API reads it from the verified token, so PATCH /v1/me refuses
    // it. Changing an address is a re-authentication, not a profile edit.
    final Map<String, Object?> preferences = <String, Object?>{
      if (tone != null) 'tone': tone.name,
      if (rhythm != null) 'rhythm': OnboardingMapper.rhythmToWire(rhythm),
      if (remindersEnabled != null) 'remindersEnabled': remindersEnabled,
    };

    final Map<String, Object?> body = <String, Object?>{
      if (name != null) 'name': name,
      if (preferences.isNotEmpty) 'coachingPreferences': preferences,
    };

    final Map<String, Object?> updated = await _api.patch(_mePath, body: body);
    return UserProfileMapper.fromJson(updated, uid: Json.text(updated['id']));
  }

  @override
  Future<OnboardingResponse> loadOnboardingResponse() async {
    return OnboardingMapper.fromJson(await _api.get('$_mePath/onboarding'));
  }

  @override
  Future<void> saveOnboardingResponse(OnboardingResponse response) async {
    await _api.post(
      '$_mePath/onboarding',
      body: OnboardingMapper.toBody(response),
    );
  }

  /// The three pre-registration answers, merged into the assessment.
  ///
  /// Read-modify-write rather than a partial POST: the endpoint takes all
  /// seven answers together, because a partial write would leave a profile
  /// the coach cannot reason about. The four later answers are read back
  /// first so the quiz cannot erase them on a re-run.
  @override
  Future<void> saveQuizAnswers({
    required Map<String, String> ambition,
    required List<String> focusAreaKeys,
    required Map<String, String> challenge,
  }) async {
    final OnboardingResponse existing = await _loadOrEmpty();

    await saveOnboardingResponse(
      existing.copyWith(
        ambition: ambition,
        focusAreaKeys: focusAreaKeys,
        challenge: challenge,
      ),
    );
  }

  /// The assessment, or an empty one when it has not been started.
  ///
  /// A 404 here is the normal first case — the quiz runs before any answer
  /// exists — so it is a starting point rather than a failure.
  Future<OnboardingResponse> _loadOrEmpty() async {
    try {
      return await loadOnboardingResponse();
    } on ApiException catch (error) {
      if (error.kind == ApiFailureKind.notFound) {
        return OnboardingMapper.empty;
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, Map<String, String>>> loadPurposeAnswers() async {
    return PurposeMapper.fromJson(await _api.getAll('$_mePath/purpose'));
  }

  @override
  Future<void> savePurposeAnswer({
    required String promptId,
    required String answer,
  }) async {
    await _api.post(
      '$_mePath/purpose/$promptId',
      body: <String, Object?>{'answer': answer},
    );
  }

  // --- Management console -------------------------------------------------

  @override
  Future<List<User>> loadDirectory() async {
    final List<Object?> page = await _api.getAll('/admin/users');
    return UserProfileMapper.directoryFromJson(page);
  }

  @override
  Future<Map<String, String>> loadPlatformStats() async {
    final Map<String, Object?> stats = await _api.get('/admin/stats');
    return UserProfileMapper.statsFromJson(stats);
  }
}

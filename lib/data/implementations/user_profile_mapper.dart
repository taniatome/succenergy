import '../models/principle.dart';
import '../models/subscription_plan.dart';
import '../models/user.dart';

/// Translates between the `/v1/me` payload and the app's [User].
///
/// The one place a wire field name meets a Dart field, so a rename on either
/// side is a single edit here rather than a hunt through the repository.
class UserProfileMapper {
  const UserProfileMapper._();

  /// Wire values for [UserActivity]. Snake case, as the API's schema declares.
  static const String _studentWire = 'student_minorities';
  static const String _professionalWire = 'professional';

  static String activityToWire(UserActivity activity) =>
      activity == UserActivity.studentMinorities
          ? _studentWire
          : _professionalWire;

  static UserActivity activityFromWire(Object? value) =>
      value == _studentWire
          ? UserActivity.studentMinorities
          : UserActivity.professional;

  /// The body `POST /v1/me` takes.
  ///
  /// Email is absent by design: the API reads it off the verified token, so a
  /// client cannot claim an address it has not proven it owns.
  static Map<String, Object?> createBody({
    required String name,
    required DateTime dateOfBirth,
    required String countryCode,
    required UserActivity activity,
    required String preferredLanguage,
    required bool acceptedTerms,
    required bool confirmedInfoTrue,
  }) {
    return <String, Object?>{
      'name': name,
      'preferredLanguage': preferredLanguage,
      'activity': activityToWire(activity),
      'dateOfBirth': dateOfBirth.toUtc().toIso8601String(),
      'countryCode': countryCode.toUpperCase(),
      'acceptedTerms': acceptedTerms,
      'confirmedInfoTrue': confirmedInfoTrue,
    };
  }

  /// A profile as the API returned it.
  ///
  /// Tolerant of missing fields rather than strict: a profile that is a
  /// version behind the app should still sign in, and every absent value here
  /// has a sane resting state.
  static User fromJson(Map<String, Object?> json, {required String uid}) {
    return User(
      id: json['id'] as String? ?? uid,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      joinedAt: _date(json['joinedAt']) ?? DateTime.now(),
      currentPrinciple: _principle(json['currentPrinciple']),
      cycleDay: _int(json['cycleDay']) ?? 1,
      dayStreak: _int(json['dayStreak']) ?? 0,
      tier: SubscriptionTier.trial,
      activity: activityFromWire(json['activity']),
      dateOfBirth: _date(json['dateOfBirth']),
      countryCode: json['countryCode'] as String?,
      tone: _tone(_preference(json, 'tone')),
      rhythm: _rhythm(_preference(json, 'rhythm')),
      remindersEnabled: _preference(json, 'remindersEnabled') as bool? ?? true,
    );
  }

  static Object? _preference(Map<String, Object?> json, String key) {
    final Object? preferences = json['coachingPreferences'];
    return preferences is Map<String, Object?> ? preferences[key] : null;
  }

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toLocal() : null;

  static int? _int(Object? value) => value is num ? value.toInt() : null;

  static Principle _principle(Object? value) {
    return Principle.values.firstWhere(
      (Principle p) => p.name == value,
      orElse: () => Principle.purpose,
    );
  }

  static CoachingTone _tone(Object? value) {
    return CoachingTone.values.firstWhere(
      (CoachingTone t) => t.name == value,
      orElse: () => CoachingTone.direct,
    );
  }

  /// The API writes `every_other_day` where Dart has `everyOtherDay`.
  static CheckInRhythm _rhythm(Object? value) {
    if (value == 'every_other_day') {
      return CheckInRhythm.everyOtherDay;
    }
    return CheckInRhythm.values.firstWhere(
      (CheckInRhythm r) => r.name == value,
      orElse: () => CheckInRhythm.daily,
    );
  }
}

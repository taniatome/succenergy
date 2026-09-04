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

  // --- Management console --------------------------------------------------

  /// A page of `/v1/admin/users` as the console's directory list.
  ///
  /// The directory row is narrower than a full profile — it has no coaching
  /// preferences and no onboarding — so the absent fields take the same
  /// resting defaults `fromJson` gives them.
  static List<User> directoryFromJson(List<Object?> page) {
    return page
        .whereType<Map<String, Object?>>()
        .map(
          (Map<String, Object?> entry) =>
              fromJson(entry, uid: entry['id'] as String? ?? ''),
        )
        .toList(growable: false);
  }

  /// `/v1/admin/stats` as the four tiles the console renders.
  ///
  /// Keyed by localisation key and formatted here, because the interface
  /// promises display-ready strings — the console shows them verbatim and has
  /// no number formatter of its own.
  static Map<String, String> statsFromJson(Map<String, Object?> stats) {
    final int users = _int(stats['users']) ?? 0;
    final int active = _int(stats['activeSubscriptions']) ?? 0;

    return <String, String>{
      'admin.stat.users': _grouped(users),
      'admin.stat.active': _grouped(active),
      'admin.stat.premium':
          users == 0 ? '0%' : '${((active / users) * 100).round()}%',
      'admin.stat.sessions': _grouped(_int(stats['sessions']) ?? 0),
    };
  }

  /// Thousands separated, which is how the tiles were mocked up.
  static String _grouped(int value) {
    final String digits = value.abs().toString();
    final StringBuffer out = StringBuffer(value < 0 ? '-' : '');

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        out.write(',');
      }
      out.write(digits[i]);
    }
    return out.toString();
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

import 'principle.dart';
import 'subscription_plan.dart';

/// How direct the coach should be with this user.
enum CoachingTone { direct, warm, challenging }

/// How often the coach checks in.
enum CheckInRhythm { daily, everyOtherDay, weekly }

/// What the person does, chosen at registration.
///
/// This is what sets the monthly price after the trial, so it is captured on
/// the account rather than asked for again at the paywall.
enum UserActivity {
  /// Students and minorities, on the reduced monthly rate.
  studentMinorities,

  /// Everyone else, on the standard monthly rate.
  professional,
}

/// The signed-in person.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.joinedAt,
    required this.currentPrinciple,
    required this.cycleDay,
    required this.dayStreak,
    required this.tier,
    this.activity = UserActivity.professional,
    this.dateOfBirth,
    this.countryCode,
    this.tone = CoachingTone.direct,
    this.rhythm = CheckInRhythm.daily,
    this.remindersEnabled = true,
  });

  final String id;
  final String name;
  final String email;
  final DateTime joinedAt;

  /// Where the user currently sits in the seven-principle cycle.
  final Principle currentPrinciple;

  /// Day number within the current cycle, shown under the greeting.
  final int cycleDay;

  final int dayStreak;
  final SubscriptionTier tier;

  /// Drives the monthly price shown on the trial and plan screens.
  final UserActivity activity;

  /// Captured at registration; null on accounts created before the field
  /// existed, which is every seeded persona but the demo one.
  final DateTime? dateOfBirth;

  /// ISO 3166-1 alpha-2 code of the country chosen at registration.
  final String? countryCode;

  final CoachingTone tone;
  final CheckInRhythm rhythm;
  final bool remindersEnabled;

  /// First name only, for greetings.
  String get firstName => name.split(' ').first;

  /// The plan tier this person's activity puts them on after the trial.
  SubscriptionTier get monthlyTier =>
      activity == UserActivity.studentMinorities
          ? SubscriptionTier.student
          : SubscriptionTier.professional;

  User copyWith({
    String? name,
    String? email,
    CoachingTone? tone,
    CheckInRhythm? rhythm,
    bool? remindersEnabled,
    SubscriptionTier? tier,
    Principle? currentPrinciple,
    UserActivity? activity,
    DateTime? dateOfBirth,
    String? countryCode,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      joinedAt: joinedAt,
      currentPrinciple: currentPrinciple ?? this.currentPrinciple,
      cycleDay: cycleDay,
      dayStreak: dayStreak,
      tier: tier ?? this.tier,
      activity: activity ?? this.activity,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      countryCode: countryCode ?? this.countryCode,
      tone: tone ?? this.tone,
      rhythm: rhythm ?? this.rhythm,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    );
  }
}

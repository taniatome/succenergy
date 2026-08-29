import 'principle.dart';
import 'subscription_plan.dart';

/// How direct the coach should be with this user.
enum CoachingTone { direct, warm, challenging }

/// How often the coach checks in.
enum CheckInRhythm { daily, everyOtherDay, weekly }

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
  final CoachingTone tone;
  final CheckInRhythm rhythm;
  final bool remindersEnabled;

  /// First name only, for greetings.
  String get firstName => name.split(' ').first;

  User copyWith({
    String? name,
    String? email,
    CoachingTone? tone,
    CheckInRhythm? rhythm,
    bool? remindersEnabled,
    SubscriptionTier? tier,
    Principle? currentPrinciple,
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
      tone: tone ?? this.tone,
      rhythm: rhythm ?? this.rhythm,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    );
  }
}

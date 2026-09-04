import '../models/onboarding_response.dart';
import '../models/user.dart';
import 'json_reader.dart';

/// Translates between `/v1/me/onboarding` and [OnboardingResponse].
class OnboardingMapper {
  const OnboardingMapper._();

  /// The starting point when no assessment exists yet.
  ///
  /// The quiz runs before any answer has been written, so a 404 on the first
  /// read is the normal case and this is what it becomes — not an error.
  static const OnboardingResponse empty = OnboardingResponse(
    ambition: <String, String>{},
    focusAreaKeys: <String>[],
    challenge: <String, String>{},
    priorityKeys: <String>[],
    mainGoals: <String, String>{},
    motivationBalance: 0,
    successVision: <String, String>{},
  );

  /// The API writes `every_other_day`; the Dart enum has `everyOtherDay`.
  static const Map<String, CheckInRhythm> _rhythms = <String, CheckInRhythm>{
    'daily': CheckInRhythm.daily,
    'every_other_day': CheckInRhythm.everyOtherDay,
    'weekly': CheckInRhythm.weekly,
  };

  static CheckInRhythm rhythmFromWire(Object? value) =>
      _rhythms[Json.text(value)] ?? CheckInRhythm.daily;

  static String rhythmToWire(CheckInRhythm rhythm) =>
      rhythm == CheckInRhythm.everyOtherDay ? 'every_other_day' : rhythm.name;

  static OnboardingResponse fromJson(Map<String, Object?> json) {
    return OnboardingResponse(
      ambition: Json.localized(json['ambition']),
      focusAreaKeys: Json.stringList(json['focusAreaKeys']),
      challenge: Json.localized(json['challenge']),
      priorityKeys: Json.stringList(json['priorityKeys']),
      mainGoals: Json.localized(json['mainGoals']),
      motivationBalance: Json.number(json['motivationBalance']),
      successVision: Json.localized(json['successVision']),
    );
  }

  /// The body `POST /v1/me/onboarding` takes: all seven answers together.
  ///
  /// `completedAt` is absent by design — the server stamps it, and only once
  /// the answers actually satisfy the completeness rule, so a client cannot
  /// mark a half-finished profile done.
  static Map<String, Object?> toBody(OnboardingResponse response) {
    return <String, Object?>{
      'ambition': response.ambition,
      'focusAreaKeys': response.focusAreaKeys,
      'challenge': response.challenge,
      'priorityKeys': response.priorityKeys,
      'mainGoals': response.mainGoals,
      'motivationBalance': response.motivationBalance,
      'successVision': response.successVision,
    };
  }
}

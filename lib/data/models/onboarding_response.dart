/// The seven answers captured during the onboarding assessment.
///
/// Shown back to the user on the closing summary screen and on the editable
/// "Your coaching profile" section of Profile.
///
/// The free-text answers are stored as locale maps: the seeded persona has a
/// version in each language, while text the user types in session is written
/// to both entries, because their own words are shown back verbatim.
class OnboardingResponse {
  const OnboardingResponse({
    required this.ambition,
    required this.focusAreaKeys,
    required this.challenge,
    required this.priorityKeys,
    required this.mainGoals,
    required this.motivationBalance,
    required this.successVision,
  });

  /// Q1 - what the user wants to achieve.
  final Map<String, String> ambition;

  /// Q2 - up to two life areas, as localisation keys.
  final List<String> focusAreaKeys;

  /// Q3 - what is challenging them now.
  final Map<String, String> challenge;

  /// Q4 - three priorities, as localisation keys.
  final List<String> priorityKeys;

  /// Q5 - main goals in their own words.
  final Map<String, String> mainGoals;

  /// Q6 - motivation balance from inner drive (0) to people they carry (1).
  final double motivationBalance;

  /// Q7 - what success looks like.
  final Map<String, String> successVision;

  bool get isComplete =>
      textFor(ambition, 'en').isNotEmpty &&
      focusAreaKeys.isNotEmpty &&
      priorityKeys.isNotEmpty &&
      textFor(successVision, 'en').isNotEmpty;

  /// Resolves one of the free-text answers, falling back to English.
  static String textFor(Map<String, String> field, String localeCode) =>
      field[localeCode] ?? field['en'] ?? '';

  /// Wraps text the user just typed so it reads the same in both languages.
  static Map<String, String> asTyped(String value) => <String, String>{
    'en': value,
    'pt': value,
  };

  OnboardingResponse copyWith({
    Map<String, String>? ambition,
    List<String>? focusAreaKeys,
    Map<String, String>? challenge,
    List<String>? priorityKeys,
    Map<String, String>? mainGoals,
    double? motivationBalance,
    Map<String, String>? successVision,
  }) {
    return OnboardingResponse(
      ambition: ambition ?? this.ambition,
      focusAreaKeys: focusAreaKeys ?? this.focusAreaKeys,
      challenge: challenge ?? this.challenge,
      priorityKeys: priorityKeys ?? this.priorityKeys,
      mainGoals: mainGoals ?? this.mainGoals,
      motivationBalance: motivationBalance ?? this.motivationBalance,
      successVision: successVision ?? this.successVision,
    );
  }

  /// A blank set of answers, used as the starting state for a new account.
  static const OnboardingResponse empty = OnboardingResponse(
    ambition: <String, String>{},
    focusAreaKeys: <String>[],
    challenge: <String, String>{},
    priorityKeys: <String>[],
    mainGoals: <String, String>{},
    motivationBalance: 0.5,
    successVision: <String, String>{},
  );
}

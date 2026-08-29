/// The input a single exercise step asks for.
enum ExerciseStepType { freeText, singleChoice, scale }

/// One prompt inside a guided exercise.
///
/// Exercise sessions are driven entirely from these; no exercise content is
/// ever hardcoded into a widget.
class ExerciseStep {
  const ExerciseStep({
    required this.id,
    required this.type,
    required this.prompt,
    required this.help,
    this.options = const <Map<String, String>>[],
    this.scaleLowLabel = const <String, String>{},
    this.scaleHighLabel = const <String, String>{},
  });

  final String id;
  final ExerciseStepType type;

  /// Locale code to prompt text.
  final Map<String, String> prompt;

  /// Locale code to the supporting line beneath the prompt.
  final Map<String, String> help;

  /// Choices for [ExerciseStepType.singleChoice], each a locale code map.
  final List<Map<String, String>> options;

  /// Locale code to the label at the low end of a scale step.
  final Map<String, String> scaleLowLabel;

  /// Locale code to the label at the high end of a scale step.
  final Map<String, String> scaleHighLabel;

  /// Resolves one of this step's locale maps, falling back to English.
  static String resolve(Map<String, String> field, String localeCode) =>
      field[localeCode] ?? field['en'] ?? '';
}

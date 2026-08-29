import 'exercise_step.dart';
import 'principle.dart';

/// A short guided practice belonging to one of the seven principles.
class Exercise {
  const Exercise({
    required this.id,
    required this.principle,
    required this.title,
    required this.summary,
    required this.durationMinutes,
    required this.steps,
    required this.suggestedAction,
    this.completedAt,
  });

  final String id;
  final Principle principle;

  /// Locale code to exercise title.
  final Map<String, String> title;

  /// Locale code to the one-line description shown on the library card.
  final Map<String, String> summary;

  final int durationMinutes;
  final List<ExerciseStep> steps;

  /// Locale code to the action offered at the end of the session, which the
  /// user can convert into a goal action item.
  final Map<String, String> suggestedAction;

  final DateTime? completedAt;

  bool get isCompleted => completedAt != null;

  /// Steps plus the closing reflection screen.
  int get totalScreens => steps.length + 1;

  String titleFor(String localeCode) => ExerciseStep.resolve(title, localeCode);

  String summaryFor(String localeCode) =>
      ExerciseStep.resolve(summary, localeCode);

  String suggestedActionFor(String localeCode) =>
      ExerciseStep.resolve(suggestedAction, localeCode);

  Exercise copyWith({DateTime? completedAt}) {
    return Exercise(
      id: id,
      principle: principle,
      title: title,
      summary: summary,
      durationMinutes: durationMinutes,
      steps: steps,
      suggestedAction: suggestedAction,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

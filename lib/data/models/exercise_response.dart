/// What the user entered for one step of one exercise.
///
/// Saved responses are shown again when a completed exercise is reviewed.
class ExerciseResponse {
  const ExerciseResponse({
    required this.exerciseId,
    required this.stepId,
    required this.value,
    required this.answeredAt,
  });

  /// The [stepId] the closing reflection is stored under.
  ///
  /// The reflection is not one of the exercise's declared steps, so it takes
  /// a reserved id rather than colliding with a real one.
  static const String reflectionStepId = 'reflection';

  final String exerciseId;

  /// The step this answers, or [reflectionStepId] for the closing reflection.
  final String stepId;

  /// Free text, the chosen option label, or a scale value rendered as text.
  final String value;

  final DateTime answeredAt;
}

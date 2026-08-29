/// One day of recorded activity, used by the Progress charts.
class ProgressSnapshot {
  const ProgressSnapshot({
    required this.date,
    required this.goalCompletion,
    required this.actionsCompleted,
    required this.exercisesCompleted,
  });

  final DateTime date;

  /// Average completion across active goals on this date, 0 to 1.
  final double goalCompletion;

  final int actionsCompleted;
  final int exercisesCompleted;

  /// Whether the day counts toward the streak.
  bool get wasActive => actionsCompleted > 0 || exercisesCompleted > 0;
}

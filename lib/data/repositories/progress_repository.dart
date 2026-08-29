import '../models/milestone.dart';
import '../models/principle.dart';
import '../models/progress_snapshot.dart';

/// Everything the Progress screen charts.
abstract class ProgressRepository {
  /// Daily snapshots, oldest first.
  Future<List<ProgressSnapshot>> loadHistory();

  /// Completed exercise count per principle.
  Future<Map<Principle, int>> loadPracticeByPrinciple();

  /// Milestones reached across all goals, most recent first.
  Future<List<Milestone>> loadReachedMilestones();

  /// Share of the seven-principle cycle the user has closed, 0 to 1.
  Future<double> loadCycleCompletion();

  /// Headline counters shown above the charts.
  Future<Map<String, int>> loadHeadlineStats();
}

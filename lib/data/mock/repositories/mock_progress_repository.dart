import '../../models/goal.dart';
import '../../models/milestone.dart';
import '../../models/principle.dart';
import '../../models/progress_snapshot.dart';
import '../../repositories/progress_repository.dart';
import '../mock_data.dart';

/// In-memory progress data derived from the same goals the rest of the app
/// shows, so the charts and the goal list never disagree.
class MockProgressRepository implements ProgressRepository {
  @override
  Future<List<ProgressSnapshot>> loadHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return MockData.progressHistory;
  }

  @override
  Future<Map<Principle, int>> loadPracticeByPrinciple() async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return MockData.practiceByPrinciple;
  }

  @override
  Future<List<Milestone>> loadReachedMilestones() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final List<Milestone> reached = <Milestone>[
      for (final Goal goal in MockData.goals)
        ...goal.milestones.where((Milestone m) => m.isReached),
    ];
    reached.sort(
      (Milestone a, Milestone b) => b.reachedAt!.compareTo(a.reachedAt!),
    );
    return reached;
  }

  @override
  Future<double> loadCycleCompletion() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return MockData.cycleCompletion;
  }

  @override
  Future<Map<String, int>> loadHeadlineStats() async {
    await Future<void>.delayed(const Duration(milliseconds: 140));
    return MockData.headlineStats;
  }
}

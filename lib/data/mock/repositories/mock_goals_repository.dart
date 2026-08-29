import '../../models/action_item.dart';
import '../../models/goal.dart';
import '../../models/milestone.dart';
import '../../models/principle.dart';
import '../../repositories/goals_repository.dart';
import '../mock_data.dart';

/// In-memory goals store. Edits persist for the life of the session so the
/// demo responds to what the reviewer does.
class MockGoalsRepository implements GoalsRepository {
  final List<Goal> _goals = List<Goal>.from(MockData.goals);

  @override
  Future<List<Goal>> loadGoals() async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return List<Goal>.unmodifiable(_goals);
  }

  @override
  Future<Goal?> loadGoal(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _find(id);
  }

  @override
  Future<ActionItem?> loadTodaysAction() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    for (final Goal goal in _goals) {
      if (goal.isCompleted) {
        continue;
      }
      for (final ActionItem action in goal.actions) {
        if (action.isToday) {
          return action;
        }
      }
    }
    return null;
  }

  @override
  Future<Goal> createGoal({
    required String title,
    required String why,
    required Principle principle,
    required DateTime targetDate,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    final String id = 'goal-${DateTime.now().millisecondsSinceEpoch}';
    final Goal goal = Goal(
      id: id,
      title: <String, String>{'en': title, 'pt': title},
      why: <String, String>{'en': why, 'pt': why},
      principle: principle,
      createdAt: DateTime.now(),
      targetDate: targetDate,
      milestones: <Milestone>[],
      actions: <ActionItem>[],
    );
    _goals.insert(0, goal);
    return goal;
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _replace(goal);
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _goals.removeWhere((Goal g) => g.id == goalId);
  }

  @override
  Future<Goal> setGoalCompleted({
    required String goalId,
    required bool completed,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final Goal goal = _find(goalId)!;
    return _replace(
      goal.copyWith(
        completedAt: completed ? DateTime.now() : null,
        clearCompletedAt: !completed,
      ),
    );
  }

  @override
  Future<Goal> setActionDone({
    required String goalId,
    required String actionId,
    required bool isDone,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 140));
    final Goal goal = _find(goalId)!;
    final List<ActionItem> actions = <ActionItem>[
      for (final ActionItem a in goal.actions)
        if (a.id == actionId) a.copyWith(isDone: isDone) else a,
    ];
    return _replace(goal.copyWith(actions: actions));
  }

  @override
  Future<Goal> setMilestoneReached({
    required String goalId,
    required String milestoneId,
    required bool isReached,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 140));
    final Goal goal = _find(goalId)!;
    final List<Milestone> milestones = <Milestone>[
      for (final Milestone m in goal.milestones)
        if (m.id == milestoneId)
          m.copyWith(
            reachedAt: isReached ? DateTime.now() : null,
            clearReachedAt: !isReached,
          )
        else
          m,
    ];
    return _replace(goal.copyWith(milestones: milestones));
  }

  @override
  Future<Goal> addActionItem({
    required String goalId,
    required String title,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final Goal goal = _find(goalId)!;
    final ActionItem item = ActionItem(
      id: 'act-${DateTime.now().millisecondsSinceEpoch}',
      goalId: goalId,
      title: <String, String>{'en': title, 'pt': title},
    );
    return _replace(
      goal.copyWith(actions: <ActionItem>[...goal.actions, item]),
    );
  }

  Goal? _find(String id) {
    for (final Goal goal in _goals) {
      if (goal.id == id) {
        return goal;
      }
    }
    return null;
  }

  Goal _replace(Goal updated) {
    final int index = _goals.indexWhere((Goal g) => g.id == updated.id);
    _goals[index] = updated;
    return updated;
  }
}

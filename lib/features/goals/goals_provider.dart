import 'package:flutter/foundation.dart';

import '../../data/models/goal.dart';
import '../../data/models/principle.dart';
import '../../data/repositories/goals_repository.dart';

/// Backs the Goals list and Goal Detail.
///
/// One provider covers both because they operate on the same collection and
/// an edit made on the detail screen has to be visible in the list behind it.
class GoalsProvider extends ChangeNotifier {
  GoalsProvider(this._goals);

  final GoalsRepository _goals;

  List<Goal> _all = const <Goal>[];
  bool _loading = true;

  bool get loading => _loading;

  List<Goal> get active =>
      _all.where((Goal g) => !g.isCompleted).toList(growable: false);

  List<Goal> get completed =>
      _all.where((Goal g) => g.isCompleted).toList(growable: false);

  Goal? byId(String id) {
    for (final Goal goal in _all) {
      if (goal.id == id) {
        return goal;
      }
    }
    return null;
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _all = await _goals.loadGoals();
    _loading = false;
    notifyListeners();
  }

  Future<void> create({
    required String title,
    required String why,
    required Principle principle,
    required DateTime targetDate,
  }) async {
    await _goals.createGoal(
      title: title,
      why: why,
      principle: principle,
      targetDate: targetDate,
    );
    _all = await _goals.loadGoals();
    notifyListeners();
  }

  /// Saves an edit made in the goal sheet. Title and reason are mirrored
  /// across both locales, matching how [create] stores user-authored text.
  Future<void> edit({
    required Goal goal,
    required String title,
    required String why,
    required Principle principle,
  }) async {
    await _goals.updateGoal(
      goal.copyWith(
        title: <String, String>{'en': title, 'pt': title},
        why: <String, String>{'en': why, 'pt': why},
        principle: principle,
      ),
    );
    _all = await _goals.loadGoals();
    notifyListeners();
  }

  Future<void> delete(String goalId) async {
    await _goals.deleteGoal(goalId);
    _all = await _goals.loadGoals();
    notifyListeners();
  }

  Future<void> setCompleted({
    required String goalId,
    required bool completed,
  }) async {
    await _goals.setGoalCompleted(goalId: goalId, completed: completed);
    _all = await _goals.loadGoals();
    notifyListeners();
  }

  Future<void> setActionDone({
    required String goalId,
    required String actionId,
    required bool isDone,
  }) async {
    await _goals.setActionDone(
      goalId: goalId,
      actionId: actionId,
      isDone: isDone,
    );
    _all = await _goals.loadGoals();
    notifyListeners();
  }

  Future<void> setMilestoneReached({
    required String goalId,
    required String milestoneId,
    required bool isReached,
  }) async {
    await _goals.setMilestoneReached(
      goalId: goalId,
      milestoneId: milestoneId,
      isReached: isReached,
    );
    _all = await _goals.loadGoals();
    notifyListeners();
  }
}

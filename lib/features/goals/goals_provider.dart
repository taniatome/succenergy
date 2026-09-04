import 'package:flutter/foundation.dart';

import '../../core/network/request_guard.dart';
import '../../data/models/goal.dart';
import '../../data/models/principle.dart';
import '../../data/repositories/goals_repository.dart';

/// Backs the Goals list and Goal Detail.
///
/// One provider covers both because they operate on the same collection and
/// an edit made on the detail screen has to be visible in the list behind it.
class GoalsProvider extends ChangeNotifier with RequestGuard {
  GoalsProvider(this._goals);

  final GoalsRepository _goals;

  List<Goal> _all = const <Goal>[];

  /// True until the first read resolves, one way or the other.
  bool get loading => isBusy;

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
    await guard(() async {
      _all = await _goals.loadGoals();
    });
  }

  /// Re-reads after a write, without blanking the screen for it.
  ///
  /// The list is already on the page and the control that started the write
  /// shows its own progress, so the branded loader would be a flash of
  /// nothing for no information.
  Future<void> _refresh(Future<void> Function() write) async {
    await guard(() async {
      await write();
      _all = await _goals.loadGoals();
    }, showLoading: false);
  }

  Future<void> create({
    required String title,
    required String why,
    required Principle principle,
    required DateTime targetDate,
  }) async {
    await _refresh(
      () => _goals.createGoal(
        title: title,
        why: why,
        principle: principle,
        targetDate: targetDate,
      ),
    );
  }

  /// Saves an edit made in the goal sheet. Title and reason are mirrored
  /// across both locales, matching how [create] stores user-authored text.
  Future<void> edit({
    required Goal goal,
    required String title,
    required String why,
    required Principle principle,
  }) async {
    await _refresh(
      () => _goals.updateGoal(
        goal.copyWith(
          title: <String, String>{'en': title, 'pt': title},
          why: <String, String>{'en': why, 'pt': why},
          principle: principle,
        ),
      ),
    );
  }

  Future<void> delete(String goalId) async {
    await _refresh(() => _goals.deleteGoal(goalId));
  }

  Future<void> setCompleted({
    required String goalId,
    required bool completed,
  }) async {
    await _refresh(
      () => _goals.setGoalCompleted(goalId: goalId, completed: completed),
    );
  }

  Future<void> setActionDone({
    required String goalId,
    required String actionId,
    required bool isDone,
  }) async {
    await _refresh(
      () => _goals.setActionDone(
        goalId: goalId,
        actionId: actionId,
        isDone: isDone,
      ),
    );
  }

  Future<void> setMilestoneReached({
    required String goalId,
    required String milestoneId,
    required bool isReached,
  }) async {
    await _refresh(
      () => _goals.setMilestoneReached(
        goalId: goalId,
        milestoneId: milestoneId,
        isReached: isReached,
      ),
    );
  }
}

import 'package:flutter/foundation.dart';

import '../../core/network/request_guard.dart';

import '../../data/models/action_item.dart';
import '../../data/models/app_notification.dart';
import '../../data/models/exercise.dart';
import '../../data/models/goal.dart';
import '../../data/models/user.dart';
import '../../data/repositories/exercises_repository.dart';
import '../../data/repositories/goals_repository.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../data/repositories/user_repository.dart';

/// Assembles everything the Dashboard shows from the repository interfaces.
class DashboardProvider extends ChangeNotifier with RequestGuard {
  DashboardProvider({
    required UserRepository users,
    required GoalsRepository goals,
    required ExercisesRepository exercises,
    required NotificationsRepository notifications,
  }) : _users = users,
       _goals = goals,
       _exercises = exercises,
       _notifications = notifications;

  final UserRepository _users;
  final GoalsRepository _goals;
  final ExercisesRepository _exercises;
  final NotificationsRepository _notifications;

  User? _user;
  List<Goal> _allGoals = const <Goal>[];
  ActionItem? _todaysAction;
  int _completedExercises = 0;
  bool _hasUnread = false;
  // Loading and failure state come from RequestGuard.

  User? get user => _user;

  bool get loading => isBusy;

  List<Goal> get activeGoals =>
      _allGoals.where((Goal g) => !g.isCompleted).toList(growable: false);

  /// The goal the Dashboard leads with: the active goal closest to done.
  Goal? get leadGoal {
    final List<Goal> active = activeGoals;
    if (active.isEmpty) {
      return null;
    }
    return active.reduce((Goal a, Goal b) => a.progress >= b.progress ? a : b);
  }

  ActionItem? get todaysAction => _todaysAction;

  int get completedExerciseCount => _completedExercises;

  /// Whether the bell in the header should carry its unread mark.
  bool get hasUnreadNotifications => _hasUnread;

  Future<void> load() async {
    await guard(_read);
  }

  /// The five reads the Dashboard opens with, together rather than in turn.
  Future<void> _read() async {
    final List<Object?> results = await Future.wait<Object?>(<Future<Object?>>[
      _users.loadUser(),
      _goals.loadGoals(),
      _goals.loadTodaysAction(),
      _exercises.loadExercises(),
      _notifications.loadNotifications(),
    ]);
    _user = results[0] as User;
    _allGoals = results[1] as List<Goal>;
    _todaysAction = results[2] as ActionItem?;
    _completedExercises =
        (results[3] as List<Exercise>)
            .where((Exercise e) => e.isCompleted)
            .length;
    _hasUnread = (results[4] as List<AppNotification>).any(
      (AppNotification n) => !n.isRead,
    );
  }

  /// Marks today's action done and refreshes the goal it belongs to.
  Future<void> completeTodaysAction() async {
    final ActionItem? action = _todaysAction;
    if (action == null || action.isDone) {
      return;
    }
    // The card shows its own progress, so the loader stays off. The local
    // copy is only advanced once the write has actually landed — marking it
    // done first would leave the tick on a card whose action is still open.
    await guard(() async {
      await _goals.setActionDone(
        goalId: action.goalId,
        actionId: action.id,
        isDone: true,
      );
      _todaysAction = action.copyWith(isDone: true);
      _allGoals = await _goals.loadGoals();
    }, showLoading: false);
  }
}

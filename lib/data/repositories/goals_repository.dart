import '../models/action_item.dart';
import '../models/goal.dart';
import '../models/principle.dart';

/// Goals, their milestones and their action plans.
abstract class GoalsRepository {
  Future<List<Goal>> loadGoals();

  Future<Goal?> loadGoal(String id);

  /// The single action surfaced on the Dashboard as today's step.
  Future<ActionItem?> loadTodaysAction();

  Future<Goal> createGoal({
    required String title,
    required String why,
    required Principle principle,
    required DateTime targetDate,
  });

  /// Saves an edited goal in place, keeping its id, creation date, milestones
  /// and action plan.
  Future<Goal> updateGoal(Goal goal);

  /// Removes a goal and everything hanging off it. Not reversible.
  Future<void> deleteGoal(String goalId);

  /// Closes a goal, or reopens it when [completed] is false.
  Future<Goal> setGoalCompleted({
    required String goalId,
    required bool completed,
  });

  Future<Goal> setActionDone({
    required String goalId,
    required String actionId,
    required bool isDone,
  });

  Future<Goal> setMilestoneReached({
    required String goalId,
    required String milestoneId,
    required bool isReached,
  });

  /// Appends an action item, used when an exercise converts its suggested
  /// next step into part of a goal's plan.
  Future<Goal> addActionItem({required String goalId, required String title});
}

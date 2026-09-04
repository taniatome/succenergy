import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/action_item.dart';
import '../models/goal.dart';
import '../models/principle.dart';
import '../repositories/goals_repository.dart';
import 'goal_mapper.dart';

/// Goals against `/v1/me/goals`.
///
/// Every mutation endpoint answers with the whole goal, so each method here is
/// one call rather than a write followed by a read. That is also why the
/// interface above did not have to change for this swap: it already returned
/// `Goal` from the operations that touch a milestone or an action.
class ApiGoalsRepository implements GoalsRepository {
  const ApiGoalsRepository(this._api);

  final ApiClient _api;

  static const String _path = '/me/goals';

  @override
  Future<List<Goal>> loadGoals() async {
    return GoalMapper.listFromJson(await _api.getAll(_path));
  }

  @override
  Future<Goal?> loadGoal(String id) async {
    try {
      return GoalMapper.fromJson(await _api.get('$_path/$id'));
    } on ApiException catch (error) {
      // The interface says "null when there is no such goal", and the API
      // answers 404 for a goal that is not this user's as well as one that
      // does not exist. Anything else is a real failure and travels on.
      if (error.kind == ApiFailureKind.notFound) {
        return null;
      }
      rethrow;
    }
  }

  /// The one action the Dashboard surfaces.
  ///
  /// Derived from the goals list rather than given its own endpoint: the
  /// Dashboard already loads the goals, and the flag that marks today's
  /// action rides on the actions it returns. A second round trip would ask
  /// the server a question the answer to which is already on the way.
  @override
  Future<ActionItem?> loadTodaysAction() async {
    final List<Goal> goals = await loadGoals();

    for (final Goal goal in goals) {
      if (goal.isCompleted) {
        continue;
      }
      for (final ActionItem action in goal.actions) {
        if (action.isToday && !action.isDone) {
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
    return GoalMapper.fromJson(
      await _api.post(
        _path,
        body: GoalMapper.createBody(
          title: title,
          why: why,
          principle: principle,
          targetDate: targetDate,
        ),
      ),
    );
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    return GoalMapper.fromJson(
      await _api.patch('$_path/${goal.id}', body: GoalMapper.updateBody(goal)),
    );
  }

  @override
  Future<void> deleteGoal(String goalId) => _api.delete('$_path/$goalId');

  @override
  Future<Goal> setGoalCompleted({
    required String goalId,
    required bool completed,
  }) async {
    return GoalMapper.fromJson(
      await _api.patch(
        '$_path/$goalId/complete',
        body: <String, Object?>{'completed': completed},
      ),
    );
  }

  /// The intended state is sent, not a flip. Two taps racing on a flip both
  /// invert and the second undoes the first.
  @override
  Future<Goal> setActionDone({
    required String goalId,
    required String actionId,
    required bool isDone,
  }) async {
    return GoalMapper.fromJson(
      await _api.patch(
        '$_path/$goalId/actions/$actionId/toggle',
        body: <String, Object?>{'isDone': isDone},
      ),
    );
  }

  @override
  Future<Goal> setMilestoneReached({
    required String goalId,
    required String milestoneId,
    required bool isReached,
  }) async {
    return GoalMapper.fromJson(
      await _api.patch(
        '$_path/$goalId/milestones/$milestoneId/reach',
        body: <String, Object?>{'reached': isReached},
      ),
    );
  }

  @override
  Future<Goal> addActionItem({
    required String goalId,
    required String title,
  }) async {
    return GoalMapper.fromJson(
      await _api.post(
        '$_path/$goalId/actions',
        body: <String, Object?>{'title': title},
      ),
    );
  }
}

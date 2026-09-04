import '../models/action_item.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/principle.dart';
import 'json_reader.dart';

/// Translates between the goal endpoints and the app's models.
///
/// The one place a wire field name meets a Dart field for goals, so a rename
/// on either side is a single edit here rather than a hunt through the
/// repository.
///
/// The derived fields the API sends — `status`, `isCompleted`, `progress`,
/// `actionsDone` — are deliberately ignored. The Dart model computes all four
/// from `completedAt` and the milestone list, and reading them from the wire
/// would give the app two answers that could disagree. They are on the
/// response for other consumers, not for this one.
class GoalMapper {
  const GoalMapper._();

  static Goal fromJson(Map<String, Object?> json) {
    final String id = Json.text(json['id']);
    final DateTime createdAt = Json.date(json['createdAt']);

    return Goal(
      id: id,
      title: Json.localized(json['title']),
      why: Json.localized(json['why']),
      principle: Json.enumByName(
        json['principle'],
        Principle.values,
        Principle.purpose,
      ),
      createdAt: createdAt,
      targetDate: Json.date(json['targetDate'], fallback: createdAt),
      milestones: Json.objects(
        json['milestones'],
      ).map(_milestoneFromJson).toList(growable: false),
      actions: Json.objects(json['actions'])
          .map((Map<String, Object?> entry) => _actionFromJson(entry, id))
          .toList(growable: false),
      completedAt: Json.dateOrNull(json['completedAt']),
    );
  }

  static List<Goal> listFromJson(Object? value) {
    return Json.objects(value).map(fromJson).toList(growable: false);
  }

  static Milestone _milestoneFromJson(Map<String, Object?> json) {
    return Milestone(
      id: Json.text(json['id']),
      title: Json.localized(json['title']),
      dueDate: Json.date(json['dueDate']),
      reachedAt: Json.dateOrNull(json['reachedAt']),
    );
  }

  /// `goalId` is denormalised onto the Dart model but not always onto the
  /// wire entry, so the goal being parsed supplies it.
  static ActionItem _actionFromJson(Map<String, Object?> json, String goalId) {
    return ActionItem(
      id: Json.text(json['id']),
      goalId: Json.text(json['goalId'], fallback: goalId),
      title: Json.localized(json['title']),
      isDone: Json.flag(json['isDone']),
      isToday: Json.flag(json['isToday']),
    );
  }

  /// The body `POST /v1/me/goals` takes.
  ///
  /// Title and reason go over as plain strings, not locale maps: they are the
  /// person's own words, and the backend stores them in one column and echoes
  /// them back under both codes.
  static Map<String, Object?> createBody({
    required String title,
    required String why,
    required Principle principle,
    required DateTime targetDate,
  }) {
    return <String, Object?>{
      'title': title,
      'why': why,
      'principle': principle.name,
      'targetDate': targetDate.toUtc().toIso8601String(),
    };
  }

  /// The body `PATCH /v1/me/goals/:id` takes, for an edited goal.
  ///
  /// Sent from the model rather than from the sheet's fields, because that is
  /// what the repository interface is handed — the whole goal, edited in place.
  static Map<String, Object?> updateBody(Goal goal) {
    return <String, Object?>{
      'title': goal.titleFor('en'),
      'why': goal.whyFor('en'),
      'principle': goal.principle.name,
      'targetDate': goal.targetDate.toUtc().toIso8601String(),
    };
  }
}

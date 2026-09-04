import '../models/milestone.dart';
import '../models/principle.dart';
import '../models/progress_snapshot.dart';
import 'goal_mapper.dart';
import 'json_reader.dart';

/// Translates `/v1/me/progress` into what the Progress screen charts.
///
/// The milestone shape comes from [GoalMapper]: a reached milestone is the
/// same thing whether it arrives on a goal or in the achievements list, so it
/// is mapped once.
class ProgressMapper {
  const ProgressMapper._();

  static List<ProgressSnapshot> snapshotsFromJson(Object? value) {
    return Json.objects(value)
        .map(
          (Map<String, Object?> entry) => ProgressSnapshot(
            // A snapshot's date is a calendar day, so it arrives as
            // `YYYY-MM-DD` rather than a timestamp.
            date: Json.date(entry['date']),
            goalCompletion: Json.number(entry['goalCompletion']),
            actionsCompleted: Json.integer(entry['actionsCompleted']),
            exercisesCompleted: Json.integer(entry['exercisesCompleted']),
          ),
        )
        .toList(growable: false);
  }

  /// Completed exercises per principle.
  ///
  /// The API sends all seven, zeros included, so the chart draws seven bars
  /// without the app filling any gaps of its own.
  static Map<Principle, int> breakdownFromJson(Object? value) {
    final Map<String, Object?> raw = Json.object(value);
    final Map<Principle, int> breakdown = <Principle, int>{};

    for (final Principle principle in Principle.values) {
      breakdown[principle] = Json.integer(raw[principle.name]);
    }
    return breakdown;
  }

  static List<Milestone> milestonesFromJson(Object? value) {
    return Json.objects(
      value,
    ).map(GoalMapper.milestoneFromJson).toList(growable: false);
  }

  /// The four counters above the charts, already keyed as the app reads them.
  static Map<String, int> headlineFromJson(Object? value) {
    final Map<String, Object?> raw = Json.object(value);
    return <String, int>{
      for (final MapEntry<String, Object?> entry in raw.entries)
        entry.key: Json.integer(entry.value),
    };
  }
}

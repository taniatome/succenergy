import 'action_item.dart';
import 'milestone.dart';
import 'principle.dart';

/// Whether a goal is still being worked or has been closed.
enum GoalStatus { active, completed }

/// A goal the user is moving through the cycle with.
///
/// The same goal is referenced by the Dashboard, the Goals list, Goal Detail,
/// the AI Coach conversation and Progress.
class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.why,
    required this.principle,
    required this.createdAt,
    required this.targetDate,
    required this.milestones,
    required this.actions,
    this.completedAt,
  });

  final String id;

  /// Locale code to goal title.
  final Map<String, String> title;

  /// Locale code to the reason the goal matters.
  final Map<String, String> why;

  final Principle principle;
  final DateTime createdAt;
  final DateTime targetDate;
  final List<Milestone> milestones;
  final List<ActionItem> actions;
  final DateTime? completedAt;

  GoalStatus get status =>
      completedAt == null ? GoalStatus.active : GoalStatus.completed;

  bool get isCompleted => completedAt != null;

  /// The title for [localeCode], falling back to English.
  String titleFor(String localeCode) => title[localeCode] ?? title['en'] ?? '';

  /// The reason for [localeCode], falling back to English.
  String whyFor(String localeCode) => why[localeCode] ?? why['en'] ?? '';

  /// Completion from 0 to 1, derived from milestones reached.
  double get progress {
    if (isCompleted) {
      return 1;
    }
    if (milestones.isEmpty) {
      return 0;
    }
    final int reached = milestones.where((Milestone m) => m.isReached).length;
    return reached / milestones.length;
  }

  int get actionsDone => actions.where((ActionItem a) => a.isDone).length;

  /// The next milestone still ahead, or null once all are reached.
  Milestone? get nextMilestone {
    for (final Milestone m in milestones) {
      if (!m.isReached) {
        return m;
      }
    }
    return null;
  }

  /// Returns a copy with the given fields replaced.
  ///
  /// [clearCompletedAt] reopens a closed goal; without it a null
  /// [completedAt] leaves the existing value alone, as elsewhere in the
  /// models.
  Goal copyWith({
    Map<String, String>? title,
    Map<String, String>? why,
    Principle? principle,
    DateTime? targetDate,
    List<Milestone>? milestones,
    List<ActionItem>? actions,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      why: why ?? this.why,
      principle: principle ?? this.principle,
      createdAt: createdAt,
      targetDate: targetDate ?? this.targetDate,
      milestones: milestones ?? this.milestones,
      actions: actions ?? this.actions,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }
}

/// A single concrete step inside a goal's action plan.
///
/// The item flagged [isToday] is what the Dashboard surfaces as the one
/// action for the day.
class ActionItem {
  const ActionItem({
    required this.id,
    required this.goalId,
    required this.title,
    this.isDone = false,
    this.isToday = false,
  });

  final String id;
  final String goalId;

  /// Locale code to action title.
  final Map<String, String> title;

  final bool isDone;
  final bool isToday;

  /// The title for [localeCode], falling back to English.
  String titleFor(String localeCode) => title[localeCode] ?? title['en'] ?? '';

  ActionItem copyWith({bool? isDone, bool? isToday}) {
    return ActionItem(
      id: id,
      goalId: goalId,
      title: title,
      isDone: isDone ?? this.isDone,
      isToday: isToday ?? this.isToday,
    );
  }
}

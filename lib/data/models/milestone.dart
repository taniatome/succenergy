/// A dated checkpoint on the way to a goal.
///
/// Rendered as the connected vertical timeline on Goal Detail.
class Milestone {
  const Milestone({
    required this.id,
    required this.title,
    required this.dueDate,
    this.reachedAt,
  });

  final String id;

  /// Locale code to milestone title.
  final Map<String, String> title;

  final DateTime dueDate;

  /// Null while the milestone is still ahead of the user.
  final DateTime? reachedAt;

  bool get isReached => reachedAt != null;

  /// The title for [localeCode], falling back to English.
  String titleFor(String localeCode) => title[localeCode] ?? title['en'] ?? '';

  Milestone copyWith({DateTime? reachedAt, bool clearReachedAt = false}) {
    return Milestone(
      id: id,
      title: title,
      dueDate: dueDate,
      reachedAt: clearReachedAt ? null : (reachedAt ?? this.reachedAt),
    );
  }
}

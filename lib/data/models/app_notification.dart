/// The kinds of notification the app sends, each with its own icon treatment.
enum NotificationType {
  goalNudge,
  principleOfDay,
  reengagement,
  exerciseReminder,
  milestone,
}

/// One entry in the notification inbox.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.isRead = false,
  });

  final String id;
  final NotificationType type;

  /// Locale code to notification heading.
  final Map<String, String> title;

  /// Locale code to notification body.
  final Map<String, String> body;

  final DateTime receivedAt;
  final bool isRead;

  String titleFor(String localeCode) => title[localeCode] ?? title['en'] ?? '';

  String bodyFor(String localeCode) => body[localeCode] ?? body['en'] ?? '';

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      receivedAt: receivedAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

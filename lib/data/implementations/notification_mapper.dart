import '../models/app_notification.dart';
import 'json_reader.dart';

/// Translates the notification endpoints into the app's inbox model.
class NotificationMapper {
  const NotificationMapper._();

  /// Wire types are snake case; the Dart enum is camel case.
  static const Map<String, NotificationType> _types =
      <String, NotificationType>{
        'goal_nudge': NotificationType.goalNudge,
        'principle_of_day': NotificationType.principleOfDay,
        'reengagement': NotificationType.reengagement,
        'exercise_reminder': NotificationType.exerciseReminder,
        'milestone': NotificationType.milestone,
      };

  static AppNotification fromJson(Map<String, Object?> json) {
    return AppNotification(
      id: Json.text(json['id']),
      type: _types[Json.text(json['type'])] ?? NotificationType.goalNudge,
      title: Json.localized(json['title']),
      body: Json.localized(json['body']),
      receivedAt: Json.date(json['receivedAt']),
      isRead: Json.flag(json['isRead']),
    );
  }

  static List<AppNotification> listFromJson(Object? value) {
    return Json.objects(value).map(fromJson).toList(growable: false);
  }

  /// The five per-type switches, as the app's preference list reads them.
  ///
  /// The stored map only holds the switches that have been changed, so a key
  /// that is absent takes its default from the master reminders switch —
  /// which is what "reminders are on unless you turned this one off" means.
  static Map<String, bool> preferencesFromJson(Map<String, Object?> json) {
    final bool master = Json.flag(json['remindersEnabled'], fallback: true);
    final Map<String, Object?> stored = Json.object(json['types']);

    final Map<String, bool> preferences = <String, bool>{};
    for (final String key in preferenceKeys) {
      preferences[key] = Json.flag(stored[key], fallback: master);
    }
    return preferences;
  }

  /// The switches the Notifications screen renders, in display order.
  ///
  /// Localisation keys, and the same keys the API stores them under — the app
  /// resolves them for display and the backend never sees the text.
  static const List<String> preferenceKeys = <String>[
    'notifications.pref.goalNudges',
    'notifications.pref.principleOfDay',
    'notifications.pref.reengagement',
    'notifications.pref.exerciseReminders',
    'notifications.pref.quietHours',
  ];
}

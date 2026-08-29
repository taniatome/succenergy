import '../models/app_notification.dart';

/// The notification inbox and the delivery preferences behind it.
abstract class NotificationsRepository {
  Future<List<AppNotification>> loadNotifications();

  Future<void> markRead(String id);

  Future<void> markAllRead();

  /// Preference key to whether it is switched on.
  Future<Map<String, bool>> loadPreferences();

  Future<void> setPreference({required String key, required bool enabled});

  /// Queues a notification composed in the management console.
  Future<void> queueBroadcast({
    required String audienceKey,
    required String heading,
    required String body,
  });
}

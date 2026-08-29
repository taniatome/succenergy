import '../../models/app_notification.dart';
import '../../repositories/notifications_repository.dart';
import '../mock_data.dart';

/// In-memory notification inbox and preference switches.
class MockNotificationsRepository implements NotificationsRepository {
  final List<AppNotification> _items = List<AppNotification>.from(
    MockData.notifications,
  );
  final Map<String, bool> _preferences = Map<String, bool>.from(
    MockData.notificationPreferences,
  );

  @override
  Future<List<AppNotification>> loadNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return List<AppNotification>.unmodifiable(_items);
  }

  @override
  Future<void> markRead(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final int index = _items.indexWhere((AppNotification n) => n.id == id);
    if (index == -1) {
      return;
    }
    _items[index] = _items[index].copyWith(isRead: true);
  }

  @override
  Future<void> markAllRead() async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    for (int i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
  }

  @override
  Future<Map<String, bool>> loadPreferences() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return Map<String, bool>.unmodifiable(_preferences);
  }

  @override
  Future<void> setPreference({
    required String key,
    required bool enabled,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _preferences[key] = enabled;
  }

  @override
  Future<void> queueBroadcast({
    required String audienceKey,
    required String heading,
    required String body,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
  }
}

import '../../core/network/api_client.dart';
import '../models/app_notification.dart';
import '../repositories/notifications_repository.dart';
import 'notification_mapper.dart';

/// The inbox against `/v1/me/notifications`.
///
/// The API orders unread first, so the list arrives in the order the screen
/// shows it and nothing here re-sorts it.
class ApiNotificationsRepository implements NotificationsRepository {
  const ApiNotificationsRepository(this._api);

  final ApiClient _api;

  static const String _path = '/me/notifications';
  static const String _preferencesPath = '/me/notification-preferences';

  @override
  Future<List<AppNotification>> loadNotifications() async {
    return NotificationMapper.listFromJson(await _api.getAll(_path));
  }

  @override
  Future<void> markRead(String id) async {
    await _api.patch('$_path/$id/read');
  }

  @override
  Future<void> markAllRead() async {
    await _api.patch('$_path/read-all');
  }

  @override
  Future<Map<String, bool>> loadPreferences() async {
    return NotificationMapper.preferencesFromJson(
      await _api.get(_preferencesPath),
    );
  }

  /// Writes one switch, leaving the other four alone.
  ///
  /// The API merges the map rather than replacing it, which is why sending
  /// just the key that changed is safe — and why this does not have to read
  /// the other four back first.
  @override
  Future<void> setPreference({
    required String key,
    required bool enabled,
  }) async {
    await _api.patch(
      _preferencesPath,
      body: <String, Object?>{
        'types': <String, Object?>{key: enabled},
      },
    );
  }

  /// Queues a notification composed in the management console.
  ///
  /// The audience arrives as a localisation key from the composer's segmented
  /// control, so it is mapped to the name the API takes. An unknown key goes
  /// to everyone, which is what the control's first option is.
  @override
  Future<void> queueBroadcast({
    required String audienceKey,
    required String heading,
    required String body,
  }) async {
    await _api.post(
      '/admin/notifications',
      body: <String, Object?>{
        'audience': _audiences[audienceKey] ?? 'all',
        // The console composes nudges; the type is not part of its form.
        'type': 'goal_nudge',
        'title': heading,
        'body': body,
      },
    );
  }

  static const Map<String, String> _audiences = <String, String>{
    'admin.notify.audience.all': 'all',
    'admin.notify.audience.free': 'trial',
    'admin.notify.audience.premium': 'paying',
  };

  /// Removes one notification. Not on the interface yet; the endpoint exists
  /// and this is its client for when the inbox offers a swipe to delete.
  Future<void> deleteNotification(String id) => _api.delete('$_path/$id');
}

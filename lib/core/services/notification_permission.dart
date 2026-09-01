import 'package:permission_handler/permission_handler.dart';

/// The one-shot native notification permission request.
///
/// Push itself is not wired yet: this exists so the system dialog appears at
/// the right moment in the journey — the first entry into the app after
/// onboarding — and so the answer is on record for when messaging is added.
///
/// [requestOnce] is safe to call from anywhere and more than once: it runs the
/// native request at most once per launch, and on a platform with no
/// permission plugin behind it (desktop, tests) it records nothing and
/// returns quietly rather than throwing into the widget that called it.
class NotificationPermission {
  const NotificationPermission._();

  static bool _asked = false;
  static bool? _granted;

  /// Whether the request has run this launch.
  static bool get asked => _asked;

  /// True if granted, false if refused, null if never answered.
  static bool? get granted => _granted;

  /// Asks for notification permission the first time it is called.
  static Future<void> requestOnce() async {
    if (_asked) {
      return;
    }
    _asked = true;
    try {
      final PermissionStatus status = await Permission.notification.request();
      _granted = status.isGranted;
    } on Object {
      // No plugin on this platform. Nothing was asked, so nothing is stored.
      _granted = null;
    }
  }

  /// Clears the record, so a test can drive the request again.
  static void reset() {
    _asked = false;
    _granted = null;
  }
}

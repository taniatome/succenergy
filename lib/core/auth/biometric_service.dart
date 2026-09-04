import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Which biometric the device offers, so the copy can name it.
///
/// "Use Face ID" and "Use your fingerprint" are worth the distinction; beyond
/// those two, [generic] covers whatever the hardware calls its own.
enum BiometricKind { none, face, fingerprint, generic }

/// The device's biometric check.
///
/// Every call is guarded. local_auth throws a [PlatformException] on a device
/// with no hardware, no enrolment or a locked-out sensor, and a
/// [MissingPluginException] where the plugin does not exist at all — the
/// desktop builds, and the widget tests. None of those are errors the user
/// should see: they mean the password form is the way in, and the password
/// form is always there.
class BiometricService {
  BiometricService({LocalAuthentication? plugin})
    : _plugin = plugin ?? LocalAuthentication();

  final LocalAuthentication _plugin;

  /// True when the device can run a biometric check at all.
  Future<bool> isSupported() async {
    try {
      if (!await _plugin.isDeviceSupported()) {
        return false;
      }
      return _plugin.canCheckBiometrics;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// What the device offers, for the copy that asks to use it.
  Future<BiometricKind> kind() async {
    try {
      final List<BiometricType> available =
          await _plugin.getAvailableBiometrics();
      if (available.isEmpty) {
        return BiometricKind.none;
      }
      if (available.contains(BiometricType.face)) {
        return BiometricKind.face;
      }
      if (available.contains(BiometricType.fingerprint)) {
        return BiometricKind.fingerprint;
      }
      return BiometricKind.generic;
    } on PlatformException {
      return BiometricKind.none;
    } on MissingPluginException {
      return BiometricKind.none;
    }
  }

  /// Runs the system prompt. False for a failure and for a cancellation
  /// alike: neither is worth telling the user about, because the form they
  /// fall back to is already on screen.
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _plugin.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          // The prompt survives the app going to the background, which is
          // what a fingerprint sensor on the back of a phone needs.
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

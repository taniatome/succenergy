import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Everything the app keeps on the device between launches.
///
/// The platform keystore, not shared preferences: the biometric credentials
/// are a real password, and the Keychain on iOS and EncryptedSharedPreferences
/// on Android are the only places on a phone meant to hold one. The ID token is
/// deliberately absent — Firebase holds and refreshes that itself.
///
/// Every call is guarded. A keystore can refuse to answer — a corrupted
/// Android keyset, a Keychain locked at the wrong moment, or a platform with
/// no plugin at all, which covers the desktop builds and the widget tests. A
/// store that cannot be read means biometric sign-in is not available on this
/// launch; it does not mean the app is broken, so every read falls back to
/// "nothing stored" and every write fails quietly.
class SecureSessionStore {
  const SecureSessionStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  final FlutterSecureStorage _storage;

  static const String _bioEnabled = 'bio_enabled';
  static const String _bioEmail = 'bio_email';
  static const String _bioPassword = 'bio_password';
  static const String _trialTaken = 'trial_taken';

  /// True once the user has opted into signing in with a fingerprint or face.
  Future<bool> isBiometricEnabled() async => await _read(_bioEnabled) == 'true';

  /// The stored pair, or null if biometric sign-in is off or incomplete.
  Future<({String email, String password})?> readBiometricCredentials() async {
    if (!await isBiometricEnabled()) {
      return null;
    }
    final String? email = await _read(_bioEmail);
    final String? password = await _read(_bioPassword);
    if (email == null || password == null) {
      return null;
    }
    return (email: email, password: password);
  }

  Future<void> enableBiometric({
    required String email,
    required String password,
  }) async {
    await _write(_bioEmail, email);
    await _write(_bioPassword, password);
    await _write(_bioEnabled, 'true');
  }

  /// Forgets the credentials and turns the option off.
  ///
  /// Called on log out, and again whenever Firebase rejects what was stored —
  /// a changed password or a disabled account — so a stale pair is never
  /// offered a second time.
  Future<void> clearBiometric() async {
    await _delete(_bioEmail);
    await _delete(_bioPassword);
    await _write(_bioEnabled, 'false');
  }

  /// Whether this account has taken the trial.
  ///
  /// A local record, because the API does not yet report the subscription on
  /// `GET /v1/me`: the column exists and RevenueCat webhooks write it, but the
  /// response does not carry it. Keyed by uid so two accounts on one device do
  /// not inherit each other's access, and superseded the moment the server
  /// starts answering with a subscription of its own.
  Future<bool> hasTakenTrial(String uid) async =>
      await _read('$_trialTaken:$uid') == 'true';

  Future<void> recordTrialTaken(String uid) =>
      _write('$_trialTaken:$uid', 'true');

  Future<void> forgetTrial(String uid) => _delete('$_trialTaken:$uid');

  /// Wipes everything this store holds. Used on log out and account deletion.
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } on PlatformException {
      // Nothing readable is nothing to leak, and the sign-out proceeds.
    } on MissingPluginException {
      // No keystore on this platform; there was nothing here to wipe.
    }
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException {
      // The offer to remember a credential simply does not take.
    } on MissingPluginException {
      // No keystore on this platform.
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on PlatformException {
      // Already unreadable, which is the outcome delete was after.
    } on MissingPluginException {
      // No keystore on this platform.
    }
  }
}

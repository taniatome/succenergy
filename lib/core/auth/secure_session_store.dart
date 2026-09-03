import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Everything the app keeps on the device between launches.
///
/// The platform keystore, not shared preferences: the biometric credentials
/// are a real password, and the Keychain on iOS and EncryptedSharedPreferences
/// on Android are the only places on a phone that are meant to hold one. The
/// ID token is deliberately absent — Firebase holds and refreshes that itself.
class SecureSessionStore {
  const SecureSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  final FlutterSecureStorage _storage;

  static const String _bioEnabled = 'bio_enabled';
  static const String _bioEmail = 'bio_email';
  static const String _bioPassword = 'bio_password';
  static const String _trialTaken = 'trial_taken';

  /// True once the user has opted into signing in with a fingerprint or face.
  Future<bool> isBiometricEnabled() async =>
      await _storage.read(key: _bioEnabled) == 'true';

  /// The stored pair, or null if biometric sign-in is off or incomplete.
  Future<({String email, String password})?> readBiometricCredentials() async {
    if (!await isBiometricEnabled()) {
      return null;
    }
    final String? email = await _storage.read(key: _bioEmail);
    final String? password = await _storage.read(key: _bioPassword);
    if (email == null || password == null) {
      return null;
    }
    return (email: email, password: password);
  }

  Future<void> enableBiometric({
    required String email,
    required String password,
  }) async {
    await _storage.write(key: _bioEmail, value: email);
    await _storage.write(key: _bioPassword, value: password);
    await _storage.write(key: _bioEnabled, value: 'true');
  }

  /// Forgets the credentials and turns the option off.
  ///
  /// Called on log out, and again whenever Firebase rejects what was stored —
  /// a changed password or a disabled account — so a stale pair is never
  /// offered a second time.
  Future<void> clearBiometric() async {
    await _storage.delete(key: _bioEmail);
    await _storage.delete(key: _bioPassword);
    await _storage.write(key: _bioEnabled, value: 'false');
  }

  /// Whether this account has taken the trial.
  ///
  /// A local record, because the API does not yet report the subscription on
  /// `GET /v1/me`: the column exists and RevenueCat webhooks write it, but the
  /// response does not carry it. Keyed by uid so two accounts on one device do
  /// not inherit each other's access, and superseded the moment the server
  /// starts answering with a subscription of its own.
  Future<bool> hasTakenTrial(String uid) async =>
      await _storage.read(key: '$_trialTaken:$uid') == 'true';

  Future<void> recordTrialTaken(String uid) =>
      _storage.write(key: '$_trialTaken:$uid', value: 'true');

  Future<void> forgetTrial(String uid) =>
      _storage.delete(key: '$_trialTaken:$uid');

  /// Wipes everything this store holds. Used on log out and account deletion.
  Future<void> clearAll() => _storage.deleteAll();
}

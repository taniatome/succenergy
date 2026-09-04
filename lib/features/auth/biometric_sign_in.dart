import '../../core/auth/biometric_service.dart';
import '../../core/auth/secure_session_store.dart';
import '../../data/repositories/auth_failure.dart';
import '../../data/repositories/auth_repository.dart';

/// Biometric sign-in, without the widgets.
///
/// The sign-in screen owns the sheet and the overlay; the order of operations
/// — read the store, run the prompt, use the credentials, forget them if they
/// no longer work — lives here, so the screen stays a screen.
class BiometricSignIn {
  const BiometricSignIn({
    required SecureSessionStore store,
    required BiometricService service,
    required AuthRepository repository,
  }) : _store = store,
       _service = service,
       _repository = repository;

  final SecureSessionStore _store;
  final BiometricService _service;
  final AuthRepository _repository;

  /// How long the device is given to answer before the offer is abandoned.
  ///
  /// Only the checks that happen before the system prompt are bounded — a
  /// keystore that has wedged, or hardware that never reports. The prompt
  /// itself is not: the person in front of it takes as long as they take. The
  /// point is that a device which never answers leaves the password form
  /// usable instead of a veil over it with no way back.
  static const Duration _deviceTimeout = Duration(seconds: 5);

  /// Signs in with the stored credentials behind a biometric check.
  ///
  /// False covers every way this can not happen: nothing stored, no hardware,
  /// a failed or cancelled prompt, or credentials Firebase no longer accepts.
  /// None of them is reported to the user — the password form is on the screen
  /// underneath and ready, and "biometric sign-in failed" tells someone
  /// nothing they can act on.
  ///
  /// Credentials Firebase rejects are cleared rather than kept: the password
  /// was changed or the account was disabled, and offering the same stale pair
  /// on the next launch would fail exactly the same way.
  Future<bool> attempt({required String reason}) async {
    final ({String email, String password})? stored = await _store
        .readBiometricCredentials()
        .timeout(_deviceTimeout, onTimeout: () => null);
    if (stored == null || !await _supported()) {
      return false;
    }
    if (!await _service.authenticate(reason: reason)) {
      return false;
    }

    try {
      await _repository.logIn(email: stored.email, password: stored.password);
      return true;
    } on AuthException catch (error) {
      if (error.reason != AuthFailure.network) {
        await _store.clearBiometric();
      }
      return false;
    }
  }

  /// What the device offers, or null when there is no offer worth making —
  /// biometric sign-in is already on, or the hardware cannot do it.
  Future<BiometricKind?> offerable() async {
    final bool enabled = await _store.isBiometricEnabled().timeout(
      _deviceTimeout,
      onTimeout: () => true,
    );
    if (enabled || !await _supported()) {
      return null;
    }
    final BiometricKind kind = await _service.kind();
    return kind == BiometricKind.none ? null : kind;
  }

  Future<bool> _supported() =>
      _service.isSupported().timeout(_deviceTimeout, onTimeout: () => false);

  /// Remembers the pair that just worked.
  Future<void> remember({required String email, required String password}) =>
      _store.enableBiometric(email: email, password: password);
}

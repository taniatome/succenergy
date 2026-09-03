import '../../data/repositories/auth_failure.dart';

/// The message shown for a failed authentication attempt.
///
/// One place, so the wording cannot drift between the sign-in screen and
/// registration. Nothing here names a field or an address: several distinct
/// Firebase codes already collapse into [AuthFailure.invalidCredentials], and
/// the copy that reason maps to has to hold that line too — "incorrect email
/// or password" and never "no account for that address".
class AuthFailureCopy {
  const AuthFailureCopy._();

  /// Localisation key for [reason], for an error shown under a password field.
  static String keyFor(AuthFailure reason) {
    switch (reason) {
      case AuthFailure.invalidCredentials:
        return 'auth.error.signInFailed';
      case AuthFailure.emailInUse:
        return 'auth.error.emailInUse';
      case AuthFailure.weakPassword:
        return 'auth.error.passwordWeak';
      case AuthFailure.userDisabled:
        return 'auth.error.accountDisabled';
      case AuthFailure.tooManyRequests:
        return 'auth.error.tooManyAttempts';
      case AuthFailure.network:
        return 'auth.error.network';
      case AuthFailure.unavailable:
        return 'auth.error.unavailable';
      case AuthFailure.unknown:
        return 'auth.error.generic';
    }
  }
}

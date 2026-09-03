/// Why an authentication attempt did not succeed.
///
/// A reason rather than a message: the copy shown to the user comes from the
/// string tables, and several distinct Firebase codes deliberately collapse
/// into [AuthFailure.invalidCredentials] so a failed sign-in never reveals
/// whether the email address is one we know.
enum AuthFailure {
  /// Wrong password, unknown email, or a malformed credential. One case on
  /// purpose.
  invalidCredentials,

  /// Registration hit an address that already has an account.
  emailInUse,

  /// Firebase rejected the password as too weak.
  weakPassword,

  /// The account was disabled from the console.
  userDisabled,

  /// Too many attempts from this device.
  tooManyRequests,

  /// The request never reached Firebase or the API.
  network,

  /// The Firebase SDK is not configured on this build.
  unavailable,

  /// Anything else. Reported as a generic failure.
  unknown,
}

/// A failed authentication attempt.
class AuthException implements Exception {
  const AuthException(this.reason);

  /// Maps a `FirebaseAuthException.code` to the reason the app acts on.
  ///
  /// Wrong password, unknown email and a malformed credential all collapse
  /// into [AuthFailure.invalidCredentials] on purpose: a failed sign-in must
  /// never say which of the two fields was wrong, because that answers
  /// whether the address has an account.
  factory AuthException.fromFirebaseCode(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-email':
        return const AuthException(AuthFailure.invalidCredentials);
      case 'email-already-in-use':
        return const AuthException(AuthFailure.emailInUse);
      case 'weak-password':
        return const AuthException(AuthFailure.weakPassword);
      case 'user-disabled':
        return const AuthException(AuthFailure.userDisabled);
      case 'too-many-requests':
        return const AuthException(AuthFailure.tooManyRequests);
      case 'network-request-failed':
        return const AuthException(AuthFailure.network);
      default:
        return const AuthException(AuthFailure.unknown);
    }
  }

  final AuthFailure reason;

  @override
  String toString() => 'AuthException(${reason.name})';
}

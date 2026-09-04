import '../../data/repositories/auth_failure.dart';
import 'api_exception.dart';

/// Why a screen has no data, in a form a provider can hold and a widget can
/// render.
///
/// Providers catch [ApiException] and [AuthException] and keep one of these
/// instead. Nothing above the data layer sees an exception type, a status
/// code or a message the server wrote — the copy comes from the string
/// tables, keyed by [messageKey].
enum RequestFailure {
  /// The request never reached the server, or it did not answer in time.
  offline,

  /// The server answered with something the app cannot act on.
  server,

  /// The session is gone. The router is already moving the app to Welcome.
  signedOut,

  /// Anything else.
  unknown;

  /// Localisation key for what to tell the user.
  String get messageKey {
    switch (this) {
      case RequestFailure.offline:
        return 'error.offline';
      case RequestFailure.server:
        return 'error.server';
      case RequestFailure.signedOut:
        return 'error.signedOut';
      case RequestFailure.unknown:
        return 'error.generic';
    }
  }

  /// True when trying again might work. A revoked session will not.
  bool get isRetryable => this != RequestFailure.signedOut;

  /// Classifies whatever a repository threw.
  ///
  /// A single entry point, so a provider's catch block is one line and no
  /// screen ends up branching on an exception type. Anything unrecognised
  /// becomes [RequestFailure.unknown] rather than being rethrown: a provider
  /// that rethrows leaves the screen on its loading state forever, which is
  /// the one outcome worse than a wrong message.
  static RequestFailure from(Object error) {
    if (error is ApiException) {
      switch (error.kind) {
        case ApiFailureKind.offline:
          return RequestFailure.offline;
        case ApiFailureKind.unauthorized:
          return RequestFailure.signedOut;
        case ApiFailureKind.notFound:
        case ApiFailureKind.server:
          return RequestFailure.server;
      }
    }
    if (error is AuthException) {
      return error.reason == AuthFailure.network
          ? RequestFailure.offline
          : RequestFailure.signedOut;
    }
    return RequestFailure.unknown;
  }
}

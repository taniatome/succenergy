/// Why a call to the Succenergy API did not return data.
///
/// The reason is an enum rather than a message: nothing the server writes is
/// ever shown to the user, so each case is mapped to copy from the string
/// tables at the point it is caught.
enum ApiFailureKind {
  /// The token was rejected twice, once after a forced refresh. The session
  /// has been revoked server-side and the app has to sign out.
  unauthorized,

  /// No resource for this account yet. On `/v1/me` this means registration
  /// never finished and the profile still has to be created.
  notFound,

  /// The request never reached the server, or it did not answer in time.
  offline,

  /// The server answered, but not with something this app can act on.
  server,
}

/// A failed API call.
class ApiException implements Exception {
  const ApiException(this.kind, {this.code, this.status});

  final ApiFailureKind kind;

  /// The backend's own machine-readable code, e.g. `profile_not_found`.
  /// Useful in a log; never rendered.
  final String? code;

  final int? status;

  /// True when the profile row does not exist for an otherwise valid session.
  bool get isProfileMissing =>
      kind == ApiFailureKind.notFound && code == 'profile_not_found';

  @override
  String toString() => 'ApiException(${kind.name}, code: $code, status: $status)';
}

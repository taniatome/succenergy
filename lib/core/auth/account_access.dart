/// What the signed-in account may reach.
///
/// An enum rather than a profile object: the router branches on this alone,
/// and keeping the data models out of `core/` is what lets the auth state sit
/// above the data layer instead of inside it.
enum AccountAccess {
  /// Nothing read yet. The splash screen holds here.
  unknown,

  /// `GET /v1/me` answered 404. A Firebase account exists but registration
  /// never wrote the profile behind it, so the app has to finish it.
  profileMissing,

  /// A profile exists and the trial has not been taken, or has lapsed. The
  /// paywall.
  locked,

  /// Trialing or active. Everything opens.
  open,
}

/// Reads the account behind the current session.
///
/// Declared here and implemented by the auth repository, so `core/` states
/// what it needs and the data layer supplies it rather than the other way
/// round.
abstract class SessionResolver {
  /// Throws `ApiException` rather than returning a failure: an unreachable
  /// server and a revoked session are different outcomes and the caller
  /// treats them differently.
  Future<AccountAccess> resolveSession();
}

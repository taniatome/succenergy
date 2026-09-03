import '../../core/auth/account_access.dart';
import '../models/user.dart';
import '../repositories/auth_failure.dart';
import '../repositories/auth_repository.dart';

/// The repository used when the Firebase SDK could not start.
///
/// Without `google-services.json` or `GoogleService-Info.plist` there is no
/// SDK to call, and reaching for `FirebaseAuth.instance` would throw a
/// platform error from wherever it was touched. This answers every call with
/// [AuthFailure.unavailable] instead, so a misconfigured build says so on the
/// sign-in screen rather than crashing on launch.
class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();

  @override
  User? get currentUser => null;

  @override
  bool get isLoggedIn => false;

  @override
  bool get needsOnboarding => false;

  @override
  bool get hasActiveSubscription => false;

  @override
  Future<AccountAccess> resolveSession() async => AccountAccess.unknown;

  @override
  Future<User> logIn({required String email, required String password}) =>
      _refuse();

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required DateTime dateOfBirth,
    required String countryCode,
    required UserActivity activity,
    required String preferredLanguage,
    required bool acceptedTerms,
    required bool confirmedInfoTrue,
  }) => _refuse();

  @override
  Future<User> completeProfile({
    required String name,
    required DateTime dateOfBirth,
    required String countryCode,
    required UserActivity activity,
    required String preferredLanguage,
    required bool acceptedTerms,
    required bool confirmedInfoTrue,
  }) => _refuse();

  @override
  Future<void> startTrial() => _refuse();

  @override
  Future<void> sendPasswordReset(String email) => _refuse();

  /// Signing out of nothing succeeds, so Settings still returns to Welcome.
  @override
  Future<void> logOut() async {}

  @override
  Future<void> deleteAccount() => _refuse();

  Future<T> _refuse<T>() =>
      Future<T>.error(const AuthException(AuthFailure.unavailable));
}

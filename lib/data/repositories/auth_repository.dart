import '../../core/auth/account_access.dart';
import '../models/user.dart';

/// Authentication contract.
///
/// Implemented against Firebase Auth and the Succenergy API, and by the mock
/// layer for tests and the offline showcase build. Widgets talk to this and
/// never to Firebase.
///
/// It also implements [SessionResolver], which is what the router's launch
/// gate reads. Declaring it here rather than in a second class keeps one
/// answer to "who is signed in and what may they reach".
abstract class AuthRepository implements SessionResolver {
  /// The signed-in user, or null when nobody is signed in.
  User? get currentUser;

  /// True when a session exists and the app may open past Welcome.
  bool get isLoggedIn;

  /// True when the signed-in account has not completed onboarding.
  bool get needsOnboarding;

  /// True once the seven-day trial has been taken. Nothing behind the paywall
  /// opens until this is set; the router is the only place that checks it.
  bool get hasActiveSubscription;

  Future<User> logIn({required String email, required String password});

  /// Creates the Firebase account and the profile behind it, in that order.
  ///
  /// [acceptedTerms] and [confirmedInfoTrue] are the two boxes ticked at the
  /// last step of registration. They are recorded rather than assumed: the API
  /// stores each separately, so what the user actually agreed to is on the
  /// account and not inferred from the fact that the request arrived.
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
  });

  /// Writes the profile for a Firebase account that already exists.
  ///
  /// The recovery path for a session whose `GET /v1/me` answered 404: the
  /// sign-up succeeded but the profile write that follows it did not, so
  /// registration resumes at step two and finishes with this instead of
  /// creating a second account.
  Future<User> completeProfile({
    required String name,
    required DateTime dateOfBirth,
    required String countryCode,
    required UserActivity activity,
    required String preferredLanguage,
    required bool acceptedTerms,
    required bool confirmedInfoTrue,
  });

  /// Takes the trial. No payment runs in this build: the flag is recorded and
  /// the app opens.
  Future<void> startTrial();

  Future<void> sendPasswordReset(String email);

  Future<void> logOut();

  Future<void> deleteAccount();
}

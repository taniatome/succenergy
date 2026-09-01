import '../models/user.dart';

/// Authentication contract. Implemented by the mock layer for this build and
/// by a real client later without any change to widgets.
abstract class AuthRepository {
  /// The signed-in user, or null when nobody is signed in.
  User? get currentUser;

  /// True when a session exists and the app may open on the Dashboard.
  bool get isLoggedIn;

  /// True when the signed-in account has not completed onboarding.
  bool get needsOnboarding;

  /// True once the seven-day trial has been taken. Nothing behind the
  /// paywall opens until this is set; the router is the only place that
  /// checks it.
  bool get hasActiveSubscription;

  Future<User> logIn({required String email, required String password});

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required DateTime dateOfBirth,
    required String countryCode,
    required UserActivity activity,
  });

  /// Takes the trial. No payment runs in this build: the flag flips and the
  /// app opens.
  Future<void> startTrial();

  Future<void> sendPasswordReset(String email);

  Future<void> logOut();

  Future<void> deleteAccount();
}

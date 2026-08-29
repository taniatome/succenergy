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

  Future<User> logIn({required String email, required String password});

  Future<User> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset(String email);

  Future<void> logOut();

  Future<void> deleteAccount();
}

import '../../models/subscription_plan.dart';
import '../../models/user.dart';
import '../../repositories/auth_repository.dart';
import '../mock_data.dart';

/// In-memory authentication for the showcase build.
///
/// No credentials are checked: any well-formed input succeeds, because the
/// purpose here is to demonstrate the journey, not to guard anything.
///
/// A returning log-in lands on an account that already pays, so the demo can
/// reach the Dashboard directly. A fresh registration does not: it has to go
/// through the trial screen, which is what the paywall is there to show.
class MockAuthRepository implements AuthRepository {
  User? _user;
  bool _needsOnboarding = false;
  bool _hasActiveSubscription = false;

  @override
  User? get currentUser => _user;

  @override
  bool get isLoggedIn => _user != null;

  @override
  bool get needsOnboarding => _needsOnboarding;

  @override
  bool get hasActiveSubscription => _hasActiveSubscription;

  @override
  Future<User> logIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    _user = MockData.user;
    _needsOnboarding = false;
    _hasActiveSubscription = true;
    return _user!;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required DateTime dateOfBirth,
    required String countryCode,
    required UserActivity activity,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    _user = MockData.user.copyWith(
      name: name,
      email: email,
      dateOfBirth: dateOfBirth,
      countryCode: countryCode,
      activity: activity,
      tier: SubscriptionTier.trial,
    );
    _needsOnboarding = true;
    _hasActiveSubscription = false;
    return _user!;
  }

  @override
  Future<void> startTrial() async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    _hasActiveSubscription = true;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
  }

  @override
  Future<void> logOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    _user = null;
    _needsOnboarding = false;
    _hasActiveSubscription = false;
  }

  @override
  Future<void> deleteAccount() async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    _user = null;
    _needsOnboarding = false;
    _hasActiveSubscription = false;
  }
}

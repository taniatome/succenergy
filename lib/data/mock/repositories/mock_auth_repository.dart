import '../../../core/auth/account_access.dart';
import '../../models/subscription_plan.dart';
import '../../models/user.dart';
import '../../repositories/auth_repository.dart';
import '../mock_data.dart';

/// In-memory authentication.
///
/// No credentials are checked: any well-formed input succeeds, because the
/// purpose here is to exercise the journey rather than to guard anything. Kept
/// for the widget tests, which cannot reach Firebase, and for a build that has
/// to demonstrate the app with no backend behind it.
///
/// A returning log-in lands on an account that already pays, so a test can
/// reach the Dashboard directly. A fresh registration does not: it goes
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
  Future<AccountAccess> resolveSession() async {
    if (_user == null) {
      return AccountAccess.unknown;
    }
    return _hasActiveSubscription ? AccountAccess.open : AccountAccess.locked;
  }

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
    required String preferredLanguage,
    required bool acceptedTerms,
    required bool confirmedInfoTrue,
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
  Future<User> completeProfile({
    required String name,
    required DateTime dateOfBirth,
    required String countryCode,
    required UserActivity activity,
    required String preferredLanguage,
    required bool acceptedTerms,
    required bool confirmedInfoTrue,
  }) {
    return register(
      name: name,
      email: _user?.email ?? MockData.user.email,
      password: '',
      dateOfBirth: dateOfBirth,
      countryCode: countryCode,
      activity: activity,
      preferredLanguage: preferredLanguage,
      acceptedTerms: acceptedTerms,
      confirmedInfoTrue: confirmedInfoTrue,
    );
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

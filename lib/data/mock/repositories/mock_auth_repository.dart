import 'dart:async';

import '../../../core/auth/account_access.dart';
import '../../../core/auth/session_signal.dart';
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
/// It is also its own [SessionSignal]: nothing here reaches Firebase, so the
/// launch state machine is driven from the same object the calls land on,
/// which is what lets the whole journey be walked in a widget test.
class MockAuthRepository implements AuthRepository, SessionSignal {
  final StreamController<void> _changes = StreamController<void>.broadcast();

  User? _user;
  bool _needsOnboarding = false;
  bool _hasActiveSubscription = false;

  /// Opens with the current state, the way Firebase's own stream does, so the
  /// launch state machine has something to act on without waiting for a call.
  @override
  Stream<void> get changes async* {
    yield null;
    yield* _changes.stream;
  }

  @override
  bool get hasSession => _user != null;

  void _announce() {
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }

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
    _announce();
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
    _announce();
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
    _announce();
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
    _announce();
  }

  @override
  Future<void> deleteAccount() async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    _user = null;
    _needsOnboarding = false;
    _hasActiveSubscription = false;
    _announce();
  }

  void dispose() {
    _changes.close();
  }
}

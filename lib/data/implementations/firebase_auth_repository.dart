import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../core/auth/account_access.dart';
import '../../core/auth/secure_session_store.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/subscription_plan.dart';
import '../models/user.dart';
import '../repositories/auth_failure.dart';
import '../repositories/auth_repository.dart';
import 'subscription_reader.dart';
import 'user_profile_mapper.dart';

/// Authentication against Firebase Auth, with the profile in Postgres behind
/// the Succenergy API.
///
/// The split matches the backend: Firebase issues and refreshes the token and
/// the API only ever verifies it. Registration is therefore two writes — the
/// credential, then the profile — and the second can fail on its own, which
/// is what [completeProfile] exists to repair.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required ApiClient api,
    required SecureSessionStore store,
    fb.FirebaseAuth? auth,
  }) : _api = api,
       _store = store,
       _auth = auth ?? fb.FirebaseAuth.instance;

  final ApiClient _api;
  final SecureSessionStore _store;
  final fb.FirebaseAuth _auth;

  static const String _mePath = '/me';

  User? _user;
  bool _hasAccess = false;

  @override
  User? get currentUser => _user;

  @override
  bool get isLoggedIn => _auth.currentUser != null;

  @override
  bool get hasActiveSubscription => _hasAccess;

  /// Always false. The onboarding assessment is stored under
  /// `/v1/me/onboarding` and nothing in the app branches on it yet; the getter
  /// stays on the interface so both implementations keep the same shape.
  @override
  bool get needsOnboarding => false;

  // --- Session -------------------------------------------------------------

  @override
  Future<AccountAccess> resolveSession() async {
    final fb.User? account = _auth.currentUser;
    if (account == null) {
      _forget();
      return AccountAccess.unknown;
    }

    final Map<String, Object?> profile = await _api.get(_mePath);
    _hasAccess = await SubscriptionReader.hasAccess(
      profile: profile,
      uid: account.uid,
      store: _store,
    );

    final User resolved = UserProfileMapper.fromJson(profile, uid: account.uid);
    _user = resolved.copyWith(
      tier: _hasAccess ? resolved.monthlyTier : SubscriptionTier.trial,
    );
    return _hasAccess ? AccountAccess.open : AccountAccess.locked;
  }

  // --- Credentials ---------------------------------------------------------

  @override
  Future<User> logIn({required String email, required String password}) async {
    await _guard(
      () => _auth.signInWithEmailAndPassword(email: email, password: password),
    );
    return _afterSignIn();
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
    await _guard(
      () => _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
    return completeProfile(
      name: name,
      dateOfBirth: dateOfBirth,
      countryCode: countryCode,
      activity: activity,
      preferredLanguage: preferredLanguage,
      acceptedTerms: acceptedTerms,
      confirmedInfoTrue: confirmedInfoTrue,
    );
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
  }) async {
    final fb.User? account = _auth.currentUser;
    if (account == null) {
      throw const AuthException(AuthFailure.invalidCredentials);
    }

    final Map<String, Object?> profile = await _post(
      UserProfileMapper.createBody(
        name: name,
        dateOfBirth: dateOfBirth,
        countryCode: countryCode,
        activity: activity,
        preferredLanguage: preferredLanguage,
        acceptedTerms: acceptedTerms,
        confirmedInfoTrue: confirmedInfoTrue,
      ),
    );

    _hasAccess = await _store.hasTakenTrial(account.uid);
    _user = UserProfileMapper.fromJson(profile, uid: account.uid);
    return _user!;
  }

  Future<Map<String, Object?>> _post(Map<String, Object?> body) async {
    try {
      return await _api.post(_mePath, body: body);
    } on ApiException catch (error) {
      throw AuthException(
        error.kind == ApiFailureKind.offline
            ? AuthFailure.network
            : AuthFailure.unknown,
      );
    }
  }

  /// The profile read that follows a successful credential check.
  ///
  /// A 404 is not an error here: the credential is valid but registration
  /// never wrote the profile, and the router sends the account back to finish
  /// rather than refusing a sign-in that actually worked.
  Future<User> _afterSignIn() async {
    try {
      await resolveSession();
    } on ApiException catch (error) {
      if (!error.isProfileMissing) {
        throw AuthException(
          error.kind == ApiFailureKind.offline
              ? AuthFailure.network
              : AuthFailure.unknown,
        );
      }
    }
    return _user ?? _placeholder();
  }

  /// Stands in between a valid credential and a profile that does not exist
  /// yet, so a caller always has an account to read an email off.
  User _placeholder() {
    final fb.User account = _auth.currentUser!;
    return UserProfileMapper.fromJson(<String, Object?>{
      'email': account.email,
    }, uid: account.uid);
  }

  // --- Account actions -----------------------------------------------------

  @override
  Future<void> startTrial() async {
    final fb.User? account = _auth.currentUser;
    if (account == null) {
      throw const AuthException(AuthFailure.invalidCredentials);
    }
    await _store.recordTrialTaken(account.uid);
    _hasAccess = true;
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email));

  @override
  Future<void> logOut() async {
    await _store.clearAll();
    _forget();
    await _auth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final fb.User? account = _auth.currentUser;
    if (account != null) {
      // The API removes the rows and revokes the session; Firebase then drops
      // the credential. Either side failing still ends in a sign-out, so the
      // device is never left holding half a deleted account.
      try {
        await _api.delete(_mePath);
        await account.delete();
      } on ApiException {
        // The rows are the server's to reconcile; retrying here changes
        // nothing the user can see.
      } on fb.FirebaseAuthException {
        // Usually requires-recent-login. The profile is already gone.
      }
    }
    await logOut();
  }

  void _forget() {
    _user = null;
    _hasAccess = false;
  }

  /// Runs a Firebase call and reports its failures as an [AuthException].
  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on fb.FirebaseAuthException catch (error) {
      throw AuthException.fromFirebaseCode(error.code);
    }
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../network/api_exception.dart';
import 'account_access.dart';
import 'session_signal.dart';

/// Where the app is in resolving who is signed in.
enum AuthStatus {
  /// Nothing reported yet, or the account is still being read. The splash
  /// screen holds here.
  loading,

  /// Nobody is signed in.
  unauthenticated,

  /// A session exists, and [AuthState.access] says what it may reach.
  authenticated,
}

/// The app's single source of truth for the session.
///
/// Watches a [SessionSignal] and, whenever a session appears, resolves what
/// that account may reach through the [SessionResolver]. The router watches
/// this and redirects on every notification, which is why no screen in the app
/// checks whether anyone is signed in.
class AuthState extends ChangeNotifier {
  AuthState({
    required SessionResolver resolver,
    required SessionSignal signal,
    this.minimumHold = Duration.zero,
  }) : _resolver = resolver,
       _signal = signal,
       isAvailable = true {
    // The signal reports the current session on subscription, so the first
    // event is what moves the app off the splash. Reading `hasSession` here
    // instead would answer before Firebase had restored a persisted session.
    _subscription = signal.changes.listen((void _) => _onSessionChanged());
  }

  /// The state to run in when Firebase could not start.
  ///
  /// Without `google-services.json` or `GoogleService-Info.plist` there is no
  /// SDK to ask, so the app opens on Welcome and every sign-in attempt reports
  /// that authentication is unavailable, rather than holding on a splash that
  /// will never resolve.
  AuthState.unavailable()
    : _resolver = null,
      _signal = null,
      isAvailable = false,
      minimumHold = Duration.zero,
      _status = AuthStatus.unauthenticated,
      _leftLoading = true;

  final SessionResolver? _resolver;
  final SessionSignal? _signal;

  /// False when the Firebase SDK failed to initialise on this device.
  final bool isAvailable;

  /// How long the very first answer is held back for.
  ///
  /// Firebase usually reports within a frame, which would replace the splash
  /// before its brand sequence has drawn. Held here rather than in the splash
  /// screen because the router moves the app, not the screen.
  final Duration minimumHold;

  StreamSubscription<void>? _subscription;

  AuthStatus _status = AuthStatus.loading;
  AuthStatus get status => _status;

  AccountAccess _access = AccountAccess.unknown;

  /// What the signed-in account may reach. Meaningless unless [status] is
  /// [AuthStatus.authenticated].
  AccountAccess get access => _access;

  bool _isOffline = false;

  /// True when the last read of the account did not reach the server. The app
  /// carries on with what it last knew and shows a banner.
  bool get isOffline => _isOffline;

  /// Guards against a slow resolve for a previous session landing after a
  /// newer one has already settled.
  int _generation = 0;

  /// Re-reads the account. Called after registration and after the trial is
  /// taken, so the router moves on without waiting for a relaunch.
  Future<void> refresh() => _resolve(++_generation);

  bool _suspended = false;

  /// Stops routing decisions while a flow writes the account itself.
  ///
  /// Registration is two writes: the credential, then the profile. Between
  /// them `GET /v1/me` answers 404, and the gate would send the flow back to
  /// step two while step three is still running. Sign-in holds it for the
  /// same reason — the offer to remember the credentials has to be made before
  /// the router leaves the screen. The screen doing the work says when it is
  /// finished, and [resume] re-reads once.
  void suspend() {
    _suspended = true;
  }

  Future<void> resume() async {
    _suspended = false;
    await refresh();
  }

  void _onSessionChanged() {
    if (_suspended) {
      return;
    }
    final int generation = ++_generation;

    if (!(_signal?.hasSession ?? false)) {
      _access = AccountAccess.unknown;
      _isOffline = false;
      _set(AuthStatus.unauthenticated);
      return;
    }

    if (_status != AuthStatus.authenticated) {
      _set(AuthStatus.loading);
    }
    unawaited(_resolve(generation));
  }

  Future<void> _resolve(int generation) async {
    final SessionResolver? resolver = _resolver;
    if (_suspended || resolver == null) {
      return;
    }
    if (!(_signal?.hasSession ?? false)) {
      _access = AccountAccess.unknown;
      _isOffline = false;
      _set(AuthStatus.unauthenticated);
      return;
    }

    try {
      final AccountAccess resolved = await resolver.resolveSession();
      if (generation != _generation) {
        return;
      }
      _access = resolved;
      _isOffline = false;
      _set(AuthStatus.authenticated);
    } on ApiException catch (error) {
      if (generation == _generation) {
        _onResolveFailed(error);
      }
    }
  }

  /// A revoked session has already been signed out by the API client, so the
  /// signal will report it and there is nothing to do here. Anything else is
  /// treated as offline: the app keeps what it last knew, and a cold launch
  /// with nothing known opens the account rather than stranding it on the
  /// paywall because the network happens to be down.
  void _onResolveFailed(ApiException error) {
    if (error.kind == ApiFailureKind.unauthorized) {
      return;
    }
    if (error.isProfileMissing) {
      _access = AccountAccess.profileMissing;
      _isOffline = false;
      _set(AuthStatus.authenticated);
      return;
    }
    _isOffline = true;
    if (_access == AccountAccess.unknown) {
      _access = AccountAccess.open;
    }
    _set(AuthStatus.authenticated);
  }

  bool _leftLoading = false;
  final Stopwatch _sinceLaunch = Stopwatch()..start();

  void _set(AuthStatus status) {
    _status = status;
    if (_leftLoading || status == AuthStatus.loading) {
      notifyListeners();
      return;
    }
    _leftLoading = true;
    unawaited(_notifyAfterHold());
  }

  Future<void> _notifyAfterHold() async {
    final Duration remaining = minimumHold - _sinceLaunch.elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

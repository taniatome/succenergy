import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/auth/account_access.dart';
import '../core/auth/auth_state.dart';
import 'routes.dart';

/// The app's launch state machine, and the only place session or subscription
/// is checked.
///
/// This runs as the router's redirect against [AuthState], which the router
/// also watches, so every screen added later inherits the protection without
/// asking for it. No screen checks whether anyone is signed in.
///
///     loading            -> Splash
///     unauthenticated    -> Welcome, or any of the pre-account screens
///     authenticated
///       profile missing  -> Registration, resumed at step two
///       locked           -> Trial gate
///       open             -> wherever it was going
class LaunchGate {
  const LaunchGate._();

  /// Reachable with no session at all.
  ///
  /// The splash is deliberately absent: it is where the app waits, not
  /// somewhere it may stay. Once the session has resolved, every state has
  /// somewhere better to be.
  static const Set<String> _public = <String>{
    Routes.welcome,
    Routes.language,
    Routes.quiz,
    Routes.login,
    Routes.register,
    Routes.registerAbout,
    Routes.registerConsent,
    Routes.forgotPassword,
  };

  /// The registration subtree, which is where an account with no profile has
  /// to finish before anything else opens.
  static const Set<String> _registration = <String>{
    Routes.registerAbout,
    Routes.registerConsent,
  };

  /// Reachable while signed in but before the trial is taken.
  ///
  /// Password reset is here because Settings routes to it for a signed-in
  /// account that wants to change its password.
  static const Set<String> _locked = <String>{
    Routes.trial,
    Routes.trialWelcome,
    Routes.forgotPassword,
  };

  /// Pre-account screens, which a signed-in account is moved off.
  ///
  /// The trial screen is deliberately absent: it navigates onward itself once
  /// the trial is taken, and redirecting it out from under that would race the
  /// welcome moment it hands off to.
  static const Set<String> _preAccount = <String>{
    Routes.splash,
    Routes.welcome,
    Routes.language,
    Routes.quiz,
    Routes.login,
    Routes.register,
    Routes.registerAbout,
    Routes.registerConsent,
  };

  /// The path to redirect to, or null to let the route through.
  static String? redirect(BuildContext context, GoRouterState state) {
    final AuthState auth = context.read<AuthState>();
    final String path = state.uri.path;

    switch (auth.status) {
      case AuthStatus.loading:
        return path == Routes.splash ? null : Routes.splash;

      case AuthStatus.unauthenticated:
        return _public.contains(path) ? null : Routes.welcome;

      case AuthStatus.authenticated:
        return _forAccess(auth.access, path);
    }
  }

  static String? _forAccess(AccountAccess access, String path) {
    switch (access) {
      case AccountAccess.profileMissing:
        return _registration.contains(path) ? null : Routes.registerAbout;

      case AccountAccess.locked:
        return _locked.contains(path) ? null : Routes.trial;

      case AccountAccess.open:
        return _preAccount.contains(path) ? Routes.dashboard : null;

      // Only reachable between the stream reporting a user and the account
      // being read, which the loading case above already holds on.
      case AccountAccess.unknown:
        return Routes.splash;
    }
  }
}

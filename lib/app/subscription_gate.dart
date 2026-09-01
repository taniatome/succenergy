import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth_repository.dart';
import 'routes.dart';

/// The single subscription check in the app.
///
/// The app is free to download and nothing inside it opens until the trial is
/// taken. This runs as the router's redirect, so a signed-in account with no
/// trial lands on the paywall wherever it tries to go — no screen asks about
/// subscriptions, so no screen can forget to.
class SubscriptionGate {
  const SubscriptionGate._();

  /// The paths an account may reach before the trial is taken.
  ///
  /// Onboarding is not among them: it runs after the trial is accepted, by
  /// which point the flag is already set.
  static const Set<String> openPaths = <String>{
    Routes.splash,
    Routes.welcome,
    Routes.language,
    Routes.quiz,
    Routes.login,
    Routes.register,
    Routes.forgotPassword,
    Routes.trial,
    Routes.trialWelcome,
  };

  /// Returns the path to redirect to, or null to let the route through.
  static String? redirect(BuildContext context, GoRouterState state) {
    final AuthRepository auth = context.read<AuthRepository>();
    if (!auth.isLoggedIn || auth.hasActiveSubscription) {
      return null;
    }
    return openPaths.contains(state.uri.path) ? null : Routes.trial;
  }
}

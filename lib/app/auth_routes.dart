import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/motion/page_transitions.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/registration/registration_draft.dart';
import '../features/auth/registration/step1_account_screen.dart';
import '../features/auth/registration/step2_about_you_screen.dart';
import '../features/auth/registration/step3_consent_screen.dart';
import 'route_builders.dart';
import 'routes.dart';

/// Every route that exists before an account does.
///
/// Split out of the main table because registration is a subtree with state of
/// its own rather than one more entry, and the file that lists every
/// destination in the app should stay a list.
class AuthRoutes {
  const AuthRoutes._();

  static List<RouteBase> all() => <RouteBase>[
    AppRoute.fade(Routes.login, (_) => const LoginScreen()),
    _registration(),
    _forgotPassword(),
  ];

  /// The three registration steps, sharing one [RegistrationDraft].
  ///
  /// Three full screens rather than pages inside a PageView, so the system
  /// back gesture steps back through them and each arrives on the app's own
  /// fade-through. The draft is created once above all three and holds what
  /// has been entered so far, which is what lets step three submit everything
  /// in one call rather than writing a partial account at each step.
  static ShellRoute _registration() {
    return ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ChangeNotifierProvider<RegistrationDraft>(
          create: (BuildContext context) => RegistrationDraft(),
          child: child,
        );
      },
      routes: <RouteBase>[
        AppRoute.fade(Routes.register, (_) => const Step1AccountScreen()),
        AppRoute.fade(Routes.registerAbout, (_) => const Step2AboutYouScreen()),
        AppRoute.fade(
          Routes.registerConsent,
          (_) => const Step3ConsentScreen(),
        ),
      ],
    );
  }

  /// Declared longhand because it reads a route extra: an address already
  /// typed on the sign-in screen is carried over, and an email address has no
  /// business in a URL.
  static GoRoute _forgotPassword() {
    return GoRoute(
      path: Routes.forgotPassword,
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              AppPageTransitions.fadeThrough(
                child: ForgotPasswordScreen(
                  initialEmail:
                      state.extra is String ? state.extra! as String : '',
                ),
                state: state,
              ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/auth/auth_state.dart';
import '../core/motion/page_transitions.dart';
import '../data/repositories/coach_repository.dart';
import '../data/repositories/exercises_repository.dart';
import '../data/repositories/goals_repository.dart';
import '../data/repositories/notifications_repository.dart';
import '../data/repositories/subscription_repository.dart';
import '../data/repositories/user_repository.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/admin/admin_gate_screen.dart';
import '../features/ai_coach/ai_coach_screen.dart';
import '../features/ai_coach/coach_provider.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/coaching_history/coaching_history_screen.dart';
import '../features/coaching_history/session_detail_screen.dart';
import '../features/dashboard/dashboard_provider.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/exercises/exercise_session_screen.dart';
import '../features/exercises/exercises_provider.dart';
import '../features/exercises/exercises_screen.dart';
import '../features/goals/goal_detail_screen.dart';
import '../features/goals/goals_provider.dart';
import '../features/goals/goals_screen.dart';
import '../features/help_about/help_about_screen.dart';
import '../features/language_selection/language_selection_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/onboarding/onboarding_provider.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/purpose/purpose_provider.dart';
import '../features/purpose/purpose_screen.dart';
import '../features/quiz/quiz_provider.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/recharge/recharge_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/subscription/subscription_screen.dart';
import '../features/trial/trial_screen.dart';
import '../features/trial/trial_welcome_screen.dart';
import '../features/welcome/welcome_screen.dart';
import 'launch_gate.dart';
import 'routes.dart';
import 'shell_frame.dart';

/// The app's complete route table.
///
/// Every destination is declared here. Screens navigate with the constants in
/// `routes.dart` and never with literal paths. Feature providers are created
/// at the route that owns them, so a screen never has to be told where its
/// state came from.
class AppRouter {
  const AppRouter._();

  static GoRouter build(AuthState auth) {
    return GoRouter(
      initialLocation: Routes.splash,
      // The router watches the session and re-runs the gate on every change,
      // so a sign-in, a sign-out or a revoked token moves the app on its own.
      refreshListenable: auth,
      redirect: LaunchGate.redirect,
      routes: <RouteBase>[
        _page(Routes.splash, (_) => const SplashScreen()),
        _page(Routes.welcome, (_) => const WelcomeScreen()),
        _page(Routes.language, (_) => const LanguageSelectionScreen()),
        _page(Routes.quiz, _quiz),
        _page(Routes.login, (_) => const LoginScreen()),
        _page(Routes.register, (_) => const RegisterScreen()),
        _page(Routes.forgotPassword, (_) => const ForgotPasswordScreen()),
        _page(Routes.trial, (_) => const TrialScreen()),
        _page(Routes.trialWelcome, (_) => const TrialWelcomeScreen()),
        _page(Routes.onboarding, _onboarding),
        _shell(),
        _page(Routes.purpose, _purpose, rise: true),
        _page(Routes.profile, (_) => const ProfileScreen(), rise: true),
        _page(
          Routes.notifications,
          (_) => const NotificationsScreen(),
          rise: true,
        ),
        _page(
          Routes.subscription,
          (_) => const SubscriptionScreen(),
          rise: true,
        ),
        _page(Routes.settings, (_) => const SettingsScreen(), rise: true),
        _page(Routes.recharge, (_) => const RechargeScreen(), rise: true),
        _page(Routes.help, (_) => const HelpAboutScreen(), rise: true),
        _page(Routes.adminGate, (_) => const AdminGateScreen(), rise: true),
        _page(
          Routes.adminConsole,
          (_) => const AdminDashboardScreen(),
          rise: true,
        ),
        GoRoute(
          path: Routes.coachingHistory,
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  AppPageTransitions.riseOver(
                    child: const CoachingHistoryScreen(),
                    state: state,
                  ),
          routes: <RouteBase>[
            GoRoute(
              path: Routes.sessionDetailSegment,
              pageBuilder:
                  (BuildContext context, GoRouterState state) =>
                      AppPageTransitions.riseOver(
                        child: SessionDetailScreen(
                          sessionId: state.pathParameters['sessionId'] ?? '',
                        ),
                        state: state,
                      ),
            ),
          ],
        ),
      ],
    );
  }

  static GoRoute _page(
    String path,
    Widget Function(BuildContext context) builder, {
    bool rise = false,
    List<RouteBase> routes = const <RouteBase>[],
  }) {
    return GoRoute(
      path: path,
      routes: routes,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final Widget child = builder(context);
        return rise
            ? AppPageTransitions.riseOver(child: child, state: state)
            : AppPageTransitions.fadeThrough(child: child, state: state);
      },
    );
  }

  static Widget _quiz(BuildContext context) {
    return ChangeNotifierProvider<QuizProvider>(
      create:
          (BuildContext context) =>
              QuizProvider(context.read<UserRepository>()),
      child: const QuizScreen(),
    );
  }

  static Widget _onboarding(BuildContext context) {
    return ChangeNotifierProvider<OnboardingProvider>(
      create:
          (BuildContext context) =>
              OnboardingProvider(context.read<UserRepository>()),
      child: const OnboardingScreen(),
    );
  }

  static Widget _purpose(BuildContext context) {
    return ChangeNotifierProvider<PurposeProvider>(
      create:
          (BuildContext context) =>
              PurposeProvider(context.read<UserRepository>()),
      child: const PurposeScreen(),
    );
  }

  static Widget _dashboard(BuildContext context) {
    return ChangeNotifierProvider<DashboardProvider>(
      create:
          (BuildContext context) => DashboardProvider(
            users: context.read<UserRepository>(),
            goals: context.read<GoalsRepository>(),
            exercises: context.read<ExercisesRepository>(),
            notifications: context.read<NotificationsRepository>(),
          ),
      child: const DashboardScreen(),
    );
  }

  static Widget _coach(BuildContext context) {
    return ChangeNotifierProvider<CoachProvider>(
      create:
          (BuildContext context) =>
              CoachProvider(context.read<CoachRepository>()),
      child: const AiCoachScreen(),
    );
  }

  static StatefulShellRoute _shell() {
    return StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell shell,
      ) {
        return ShellFrame(shell: shell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[_page(Routes.dashboard, _dashboard)],
        ),
        StatefulShellBranch(routes: <RouteBase>[_goalsBranch()]),
        StatefulShellBranch(routes: <RouteBase>[_page(Routes.coach, _coach)]),
        StatefulShellBranch(routes: <RouteBase>[_exercisesBranch()]),
        StatefulShellBranch(
          routes: <RouteBase>[
            _page(Routes.progress, (_) => const ProgressScreen()),
          ],
        ),
      ],
    );
  }

  /// Goals and Goal Detail share one [GoalsProvider], so checking an action
  /// off on the detail screen is reflected in the list behind it.
  static ShellRoute _goalsBranch() {
    return ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ChangeNotifierProvider<GoalsProvider>(
          create:
              (BuildContext context) =>
                  GoalsProvider(context.read<GoalsRepository>()),
          child: child,
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: Routes.goals,
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  AppPageTransitions.fadeThrough(
                    child: const GoalsScreen(),
                    state: state,
                  ),
        ),
        GoRoute(
          path: '${Routes.goals}/${Routes.goalDetailSegment}',
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  AppPageTransitions.riseOver(
                    child: GoalDetailScreen(
                      goalId: state.pathParameters['goalId'] ?? '',
                    ),
                    state: state,
                  ),
        ),
      ],
    );
  }

  static GoRoute _exercisesBranch() {
    return GoRoute(
      path: Routes.exercises,
      pageBuilder:
          (BuildContext context, GoRouterState state) =>
              AppPageTransitions.fadeThrough(
                child: ChangeNotifierProvider<ExercisesProvider>(
                  create:
                      (BuildContext context) => ExercisesProvider(
                        context.read<ExercisesRepository>(),
                        context.read<SubscriptionRepository>(),
                      ),
                  child: const ExercisesScreen(),
                ),
                state: state,
              ),
      routes: <RouteBase>[
        GoRoute(
          path: Routes.exerciseSessionSegment,
          pageBuilder:
              (BuildContext context, GoRouterState state) =>
                  AppPageTransitions.riseOver(
                    child: ExerciseSessionScreen(
                      exerciseId: state.pathParameters['exerciseId'] ?? '',
                    ),
                    state: state,
                  ),
        ),
      ],
    );
  }
}

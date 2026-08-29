/// Every route path in the app.
///
/// Widgets navigate with these constants; no raw path strings appear anywhere
/// else in the project.
class Routes {
  const Routes._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String language = '/language';

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';

  static const String dashboard = '/dashboard';
  static const String goals = '/goals';
  static const String coach = '/coach';
  static const String exercises = '/exercises';
  static const String progress = '/progress';

  /// Sub-route segment for a single goal, relative to [goals].
  static const String goalDetailSegment = ':goalId';

  /// Sub-route segment for a guided session, relative to [exercises].
  static const String exerciseSessionSegment = ':exerciseId/session';

  static const String purpose = '/purpose';
  static const String profile = '/profile';
  static const String coachingHistory = '/coaching-history';

  /// Sub-route segment for one past session, relative to [coachingHistory].
  static const String sessionDetailSegment = ':sessionId';

  static const String notifications = '/notifications';
  static const String subscription = '/subscription';
  static const String settings = '/settings';
  static const String help = '/help';
  static const String adminGate = '/admin';
  static const String adminConsole = '/admin/console';

  /// Absolute path to one goal.
  static String goalDetail(String goalId) => '$goals/$goalId';

  /// Absolute path to a guided exercise session.
  static String exerciseSession(String exerciseId) =>
      '$exercises/$exerciseId/session';

  /// Absolute path to one past coaching session.
  static String sessionDetail(String sessionId) =>
      '$coachingHistory/$sessionId';
}

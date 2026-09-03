/// Every route path in the app.
///
/// Widgets navigate with these constants; no raw path strings appear anywhere
/// else in the project.
class Routes {
  const Routes._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String language = '/language';

  /// The three questions asked before an account exists.
  static const String quiz = '/quiz';

  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  /// Registration, step one of three: email and password.
  static const String register = '/register';

  /// Sub-route segment for step two, relative to [register].
  static const String registerAboutSegment = 'about';

  /// Sub-route segment for step three, relative to [register].
  static const String registerConsentSegment = 'consent';

  /// Registration, step two of three: name, date of birth, country, activity.
  static const String registerAbout = '$register/$registerAboutSegment';

  /// Registration, step three of three: consent and the summary.
  static const String registerConsent = '$register/$registerConsentSegment';
  static const String onboarding = '/onboarding';

  /// The paywall, between registration and onboarding.
  static const String trial = '/trial';

  /// The one-time welcome moment shown once the trial is taken.
  static const String trialWelcome = '/trial/welcome';

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
  static const String recharge = '/recharge';
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

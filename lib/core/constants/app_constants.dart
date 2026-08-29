/// Non-visual constants shared across features.
class AppConstants {
  const AppConstants._();

  /// Number of questions in the onboarding assessment.
  static const int onboardingQuestionCount = 7;

  /// Principles in one full Succenergy cycle.
  static const int principleCount = 7;

  /// Days of activity rendered by the progress streak view.
  static const int activityWindowDays = 21;

  /// Minimum password length accepted by the mock auth layer.
  static const int minPasswordLength = 8;

  /// Longest free-text answer accepted in onboarding and exercises.
  static const int maxFreeTextLength = 400;

  /// Widest layout the content column is allowed to grow to on tablets.
  static const double maxContentWidth = 560;

  /// Narrowest layout the app is designed to hold without overflow.
  static const double minSupportedWidth = 360;

  /// Supported locale codes, in the order shown on the language screen.
  static const List<String> supportedLocales = <String>['en', 'pt'];

  /// Access code accepted by the mock admin gate.
  static const String adminAccessCode = 'SUCC-ADMIN';
}

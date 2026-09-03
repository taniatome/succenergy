/// Non-visual constants shared across features.
class AppConstants {
  const AppConstants._();

  /// Questions asked before registration, in the entry quiz.
  static const int quizQuestionCount = 3;

  /// Questions asked after registration, in the onboarding assessment.
  static const int onboardingQuestionCount = 4;

  /// Principles in one full Succenergy cycle.
  static const int principleCount = 7;

  /// Days of activity rendered by the progress streak view.
  static const int activityWindowDays = 21;

  /// Minimum password length accepted by the mock auth layer.
  static const int minPasswordLength = 8;

  /// Youngest age allowed to register.
  static const int minimumAgeYears = 16;

  /// Oldest date of birth offered by the picker, as years before today.
  static const int maxAgeYears = 100;

  /// Longest free-text answer accepted in onboarding and exercises.
  static const int maxFreeTextLength = 400;

  /// Widest layout the content column is allowed to grow to on tablets.
  static const double maxContentWidth = 560;

  /// Narrowest layout the app is designed to hold without overflow.
  static const double minSupportedWidth = 360;

  // --- Backend -------------------------------------------------------------

  /// Root of the Succenergy API, without a trailing slash.
  ///
  /// The default is the Android emulator's route to the host machine. A
  /// physical device needs the machine's LAN address instead, passed at build
  /// time: `--dart-define=API_URL=http://192.168.1.20:8787`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8787',
  );

  /// Version prefix every endpoint sits behind.
  static const String apiVersion = 'v1';

  /// How long a single API call is given before it is treated as offline.
  static const Duration apiTimeout = Duration(seconds: 20);

  /// Supported locale codes, in the order shown on the language screen.
  static const List<String> supportedLocales = <String>['en', 'pt'];

  /// Access code accepted by the mock admin gate.
  static const String adminAccessCode = 'SUCC-ADMIN';

  // --- Pricing -------------------------------------------------------------
  //
  // Prices are figures rather than written copy, so they live here once and
  // are read by the trial screen, the plan cards and the small print alike.

  /// Length of the introductory trial.
  static const int trialDays = 7;

  /// What the trial costs.
  static const String trialPrice = r'$1';

  /// Monthly rate for students and minorities.
  static const String studentMonthlyPrice = r'$11';

  /// Monthly rate for everyone else.
  static const String professionalMonthlyPrice = r'$33';

  // --- External destinations ----------------------------------------------
  //
  // Every URL below is a PLACEHOLDER standing in until the client supplies
  // the real destination. Nothing here has been confirmed.

  /// Placeholder: the Succenergy content library.
  static const String placeholderLibraryUrl = 'https://succenergy.com/library';

  /// Placeholder: the booking page for Tânia Tomé.
  static const String placeholderBookingUrl = 'https://succenergy.com/booking';

  /// Placeholder: Instagram.
  static const String placeholderInstagramUrl =
      'https://instagram.com/succenergy';

  /// Placeholder: Facebook.
  static const String placeholderFacebookUrl =
      'https://facebook.com/succenergy';

  /// Placeholder: LinkedIn.
  static const String placeholderLinkedInUrl =
      'https://linkedin.com/company/succenergy';

  /// Placeholder: YouTube.
  static const String placeholderYouTubeUrl = 'https://youtube.com/@succenergy';

  /// Placeholder: the terms and conditions page.
  static const String placeholderTermsUrl = 'https://succenergy.com/terms';

  /// Placeholder: the privacy policy page.
  static const String placeholderPrivacyUrl = 'https://succenergy.com/privacy';
}

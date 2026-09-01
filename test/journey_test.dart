import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:succenergy_ai_coach/app/app.dart';
import 'package:succenergy_ai_coach/core/localization/locale_provider.dart';
import 'package:succenergy_ai_coach/app/routes.dart';
import 'package:succenergy_ai_coach/core/widgets/icons/app_icon.dart';
import 'package:succenergy_ai_coach/core/widgets/inputs/scale_input.dart';
import 'package:succenergy_ai_coach/features/trial/trial_screen.dart';
import 'package:succenergy_ai_coach/data/mock/repositories/mock_auth_repository.dart';
import 'package:succenergy_ai_coach/data/mock/repositories/mock_coach_repository.dart';
import 'package:succenergy_ai_coach/data/mock/repositories/mock_exercises_repository.dart';
import 'package:succenergy_ai_coach/data/mock/repositories/mock_goals_repository.dart';
import 'package:succenergy_ai_coach/data/mock/repositories/mock_notifications_repository.dart';
import 'package:succenergy_ai_coach/data/mock/repositories/mock_progress_repository.dart';
import 'package:succenergy_ai_coach/data/mock/repositories/mock_subscription_repository.dart';
import 'package:succenergy_ai_coach/data/mock/repositories/mock_user_repository.dart';
import 'package:succenergy_ai_coach/data/repositories/auth_repository.dart';
import 'package:succenergy_ai_coach/data/repositories/coach_repository.dart';
import 'package:succenergy_ai_coach/data/repositories/exercises_repository.dart';
import 'package:succenergy_ai_coach/data/repositories/goals_repository.dart';
import 'package:succenergy_ai_coach/data/repositories/notifications_repository.dart';
import 'package:succenergy_ai_coach/data/repositories/progress_repository.dart';
import 'package:succenergy_ai_coach/data/repositories/subscription_repository.dart';
import 'package:succenergy_ai_coach/data/repositories/user_repository.dart';
import 'package:go_router/go_router.dart';

/// Walks the journey the client is asked to click through, and checks the
/// layout holds at the narrowest supported width.
void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting();
    final FontLoader icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  Future<void> launch(WidgetTester tester, {Size size = const Size(390, 900)}) {
    // Reduced motion keeps the continuous ring pulse and ambient drift from
    // preventing the tree from ever settling.
    tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    return tester.pumpWidget(
      MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<LocaleProvider>(
            create: (_) => LocaleProvider(),
          ),
          Provider<AuthRepository>(create: (_) => MockAuthRepository()),
          Provider<UserRepository>(create: (_) => MockUserRepository()),
          Provider<GoalsRepository>(create: (_) => MockGoalsRepository()),
          Provider<ExercisesRepository>(
            create: (_) => MockExercisesRepository(),
          ),
          Provider<CoachRepository>(create: (_) => MockCoachRepository()),
          Provider<ProgressRepository>(create: (_) => MockProgressRepository()),
          Provider<NotificationsRepository>(
            create: (_) => MockNotificationsRepository(),
          ),
          Provider<SubscriptionRepository>(
            create: (_) => MockSubscriptionRepository(),
          ),
        ],
        child: const SuccenergyApp(),
      ),
    );
  }

  // Repository latency and the splash hand-off are plain timers rather than
  // animations, so time has to be advanced explicitly before settling.
  Future<void> settle(WidgetTester tester) async {
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.pumpAndSettle(const Duration(milliseconds: 120));
  }

  // Some labels are rendered as Text.rich so a word can carry the gold
  // emphasis, so every lookup has to consider rich text too.
  Finder label(String text) => find.text(text, findRichText: true);

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(label(text).first);
    await settle(tester);
  }

  // The registration form is longer than a phone viewport, so anything below
  // the fold has to be scrolled to before it can be tapped.
  Future<void> tapVisible(WidgetTester tester, String text) async {
    final Finder target = label(text).first;
    await tester.ensureVisible(target);
    await settle(tester);
    await tester.tap(target);
    await settle(tester);
  }

  // The three pre-registration questions: free text, chips, free text.
  Future<void> completeQuiz(WidgetTester tester) async {
    expect(label('What do you want to achieve?'), findsWidgets);
    await tester.enterText(find.byType(TextField).first, 'A real answer.');
    await settle(tester);
    await tapText(tester, 'Continue');

    await tapText(tester, 'Career and leadership');
    await tapText(tester, 'Continue');

    await tester.enterText(
      find.byType(TextField).first,
      'What gets in the way.',
    );
    await settle(tester);
    await tapText(tester, 'Create your account');
  }

  // The registration form, including the two sheets and both checkboxes.
  //
  // [student] picks the Student | Minorities activity, which is what decides
  // the monthly rate shown on the trial screen.
  Future<void> completeRegistration(
    WidgetTester tester, {
    bool student = false,
  }) async {
    expect(label('Begin the first cycle'), findsWidgets);
    await tester.enterText(find.byType(TextField).at(0), 'Marisa Chissano');
    await tester.enterText(
      find.byType(TextField).at(1),
      'marisa@lumeconsult.co.mz',
    );
    await tester.enterText(find.byType(TextField).at(2), 'succenergy2026');
    await tester.enterText(find.byType(TextField).at(3), 'succenergy2026');
    await settle(tester);

    // Date of birth opens the wheel sheet, which starts at the youngest date
    // that can register.
    await tapVisible(tester, 'Select your date of birth');
    await tapVisible(tester, 'Done');

    // Country is searched rather than scrolled: the list holds every country.
    await tapVisible(tester, 'Select your country');
    await tester.enterText(find.byType(TextField).last, 'Mozam');
    await settle(tester);
    await tapVisible(tester, 'Mozambique');

    if (student) {
      await tapVisible(tester, 'Student | Minorities');
    }

    // Both boxes have to be ticked before the form will submit.
    await tapVisible(tester, 'Create account');
    expect(label('Tick both boxes before you continue.'), findsWidgets);

    await tapVisible(tester, 'I accept the terms and conditions.');
    await tapText(
      tester,
      'I confirm that all the information I have given is true.',
    );
    await tapVisible(tester, 'Create account');
  }

  testWidgets('splash through quiz, trial and onboarding into the dashboard', (
    WidgetTester tester,
  ) async {
    await launch(tester);
    await settle(tester);

    expect(label('Start your Journey within.'), findsWidgets);
    await tapText(tester, 'Start your Journey within.');

    expect(label('Choose your language'), findsWidgets);
    await tapText(tester, 'Continue');

    await completeQuiz(tester);
    await completeRegistration(tester);

    // The paywall, showing the Professional rate the form defaults to.
    expect(label('Seven days, one dollar'), findsWidgets);
    expect(find.textContaining(r'$33'), findsWidgets);
    await tapText(tester, 'Start 7-day trial');

    // The welcome moment, then the four remaining questions.
    expect(
      label(
        'Congratulations, you are on the path to becoming a Succenergy '
        'winner.',
      ),
      findsWidgets,
    );
    await tapText(tester, 'Continue');

    expect(label('What are your priorities?'), findsWidgets);
    for (int step = 0; step < 4; step++) {
      if (find.byType(TextField).evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextField).first, 'A real answer.');
        await settle(tester);
      } else if (label('Deep focus').evaluate().isNotEmpty) {
        await tapText(tester, 'Deep focus');
      } else if (find.byType(ScaleInput).evaluate().isNotEmpty) {
        // The motivation scale has to be placed before the step will
        // advance, the same as every other question.
        await tester.tapAt(tester.getCenter(find.byType(ScaleInput).first));
        await settle(tester);
      }
      await tapText(tester, 'Continue');
    }

    expect(label('This is what your coach heard'), findsWidgets);
    await tapText(tester, 'Enter the app');

    expect(find.textContaining('Marisa'), findsWidgets);
    expect(find.text('Praxis'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the quiz answers reach the closing summary', (
    WidgetTester tester,
  ) async {
    await launch(tester);
    await settle(tester);
    await tapText(tester, 'Start your Journey within.');
    await tapText(tester, 'Continue');
    await completeQuiz(tester);
    await completeRegistration(tester, student: true);

    // The reduced rate, and only that rate.
    expect(find.textContaining(r'$11'), findsWidgets);
    expect(find.textContaining(r'$33'), findsNothing);
    await tapText(tester, 'Start 7-day trial');
    await tapText(tester, 'Continue');

    for (int step = 0; step < 4; step++) {
      if (find.byType(TextField).evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextField).first, 'A later answer.');
        await settle(tester);
      } else if (label('Deep focus').evaluate().isNotEmpty) {
        await tapText(tester, 'Deep focus');
      } else if (find.byType(ScaleInput).evaluate().isNotEmpty) {
        await tester.tapAt(tester.getCenter(find.byType(ScaleInput).first));
        await settle(tester);
      }
      await tapText(tester, 'Continue');
    }

    // All three quiz answers are read back on the summary, beside the four
    // just given: the split assessment is still one set of answers.
    expect(label('This is what your coach heard'), findsWidgets);
    expect(find.textContaining('A real answer.'), findsWidgets);
    expect(find.textContaining('What gets in the way.'), findsWidgets);
    expect(label('Career and leadership'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the dashboard is closed until the trial is taken', (
    WidgetTester tester,
  ) async {
    await launch(tester);
    await settle(tester);
    await tapText(tester, 'Start your Journey within.');
    await tapText(tester, 'Continue');
    await completeQuiz(tester);
    await completeRegistration(tester);

    expect(find.byType(TrialScreen), findsOneWidget);

    // Registered, signed in, no trial: the router sends every gated
    // destination back to the paywall.
    final GoRouter router = GoRouter.of(
      tester.element(find.byType(TrialScreen)),
    );
    for (final String path in <String>[
      Routes.dashboard,
      Routes.coach,
      Routes.progress,
    ]) {
      router.go(path);
      await settle(tester);
      expect(find.byType(TrialScreen), findsOneWidget, reason: 'went to $path');
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('every main destination opens from the dashboard', (
    WidgetTester tester,
  ) async {
    await launch(tester);
    await settle(tester);
    await tapText(tester, 'I already have an account');
    await tester.enterText(find.byType(TextField).at(0), 'marisa@lume.co.mz');
    await tester.enterText(find.byType(TextField).at(1), 'succenergy2026');
    await settle(tester);
    await tapText(tester, 'Log in');

    expect(label('Your one action'), findsWidgets);

    for (final String tab in <String>[
      'GOALS',
      'COACH',
      'PRACTICE',
      'PROGRESS',
      'HOME',
    ]) {
      await tapText(tester, tab);
      expect(tester.takeException(), isNull, reason: 'opening $tab');
    }

    await tapText(tester, 'GOALS');
    await tapText(tester, 'Lead the Q4 brand relaunch end to end');
    // The section eyebrow renders its label in letterspaced caps.
    expect(label('WHY IT MATTERS'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the kebab menu opens Settings and the Succenergy links', (
    WidgetTester tester,
  ) async {
    await launch(tester);
    await settle(tester);
    await tapText(tester, 'I already have an account');
    await tester.enterText(find.byType(TextField).at(0), 'marisa@lume.co.mz');
    await tester.enterText(find.byType(TextField).at(1), 'succenergy2026');
    await settle(tester);
    await tapText(tester, 'Log in');

    // Settings is reached only through the header's kebab menu.
    await tester.tap(
      find.byWidgetPredicate(
        (Widget w) => w is AppIcon && w.mark == AppIconMark.kebab,
      ),
    );
    await settle(tester);

    expect(label('Settings'), findsWidgets);
    for (final String item in <String>[
      'Recharge with Succenergy',
      'Succenergy Library',
      'Book T\u00e2nia Tom\u00e9',
      'Connect with Us',
    ]) {
      expect(label(item), findsWidgets, reason: 'missing $item');
    }

    // Connect with Us opens in place rather than pushing a screen.
    expect(label('Instagram'), findsNothing);
    await tapVisible(tester, 'Connect with Us');
    expect(label('Instagram'), findsWidgets);
    expect(label('YouTube'), findsWidgets);

    // The in-app item still routes.
    await tapVisible(tester, 'Recharge with Succenergy');
    expect(label('Coming soon'.toUpperCase()), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('layout holds at the narrowest supported width', (
    WidgetTester tester,
  ) async {
    await launch(tester, size: const Size(360, 720));
    await settle(tester);
    expect(tester.takeException(), isNull);

    await tapText(tester, 'I already have an account');
    await tester.enterText(find.byType(TextField).at(0), 'marisa@lume.co.mz');
    await tester.enterText(find.byType(TextField).at(1), 'succenergy2026');
    await settle(tester);
    await tapText(tester, 'Log in');

    for (final String tab in <String>[
      'GOALS',
      'COACH',
      'PRACTICE',
      'PROGRESS',
    ]) {
      await tapText(tester, tab);
      expect(tester.takeException(), isNull, reason: '$tab at 360px');
    }
  });
}

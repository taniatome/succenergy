import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:succenergy_ai_coach/app/app.dart';
import 'package:succenergy_ai_coach/core/localization/locale_provider.dart';
import 'package:succenergy_ai_coach/core/widgets/inputs/scale_input.dart';
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

  testWidgets('splash through onboarding into the dashboard', (
    WidgetTester tester,
  ) async {
    await launch(tester);
    await settle(tester);

    expect(label('Start your Journey within.'), findsWidgets);
    await tapText(tester, 'Start your Journey within.');

    expect(label('Choose your language'), findsWidgets);
    await tapText(tester, 'Continue');

    expect(label('Begin the first cycle'), findsWidgets);
    final List<Finder> fields = <Finder>[
      find.byType(TextField).at(0),
      find.byType(TextField).at(1),
      find.byType(TextField).at(2),
      find.byType(TextField).at(3),
    ];
    await tester.enterText(fields[0], 'Marisa Chissano');
    await tester.enterText(fields[1], 'marisa@lumeconsult.co.mz');
    await tester.enterText(fields[2], 'succenergy2026');
    await tester.enterText(fields[3], 'succenergy2026');
    await settle(tester);
    await tapText(tester, 'Create account');

    // Seven questions: free text, chips and one scale.
    expect(label('What do you want to achieve?'), findsWidgets);
    for (int step = 0; step < 7; step++) {
      if (find.byType(TextField).evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextField).first, 'A real answer.');
        await settle(tester);
      } else if (label('Career and leadership').evaluate().isNotEmpty) {
        await tapText(tester, 'Career and leadership');
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

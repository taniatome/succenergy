import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:succenergy_ai_coach/app/app.dart';
import 'package:succenergy_ai_coach/core/localization/locale_provider.dart';
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

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('launches into the splash sequence and reaches Welcome', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
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

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(find.text('Start your Journey within.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

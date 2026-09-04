import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:succenergy_ai_coach/app/app.dart';
import 'package:succenergy_ai_coach/core/auth/auth_state.dart';
import 'package:succenergy_ai_coach/core/auth/biometric_service.dart';
import 'package:succenergy_ai_coach/core/auth/secure_session_store.dart';
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

/// The app under the mock layer, wired the way `main.dart` wires the real one.
///
/// The mock auth repository is both the resolver and the session signal, which
/// is what lets the launch state machine be exercised with no Firebase project
/// behind it: signing in through the mock moves the router exactly as a real
/// sign-in would.
///
/// No minimum splash hold here. On a device the first routing decision waits
/// for the brand sequence; in a test that would be two and a half seconds of
/// pumping per case for nothing.
Widget buildTestApp({MockAuthRepository? auth}) {
  // The keystore has no plugin behind it in a test, and a call into one that
  // is not there never comes back. This is the package's own in-memory hook.
  FlutterSecureStorage.setMockInitialValues(<String, String>{});

  final MockAuthRepository repository = auth ?? MockAuthRepository();

  return MultiProvider(
    providers: <SingleChildWidget>[
      ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
      Provider<AuthRepository>.value(value: repository),
      Provider<SecureSessionStore>(create: (_) => const SecureSessionStore()),
      Provider<BiometricService>(create: (_) => BiometricService()),
      ChangeNotifierProvider<AuthState>(
        create: (_) => AuthState(resolver: repository, signal: repository),
      ),
      Provider<UserRepository>(create: (_) => MockUserRepository()),
      Provider<GoalsRepository>(create: (_) => MockGoalsRepository()),
      Provider<ExercisesRepository>(create: (_) => MockExercisesRepository()),
      Provider<CoachRepository>(create: (_) => MockCoachRepository()),
      Provider<ProgressRepository>(create: (_) => MockProgressRepository()),
      Provider<NotificationsRepository>(
        create: (_) => MockNotificationsRepository(),
      ),
      Provider<SubscriptionRepository>(
        create:
            (BuildContext context) =>
                MockSubscriptionRepository(context.read<AuthRepository>()),
      ),
    ],
    child: const SuccenergyApp(),
  );
}

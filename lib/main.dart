import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'app/app.dart';
import 'core/localization/locale_provider.dart';
import 'data/mock/repositories/mock_auth_repository.dart';
import 'data/mock/repositories/mock_coach_repository.dart';
import 'data/mock/repositories/mock_exercises_repository.dart';
import 'data/mock/repositories/mock_goals_repository.dart';
import 'data/mock/repositories/mock_notifications_repository.dart';
import 'data/mock/repositories/mock_progress_repository.dart';
import 'data/mock/repositories/mock_subscription_repository.dart';
import 'data/mock/repositories/mock_user_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/coach_repository.dart';
import 'data/repositories/exercises_repository.dart';
import 'data/repositories/goals_repository.dart';
import 'data/repositories/notifications_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/repositories/subscription_repository.dart';
import 'data/repositories/user_repository.dart';

/// Application entry point.
///
/// This is the only file that names a repository implementation. Swapping the
/// mock layer for real API clients means changing the eight `create` lines
/// below and adding files under `data/`; no widget changes at all.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  // Poppins ships inside the bundle, so the app never reaches the network
  // for type and never falls back to a system face.
  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(
    MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
        Provider<AuthRepository>(create: (_) => MockAuthRepository()),
        Provider<UserRepository>(create: (_) => MockUserRepository()),
        Provider<GoalsRepository>(create: (_) => MockGoalsRepository()),
        Provider<ExercisesRepository>(create: (_) => MockExercisesRepository()),
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

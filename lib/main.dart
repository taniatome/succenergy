import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'app/app.dart';
import 'core/auth/auth_state.dart';
import 'core/auth/biometric_service.dart';
import 'core/auth/secure_session_store.dart';
import 'core/auth/session_signal.dart';
import 'core/localization/locale_provider.dart';
import 'core/motion/app_durations.dart';
import 'core/network/api_client.dart';
import 'data/implementations/api_coach_repository.dart';
import 'data/implementations/api_exercises_repository.dart';
import 'data/implementations/api_goals_repository.dart';
import 'data/implementations/api_notifications_repository.dart';
import 'data/implementations/api_progress_repository.dart';
import 'data/implementations/api_user_repository.dart';
import 'data/implementations/firebase_auth_repository.dart';
import 'data/implementations/unavailable_auth_repository.dart';
import 'data/mock/repositories/mock_subscription_repository.dart';
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
/// The only file that names a repository implementation. Everything but the
/// AI Coach's reply generation now runs against Firebase and the Succenergy
/// API; swapping an implementation is a change to one `create` line below.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  // Poppins ships inside the bundle, so the app never reaches the network
  // for type and never falls back to a system face.
  GoogleFonts.config.allowRuntimeFetching = false;

  final bool firebaseReady = await _startFirebase();
  const SecureSessionStore store = SecureSessionStore();

  // One client for the whole app: it holds the http connection pool and the
  // 401 refresh-and-retry, and a second would duplicate both.
  final ApiClient api = ApiClient();
  final AuthRepository auth = _authRepository(firebaseReady, store, api);

  runApp(
    MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
        Provider<AuthRepository>.value(value: auth),
        Provider<SecureSessionStore>.value(value: store),
        Provider<BiometricService>(create: (_) => BiometricService()),
        ChangeNotifierProvider<AuthState>(
          create: (_) => _authState(firebaseReady, auth),
        ),
        Provider<UserRepository>(create: (_) => ApiUserRepository(api)),
        Provider<GoalsRepository>(create: (_) => ApiGoalsRepository(api)),
        Provider<ExercisesRepository>(
          create: (_) => ApiExercisesRepository(api),
        ),
        Provider<CoachRepository>(create: (_) => ApiCoachRepository(api)),
        Provider<ProgressRepository>(create: (_) => ApiProgressRepository(api)),
        Provider<NotificationsRepository>(
          create: (_) => ApiNotificationsRepository(api),
        ),
        Provider<SubscriptionRepository>(
          create:
              (BuildContext context) =>
                  MockSubscriptionRepository(context.read<AuthRepository>()),
        ),
      ],
      child: const SuccenergyApp(),
    ),
  );
}

/// Starts the Firebase SDK, reporting whether it came up.
///
/// A missing `google-services.json` or `GoogleService-Info.plist` throws here.
/// That is a build configuration problem rather than something a user can act
/// on, so the app carries on into a state where sign-in reports itself
/// unavailable instead of dying on a red screen before anything is drawn.
Future<bool> _startFirebase() async {
  try {
    await Firebase.initializeApp();
    return true;
  } on Exception {
    return false;
  }
}

AuthRepository _authRepository(
  bool firebaseReady,
  SecureSessionStore store,
  ApiClient api,
) {
  if (!firebaseReady) {
    return const UnavailableAuthRepository();
  }
  return FirebaseAuthRepository(api: api, store: store);
}

/// The splash sequence is held for its full run before the first routing
/// decision, so a session that resolves in a frame does not cut the brand
/// moment off mid-bloom.
AuthState _authState(bool firebaseReady, AuthRepository auth) {
  if (!firebaseReady) {
    return AuthState.unavailable();
  }
  return AuthState(
    resolver: auth,
    signal: FirebaseSessionSignal(),
    minimumHold: AppDurations.splashHold,
  );
}

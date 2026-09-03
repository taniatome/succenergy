import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/auth/auth_state.dart';
import '../core/constants/app_constants.dart';
import '../core/localization/locale_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/offline_banner.dart';
import 'router.dart';

/// The root widget: theme, locale and router in one place.
class SuccenergyApp extends StatefulWidget {
  const SuccenergyApp({super.key});

  @override
  State<SuccenergyApp> createState() => _SuccenergyAppState();
}

class _SuccenergyAppState extends State<SuccenergyApp> {
  late final GoRouter _router = AppRouter.build(context.read<AuthState>());

  @override
  Widget build(BuildContext context) {
    final LocaleProvider locale = context.watch<LocaleProvider>();

    return MaterialApp.router(
      title: 'Succenergy AI Coach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      themeMode: ThemeMode.dark,
      routerConfig: _router,
      locale: locale.locale,
      supportedLocales: AppConstants.supportedLocales.map(Locale.new),
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (BuildContext context, Widget? child) {
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.25,
          // The banner sits above every route rather than inside any screen:
          // losing the network is a property of the app, not of the page that
          // happened to be open when it went.
          child: OfflineBanner(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}

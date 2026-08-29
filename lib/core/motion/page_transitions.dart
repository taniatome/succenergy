import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_curves.dart';
import 'app_durations.dart';

/// Route transition builders used by every route in `router.dart`.
///
/// The app never uses Material's default horizontal slide. Screens fade
/// through a barely perceptible scale, which reads as content resolving into
/// place rather than sliding past.
class AppPageTransitions {
  const AppPageTransitions._();

  /// The default transition: fade through a 1.02 scale.
  static CustomTransitionPage<void> fadeThrough({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppDurations.medium,
      reverseTransitionDuration: AppDurations.fast,
      transitionsBuilder: _fadeThroughBuilder,
    );
  }

  /// Used where a screen should feel like it rises over the current one, such
  /// as an exercise session or a goal detail.
  static CustomTransitionPage<void> riseOver({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: AppDurations.medium,
      reverseTransitionDuration: AppDurations.fast,
      transitionsBuilder: _riseOverBuilder,
    );
  }

  static Widget _fadeThroughBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondary,
    Widget child,
  ) {
    if (_reducedMotion(context)) {
      return child;
    }
    final Animation<double> eased = CurvedAnimation(
      parent: animation,
      curve: AppCurves.entrance,
      reverseCurve: AppCurves.exit,
    );
    return FadeTransition(
      opacity: eased,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.02, end: 1).animate(eased),
        child: child,
      ),
    );
  }

  static Widget _riseOverBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondary,
    Widget child,
  ) {
    if (_reducedMotion(context)) {
      return child;
    }
    final Animation<double> eased = CurvedAnimation(
      parent: animation,
      curve: AppCurves.entrance,
      reverseCurve: AppCurves.exit,
    );
    return FadeTransition(
      opacity: eased,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(eased),
        child: child,
      ),
    );
  }

  static bool _reducedMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}

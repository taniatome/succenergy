import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/motion/page_transitions.dart';

/// How a route is declared in this app.
///
/// Two shapes and no third: content fades through, and anything that should
/// feel like it opened over what was already there rises. Shared by the main
/// route table and the auth subtree, so a route added to either arrives on the
/// same motion.
class AppRoute {
  const AppRoute._();

  /// A route on the default fade-through transition.
  static GoRoute fade(
    String path,
    Widget Function(BuildContext context) builder, {
    List<RouteBase> routes = const <RouteBase>[],
  }) => _build(path, builder, routes: routes, rise: false);

  /// A route that rises over the screen beneath it.
  static GoRoute rise(
    String path,
    Widget Function(BuildContext context) builder, {
    List<RouteBase> routes = const <RouteBase>[],
  }) => _build(path, builder, routes: routes, rise: true);

  /// A rising route whose screen needs something out of the URL — a goal id, a
  /// session id — so the builder is handed the router state as well.
  static GoRoute riseWith(
    String path,
    Widget Function(BuildContext context, GoRouterState state) builder, {
    List<RouteBase> routes = const <RouteBase>[],
  }) => _build(path, builder, routes: routes, rise: true);

  /// The fading equivalent of [riseWith].
  static GoRoute fadeWith(
    String path,
    Widget Function(BuildContext context, GoRouterState state) builder, {
    List<RouteBase> routes = const <RouteBase>[],
  }) => _build(path, builder, routes: routes, rise: false);

  static GoRoute _build(
    String path,
    Object builder, {
    required List<RouteBase> routes,
    required bool rise,
  }) {
    return GoRoute(
      path: path,
      routes: routes,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final Widget child =
            builder is Widget Function(BuildContext, GoRouterState)
                ? builder(context, state)
                : (builder as Widget Function(BuildContext))(context);
        return rise
            ? AppPageTransitions.riseOver(child: child, state: state)
            : AppPageTransitions.fadeThrough(child: child, state: state);
      },
    );
  }
}

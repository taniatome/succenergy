import 'package:flutter/animation.dart';

/// Named easing curves. Nothing in this app animates linearly.
class AppCurves {
  const AppCurves._();

  /// Entrances: content arriving from off-screen or from zero opacity.
  static const Curve entrance = Curves.easeOutCubic;

  /// State changes: a value moving between two settled positions.
  static const Curve stateChange = Curves.easeInOutCubic;

  /// Exits: content leaving the screen.
  static const Curve exit = Curves.easeInCubic;

  /// Continuous ambient motion, such as the active segment pulse.
  static const Curve ambient = Curves.easeInOutSine;

  /// Achievement bloom on goal completion.
  static const Curve celebrate = Curves.easeOutQuart;
}

import 'package:flutter/painting.dart';

/// The single source of colour truth for Succenergy AI Coach.
///
/// No other file in the project may declare a raw colour value. Opacity
/// variants of these tokens are permitted; new hues are not.
///
/// Discipline: [gold] means Succenergy, achievement and primary action.
/// [aiBlue] means artificial intelligence and nothing else. The two never
/// accent the same element.
class AppColors {
  const AppColors._();

  /// Principal brand colour. Succenergy identity, primary actions, achievement.
  static const Color gold = Color(0xFFD4AF37);

  /// Accent reserved exclusively for AI and intelligence cues.
  static const Color aiBlue = Color(0xFF00E5FF);

  /// Primary application background.
  static const Color deepNavy = Color(0xFF0A1628);

  /// Cards, sheets and elevated surfaces.
  static const Color navyElevated = Color(0xFF111E33);

  /// Recessed areas, scrims and sheet backdrops.
  static const Color navyDeep = Color(0xFF060D1A);

  /// Headings and primary body text.
  static const Color textPrimary = Color(0xFFF5F7FA);

  /// Supporting text, labels and inactive states.
  static const Color textSecondary = Color(0xFF8A94A6);

  /// The one destructive/error hue, derived from the palette's warm axis.
  static const Color error = Color(0xFFD4483C);

  /// Fully transparent. Used in gradients and where a surface must not paint.
  static const Color transparent = Color(0x00000000);

  /// Hairline border on standard cards and inputs.
  static Color get hairline => textPrimary.withValues(alpha: 0.10);

  /// Hairline border carrying brand emphasis.
  static Color get goldHairline => gold.withValues(alpha: 0.28);

  /// Hairline border carrying AI emphasis.
  static Color get blueHairline => aiBlue.withValues(alpha: 0.28);

  /// Low-opacity gold used for in-progress, non-AI states.
  static Color get goldMuted => gold.withValues(alpha: 0.45);

  /// Backdrop scrim behind modal sheets and dialogs.
  static Color get scrim => navyDeep.withValues(alpha: 0.82);
}

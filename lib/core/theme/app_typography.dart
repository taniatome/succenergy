import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// The Succenergy type scale.
///
/// Poppins carries the whole app. It is a geometric sans with generous
/// counters and round terminals, so headings stay warm at display size and
/// body copy stays soft at 14. There is no second face: the "AI COACH"
/// register that used to be set in Orbitron is now Poppins in letterspaced
/// caps, which keeps the technical read without the hard machine edge.
///
/// Poppins runs optically larger and wider than the face it replaced, so the
/// sizes below sit a step down from a naive one-to-one swap and body leading
/// is opened up to match the taller x-height.
class AppTypography {
  const AppTypography._();

  static TextStyle _sans(
    double size,
    FontWeight weight, {
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.textPrimary,
    );
  }

  /// The letterspaced caps register: eyebrows, metric labels, the AI Coach
  /// title. Same family, held apart by tracking and weight rather than by a
  /// different typeface.
  static TextStyle _caps(
    double size,
    FontWeight weight, {
    double letterSpacing = 1.6,
    double height = 1.25,
    Color? color,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: height,
      color: color ?? AppColors.textPrimary,
    );
  }

  // --- Display and headings -------------------------------------------------

  static TextStyle get displayLarge =>
      _sans(34, FontWeight.w600, height: 1.16, letterSpacing: -0.8);

  static TextStyle get displayMedium =>
      _sans(28, FontWeight.w600, height: 1.2, letterSpacing: -0.6);

  static TextStyle get headlineLarge =>
      _sans(24, FontWeight.w600, height: 1.26, letterSpacing: -0.4);

  static TextStyle get headlineMedium =>
      _sans(21, FontWeight.w600, height: 1.3, letterSpacing: -0.3);

  static TextStyle get titleLarge =>
      _sans(18, FontWeight.w600, height: 1.34, letterSpacing: -0.2);

  static TextStyle get titleMedium =>
      _sans(15.5, FontWeight.w600, height: 1.38, letterSpacing: -0.1);

  // --- Body -----------------------------------------------------------------

  static TextStyle get bodyLarge => _sans(15.5, FontWeight.w400, height: 1.62);

  static TextStyle get bodyMedium => _sans(14, FontWeight.w400, height: 1.62);

  static TextStyle get bodySmall =>
      _sans(13, FontWeight.w400, height: 1.56, color: AppColors.textSecondary);

  static TextStyle get caption =>
      _sans(11.5, FontWeight.w400, height: 1.5, color: AppColors.textSecondary);

  /// Button and interactive label text.
  static TextStyle get label =>
      _sans(14.5, FontWeight.w600, height: 1.2, letterSpacing: 0.2);

  static TextStyle get labelSmall =>
      _sans(12.5, FontWeight.w600, height: 1.24, letterSpacing: 0.2);

  // --- The letterspaced caps register --------------------------------------

  /// Small caps section eyebrow. Always uppercased by the caller's widget.
  static TextStyle get eyebrow => _caps(
    10,
    FontWeight.w600,
    letterSpacing: 2.2,
    color: AppColors.textSecondary,
  );

  /// Data and metric labels beneath numeric values.
  static TextStyle get metricLabel => _caps(
    9.5,
    FontWeight.w500,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );

  /// Large numeric readouts on stat tiles and charts.
  static TextStyle get metricValue =>
      _caps(24, FontWeight.w600, letterSpacing: -0.2, height: 1.15);

  /// Medium numeric readouts inside compact tiles.
  static TextStyle get metricValueSmall =>
      _caps(18, FontWeight.w600, letterSpacing: -0.2, height: 1.15);

  /// The AI Coach screen title treatment.
  static TextStyle get aiTitle =>
      _caps(15, FontWeight.w600, letterSpacing: 2.8, color: AppColors.aiBlue);

  /// Principle name badges around the app.
  static TextStyle get principleBadge =>
      _caps(9, FontWeight.w600, letterSpacing: 1.3, color: AppColors.gold);

  /// Destination labels in the navigation bar.
  static TextStyle get navLabel => _caps(
    9.5,
    FontWeight.w500,
    letterSpacing: 0.9,
    height: 1.1,
    color: AppColors.textSecondary,
  );
}

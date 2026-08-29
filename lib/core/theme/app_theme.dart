import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Assembles the single [ThemeData] used by the app.
///
/// Every Material component is themed here so no screen ever renders an
/// unstyled default.
class AppTheme {
  const AppTheme._();

  static ThemeData build() {
    final ColorScheme scheme = const ColorScheme.dark().copyWith(
      primary: AppColors.gold,
      onPrimary: AppColors.navyDeep,
      secondary: AppColors.aiBlue,
      onSecondary: AppColors.navyDeep,
      surface: AppColors.navyElevated,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.textPrimary,
      outline: AppColors.hairline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.deepNavy,
      canvasColor: AppColors.deepNavy,
      splashColor: AppColors.gold.withValues(alpha: 0.06),
      highlightColor: AppColors.gold.withValues(alpha: 0.04),
      textTheme: _textTheme(),
      appBarTheme: _appBarTheme(),
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 22),
      dividerTheme: DividerThemeData(
        color: AppColors.hairline,
        thickness: AppBorders.hairline,
        space: AppSpacing.lg,
      ),
      cardTheme: _cardTheme(),
      inputDecorationTheme: _inputTheme(),
      elevatedButtonTheme: _elevatedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      bottomNavigationBarTheme: _bottomNavTheme(),
      bottomSheetTheme: _bottomSheetTheme(),
      dialogTheme: _dialogTheme(),
      popupMenuTheme: _popupMenuTheme(),
      snackBarTheme: _snackBarTheme(),
      switchTheme: _switchTheme(),
      chipTheme: _chipTheme(),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
        linearMinHeight: 3,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.gold,
        inactiveTrackColor: AppColors.textPrimary.withValues(alpha: 0.10),
        thumbColor: AppColors.gold,
        overlayColor: AppColors.gold.withValues(alpha: 0.14),
        trackHeight: 3,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
    );
  }

  static TextTheme _textTheme() => TextTheme(
    displayLarge: AppTypography.displayLarge,
    displayMedium: AppTypography.displayMedium,
    displaySmall: AppTypography.headlineLarge,
    headlineLarge: AppTypography.headlineLarge,
    headlineMedium: AppTypography.headlineMedium,
    headlineSmall: AppTypography.titleLarge,
    titleLarge: AppTypography.titleLarge,
    titleMedium: AppTypography.titleMedium,
    titleSmall: AppTypography.labelSmall,
    bodyLarge: AppTypography.bodyLarge,
    bodyMedium: AppTypography.bodyMedium,
    bodySmall: AppTypography.bodySmall,
    labelLarge: AppTypography.label,
    labelMedium: AppTypography.labelSmall,
    labelSmall: AppTypography.caption,
  );

  static AppBarTheme _appBarTheme() => AppBarTheme(
    backgroundColor: AppColors.transparent,
    surfaceTintColor: AppColors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: AppTypography.titleLarge,
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
    actionsIconTheme: const IconThemeData(
      color: AppColors.textSecondary,
      size: 22,
    ),
  );

  static CardThemeData _cardTheme() => CardThemeData(
    color: AppColors.navyElevated,
    surfaceTintColor: AppColors.transparent,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.card),
      side: BorderSide(color: AppColors.hairline),
    ),
  );

  static InputDecorationTheme _inputTheme() {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.input),
      borderSide: BorderSide(color: color, width: width),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.navyDeep.withValues(alpha: 0.55),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary.withValues(alpha: 0.7),
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      floatingLabelStyle: AppTypography.labelSmall.copyWith(
        color: AppColors.gold,
      ),
      errorStyle: AppTypography.caption.copyWith(color: AppColors.error),
      enabledBorder: border(AppColors.hairline, AppBorders.hairline),
      focusedBorder: border(AppColors.gold, AppBorders.emphasis),
      errorBorder: border(AppColors.error, AppBorders.hairline),
      focusedErrorBorder: border(AppColors.error, AppBorders.emphasis),
      disabledBorder: border(AppColors.hairline, AppBorders.hairline),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme() =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navyDeep,
          disabledBackgroundColor: AppColors.textPrimary.withValues(
            alpha: 0.08,
          ),
          disabledForegroundColor: AppColors.textSecondary,
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape: const StadiumBorder(),
          textStyle: AppTypography.label,
        ),
      );

  static TextButtonThemeData _textButtonTheme() => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.gold,
      textStyle: AppTypography.labelSmall,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      shape: const StadiumBorder(),
    ),
  );

  static OutlinedButtonThemeData _outlinedButtonTheme() =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.goldHairline),
          minimumSize: const Size.fromHeight(54),
          shape: const StadiumBorder(),
          textStyle: AppTypography.label,
        ),
      );

  static BottomNavigationBarThemeData _bottomNavTheme() =>
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.navyDeep,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTypography.metricLabel.copyWith(
          color: AppColors.gold,
        ),
        unselectedLabelStyle: AppTypography.metricLabel,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      );

  static BottomSheetThemeData _bottomSheetTheme() => BottomSheetThemeData(
    backgroundColor: AppColors.navyElevated,
    surfaceTintColor: AppColors.transparent,
    modalBarrierColor: AppColors.scrim,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
    ),
  );

  static DialogThemeData _dialogTheme() => DialogThemeData(
    backgroundColor: AppColors.navyElevated,
    surfaceTintColor: AppColors.transparent,
    elevation: 0,
    barrierColor: AppColors.scrim,
    titleTextStyle: AppTypography.titleLarge,
    contentTextStyle: AppTypography.bodyMedium.copyWith(
      color: AppColors.textSecondary,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.cardLarge),
      side: BorderSide(color: AppColors.hairline),
    ),
  );

  static PopupMenuThemeData _popupMenuTheme() => PopupMenuThemeData(
    color: AppColors.navyElevated,
    surfaceTintColor: AppColors.transparent,
    elevation: 0,
    textStyle: AppTypography.bodyMedium,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.card),
      side: BorderSide(color: AppColors.hairline),
    ),
  );

  static SnackBarThemeData _snackBarTheme() => SnackBarThemeData(
    backgroundColor: AppColors.navyElevated,
    contentTextStyle: AppTypography.bodyMedium,
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.input),
      side: BorderSide(color: AppColors.goldHairline),
    ),
  );

  static SwitchThemeData _switchTheme() => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> s) {
      return s.contains(WidgetState.selected)
          ? AppColors.navyDeep
          : AppColors.textSecondary;
    }),
    trackColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> s) {
      return s.contains(WidgetState.selected)
          ? AppColors.gold
          : AppColors.textPrimary.withValues(alpha: 0.08);
    }),
    trackOutlineColor: WidgetStateProperty.all<Color>(AppColors.hairline),
  );

  static ChipThemeData _chipTheme() => ChipThemeData(
    backgroundColor: AppColors.navyDeep.withValues(alpha: 0.6),
    selectedColor: AppColors.gold.withValues(alpha: 0.16),
    side: BorderSide(color: AppColors.hairline),
    labelStyle: AppTypography.labelSmall,
    secondaryLabelStyle: AppTypography.labelSmall,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    shape: const StadiumBorder(),
    showCheckmark: false,
  );
}

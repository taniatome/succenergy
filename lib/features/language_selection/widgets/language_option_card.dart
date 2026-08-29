import 'package:flutter/material.dart';

import '../../../core/motion/app_curves.dart';
import '../../../core/motion/app_durations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// One of the two large language choices.
///
/// Selecting animates a gold border and bloom in, so the choice registers as
/// a state change rather than a radio button.
class LanguageOptionCard extends StatelessWidget {
  const LanguageOptionCard({
    required this.name,
    required this.nativeName,
    required this.code,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String name;
  final String nativeName;

  /// Locale code, shown as the card's typographic mark.
  final String code;

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.medium,
        curve: AppCurves.stateChange,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: AppGradients.card,
          borderRadius: BorderRadius.circular(AppRadii.cardLarge),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.hairline,
            width: selected ? AppBorders.emphasis : AppBorders.hairline,
          ),
          boxShadow: selected ? AppShadows.goldGlow : AppShadows.elevation,
        ),
        child: Row(
          children: <Widget>[
            _codeMark(),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(nativeName, style: AppTypography.titleLarge),
                  const SizedBox(height: 2),
                  Text(name, style: AppTypography.bodySmall),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: AppDurations.fast,
              opacity: selected ? 1 : 0,
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.gold,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _codeMark() {
    return AnimatedContainer(
      duration: AppDurations.medium,
      curve: AppCurves.stateChange,
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            selected
                ? AppColors.gold.withValues(alpha: 0.14)
                : AppColors.navyDeep.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(
          color: selected ? AppColors.goldHairline : AppColors.hairline,
        ),
      ),
      child: Text(
        code.toUpperCase(),
        style: AppTypography.metricValueSmall.copyWith(
          color: selected ? AppColors.gold : AppColors.textSecondary,
          fontSize: 15,
        ),
      ),
    );
  }
}

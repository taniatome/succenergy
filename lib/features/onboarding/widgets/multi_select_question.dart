import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/motion/app_curves.dart';
import '../../../core/motion/app_durations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// An assessment question answered by choosing from a set of chips.
///
/// Selecting past the limit drops the oldest choice, so the user is never
/// blocked by a silent maximum.
class MultiSelectQuestion extends StatelessWidget {
  const MultiSelectQuestion({
    required this.title,
    required this.help,
    required this.optionKeys,
    required this.selectedKeys,
    required this.onToggle,
    super.key,
  });

  final String title;
  final String help;

  /// Localisation keys for the available choices.
  final List<String> optionKeys;

  final List<String> selectedKeys;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: AppTypography.headlineLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          help,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: <Widget>[
            for (final String key in optionKeys)
              _chip(context, key, selectedKeys.contains(key)),
          ],
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, String key, bool selected) {
    return GestureDetector(
      onTap: () => onToggle(key),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.stateChange,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color:
              selected
                  ? AppColors.gold.withValues(alpha: 0.12)
                  : AppColors.navyDeep.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.hairline,
            width: selected ? AppBorders.emphasis : AppBorders.hairline,
          ),
          boxShadow: selected ? AppShadows.goldGlow : null,
        ),
        child: Text(
          context.tr(key),
          style: AppTypography.labelSmall.copyWith(
            color: selected ? AppColors.gold : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

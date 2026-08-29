import 'package:flutter/material.dart';

import '../../../core/motion/app_curves.dart';
import '../../../core/motion/app_durations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/action_item.dart';
import '../../../core/localization/string_extensions.dart';

/// A checkable step in a goal's action plan.
///
/// Completing one fills the marker with gold and lifts a brief bloom, so
/// finishing a step is felt rather than merely recorded.
class ActionItemTile extends StatelessWidget {
  const ActionItemTile({
    required this.action,
    required this.onToggle,
    super.key,
  });

  final ActionItem action;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onToggle(!action.isDone),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AnimatedContainer(
              duration: AppDurations.medium,
              curve: AppCurves.stateChange,
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    action.isDone
                        ? AppColors.gold
                        : AppColors.navyDeep.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
                border: Border.all(
                  color: action.isDone ? AppColors.gold : AppColors.hairline,
                  width: AppBorders.hairline,
                ),
                boxShadow: action.isDone ? AppShadows.goldGlow : null,
              ),
              child:
                  action.isDone
                      ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: AppColors.navyDeep,
                      )
                      : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: AppDurations.medium,
                curve: AppCurves.stateChange,
                style: AppTypography.bodyMedium.copyWith(
                  color:
                      action.isDone
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                  decoration:
                      action.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                  decorationColor: AppColors.textSecondary,
                ),
                child: Text(action.titleFor(context.localeCode)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

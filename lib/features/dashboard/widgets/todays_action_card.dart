import 'package:flutter/material.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/motion/app_curves.dart';
import '../../../core/motion/app_durations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/cards/glow_card.dart';
import '../../../core/widgets/section_eyebrow.dart';

/// The single concrete step for today.
///
/// The most prominent element on the Dashboard after the ring, because one
/// clear action is the whole point of Praxis.
class TodaysActionCard extends StatelessWidget {
  const TodaysActionCard({
    required this.title,
    required this.isDone,
    required this.onComplete,
    super.key,
  });

  final String title;
  final bool isDone;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: isDone ? GlowAccent.none : GlowAccent.gold,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionEyebrow(
            label: context.tr('dashboard.action.eyebrow'),
            withRule: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.tr('dashboard.action.title'),
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            title,
            style: AppTypography.headlineMedium.copyWith(
              color: isDone ? AppColors.textSecondary : AppColors.textPrimary,
              decoration: isDone ? TextDecoration.lineThrough : null,
              decorationColor: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _completeRow(context),
        ],
      ),
    );
  }

  Widget _completeRow(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isDone ? null : onComplete,
      child: Row(
        children: <Widget>[
          AnimatedContainer(
            duration: AppDurations.medium,
            curve: AppCurves.stateChange,
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  isDone
                      ? AppColors.gold
                      : AppColors.navyDeep.withValues(alpha: 0.6),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDone ? AppColors.gold : AppColors.goldHairline,
                width: AppBorders.hairline,
              ),
              boxShadow: isDone ? AppShadows.goldGlow : null,
            ),
            child:
                isDone
                    ? const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: AppColors.navyDeep,
                    )
                    : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            isDone
                ? context.tr('dashboard.action.doneToday')
                : context.tr('dashboard.action.markDone'),
            style: AppTypography.labelSmall.copyWith(
              color: isDone ? AppColors.gold : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

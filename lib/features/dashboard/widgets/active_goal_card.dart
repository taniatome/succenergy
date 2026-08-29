import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/cards/gradient_border_card.dart';
import '../../../core/widgets/principle_badge.dart';
import '../../../core/widgets/progress_indicators.dart';
import '../../../core/widgets/section_eyebrow.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/milestone.dart';

/// The goal the Dashboard leads with.
///
/// The one card on this screen that carries a gradient edge, because it is
/// the thing the rest of the screen is in service of.
class ActiveGoalCard extends StatelessWidget {
  const ActiveGoalCard({required this.goal, required this.onTap, super.key});

  final Goal goal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Milestone? next = goal.nextMilestone;

    return GradientBorderCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SectionEyebrow(label: context.tr('dashboard.goal.eyebrow')),
              const Spacer(),
              PrincipleBadge(principle: goal.principle),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            goal.titleFor(context.localeCode),
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(child: AppProgress.bar(value: goal.progress)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${(goal.progress * 100).round()}%',
                style: AppTypography.metricValueSmall.copyWith(
                  fontSize: 13,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          if (next != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            _nextMilestone(context, next),
          ],
        ],
      ),
    );
  }

  Widget _nextMilestone(BuildContext context, Milestone next) {
    final String date = DateFormat.MMMd(
      context.localeCode,
    ).format(next.dueDate);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 3),
          child: Icon(
            Icons.flag_outlined,
            size: 15,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SectionEyebrow(label: context.tr('dashboard.goal.next')),
              const SizedBox(height: 2),
              Text(
                next.titleFor(context.localeCode),
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(date, style: AppTypography.caption),
      ],
    );
  }
}

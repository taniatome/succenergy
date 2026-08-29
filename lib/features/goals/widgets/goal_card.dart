import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/cards/glow_card.dart';
import '../../../core/widgets/principle_badge.dart';
import '../../../core/widgets/progress_indicators.dart';
import '../../../core/widgets/section_eyebrow.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/milestone.dart';
import 'goal_overflow_menu.dart';

/// One goal in the list: principle, progress, next milestone and target date.
///
/// The overflow affordance in the top corner carries edit and delete, the
/// same menu Goal Detail opens.
class GoalCard extends StatelessWidget {
  const GoalCard({
    required this.goal,
    required this.onTap,
    required this.onMenuAction,
    super.key,
  });

  final Goal goal;
  final VoidCallback onTap;
  final ValueChanged<GoalMenuAction> onMenuAction;

  @override
  Widget build(BuildContext context) {
    final Milestone? next = goal.nextMilestone;
    final DateFormat format = DateFormat.MMMd(context.localeCode);

    return GlowCard(
      onTap: onTap,
      accent: goal.isCompleted ? GlowAccent.none : GlowAccent.gold,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _header(context, format),
          const SizedBox(height: AppSpacing.sm),
          Text(
            goal.titleFor(context.localeCode),
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          _progress(),
          if (next != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            _nextMilestone(context, next),
          ],
          if (goal.isCompleted && goal.completedAt != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${context.tr('goals.detail.completedOn')}  ${format.format(goal.completedAt!)}',
              style: AppTypography.caption,
            ),
          ],
        ],
      ),
    );
  }

  Widget _header(BuildContext context, DateFormat format) {
    return Row(
      children: <Widget>[
        PrincipleBadge(principle: goal.principle),
        const Spacer(),
        if (goal.isCompleted)
          const Icon(Icons.verified_outlined, size: 17, color: AppColors.gold)
        else
          Text(
            '${context.tr('goals.card.due')}  ${format.format(goal.targetDate)}',
            style: AppTypography.caption,
          ),
        const SizedBox(width: AppSpacing.xxs),
        SizedBox(
          width: 28,
          height: 28,
          child: GoalOverflowMenu(onSelected: onMenuAction),
        ),
      ],
    );
  }

  Widget _progress() {
    return Row(
      children: <Widget>[
        Expanded(child: AppProgress.bar(value: goal.progress)),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${(goal.progress * 100).round()}%',
          style: AppTypography.metricValueSmall.copyWith(
            fontSize: 12,
            color: goal.isCompleted ? AppColors.gold : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _nextMilestone(BuildContext context, Milestone next) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionEyebrow(label: context.tr('goals.card.next')),
        const SizedBox(height: 2),
        Text(
          next.titleFor(context.localeCode),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

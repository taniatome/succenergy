import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/principle_badge.dart';
import '../../../core/widgets/progress_indicators.dart';
import '../../../data/models/goal.dart';
import 'goal_completion_bloom.dart';

/// The top of Goal Detail: principle, title, date and the progress ring.
///
/// The ring is wrapped in [GoalCompletionBloom], so closing the goal plays
/// the completion moment here rather than anywhere else on the screen.
class GoalDetailHeader extends StatelessWidget {
  const GoalDetailHeader({required this.goal, super.key});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final DateFormat format = DateFormat.yMMMd(context.localeCode);
    final String dateLabel = context.tr(
      goal.isCompleted ? 'goals.detail.completedOn' : 'goals.detail.targetDate',
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              PrincipleBadge(principle: goal.principle, showPosition: true),
              const SizedBox(height: AppSpacing.sm),
              Text(
                goal.titleFor(context.localeCode),
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$dateLabel  ${format.format(goal.completedAt ?? goal.targetDate)}',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        GoalCompletionBloom(
          completed: goal.isCompleted,
          child: AppProgress.ring(value: goal.progress, diameter: 62),
        ),
      ],
    );
  }
}

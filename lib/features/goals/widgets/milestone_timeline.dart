import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/milestone.dart';

/// The vertical, connected milestone timeline on Goal Detail.
///
/// The connector runs gold behind reached milestones and fades to a hairline
/// beyond the current position, so progression is legible at a glance.
class MilestoneTimeline extends StatelessWidget {
  const MilestoneTimeline({
    required this.milestones,
    required this.onToggle,
    super.key,
  });

  final List<Milestone> milestones;
  final void Function(Milestone milestone, bool isReached) onToggle;

  @override
  Widget build(BuildContext context) {
    final DateFormat format = DateFormat.MMMd(context.localeCode);

    return Column(
      children: <Widget>[
        for (int i = 0; i < milestones.length; i++)
          _row(context, milestones[i], i, format),
      ],
    );
  }

  Widget _row(
    BuildContext context,
    Milestone milestone,
    int index,
    DateFormat format,
  ) {
    final bool isLast = index == milestones.length - 1;
    final bool nextReached = !isLast && milestones[index + 1].isReached;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 26,
            child: Column(
              children: <Widget>[
                _node(milestone.isReached),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: AppBorders.emphasis,
                      color:
                          nextReached
                              ? AppColors.gold.withValues(alpha: 0.5)
                              : AppColors.hairline,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onToggle(milestone, !milestone.isReached),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      milestone.titleFor(context.localeCode),
                      style: AppTypography.bodyLarge.copyWith(
                        color:
                            milestone.isReached
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      format.format(milestone.reachedAt ?? milestone.dueDate),
                      style: AppTypography.caption.copyWith(
                        color:
                            milestone.isReached
                                ? AppColors.gold
                                : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _node(bool reached) {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            reached
                ? AppColors.gold
                : AppColors.navyDeep.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        border: Border.all(
          color: reached ? AppColors.gold : AppColors.hairline,
          width: AppBorders.hairline,
        ),
        boxShadow: reached ? AppShadows.goldGlow : null,
      ),
      child:
          reached
              ? const Icon(
                Icons.check_rounded,
                size: 11,
                color: AppColors.navyDeep,
              )
              : null,
    );
  }
}

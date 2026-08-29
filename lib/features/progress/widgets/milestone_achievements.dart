import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_eyebrow.dart';
import '../../../data/models/milestone.dart';

/// Milestones already reached across every goal, most recent first.
class MilestoneAchievements extends StatelessWidget {
  const MilestoneAchievements({
    required this.milestones,
    this.limit = 6,
    super.key,
  });

  final List<Milestone> milestones;

  /// How many to show before the list stops earning its space.
  final int limit;

  @override
  Widget build(BuildContext context) {
    final String locale = context.localeCode;
    final DateFormat format = DateFormat.MMMd(locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionEyebrow(
          label: context.tr('progress.milestones.title'),
          withRule: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final Milestone milestone in milestones.take(limit))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Icon(
                    Icons.workspace_premium_outlined,
                    size: 16,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    milestone.titleFor(locale),
                    style: AppTypography.bodyMedium,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  format.format(milestone.reachedAt!),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

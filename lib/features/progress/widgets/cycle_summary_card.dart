import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/cards/glow_card.dart';
import '../../../core/widgets/cycle_ring/cycle_ring.dart';
import '../../../core/widgets/section_eyebrow.dart';
import '../../../data/models/principle.dart';

/// The compact Cycle Ring on Progress, showing overall methodology
/// progression rather than the day-to-day position the Dashboard shows.
class CycleSummaryCard extends StatelessWidget {
  const CycleSummaryCard({required this.completion, super.key});

  /// Share of the seven-principle cycle closed so far, 0 to 1.
  final double completion;

  @override
  Widget build(BuildContext context) {
    final int closed = (completion * Principle.values.length).round().clamp(
      0,
      Principle.values.length - 1,
    );

    return GlowCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: <Widget>[
          CycleRing(
            activeIndex: closed,
            completedCount: closed,
            size: 92,
            strokeWidth: 6,
            child: Text(
              '${(completion * 100).round()}%',
              style: AppTypography.metricValueSmall.copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SectionEyebrow(label: context.tr('progress.cycle.eyebrow')),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.tr('progress.cycle.title'),
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  context.tr(Principle.values[closed].descriptionKey),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

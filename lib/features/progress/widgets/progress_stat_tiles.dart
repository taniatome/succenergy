import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/cards/glow_card.dart';

/// The four headline counters above the Progress charts.
class ProgressStatTiles extends StatelessWidget {
  const ProgressStatTiles({required this.stats, super.key});

  /// Counter name to value, keyed as returned by the progress repository.
  final Map<String, int> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _tile(
          '${stats['completionRate'] ?? 0}%',
          context.tr('progress.stat.completionRate'),
        ),
        const SizedBox(width: AppSpacing.xs),
        _tile('${stats['streak'] ?? 0}', context.tr('progress.stat.streak')),
        const SizedBox(width: AppSpacing.xs),
        _tile(
          '${stats['sessions'] ?? 0}',
          context.tr('progress.stat.sessions'),
        ),
        const SizedBox(width: AppSpacing.xs),
        _tile('${stats['actions'] ?? 0}', context.tr('progress.stat.actions')),
      ],
    );
  }

  Widget _tile(String value, String label) {
    return Expanded(
      child: GlowCard(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        child: Column(
          children: <Widget>[
            Text(
              value,
              style: AppTypography.metricValueSmall.copyWith(
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              style: AppTypography.metricLabel.copyWith(
                fontSize: 8,
                letterSpacing: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

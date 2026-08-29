import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Three compact counters beneath the ring: streak, active goals, completed
/// practice. Numbers sit in the metric style, labels in letterspaced caps.
class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({
    required this.dayStreak,
    required this.activeGoals,
    required this.exercisesDone,
    super.key,
  });

  final int dayStreak;
  final int activeGoals;
  final int exercisesDone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _tile('$dayStreak', context.tr('dashboard.stats.dayStreak')),
        ),
        _divider(),
        Expanded(
          child: _tile(
            '$activeGoals',
            context.tr('dashboard.stats.goalsActive'),
          ),
        ),
        _divider(),
        Expanded(
          child: _tile(
            '$exercisesDone',
            context.tr('dashboard.stats.exercises'),
          ),
        ),
      ],
    );
  }

  Widget _tile(String value, String label) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: AppTypography.metricValue.copyWith(color: AppColors.gold),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: AppTypography.metricLabel,
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: AppBorders.hairline,
      height: 34,
      color: AppColors.hairline,
    );
  }
}

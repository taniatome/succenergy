import 'package:flutter/widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/progress_snapshot.dart';

/// Three weeks of activity as a grid of days.
///
/// Each cell brightens with the amount of work recorded that day, so a broken
/// streak is visible without a number having to say so.
class ActivityGrid extends StatelessWidget {
  const ActivityGrid({required this.history, super.key});

  final List<ProgressSnapshot> history;

  static const int _columns = 7;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double gap = AppSpacing.xs;
        final double cell =
            (constraints.maxWidth - gap * (_columns - 1)) / _columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final ProgressSnapshot day in history) _cell(day, cell),
          ],
        );
      },
    );
  }

  Widget _cell(ProgressSnapshot day, double size) {
    final int work = day.actionsCompleted + day.exercisesCompleted;
    final double intensity =
        work == 0 ? 0 : (0.28 + work * 0.18).clamp(0.0, 1.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color:
            work == 0
                ? AppColors.textPrimary.withValues(alpha: 0.04)
                : AppColors.gold.withValues(alpha: intensity),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        border: Border.all(
          color: work == 0 ? AppColors.hairline : AppColors.goldHairline,
          width: AppBorders.hairline,
        ),
      ),
    );
  }
}

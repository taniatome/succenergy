import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/motion/app_curves.dart';
import '../../../core/motion/app_durations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Where the user is in registration: three segments and a count.
///
/// The current segment is gold and wider than the rest, completed ones hold
/// their gold at reduced strength, and the ones still to come are navy behind
/// a hairline. Widths and colours animate, so advancing a step reads as the
/// bar filling rather than as a new bar being drawn.
class StepIndicator extends StatelessWidget {
  const StepIndicator({required this.current, this.total = 3, super.key});

  /// One-based position of the step being shown.
  final int current;

  final int total;

  /// Height of one segment.
  static const double _track = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            for (int step = 1; step <= total; step++) ...<Widget>[
              if (step > 1) const SizedBox(width: AppSpacing.xxs),
              Expanded(
                // The active segment takes half again the width of the others,
                // so the bar says where you are without a label doing it.
                flex: step == current ? 3 : 2,
                child: _segment(step),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.tr(
            'auth.register.step',
            params: <String, String>{'current': '$current', 'total': '$total'},
          ),
          style: AppTypography.metricLabel.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _segment(int step) {
    final bool isCurrent = step == current;
    final bool isDone = step < current;

    return AnimatedContainer(
      duration: AppDurations.medium,
      curve: AppCurves.stateChange,
      height: _track,
      decoration: BoxDecoration(
        color:
            isCurrent
                ? AppColors.gold
                : isDone
                ? AppColors.goldMuted
                : AppColors.navyDeep.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border:
            isCurrent || isDone
                ? null
                : Border.all(
                  color: AppColors.hairline,
                  width: AppBorders.hairline,
                ),
        boxShadow: isCurrent ? AppShadows.goldGlow : null,
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

import '../../../core/motion/app_curves.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Three AI Blue dots that fade in sequence while the coach composes.
///
/// Shown in place of the incoming bubble, so a reply never appears without
/// warning.
class ThinkingIndicator extends StatefulWidget {
  const ThinkingIndicator({required this.label, super.key});

  /// Already-localised word shown beside the dots.
  final String label;

  @override
  State<ThinkingIndicator> createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<ThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.value = 0.5;
      return;
    }
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.navyElevated,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: AppColors.blueHairline,
          width: AppBorders.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            widget.label,
            style: AppTypography.metricLabel.copyWith(color: AppColors.aiBlue),
          ),
          const SizedBox(width: AppSpacing.sm),
          for (int i = 0; i < 3; i++) _dot(i),
        ],
      ),
    );
  }

  Widget _dot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double phase = (_controller.value - index * 0.18) % 1;
        final double curved = AppCurves.ambient.transform(
          phase < 0.5 ? phase * 2 : (1 - phase) * 2,
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.aiBlue.withValues(alpha: 0.25 + 0.7 * curved),
            ),
          ),
        );
      },
    );
  }
}

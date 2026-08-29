import 'package:flutter/widgets.dart';

import '../../motion/app_curves.dart';
import '../../motion/app_durations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

/// The app switch.
///
/// Built rather than borrowed, so the on state reads as a gold bloom in the
/// track instead of a Material accent fill.
class AppSwitch extends StatelessWidget {
  const AppSwitch({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool>? onChanged;

  static const double _width = 48;
  static const double _height = 28;
  static const double _thumb = 20;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onChanged != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.stateChange,
        width: _width,
        height: _height,
        padding: const EdgeInsets.all(AppSpacing.xxs),
        decoration: BoxDecoration(
          color:
              value
                  ? AppColors.gold.withValues(alpha: 0.22)
                  : AppColors.navyDeep.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: value ? AppColors.goldHairline : AppColors.hairline,
            width: AppBorders.hairline,
          ),
          boxShadow: value && enabled ? AppShadows.goldGlow : null,
        ),
        child: AnimatedAlign(
          duration: AppDurations.fast,
          curve: AppCurves.stateChange,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: _thumb,
            height: _thumb,
            decoration: BoxDecoration(
              color:
                  enabled
                      ? (value ? AppColors.gold : AppColors.textSecondary)
                      : AppColors.textSecondary.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

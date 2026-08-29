import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/motion/app_curves.dart';
import '../../../core/motion/app_durations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/principle.dart';

/// The horizontal row that filters the library by principle.
///
/// Runs in cycle order, opening with an "All" entry, so the row itself
/// teaches the sequence of the methodology.
class PrincipleSelector extends StatelessWidget {
  const PrincipleSelector({
    required this.principles,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final List<Principle> principles;
  final Principle? selected;
  final ValueChanged<Principle?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        itemCount: principles.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _pill(
              context.tr('exercises.all'),
              selected == null,
              () => onSelect(null),
            );
          }
          final Principle principle = principles[index - 1];
          return _pill(
            context.tr(principle.labelKey),
            selected == principle,
            () => onSelect(principle),
          );
        },
      ),
    );
  }

  Widget _pill(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.stateChange,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color:
              active
                  ? AppColors.gold.withValues(alpha: 0.12)
                  : AppColors.navyElevated.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: active ? AppColors.gold : AppColors.hairline,
            width: AppBorders.hairline,
          ),
          boxShadow: active ? AppShadows.goldGlow : null,
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.principleBadge.copyWith(
            color: active ? AppColors.gold : AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

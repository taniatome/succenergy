import 'package:flutter/widgets.dart';

import '../../motion/app_curves.dart';
import '../../motion/app_durations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../section_eyebrow.dart';

/// A labelled row of mutually exclusive choices.
///
/// Used for coaching tone, check-in rhythm and language on Profile, and for
/// the audience picker in the management console, so it lives in core.
class PreferenceChoiceRow extends StatelessWidget {
  const PreferenceChoiceRow({
    this.label,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
    super.key,
  });

  /// Optional eyebrow. Omitted where a nearby heading already names the row.
  final String? label;

  /// Already-localised option labels.
  final List<String> options;

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (label != null) ...<Widget>[
          SectionEyebrow(label: label!),
          const SizedBox(height: AppSpacing.xs),
        ],
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: <Widget>[
            for (int i = 0; i < options.length; i++)
              _option(options[i], i == selectedIndex, () => onSelect(i)),
          ],
        ),
      ],
    );
  }

  Widget _option(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.stateChange,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color:
              selected
                  ? AppColors.gold.withValues(alpha: 0.12)
                  : AppColors.navyDeep.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.hairline,
            width: AppBorders.hairline,
          ),
        ),
        child: Text(
          text,
          style: AppTypography.labelSmall.copyWith(
            color: selected ? AppColors.gold : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

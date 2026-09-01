import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../inputs/scale_input.dart';

/// An assessment question answered by moving a scale between two poles.
class ScaleQuestion extends StatelessWidget {
  const ScaleQuestion({
    required this.title,
    required this.help,
    required this.lowLabel,
    required this.highLabel,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String title;
  final String help;
  final String lowLabel;
  final String highLabel;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: AppTypography.headlineLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          help,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        ScaleInput(
          value: value,
          onChanged: onChanged,
          lowLabel: lowLabel,
          highLabel: highLabel,
        ),
      ],
    );
  }
}

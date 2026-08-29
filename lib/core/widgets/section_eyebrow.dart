import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// The small letterspaced caps label that opens a section.
///
/// This is the letterspaced caps register: eyebrows, metric labels, the AI Coach
/// title. Never body text.
class SectionEyebrow extends StatelessWidget {
  const SectionEyebrow({
    required this.label,
    this.useAiAccent = false,
    this.withRule = false,
    super.key,
  });

  final String label;

  /// Renders in AI Blue. Only for sections that belong to the coach.
  final bool useAiAccent;

  /// Draws a hairline that runs from the label to the end of the row.
  final bool withRule;

  @override
  Widget build(BuildContext context) {
    final Text text = Text(
      label.toUpperCase(),
      style: AppTypography.eyebrow.copyWith(
        color: useAiAccent ? AppColors.aiBlue : AppColors.textSecondary,
      ),
    );

    if (!withRule) {
      return text;
    }

    return Row(
      children: <Widget>[
        text,
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Container(
            height: AppBorders.hairline,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  (useAiAccent ? AppColors.aiBlue : AppColors.gold).withValues(
                    alpha: 0.35,
                  ),
                  AppColors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

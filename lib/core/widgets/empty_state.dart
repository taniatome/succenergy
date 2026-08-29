import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'buttons/secondary_button.dart';
import 'section_eyebrow.dart';

/// The empty state.
///
/// Written as an invitation rather than an apology: an eyebrow, a line that
/// says what could be here, and a way to start.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.eyebrow,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.goldHairline,
                  width: AppBorders.hairline,
                ),
                gradient: RadialGradient(
                  colors: <Color>[
                    AppColors.gold.withValues(alpha: 0.14),
                    AppColors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionEyebrow(label: eyebrow),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              SecondaryButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

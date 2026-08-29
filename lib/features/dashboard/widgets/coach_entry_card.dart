import 'package:flutter/material.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/cards/glow_card.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/section_eyebrow.dart';

/// The entry point to the AI Coach.
///
/// The one element on the Dashboard that carries AI Blue, and it carries no
/// gold at all. The body names the user's current goal so the invitation is
/// specific rather than generic.
class CoachEntryCard extends StatelessWidget {
  const CoachEntryCard({
    required this.goalTitle,
    required this.onOpen,
    super.key,
  });

  final String goalTitle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: GlowAccent.ai,
      onTap: onOpen,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _mark(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SectionEyebrow(
                  label: context.tr('dashboard.coach.eyebrow'),
                  useAiAccent: true,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.tr('dashboard.coach.title'),
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  context.tr(
                    'dashboard.coach.body',
                    params: <String, String>{'goal': goalTitle},
                  ),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.xs),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: AppColors.aiBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mark() {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.blueHairline,
          width: AppBorders.hairline,
        ),
        gradient: RadialGradient(
          colors: <Color>[
            AppColors.aiBlue.withValues(alpha: 0.18),
            AppColors.transparent,
          ],
        ),
      ),
      child: const AppIcon(
        mark: AppIconMark.signal,
        color: AppColors.aiBlue,
        size: 20,
      ),
    );
  }
}

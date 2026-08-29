import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/cards/glow_card.dart';
import '../../../core/widgets/inputs/scale_input.dart';
import '../../../core/widgets/section_eyebrow.dart';
import '../../../data/models/onboarding_response.dart';

/// The onboarding answers shown back on Profile, so the user can see exactly
/// what the coach is working from.
///
/// All seven answers appear, in the order they were asked. The motivation
/// scale is shown on the same control the question used, rather than as a
/// number the user never entered.
class CoachingProfileSection extends StatelessWidget {
  const CoachingProfileSection({required this.response, super.key});

  final OnboardingResponse response;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionEyebrow(
          label: context.tr('profile.section.coaching'),
          withRule: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _entry(
          context,
          context.tr('onboarding.summary.wants'),
          OnboardingResponse.textFor(response.ambition, context.localeCode),
        ),
        const SizedBox(height: AppSpacing.sm),
        _entry(
          context,
          context.tr('onboarding.summary.focus'),
          response.focusAreaKeys.map(context.tr).join('  ·  '),
        ),
        const SizedBox(height: AppSpacing.sm),
        _entry(
          context,
          context.tr('onboarding.summary.challenge'),
          OnboardingResponse.textFor(response.challenge, context.localeCode),
        ),
        const SizedBox(height: AppSpacing.sm),
        _entry(
          context,
          context.tr('onboarding.summary.priorities'),
          response.priorityKeys.map(context.tr).join('  ·  '),
        ),
        const SizedBox(height: AppSpacing.sm),
        _entry(
          context,
          context.tr('onboarding.summary.mainGoals'),
          OnboardingResponse.textFor(response.mainGoals, context.localeCode),
        ),
        const SizedBox(height: AppSpacing.sm),
        _motivation(context),
        const SizedBox(height: AppSpacing.sm),
        _entry(
          context,
          context.tr('onboarding.summary.success'),
          OnboardingResponse.textFor(
            response.successVision,
            context.localeCode,
          ),
        ),
      ],
    );
  }

  Widget _motivation(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionEyebrow(label: context.tr('onboarding.summary.motivation')),
          const SizedBox(height: AppSpacing.sm),
          ScaleInput(
            value: response.motivationBalance,
            lowLabel: context.tr('onboarding.q6.scaleMin'),
            highLabel: context.tr('onboarding.q6.scaleMax'),
          ),
        ],
      ),
    );
  }

  Widget _entry(BuildContext context, String label, String value) {
    return GlowCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionEyebrow(label: label),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value.trim().isEmpty ? context.tr('purpose.unanswered') : value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

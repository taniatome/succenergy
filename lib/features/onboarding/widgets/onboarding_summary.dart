import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/animated_reveal.dart';
import '../../../core/widgets/cards/glow_card.dart';
import '../../../core/widgets/section_eyebrow.dart';
import '../../../data/models/onboarding_response.dart';

/// The closing screen of the assessment: the answers read back in the app's
/// own words, so the user sees that they were heard before they go in.
class OnboardingSummary extends StatelessWidget {
  const OnboardingSummary({required this.response, super.key});

  final OnboardingResponse response;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionEyebrow(label: context.tr('onboarding.summary.eyebrow')),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.tr('onboarding.summary.title'),
          style: AppTypography.displayMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        AnimatedReveal(
          index: 0,
          child: _entry(
            context,
            context.tr('onboarding.summary.wants'),
            OnboardingResponse.textFor(response.ambition, context.localeCode),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedReveal(
          index: 1,
          child: _entry(
            context,
            context.tr('onboarding.summary.focus'),
            _joined(context, response.focusAreaKeys),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedReveal(
          index: 2,
          child: _entry(
            context,
            context.tr('onboarding.summary.challenge'),
            OnboardingResponse.textFor(response.challenge, context.localeCode),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedReveal(
          index: 3,
          child: _entry(
            context,
            context.tr('onboarding.summary.priorities'),
            _joined(context, response.priorityKeys),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedReveal(
          index: 4,
          child: _entry(
            context,
            context.tr('onboarding.summary.success'),
            OnboardingResponse.textFor(
              response.successVision,
              context.localeCode,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AnimatedReveal(
          index: 5,
          child: Text(
            context.tr('onboarding.summary.closing'),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
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
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _joined(BuildContext context, List<String> keys) {
    return keys.map(context.tr).join('  ·  ');
  }
}

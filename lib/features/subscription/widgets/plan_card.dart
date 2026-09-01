import 'package:flutter/material.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/cards/glow_card.dart';
import '../../../core/widgets/cards/gradient_border_card.dart';
import '../../../core/widgets/section_eyebrow.dart';
import '../../../data/models/subscription_plan.dart';

/// One plan tier.
///
/// The tier matching the activity chosen at registration is the only card on
/// the screen that carries a gradient edge and the filled action, which is
/// what marks it out. There is no best-value flag any more: the two monthly
/// rates are for different people, not different amounts of the same thing.
class PlanCard extends StatelessWidget {
  const PlanCard({
    required this.plan,
    required this.isCurrent,
    required this.onSelect,
    this.highlighted = false,
    super.key,
  });

  final SubscriptionPlan plan;
  final bool isCurrent;
  final VoidCallback onSelect;

  /// True for the tier the user's registered activity puts them on.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final Widget content = _content(context);

    if (highlighted) {
      return GradientBorderCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: content,
      );
    }
    return GlowCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: content,
    );
  }

  /// The filled gold action is reserved for the matching tier, so the three
  /// cards do not compete for the same attention.
  Widget _action(BuildContext context) {
    final String label =
        isCurrent
            ? context.tr('subscription.cta.current')
            : context.tr('subscription.cta.choose');
    if (highlighted) {
      return PrimaryButton(
        label: label,
        onPressed: isCurrent ? null : onSelect,
      );
    }
    return SecondaryButton(
      label: label,
      onPressed: isCurrent ? null : onSelect,
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                context.tr(plan.nameKey),
                style: AppTypography.titleLarge,
              ),
            ),
            if (highlighted)
              SectionEyebrow(label: context.tr('subscription.recommended')),
            if (isCurrent && !highlighted)
              SectionEyebrow(label: context.tr('subscription.current')),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Text(
              plan.price,
              style: AppTypography.metricValue.copyWith(color: AppColors.gold),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(context.tr(plan.periodKey), style: AppTypography.caption),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _action(context),
      ],
    );
  }
}

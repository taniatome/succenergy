import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/cards/glow_card.dart';
import '../../../core/widgets/section_eyebrow.dart';
import '../../../data/models/subscription_plan.dart';

/// Feature-by-feature comparison of the free and premium levels.
///
/// Premium is one column because the monthly and annual plans include exactly
/// the same thing; only the price differs.
class FeatureComparisonTable extends StatelessWidget {
  const FeatureComparisonTable({
    required this.featureKeys,
    required this.free,
    required this.premium,
    super.key,
  });

  final List<String> featureKeys;
  final SubscriptionPlan free;
  final SubscriptionPlan premium;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionEyebrow(
            label: context.tr('subscription.compare'),
            withRule: true,
          ),
          const SizedBox(height: AppSpacing.md),
          _headerRow(context),
          for (final String key in featureKeys) _row(context, key),
        ],
      ),
    );
  }

  Widget _headerRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: <Widget>[
          const Spacer(flex: 4),
          Expanded(
            flex: 3,
            child: Text(
              context.tr(free.nameKey).toUpperCase(),
              style: AppTypography.metricLabel,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 3,
            child: Text(
              context.tr('subscription.premiumColumn').toUpperCase(),
              style: AppTypography.metricLabel.copyWith(color: AppColors.gold),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String featureKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: <Widget>[
          Container(height: AppBorders.hairline, color: AppColors.hairline),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Text(
                  context.tr(featureKey),
                  style: AppTypography.bodyMedium,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  context.tr(free.featureValueKeys[featureKey] ?? featureKey),
                  style: AppTypography.caption,
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 3,
                child: Text(
                  context.tr(
                    premium.featureValueKeys[featureKey] ?? featureKey,
                  ),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

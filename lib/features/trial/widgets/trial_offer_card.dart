import 'package:flutter/widgets.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/cards/gradient_border_card.dart';
import '../../../core/widgets/section_eyebrow.dart';
import '../../../data/models/user.dart';

/// The offer itself: a dollar for seven days, and the one monthly rate that
/// follows it.
///
/// Only the rate the user's activity puts them on is shown. Both prices side
/// by side would turn the moment into a comparison, which is what the Plans
/// screen is for.
class TrialOfferCard extends StatelessWidget {
  const TrialOfferCard({required this.activity, super.key});

  final UserActivity activity;

  bool get _isStudent => activity == UserActivity.studentMinorities;

  String get monthlyPrice =>
      _isStudent
          ? AppConstants.studentMonthlyPrice
          : AppConstants.professionalMonthlyPrice;

  @override
  Widget build(BuildContext context) {
    return GradientBorderCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionEyebrow(label: context.tr('subscription.plan.trial')),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                AppConstants.trialPrice,
                style: AppTypography.displayLarge.copyWith(
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                context.tr('subscription.perTrial'),
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(height: AppBorders.hairline, color: AppColors.hairline),
          const SizedBox(height: AppSpacing.md),
          _afterTrial(context),
        ],
      ),
    );
  }

  Widget _afterTrial(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                context.tr('trial.after.label'),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Text(
              context.tr(
                'trial.after.value',
                params: <String, String>{'price': monthlyPrice},
              ),
              style: AppTypography.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          context.tr(
            _isStudent ? 'trial.after.student' : 'trial.after.professional',
          ),
          style: AppTypography.caption,
        ),
      ],
    );
  }
}

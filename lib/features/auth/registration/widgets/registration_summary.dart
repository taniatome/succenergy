import 'package:flutter/widgets.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/string_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/cards/glow_card.dart';
import '../../../../core/widgets/section_eyebrow.dart';
import '../../../../data/models/user.dart';

/// What the account is about to sign up for, shown before it is created.
///
/// The monthly rate that follows the trial is stated here, with the figure
/// that follows from the activity chosen at step two, so the paywall on the
/// next screen confirms a number the user has already seen rather than
/// producing one.
class RegistrationSummary extends StatelessWidget {
  const RegistrationSummary({required this.activity, super.key});

  final UserActivity activity;

  String get _monthlyPrice =>
      activity == UserActivity.studentMinorities
          ? AppConstants.studentMonthlyPrice
          : AppConstants.professionalMonthlyPrice;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: GlowAccent.gold,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionEyebrow(label: context.tr('auth.summary.eyebrow')),
          const SizedBox(height: AppSpacing.sm),
          _row(
            context,
            label: context.tr('auth.summary.trialLabel'),
            value: context.tr(
              'auth.summary.trialValue',
              params: <String, String>{
                'days': '${AppConstants.trialDays}',
                'price': AppConstants.trialPrice,
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _row(
            context,
            label: context.tr('auth.summary.monthlyLabel'),
            value: context.tr(
              'auth.summary.monthlyValue',
              params: <String, String>{'price': _monthlyPrice},
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.tr('auth.summary.cancel'),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          textAlign: TextAlign.right,
          style: AppTypography.titleMedium.copyWith(color: AppColors.gold),
        ),
      ],
    );
  }
}

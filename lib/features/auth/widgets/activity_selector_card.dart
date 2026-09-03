import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/motion/app_curves.dart';
import '../../../core/motion/app_durations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_eyebrow.dart';
import '../../../data/models/user.dart';

/// The activity choice, as two cards rather than a segmented control.
///
/// This is the answer that sets the monthly rate after the trial, so it is
/// given the room to say what each option means instead of being reduced to
/// two words in a toggle. The selected card takes the gold edge and the
/// resting bloom that mark a committed state everywhere else in the app.
class ActivitySelectorCard extends StatelessWidget {
  const ActivitySelectorCard({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Null until the user has chosen, so neither card starts out selected.
  final UserActivity? value;

  final ValueChanged<UserActivity> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionEyebrow(label: context.tr('auth.field.activity')),
        const SizedBox(height: AppSpacing.xs),
        _card(
          context,
          activity: UserActivity.studentMinorities,
          title: context.tr('auth.activity.student'),
          body: context.tr('auth.activity.student.detail'),
        ),
        const SizedBox(height: AppSpacing.sm),
        _card(
          context,
          activity: UserActivity.professional,
          title: context.tr('auth.activity.professional'),
          body: context.tr('auth.activity.professional.detail'),
        ),
      ],
    );
  }

  Widget _card(
    BuildContext context, {
    required UserActivity activity,
    required String title,
    required String body,
  }) {
    final bool selected = value == activity;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(activity),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.stateChange,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: AppGradients.card,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.hairline,
            width: selected ? AppBorders.emphasis : AppBorders.hairline,
          ),
          boxShadow: selected ? AppShadows.goldGlow : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                color: selected ? AppColors.gold : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              body,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

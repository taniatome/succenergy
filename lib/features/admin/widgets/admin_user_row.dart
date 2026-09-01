import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/subscription_plan.dart';
import '../../../data/models/user.dart';

/// One account in the management console list.
///
/// A table row rather than a card: the console trades the user app's
/// generosity for density.
class AdminUserRow extends StatelessWidget {
  const AdminUserRow({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.hairline,
            width: AppBorders.hairline,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(user.name, style: AppTypography.bodyMedium),
                Text(
                  user.email,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              context.tr(_planKey).toUpperCase(),
              style: AppTypography.metricLabel.copyWith(
                color:
                    user.tier == SubscriptionTier.trial
                        ? AppColors.textSecondary
                        : AppColors.gold,
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat.MMMd(context.localeCode).format(user.joinedAt),
              style: AppTypography.caption,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String get _planKey {
    switch (user.tier) {
      case SubscriptionTier.trial:
        return 'admin.users.planTrial';
      case SubscriptionTier.student:
        return 'admin.users.planStudent';
      case SubscriptionTier.professional:
        return 'admin.users.planProfessional';
    }
  }
}

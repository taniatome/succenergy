import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/cards/glow_card.dart';
import '../../../data/models/app_notification.dart';

/// One notification, with a type mark and an unread indicator.
class NotificationRow extends StatelessWidget {
  const NotificationRow({
    required this.notification,
    required this.onTap,
    super.key,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String locale = context.localeCode;
    final bool unread = !notification.isRead;

    return GlowCard(
      onTap: onTap,
      accent: unread ? GlowAccent.gold : GlowAccent.none,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _mark(unread),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        notification.titleFor(locale),
                        style: AppTypography.titleMedium.copyWith(
                          color:
                              unread
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat.MMMd(locale).format(notification.receivedAt),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  notification.bodyFor(locale),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mark(bool unread) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            unread
                ? AppColors.gold.withValues(alpha: 0.12)
                : AppColors.navyDeep.withValues(alpha: 0.6),
        border: Border.all(
          color: unread ? AppColors.goldHairline : AppColors.hairline,
          width: AppBorders.hairline,
        ),
      ),
      child: Icon(
        _icon,
        size: 17,
        color: unread ? AppColors.gold : AppColors.textSecondary,
      ),
    );
  }

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.goalNudge:
        return Icons.flag_outlined;
      case NotificationType.principleOfDay:
        return Icons.donut_large_outlined;
      case NotificationType.reengagement:
        return Icons.schedule_rounded;
      case NotificationType.exerciseReminder:
        return Icons.bolt_outlined;
      case NotificationType.milestone:
        return Icons.workspace_premium_outlined;
    }
  }
}

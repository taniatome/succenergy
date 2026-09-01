import 'package:flutter/material.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/section_eyebrow.dart';

/// The personalised greeting at the top of the Dashboard.
///
/// Picks the greeting from the time of day and states where the user is in
/// the current cycle. Carries the three chrome affordances — notifications,
/// profile and the kebab menu — the last being the app's only entrance to
/// Settings and, through it, to Subscription, Help and the admin console.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    required this.firstName,
    required this.cycleDay,
    required this.onNotifications,
    required this.onProfile,
    required this.onSettings,
    this.hasUnread = false,
    super.key,
  });

  final String firstName;
  final int cycleDay;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;
  final VoidCallback onSettings;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                context.tr(
                  _greetingKey(),
                  params: <String, String>{'name': firstName},
                ),
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.xxs),
              SectionEyebrow(
                label: context.tr(
                  'dashboard.greeting.sub',
                  params: <String, String>{'day': '$cycleDay'},
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _iconAction(
          mark: AppIconMark.chime,
          onTap: onNotifications,
          showDot: hasUnread,
        ),
        const SizedBox(width: AppSpacing.xs),
        _iconAction(mark: AppIconMark.person, onTap: onProfile),
        const SizedBox(width: AppSpacing.xs),
        _iconAction(mark: AppIconMark.kebab, onTap: onSettings),
      ],
    );
  }

  String _greetingKey() {
    final int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'dashboard.greeting.morning';
    }
    if (hour < 18) {
      return 'dashboard.greeting.afternoon';
    }
    return 'dashboard.greeting.evening';
  }

  Widget _iconAction({
    required AppIconMark mark,
    required VoidCallback onTap,
    bool showDot = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.navyElevated,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.hairline,
            width: AppBorders.hairline,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            AppIcon(mark: mark, color: AppColors.textSecondary, size: 19),
            if (showDot)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

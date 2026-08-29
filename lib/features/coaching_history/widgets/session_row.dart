import 'package:flutter/material.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/cards/glow_card.dart';
import '../../../core/widgets/principle_badge.dart';
import '../../../data/models/coaching_session.dart';

/// One past session: what it was about, which principle it served, how long
/// it ran and how many messages it took.
class SessionRow extends StatelessWidget {
  const SessionRow({required this.session, required this.onTap, super.key});

  final CoachingSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              PrincipleBadge(principle: session.principle),
              const Spacer(),
              Text(
                context.tr(
                  'history.duration',
                  params: <String, String>{
                    'minutes': '${session.durationMinutes}',
                  },
                ),
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            session.summaryFor(context.localeCode),
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Text(
                context.tr(
                  'history.messages',
                  params: <String, String>{'count': '${session.messageCount}'},
                ),
                style: AppTypography.caption,
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 15,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

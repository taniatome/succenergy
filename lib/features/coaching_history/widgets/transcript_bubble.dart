import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/chat_message.dart';

/// One line of a past transcript.
///
/// Quieter than the live conversation bubble: an archive is read rather than
/// spoken to, so the treatment is a labelled block instead of a chat bubble.
class TranscriptBubble extends StatelessWidget {
  const TranscriptBubble({
    required this.message,
    required this.localeCode,
    super.key,
  });

  final ChatMessage message;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final bool coach = message.isCoach;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: coach ? AppColors.blueHairline : AppColors.goldHairline,
            width: AppBorders.emphasis,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.tr(coach ? 'coach.title' : 'history.speaker.you'),
            style: AppTypography.metricLabel.copyWith(
              color: coach ? AppColors.aiBlue : AppColors.gold,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs + 2),
          Text(
            message.body(localeCode),
            style: AppTypography.bodyMedium.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}

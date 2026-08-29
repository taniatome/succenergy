import 'package:flutter/widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/branding/succenergy_logo.dart';
import '../../../data/models/chat_message.dart';

/// One message in the conversation.
///
/// The coach speaks from a navy card with a thin AI Blue edge; the user
/// speaks from a gold-tinted bubble on the right. The Succenergy mark appears
/// once per run of coach messages rather than on every bubble, which keeps a
/// long reply from reading as a stack of avatars.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    required this.localeCode,
    this.showAvatar = true,
    super.key,
  });

  final ChatMessage message;
  final String localeCode;

  /// False for a coach message that follows another coach message.
  final bool showAvatar;

  static const double _avatarSize = 26;

  @override
  Widget build(BuildContext context) {
    final bool coach = message.isCoach;

    return Row(
      mainAxisAlignment:
          coach ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (coach) ...<Widget>[
          SizedBox(
            width: _avatarSize,
            height: _avatarSize,
            child:
                showAvatar
                    ? const SuccenergyLogo(size: _avatarSize, bloom: false)
                    : null,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        Flexible(child: _bubble(coach)),
      ],
    );
  }

  Widget _bubble(bool coach) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color:
            coach
                ? AppColors.navyElevated
                : AppColors.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppRadii.card),
          topRight: const Radius.circular(AppRadii.card),
          bottomLeft: Radius.circular(coach ? AppSpacing.xxs : AppRadii.card),
          bottomRight: Radius.circular(coach ? AppRadii.card : AppSpacing.xxs),
        ),
        border: Border.all(
          color: coach ? AppColors.blueHairline : AppColors.goldHairline,
          width: AppBorders.hairline,
        ),
      ),
      child: Text(
        message.body(localeCode),
        style: AppTypography.bodyMedium.copyWith(height: 1.6),
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/cards/glow_card.dart';
import '../../../core/widgets/section_eyebrow.dart';

/// What the trial opens, as a short list.
///
/// Each line carries a small gold node rather than a tick glyph, which keeps
/// the list in the same drawn vocabulary as the cycle ring and the milestone
/// timeline.
class TrialUnlockList extends StatelessWidget {
  const TrialUnlockList({required this.unlockKeys, super.key});

  /// Localisation keys, in the order they are listed.
  final List<String> unlockKeys;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionEyebrow(
            label: context.tr('trial.unlock.title'),
            withRule: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final String key in unlockKeys) _row(context, key),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: AppSpacing.xs),
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(context.tr(key), style: AppTypography.bodyMedium),
          ),
        ],
      ),
    );
  }
}

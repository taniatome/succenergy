import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_eyebrow.dart';

/// Contextual openings offered when the coach is waiting on the user.
///
/// Scrolls horizontally so the row never wraps and never pushes the input bar
/// off the screen.
class SuggestedReplies extends StatelessWidget {
  const SuggestedReplies({
    required this.suggestionKeys,
    required this.onSelect,
    super.key,
  });

  final List<String> suggestionKeys;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: SectionEyebrow(
            label: context.tr('coach.suggested.eyebrow'),
            useAiAccent: true,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            itemCount: suggestionKeys.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (BuildContext context, int index) {
              final String text = context.tr(suggestionKeys[index]);
              return GestureDetector(
                onTap: () => onSelect(text),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.aiBlue.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(
                      color: AppColors.blueHairline,
                      width: AppBorders.hairline,
                    ),
                  ),
                  child: Text(
                    text,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.aiBlue,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/cards/gradient_border_card.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/section_eyebrow.dart';

/// The closing screen of a session: a reflection, then the suggested next
/// action, which can be added straight to a goal's plan.
class SessionCompleteView extends StatelessWidget {
  const SessionCompleteView({
    required this.reflection,
    required this.onReflectionChanged,
    required this.suggestedAction,
    required this.addLabel,
    required this.onAddToGoal,
    required this.added,
    super.key,
  });

  final TextEditingController reflection;
  final ValueChanged<String> onReflectionChanged;

  /// Already-resolved suggested action text for the active language.
  final String suggestedAction;

  /// Already-localised label naming the goal it would be added to.
  final String addLabel;

  final VoidCallback onAddToGoal;
  final bool added;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionEyebrow(label: context.tr('exercises.session.reflection')),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.tr('exercises.done.title'),
          style: AppTypography.headlineLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: reflection,
          hint: context.tr('exercises.session.reflectionHint'),
          minLines: 3,
          maxLines: 6,
          onChanged: onReflectionChanged,
        ),
        const SizedBox(height: AppSpacing.lg),
        GradientBorderCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SectionEyebrow(label: context.tr('exercises.done.suggested')),
              const SizedBox(height: AppSpacing.xs),
              Text(suggestedAction, style: AppTypography.titleMedium),
              const SizedBox(height: AppSpacing.md),
              if (added)
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        context.tr('exercises.done.added'),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                )
              else
                SecondaryButton(
                  label: addLabel,
                  icon: Icons.playlist_add_rounded,
                  onPressed: onAddToGoal,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

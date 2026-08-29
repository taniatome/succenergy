import 'package:flutter/material.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/cards/glow_card.dart';
import '../../../core/widgets/principle_badge.dart';
import '../../../data/models/exercise.dart';

/// One exercise in the library: principle, title, duration and whether the
/// user has already worked through it.
class ExerciseCard extends StatelessWidget {
  const ExerciseCard({required this.exercise, required this.onTap, super.key});

  final Exercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String locale = context.localeCode;

    return GlowCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              PrincipleBadge(principle: exercise.principle),
              const Spacer(),
              Text(
                context.tr(
                  'exercises.card.duration',
                  params: <String, String>{
                    'minutes': '${exercise.durationMinutes}',
                  },
                ),
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(exercise.titleFor(locale), style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            exercise.summaryFor(locale),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              if (exercise.isCompleted) ...<Widget>[
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 15,
                  color: AppColors.gold,
                ),
                const SizedBox(width: AppSpacing.xxs + 2),
                Text(
                  context.tr('exercises.card.completed'),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.gold,
                  ),
                ),
              ] else
                Text(
                  context.tr('exercises.card.start'),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color:
                    exercise.isCompleted
                        ? AppColors.gold
                        : AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

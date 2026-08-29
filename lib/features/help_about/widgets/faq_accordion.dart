import 'package:flutter/material.dart';

import '../../../core/motion/app_curves.dart';
import '../../../core/motion/app_durations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/cards/glow_card.dart';

/// One expandable question and answer.
class FaqAccordion extends StatefulWidget {
  const FaqAccordion({required this.question, required this.answer, super.key});

  final String question;
  final String answer;

  @override
  State<FaqAccordion> createState() => _FaqAccordionState();
}

class _FaqAccordionState extends State<FaqAccordion> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      onTap: () => setState(() => _open = !_open),
      accent: _open ? GlowAccent.gold : GlowAccent.none,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.question,
                  style: AppTypography.titleMedium.copyWith(
                    color: _open ? AppColors.gold : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: AppDurations.fast,
                curve: AppCurves.stateChange,
                child: Icon(
                  Icons.expand_more_rounded,
                  size: 20,
                  color: _open ? AppColors.gold : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                widget.answer,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            crossFadeState:
                _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: AppDurations.medium,
            sizeCurve: AppCurves.stateChange,
          ),
        ],
      ),
    );
  }
}

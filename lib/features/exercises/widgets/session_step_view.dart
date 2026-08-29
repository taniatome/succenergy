import 'package:flutter/widgets.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/string_extensions.dart';
import '../../../core/motion/app_curves.dart';
import '../../../core/motion/app_durations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/inputs/scale_input.dart';
import '../../../data/models/exercise_step.dart';

/// Renders one exercise step according to its declared type.
///
/// Everything here comes from the [ExerciseStep] model, so a new exercise is
/// content rather than code.
class SessionStepView extends StatefulWidget {
  const SessionStepView({
    required this.step,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final ExerciseStep step;

  /// The answer so far: free text, the chosen option, or a scale as text.
  final String value;

  final ValueChanged<String> onChanged;

  @override
  State<SessionStepView> createState() => _SessionStepViewState();
}

class _SessionStepViewState extends State<SessionStepView> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _text(Map<String, String> field) =>
      ExerciseStep.resolve(field, context.localeCode);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(_text(widget.step.prompt), style: AppTypography.headlineLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _text(widget.step.help),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _input(),
      ],
    );
  }

  Widget _input() {
    switch (widget.step.type) {
      case ExerciseStepType.freeText:
        return AppTextField(
          controller: _controller,
          hint: context.tr('exercises.session.answerHint'),
          minLines: 4,
          maxLines: 8,
          maxLength: AppConstants.maxFreeTextLength,
          onChanged: widget.onChanged,
        );
      case ExerciseStepType.singleChoice:
        return Column(
          children: <Widget>[
            for (final Map<String, String> option in widget.step.options)
              _choice(_text(option)),
          ],
        );
      case ExerciseStepType.scale:
        final double current = double.tryParse(widget.value) ?? 0.5;
        return ScaleInput(
          value: current,
          onChanged: (double v) => widget.onChanged(v.toStringAsFixed(2)),
          lowLabel:
              widget.step.scaleLowLabel.isEmpty
                  ? context.tr('exercises.scaleLow')
                  : _text(widget.step.scaleLowLabel),
          highLabel:
              widget.step.scaleHighLabel.isEmpty
                  ? context.tr('exercises.scaleHigh')
                  : _text(widget.step.scaleHighLabel),
        );
    }
  }

  Widget _choice(String label) {
    final bool selected = widget.value == label;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: GestureDetector(
        onTap: () => widget.onChanged(label),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.stateChange,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color:
                selected
                    ? AppColors.gold.withValues(alpha: 0.10)
                    : AppColors.navyElevated.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppRadii.input),
            border: Border.all(
              color: selected ? AppColors.gold : AppColors.hairline,
              width: selected ? AppBorders.emphasis : AppBorders.hairline,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.bodyLarge.copyWith(
              color: selected ? AppColors.gold : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/inputs/app_text_field.dart';

/// An assessment question answered in the user's own words.
class FreeTextQuestion extends StatefulWidget {
  const FreeTextQuestion({
    required this.title,
    required this.help,
    required this.hint,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String title;
  final String help;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<FreeTextQuestion> createState() => _FreeTextQuestionState();
}

class _FreeTextQuestionState extends State<FreeTextQuestion> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(widget.title, style: AppTypography.headlineLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          widget.help,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          controller: _controller,
          hint: widget.hint,
          minLines: 4,
          maxLines: 7,
          maxLength: AppConstants.maxFreeTextLength,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}

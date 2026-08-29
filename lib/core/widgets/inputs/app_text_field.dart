import 'package:flutter/material.dart';

import '../../motion/app_curves.dart';
import '../../motion/app_durations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../section_eyebrow.dart';

/// The app text field.
///
/// The active field carries a gold focus bloom, matching the focused border
/// in the theme. AI Blue is reserved for the coach's own composer, which
/// declares its own borders in `coach_input_bar.dart`.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscure = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;

  /// Rendered above the field as a letterspaced eyebrow, not a floating label.
  final String? label;

  final String? hint;
  final String? errorText;
  final bool obscure;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focus = FocusNode();
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null;
    final bool focused = _focus.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          SectionEyebrow(label: widget.label!),
          const SizedBox(height: AppSpacing.xs),
        ],
        AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.stateChange,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.input),
            boxShadow:
                focused && !hasError
                    ? AppShadows.goldGlow
                    : hasError
                    ? AppShadows.errorGlow
                    : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focus,
            autofocus: widget.autofocus,
            obscureText: widget.obscure && _obscured,
            minLines: widget.obscure ? 1 : widget.minLines,
            maxLines: widget.obscure ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            cursorColor: AppColors.gold,
            style: AppTypography.bodyLarge,
            decoration: InputDecoration(
              hintText: widget.hint,
              counterText: '',
              suffixIcon: widget.obscure ? _revealToggle() : null,
              errorText: null,
            ),
          ),
        ),
        if (hasError) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText!,
            style: AppTypography.caption.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _revealToggle() {
    return IconButton(
      onPressed: () => setState(() => _obscured = !_obscured),
      icon: Icon(
        _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 18,
        color: AppColors.textSecondary,
      ),
    );
  }
}

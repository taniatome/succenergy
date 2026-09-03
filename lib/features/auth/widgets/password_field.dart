import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/inputs/app_text_field.dart';

/// A password field with the reveal toggle drawn on the app's icon grid.
///
/// The eye is one of our own marks rather than Material's, because it sits
/// inside a field the brand has already claimed and a borrowed glyph reads as
/// a different app's control.
class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.controller,
    required this.label,
    this.errorText,
    this.isValid = false,
    this.hint,
    this.autofillHints,
    this.textInputAction,
    this.enabled = true,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.onFocusLost,
    super.key,
  });

  final TextEditingController controller;

  /// Already-localised eyebrow above the field.
  final String label;

  final String? errorText;
  final bool isValid;
  final String? hint;
  final List<String>? autofillHints;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFocusLost;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      errorText: widget.errorText,
      isValid: widget.isValid,
      obscure: _hidden,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onFocusLost: widget.onFocusLost,
      trailing: _toggle(),
    );
  }

  Widget _toggle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _hidden = !_hidden),
      child: Center(
        child: AppIcon(
          mark: _hidden ? AppIconMark.eyeClosed : AppIconMark.eye,
          color: AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}

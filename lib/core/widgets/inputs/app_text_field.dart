import 'package:flutter/material.dart';

import '../../motion/app_curves.dart';
import '../../motion/app_durations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../section_eyebrow.dart';
import 'inline_field_error.dart';

/// The app text field.
///
/// Three states, each carried by the border and the bloom rather than by an
/// icon: the active field glows gold, a rejected one glows in the error hue
/// instead of showing a bare red outline, and a field that has been checked
/// and passed settles onto a gold hairline after a brief flash. The flash is
/// what makes a corrected field feel accepted rather than merely no longer
/// complained about.
///
/// AI Blue is reserved for the coach's own composer, which declares its own
/// borders in `coach_input_bar.dart`.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.isValid = false,
    this.obscure = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.onFocusLost,
    this.autofocus = false,
    this.trailing,
    super.key,
  });

  final TextEditingController controller;

  /// Rendered above the field as a letterspaced eyebrow, not a floating label.
  final String? label;

  final String? hint;

  /// Already-localised validation message. Animates in and out beneath the
  /// field.
  final String? errorText;

  /// True once the value has been checked and passed. Draws the gold hairline.
  final bool isValid;

  final bool obscure;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  /// Autofill categories for the OS password manager, e.g.
  /// `[AutofillHints.email]`.
  final List<String>? autofillHints;

  /// False while an async action is in flight, so a form cannot be edited
  /// out from under the request it already sent.
  final bool enabled;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Called when focus leaves the field. This is what lets the confirmation
  /// password start checking itself only once the password above it is done.
  final VoidCallback? onFocusLost;

  final bool autofocus;

  /// Replaces the built-in reveal toggle.
  ///
  /// A field that supplies one owns the reveal state too, so [obscure] is read
  /// literally rather than combined with an internal flag.
  final Widget? trailing;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focus = FocusNode();
  bool _obscured = true;

  /// Set for one beat when the field first passes, so the border flashes gold
  /// before settling to the hairline.
  bool _flashing = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(AppTextField old) {
    super.didUpdateWidget(old);
    if (widget.isValid && !old.isValid) {
      _flash();
    }
  }

  void _onFocusChanged() {
    setState(() {});
    if (!_focus.hasFocus) {
      widget.onFocusLost?.call();
    }
  }

  Future<void> _flash() async {
    setState(() => _flashing = true);
    await Future<void>.delayed(AppDurations.fast);
    if (mounted) {
      setState(() => _flashing = false);
    }
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            boxShadow: _glow(),
          ),
          child: _field(),
        ),
        InlineFieldError(message: widget.errorText),
      ],
    );
  }

  /// Whether the text is currently masked.
  bool get _hidden =>
      widget.trailing != null ? widget.obscure : widget.obscure && _obscured;

  List<BoxShadow>? _glow() {
    if (widget.errorText != null) {
      return AppShadows.errorGlow;
    }
    if (_flashing) {
      return AppShadows.goldGlowStrong;
    }
    return _focus.hasFocus ? AppShadows.goldGlow : null;
  }

  Widget _field() {
    return TextField(
      controller: widget.controller,
      focusNode: _focus,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      obscureText: _hidden,
      minLines: _hidden ? 1 : widget.minLines,
      maxLines: _hidden ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      cursorColor: AppColors.gold,
      style: AppTypography.bodyLarge,
      decoration: InputDecoration(
        hintText: widget.hint,
        counterText: '',
        suffixIcon:
            widget.trailing ?? (widget.obscure ? _revealToggle() : null),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        errorText: null,
        // The theme covers the resting, focused and error borders. Only the
        // validated hairline is declared here, because it is the one state
        // the framework has no notion of.
        enabledBorder: _validatedBorder(),
      ),
    );
  }

  /// The gold hairline a checked-and-passed field settles onto, or null to let
  /// the theme's resting border stand.
  OutlineInputBorder? _validatedBorder() {
    if (!widget.isValid || widget.errorText != null) {
      return null;
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.input),
      borderSide: BorderSide(
        color: AppColors.goldHairline,
        width: AppBorders.hairline,
      ),
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

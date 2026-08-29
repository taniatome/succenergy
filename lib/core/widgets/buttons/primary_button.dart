import 'package:flutter/material.dart';

import '../../motion/app_curves.dart';
import '../../motion/app_durations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// The filled gold action button.
///
/// Used for the single most important action on a screen. Pressing scales it
/// down slightly and intensifies its bloom, so every tap feels physical.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isBusy = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Shows a progress indicator and blocks input while an action resolves.
  final bool isBusy;

  final bool expand;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isBusy;

  @override
  Widget build(BuildContext context) {
    final bool reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final double scale = _pressed && !reduced ? 0.97 : 1;

    return GestureDetector(
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
      onTap: _enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: scale,
        duration: AppDurations.instant,
        curve: AppCurves.stateChange,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.stateChange,
          width: widget.expand ? double.infinity : null,
          height: 54,
          padding: EdgeInsets.symmetric(
            horizontal: widget.expand ? AppSpacing.lg : AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color:
                _enabled
                    ? AppColors.gold
                    : AppColors.textPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow:
                !_enabled
                    ? null
                    : _pressed
                    ? AppShadows.goldGlowStrong
                    : AppShadows.goldGlow,
          ),
          child: Center(child: _content()),
        ),
      ),
    );
  }

  Widget _content() {
    final Color fg = _enabled ? AppColors.navyDeep : AppColors.textSecondary;
    if (widget.isBusy) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: fg),
      );
    }
    final Text text = Text(
      widget.label,
      style: AppTypography.label.copyWith(color: fg),
      textAlign: TextAlign.center,
    );
    if (widget.icon == null) {
      return text;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(widget.icon, size: 18, color: fg),
        const SizedBox(width: AppSpacing.sm),
        Flexible(child: text),
      ],
    );
  }
}

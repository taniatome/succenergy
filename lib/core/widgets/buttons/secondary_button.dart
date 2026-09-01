import 'package:flutter/material.dart';

import '../../motion/app_curves.dart';
import '../../motion/app_durations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// The glowing outline action button.
///
/// Sits beneath the filled gold action at the same width and height, so the
/// two read as one pair. [useAiAccent] switches the outline and bloom to AI
/// Blue, and is reserved for actions that open or continue the AI Coach.
class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.emphasis,
    this.icon,
    this.useAiAccent = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  /// A substring of [label] rendered in the accent colour. Used for the word
  /// the client wants carried in gold on the Welcome screen.
  final String? emphasis;

  final IconData? icon;
  final bool useAiAccent;
  final bool expand;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  Color get _accent => widget.useAiAccent ? AppColors.aiBlue : AppColors.gold;

  @override
  Widget build(BuildContext context) {
    final bool reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final List<BoxShadow> glow =
        widget.useAiAccent
            ? (_pressed ? AppShadows.blueGlowStrong : AppShadows.blueGlow)
            : (_pressed ? AppShadows.goldGlowStrong : AppShadows.goldGlow);

    return GestureDetector(
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed && !reduced ? 0.97 : 1,
        duration: AppDurations.instant,
        curve: AppCurves.stateChange,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.stateChange,
          width: widget.expand ? double.infinity : null,
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.navyDeep.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color:
                  _enabled
                      ? _accent.withValues(alpha: _pressed ? 0.9 : 0.6)
                      : AppColors.hairline,
              width: AppBorders.emphasis,
            ),
            boxShadow: _enabled ? glow : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (widget.icon != null) ...<Widget>[
                Icon(widget.icon, size: 18, color: _accent),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(child: _label()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label() {
    final TextStyle base = AppTypography.label.copyWith(
      color: _enabled ? AppColors.textPrimary : AppColors.textSecondary,
    );
    final String? emphasis = widget.emphasis;
    if (emphasis == null || !widget.label.contains(emphasis)) {
      return Text(widget.label, style: base, textAlign: TextAlign.center);
    }
    final int start = widget.label.indexOf(emphasis);
    return Text.rich(
      TextSpan(
        style: base,
        children: <TextSpan>[
          TextSpan(text: widget.label.substring(0, start)),
          TextSpan(
            text: emphasis,
            style: base.copyWith(color: _accent, fontWeight: FontWeight.w700),
          ),
          TextSpan(text: widget.label.substring(start + emphasis.length)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

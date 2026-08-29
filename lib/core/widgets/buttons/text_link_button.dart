import 'package:flutter/material.dart';

import '../../motion/app_curves.dart';
import '../../motion/app_durations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// The quiet text link.
///
/// Sits beneath a primary action where a second route exists but should not
/// compete for attention.
class TextLinkButton extends StatefulWidget {
  const TextLinkButton({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Renders in the single error hue. Used only for account deletion.
  final bool isDestructive;

  @override
  State<TextLinkButton> createState() => _TextLinkButtonState();
}

class _TextLinkButtonState extends State<TextLinkButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final Color color =
        widget.isDestructive ? AppColors.error : AppColors.textSecondary;
    final Color active =
        widget.isDestructive ? AppColors.error : AppColors.gold;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: AnimatedDefaultTextStyle(
          duration: AppDurations.fast,
          curve: AppCurves.stateChange,
          style: AppTypography.labelSmall.copyWith(
            color: _pressed ? active : color,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

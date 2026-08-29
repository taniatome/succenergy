import 'package:flutter/material.dart';

import '../../motion/app_curves.dart';
import '../../motion/app_durations.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import 'glow_card.dart';

/// A card whose edge is a gradient fading from the accent to nothing.
///
/// Reserved for the single most important card on a screen: the active goal
/// on the Dashboard, the annual plan on Plans. More than one on a screen and
/// the emphasis stops meaning anything.
class GradientBorderCard extends StatefulWidget {
  const GradientBorderCard({
    required this.child,
    this.accent = GlowAccent.gold,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadii.cardLarge,
    super.key,
  });

  final Widget child;
  final GlowAccent accent;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double radius;

  @override
  State<GradientBorderCard> createState() => _GradientBorderCardState();
}

class _GradientBorderCardState extends State<GradientBorderCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final Widget card = AnimatedContainer(
      duration: AppDurations.fast,
      curve: AppCurves.stateChange,
      padding: const EdgeInsets.all(AppBorders.emphasis),
      decoration: BoxDecoration(
        gradient:
            widget.accent == GlowAccent.ai
                ? AppGradients.blueEdge
                : AppGradients.goldEdge,
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: _glow,
      ),
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          gradient: AppGradients.card,
          borderRadius: BorderRadius.circular(
            widget.radius - AppBorders.emphasis,
          ),
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap == null) {
      return card;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed && !reduced ? 0.985 : 1,
        duration: AppDurations.instant,
        curve: AppCurves.stateChange,
        child: card,
      ),
    );
  }

  List<BoxShadow> get _glow {
    if (widget.accent == GlowAccent.ai) {
      return _pressed ? AppShadows.blueGlowStrong : AppShadows.blueGlow;
    }
    return _pressed ? AppShadows.goldGlowStrong : AppShadows.goldGlow;
  }
}

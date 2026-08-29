import 'package:flutter/material.dart';

import '../../motion/app_curves.dart';
import '../../motion/app_durations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

/// The standard elevated surface.
///
/// Elevation reads as a soft bloom rather than a black shadow. [accent]
/// picks which bloom, and a card carries at most one: gold for Succenergy and
/// achievement, AI Blue for the coach.
enum GlowAccent { none, gold, ai }

/// A navy card with a hairline border and an optional coloured bloom.
class GlowCard extends StatefulWidget {
  const GlowCard({
    required this.child,
    this.accent = GlowAccent.none,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadii.card,
    super.key,
  });

  final Widget child;
  final GlowAccent accent;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double radius;

  @override
  State<GlowCard> createState() => _GlowCardState();
}

class _GlowCardState extends State<GlowCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final bool interactive = widget.onTap != null;

    final Widget card = AnimatedContainer(
      duration: AppDurations.fast,
      curve: AppCurves.stateChange,
      padding: widget.padding,
      decoration: BoxDecoration(
        gradient: AppGradients.card,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: _border, width: AppBorders.hairline),
        boxShadow: _glow,
      ),
      child: widget.child,
    );

    if (!interactive) {
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

  Color get _border {
    switch (widget.accent) {
      case GlowAccent.gold:
        return AppColors.goldHairline;
      case GlowAccent.ai:
        return AppColors.blueHairline;
      case GlowAccent.none:
        return AppColors.hairline;
    }
  }

  List<BoxShadow> get _glow {
    switch (widget.accent) {
      case GlowAccent.gold:
        return _pressed ? AppShadows.goldGlowStrong : AppShadows.goldGlow;
      case GlowAccent.ai:
        return _pressed ? AppShadows.blueGlowStrong : AppShadows.blueGlow;
      case GlowAccent.none:
        return AppShadows.elevation;
    }
  }
}

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
///
/// [emphasis] holds one word of the label at a heavier weight, which is how
/// the Welcome call to action keeps its stressed word now that the button
/// itself is gold.
///
/// While [isBusy] the whole button breathes rather than only showing a
/// spinner: a form waiting on the network should look like it is working, and
/// a static button with a ring in it looks like it is stuck.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.emphasis,
    this.icon,
    this.isBusy = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  /// A substring of [label] carried at heavier weight. Used for the word the
  /// client wants held out on the Welcome call to action, which cannot be
  /// picked out in gold here because the fill already is.
  final String? emphasis;

  final IconData? icon;

  /// Shows a progress indicator and blocks input while an action resolves.
  final bool isBusy;

  final bool expand;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  /// The busy breath. Runs only while an action is in flight.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppDurations.pulse ~/ 2,
  );

  bool get _enabled => widget.onPressed != null && !widget.isBusy;

  @override
  void didUpdateWidget(PrimaryButton old) {
    super.didUpdateWidget(old);
    if (widget.isBusy == old.isBusy) {
      return;
    }
    if (widget.isBusy) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.isBusy && !reduced) {
      return AnimatedBuilder(
        animation: _pulse,
        builder: (BuildContext context, Widget? child) {
          final double t = AppCurves.ambient.transform(_pulse.value);
          return Transform.scale(scale: 1 - 0.02 * t, child: child);
        },
        child: _body(reduced: reduced),
      );
    }
    return _body(reduced: reduced);
  }

  Widget _body({required bool reduced}) {
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
    final Widget text = _label(fg);
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

  /// The label, with [PrimaryButton.emphasis] held at a heavier weight.
  Widget _label(Color fg) {
    final TextStyle base = AppTypography.label.copyWith(color: fg);
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
            style: base.copyWith(fontWeight: FontWeight.w800),
          ),
          TextSpan(text: widget.label.substring(start + emphasis.length)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

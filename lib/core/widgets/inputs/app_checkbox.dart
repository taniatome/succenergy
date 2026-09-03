import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../motion/app_curves.dart';
import '../../motion/app_durations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'tick_painter.dart';

/// A consent checkbox with its statement beside it.
///
/// The box is drawn rather than taken from Material: ticked, it fills gold and
/// carries the same resting bloom as every other committed state in the app,
/// and the tick draws itself on rather than appearing, which is what makes
/// agreeing to something feel like an act.
///
/// The whole row is the target, so the statement is as tappable as the box —
/// except for [linkLabel], which opens the document instead of ticking.
class AppCheckbox extends StatefulWidget {
  const AppCheckbox({
    required this.value,
    required this.label,
    required this.onChanged,
    this.linkLabel,
    this.onLinkTap,
    super.key,
  });

  final bool value;

  /// Already-localised statement the user is agreeing to.
  final String label;

  final ValueChanged<bool> onChanged;

  /// A substring of [label] rendered in gold and tapped to open a document.
  /// Ignored when it does not appear in [label].
  final String? linkLabel;

  final VoidCallback? onLinkTap;

  @override
  State<AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<AppCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tick = AnimationController(
    vsync: this,
    duration: AppDurations.tickDraw,
    value: widget.value ? 1 : 0,
  );

  final TapGestureRecognizer _link = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _link.onTap = () => widget.onLinkTap?.call();
  }

  @override
  void didUpdateWidget(AppCheckbox old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      if (widget.value) {
        _tick.forward();
      } else {
        _tick.reverse();
      }
    }
  }

  @override
  void dispose() {
    _tick.dispose();
    _link.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onChanged(!widget.value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _box(),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _statement()),
          ],
        ),
      ),
    );
  }

  Widget _box() {
    return AnimatedContainer(
      duration: AppDurations.fast,
      curve: AppCurves.stateChange,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color:
            widget.value
                ? AppColors.gold
                : AppColors.navyDeep.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadii.input * 0.5),
        border: Border.all(
          color: widget.value ? AppColors.gold : AppColors.hairline,
          width: widget.value ? AppBorders.emphasis : AppBorders.hairline,
        ),
        boxShadow: widget.value ? AppShadows.goldGlow : null,
      ),
      child: AnimatedBuilder(
        animation: _tick,
        builder:
            (BuildContext context, Widget? child) => CustomPaint(
              painter: TickPainter(
                progress: AppCurves.entrance.transform(_tick.value),
                color: AppColors.navyDeep,
              ),
            ),
      ),
    );
  }

  /// The statement, with [AppCheckbox.linkLabel] held out in gold.
  Widget _statement() {
    final TextStyle base = AppTypography.bodyMedium.copyWith(
      color: widget.value ? AppColors.textPrimary : AppColors.textSecondary,
    );
    final String? link = widget.linkLabel;
    if (link == null || !widget.label.contains(link)) {
      return Text(widget.label, style: base);
    }

    final int start = widget.label.indexOf(link);
    return Text.rich(
      TextSpan(
        style: base,
        children: <InlineSpan>[
          TextSpan(text: widget.label.substring(0, start)),
          TextSpan(
            text: link,
            style: base.copyWith(color: AppColors.gold),
            recognizer: _link,
          ),
          TextSpan(text: widget.label.substring(start + link.length)),
        ],
      ),
    );
  }
}

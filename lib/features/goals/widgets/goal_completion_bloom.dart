import 'package:flutter/widgets.dart';

import '../../../core/motion/app_curves.dart';
import '../../../core/motion/app_durations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';

/// The moment a goal closes.
///
/// Wraps the progress ring on Goal Detail. When [completed] turns true a gold
/// bloom expands outward from behind the ring and settles, while the ring
/// itself fills to full and stays there. One gesture, roughly three quarters
/// of a second, on the celebrate curve.
///
/// There is nothing to dismiss and nothing to click through: the bloom plays
/// once and the screen is where it was. Reduced motion skips straight to the
/// settled state.
class GoalCompletionBloom extends StatefulWidget {
  const GoalCompletionBloom({
    required this.completed,
    required this.child,
    super.key,
  });

  /// Whether the goal is closed. The bloom plays on the false-to-true edge.
  final bool completed;

  /// The progress ring the bloom radiates from.
  final Widget child;

  @override
  State<GoalCompletionBloom> createState() => _GoalCompletionBloomState();
}

class _GoalCompletionBloomState extends State<GoalCompletionBloom>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.goalCompletion,
  );

  late final Animation<double> _bloom = CurvedAnimation(
    parent: _controller,
    curve: AppCurves.celebrate,
  );

  @override
  void didUpdateWidget(GoalCompletionBloom old) {
    super.didUpdateWidget(old);
    if (old.completed || !widget.completed) {
      return;
    }
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.value = 1;
      return;
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bloom,
      builder: (BuildContext context, Widget? child) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: <Widget>[
            if (_controller.isAnimating) _wave(),
            _settledRing(child),
          ],
        );
      },
      child: widget.child,
    );
  }

  /// The expanding ring of light. Overflows its bounds so the ring keeps a
  /// tight layout box and nothing below it shifts while the bloom plays.
  Widget _wave() {
    final double t = _bloom.value;
    return Positioned.fill(
      child: IgnorePointer(
        child: OverflowBox(
          maxWidth: 240,
          maxHeight: 240,
          child: Opacity(
            opacity: (1 - t) * 0.75,
            child: Transform.scale(
              scale: 0.55 + t * 1.65,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      AppColors.transparent,
                      AppColors.gold.withValues(alpha: 0.34),
                      AppColors.transparent,
                    ],
                    stops: const <double>[0.42, 0.74, 1],
                  ),
                ),
                child: const SizedBox(width: 240, height: 240),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The ring itself, carrying the strong gold bloom at the peak of the
  /// moment and easing back to the resting glow.
  Widget _settledRing(Widget? child) {
    if (!widget.completed) {
      return child ?? const SizedBox.shrink();
    }
    final double t = _bloom.value;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: t < 1 ? AppShadows.goldGlowStrong : AppShadows.goldGlow,
      ),
      child: child,
    );
  }
}

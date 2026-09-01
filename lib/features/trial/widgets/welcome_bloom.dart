import 'package:flutter/widgets.dart';

import '../../../core/motion/app_curves.dart';
import '../../../core/motion/app_durations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';

/// The celebration beat when the trial is taken.
///
/// The same gesture as the goal-completion bloom: one ring of gold light
/// expands from behind the mark and settles, roughly three quarters of a
/// second, on the celebrate curve. It plays once on entry, there is nothing to
/// dismiss inside it, and reduced motion goes straight to the settled state.
class WelcomeBloom extends StatefulWidget {
  const WelcomeBloom({required this.child, this.size = 260, super.key});

  /// The mark the light radiates from.
  final Widget child;

  /// Diameter the bloom expands to.
  final double size;

  @override
  State<WelcomeBloom> createState() => _WelcomeBloomState();
}

class _WelcomeBloomState extends State<WelcomeBloom>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.goalCompletion,
  );
  late final Animation<double> _bloom = CurvedAnimation(
    parent: _controller,
    curve: AppCurves.celebrate,
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.value = 1;
      return;
    }
    _controller.forward();
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
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow:
                    _controller.value < 1
                        ? AppShadows.goldGlowStrong
                        : AppShadows.goldGlow,
              ),
              child: child,
            ),
          ],
        );
      },
      child: widget.child,
    );
  }

  /// The expanding ring of light, overflowing its bounds so nothing below it
  /// shifts while the bloom plays.
  Widget _wave() {
    final double t = _bloom.value;
    return Positioned.fill(
      child: IgnorePointer(
        child: OverflowBox(
          maxWidth: widget.size,
          maxHeight: widget.size,
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
                child: SizedBox(width: widget.size, height: widget.size),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

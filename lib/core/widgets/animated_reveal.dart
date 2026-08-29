import 'package:flutter/widgets.dart';

import '../motion/app_curves.dart';
import '../motion/app_durations.dart';

/// Fades and lifts a child into place after a delay.
///
/// Used to stagger the Dashboard and other list entrances: siblings are given
/// increasing [index] values and arrive roughly 60ms apart. Honours the
/// platform reduced-motion setting by rendering immediately.
class AnimatedReveal extends StatefulWidget {
  const AnimatedReveal({
    required this.child,
    this.index = 0,
    this.offset = 18,
    super.key,
  });

  final Widget child;

  /// Position in the stagger sequence.
  final int index;

  /// Distance in logical pixels the child rises through.
  final double offset;

  @override
  State<AnimatedReveal> createState() => _AnimatedRevealState();
}

class _AnimatedRevealState extends State<AnimatedReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.slow,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: AppCurves.entrance,
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
    Future<void>.delayed(AppDurations.stagger * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: _curve.value,
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - _curve.value)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

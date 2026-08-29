import 'package:flutter/widgets.dart';

import '../../constants/app_constants.dart';
import '../../motion/app_curves.dart';
import '../../motion/app_durations.dart';
import 'cycle_ring_painter.dart';

/// The Seven Principles rendered as a ring, showing where the user sits in
/// the coaching cycle.
///
/// Anchors the Dashboard at full size and appears compact on Progress. Arcs
/// draw in on load and the active segment pulses continuously, unless the
/// platform asks for reduced motion.
class CycleRing extends StatefulWidget {
  const CycleRing({
    required this.activeIndex,
    required this.completedCount,
    this.size = 220,
    this.strokeWidth = 9,
    this.child,
    super.key,
  });

  /// Index of the principle currently being worked, or -1 when none is.
  final int activeIndex;

  /// Number of principles closed in this cycle.
  final int completedCount;

  final double size;
  final double strokeWidth;

  /// Content placed at the centre of the ring.
  final Widget? child;

  @override
  State<CycleRing> createState() => _CycleRingState();
}

class _CycleRingState extends State<CycleRing> with TickerProviderStateMixin {
  late final AnimationController _draw = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppDurations.pulse,
  );

  late final Animation<double> _drawCurve = CurvedAnimation(
    parent: _draw,
    curve: AppCurves.entrance,
  );
  late final Animation<double> _pulseCurve = CurvedAnimation(
    parent: _pulse,
    curve: AppCurves.ambient,
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
      _draw.value = 1;
      _pulse.value = 0.5;
      return;
    }
    _draw.forward();
    _pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _draw.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_drawCurve, _pulseCurve]),
        builder: (BuildContext context, Widget? child) {
          return CustomPaint(
            painter: CycleRingPainter(
              segmentCount: AppConstants.principleCount,
              completedCount: widget.completedCount,
              activeIndex: widget.activeIndex,
              drawProgress: _drawCurve.value,
              pulse: _pulseCurve.value,
              strokeWidth: widget.strokeWidth,
            ),
            child: child,
          );
        },
        child: widget.child == null ? null : Center(child: widget.child),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../constants/app_constants.dart';
import '../motion/app_durations.dart';
import '../theme/app_colors.dart';

/// The app's waiting state.
///
/// Seven segments in a ring, carrying a highlight that travels around them:
/// the Cycle Ring reduced to the one thing a loading state has to say. It is
/// deliberately quiet — this is a wait, not a feature — and it holds still
/// under reduced motion rather than stopping mid-turn.
class AppLoader extends StatefulWidget {
  const AppLoader({this.size = 34, this.useAiAccent = false, super.key});

  final double size;

  /// Renders in AI Blue. Only where the wait belongs to the coach.
  final bool useAiAccent;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.loaderTurn,
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
      _controller.value = 0;
      return;
    }
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return CustomPaint(
            painter: _LoaderPainter(
              phase: _controller.value,
              still: still,
              accent: widget.useAiAccent ? AppColors.aiBlue : AppColors.gold,
            ),
          );
        },
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  const _LoaderPainter({
    required this.phase,
    required this.still,
    required this.accent,
  });

  /// 0 to 1 position of the travelling highlight.
  final double phase;

  /// True under reduced motion: every segment sits at one settled weight.
  final bool still;

  final Color accent;

  static const int _segments = AppConstants.principleCount;
  static const double _gapDegrees = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = size.width * 0.11;
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (math.min(size.width, size.height) - stroke) / 2,
    );

    final double gap = _gapDegrees * math.pi / 180;
    final double sweep = (2 * math.pi - gap * _segments) / _segments;
    final double start = -math.pi / 2 + gap / 2;

    for (int i = 0; i < _segments; i++) {
      canvas.drawArc(
        rect,
        start + i * (sweep + gap),
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = accent.withValues(alpha: _alphaFor(i)),
      );
    }
  }

  /// Segments brighten as the highlight reaches them and fade behind it.
  double _alphaFor(int index) {
    if (still) {
      return 0.5;
    }
    double distance = (index / _segments) - phase;
    distance -= distance.floorToDouble();
    return 0.14 + 0.76 * math.pow(1 - distance, 3).toDouble();
  }

  @override
  bool shouldRepaint(_LoaderPainter old) =>
      old.phase != phase || old.accent != accent || old.still != still;
}

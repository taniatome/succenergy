import 'package:flutter/widgets.dart';

import '../../../core/motion/app_curves.dart';
import '../../../core/motion/app_durations.dart';
import '../../../core/theme/app_colors.dart';

/// The confirmation mark on the password-reset screen: an envelope with a gold
/// bloom behind it.
///
/// Drawn rather than taken from an icon set, and given the same treatment as
/// the brand symbol on the splash — a radial bloom expanding behind a stroked
/// mark that resolves into it. A stock mail glyph on this screen would be the
/// one moment in the flow that came from somewhere else.
class EnvelopeBloom extends StatefulWidget {
  const EnvelopeBloom({this.size = 96, super.key});

  final double size;

  @override
  State<EnvelopeBloom> createState() => _EnvelopeBloomState();
}

class _EnvelopeBloomState extends State<EnvelopeBloom>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.slow,
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
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return CustomPaint(
            painter: _EnvelopePainter(
              progress: AppCurves.entrance.transform(_controller.value),
            ),
          );
        },
      ),
    );
  }
}

class _EnvelopePainter extends CustomPainter {
  const _EnvelopePainter({required this.progress});

  final double progress;

  /// The design grid the mark is drawn on, matching the app's icon set.
  static const double _grid = 24;

  @override
  void paint(Canvas canvas, Size size) {
    _bloom(canvas, size);

    final double u = size.width / _grid;
    final Paint stroke =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4 * u
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = AppColors.gold.withValues(alpha: progress);

    final Rect body = Rect.fromLTRB(4 * u, 7 * u, 20 * u, 18 * u);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(1.6 * u)),
      stroke,
    );

    // The flap, opened: the line the letter came out of.
    canvas.drawPath(
      Path()
        ..moveTo(4 * u, 8.4 * u)
        ..lineTo(12 * u, 14 * u)
        ..lineTo(20 * u, 8.4 * u),
      stroke,
    );
  }

  /// The bloom expands from a point as the mark resolves, so the panel arrives
  /// rather than appearing.
  void _bloom(Canvas canvas, Size size) {
    final double radius = size.width * (0.32 + 0.28 * progress);
    canvas.drawCircle(
      size.center(Offset.zero),
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            AppColors.gold.withValues(alpha: 0.26 * progress),
            AppColors.gold.withValues(alpha: 0.08 * progress),
            AppColors.transparent,
          ],
          stops: const <double>[0, 0.45, 1],
        ).createShader(
          Rect.fromCircle(center: size.center(Offset.zero), radius: radius),
        ),
    );
  }

  @override
  bool shouldRepaint(_EnvelopePainter old) => old.progress != progress;
}

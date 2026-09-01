import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../../core/theme/app_colors.dart';

/// Paints the lit curve of the Earth across the bottom of the Welcome screen,
/// and the sky above it.
///
/// Built from gradients and arcs rather than a bitmap, so it scales to any
/// device without a seam. The atmosphere rim carries the technology halo that
/// sits beneath the AI COACH lockup, the surface lights are gold, and the
/// light breaking over the curve is the app's own off-white. The sky above it
/// is painted by `StarfieldPainter`.
///
/// Depth comes from four passes over the same circle — a wide outer haze, a
/// tighter halo, the hard rim, and a wrap of light clipped inside the body —
/// which is what stops the horizon reading as a flat arc with a stroke on it.
class EarthGlowPainter extends CustomPainter {
  const EarthGlowPainter({required this.reveal, this.drift = 0});

  /// 0 to 1 entrance, used to bring the horizon up on first paint.
  final double reveal;

  /// 0 to 1 position in the ambient cycle. Moves the sunrise bloom a fraction
  /// of the screen width and breathes its intensity; one full cycle runs on
  /// the app's ambient drift duration.
  final double drift;

  /// Share of the screen height the curve rises to. Screens that sit above
  /// the horizon read this so their content clears it.
  static const double horizonFraction = 0.26;

  @override
  void paint(Canvas canvas, Size size) {
    final double visible = size.height * horizonFraction * reveal;
    if (visible <= 0) {
      return;
    }
    final double radius = size.width * 1.05;
    final Offset center = Offset(
      size.width / 2,
      size.height + radius - visible,
    );
    final Rect circle = Rect.fromCircle(center: center, radius: radius);
    final double horizonY = size.height - visible;

    _paintBody(canvas, circle, center, radius);
    _paintSurfaceLights(canvas, center, radius, size, horizonY);
    _paintAtmosphere(canvas, circle);
    _paintLightWrap(canvas, circle, center, radius, size);
    _paintFlare(canvas, center, radius, size);
  }

  void _paintBody(Canvas canvas, Rect circle, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            AppColors.navyElevated,
            AppColors.deepNavy,
            AppColors.navyDeep,
            AppColors.navyDeep,
          ],
          stops: const <double>[0.9, 0.962, 0.99, 1],
        ).createShader(circle),
    );
  }

  /// Outer haze, tighter halo, then the rim itself.
  void _paintAtmosphere(Canvas canvas, Rect circle) {
    void arc(double width, double blur, double alpha) {
      canvas.drawArc(
        circle,
        math.pi,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..color = AppColors.aiBlue.withValues(alpha: alpha * reveal)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
      );
    }

    arc(52, 44, 0.09);
    arc(24, 20, 0.16);

    final Paint rim =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..shader = LinearGradient(
            colors: <Color>[
              AppColors.aiBlue.withValues(alpha: 0.08 * reveal),
              AppColors.aiBlue.withValues(alpha: 0.92 * reveal),
              AppColors.aiBlue.withValues(alpha: 0.08 * reveal),
            ],
          ).createShader(circle);
    canvas.drawArc(circle, math.pi, math.pi, false, rim);
  }

  /// Light falling inside the body from the horizon's peak.
  ///
  /// Clipped to the circle, so it fades along the curve rather than across a
  /// straight edge. This is the pass that makes the horizon read as light
  /// wrapping a sphere.
  void _paintLightWrap(
    Canvas canvas,
    Rect circle,
    Offset center,
    double radius,
    Size size,
  ) {
    final Offset apex = Offset(center.dx, center.dy - radius);
    final double span = size.width * 0.58;
    canvas.save();
    canvas.clipPath(Path()..addOval(circle));
    canvas.drawCircle(
      apex,
      span,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            AppColors.aiBlue.withValues(alpha: 0.30 * reveal),
            AppColors.aiBlue.withValues(alpha: 0.06 * reveal),
            AppColors.transparent,
          ],
          stops: const <double>[0, 0.30, 1],
        ).createShader(Rect.fromCircle(center: apex, radius: span)),
    );
    canvas.restore();
  }

  void _paintSurfaceLights(
    Canvas canvas,
    Offset center,
    double radius,
    Size size,
    double horizonY,
  ) {
    final math.Random random = math.Random(7);
    final Paint light = Paint()..color = AppColors.gold;
    for (int i = 0; i < 90; i++) {
      final double angle = math.pi + random.nextDouble() * math.pi;
      final double depth = radius * (0.9955 - random.nextDouble() * 0.02);
      final Offset point = Offset(
        center.dx + depth * math.cos(angle),
        center.dy + depth * math.sin(angle),
      );
      if (point.dy > size.height || point.dy < horizonY) {
        continue;
      }
      light.color = AppColors.gold.withValues(
        alpha: (0.25 + random.nextDouble() * 0.55) * reveal,
      );
      canvas.drawCircle(point, 0.7 + random.nextDouble() * 1.1, light);
    }
  }

  /// The sunrise breaking over the curve.
  ///
  /// Two blooms — a tight white core and a wide blue spill — plus the beam
  /// along the rim. [drift] slides the whole thing a little either side of the
  /// peak and breathes its intensity, which is the same ambient treatment the
  /// AI Coach backdrop carries.
  void _paintFlare(Canvas canvas, Offset center, double radius, Size size) {
    final double phase = math.sin(drift * 2 * math.pi);
    final double breathe = 0.9 + 0.1 * math.cos(drift * 2 * math.pi);
    final Offset top = Offset(
      center.dx + size.width * 0.035 * phase,
      center.dy - radius,
    );
    final double span = size.width * 0.62;

    canvas.drawCircle(
      top,
      span * 0.86,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            AppColors.aiBlue.withValues(alpha: 0.24 * breathe * reveal),
            AppColors.aiBlue.withValues(alpha: 0.08 * breathe * reveal),
            AppColors.transparent,
          ],
          stops: const <double>[0, 0.42, 1],
        ).createShader(Rect.fromCircle(center: top, radius: span * 0.86)),
    );

    canvas.drawCircle(
      top,
      span * 0.5,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            AppColors.textPrimary.withValues(alpha: 0.72 * breathe * reveal),
            AppColors.aiBlue.withValues(alpha: 0.26 * breathe * reveal),
            AppColors.transparent,
          ],
          stops: const <double>[0, 0.26, 1],
        ).createShader(Rect.fromCircle(center: top, radius: span * 0.5)),
    );

    final Rect beam = Rect.fromCenter(
      center: top,
      width: span * 1.7,
      height: 3,
    );
    canvas.drawRect(
      beam,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            AppColors.transparent,
            AppColors.aiBlue.withValues(alpha: 0.42 * breathe * reveal),
            AppColors.transparent,
          ],
        ).createShader(beam)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(EarthGlowPainter old) =>
      old.reveal != reveal || old.drift != drift;
}

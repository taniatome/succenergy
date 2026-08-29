import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../../core/theme/app_colors.dart';

/// Paints the lit curve of the Earth across the bottom of the Welcome screen.
///
/// Built from gradients and arcs rather than a bitmap, so it scales to any
/// device without a seam. The atmosphere rim carries the technology halo that
/// sits beneath the AI COACH lockup; the surface lights are gold.
class EarthGlowPainter extends CustomPainter {
  const EarthGlowPainter({required this.reveal});

  /// 0 to 1 entrance, used to bring the horizon up on first paint.
  final double reveal;

  @override
  void paint(Canvas canvas, Size size) {
    final double visible = size.height * 0.26 * reveal;
    if (visible <= 0) {
      return;
    }
    final double radius = size.width * 1.05;
    final Offset center = Offset(
      size.width / 2,
      size.height + radius - visible,
    );
    final Rect circle = Rect.fromCircle(center: center, radius: radius);

    _paintBody(canvas, circle, center, radius);
    _paintSurfaceLights(canvas, center, radius, size);
    _paintAtmosphere(canvas, circle, center, radius);
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
            AppColors.navyDeep,
            AppColors.navyDeep,
          ],
          stops: const <double>[0.94, 0.985, 1],
        ).createShader(circle),
    );
  }

  void _paintAtmosphere(
    Canvas canvas,
    Rect circle,
    Offset center,
    double radius,
  ) {
    final Paint halo =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 26
          ..color = AppColors.aiBlue.withValues(alpha: 0.16 * reveal)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26);
    canvas.drawArc(circle, math.pi, math.pi, false, halo);

    final Paint rim =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..shader = LinearGradient(
            colors: <Color>[
              AppColors.aiBlue.withValues(alpha: 0.10 * reveal),
              AppColors.aiBlue.withValues(alpha: 0.85 * reveal),
              AppColors.aiBlue.withValues(alpha: 0.10 * reveal),
            ],
          ).createShader(circle);
    canvas.drawArc(circle, math.pi, math.pi, false, rim);
  }

  void _paintSurfaceLights(
    Canvas canvas,
    Offset center,
    double radius,
    Size size,
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
      if (point.dy > size.height || point.dy < size.height * 0.7) {
        continue;
      }
      light.color = AppColors.gold.withValues(
        alpha: (0.25 + random.nextDouble() * 0.55) * reveal,
      );
      canvas.drawCircle(point, 0.7 + random.nextDouble() * 1.1, light);
    }
  }

  void _paintFlare(Canvas canvas, Offset center, double radius, Size size) {
    final Offset top = Offset(center.dx, center.dy - radius);
    final double span = size.width * 0.62;

    canvas.drawCircle(
      top,
      span * 0.5,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            AppColors.textPrimary.withValues(alpha: 0.55 * reveal),
            AppColors.aiBlue.withValues(alpha: 0.22 * reveal),
            AppColors.transparent,
          ],
          stops: const <double>[0, 0.28, 1],
        ).createShader(Rect.fromCircle(center: top, radius: span * 0.5)),
    );

    final Rect beam = Rect.fromCenter(
      center: top,
      width: span * 1.5,
      height: 3,
    );
    canvas.drawRect(
      beam,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            AppColors.transparent,
            AppColors.aiBlue.withValues(alpha: 0.35 * reveal),
            AppColors.transparent,
          ],
        ).createShader(beam)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(EarthGlowPainter old) => old.reveal != reveal;
}

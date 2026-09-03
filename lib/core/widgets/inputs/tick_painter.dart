import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

/// The checkmark, drawn on the same 24-unit grid as the app's icon marks.
///
/// [progress] is how much of the stroke to lay down, so the tick draws itself
/// on rather than appearing. Path metrics rather than two animated line
/// segments, so the corner is reached at the right moment and the stroke keeps
/// an even speed through it.
class TickPainter extends CustomPainter {
  const TickPainter({required this.progress, required this.color});

  /// 0 for nothing drawn, 1 for the whole mark.
  final double progress;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) {
      return;
    }

    final double u = size.width / 24;
    final Path mark =
        Path()
          ..moveTo(6 * u, 12.6 * u)
          ..lineTo(10.2 * u, 16.8 * u)
          ..lineTo(18 * u, 7.6 * u);

    final Paint stroke =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4 * u
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color;

    if (progress >= 1) {
      canvas.drawPath(mark, stroke);
      return;
    }

    for (final ui.PathMetric metric in mark.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress), stroke);
    }
  }

  @override
  bool shouldRepaint(TickPainter old) =>
      old.progress != progress || old.color != color;
}

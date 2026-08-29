import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/progress_snapshot.dart';

/// Draws goal completion over time as a filled gold curve.
///
/// Painted rather than charted, so the line carries the same bloom language
/// as the rest of the app instead of a library's default styling.
class CompletionChartPainter extends CustomPainter {
  const CompletionChartPainter({required this.history, required this.reveal});

  final List<ProgressSnapshot> history;

  /// 0 to 1 draw-in of the curve from left to right.
  final double reveal;

  @override
  void paint(Canvas canvas, Size size) {
    if (history.length < 2) {
      return;
    }
    _paintGrid(canvas, size);

    final int count = math.max(
      2,
      (history.length * reveal).round().clamp(2, history.length),
    );
    final Path line = Path();
    final Path fill = Path()..moveTo(0, size.height);

    for (int i = 0; i < count; i++) {
      final double x = size.width * (i / (history.length - 1));
      final double y =
          size.height - size.height * history[i].goalCompletion.clamp(0.0, 1.0);
      if (i == 0) {
        line.moveTo(x, y);
      } else {
        line.lineTo(x, y);
      }
      fill.lineTo(x, y);
    }
    final double lastX = size.width * ((count - 1) / (history.length - 1));
    fill
      ..lineTo(lastX, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.gold.withValues(alpha: 0.26),
            AppColors.transparent,
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.gold,
    );

    final double headY =
        size.height -
        size.height * history[count - 1].goalCompletion.clamp(0.0, 1.0);
    canvas.drawCircle(Offset(lastX, headY), 4, Paint()..color = AppColors.gold);
    canvas.drawCircle(
      Offset(lastX, headY),
      10,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  void _paintGrid(Canvas canvas, Size size) {
    final Paint grid =
        Paint()
          ..color = AppColors.textPrimary.withValues(alpha: 0.05)
          ..strokeWidth = 1;
    for (int i = 0; i <= 3; i++) {
      final double y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(CompletionChartPainter old) =>
      old.reveal != reveal || old.history != history;
}

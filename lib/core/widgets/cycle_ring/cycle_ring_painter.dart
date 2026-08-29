import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../theme/app_colors.dart';

/// Paints the Seven Principles as arc segments around a ring.
///
/// Completed segments render in gold, the active segment carries a soft pulse
/// behind it, and segments still ahead sit at low opacity. Driven by
/// [CycleRing]; not used directly.
class CycleRingPainter extends CustomPainter {
  const CycleRingPainter({
    required this.segmentCount,
    required this.completedCount,
    required this.activeIndex,
    required this.drawProgress,
    required this.pulse,
    required this.strokeWidth,
  });

  final int segmentCount;

  /// Segments already closed in this cycle.
  final int completedCount;

  /// Segment the user is currently working, or -1 when the cycle is closed.
  final int activeIndex;

  /// 0 to 1 draw-in of the whole ring, segment by segment.
  final double drawProgress;

  /// 0 to 1 continuous pulse driving the active segment bloom.
  final double pulse;

  final double strokeWidth;

  static const double _gapDegrees = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final double gap = _radians(_gapDegrees);
    final double segment = (2 * math.pi - gap * segmentCount) / segmentCount;
    final double start = -math.pi / 2 + gap / 2;

    _paintTrack(canvas, rect);

    for (int i = 0; i < segmentCount; i++) {
      final double reveal = (drawProgress * segmentCount - i).clamp(0.0, 1.0);
      if (reveal <= 0) {
        continue;
      }
      final double from = start + i * (segment + gap);
      final double sweep = segment * reveal;
      final bool isActive = i == activeIndex;
      final bool isDone = i < completedCount;

      if (isActive) {
        canvas.drawArc(rect, from, sweep, false, _bloomPaint());
      }
      canvas.drawArc(
        rect,
        from,
        sweep,
        false,
        _segmentPaint(isDone: isDone, isActive: isActive),
      );
      if (isActive && reveal >= 1) {
        _paintHead(canvas, center, radius, from + sweep);
      }
    }
  }

  void _paintTrack(Canvas canvas, Rect rect) {
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.35
        ..color = AppColors.textPrimary.withValues(alpha: 0.04),
    );
  }

  Paint _segmentPaint({required bool isDone, required bool isActive}) {
    final Paint paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    if (isDone) {
      paint.color = AppColors.gold;
    } else if (isActive) {
      paint.color = AppColors.gold.withValues(alpha: 0.55 + 0.45 * pulse);
    } else {
      paint.color = AppColors.textSecondary.withValues(alpha: 0.18);
    }
    return paint;
  }

  Paint _bloomPaint() {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2.4
      ..strokeCap = StrokeCap.round
      ..color = AppColors.gold.withValues(alpha: 0.08 + 0.14 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
  }

  void _paintHead(Canvas canvas, Offset center, double radius, double angle) {
    final Offset head = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    canvas.drawCircle(
      head,
      strokeWidth * 0.62,
      Paint()..color = AppColors.gold,
    );
    canvas.drawCircle(
      head,
      strokeWidth * 1.5,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.16 + 0.2 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  double _radians(double degrees) => degrees * math.pi / 180;

  @override
  bool shouldRepaint(CycleRingPainter old) {
    return old.drawProgress != drawProgress ||
        old.pulse != pulse ||
        old.completedCount != completedCount ||
        old.activeIndex != activeIndex ||
        old.strokeWidth != strokeWidth;
  }
}

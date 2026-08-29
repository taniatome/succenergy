import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/principle.dart';

/// Draws completed practice per principle as seven vertical bars in cycle
/// order, so the shape of the user's attention is readable at a glance.
class PrincipleBarsPainter extends CustomPainter {
  const PrincipleBarsPainter({required this.counts, required this.reveal});

  final Map<Principle, int> counts;

  /// 0 to 1 growth of the bars from the baseline.
  final double reveal;

  @override
  void paint(Canvas canvas, Size size) {
    if (counts.isEmpty) {
      return;
    }
    final int peak = math.max(1, counts.values.reduce(math.max));
    final int bars = Principle.values.length;
    final double gap = 10;
    final double barWidth = (size.width - gap * (bars - 1)) / bars;

    for (int i = 0; i < bars; i++) {
      final Principle principle = Principle.values[i];
      final int value = counts[principle] ?? 0;
      final double full = size.height * (value / peak);
      final double height = math.max(3, full * reveal);
      final double left = i * (barWidth + gap);
      final RRect bar = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - height, barWidth, height),
        const Radius.circular(4),
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, 0, barWidth, size.height),
          const Radius.circular(4),
        ),
        Paint()..color = AppColors.textPrimary.withValues(alpha: 0.04),
      );
      canvas.drawRRect(
        bar,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[
              AppColors.gold,
              AppColors.gold.withValues(alpha: 0.55),
            ],
          ).createShader(bar.outerRect),
      );
    }
  }

  @override
  bool shouldRepaint(PrincipleBarsPainter old) =>
      old.reveal != reveal || old.counts != counts;
}

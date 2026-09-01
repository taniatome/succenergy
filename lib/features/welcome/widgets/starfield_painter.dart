import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../../core/theme/app_colors.dart';

/// The sky above the horizon on the Welcome screen.
///
/// Sparse, still points in the app's own off-white. Deterministic, so the sky
/// is identical on every paint and nothing twinkles: the slow drift of the
/// sunrise is the only motion on this screen. Every ninth point is held
/// brighter and larger, which is what keeps a low-opacity field reading as
/// stars rather than as noise.
class StarfieldPainter extends CustomPainter {
  const StarfieldPainter({required this.reveal, required this.horizonFraction});

  /// 0 to 1 entrance, shared with the horizon so the sky arrives with it.
  final double reveal;

  /// Share of the screen height the Earth's curve rises to. Stars are only
  /// placed above it.
  final double horizonFraction;

  /// How many points are placed across the sky.
  static const int _count = 110;

  @override
  void paint(Canvas canvas, Size size) {
    if (reveal <= 0) {
      return;
    }
    final double horizonY =
        size.height - size.height * horizonFraction * reveal;
    final math.Random random = math.Random(31);
    final Paint star = Paint();

    for (int i = 0; i < _count; i++) {
      final Offset point = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * horizonY * 0.94,
      );
      final bool bright = i % 9 == 0;
      // Points nearer the horizon sit deeper in the atmosphere and dim.
      final double fade = 1 - (point.dy / math.max(horizonY, 1)) * 0.35;
      final double alpha =
          bright
              ? 0.42 + random.nextDouble() * 0.24
              : 0.08 + random.nextDouble() * 0.14;
      final double dot =
          bright
              ? 1.1 + random.nextDouble() * 0.5
              : 0.5 + random.nextDouble() * 0.4;
      star.color = AppColors.textPrimary.withValues(
        alpha: alpha * fade * reveal,
      );
      canvas.drawCircle(point, dot, star);
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter old) =>
      old.reveal != reveal || old.horizonFraction != horizonFraction;
}

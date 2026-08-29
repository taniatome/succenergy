import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../motion/app_curves.dart';
import '../motion/app_durations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Progress readouts in the Succenergy language.
///
/// One class with two forms: [AppProgress.bar] for the thin gold rule used on
/// goal cards and the onboarding header, and [AppProgress.ring] for the
/// compact circle on Goal Detail. Both animate to position rather than
/// snapping.
///
/// [AppLoader] in `app_loader.dart` is the waiting state that goes with
/// them.
class AppProgress extends StatelessWidget {
  /// A thin horizontal rule that fills in gold.
  const AppProgress.bar({
    required this.value,
    this.thickness = 4,
    this.useAiAccent = false,
    super.key,
  }) : _isRing = false,
       diameter = 0;

  /// A circular readout, used where a bar would be too wide.
  const AppProgress.ring({
    required this.value,
    this.diameter = 64,
    this.thickness = 5,
    this.useAiAccent = false,
    super.key,
  }) : _isRing = true;

  /// Completion from 0 to 1.
  final double value;

  final double thickness;
  final double diameter;

  /// Renders in AI Blue. Only for progress that belongs to the coach.
  final bool useAiAccent;

  final bool _isRing;

  Color get _accent => useAiAccent ? AppColors.aiBlue : AppColors.gold;

  @override
  Widget build(BuildContext context) {
    final Duration duration =
        (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
            ? Duration.zero
            : AppDurations.slow;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: duration,
      curve: AppCurves.stateChange,
      builder: (BuildContext context, double v, Widget? child) {
        return _isRing ? _buildRing(v) : _buildBar(v);
      },
    );
  }

  Widget _buildBar(double v) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Stack(
        children: <Widget>[
          Container(
            height: thickness,
            color: AppColors.textPrimary.withValues(alpha: 0.07),
          ),
          FractionallySizedBox(
            widthFactor: v,
            child: Container(
              height: thickness,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[_accent.withValues(alpha: 0.55), _accent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRing(double v) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: _RingPainter(value: v, thickness: thickness, accent: _accent),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.thickness,
    required this.accent,
  });

  final double value;
  final double thickness;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (math.min(size.width, size.height) - thickness) / 2,
    );
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..color = AppColors.textPrimary.withValues(alpha: 0.07),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * value,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..color = accent,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.accent != accent;
}

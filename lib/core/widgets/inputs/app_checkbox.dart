import 'package:flutter/widgets.dart';

import '../../motion/app_curves.dart';
import '../../motion/app_durations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// A consent checkbox with its statement beside it.
///
/// The box is drawn rather than taken from Material: ticked, it fills gold and
/// carries the same resting bloom as every other committed state in the app,
/// and the whole row is the target so the statement is as tappable as the box.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    required this.value,
    required this.label,
    required this.onChanged,
    super.key,
  });

  final bool value;

  /// Already-localised statement the user is agreeing to.
  final String label;

  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _box(),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color:
                      value ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box() {
    return AnimatedContainer(
      duration: AppDurations.fast,
      curve: AppCurves.stateChange,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color:
            value ? AppColors.gold : AppColors.navyDeep.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadii.input * 0.5),
        border: Border.all(
          color: value ? AppColors.gold : AppColors.hairline,
          width: value ? AppBorders.emphasis : AppBorders.hairline,
        ),
        boxShadow: value ? AppShadows.goldGlow : null,
      ),
      child: value ? const _Tick() : null,
    );
  }
}

/// The tick itself, drawn on the same 24-unit grid as the app's icon marks.
class _Tick extends StatelessWidget {
  const _Tick();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _TickPainter());
  }
}

class _TickPainter extends CustomPainter {
  const _TickPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double u = size.width / 24;
    final Path path =
        Path()
          ..moveTo(6 * u, 12.6 * u)
          ..lineTo(10.2 * u, 16.8 * u)
          ..lineTo(18 * u, 7.6 * u);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * u
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.navyDeep,
    );
  }

  @override
  bool shouldRepaint(_TickPainter old) => false;
}

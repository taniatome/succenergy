import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// A labelled 0-to-1 scale.
///
/// Used by the onboarding motivation question and by any exercise step of
/// type scale. The track fills in gold from the left and the handle carries a
/// bloom, so the control reads as energy rather than as a form field.
///
/// Leave [onChanged] null to render the same scale as a read-only readout,
/// which is how a saved answer is shown back on Profile.
class ScaleInput extends StatelessWidget {
  const ScaleInput({
    required this.value,
    required this.lowLabel,
    required this.highLabel,
    this.onChanged,
    super.key,
  });

  final double value;

  /// Null renders the scale as a readout rather than a control.
  final ValueChanged<double>? onChanged;

  final String lowLabel;
  final String highLabel;

  static const double _trackHeight = 4;
  static const double _handle = 26;

  bool get _interactive => onChanged != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double usable = constraints.maxWidth - _handle;
            final Widget track = SizedBox(
              height: _handle + AppSpacing.md,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[_rail(), _fill(usable), _knob(usable)],
              ),
            );
            if (!_interactive) {
              return track;
            }
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown:
                  (TapDownDetails d) => _emit(d.localPosition.dx, usable),
              onHorizontalDragUpdate:
                  (DragUpdateDetails d) => _emit(d.localPosition.dx, usable),
              child: track,
            );
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        _poles(),
      ],
    );
  }

  Widget _rail() {
    return Container(
      height: _trackHeight,
      margin: const EdgeInsets.symmetric(horizontal: _handle / 2),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
    );
  }

  Widget _fill(double usable) {
    return Container(
      height: _trackHeight,
      width: (_handle / 2) + usable * value.clamp(0.0, 1.0),
      margin: const EdgeInsets.only(left: _handle / 2),
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
    );
  }

  Widget _knob(double usable) {
    return Positioned(
      left: usable * value.clamp(0.0, 1.0),
      child: Container(
        width: _handle,
        height: _handle,
        decoration: BoxDecoration(
          color: AppColors.gold,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.navyDeep,
            width: AppBorders.emphasis,
          ),
          boxShadow: AppShadows.goldGlow,
        ),
      ),
    );
  }

  Widget _poles() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(child: Text(lowLabel, style: AppTypography.caption)),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Text(
            highLabel,
            style: AppTypography.caption,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _emit(double dx, double usable) {
    if (usable <= 0) {
      return;
    }
    onChanged!(((dx - _handle / 2) / usable).clamp(0.0, 1.0));
  }
}

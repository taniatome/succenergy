import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_eyebrow.dart';

/// One column of the date of birth picker.
///
/// The selected row sits inside a gold band, the rows either side fall back to
/// secondary text, and the whole column is the app's own type — the wheel is
/// the only borrowed mechanic here.
class DobWheel extends StatefulWidget {
  const DobWheel({
    required this.label,
    required this.values,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  /// Already-localised column heading.
  final String label;

  /// Already-formatted row labels.
  final List<String> values;

  final int selected;
  final ValueChanged<int> onSelected;

  /// Height of one row, and the height of the selection band.
  static const double rowExtent = 40;

  @override
  State<DobWheel> createState() => _DobWheelState();
}

class _DobWheelState extends State<DobWheel> {
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: widget.selected);

  @override
  void didUpdateWidget(DobWheel old) {
    super.didUpdateWidget(old);
    // A shorter month can drop the selected day below the end of the list.
    if (widget.selected != _controller.selectedItem &&
        widget.selected < widget.values.length) {
      _controller.jumpToItem(widget.selected);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionEyebrow(label: widget.label),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: DobWheel.rowExtent * 5,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              IgnorePointer(child: _band()),
              ListWheelScrollView.useDelegate(
                controller: _controller,
                itemExtent: DobWheel.rowExtent,
                physics: const FixedExtentScrollPhysics(),
                diameterRatio: 1.8,
                perspective: 0.003,
                onSelectedItemChanged: widget.onSelected,
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: widget.values.length,
                  builder: (BuildContext context, int index) => _row(index),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _band() {
    return Container(
      height: DobWheel.rowExtent,
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: AppColors.goldHairline),
      ),
    );
  }

  Widget _row(int index) {
    final bool active = index == widget.selected;
    return Center(
      child: Text(
        widget.values[index],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style:
            active
                ? AppTypography.titleMedium.copyWith(color: AppColors.gold)
                : AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
      ),
    );
  }
}

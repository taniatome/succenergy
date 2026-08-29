import 'package:flutter/widgets.dart';

import '../../../core/motion/app_curves.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cards/glow_card.dart';
import '../../../core/widgets/section_eyebrow.dart';

/// A titled card that holds one chart and animates its contents in.
///
/// The builder receives a 0-to-1 reveal value, which each painter uses to
/// draw itself into place rather than appearing fully formed.
class ChartFrame extends StatefulWidget {
  const ChartFrame({
    required this.title,
    required this.height,
    required this.builder,
    this.footer,
    super.key,
  });

  final String title;
  final double height;
  final Widget Function(double reveal) builder;

  /// Optional row beneath the chart, typically axis labels.
  final Widget? footer;

  @override
  State<ChartFrame> createState() => _ChartFrameState();
}

class _ChartFrameState extends State<ChartFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _reveal = CurvedAnimation(
    parent: _controller,
    curve: AppCurves.entrance,
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.value = 1;
      return;
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionEyebrow(label: widget.title, withRule: true),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: widget.height,
            child: AnimatedBuilder(
              animation: _reveal,
              builder:
                  (BuildContext context, Widget? child) =>
                      widget.builder(_reveal.value),
            ),
          ),
          if (widget.footer != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            widget.footer!,
          ],
        ],
      ),
    );
  }
}

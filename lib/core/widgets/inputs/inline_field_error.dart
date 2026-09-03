import 'package:flutter/widgets.dart';

import '../../motion/app_curves.dart';
import '../../motion/app_durations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// The validation message that appears beneath a field.
///
/// Inline rather than a dialog or a snackbar: the message belongs next to the
/// thing that is wrong, and a form with three problems should show three
/// messages rather than one at a time.
///
/// It rises four pixels as it fades in, and fades and collapses again when the
/// field is corrected — the message leaving is as much a piece of feedback as
/// the message arriving, so it is animated rather than simply removed.
class InlineFieldError extends StatefulWidget {
  const InlineFieldError({required this.message, super.key});

  /// Already-localised message, or null when the field is fine.
  final String? message;

  @override
  State<InlineFieldError> createState() => _InlineFieldErrorState();
}

class _InlineFieldErrorState extends State<InlineFieldError>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.fast,
  );

  /// Held through the exit so there is still something to fade out.
  String? _shown;

  /// Distance the message travels as it arrives.
  static const double _rise = 4;

  @override
  void initState() {
    super.initState();
    _shown = widget.message;
    if (_shown != null) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(InlineFieldError old) {
    super.didUpdateWidget(old);
    if (widget.message == old.message) {
      return;
    }
    if (widget.message != null) {
      setState(() => _shown = widget.message);
      _controller.forward();
      return;
    }
    _controller.reverse().whenComplete(() {
      if (mounted) {
        setState(() => _shown = null);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? message = _shown;
    if (message == null) {
      return const SizedBox(width: double.infinity);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double t = AppCurves.entrance.transform(_controller.value);
        return ClipRect(
          child: Align(
            alignment: Alignment.bottomLeft,
            heightFactor: t,
            child: Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, _rise * (1 - t)),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Text(
          message,
          style: AppTypography.caption.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}

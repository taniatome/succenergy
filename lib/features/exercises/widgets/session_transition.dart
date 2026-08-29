import 'package:flutter/widgets.dart';

import '../../../core/motion/app_curves.dart';
import '../../../core/motion/app_durations.dart';

/// Carries one exercise step off and the next one on.
///
/// Steps travel horizontally in the direction of travel, so going back reads
/// as going back rather than as another step forward.
class SessionTransition extends StatelessWidget {
  const SessionTransition({
    required this.stepIndex,
    required this.forward,
    required this.child,
    super.key,
  });

  /// Identifies the step on screen. A change is what drives the transition.
  final int stepIndex;

  /// False when the user pressed Back, which reverses the slide.
  final bool forward;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return AnimatedSwitcher(
      duration: reduced ? Duration.zero : AppDurations.medium,
      switchInCurve: AppCurves.entrance,
      switchOutCurve: AppCurves.exit,
      transitionBuilder: _slide,
      child: KeyedSubtree(key: ValueKey<int>(stepIndex), child: child),
    );
  }

  Widget _slide(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(forward ? 0.18 : -0.18, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

import '../../../core/motion/app_durations.dart';
import '../../../core/theme/app_colors.dart';

/// A very slow drifting bloom behind the conversation.
///
/// Gives the coach screen a sense of being awake while idle. The movement is
/// under one screen width over eighteen seconds, so it registers as
/// atmosphere rather than as motion.
class AmbientDrift extends StatefulWidget {
  const AmbientDrift({super.key});

  @override
  State<AmbientDrift> createState() => _AmbientDriftState();
}

class _AmbientDriftState extends State<AmbientDrift>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.ambientDrift,
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
      _controller.value = 0.5;
      return;
    }
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double t = Curves.easeInOutSine.transform(_controller.value);
          return Align(
            alignment: Alignment(-0.5 + t, -0.85 + t * 0.35),
            child: Container(
              width: width * 1.1,
              height: width * 1.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    AppColors.aiBlue.withValues(alpha: 0.10),
                    AppColors.aiBlue.withValues(alpha: 0.03),
                    AppColors.transparent,
                  ],
                  stops: const <double>[0, 0.45, 1],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

/// The layered navy backdrop every screen sits on.
///
/// Backgrounds are never a flat fill: a vertical gradient darkens toward the
/// bottom, an optional radial bloom sits behind the focal content, and a
/// vignette pulls the eye inward. Shared by every feature, so it lives here
/// rather than in any one of them.
class ScreenBackground extends StatelessWidget {
  const ScreenBackground({
    required this.child,
    this.glowTint,
    this.glowAlignment = const Alignment(0, -0.55),
    this.glowScale = 1,
    super.key,
  });

  final Widget child;

  /// Tint of the radial bloom. Gold for brand surfaces, AI Blue for the
  /// coach. Null leaves the background unaccented, which is the right choice
  /// on dense screens.
  final Color? glowTint;

  final Alignment glowAlignment;

  /// Multiplier on the bloom diameter, which is otherwise the screen width.
  final double glowScale;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double bloom = size.width * 1.35 * glowScale;

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.screen),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (glowTint != null)
            Align(
              alignment: glowAlignment,
              child: IgnorePointer(
                child: Container(
                  width: bloom,
                  height: bloom,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.focalGlow(glowTint!),
                  ),
                ),
              ),
            ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.95,
                  colors: <Color>[
                    AppColors.transparent,
                    AppColors.navyDeep.withValues(alpha: 0.55),
                  ],
                  stops: const <double>[0.6, 1],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

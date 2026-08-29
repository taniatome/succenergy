import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/asset_paths.dart';
import '../../theme/app_colors.dart';

/// The Succenergy symbol.
///
/// The only file in the project that references the symbol asset. The mark is
/// rendered from vector at full opacity with no tint, filter or blend mode.
/// The bloom is a separate layer painted behind it, never a filter on it, and
/// it overflows the widget's bounds so the mark keeps a tight layout box.
class SuccenergyLogo extends StatelessWidget {
  const SuccenergyLogo({this.size = 120, this.bloom = true, super.key});

  /// Width and height of the square mark. Aspect ratio is always preserved.
  final double size;

  /// Whether to paint the radial gold bloom behind the mark.
  final bool bloom;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: <Widget>[
          if (bloom)
            OverflowBox(
              maxWidth: size * 1.9,
              maxHeight: size * 1.9,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        AppColors.gold.withValues(alpha: 0.22),
                        AppColors.gold.withValues(alpha: 0.07),
                        AppColors.transparent,
                      ],
                      stops: const <double>[0, 0.36, 0.7],
                    ),
                  ),
                  child: SizedBox(width: size * 1.9, height: size * 1.9),
                ),
              ),
            ),
          SvgPicture.asset(
            AssetPaths.logoSymbolSvg,
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

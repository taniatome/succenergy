import 'package:flutter/widgets.dart';

import '../../constants/asset_paths.dart';

/// The SUCCENERGY / AI COACH lockup.
///
/// The only file in the project that references the wordmark asset.
///
/// The artwork has a navy background baked into it, so it may only be placed
/// on `AppColors.deepNavy` or `AppColors.navyDeep`, and `AppColors.navyDeep`
/// is the closer match. Putting it on a card, a gradient or any lighter
/// surface shows the seam. It is constrained by width and never stretched,
/// tinted or faded.
///
/// Set [fullBleed] where the lockup can run the full width of the screen: the
/// artwork's left and right edges then leave the viewport entirely and only
/// its near-black top and bottom edges meet the background, which makes the
/// baked-in panel effectively invisible.
class SuccenergyWordmark extends StatelessWidget {
  const SuccenergyWordmark({
    this.width = 240,
    this.fullBleed = false,
    super.key,
  });

  /// Rendered width. Height follows the artwork's own aspect ratio.
  final double width;

  /// Allows the artwork to overflow its parent's horizontal padding.
  final bool fullBleed;

  /// Intrinsic aspect ratio of the supplied artwork, 3375 by 804.
  static const double _aspectRatio = 3375 / 804;

  @override
  Widget build(BuildContext context) {
    final double resolved =
        fullBleed ? MediaQuery.sizeOf(context).width : width;
    final Widget image = SizedBox(
      width: resolved,
      height: resolved / _aspectRatio,
      child: Image.asset(
        AssetPaths.logoWordmark,
        width: resolved,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
    if (!fullBleed) {
      return image;
    }
    return SizedBox(
      height: resolved / _aspectRatio,
      child: OverflowBox(
        maxWidth: resolved,
        maxHeight: resolved / _aspectRatio,
        child: image,
      ),
    );
  }
}

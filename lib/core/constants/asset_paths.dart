/// Every bundled asset path in the app.
///
/// The three brand files below are the complete set of permitted brand
/// imagery. Only `succenergy_logo.dart` and `succenergy_wordmark.dart` may
/// reference them.
class AssetPaths {
  const AssetPaths._();

  /// Vector "S" symbol. Rendered with `SvgPicture.asset` only.
  static const String logoSymbolSvg = 'assets/branding/succenergy_app_icon.svg';

  /// The SUCCENERGY / AI COACH lockup. Its navy background is baked in, so it
  /// may only sit on `AppColors.deepNavy` or `AppColors.navyDeep`.
  static const String logoWordmark =
      'assets/branding/succenergy_logo_wordmark.png';
}

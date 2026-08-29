/// Spacing, corner radius and border width scale.
///
/// Every gap, padding, radius and stroke in the app resolves through here so
/// rhythm stays consistent across all twenty screens.
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double huge = 64;

  /// Standard horizontal inset for screen content.
  static const double screenH = 24;

  /// Standard vertical inset below the status bar for screen content.
  static const double screenV = 16;
}

/// Corner radius scale. Inputs 12, cards 16-20, pills fully rounded.
class AppRadii {
  const AppRadii._();

  static const double input = 12;
  static const double card = 16;
  static const double cardLarge = 20;
  static const double sheet = 28;
  static const double pill = 999;
}

/// Border stroke widths. Hairlines only; the design carries weight with glow.
class AppBorders {
  const AppBorders._();

  static const double hairline = 1;
  static const double emphasis = 1.5;
}

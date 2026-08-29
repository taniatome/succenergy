import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Elevation in this app reads as light bloom, never as a black drop shadow.
///
/// Gold glow marks Succenergy and achievement; blue glow marks AI surfaces.
/// A surface never carries both.
class AppShadows {
  const AppShadows._();

  /// Ambient depth for standard cards. Uses the recessed navy, not black.
  static List<BoxShadow> get elevation => <BoxShadow>[
    BoxShadow(
      color: AppColors.navyDeep.withValues(alpha: 0.55),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Resting gold bloom for brand-carrying cards and buttons.
  static List<BoxShadow> get goldGlow => <BoxShadow>[
    BoxShadow(
      color: AppColors.gold.withValues(alpha: 0.16),
      blurRadius: 28,
      spreadRadius: -4,
    ),
  ];

  /// Pressed or focused gold bloom.
  static List<BoxShadow> get goldGlowStrong => <BoxShadow>[
    BoxShadow(
      color: AppColors.gold.withValues(alpha: 0.34),
      blurRadius: 40,
      spreadRadius: -2,
    ),
  ];

  /// Resting AI bloom. Reserved for AI Coach affordances.
  static List<BoxShadow> get blueGlow => <BoxShadow>[
    BoxShadow(
      color: AppColors.aiBlue.withValues(alpha: 0.16),
      blurRadius: 28,
      spreadRadius: -4,
    ),
  ];

  /// Pressed or focused AI bloom.
  static List<BoxShadow> get blueGlowStrong => <BoxShadow>[
    BoxShadow(
      color: AppColors.aiBlue.withValues(alpha: 0.32),
      blurRadius: 40,
      spreadRadius: -2,
    ),
  ];

  /// Bloom used behind the brand logo. Rendered as its own layer, never as a
  /// filter applied to the asset.
  static List<BoxShadow> get logoBloom => <BoxShadow>[
    BoxShadow(
      color: AppColors.gold.withValues(alpha: 0.22),
      blurRadius: 72,
      spreadRadius: 8,
    ),
  ];

  /// Bloom for destructive confirmations.
  static List<BoxShadow> get errorGlow => <BoxShadow>[
    BoxShadow(
      color: AppColors.error.withValues(alpha: 0.24),
      blurRadius: 28,
      spreadRadius: -4,
    ),
  ];
}

/// Layered navy gradients. Backgrounds are never a flat fill.
class AppGradients {
  const AppGradients._();

  /// The default screen background: deep navy darkening toward the edges.
  static const LinearGradient screen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[AppColors.deepNavy, AppColors.deepNavy, AppColors.navyDeep],
    stops: <double>[0, 0.55, 1],
  );

  /// Elevated card fill, lit slightly from the top-left.
  static const LinearGradient card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[AppColors.navyElevated, AppColors.deepNavy],
  );

  /// Gradient edge for the single most important card on a screen.
  static LinearGradient get goldEdge => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      AppColors.gold.withValues(alpha: 0.62),
      AppColors.gold.withValues(alpha: 0.10),
      AppColors.transparent,
    ],
    stops: const <double>[0, 0.5, 1],
  );

  /// Gradient edge for the AI Coach entry point.
  static LinearGradient get blueEdge => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      AppColors.aiBlue.withValues(alpha: 0.62),
      AppColors.aiBlue.withValues(alpha: 0.10),
      AppColors.transparent,
    ],
    stops: const <double>[0, 0.5, 1],
  );

  /// Radial bloom placed behind focal content.
  static RadialGradient focalGlow(Color tint) => RadialGradient(
    colors: <Color>[
      tint.withValues(alpha: 0.18),
      tint.withValues(alpha: 0.06),
      AppColors.transparent,
    ],
    stops: const <double>[0, 0.45, 1],
  );
}

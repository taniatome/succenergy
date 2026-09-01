import 'package:flutter/widgets.dart';

import 'app_icon_painter.dart';

/// The marks the app draws for itself.
///
/// These cover the chrome the user sees on every screen: the five navigation
/// destinations and the three affordances in the Dashboard header. Everything
/// else still uses Material Symbols.
enum AppIconMark {
  /// Home. A cycle ring with the active position sitting in its gap, which is
  /// the Cycle Ring reduced to icon size.
  cycle,

  /// Goals. Concentric rings closing on a centre.
  target,

  /// AI Coach. A point with two arcs opening away from it: intelligence
  /// speaking, rather than the sparkle every product uses.
  signal,

  /// Exercises. A three-tread ascent, one step at a time.
  steps,

  /// Progress. A rise across a baseline, resolving on a node.
  rise,

  /// Notifications. A chime abstracted to its arc, base and clapper.
  chime,

  /// Settings. Two rules with their handles set differently.
  sliders,

  /// Profile. Head and shoulders, drawn as circle and arc.
  person,

  /// Settings. Three dots stacked vertically: the kebab menu, drawn on the
  /// same grid as its neighbours instead of borrowed from Material.
  kebab,

  /// A chevron pointing down, for a row that expands in place.
  chevronDown,
}

/// Draws one of the app's own icon marks.
///
/// Single-colour by design: the mark takes whichever accent its context
/// carries, so the same glyph reads gold in the brand chrome and AI Blue on
/// the coach. Laid out on a 24-unit grid and scaled, so it stays legible at
/// the 20-24px the navigation bar and header use.
class AppIcon extends StatelessWidget {
  const AppIcon({
    required this.mark,
    required this.color,
    this.size = 24,
    super.key,
  });

  final AppIconMark mark;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: AppIconPainter(mark: mark, color: color),
        isComplex: false,
      ),
    );
  }
}

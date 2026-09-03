import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import 'app_icon.dart';

/// Paints the app's own icon marks.
///
/// Every mark is described on a 24-unit grid and scaled to the canvas, so one
/// set of coordinates holds at any size. Stroke weight scales with it, which
/// keeps the marks reading as one family beside the wordmark and the Cycle
/// Ring rather than as eight separate drawings.
class AppIconPainter extends CustomPainter {
  const AppIconPainter({required this.mark, required this.color});

  final AppIconMark mark;
  final Color color;

  /// The design grid every mark is drawn on.
  static const double _grid = 24;

  /// Stroke weight in grid units. Confident, not hairline.
  static const double _weight = 1.8;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = math.min(size.width, size.height) / _grid;
    canvas.save();
    canvas.scale(scale);

    final Paint stroke =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _weight
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color;
    final Paint fill =
        Paint()
          ..style = PaintingStyle.fill
          ..color = color;

    switch (mark) {
      case AppIconMark.cycle:
        _cycle(canvas, stroke, fill);
      case AppIconMark.target:
        _target(canvas, stroke, fill);
      case AppIconMark.signal:
        _signal(canvas, stroke, fill);
      case AppIconMark.steps:
        _steps(canvas, stroke);
      case AppIconMark.rise:
        _rise(canvas, stroke, fill);
      case AppIconMark.chime:
        _chime(canvas, stroke, fill);
      case AppIconMark.sliders:
        _sliders(canvas, stroke, fill);
      case AppIconMark.person:
        _person(canvas, stroke);
      case AppIconMark.kebab:
        _kebab(canvas, fill);
      case AppIconMark.chevronDown:
        _chevronDown(canvas, stroke);
      case AppIconMark.eye:
        _eye(canvas, stroke, fill, struck: false);
      case AppIconMark.eyeClosed:
        _eye(canvas, stroke, fill, struck: true);
    }

    canvas.restore();
  }

  /// A ring broken at the top, with the active position resting in the gap.
  void _cycle(Canvas canvas, Paint stroke, Paint fill) {
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(12, 12.6), radius: 8),
      _rad(-62),
      _rad(304),
      false,
      stroke,
    );
    canvas.drawCircle(const Offset(12, 4.2), 2, fill);
  }

  /// Concentric rings closing on a centre.
  void _target(Canvas canvas, Paint stroke, Paint fill) {
    canvas.drawCircle(const Offset(12, 12), 8, stroke);
    canvas.drawCircle(const Offset(12, 12), 3.9, stroke);
    canvas.drawCircle(const Offset(12, 12), 1.7, fill);
  }

  /// A point with two arcs opening away from it.
  void _signal(Canvas canvas, Paint stroke, Paint fill) {
    const Offset origin = Offset(7.4, 12);
    canvas.drawCircle(origin, 2.1, fill);
    for (final double radius in <double>[5.6, 9.2]) {
      canvas.drawArc(
        Rect.fromCircle(center: origin, radius: radius),
        _rad(-52),
        _rad(104),
        false,
        stroke,
      );
    }
  }

  /// A three-tread ascent.
  void _steps(Canvas canvas, Paint stroke) {
    canvas.drawPath(
      _path(const <Offset>[
        Offset(3.8, 18),
        Offset(9, 18),
        Offset(9, 13.2),
        Offset(14.4, 13.2),
        Offset(14.4, 8.4),
        Offset(20.2, 8.4),
      ]),
      stroke,
    );
  }

  /// A rise across a baseline, resolving on a node.
  void _rise(Canvas canvas, Paint stroke, Paint fill) {
    canvas.drawLine(const Offset(4, 19.4), const Offset(20, 19.4), stroke);
    canvas.drawPath(
      _path(const <Offset>[
        Offset(5.2, 15.4),
        Offset(10.4, 10),
        Offset(14, 12.6),
        Offset(19, 5.6),
      ]),
      stroke,
    );
    canvas.drawCircle(const Offset(19, 5.6), 1.9, fill);
  }

  /// A chime reduced to arc, base and clapper.
  void _chime(Canvas canvas, Paint stroke, Paint fill) {
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(12, 12.4), radius: 5.8),
      _rad(180),
      _rad(180),
      false,
      stroke,
    );
    canvas.drawLine(const Offset(6.2, 12.4), const Offset(6.2, 15), stroke);
    canvas.drawLine(const Offset(17.8, 12.4), const Offset(17.8, 15), stroke);
    canvas.drawLine(const Offset(4.4, 15.6), const Offset(19.6, 15.6), stroke);
    canvas.drawCircle(const Offset(12, 18.7), 1.6, fill);
  }

  /// Two rules with their handles set differently.
  void _sliders(Canvas canvas, Paint stroke, Paint fill) {
    canvas.drawLine(const Offset(4, 9.4), const Offset(20, 9.4), stroke);
    canvas.drawCircle(const Offset(15.4, 9.4), 2.5, fill);
    canvas.drawLine(const Offset(4, 15.2), const Offset(20, 15.2), stroke);
    canvas.drawCircle(const Offset(8.6, 15.2), 2.5, fill);
  }

  /// Head and shoulders, as circle and arc.
  void _person(Canvas canvas, Paint stroke) {
    canvas.drawCircle(const Offset(12, 8.4), 3.5, stroke);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(12, 20.4), radius: 6.4),
      _rad(200),
      _rad(140),
      false,
      stroke,
    );
  }

  /// Three dots up the centre, spaced on the grid so the mark reads at 19px
  /// beside the chime and the person.
  void _kebab(Canvas canvas, Paint fill) {
    for (final double y in <double>[6.2, 12, 17.8]) {
      canvas.drawCircle(Offset(12, y), 1.85, fill);
    }
  }

  /// A chevron pointing down, for a row that opens in place.
  void _chevronDown(Canvas canvas, Paint stroke) {
    canvas.drawPath(
      _path(const <Offset>[
        Offset(6.4, 9.8),
        Offset(12, 15.2),
        Offset(17.6, 9.8),
      ]),
      stroke,
    );
  }

  /// Two mirrored arcs closing on a pupil, with an optional stroke through
  /// it for the hidden state. Drawn here rather than borrowed from Material,
  /// so the reveal toggle sits on the same grid as the rest of the set.
  void _eye(Canvas canvas, Paint stroke, Paint fill, {required bool struck}) {
    final Path lid =
        Path()
          ..moveTo(3.2, 12)
          ..quadraticBezierTo(7.6, 6.2, 20.8, 12)
          ..quadraticBezierTo(16.4, 17.8, 3.2, 12)
          ..close();
    canvas.drawPath(lid, stroke);
    canvas.drawCircle(const Offset(12, 12), 2.5, fill);

    if (struck) {
      canvas.drawLine(const Offset(5, 19), const Offset(19, 5), stroke);
    }
  }

  Path _path(List<Offset> points) {
    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final Offset point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path;
  }

  double _rad(double degrees) => degrees * math.pi / 180;

  @override
  bool shouldRepaint(AppIconPainter old) =>
      old.mark != mark || old.color != color;
}

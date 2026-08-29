import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../motion/app_curves.dart';
import '../motion/app_durations.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'icons/app_icon.dart';

/// The persistent navigation for the five main destinations.
///
/// The Coach is the product, so it is not a fifth tab of equal weight: it is
/// a raised AI-blue dock that breaks the top edge of the bar, and the bar
/// curves around it. The other four destinations sit two to a side, gold, on
/// a floating navy pill lifted off the page.
///
/// Everything else follows the house rules. Gold means Succenergy; AI Blue
/// means the Coach and nothing else. The active destination is marked by a
/// puck that slides between positions rather than reappearing, and the dock
/// breathes on its own so the entry point stays alive on every screen.
class AppBottomNav extends StatefulWidget {
  const AppBottomNav({
    required this.currentIndex,
    required this.onSelect,
    required this.labels,
    required this.marks,
    this.aiIndex = 2,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  /// Already-localised labels, one per destination including the Coach.
  final List<String> labels;

  /// The app's own marks, one per destination.
  final List<AppIconMark> marks;

  /// Index of the destination that belongs to the AI Coach. This one is
  /// lifted out of the bar and into the dock.
  final int aiIndex;

  /// Height of the floating pill itself.
  static const double barHeight = 62;

  /// Radius of the raised Coach dock.
  static const double dockRadius = 26;

  /// Radius of the cut in the bar. The difference from [dockRadius] is the
  /// ring of background that reads as the gap around the dock.
  static const double notchRadius = 33;

  /// How far the notch circle's centre sits below the bar's top edge. Keeping
  /// it a little inside stops the dock floating free of the bar, and keeps the
  /// cut shallow enough that the Coach label still fits underneath it.
  static const double notchDip = 6;

  /// Side of the dock's hit target, which is also the box its halo breathes
  /// inside. Sized to hold the halo at its widest.
  static const double dockBox = dockRadius * 2 + 20;

  /// Distance from the bar's bottom edge up to the dock's centre, which is
  /// the centre of the notch.
  static const double _dockCentre = barHeight - notchDip;

  /// Full height of the navigation: the bar plus the dock's overhang.
  static const double stackHeight = _dockCentre + dockBox / 2;

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: AppDurations.pulse,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _breath.stop();
    } else if (!_breath.isAnimating) {
      _breath.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  /// The four destinations that stay in the bar, in bar order.
  List<int> get _barIndices => <int>[
    for (int i = 0; i < widget.labels.length; i++)
      if (i != widget.aiIndex) i,
  ];

  @override
  Widget build(BuildContext context) {
    final Duration duration =
        (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
            ? Duration.zero
            : AppDurations.medium;
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      // The screen gradient resolves to this exact navy at its own bottom
      // edge, so the pill reads as lifted off an uninterrupted background.
      color: AppColors.navyDeep,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.sm + bottomInset * 0.5,
        ),
        child: SizedBox(
          height: AppBottomNav.stackHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: AppBottomNav.barHeight,
                child: _bar(duration),
              ),
              Positioned(
                bottom: AppBottomNav._dockCentre - AppBottomNav.dockBox / 2,
                child: _CoachDock(
                  mark: widget.marks[widget.aiIndex],
                  label: widget.labels[widget.aiIndex],
                  active: widget.currentIndex == widget.aiIndex,
                  breath: _breath,
                  onTap: () => widget.onSelect(widget.aiIndex),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The floating pill: notched surface, sliding puck, four destinations.
  Widget _bar(Duration duration) {
    final List<int> indices = _barIndices;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        // The slot the notch occupies, kept clear of any destination. It is
        // sized to the dock rather than to the cut, so the icons beside it
        // stay clear of the halo too.
        final double gap = AppBottomNav.notchRadius * 2 + AppSpacing.xxs;
        // The pill's corners curve inward at label height, so the row is held
        // off both ends rather than running the full width.
        const double inset = AppSpacing.xs;
        final double slot = (width - gap - inset * 2) / indices.length;
        final int leftCount = indices.length ~/ 2;

        double leftOf(int position) =>
            inset +
            (position < leftCount ? slot * position : gap + slot * position);

        final int active = indices.indexOf(widget.currentIndex);

        return CustomPaint(
          painter: _NotchedBarPainter(
            notchCentre: width / 2,
            notchRadius: AppBottomNav.notchRadius,
            notchDip: AppBottomNav.notchDip,
          ),
          child: Stack(
            children: <Widget>[
              if (active >= 0)
                AnimatedPositioned(
                  duration: duration,
                  curve: AppCurves.stateChange,
                  left: leftOf(active) + AppSpacing.xxs,
                  width: slot - AppSpacing.xxs * 2,
                  top: AppSpacing.xs,
                  bottom: AppSpacing.xs,
                  child: const _ActivePuck(),
                ),
              Row(
                children: <Widget>[
                  const SizedBox(width: inset),
                  for (
                    int position = 0;
                    position < indices.length;
                    position++
                  ) ...<Widget>[
                    if (position == leftCount) SizedBox(width: gap),
                    SizedBox(
                      width: slot,
                      child: _BarDestination(
                        mark: widget.marks[indices[position]],
                        label: widget.labels[indices[position]],
                        active: indices[position] == widget.currentIndex,
                        duration: duration,
                        onTap: () => widget.onSelect(indices[position]),
                      ),
                    ),
                  ],
                ],
              ),
              // The Coach keeps a label like every other destination; it just
              // sits in the strip of bar left under the notch, on the same
              // baseline as the four beside it.
              Positioned(
                left: width / 2 - gap / 2,
                width: gap,
                top: AppBottomNav.notchDip + AppBottomNav.notchRadius,
                child: _CoachLabel(
                  label: widget.labels[widget.aiIndex],
                  active: widget.currentIndex == widget.aiIndex,
                  duration: duration,
                  onTap: () => widget.onSelect(widget.aiIndex),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The Coach's destination label, rendered inside the bar beneath the dock.
class _CoachLabel extends StatelessWidget {
  const _CoachLabel({
    required this.label,
    required this.active,
    required this.duration,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: AnimatedDefaultTextStyle(
            duration: duration,
            curve: AppCurves.stateChange,
            style: AppTypography.navLabel.copyWith(
              color: active ? AppColors.aiBlue : AppColors.textSecondary,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
            child: Text(label, maxLines: 1, softWrap: false),
          ),
        ),
      ),
    );
  }
}

/// Paints the pill: a rounded navy surface with a circular bite taken out of
/// the top centre, eased in and out of the top edge so the cut reads as a
/// curve rather than as two corners.
class _NotchedBarPainter extends CustomPainter {
  const _NotchedBarPainter({
    required this.notchCentre,
    required this.notchRadius,
    required this.notchDip,
  });

  final double notchCentre;
  final double notchRadius;
  final double notchDip;

  /// Horizontal run of the ease either side of the cut.
  static const double _transition = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = _path(size);

    canvas
      ..drawPath(
        path,
        Paint()
          ..color = AppColors.navyDeep
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
      )
      ..drawPath(
        path,
        Paint()
          ..shader = AppGradients.card.createShader(
            Rect.fromLTWH(0, 0, size.width, size.height),
          ),
      )
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppBorders.hairline
          ..color = AppColors.hairline,
      );
  }

  Path _path(Size size) {
    final double corner = size.height / 2;
    final double left = notchCentre - notchRadius;
    final double right = notchCentre + notchRadius;

    return Path()
      ..moveTo(0, corner)
      ..arcToPoint(Offset(corner, 0), radius: Radius.circular(corner))
      ..lineTo(left - _transition, 0)
      ..quadraticBezierTo(left - _transition * 0.25, 0, left, notchDip * 0.4)
      // Sweeping the angle down from pi to zero takes the arc under the top
      // edge, which is the bite the dock sits in.
      ..arcTo(
        Rect.fromCircle(
          center: Offset(notchCentre, notchDip),
          radius: notchRadius,
        ),
        math.pi,
        -math.pi,
        false,
      )
      ..quadraticBezierTo(right + _transition * 0.25, 0, right + _transition, 0)
      ..lineTo(size.width - corner, 0)
      ..arcToPoint(Offset(size.width, corner), radius: Radius.circular(corner))
      ..lineTo(size.width, size.height - corner)
      ..arcToPoint(
        Offset(size.width - corner, size.height),
        radius: Radius.circular(corner),
      )
      ..lineTo(corner, size.height)
      ..arcToPoint(
        Offset(0, size.height - corner),
        radius: Radius.circular(corner),
      )
      ..close();
  }

  @override
  bool shouldRepaint(_NotchedBarPainter old) =>
      old.notchCentre != notchCentre ||
      old.notchRadius != notchRadius ||
      old.notchDip != notchDip;
}

/// The gold wash that slides beneath the active destination.
class _ActivePuck extends StatelessWidget {
  const _ActivePuck();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.input + 4),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.gold.withValues(alpha: 0.18),
            AppColors.gold.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: AppColors.goldHairline),
      ),
    );
  }
}

/// One of the four destinations that stay in the bar.
class _BarDestination extends StatelessWidget {
  const _BarDestination({
    required this.mark,
    required this.label,
    required this.active,
    required this.duration,
    required this.onTap,
  });

  final AppIconMark mark;
  final String label;
  final bool active;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = active ? AppColors.gold : AppColors.textSecondary;

    return Semantics(
      button: true,
      selected: active,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedScale(
              duration: duration,
              curve: AppCurves.stateChange,
              scale: active ? 1.08 : 1,
              child: AppIcon(mark: mark, color: color, size: 20),
            ),
            const SizedBox(height: AppSpacing.xxs),
            // Scaled down rather than clipped: the Portuguese labels run
            // longer than the English ones and still have to fit the slot.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedDefaultTextStyle(
                  duration: duration,
                  curve: AppCurves.stateChange,
                  style: AppTypography.navLabel.copyWith(
                    color: color,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Text(label, maxLines: 1, softWrap: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The raised Coach entry point.
///
/// The one AI Blue affordance in the chrome, and the only element that keeps
/// moving at rest: a halo breathes out of it so the Coach reads as available
/// from anywhere in the app.
class _CoachDock extends StatelessWidget {
  const _CoachDock({
    required this.mark,
    required this.label,
    required this.active,
    required this.breath,
    required this.onTap,
  });

  final AppIconMark mark;
  final String label;
  final bool active;
  final Animation<double> breath;
  final VoidCallback onTap;

  static const double _radius = AppBottomNav.dockRadius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: AppBottomNav.dockBox,
          height: AppBottomNav.dockBox,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[_halo(), _disc()],
            ),
          ),
        ),
      ),
    );
  }

  /// A ring that widens and fades as it goes, on the ambient pulse.
  Widget _halo() {
    return AnimatedBuilder(
      animation: breath,
      builder: (BuildContext context, _) {
        final double t = AppCurves.ambient.transform(breath.value);
        final double size = _radius * 2 + 8 + t * 12;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.aiBlue.withValues(
                alpha: (active ? 0.34 : 0.20) * (1 - t),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _disc() {
    return Container(
      width: _radius * 2,
      height: _radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.aiBlue,
            AppColors.aiBlue.withValues(alpha: 0.58),
          ],
        ),
        // The ring of background that separates the disc from the notch.
        border: Border.all(
          color: AppColors.navyDeep,
          width: AppBorders.emphasis + 1.5,
        ),
        boxShadow: active ? AppShadows.blueGlowStrong : AppShadows.blueGlow,
      ),
      child: Center(
        child: AppIcon(mark: mark, color: AppColors.navyDeep, size: 24),
      ),
    );
  }
}

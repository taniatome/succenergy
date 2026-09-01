import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/motion/app_curves.dart';
import '../../core/motion/app_durations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/animated_reveal.dart';
import '../../core/widgets/branding/succenergy_logo.dart';
import '../../core/widgets/branding/succenergy_wordmark.dart';
import '../../core/widgets/buttons/primary_button.dart';
import '../../core/widgets/buttons/secondary_button.dart';
import 'widgets/author_attribution.dart';
import 'widgets/earth_glow_painter.dart';
import 'widgets/starfield_painter.dart';
import 'widgets/welcome_tagline.dart';

/// The first screen after launch.
///
/// The closest screen to the approved reference artwork: symbol, wordmark,
/// tagline and authorship centred in the sky, with the two ways in sitting
/// together above the lit curve of the Earth.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _horizon = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  /// The ambient cycle the sunrise bloom drifts through. Slow enough to be
  /// felt rather than watched, and stopped entirely under reduced motion.
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: AppDurations.ambientDrift,
  );

  late final Animation<double> _reveal = CurvedAnimation(
    parent: _horizon,
    curve: AppCurves.entrance,
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
      _horizon.value = 1;
      return;
    }
    _horizon.forward();
    _drift.repeat();
  }

  @override
  void dispose() {
    _horizon.dispose();
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          RepaintBoundary(child: _sky()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.maxContentWidth,
                ),
                child: Column(
                  children: <Widget>[
                    Expanded(child: _brand(context)),
                    _actions(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The starfield and the horizon, on one ticker so they arrive together.
  Widget _sky() {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_reveal, _drift]),
      builder: (BuildContext context, Widget? child) {
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CustomPaint(
              painter: StarfieldPainter(
                reveal: _reveal.value,
                horizonFraction: EarthGlowPainter.horizonFraction,
              ),
            ),
            CustomPaint(
              painter: EarthGlowPainter(
                reveal: _reveal.value,
                drift: _drift.value,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Symbol, lockup, tagline and authorship, centred in the space above the
  /// actions. Scrolls only when the screen is too short to hold it.
  Widget _brand(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH,
              vertical: AppSpacing.lg,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const AnimatedReveal(
                    index: 0,
                    child: SuccenergyLogo(size: 116),
                  ),
                  const AnimatedReveal(
                    index: 1,
                    child: SuccenergyWordmark(fullBleed: true),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const AnimatedReveal(index: 2, child: WelcomeTagline()),
                  const SizedBox(height: AppSpacing.xl),
                  const AnimatedReveal(index: 3, child: AuthorAttribution()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The two ways in, one above the other and the same size.
  ///
  /// The filled gold action is the journey; the outlined gold action is the
  /// account that already exists. Both are unmistakably buttons, and the fill
  /// is what keeps the order between them readable. The bottom gap clears the
  /// Earth's curve, which the painter sizes from the same fraction.
  Widget _actions(BuildContext context) {
    final double horizonGap =
        MediaQuery.sizeOf(context).height * EarthGlowPainter.horizonFraction +
        AppSpacing.xl;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        0,
        AppSpacing.screenH,
        horizonGap,
      ),
      child: Column(
        children: <Widget>[
          AnimatedReveal(
            index: 4,
            child: PrimaryButton(
              label: context.tr('welcome.cta'),
              emphasis: context.tr('welcome.ctaEmphasis'),
              icon: Icons.chevron_right_rounded,
              onPressed: () => context.go(Routes.language),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedReveal(
            index: 5,
            child: SecondaryButton(
              label: context.tr('welcome.login'),
              onPressed: () => context.go(Routes.login),
            ),
          ),
        ],
      ),
    );
  }
}

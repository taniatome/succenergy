import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/motion/app_curves.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/animated_reveal.dart';
import '../../core/widgets/branding/succenergy_logo.dart';
import '../../core/widgets/branding/succenergy_wordmark.dart';
import '../../core/widgets/buttons/secondary_button.dart';
import '../../core/widgets/buttons/text_link_button.dart';
import 'widgets/author_attribution.dart';
import 'widgets/earth_glow_painter.dart';
import 'widgets/welcome_tagline.dart';

/// The first screen after launch.
///
/// The closest screen to the approved reference artwork: symbol, wordmark,
/// tagline, authorship, and a single glowing call to action above the lit
/// curve of the Earth.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _horizon = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
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
  }

  @override
  void dispose() {
    _horizon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _reveal,
              builder: (BuildContext context, Widget? child) {
                return CustomPaint(
                  painter: EarthGlowPainter(reveal: _reveal.value),
                );
              },
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.maxContentWidth,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    AppSpacing.lg,
                    AppSpacing.screenH,
                    150,
                  ),
                  child: _content(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const AnimatedReveal(index: 0, child: SuccenergyLogo(size: 116)),
        const AnimatedReveal(
          index: 1,
          child: SuccenergyWordmark(fullBleed: true),
        ),
        const SizedBox(height: AppSpacing.lg),
        const AnimatedReveal(index: 2, child: WelcomeTagline()),
        const SizedBox(height: AppSpacing.xl),
        const AnimatedReveal(index: 3, child: AuthorAttribution()),
        const SizedBox(height: AppSpacing.xl),
        AnimatedReveal(
          index: 4,
          child: SecondaryButton(
            label: context.tr('welcome.cta'),
            emphasis: context.tr('welcome.ctaEmphasis'),
            icon: Icons.chevron_right_rounded,
            onPressed: () => context.go(Routes.language),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AnimatedReveal(
          index: 5,
          child: TextLinkButton(
            label: context.tr('welcome.login'),
            onPressed: () => context.go(Routes.login),
          ),
        ),
      ],
    );
  }
}

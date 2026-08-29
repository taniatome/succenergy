import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/motion/app_curves.dart';
import '../../core/motion/app_durations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/branding/succenergy_logo.dart';
import '../../core/widgets/branding/succenergy_wordmark.dart';
import '../../data/repositories/auth_repository.dart';

/// The launch screen.
///
/// The symbol resolves out of a radial bloom that expands behind it, the
/// wordmark settles beneath, and the app moves on. This is the first thing
/// seen on every launch, so it is given room to land.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.splashHold,
  );

  late final Animation<double> _bloom = _interval(0, 0.55);
  late final Animation<double> _symbol = _interval(0.06, 0.46);
  late final Animation<double> _wordmark = _interval(0.32, 0.66);
  late final Animation<double> _rule = _interval(0.58, 0.84);

  bool _started = false;

  Animation<double> _interval(double begin, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: AppCurves.entrance),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.value = 1;
      Future<void>.delayed(AppDurations.medium, _leave);
      return;
    }
    _controller.forward().whenComplete(_leave);
  }

  void _leave() {
    if (!mounted) {
      return;
    }
    final bool loggedIn = context.read<AuthRepository>().isLoggedIn;
    context.go(loggedIn ? Routes.dashboard : Routes.welcome);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildSymbol(),
                const SizedBox(height: AppSpacing.xs),
                _buildWordmark(),
                const SizedBox(height: AppSpacing.lg),
                _buildRule(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSymbol() {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Opacity(
            opacity: (_bloom.value * 0.9).clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.45 + _bloom.value * 0.75,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      AppColors.gold.withValues(alpha: 0.30),
                      AppColors.gold.withValues(alpha: 0.08),
                      AppColors.transparent,
                    ],
                    stops: const <double>[0, 0.42, 0.78],
                  ),
                ),
              ),
            ),
          ),
          Opacity(
            opacity: _symbol.value,
            child: Transform.scale(
              scale: 0.88 + _symbol.value * 0.12,
              child: const SuccenergyLogo(size: 138, bloom: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordmark() {
    return Opacity(
      opacity: _wordmark.value,
      child: Transform.translate(
        offset: Offset(0, 12 * (1 - _wordmark.value)),
        child: const SuccenergyWordmark(fullBleed: true),
      ),
    );
  }

  Widget _buildRule() {
    return Opacity(
      opacity: _rule.value,
      child: Container(
        height: 1,
        width: 120 * _rule.value,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              AppColors.transparent,
              AppColors.gold.withValues(alpha: 0.55),
              AppColors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

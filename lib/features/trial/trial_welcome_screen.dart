import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/animated_reveal.dart';
import '../../core/widgets/branding/succenergy_logo.dart';
import '../../core/widgets/buttons/primary_button.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/section_eyebrow.dart';
import 'widgets/welcome_bloom.dart';

/// The moment after the trial is taken.
///
/// One screen, one line, one way on: the client's exact welcome sentence over
/// a gold bloom, dismissing into the four remaining onboarding questions and
/// from there into the app. It is reached once, from the trial action, so it
/// is never a permanent fixture anywhere.
class TrialWelcomeScreen extends StatelessWidget {
  const TrialWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        glowTint: AppColors.gold,
        glowAlignment: Alignment.center,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxContentWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenH,
                  vertical: AppSpacing.xl,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const WelcomeBloom(
                      child: SuccenergyLogo(size: 108, bloom: false),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AnimatedReveal(
                      index: 1,
                      child: SectionEyebrow(
                        label: context.tr('trialWelcome.eyebrow'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AnimatedReveal(
                      index: 2,
                      child: Text(
                        context.tr('trialWelcome.message'),
                        style: AppTypography.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AnimatedReveal(
                      index: 4,
                      child: PrimaryButton(
                        label: context.tr('common.continue'),
                        onPressed: () => context.go(Routes.onboarding),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

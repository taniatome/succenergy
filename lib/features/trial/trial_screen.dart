import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/animated_reveal.dart';
import '../../core/widgets/buttons/primary_button.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/section_eyebrow.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import 'widgets/trial_offer_card.dart';
import 'widgets/trial_unlock_list.dart';

/// The paywall, between registration and the four onboarding questions.
///
/// The app is free to download and nothing inside it opens until the trial is
/// taken. No payment runs here: the CTA sets the mock subscription flag on the
/// auth repository, which is the flag the router gates the app on.
class TrialScreen extends StatefulWidget {
  const TrialScreen({super.key});

  @override
  State<TrialScreen> createState() => _TrialScreenState();
}

class _TrialScreenState extends State<TrialScreen> {
  bool _busy = false;

  Future<void> _start() async {
    setState(() => _busy = true);
    await context.read<AuthRepository>().startTrial();
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    context.go(Routes.trialWelcome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        glowTint: AppColors.gold,
        glowAlignment: const Alignment(0, -0.75),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxContentWidth,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenH,
                  vertical: AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _sections(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context) {
    final UserActivity activity =
        context.read<AuthRepository>().currentUser?.activity ??
        UserActivity.professional;
    final String monthlyPrice =
        activity == UserActivity.studentMinorities
            ? AppConstants.studentMonthlyPrice
            : AppConstants.professionalMonthlyPrice;

    return <Widget>[
      AnimatedReveal(
        index: 0,
        child: SectionEyebrow(label: context.tr('trial.eyebrow')),
      ),
      const SizedBox(height: AppSpacing.sm),
      AnimatedReveal(
        index: 1,
        child: Text(
          context.tr('trial.title'),
          style: AppTypography.displayMedium,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      AnimatedReveal(
        index: 2,
        child: Text(
          context.tr('trial.subtitle'),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(index: 3, child: TrialOfferCard(activity: activity)),
      const SizedBox(height: AppSpacing.sm),
      AnimatedReveal(
        index: 4,
        child: TrialUnlockList(unlockKeys: MockData.trialUnlockKeys),
      ),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(
        index: 5,
        child: PrimaryButton(
          label: context.tr('trial.cta'),
          isBusy: _busy,
          onPressed: _start,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      AnimatedReveal(
        index: 6,
        child: Text(
          context.tr(
            'trial.smallPrint',
            params: <String, String>{
              'price': monthlyPrice,
              'days': '${AppConstants.trialDays}',
            },
          ),
          style: AppTypography.caption,
          textAlign: TextAlign.center,
        ),
      ),
    ];
  }
}

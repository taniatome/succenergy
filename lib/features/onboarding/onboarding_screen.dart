import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/motion/app_curves.dart';
import '../../core/motion/app_durations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/buttons/primary_button.dart';
import '../../core/widgets/buttons/text_link_button.dart';
import '../../core/widgets/screen_background.dart';
import '../../data/models/onboarding_response.dart';
import 'onboarding_provider.dart';
import 'widgets/free_text_question.dart';
import 'widgets/multi_select_question.dart';
import 'widgets/onboarding_progress_bar.dart';
import 'widgets/onboarding_summary.dart';
import 'widgets/scale_question.dart';

/// The seven-question assessment, one question per screen, closing on a
/// summary of what the coach heard.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingProvider provider = context.watch<OnboardingProvider>();

    return Scaffold(
      body: ScreenBackground(
        glowTint: AppColors.gold,
        glowAlignment: const Alignment(0, -0.9),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxContentWidth,
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH,
                      AppSpacing.md,
                      AppSpacing.screenH,
                      0,
                    ),
                    child: OnboardingProgressBar(
                      progress: provider.progress,
                      label:
                          provider.isSummary
                              ? context.tr('onboarding.summary.eyebrow')
                              : context.tr(
                                'onboarding.progress',
                                params: <String, String>{
                                  'current': '${provider.step + 1}',
                                  'total':
                                      '${AppConstants.onboardingQuestionCount}',
                                },
                              ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenH,
                        AppSpacing.xl,
                        AppSpacing.screenH,
                        AppSpacing.lg,
                      ),
                      child: AnimatedSwitcher(
                        duration: AppDurations.medium,
                        switchInCurve: AppCurves.entrance,
                        switchOutCurve: AppCurves.exit,
                        child: KeyedSubtree(
                          key: ValueKey<int>(provider.step),
                          child: _body(context, provider),
                        ),
                      ),
                    ),
                  ),
                  _footer(context, provider),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, OnboardingProvider p) {
    if (p.isSummary) {
      return OnboardingSummary(response: p.draft);
    }
    switch (p.step) {
      case 1:
        return MultiSelectQuestion(
          title: context.tr('onboarding.q2.title'),
          help: context.tr('onboarding.q2.help'),
          optionKeys: OnboardingProvider.focusAreaOptions,
          selectedKeys: p.draft.focusAreaKeys,
          onToggle: p.toggleFocusArea,
        );
      case 3:
        return MultiSelectQuestion(
          title: context.tr('onboarding.q4.title'),
          help: context.tr('onboarding.q4.help'),
          optionKeys: OnboardingProvider.priorityOptions,
          selectedKeys: p.draft.priorityKeys,
          onToggle: p.togglePriority,
        );
      case 5:
        return ScaleQuestion(
          title: context.tr('onboarding.q6.title'),
          help: context.tr('onboarding.q6.help'),
          lowLabel: context.tr('onboarding.q6.scaleMin'),
          highLabel: context.tr('onboarding.q6.scaleMax'),
          value: p.draft.motivationBalance,
          onChanged: p.setMotivation,
        );
      default:
        return _freeText(context, p);
    }
  }

  Widget _freeText(BuildContext context, OnboardingProvider p) {
    final int q = p.step + 1;
    final String locale = context.localeCode;
    final String value = switch (p.step) {
      0 => OnboardingResponse.textFor(p.draft.ambition, locale),
      2 => OnboardingResponse.textFor(p.draft.challenge, locale),
      4 => OnboardingResponse.textFor(p.draft.mainGoals, locale),
      _ => OnboardingResponse.textFor(p.draft.successVision, locale),
    };
    final ValueChanged<String> onChanged = switch (p.step) {
      0 => p.setAmbition,
      2 => p.setChallenge,
      4 => p.setMainGoals,
      _ => p.setSuccessVision,
    };
    return FreeTextQuestion(
      title: context.tr('onboarding.q$q.title'),
      help: context.tr('onboarding.q$q.help'),
      hint: context.tr('onboarding.q$q.hint'),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _footer(BuildContext context, OnboardingProvider p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        0,
        AppSpacing.screenH,
        AppSpacing.md,
      ),
      child: Column(
        children: <Widget>[
          PrimaryButton(
            label:
                p.isSummary
                    ? context.tr('onboarding.summary.cta')
                    : context.tr('common.continue'),
            isBusy: p.saving,
            onPressed: p.canAdvance ? () => _advance(context, p) : null,
          ),
          if (p.step > 0)
            TextLinkButton(label: context.tr('common.back'), onPressed: p.back),
        ],
      ),
    );
  }

  Future<void> _advance(BuildContext context, OnboardingProvider p) async {
    if (!p.isSummary) {
      p.next();
      return;
    }
    await p.save();
    if (context.mounted) {
      context.go(Routes.dashboard);
    }
  }
}

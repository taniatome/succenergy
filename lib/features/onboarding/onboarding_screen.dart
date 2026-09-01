import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/motion/app_curves.dart';
import '../../core/motion/app_durations.dart';
import '../../core/services/notification_permission.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/buttons/primary_button.dart';
import '../../core/widgets/buttons/text_link_button.dart';
import '../../core/widgets/questions/free_text_question.dart';
import '../../core/widgets/questions/multi_select_question.dart';
import '../../core/widgets/questions/question_progress_bar.dart';
import '../../core/widgets/questions/scale_question.dart';
import '../../core/widgets/screen_background.dart';
import '../../data/models/onboarding_response.dart';
import 'onboarding_provider.dart';
import 'widgets/onboarding_summary.dart';

/// The four questions asked after registration, one per screen, closing on a
/// summary of what the coach heard across all seven.
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
                  _header(context, provider),
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

  Widget _header(BuildContext context, OnboardingProvider p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.md,
        AppSpacing.screenH,
        0,
      ),
      child: QuestionProgressBar(
        progress: p.progress,
        label:
            p.isSummary
                ? context.tr('onboarding.summary.eyebrow')
                : context.tr(
                  'onboarding.progress',
                  params: <String, String>{
                    'current': '${p.step + 1}',
                    'total': '${AppConstants.onboardingQuestionCount}',
                  },
                ),
      ),
    );
  }

  Widget _body(BuildContext context, OnboardingProvider p) {
    if (p.isSummary) {
      return OnboardingSummary(response: p.draft);
    }
    switch (p.step) {
      case 0:
        return MultiSelectQuestion(
          title: context.tr('onboarding.q4.title'),
          help: context.tr('onboarding.q4.help'),
          optionKeys: OnboardingProvider.priorityOptions,
          selectedKeys: p.draft.priorityKeys,
          onToggle: p.togglePriority,
        );
      case 2:
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
    final bool goals = p.step == 1;
    final String q = goals ? 'onboarding.q5' : 'onboarding.q7';
    final String locale = context.localeCode;
    return FreeTextQuestion(
      title: context.tr('$q.title'),
      help: context.tr('$q.help'),
      hint: context.tr('$q.hint'),
      value: OnboardingResponse.textFor(
        goals ? p.draft.mainGoals : p.draft.successVision,
        locale,
      ),
      onChanged: goals ? p.setMainGoals : p.setSuccessVision,
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

  /// The last step both saves the assessment and asks for notification
  /// permission: this is the first entry into the app proper, and the moment
  /// the native prompt belongs.
  ///
  /// The request is not awaited. The system dialog sits over the Dashboard on
  /// its own, and whether the user has answered it is not something the app
  /// should hold the journey open for.
  Future<void> _advance(BuildContext context, OnboardingProvider p) async {
    if (!p.isSummary) {
      p.next();
      return;
    }
    await p.save();
    unawaited(NotificationPermission.requestOnce());
    if (context.mounted) {
      context.go(Routes.dashboard);
    }
  }
}

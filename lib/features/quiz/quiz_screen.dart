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
import '../../core/widgets/questions/free_text_question.dart';
import '../../core/widgets/questions/multi_select_question.dart';
import '../../core/widgets/questions/question_progress_bar.dart';
import '../../core/widgets/screen_background.dart';
import '../../data/models/onboarding_response.dart';
import 'quiz_provider.dart';

/// The three questions asked before registration.
///
/// The same treatment as the onboarding assessment that follows the account:
/// one question per screen, the gold rule above, the answer carried forward.
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QuizProvider provider = context.watch<QuizProvider>();

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

  Widget _header(BuildContext context, QuizProvider p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.md,
        AppSpacing.screenH,
        0,
      ),
      child: QuestionProgressBar(
        progress: p.progress,
        label: context.tr(
          'onboarding.progress',
          params: <String, String>{
            'current': '${p.step + 1}',
            'total': '${AppConstants.quizQuestionCount}',
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, QuizProvider p) {
    if (p.step == 1) {
      return MultiSelectQuestion(
        title: context.tr('onboarding.q2.title'),
        help: context.tr('onboarding.q2.help'),
        optionKeys: QuizProvider.focusAreaOptions,
        selectedKeys: p.focusAreaKeys,
        onToggle: p.toggleFocusArea,
      );
    }
    final String locale = context.localeCode;
    final bool first = p.step == 0;
    return FreeTextQuestion(
      title: context.tr(first ? 'onboarding.q1.title' : 'onboarding.q3.title'),
      help: context.tr(first ? 'onboarding.q1.help' : 'onboarding.q3.help'),
      hint: context.tr(first ? 'onboarding.q1.hint' : 'onboarding.q3.hint'),
      value: OnboardingResponse.textFor(
        first ? p.ambition : p.challenge,
        locale,
      ),
      onChanged: first ? p.setAmbition : p.setChallenge,
    );
  }

  Widget _footer(BuildContext context, QuizProvider p) {
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
                p.isLast
                    ? context.tr('quiz.cta')
                    : context.tr('common.continue'),
            isBusy: p.saving,
            onPressed: p.canAdvance ? () => _advance(context, p) : null,
          ),
          TextLinkButton(
            label: context.tr('common.back'),
            onPressed: p.step > 0 ? p.back : () => context.go(Routes.language),
          ),
        ],
      ),
    );
  }

  Future<void> _advance(BuildContext context, QuizProvider p) async {
    if (!p.isLast) {
      p.next();
      return;
    }
    await p.save();
    if (context.mounted) {
      context.go(Routes.register);
    }
  }
}

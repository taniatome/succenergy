import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/animated_reveal.dart';
import '../../core/widgets/buttons/primary_button.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/section_eyebrow.dart';
import 'widgets/language_option_card.dart';

/// Language choice, offered before the account is created.
///
/// Selecting a card switches the whole app immediately, so the reviewer sees
/// the effect on this screen before continuing.
class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LocaleProvider locale = context.watch<LocaleProvider>();

    return Scaffold(
      body: ScreenBackground(
        glowTint: AppColors.gold,
        glowAlignment: const Alignment(0, -0.8),
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
                child: _content(context, locale),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The heading, the two language cards and the action, in one column.
  Widget _content(BuildContext context, LocaleProvider locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AnimatedReveal(
          index: 0,
          child: SectionEyebrow(label: context.tr('language.eyebrow')),
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedReveal(
          index: 1,
          child: Text(
            context.tr('language.title'),
            style: AppTypography.displayMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedReveal(
          index: 2,
          child: Text(
            context.tr('language.subtitle'),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AnimatedReveal(
          index: 3,
          child: LanguageOptionCard(
            code: 'en',
            name: context.tr('language.english'),
            nativeName: context.tr('language.englishNative'),
            selected: locale.code == 'en',
            onTap: () => locale.setLocale('en'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedReveal(
          index: 4,
          child: LanguageOptionCard(
            code: 'pt',
            name: context.tr('language.portuguese'),
            nativeName: context.tr('language.portugueseNative'),
            selected: locale.code == 'pt',
            onTap: () => locale.setLocale('pt'),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AnimatedReveal(
          index: 5,
          child: PrimaryButton(
            label: context.tr('language.confirm'),
            onPressed: () => context.go(Routes.quiz),
          ),
        ),
      ],
    );
  }
}

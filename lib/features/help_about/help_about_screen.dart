import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/animated_reveal.dart';
import '../../core/widgets/branding/succenergy_logo.dart';
import '../../core/widgets/branding/succenergy_wordmark.dart';
import '../../core/widgets/buttons/text_link_button.dart';
import '../../core/widgets/cards/glow_card.dart';
import '../../core/widgets/section_eyebrow.dart';
import 'widgets/faq_accordion.dart';

/// App identity, the Succenergy attribution, the FAQ and contact routes.
class HelpAboutScreen extends StatelessWidget {
  const HelpAboutScreen({super.key});

  static const String _version = '1.0.0';
  static const int _faqCount = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(context.tr('help.title')),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxContentWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                AppSpacing.xl + AppSpacing.md,
                AppSpacing.screenH,
                AppSpacing.xxl,
              ),
              children: _sections(context),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context) {
    return <Widget>[
      const AnimatedReveal(
        index: 0,
        child: Center(child: SuccenergyLogo(size: 92)),
      ),
      const AnimatedReveal(
        index: 1,
        child: SuccenergyWordmark(fullBleed: true),
      ),
      const SizedBox(height: AppSpacing.md),
      AnimatedReveal(
        index: 2,
        child: Center(
          child: Text(
            context.tr(
              'help.version',
              params: const <String, String>{'version': _version},
            ),
            style: AppTypography.caption,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
      AnimatedReveal(index: 3, child: _about(context)),
      const SizedBox(height: AppSpacing.xl),
      AnimatedReveal(
        index: 4,
        child: SectionEyebrow(
          label: context.tr('help.faq.eyebrow'),
          withRule: true,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      for (int i = 1; i <= _faqCount; i++) ...<Widget>[
        AnimatedReveal(
          index: 4 + i,
          child: FaqAccordion(
            question: context.tr('help.faq.q$i'),
            answer: context.tr('help.faq.a$i'),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
      const SizedBox(height: AppSpacing.xl),
      AnimatedReveal(index: 10, child: _contact(context)),
    ];
  }

  Widget _about(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionEyebrow(label: context.tr('help.about.eyebrow'), withRule: true),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.tr('help.about.body'),
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          context.tr('help.about.attribution'),
          style: AppTypography.caption.copyWith(color: AppColors.gold),
        ),
      ],
    );
  }

  Widget _contact(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionEyebrow(label: context.tr('help.contact.eyebrow')),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              const Icon(
                Icons.mail_outline_rounded,
                size: 17,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.tr('help.contact.email'),
                      style: AppTypography.bodyMedium,
                    ),
                    Text(
                      context.tr('help.contact.emailValue'),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              TextLinkButton(
                label: context.tr('help.legal.terms'),
                onPressed: () {},
              ),
              TextLinkButton(
                label: context.tr('help.legal.privacy'),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

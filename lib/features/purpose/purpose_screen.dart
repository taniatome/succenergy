import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/animated_reveal.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/cycle_ring/cycle_ring.dart';
import '../../core/widgets/progress_indicators.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/section_eyebrow.dart';
import 'purpose_provider.dart';
import 'widgets/purpose_prompt_card.dart';

/// Guided exploration of the first principle: talents, strengths, values,
/// direction and aspirations, with every answer saved and editable.
class PurposeScreen extends StatefulWidget {
  const PurposeScreen({super.key});

  @override
  State<PurposeScreen> createState() => _PurposeScreenState();
}

class _PurposeScreenState extends State<PurposeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PurposeProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final PurposeProvider p = context.watch<PurposeProvider>();

    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
      extendBodyBehindAppBar: true,
      body: ScreenBackground(
        glowTint: AppColors.gold,
        glowAlignment: const Alignment(0, -0.8),
        child: SafeArea(
          child:
              p.loading
                  ? const Center(child: AppLoader())
                  : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppConstants.maxContentWidth,
                      ),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenH,
                          AppSpacing.xl,
                          AppSpacing.screenH,
                          AppSpacing.xxl,
                        ),
                        children: _sections(context, p),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context, PurposeProvider p) {
    final int total = PurposeProvider.promptIds.length;

    return <Widget>[
      AnimatedReveal(index: 0, child: _header(context, p, total)),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(
        index: 1,
        child: Text(
          context.tr('purpose.intro'),
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(
        index: 2,
        child: AppProgress.bar(value: p.answeredCount / total),
      ),
      const SizedBox(height: AppSpacing.lg),
      for (int i = 0; i < total; i++) ...<Widget>[
        AnimatedReveal(
          index: 3 + i,
          child: PurposePromptCard(
            title: context.tr('purpose.prompt.${PurposeProvider.promptIds[i]}'),
            question: context.tr(
              'purpose.prompt.${PurposeProvider.promptIds[i]}.q',
            ),
            answer: p.answerFor(
              PurposeProvider.promptIds[i],
              context.localeCode,
            ),
            onSave:
                (String value) => p.save(
                  promptId: PurposeProvider.promptIds[i],
                  answer: value,
                ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    ];
  }

  Widget _header(BuildContext context, PurposeProvider p, int total) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SectionEyebrow(label: context.tr('purpose.eyebrow')),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.tr('purpose.title'),
                style: AppTypography.displayLarge.copyWith(
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),
        CycleRing(
          activeIndex: 0,
          completedCount: p.answeredCount == total ? 1 : 0,
          size: 76,
          strokeWidth: 5,
          child: Text(
            '${p.answeredCount}/$total',
            style: AppTypography.metricValueSmall.copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }
}

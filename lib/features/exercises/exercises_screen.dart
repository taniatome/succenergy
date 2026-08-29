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
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/screen_background.dart';
import '../../data/models/exercise.dart';
import 'exercises_provider.dart';
import 'widgets/exercise_card.dart';
import 'widgets/principle_selector.dart';

/// The exercise library, browsable by principle.
class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExercisesProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ExercisesProvider p = context.watch<ExercisesProvider>();

    return Scaffold(
      body: ScreenBackground(
        glowTint: AppColors.gold,
        glowAlignment: const Alignment(0, -0.95),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _header(context),
                  const SizedBox(height: AppSpacing.md),
                  PrincipleSelector(
                    principles: p.availablePrinciples,
                    selected: p.filter,
                    onSelect: p.setFilter,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(child: _list(context, p)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.md,
        AppSpacing.screenH,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.tr('exercises.title'),
            style: AppTypography.displayMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.tr('exercises.subtitle'),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, ExercisesProvider p) {
    if (p.loading) {
      return const Center(child: AppLoader());
    }
    final List<Exercise> exercises = p.visible;
    if (exercises.isEmpty) {
      return EmptyState(
        eyebrow: context.tr('exercises.title'),
        title: context.tr('exercises.empty.title'),
        body: context.tr('exercises.empty.body'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        0,
        AppSpacing.screenH,
        AppSpacing.xxl,
      ),
      itemCount: exercises.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (BuildContext context, int index) {
        final Exercise exercise = exercises[index];
        return AnimatedReveal(
          key: ValueKey<String>('${p.filter}-${exercise.id}'),
          index: index,
          child: ExerciseCard(
            exercise: exercise,
            onTap: () async {
              await context.push(Routes.exerciseSession(exercise.id));
              if (context.mounted) {
                await p.refresh();
              }
            },
          ),
        );
      },
    );
  }
}

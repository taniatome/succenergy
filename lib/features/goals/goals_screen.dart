import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/animated_reveal.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/inputs/preference_choice_row.dart';
import '../../core/widgets/screen_background.dart';
import '../../data/models/goal.dart';
import 'goals_provider.dart';
import 'widgets/goal_actions.dart';
import 'widgets/goal_card.dart';
import 'widgets/goal_overflow_menu.dart';

/// Active and completed goals, with the sheet that opens a new one.
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  /// How far ahead a newly created goal is dated, until the sheet offers a
  /// date of its own.
  static const Duration _defaultHorizon = Duration(days: 60);

  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalsProvider>().load();
    });
  }

  Future<void> _openCreateSheet() {
    return GoalActions.create(
      context: context,
      provider: context.read<GoalsProvider>(),
      defaultHorizon: _defaultHorizon,
    );
  }

  Future<void> _confirmDelete(Goal goal) async {
    final GoalsProvider provider = context.read<GoalsProvider>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String confirmation = context.tr('goals.delete.done');
    if (!await GoalActions.confirmDelete(context)) {
      return;
    }
    await provider.delete(goal.id);
    messenger.showSnackBar(SnackBar(content: Text(confirmation)));
  }

  void _onMenuAction(Goal goal, GoalMenuAction action) {
    switch (action) {
      case GoalMenuAction.edit:
        GoalActions.edit(
          context: context,
          provider: context.read<GoalsProvider>(),
          goal: goal,
        );
      case GoalMenuAction.delete:
        _confirmDelete(goal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final GoalsProvider p = context.watch<GoalsProvider>();
    final List<Goal> goals = _showCompleted ? p.completed : p.active;

    return Scaffold(
      floatingActionButton: _fab(context),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH,
                      AppSpacing.md,
                      AppSpacing.screenH,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          context.tr('goals.title'),
                          style: AppTypography.displayMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        PreferenceChoiceRow(
                          options: <String>[
                            context.tr('goals.tab.active'),
                            context.tr('goals.tab.completed'),
                          ],
                          selectedIndex: _showCompleted ? 1 : 0,
                          onSelect:
                              (int i) =>
                                  setState(() => _showCompleted = i == 1),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _list(context, p, goals)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _list(BuildContext context, GoalsProvider p, List<Goal> goals) {
    if (p.loading) {
      return const Center(child: AppLoader());
    }
    if (goals.isEmpty) {
      return EmptyState(
        eyebrow: context.tr('goals.title'),
        title:
            _showCompleted
                ? context.tr('goals.emptyCompleted.title')
                : context.tr('goals.empty.title'),
        body:
            _showCompleted
                ? context.tr('goals.emptyCompleted.body')
                : context.tr('goals.empty.body'),
        actionLabel: _showCompleted ? null : context.tr('goals.empty.cta'),
        onAction: _showCompleted ? null : _openCreateSheet,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        0,
        AppSpacing.screenH,
        AppSpacing.huge + AppSpacing.lg,
      ),
      itemCount: goals.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (BuildContext context, int index) {
        final Goal goal = goals[index];
        return AnimatedReveal(
          key: ValueKey<String>(goal.id),
          index: index,
          child: GoalCard(
            goal: goal,
            onTap: () => context.push(Routes.goalDetail(goal.id)),
            onMenuAction:
                (GoalMenuAction action) => _onMenuAction(goal, action),
          ),
        );
      },
    );
  }

  Widget _fab(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppShadows.goldGlow,
      ),
      child: FloatingActionButton(
        onPressed: _openCreateSheet,
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.navyDeep,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

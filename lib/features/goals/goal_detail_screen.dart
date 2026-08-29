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
import '../../core/widgets/buttons/secondary_button.dart';
import '../../core/widgets/buttons/text_link_button.dart';
import '../../core/widgets/cards/glow_card.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/section_eyebrow.dart';
import '../../data/models/action_item.dart';
import '../../data/models/goal.dart';
import '../../data/models/milestone.dart';
import 'goals_provider.dart';
import 'widgets/action_item_tile.dart';
import 'widgets/goal_actions.dart';
import 'widgets/goal_detail_header.dart';
import 'widgets/goal_overflow_menu.dart';
import 'widgets/milestone_timeline.dart';

/// A goal, why it matters, its milestone timeline and its action plan.
class GoalDetailScreen extends StatefulWidget {
  const GoalDetailScreen({required this.goalId, super.key});

  final String goalId;

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final GoalsProvider provider = context.read<GoalsProvider>();
      if (provider.byId(widget.goalId) == null) {
        provider.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final GoalsProvider p = context.watch<GoalsProvider>();
    final Goal? goal = p.byId(widget.goalId);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(context.tr('goals.title')),
        actions: <Widget>[
          if (goal != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: GoalOverflowMenu(
                onSelected:
                    (GoalMenuAction action) => _onMenuAction(goal, action),
              ),
            ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: ScreenBackground(
        glowTint: AppColors.gold,
        glowAlignment: const Alignment(0, -0.9),
        child: SafeArea(
          child:
              goal == null
                  ? const Center(child: AppLoader())
                  : Center(
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
                        children: _sections(context, p, goal),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context, GoalsProvider p, Goal goal) {
    return <Widget>[
      AnimatedReveal(index: 0, child: GoalDetailHeader(goal: goal)),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(index: 1, child: _why(context, goal)),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(index: 2, child: _milestones(context, p, goal)),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(index: 3, child: _actions(context, p, goal)),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(
        index: 4,
        child: SecondaryButton(
          label: context.tr('goals.detail.discuss'),
          icon: Icons.auto_awesome_outlined,
          useAiAccent: true,
          onPressed: () => context.go(Routes.coach),
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      AnimatedReveal(index: 5, child: _closeControl(context, p, goal)),
    ];
  }

  Future<void> _confirmDelete(Goal goal) async {
    final GoalsProvider provider = context.read<GoalsProvider>();
    final bool confirmed = await GoalActions.confirmDelete(context);
    if (!confirmed || !mounted) {
      return;
    }
    await provider.delete(goal.id);
    if (mounted) {
      context.pop();
    }
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

  /// Closes the goal, or reopens it. Completing here is what triggers the
  /// bloom on the ring above, because the goal's own state drives it.
  Widget _closeControl(BuildContext context, GoalsProvider p, Goal goal) {
    if (goal.isCompleted) {
      return Center(
        child: TextLinkButton(
          label: context.tr('goals.detail.reopen'),
          onPressed: () => p.setCompleted(goalId: goal.id, completed: false),
        ),
      );
    }
    return SecondaryButton(
      label: context.tr('goals.detail.markComplete'),
      icon: Icons.verified_outlined,
      onPressed: () => p.setCompleted(goalId: goal.id, completed: true),
    );
  }

  Widget _why(BuildContext context, Goal goal) {
    return GlowCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionEyebrow(label: context.tr('goals.detail.why')),
          const SizedBox(height: AppSpacing.xs),
          Text(goal.whyFor(context.localeCode), style: AppTypography.bodyLarge),
        ],
      ),
    );
  }

  Widget _milestones(BuildContext context, GoalsProvider p, Goal goal) {
    if (goal.milestones.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionEyebrow(
          label: context.tr('goals.detail.milestones'),
          withRule: true,
        ),
        const SizedBox(height: AppSpacing.md),
        MilestoneTimeline(
          milestones: goal.milestones,
          onToggle:
              (Milestone milestone, bool reached) => p.setMilestoneReached(
                goalId: goal.id,
                milestoneId: milestone.id,
                isReached: reached,
              ),
        ),
      ],
    );
  }

  Widget _actions(BuildContext context, GoalsProvider p, Goal goal) {
    if (goal.actions.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            SectionEyebrow(label: context.tr('goals.detail.actions')),
            const Spacer(),
            Text(
              context.tr(
                'goals.detail.actionsDone',
                params: <String, String>{
                  'done': '${goal.actionsDone}',
                  'total': '${goal.actions.length}',
                },
              ),
              style: AppTypography.caption,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final ActionItem action in goal.actions)
          ActionItemTile(
            action: action,
            onToggle:
                (bool done) => p.setActionDone(
                  goalId: goal.id,
                  actionId: action.id,
                  isDone: done,
                ),
          ),
      ],
    );
  }
}

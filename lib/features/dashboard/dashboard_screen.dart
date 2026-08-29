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
import '../../core/widgets/cycle_ring/cycle_ring.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/section_eyebrow.dart';
import '../../data/models/goal.dart';
import '../../data/models/user.dart';
import 'dashboard_provider.dart';
import 'widgets/active_goal_card.dart';
import 'widgets/coach_entry_card.dart';
import 'widgets/greeting_header.dart';
import 'widgets/quick_access_row.dart';
import 'widgets/quick_stats_row.dart';
import 'widgets/todays_action_card.dart';

/// The centrepiece: where the user is in the cycle, what to do today, and the
/// way into the coach.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final DashboardProvider p = context.watch<DashboardProvider>();
    final User? user = p.user;

    return Scaffold(
      body: ScreenBackground(
        glowTint: AppColors.gold,
        glowAlignment: const Alignment(0, -0.62),
        child: SafeArea(
          bottom: false,
          child:
              user == null
                  ? const Center(child: AppLoader())
                  : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppConstants.maxContentWidth,
                      ),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenH,
                          AppSpacing.md,
                          AppSpacing.screenH,
                          AppSpacing.xxl,
                        ),
                        children: _sections(context, p, user),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context, DashboardProvider p, User user) {
    final Goal? lead = p.leadGoal;

    return <Widget>[
      AnimatedReveal(
        index: 0,
        child: GreetingHeader(
          firstName: user.firstName,
          cycleDay: user.cycleDay,
          hasUnread: p.hasUnreadNotifications,
          onNotifications: () => context.push(Routes.notifications),
          onProfile: () => context.push(Routes.profile),
          onSettings: () => context.push(Routes.settings),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(index: 1, child: _ring(context, user)),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(
        index: 2,
        child: QuickStatsRow(
          dayStreak: user.dayStreak,
          activeGoals: p.activeGoals.length,
          exercisesDone: p.completedExerciseCount,
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      if (p.todaysAction != null)
        AnimatedReveal(
          index: 3,
          child: TodaysActionCard(
            title: p.todaysAction!.titleFor(context.localeCode),
            isDone: p.todaysAction!.isDone,
            onComplete: p.completeTodaysAction,
          ),
        ),
      const SizedBox(height: AppSpacing.sm),
      if (lead != null)
        AnimatedReveal(
          index: 4,
          child: ActiveGoalCard(
            goal: lead,
            onTap: () => context.push(Routes.goalDetail(lead.id)),
          ),
        ),
      const SizedBox(height: AppSpacing.sm),
      AnimatedReveal(
        index: 5,
        child: CoachEntryCard(
          goalTitle: lead?.titleFor(context.localeCode) ?? user.firstName,
          onOpen: () => context.go(Routes.coach),
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      AnimatedReveal(index: 6, child: _quickAccess(context)),
    ];
  }

  Widget _ring(BuildContext context, User user) {
    return Center(
      child: CycleRing(
        activeIndex: user.currentPrinciple.index,
        completedCount: user.currentPrinciple.index,
        size: 218,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SectionEyebrow(label: context.tr('dashboard.cycle.eyebrow')),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.tr(user.currentPrinciple.labelKey),
              style: AppTypography.displayMedium.copyWith(
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                context.tr(user.currentPrinciple.descriptionKey),
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAccess(BuildContext context) {
    return QuickAccessRow(
      items: <QuickAccessItem>[
        QuickAccessItem(
          label: context.tr('dashboard.quick.goals'),
          icon: Icons.flag_outlined,
          onTap: () => context.go(Routes.goals),
        ),
        QuickAccessItem(
          label: context.tr('dashboard.quick.exercises'),
          icon: Icons.bolt_outlined,
          onTap: () => context.go(Routes.exercises),
        ),
        QuickAccessItem(
          label: context.tr('dashboard.quick.purpose'),
          icon: Icons.explore_outlined,
          onTap: () => context.push(Routes.purpose),
        ),
        QuickAccessItem(
          label: context.tr('dashboard.quick.progress'),
          icon: Icons.insights_outlined,
          onTap: () => context.go(Routes.progress),
        ),
      ],
    );
  }
}

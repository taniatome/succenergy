import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/animated_reveal.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/screen_background.dart';
import '../../data/models/milestone.dart';
import '../../data/models/principle.dart';
import '../../data/models/progress_snapshot.dart';
import '../../data/repositories/progress_repository.dart';
import 'widgets/activity_grid.dart';
import 'widgets/chart_frame.dart';
import 'widgets/completion_chart_painter.dart';
import 'widgets/cycle_summary_card.dart';
import 'widgets/milestone_achievements.dart';
import 'widgets/principle_bars_painter.dart';
import 'widgets/progress_stat_tiles.dart';

/// Three weeks of evidence: completion over time, practice by principle,
/// day-by-day activity, and the milestones already reached.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<ProgressSnapshot> _history = const <ProgressSnapshot>[];
  Map<Principle, int> _byPrinciple = const <Principle, int>{};
  List<Milestone> _milestones = const <Milestone>[];
  Map<String, int> _stats = const <String, int>{};
  double _cycle = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final ProgressRepository repo = context.read<ProgressRepository>();
    final List<ProgressSnapshot> history = await repo.loadHistory();
    final Map<Principle, int> byPrinciple =
        await repo.loadPracticeByPrinciple();
    final List<Milestone> milestones = await repo.loadReachedMilestones();
    final Map<String, int> stats = await repo.loadHeadlineStats();
    final double cycle = await repo.loadCycleCompletion();
    if (!mounted) {
      return;
    }
    setState(() {
      _history = history;
      _byPrinciple = byPrinciple;
      _milestones = milestones;
      _stats = stats;
      _cycle = cycle;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        glowTint: AppColors.gold,
        glowAlignment: const Alignment(0, -0.95),
        child: SafeArea(
          bottom: false,
          child:
              _loading
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
                        children: _sections(context),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context) {
    return <Widget>[
      AnimatedReveal(index: 0, child: _header(context)),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(index: 1, child: ProgressStatTiles(stats: _stats)),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(index: 2, child: CycleSummaryCard(completion: _cycle)),
      const SizedBox(height: AppSpacing.sm),
      AnimatedReveal(index: 3, child: _completionChart(context)),
      const SizedBox(height: AppSpacing.sm),
      AnimatedReveal(index: 4, child: _principleChart(context)),
      const SizedBox(height: AppSpacing.sm),
      AnimatedReveal(index: 5, child: _activityChart(context)),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(
        index: 6,
        child: MilestoneAchievements(milestones: _milestones),
      ),
    ];
  }

  Widget _header(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(context.tr('progress.title'), style: AppTypography.displayMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.tr('progress.subtitle'),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _completionChart(BuildContext context) {
    return ChartFrame(
      title: context.tr('progress.chart.completion'),
      height: 132,
      builder:
          (double reveal) => CustomPaint(
            size: Size.infinite,
            painter: CompletionChartPainter(history: _history, reveal: reveal),
          ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          for (int week = 1; week <= 3; week++)
            Text(
              context.tr(
                'progress.weekLabel',
                params: <String, String>{'number': '$week'},
              ),
              style: AppTypography.metricLabel,
            ),
        ],
      ),
    );
  }

  Widget _principleChart(BuildContext context) {
    return ChartFrame(
      title: context.tr('progress.chart.byPrinciple'),
      height: 116,
      builder:
          (double reveal) => CustomPaint(
            size: Size.infinite,
            painter: PrincipleBarsPainter(counts: _byPrinciple, reveal: reveal),
          ),
      footer: Row(
        children: <Widget>[
          for (final Principle principle in Principle.values)
            Expanded(
              child: Text(
                principle.position.toString().padLeft(2, '0'),
                style: AppTypography.metricLabel,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _activityChart(BuildContext context) {
    return ChartFrame(
      title: context.tr('progress.chart.activity'),
      height: 132,
      builder:
          (double reveal) =>
              Opacity(opacity: reveal, child: ActivityGrid(history: _history)),
    );
  }
}

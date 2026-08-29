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
import '../../core/widgets/screen_background.dart';
import '../../data/models/subscription_plan.dart';
import '../../data/repositories/subscription_repository.dart';
import 'widgets/feature_comparison_table.dart';
import 'widgets/plan_card.dart';

/// The three plan tiers and what each one includes.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  List<SubscriptionPlan> _plans = const <SubscriptionPlan>[];
  List<String> _featureKeys = const <String>[];
  SubscriptionTier? _current;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final SubscriptionRepository repo = context.read<SubscriptionRepository>();
    final List<SubscriptionPlan> plans = await repo.loadPlans();
    final SubscriptionTier tier = await repo.loadCurrentTier();
    final List<String> featureKeys = await repo.loadFeatureKeys();
    if (mounted) {
      setState(() {
        _plans = plans;
        _featureKeys = featureKeys;
        _current = tier;
      });
    }
  }

  Future<void> _select(SubscriptionTier tier) async {
    final SubscriptionTier next = await context
        .read<SubscriptionRepository>()
        .selectPlan(tier);
    if (mounted) {
      setState(() => _current = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(context.tr('subscription.title')),
      ),
      extendBodyBehindAppBar: true,
      body: ScreenBackground(
        glowTint: AppColors.gold,
        glowAlignment: const Alignment(0, -0.7),
        child: SafeArea(
          child:
              _plans.isEmpty
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
      AnimatedReveal(
        index: 0,
        child: Text(
          context.tr('subscription.subtitle'),
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      for (int i = 0; i < _plans.length; i++) ...<Widget>[
        AnimatedReveal(
          index: 1 + i,
          child: PlanCard(
            plan: _plans[i],
            isCurrent: _plans[i].tier == _current,
            onSelect: () => _select(_plans[i].tier),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
      const SizedBox(height: AppSpacing.md),
      AnimatedReveal(
        index: 4,
        child: FeatureComparisonTable(
          featureKeys: _featureKeys,
          free: _plans.firstWhere(
            (SubscriptionPlan p) => p.tier == SubscriptionTier.free,
          ),
          premium: _plans.firstWhere(
            (SubscriptionPlan p) => p.tier == SubscriptionTier.annual,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      AnimatedReveal(
        index: 5,
        child: Text(
          context.tr('subscription.note'),
          style: AppTypography.caption,
          textAlign: TextAlign.center,
        ),
      ),
    ];
  }
}

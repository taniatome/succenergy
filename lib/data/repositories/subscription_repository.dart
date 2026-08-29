import '../models/subscription_plan.dart';

/// The plan catalogue and the tier the user is currently on.
abstract class SubscriptionRepository {
  Future<List<SubscriptionPlan>> loadPlans();

  Future<SubscriptionTier> loadCurrentTier();

  /// Feature rows, in the order the comparison table renders them.
  Future<List<String>> loadFeatureKeys();

  /// Selects a plan. In this build the change is local and no payment runs.
  Future<SubscriptionTier> selectPlan(SubscriptionTier tier);
}

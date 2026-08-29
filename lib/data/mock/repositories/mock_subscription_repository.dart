import '../../models/subscription_plan.dart';
import '../../repositories/subscription_repository.dart';
import '../mock_data.dart';

/// In-memory plan catalogue. Selecting a plan changes local state only; no
/// payment path exists in this build.
class MockSubscriptionRepository implements SubscriptionRepository {
  SubscriptionTier _tier = MockData.user.tier;

  @override
  Future<List<SubscriptionPlan>> loadPlans() async {
    await Future<void>.delayed(const Duration(milliseconds: 140));
    return MockData.plans;
  }

  @override
  Future<SubscriptionTier> loadCurrentTier() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _tier;
  }

  @override
  Future<List<String>> loadFeatureKeys() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return MockData.planFeatureKeys;
  }

  @override
  Future<SubscriptionTier> selectPlan(SubscriptionTier tier) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    _tier = tier;
    return _tier;
  }
}

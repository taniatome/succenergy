/// The three plan tiers offered.
enum SubscriptionTier { free, monthly, annual }

/// A purchasable plan, rendered on the Plans screen and comparison table.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.tier,
    required this.nameKey,
    required this.price,
    required this.periodKey,
    required this.featureValueKeys,
    this.annualSaving,
    this.isRecommended = false,
  });

  final SubscriptionTier tier;

  /// Localisation key for the plan name.
  final String nameKey;

  /// Price as shown, including currency symbol.
  final String price;

  /// Localisation key for the billing period line.
  final String periodKey;

  /// Feature localisation key to the value key describing this plan's level.
  final Map<String, String> featureValueKeys;

  /// Money saved against paying monthly for a year, on the annual plan only.
  final String? annualSaving;

  final bool isRecommended;

  bool get isPremium => tier != SubscriptionTier.free;
}

/// The three plan tiers offered.
///
/// The app is free to download; nothing inside it opens until the trial is
/// taken, and the monthly rate afterwards follows the activity chosen at
/// registration.
enum SubscriptionTier {
  /// Seven days of full access for a nominal amount.
  trial,

  /// Reduced monthly rate for students and minorities.
  student,

  /// Standard monthly rate.
  professional,
}

/// A purchasable plan, rendered on the Plans screen and comparison table.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.tier,
    required this.nameKey,
    required this.price,
    required this.periodKey,
    required this.featureValueKeys,
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

  /// True for the two ongoing monthly plans, false for the seven-day trial.
  bool get isMonthly => tier != SubscriptionTier.trial;
}

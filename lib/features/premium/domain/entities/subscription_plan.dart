library;

enum SubscriptionPeriod { monthly, yearly, lifetime }

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.priceString,
    required this.period,
    this.currencyCode,
    this.rcPackageIdentifier,
  });

  final String id;
  final String priceString;
  final SubscriptionPeriod period;
  final String? currencyCode;

  /// RevenueCat package identifier used for the actual purchase call
  final String? rcPackageIdentifier;

  String get periodLabel => switch (period) {
    SubscriptionPeriod.monthly => 'month',
    SubscriptionPeriod.yearly => 'year',
    SubscriptionPeriod.lifetime => 'lifetime',
  };
}

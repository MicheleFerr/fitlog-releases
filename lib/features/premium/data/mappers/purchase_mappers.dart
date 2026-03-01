library;

import 'package:gymbro_flutter_new/core/config/revenuecat_config.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_plan.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_status.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

SubscriptionPlan mapPackageToPlan(Package package) {
  final product = package.storeProduct;
  final period = _inferPeriod(package);

  return SubscriptionPlan(
    id: product.identifier,
    priceString: product.priceString,
    period: period,
    currencyCode: product.currencyCode,
    rcPackageIdentifier: package.identifier,
  );
}

SubscriptionPeriod _inferPeriod(Package package) {
  return switch (package.packageType) {
    PackageType.monthly => SubscriptionPeriod.monthly,
    PackageType.annual => SubscriptionPeriod.yearly,
    PackageType.lifetime => SubscriptionPeriod.lifetime,
    _ => _inferFromProductId(package.storeProduct.identifier),
  };
}

SubscriptionPeriod _inferFromProductId(String productId) {
  if (productId.contains('lifetime')) return SubscriptionPeriod.lifetime;
  if (productId.contains('yearly') || productId.contains('annual')) {
    return SubscriptionPeriod.yearly;
  }
  return SubscriptionPeriod.monthly;
}

SubscriptionStatus mapCustomerInfoToStatus(CustomerInfo info) {
  final entitlement = info.entitlements.all[RevenueCatConfig.premiumEntitlementId];

  if (entitlement == null || !entitlement.isActive) {
    return SubscriptionStatus.free();
  }

  final isLifetime = entitlement.expirationDate == null;
  DateTime? expirationDate;
  if (entitlement.expirationDate != null) {
    expirationDate = DateTime.tryParse(entitlement.expirationDate!);
  }

  return SubscriptionStatus(
    isActive: true,
    expirationDate: expirationDate,
    willRenew: !entitlement.willRenew,
    isLifetime: isLifetime,
    managementUrl: info.managementURL,
    productId: entitlement.productIdentifier,
  );
}

List<SubscriptionPlan> mapOfferingsToPlans(Offerings offerings) {
  final currentOffering = offerings.current;
  if (currentOffering == null) return [];

  return currentOffering.availablePackages
      .map(mapPackageToPlan)
      .toList();
}

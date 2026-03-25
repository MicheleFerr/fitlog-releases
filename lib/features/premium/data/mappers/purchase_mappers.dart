library;

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:gymbro_flutter_new/core/config/revenuecat_config.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_plan.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_status.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

SubscriptionPlan mapPackageToPlan(Package package) {
  final product = package.storeProduct;
  final period = _inferPeriod(package);
  _log(
    'mapPackageToPlan(): package=${package.identifier}, '
    'packageType=${package.packageType.name}, '
    'productId=${product.identifier}, '
    'title=${product.title}, '
    'price=${product.priceString}, '
    'currency=${product.currencyCode}, '
    'period=${period.name}',
  );

  return SubscriptionPlan(
    id: product.identifier,
    priceString: product.priceString,
    period: period,
    displayTitle: _normalizedDisplayTitle(product.title),
    currencyCode: product.currencyCode,
    rcPackageIdentifier: package.identifier,
  );
}

SubscriptionPlan mapStoreProductToPlan(StoreProduct product) {
  final period = _inferPeriodFromStoreProduct(product);
  _log(
    'mapStoreProductToPlan(): '
    'productId=${product.identifier}, '
    'title=${product.title}, '
    'price=${product.priceString}, '
    'currency=${product.currencyCode}, '
    'subscriptionPeriod=${product.subscriptionPeriod ?? '<none>'}, '
    'period=${period.name}',
  );

  return SubscriptionPlan(
    id: product.identifier,
    priceString: product.priceString,
    period: period,
    displayTitle: _normalizedDisplayTitle(product.title),
    currencyCode: product.currencyCode,
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

SubscriptionPeriod _inferPeriodFromStoreProduct(StoreProduct product) {
  final normalizedPeriod = product.subscriptionPeriod?.toUpperCase();
  return switch (normalizedPeriod) {
    'P1M' => SubscriptionPeriod.monthly,
    'P1Y' => SubscriptionPeriod.yearly,
    null => _inferFromProductId(product.identifier),
    _ => _inferFromProductId(product.identifier),
  };
}

SubscriptionPeriod _inferFromProductId(String productId) {
  final normalizedId = productId.toLowerCase();
  if (normalizedId.contains('lifetime')) return SubscriptionPeriod.lifetime;
  if (normalizedId.contains('yearly') ||
      normalizedId.contains('annual') ||
      normalizedId.contains('year')) {
    return SubscriptionPeriod.yearly;
  }
  if (normalizedId.contains('monthly') || normalizedId.contains('month')) {
    return SubscriptionPeriod.monthly;
  }
  return SubscriptionPeriod.monthly;
}

String? _normalizedDisplayTitle(String title) {
  final normalized = title.replaceAll('\n', ' ').trim();
  return normalized.isEmpty ? null : normalized;
}

SubscriptionStatus mapCustomerInfoToStatus(CustomerInfo info) {
  final entitlement =
      info.entitlements.all[RevenueCatConfig.premiumEntitlementId];

  if (entitlement == null || !entitlement.isActive) {
    _log(
      'mapCustomerInfoToStatus(): premium entitlement missing/inactive. '
      'availableEntitlements=${info.entitlements.all.keys.toList()}, '
      'activeEntitlements=${info.entitlements.active.keys.toList()}',
    );
    return SubscriptionStatus.free();
  }

  final isLifetime = entitlement.expirationDate == null;
  DateTime? expirationDate;
  if (entitlement.expirationDate != null) {
    expirationDate = DateTime.tryParse(entitlement.expirationDate!);
  }

  final status = SubscriptionStatus(
    isActive: true,
    expirationDate: expirationDate,
    willRenew: entitlement.willRenew,
    isLifetime: isLifetime,
    managementUrl: info.managementURL,
    productId: entitlement.productIdentifier,
  );

  _log(
    'mapCustomerInfoToStatus(): active=${status.isActive}, '
    'productId=${status.productId}, '
    'willRenew=${status.willRenew}, '
    'isLifetime=${status.isLifetime}, '
    'expiration=${status.expirationDate?.toIso8601String() ?? '<none>'}',
  );

  return status;
}

List<SubscriptionPlan> mapOfferingsToPlans(Offerings offerings) {
  final currentOffering =
      offerings.current ??
      (offerings.all.isNotEmpty ? offerings.all.values.first : null);
  if (currentOffering == null) {
    _log(
      'mapOfferingsToPlans(): no current offering. '
      'availableOfferings=${offerings.all.keys.toList()}',
    );
    return [];
  }

  _log(
    'mapOfferingsToPlans(): using offering=${currentOffering.identifier}, '
    'packageCount=${currentOffering.availablePackages.length}',
  );

  return currentOffering.availablePackages.map(mapPackageToPlan).toList();
}

void _log(String message) {
  if (kDebugMode) {
    debugPrint('[PurchaseMappers] $message');
  }
}

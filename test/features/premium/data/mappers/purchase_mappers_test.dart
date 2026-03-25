import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/premium/data/mappers/purchase_mappers.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_plan.dart';
import 'package:purchases_flutter/models/store_product_wrapper.dart';

void main() {
  group('mapStoreProductToPlan', () {
    test('maps a non-consumable lifetime product using the product id', () {
      const product = StoreProduct(
        'fitlog_pro_lifetime',
        'Lifetime access',
        'FitLog Pro Lifetime',
        79.99,
        '€79.99',
        'EUR',
      );

      final plan = mapStoreProductToPlan(product);

      expect(plan.id, 'fitlog_pro_lifetime');
      expect(plan.priceString, '€79.99');
      expect(plan.period, SubscriptionPeriod.lifetime);
      expect(plan.displayTitle, 'FitLog Pro Lifetime');
      expect(plan.rcPackageIdentifier, isNull);
    });

    test('maps a subscription product using the store subscription period', () {
      const product = StoreProduct(
        'fitlog_pro_monthly',
        'Monthly access',
        'FitLog Pro Monthly',
        4.99,
        '€4.99',
        'EUR',
        subscriptionPeriod: 'P1M',
      );

      final plan = mapStoreProductToPlan(product);

      expect(plan.period, SubscriptionPeriod.monthly);
      expect(plan.displayTitle, 'FitLog Pro Monthly');
    });
  });
}

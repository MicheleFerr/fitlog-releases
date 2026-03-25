import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/core/providers/effective_premium_access_provider.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/premium_entitlement.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_status.dart';
import 'package:gymbro_flutter_new/shared/auth/entities/user_profile.dart';

void main() {
  group('effectivePremiumAccessProvider', () {
    test('prefers server entitlements when they are active', () {
      final access = resolveEffectivePremiumAccess(
        storedTier: AccountTier.free,
        serverEntitlement: const PremiumEntitlement(
          isActive: true,
          accountTier: AccountTier.premium,
          source: 'revenuecat',
          willRenew: true,
          productId: 'fitlog_pro_yearly',
        ),
        subscriptionStatus: SubscriptionStatus.free(),
      );

      expect(access.isActive, isTrue);
      expect(access.accountTier, AccountTier.premium);
      expect(access.source, PremiumAccessSource.serverEntitlements);
      expect(access.productId, 'fitlog_pro_yearly');
    });

    test('prefers RevenueCat active status over stored free tier', () {
      final access = resolveEffectivePremiumAccess(
        storedTier: AccountTier.free,
        subscriptionStatus: const SubscriptionStatus(
          isActive: true,
          willRenew: true,
          productId: 'fitlog_pro_yearly',
        ),
      );

      expect(access.isActive, isTrue);
      expect(access.accountTier, AccountTier.premium);
      expect(access.source, PremiumAccessSource.revenueCat);
      expect(access.productId, 'fitlog_pro_yearly');
    });

    test('falls back to stored premium while RevenueCat is still loading', () {
      final access = resolveEffectivePremiumAccess(
        storedTier: AccountTier.premium,
      );

      expect(access.isActive, isTrue);
      expect(access.accountTier, AccountTier.premium);
      expect(access.source, PremiumAccessSource.storedProfile);
    });

    test('RevenueCat free status overrides stored premium fallback', () {
      final access = resolveEffectivePremiumAccess(
        storedTier: AccountTier.premium,
        subscriptionStatus: SubscriptionStatus.free(),
      );

      expect(access.isActive, isFalse);
      expect(access.accountTier, AccountTier.free);
      expect(access.source, PremiumAccessSource.revenueCat);
    });

    test('RevenueCat active status wins over a stale free entitlement', () {
      final access = resolveEffectivePremiumAccess(
        storedTier: AccountTier.free,
        serverEntitlement: const PremiumEntitlement.free(source: 'revenuecat'),
        subscriptionStatus: const SubscriptionStatus(
          isActive: true,
          willRenew: true,
          productId: 'fitlog_pro_monthly',
        ),
      );

      expect(access.isActive, isTrue);
      expect(access.accountTier, AccountTier.premium);
      expect(access.source, PremiumAccessSource.revenueCat);
      expect(access.productId, 'fitlog_pro_monthly');
    });
  });
}

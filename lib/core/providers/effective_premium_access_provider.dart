library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/premium_entitlement.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_status.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/providers/premium_entitlement_provider.dart';
import 'package:gymbro_flutter_new/features/premium/presentation/providers/purchase_providers.dart';
import 'package:gymbro_flutter_new/shared/auth/entities/user_profile.dart';
import 'package:gymbro_flutter_new/shared/auth/providers/consolidated_user_provider.dart';

enum PremiumAccessSource { serverEntitlements, revenueCat, storedProfile, none }

class EffectivePremiumAccess {
  const EffectivePremiumAccess({
    required this.isActive,
    required this.source,
    this.expirationDate,
    this.willRenew = false,
    this.isLifetime = false,
    this.productId,
    this.managementUrl,
  });

  const EffectivePremiumAccess.free({this.source = PremiumAccessSource.none})
    : isActive = false,
      expirationDate = null,
      willRenew = false,
      isLifetime = false,
      productId = null,
      managementUrl = null;

  factory EffectivePremiumAccess.fromSubscriptionStatus(
    SubscriptionStatus status,
  ) {
    if (!status.isActive) {
      return const EffectivePremiumAccess.free(
        source: PremiumAccessSource.revenueCat,
      );
    }

    return EffectivePremiumAccess(
      isActive: true,
      source: PremiumAccessSource.revenueCat,
      expirationDate: status.expirationDate,
      willRenew: status.willRenew,
      isLifetime: status.isLifetime,
      productId: status.productId,
      managementUrl: status.managementUrl,
    );
  }

  factory EffectivePremiumAccess.fromPremiumEntitlement(
    PremiumEntitlement entitlement, {
    String? managementUrl,
  }) {
    if (!entitlement.isActive) {
      return const EffectivePremiumAccess.free(
        source: PremiumAccessSource.serverEntitlements,
      );
    }

    return EffectivePremiumAccess(
      isActive: true,
      source: PremiumAccessSource.serverEntitlements,
      expirationDate: entitlement.expiresAt,
      willRenew: entitlement.willRenew,
      isLifetime: entitlement.isLifetime,
      productId: entitlement.productId,
      managementUrl: managementUrl,
    );
  }

  factory EffectivePremiumAccess.fromStoredProfile(AccountTier tier) {
    if (tier == AccountTier.free) {
      return const EffectivePremiumAccess.free(
        source: PremiumAccessSource.storedProfile,
      );
    }

    return const EffectivePremiumAccess(
      isActive: true,
      source: PremiumAccessSource.storedProfile,
    );
  }

  final bool isActive;
  final PremiumAccessSource source;
  final DateTime? expirationDate;
  final bool willRenew;
  final bool isLifetime;
  final String? productId;
  final String? managementUrl;

  AccountTier get accountTier =>
      isActive ? AccountTier.premium : AccountTier.free;

  SubscriptionStatus get subscriptionStatus => SubscriptionStatus(
    isActive: isActive,
    expirationDate: expirationDate,
    willRenew: willRenew,
    isLifetime: isLifetime,
    productId: productId,
    managementUrl: managementUrl,
  );
}

/// RevenueCat is the primary premium signal when it has emitted a value.
/// Until then, we fall back to the stored profile tier to avoid regressing
/// existing users during initialization.
final effectivePremiumAccessProvider = Provider<EffectivePremiumAccess>((ref) {
  final storedTier = ref.watch(
    userProfileProvider.select(
      (asyncValue) => asyncValue.value?.accountTier ?? AccountTier.free,
    ),
  );
  final serverEntitlement = ref.watch(premiumEntitlementProvider).value;
  final subscriptionStatus = ref.watch(subscriptionStatusProvider).value;

  return resolveEffectivePremiumAccess(
    serverEntitlement: serverEntitlement,
    subscriptionStatus: subscriptionStatus,
    storedTier: storedTier,
  );
});

final effectiveAccountTierProvider = Provider<AccountTier>((ref) {
  return ref.watch(
    effectivePremiumAccessProvider.select((value) => value.accountTier),
  );
});

final hasEffectivePremiumAccessProvider = Provider<bool>((ref) {
  return ref.watch(
    effectivePremiumAccessProvider.select((value) => value.isActive),
  );
});

EffectivePremiumAccess resolveEffectivePremiumAccess({
  required AccountTier storedTier,
  PremiumEntitlement? serverEntitlement,
  SubscriptionStatus? subscriptionStatus,
}) {
  if (serverEntitlement?.isActive == true) {
    return EffectivePremiumAccess.fromPremiumEntitlement(
      serverEntitlement!,
      managementUrl: subscriptionStatus?.managementUrl,
    );
  }

  if (subscriptionStatus?.isActive == true) {
    return EffectivePremiumAccess.fromSubscriptionStatus(subscriptionStatus!);
  }

  if (serverEntitlement != null) {
    return EffectivePremiumAccess.fromPremiumEntitlement(
      serverEntitlement,
      managementUrl: subscriptionStatus?.managementUrl,
    );
  }

  if (subscriptionStatus != null) {
    return EffectivePremiumAccess.fromSubscriptionStatus(subscriptionStatus);
  }

  return EffectivePremiumAccess.fromStoredProfile(storedTier);
}

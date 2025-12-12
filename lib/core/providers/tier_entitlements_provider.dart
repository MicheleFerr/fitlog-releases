/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: core/providers
/// Feature: Tier Entitlements (Policy Decision Point)
/// Type: Riverpod Provider
///
/// Centralized entitlement provider for tier-based feature access.
/// All access decisions should go through this provider.
///
/// Pattern: PDP (Policy Decision Point) from entitlement architecture
/// Based on RevenueCat/Qonversion patterns.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/domain/entities/user_tier.dart';
import 'package:gymbro_flutter_new/features/home/providers/user_xp_provider.dart';

/// Centralized entitlement provider (Policy Decision Point)
///
/// Pattern: PDP from entitlement architecture
/// All access decisions should go through this provider.
final tierEntitlementsProvider = Provider<TierEntitlements>((ref) {
  final tier = ref.watch(userTierProvider);
  return TierEntitlements(tier);
});

/// Entitlements wrapper with helper methods
///
/// Provides convenient access to tier entitlements with
/// additional helper methods for common checks.
class TierEntitlements {
  TierEntitlements(this._tier);
  final UserTier _tier;

  /// Current user tier
  UserTier get tier => _tier;

  /// Maximum private templates user can create
  int get maxTemplates => _tier.maxTemplates;

  /// Whether to show banner ads
  bool get shouldShowAds => _tier.showAds;

  /// Whether user has Pro Analytics access
  bool get hasProAnalytics => _tier.hasProAnalytics;

  /// Whether user has Cloud Sync access
  bool get hasCloudSync => _tier.hasCloudSync;

  /// Check if user can save another template
  bool canSaveTemplate(int currentCount) => currentCount < maxTemplates;

  /// Get remaining template slots
  int remainingTemplates(int currentCount) =>
      (maxTemplates - currentCount).clamp(0, maxTemplates);

  /// Check if feature is locked (for UI display)
  bool isFeatureLocked(TierFeature feature) {
    switch (feature) {
      case TierFeature.proAnalytics:
        return !hasProAnalytics;
      case TierFeature.cloudSync:
        return !hasCloudSync;
      case TierFeature.noAds:
        return shouldShowAds;
      case TierFeature.extraTemplates:
        return maxTemplates < UserTier.platinum.maxTemplates;
    }
  }

  /// Get tier required to unlock a feature
  UserTier? tierRequiredFor(TierFeature feature) {
    switch (feature) {
      case TierFeature.proAnalytics:
      case TierFeature.cloudSync:
      case TierFeature.noAds:
        return UserTier.platinum;
      case TierFeature.extraTemplates:
        if (maxTemplates < 5) return UserTier.silver;
        if (maxTemplates < 7) return UserTier.platinum;
        return null;
    }
  }
}

/// Enumeration of tier-gated features
enum TierFeature {
  proAnalytics,
  cloudSync,
  noAds,
  extraTemplates,
}

// ============================================================
// SELECTIVE PROVIDERS (Performance optimization)
// Use .select() to avoid unnecessary rebuilds
// Pattern: PEP (Policy Enforcement Point)
// ============================================================

/// Whether to show banner ads
///
/// Use this at ad display points to gate banner ads.
/// Platinum users have ads disabled.
final shouldShowAdsProvider = Provider<bool>((ref) {
  return ref.watch(
    tierEntitlementsProvider.select((e) => e.shouldShowAds),
  );
});

/// Maximum templates user can save
///
/// Use this when checking template creation limits.
final maxTemplatesProvider = Provider<int>((ref) {
  return ref.watch(
    tierEntitlementsProvider.select((e) => e.maxTemplates),
  );
});

/// Whether user has Pro Analytics access
///
/// Use this to gate Pro Analytics features.
/// Only Platinum users have access.
final hasProAnalyticsProvider = Provider<bool>((ref) {
  return ref.watch(
    tierEntitlementsProvider.select((e) => e.hasProAnalytics),
  );
});

/// Whether user has Cloud Sync access
///
/// Use this to gate Cloud Sync features.
/// Only Platinum users have access.
final hasCloudSyncProvider = Provider<bool>((ref) {
  return ref.watch(
    tierEntitlementsProvider.select((e) => e.hasCloudSync),
  );
});

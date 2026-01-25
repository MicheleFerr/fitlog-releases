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
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';

/// Centralized entitlement provider (Policy Decision Point)
///
/// Pattern: PDP from entitlement architecture
/// All access decisions should go through this provider.
///
/// CONSOLIDATED: Takes max of XP tier (UserTier) and Account tier (AccountTier/Premium)
/// This ensures Premium users always get at least their subscription benefits,
/// while XP progression can grant additional slots.
final tierEntitlementsProvider = Provider<TierEntitlements>((ref) {
  final userTier = ref.watch(userTierProvider);
  final accountTier = ref.watch(
    userProfileProvider.select((profile) =>
      profile.valueOrNull?.accountTier ?? AccountTier.free
    ),
  );
  return TierEntitlements.consolidated(
    userTier: userTier,
    accountTier: accountTier,
  );
});

/// Entitlements wrapper with helper methods
///
/// Provides convenient access to tier entitlements with
/// additional helper methods for common checks.
class TierEntitlements {
  /// Create entitlements from XP tier only (legacy)
  TierEntitlements(this._tier)
    : _quota = TemplateQuota.forUserTier(_tier),
      _accountTier = AccountTier.free;

  /// Create consolidated entitlements (XP tier + Account tier)
  /// Takes the MAXIMUM of both tiers to ensure Premium users always
  /// get at least their subscription benefits
  TierEntitlements.consolidated({
    required UserTier userTier,
    required AccountTier accountTier,
  }) : _tier = userTier,
       _accountTier = accountTier,
       _quota = TemplateQuota.consolidated(
         userTier: userTier,
         accountTier: accountTier,
       );

  final UserTier _tier;
  final AccountTier _accountTier;
  final TemplateQuota _quota;

  /// Current user tier (XP-based)
  UserTier get tier => _tier;

  /// Current account tier (Premium toggle)
  AccountTier get accountTier => _accountTier;

  /// Maximum private templates user can create (consolidated from both tiers)
  int get maxTemplates => _quota.maxPrivateTemplates;

  /// Maximum public templates user can share (consolidated from both tiers)
  int get maxPublicTemplates => _quota.maxPublicTemplates;

  /// Maximum custom exercises user can create
  int get maxCustomExercises => _tier.maxCustomExercises;

  /// Whether to show banner ads (Premium/Pro users have no ads)
  bool get shouldShowAds => _accountTier == AccountTier.free && _tier.showAds;

  /// Whether user has Pro Analytics access
  bool get hasProAnalytics => _accountTier != AccountTier.free || _tier.hasProAnalytics;

  /// Whether user has Cloud Sync access
  bool get hasCloudSync => _accountTier != AccountTier.free || _tier.hasCloudSync;

  /// Check if user can save another private template
  bool canSaveTemplate(int currentCount) => currentCount < maxTemplates;

  /// Check if user can save another public template
  bool canSavePublicTemplate(int currentCount) => currentCount < maxPublicTemplates;

  /// Check if user can create another custom exercise
  bool canCreateCustomExercise(int currentCount) => currentCount < maxCustomExercises;

  /// Get remaining private template slots
  int remainingTemplates(int currentCount) =>
      (maxTemplates - currentCount).clamp(0, maxTemplates);

  /// Get remaining public template slots
  int remainingPublicTemplates(int currentCount) =>
      (maxPublicTemplates - currentCount).clamp(0, maxPublicTemplates);

  /// Get remaining custom exercise slots
  int remainingCustomExercises(int currentCount) =>
      (maxCustomExercises - currentCount).clamp(0, maxCustomExercises);

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

/// Maximum public templates user can save
///
/// Use this when checking public template sharing limits.
final maxPublicTemplatesProvider = Provider<int>((ref) {
  return ref.watch(
    tierEntitlementsProvider.select((e) => e.maxPublicTemplates),
  );
});

/// Maximum custom exercises user can create
///
/// Use this when checking custom exercise creation limits.
final maxCustomExercisesProvider = Provider<int>((ref) {
  return ref.watch(
    tierEntitlementsProvider.select((e) => e.maxCustomExercises),
  );
});

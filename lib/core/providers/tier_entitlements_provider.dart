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
import 'package:gymbro_flutter_new/shared/domain/user/user_xp_provider.dart';
import 'package:gymbro_flutter_new/shared/auth/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/shared/auth/entities/user_profile.dart';

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
      profile.value?.accountTier ?? AccountTier.free
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
    : _accountTier = AccountTier.free;

  /// Create consolidated entitlements (XP tier + Account tier)
  /// Takes the MAXIMUM of both tiers to ensure Premium users always
  /// get at least their subscription benefits
  TierEntitlements.consolidated({
    required UserTier userTier,
    required AccountTier accountTier,
  }) : _tier = userTier,
       _accountTier = accountTier;

  final UserTier _tier;
  final AccountTier _accountTier;

  /// Current user tier (XP-based)
  UserTier get tier => _tier;

  /// Current account tier (Premium toggle)
  AccountTier get accountTier => _accountTier;

  // ============================================================
  // HISTORY LIMIT (only premium gating)
  // Free users: 90 days of history. Premium: unlimited.
  // ============================================================

  /// Days of history available (null = unlimited for premium)
  int? get historyDaysLimit =>
      _accountTier != AccountTier.free ? null : 90;

  /// Cutoff date for history access (null = no cutoff for premium)
  DateTime? get historyCutoffDate {
    final limit = historyDaysLimit;
    if (limit == null) return null;
    return DateTime.now().subtract(Duration(days: limit));
  }

  /// Whether user has unlimited history access
  bool get hasUnlimitedHistory => historyDaysLimit == null;

  // ============================================================
  // ALL FEATURES NOW FREE (no XP gating)
  // ============================================================

  /// Maximum private templates (unlimited for all)
  int get maxTemplates => 999;

  /// Maximum public templates (unlimited for all)
  int get maxPublicTemplates => 999;

  /// Maximum custom single exercises (unlimited for all)
  int get maxCustomSingleExercises => 999;

  /// Maximum custom superset templates (unlimited for all)
  int get maxCustomSupersets => 999;

  /// Maximum custom dropset templates (unlimited for all)
  int get maxCustomDropsets => 999;

  /// Maximum custom rest-pause templates (unlimited for all)
  int get maxCustomRestPause => 999;

  /// Whether to show banner ads (Premium/Pro users have no ads)
  bool get shouldShowAds => _accountTier == AccountTier.free && _tier.showAds;

  /// Pro Analytics access (free for all)
  bool get hasProAnalytics => true;

  /// Cloud Sync access (free for all)
  bool get hasCloudSync => true;

  /// Check if user can save another private template
  bool canSaveTemplate(int currentCount) => currentCount < maxTemplates;

  /// Check if user can save another public template
  bool canSavePublicTemplate(int currentCount) => currentCount < maxPublicTemplates;

  /// Check if user can create another custom single exercise
  bool canCreateCustomSingleExercise(int currentCount) => currentCount < maxCustomSingleExercises;

  /// Check if user can create another custom superset
  bool canCreateCustomSuperset(int currentCount) => currentCount < maxCustomSupersets;

  /// Check if user can create another custom dropset
  bool canCreateCustomDropset(int currentCount) => currentCount < maxCustomDropsets;

  /// Check if user can create another custom rest-pause
  bool canCreateCustomRestPause(int currentCount) => currentCount < maxCustomRestPause;

  /// Get remaining private template slots
  int remainingTemplates(int currentCount) =>
      (maxTemplates - currentCount).clamp(0, maxTemplates);

  /// Get remaining public template slots
  int remainingPublicTemplates(int currentCount) =>
      (maxPublicTemplates - currentCount).clamp(0, maxPublicTemplates);

  /// Get remaining custom single exercise slots
  int remainingCustomSingleExercises(int currentCount) =>
      (maxCustomSingleExercises - currentCount).clamp(0, maxCustomSingleExercises);

  /// Get remaining custom superset slots
  int remainingCustomSupersets(int currentCount) =>
      (maxCustomSupersets - currentCount).clamp(0, maxCustomSupersets);

  /// Get remaining custom dropset slots
  int remainingCustomDropsets(int currentCount) =>
      (maxCustomDropsets - currentCount).clamp(0, maxCustomDropsets);

  /// Get remaining custom rest-pause slots
  int remainingCustomRestPause(int currentCount) =>
      (maxCustomRestPause - currentCount).clamp(0, maxCustomRestPause);

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

/// Maximum custom single exercises user can create
///
/// Use this when checking custom single exercise creation limits.
final maxCustomSingleExercisesProvider = Provider<int>((ref) {
  return ref.watch(
    tierEntitlementsProvider.select((e) => e.maxCustomSingleExercises),
  );
});

/// Maximum custom superset templates user can create
///
/// Use this when checking custom superset template creation limits.
final maxCustomSupersetsProvider = Provider<int>((ref) {
  return ref.watch(
    tierEntitlementsProvider.select((e) => e.maxCustomSupersets),
  );
});

/// Maximum custom dropset templates user can create
///
/// Use this when checking custom dropset template creation limits.
final maxCustomDropsetsProvider = Provider<int>((ref) {
  return ref.watch(
    tierEntitlementsProvider.select((e) => e.maxCustomDropsets),
  );
});

/// Maximum custom rest-pause templates user can create
///
/// Use this when checking custom rest-pause template creation limits.
final maxCustomRestPauseProvider = Provider<int>((ref) {
  return ref.watch(
    tierEntitlementsProvider.select((e) => e.maxCustomRestPause),
  );
});

/// History cutoff date for free users (null = unlimited for premium)
///
/// Use this to filter history, analytics, and AI coach data.
final historyCutoffDateProvider = Provider<DateTime?>((ref) {
  return ref.watch(
    tierEntitlementsProvider.select((e) => e.historyCutoffDate),
  );
});

/// Whether user has unlimited history access
final hasUnlimitedHistoryProvider = Provider<bool>((ref) {
  return ref.watch(
    tierEntitlementsProvider.select((e) => e.hasUnlimitedHistory),
  );
});

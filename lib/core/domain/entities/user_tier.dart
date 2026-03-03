/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: core/domain/entities
/// Feature: User Tier with Entitlements
/// Type: Enhanced Enum
///
/// User tier based on XP with embedded entitlement properties.
/// This is the single source of truth for tier definitions and rewards.
///
/// Pattern: Enhanced Enum (Dart 3) + Entitlement System (PDP/PEP)
/// Based on RevenueCat/Qonversion architecture patterns.
library;

import 'package:flutter/material.dart';

/// User tier based on XP with entitlements
///
/// Pattern: Enhanced Enum (Dart 3) with embedded entitlement properties
/// This is the single source of truth for tier definitions and rewards.
///
/// Tier Rewards Matrix:
/// | Feature              | Starter | Bronze | Silver | Gold | Platinum | Diamond | Legend |
/// |----------------------|---------|--------|--------|------|----------|---------|--------|
/// | Private Templates    | 4       | 4      | 5      | 5    | 7        | 10      | 999    |
/// | Public Templates     | 2       | 2      | 3      | 3    | 5        | 7       | 999    |
/// | Custom Singles       | 3       | 5      | 7      | 10   | 999      | 999     | 999    |
/// | Custom Supersets     | 3       | 5      | 7      | 10   | 999      | 999     | 999    |
/// | Custom Dropsets      | 3       | 5      | 7      | 10   | 999      | 999     | 999    |
/// | Custom Rest-Pause    | 3       | 5      | 7      | 10   | 999      | 999     | 999    |
/// | Banner Ads           | Yes     | Yes    | Yes    | Yes  | No       | No      | No     |
/// | Pro Analytics        | No      | No     | No     | No   | Yes      | Yes     | Yes    |
/// | Cloud Sync           | No      | No     | No     | No   | Yes      | Yes     | Yes    |
enum UserTier {
  starter(
    minXP: 0,
    displayName: 'Starter',
    color: Color(0xFF9E9E9E),
    maxTemplates: 4,
    maxPublicTemplates: 2,
    maxCustomSingleExercises: 3,
    maxCustomSupersets: 3,
    maxCustomDropsets: 3,
    maxCustomRestPause: 3,
    showAds: true,
    hasProAnalytics: false,
    hasCloudSync: false,
  ),
  bronze(
    minXP: 300,
    displayName: 'Bronze',
    color: Color(0xFFCD7F32),
    maxTemplates: 4,
    maxPublicTemplates: 2,
    maxCustomSingleExercises: 5,
    maxCustomSupersets: 5,
    maxCustomDropsets: 5,
    maxCustomRestPause: 5,
    showAds: true,
    hasProAnalytics: false,
    hasCloudSync: false,
  ),
  silver(
    minXP: 1500,
    displayName: 'Silver',
    color: Color(0xFFC0C0C0),
    maxTemplates: 5,
    maxPublicTemplates: 3,
    maxCustomSingleExercises: 7,
    maxCustomSupersets: 7,
    maxCustomDropsets: 7,
    maxCustomRestPause: 7,
    showAds: true,
    hasProAnalytics: false,
    hasCloudSync: false,
  ),
  gold(
    minXP: 5000,
    displayName: 'Gold',
    color: Color(0xFFFFD700),
    maxTemplates: 5,
    maxPublicTemplates: 3,
    maxCustomSingleExercises: 10,
    maxCustomSupersets: 10,
    maxCustomDropsets: 10,
    maxCustomRestPause: 10,
    showAds: true,
    hasProAnalytics: false,
    hasCloudSync: false,
  ),
  platinum(
    minXP: 15000,
    displayName: 'Platinum',
    color: Color(0xFFE5E4E2),
    maxTemplates: 7,
    maxPublicTemplates: 5,
    maxCustomSingleExercises: 999,
    maxCustomSupersets: 999,
    maxCustomDropsets: 999,
    maxCustomRestPause: 999,
    showAds: false,
    hasProAnalytics: true,
    hasCloudSync: true,
  ),
  diamond(
    minXP: 30000,
    displayName: 'Diamond',
    color: Color(0xFFB9F2FF),
    maxTemplates: 10,
    maxPublicTemplates: 7,
    maxCustomSingleExercises: 999,
    maxCustomSupersets: 999,
    maxCustomDropsets: 999,
    maxCustomRestPause: 999,
    showAds: false,
    hasProAnalytics: true,
    hasCloudSync: true,
  ),
  legend(
    minXP: 60000,
    displayName: 'Legend',
    color: Color(0xFFFF6B35),
    maxTemplates: 999,
    maxPublicTemplates: 999,
    maxCustomSingleExercises: 999,
    maxCustomSupersets: 999,
    maxCustomDropsets: 999,
    maxCustomRestPause: 999,
    showAds: false,
    hasProAnalytics: true,
    hasCloudSync: true,
  );

  const UserTier({
    required this.minXP,
    required this.displayName,
    required this.color,
    required this.maxTemplates,
    required this.maxPublicTemplates,
    required this.maxCustomSingleExercises,
    required this.maxCustomSupersets,
    required this.maxCustomDropsets,
    required this.maxCustomRestPause,
    required this.showAds,
    required this.hasProAnalytics,
    required this.hasCloudSync,
  });

  /// Minimum XP required to reach this tier
  final int minXP;

  /// Display name for UI
  final String displayName;

  /// Theme color for this tier
  final Color color;

  // ============================================================
  // ENTITLEMENTS
  // ============================================================

  /// Maximum number of private templates user can create
  final int maxTemplates;

  /// Maximum number of public templates user can share
  final int maxPublicTemplates;

  /// Maximum number of custom single exercises user can create
  final int maxCustomSingleExercises;

  /// Maximum number of custom superset templates user can create
  final int maxCustomSupersets;

  /// Maximum number of custom dropset templates user can create
  final int maxCustomDropsets;

  /// Maximum number of custom rest-pause templates user can create
  final int maxCustomRestPause;

  /// Whether to show banner ads
  final bool showAds;

  /// Whether user has access to Pro Analytics
  final bool hasProAnalytics;

  /// Whether user has access to Cloud Sync
  final bool hasCloudSync;

  /// Get tier for given XP amount
  static UserTier fromXP(int xp) {
    if (xp >= legend.minXP) return legend;
    if (xp >= diamond.minXP) return diamond;
    if (xp >= platinum.minXP) return platinum;
    if (xp >= gold.minXP) return gold;
    if (xp >= silver.minXP) return silver;
    if (xp >= bronze.minXP) return bronze;
    return starter;
  }

  /// Get next tier (or null if max)
  UserTier? get next {
    final index = UserTier.values.indexOf(this);
    if (index >= UserTier.values.length - 1) return null;
    return UserTier.values[index + 1];
  }

  /// XP needed to reach next tier (or null if max)
  int? get xpToNextTier {
    final nextTier = next;
    if (nextTier == null) return null;
    return nextTier.minXP;
  }

  /// Calculate progress to next tier (0.0 to 1.0)
  double progressToNext(int currentXP) {
    final nextTier = next;
    if (nextTier == null) return 1.0;

    final xpInCurrentTier = currentXP - minXP;
    final xpNeededForNext = nextTier.minXP - minXP;

    return (xpInCurrentTier / xpNeededForNext).clamp(0.0, 1.0);
  }

  /// XP remaining to reach next tier
  int xpRemainingToNext(int currentXP) {
    final nextTier = next;
    if (nextTier == null) return 0;
    return (nextTier.minXP - currentXP).clamp(0, nextTier.minXP);
  }
}

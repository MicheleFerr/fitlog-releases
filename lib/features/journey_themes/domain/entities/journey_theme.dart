/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/journey_themes/domain/entities
/// Feature: Journey Themes Gamification
/// Type: Entity (Enum)
///
/// Journey Theme definitions with colors, taglines, and unlock logic.
/// All themes accessible from Day 1, features unlock progressively.
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/journey_themes/domain/entities/unlockable_feature.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/compact_profile_header.dart';

/// Available journey themes for app customization
enum JourneyTheme {
  classic(
    emoji: '💪',
    displayName: 'FitLog Classic',
    tagline: 'Simple & effective',
    primaryColor: Color(0xFF2196F3),
    secondaryColor: Color(0xFF64B5F6),
    accentColor: Color(0xFFBBDEFB),
  ),
  hunter(
    emoji: '🏹',
    displayName: 'Hunter',
    tagline: 'Track your prey',
    primaryColor: Color(0xFFFF5722),
    secondaryColor: Color(0xFF795548),
    accentColor: Color(0xFFFFAB91),
  ),
  hero(
    emoji: '⚔️',
    displayName: 'Hero',
    tagline: 'Rise to legend',
    primaryColor: Color(0xFF1976D2),
    secondaryColor: Color(0xFF7C4DFF),
    accentColor: Color(0xFF82B1FF),
  ),
  warriorGoddess(
    emoji: '👑',
    displayName: 'Warrior Goddess',
    tagline: 'Elegant power',
    primaryColor: Color(0xFF9C27B0),
    secondaryColor: Color(0xFFE91E63),
    accentColor: Color(0xFFF8BBD0),
  ),
  natureSpirit(
    emoji: '🌿',
    displayName: 'Nature Spirit',
    tagline: 'Flow with nature',
    primaryColor: Color(0xFF4CAF50),
    secondaryColor: Color(0xFF8BC34A),
    accentColor: Color(0xFFC8E6C9),
  ),
  phoenix(
    emoji: '🔥',
    displayName: 'Phoenix',
    tagline: 'Rise from ashes',
    primaryColor: Color(0xFFF44336),
    secondaryColor: Color(0xFFFF9800),
    accentColor: Color(0xFFFFEB3B),
  ),
  frost(
    emoji: '❄️',
    displayName: 'Frost',
    tagline: 'Cold precision',
    primaryColor: Color(0xFF03A9F4),
    secondaryColor: Color(0xFFB3E5FC),
    accentColor: Color(0xFFE1F5FE),
  );

  const JourneyTheme({
    required this.emoji,
    required this.displayName,
    required this.tagline,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  /// Theme emoji for visual representation
  final String emoji;

  /// Display name for UI (hardcoded - localization in presentation layer)
  final String displayName;

  /// Short tagline describing the theme vibe
  final String tagline;

  /// Primary color for main UI elements
  final Color primaryColor;

  /// Secondary color for accents
  final Color secondaryColor;

  /// Accent color for highlights
  final Color accentColor;

  /// Get all features for this theme
  List<UnlockableFeature> get allFeatures => UnlockableFeature.allFeatures;

  /// Get features unlocked at current tier
  List<UnlockableFeature> getUnlockedFeatures(UserTier tier) {
    return allFeatures
        .where((f) => tier.minXP >= f.requiredTier.minXP)
        .toList();
  }

  /// Get features still locked at current tier
  List<UnlockableFeature> getLockedFeatures(UserTier tier) {
    return allFeatures
        .where((f) => tier.minXP < f.requiredTier.minXP)
        .toList();
  }

  /// Calculate unlock percentage (0.0 to 1.0)
  double getUnlockPercentage(UserTier tier) {
    if (allFeatures.isEmpty) return 0;
    return getUnlockedFeatures(tier).length / allFeatures.length;
  }

  /// Get count of unlocked features
  int getUnlockedFeaturesCount(UserTier tier) => getUnlockedFeatures(tier).length;

  /// Get total features count
  int get totalFeatures => allFeatures.length;

  /// Check if a specific feature is unlocked
  bool isFeatureUnlocked(String featureId, UserTier tier) {
    final feature = allFeatures.firstWhere(
      (f) => f.id == featureId,
      orElse: () => throw ArgumentError('Unknown feature: $featureId'),
    );
    return tier.minXP >= feature.requiredTier.minXP;
  }

  /// Get next unlockable feature for current tier
  UnlockableFeature? getNextUnlockableFeature(UserTier tier) {
    final locked = getLockedFeatures(tier);
    if (locked.isEmpty) return null;
    // Return the feature with lowest required XP
    locked.sort((a, b) => a.requiredTier.minXP.compareTo(b.requiredTier.minXP));
    return locked.first;
  }
}

/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/journey_themes/domain/entities
/// Feature: Journey Themes Gamification
/// Type: Entity
///
/// Unlockable feature definitions for progressive theme customization.
/// Features unlock based on UserTier (XP levels).
library;

import 'package:gymbro_flutter_new/features/profile/presentation/widgets/compact_profile_header.dart';

/// Categories of unlockable features
enum FeatureCategory {
  colors('Colors'),
  cards('Cards'),
  buttons('Buttons'),
  progress('Progress'),
  effects('Effects'),
  icons('Icons');

  const FeatureCategory(this.displayName);

  final String displayName;
}

/// Represents a single unlockable feature within a theme
class UnlockableFeature {
  const UnlockableFeature({
    required this.id,
    required this.name,
    required this.category,
    required this.requiredTier,
    required this.description,
  });

  /// Unique identifier for the feature
  final String id;

  /// Display name (hardcoded - localization in presentation layer)
  final String name;

  /// Feature category for grouping
  final FeatureCategory category;

  /// Minimum tier required to unlock
  final UserTier requiredTier;

  /// Description of what this feature does
  final String description;

  /// Check if feature is unlocked for given tier
  bool isUnlockedFor(UserTier tier) => tier.minXP >= requiredTier.minXP;

  /// XP remaining to unlock (0 if already unlocked)
  int xpToUnlock(int currentXP) {
    if (currentXP >= requiredTier.minXP) return 0;
    return requiredTier.minXP - currentXP;
  }

  /// All available features (same structure for all themes)
  static const List<UnlockableFeature> allFeatures = [
    // ═══════════════════════════════════════════════════════════════
    // STARTER TIER (0 XP) - Basic customization, immediately available
    // ═══════════════════════════════════════════════════════════════
    UnlockableFeature(
      id: 'primary_color',
      name: 'Primary Color',
      category: FeatureCategory.colors,
      requiredTier: UserTier.starter,
      description: 'Main theme color for buttons and accents',
    ),
    UnlockableFeature(
      id: 'card_background',
      name: 'Card Background',
      category: FeatureCategory.cards,
      requiredTier: UserTier.starter,
      description: 'Background color for content cards',
    ),
    UnlockableFeature(
      id: 'basic_button',
      name: 'Basic Button Style',
      category: FeatureCategory.buttons,
      requiredTier: UserTier.starter,
      description: 'Standard button appearance',
    ),

    // ═══════════════════════════════════════════════════════════════
    // BRONZE TIER (100 XP) - Enhanced customization
    // ═══════════════════════════════════════════════════════════════
    UnlockableFeature(
      id: 'secondary_color',
      name: 'Secondary Color',
      category: FeatureCategory.colors,
      requiredTier: UserTier.bronze,
      description: 'Accent color for secondary elements',
    ),
    UnlockableFeature(
      id: 'card_border',
      name: 'Card Border Style',
      category: FeatureCategory.cards,
      requiredTier: UserTier.bronze,
      description: 'Custom border for cards',
    ),
    UnlockableFeature(
      id: 'button_hover',
      name: 'Button Hover Effect',
      category: FeatureCategory.buttons,
      requiredTier: UserTier.bronze,
      description: 'Interactive button feedback',
    ),

    // ═══════════════════════════════════════════════════════════════
    // SILVER TIER (500 XP) - Advanced styling
    // ═══════════════════════════════════════════════════════════════
    UnlockableFeature(
      id: 'accent_color',
      name: 'Accent Color',
      category: FeatureCategory.colors,
      requiredTier: UserTier.silver,
      description: 'Highlight color for emphasis',
    ),
    UnlockableFeature(
      id: 'progress_bar',
      name: 'Progress Bar Style',
      category: FeatureCategory.progress,
      requiredTier: UserTier.silver,
      description: 'Custom progress indicators',
    ),
    UnlockableFeature(
      id: 'input_fields',
      name: 'Input Field Style',
      category: FeatureCategory.cards,
      requiredTier: UserTier.silver,
      description: 'Custom text field appearance',
    ),

    // ═══════════════════════════════════════════════════════════════
    // GOLD TIER (1500 XP) - Premium effects
    // ═══════════════════════════════════════════════════════════════
    UnlockableFeature(
      id: 'glow_effects',
      name: 'Glow Effects',
      category: FeatureCategory.effects,
      requiredTier: UserTier.gold,
      description: 'Ambient glow on UI elements',
    ),
    UnlockableFeature(
      id: 'special_icons',
      name: 'Special Icons',
      category: FeatureCategory.icons,
      requiredTier: UserTier.gold,
      description: 'Theme-specific icon variants',
    ),

    // ═══════════════════════════════════════════════════════════════
    // PLATINUM TIER (5000 XP) - Ultimate customization
    // ═══════════════════════════════════════════════════════════════
    UnlockableFeature(
      id: 'app_icon',
      name: 'App Icon',
      category: FeatureCategory.icons,
      requiredTier: UserTier.platinum,
      description: 'Custom home screen icon',
    ),
    UnlockableFeature(
      id: 'custom_sounds',
      name: 'Custom Sounds',
      category: FeatureCategory.effects,
      requiredTier: UserTier.platinum,
      description: 'Theme-specific audio feedback',
    ),
    UnlockableFeature(
      id: 'particles',
      name: 'Particle Effects',
      category: FeatureCategory.effects,
      requiredTier: UserTier.platinum,
      description: 'Premium visual particles',
    ),
  ];

  /// Get features by category
  static List<UnlockableFeature> byCategory(FeatureCategory category) {
    return allFeatures.where((f) => f.category == category).toList();
  }

  /// Get features by tier
  static List<UnlockableFeature> byTier(UserTier tier) {
    return allFeatures.where((f) => f.requiredTier == tier).toList();
  }

  /// Get features grouped by tier
  static Map<UserTier, List<UnlockableFeature>> get groupedByTier {
    final map = <UserTier, List<UnlockableFeature>>{};
    for (final tier in UserTier.values) {
      map[tier] = byTier(tier);
    }
    return map;
  }

  /// Get features grouped by category
  static Map<FeatureCategory, List<UnlockableFeature>> get groupedByCategory {
    final map = <FeatureCategory, List<UnlockableFeature>>{};
    for (final category in FeatureCategory.values) {
      final features = byCategory(category);
      if (features.isNotEmpty) {
        map[category] = features;
      }
    }
    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnlockableFeature &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UnlockableFeature($id, $name, ${requiredTier.displayName})';
}

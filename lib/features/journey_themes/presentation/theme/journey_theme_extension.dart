/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/journey_themes/presentation/theme
/// Feature: Journey Themes Gamification
/// Type: ThemeExtension
///
/// Flutter ThemeExtension for journey theme colors and styling.
/// Access via `Theme.of(context).extension<JourneyThemeExtension>()!`
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/journey_themes/domain/entities/journey_theme.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/compact_profile_header.dart';

/// ThemeExtension providing journey theme colors and styles
@immutable
class JourneyThemeExtension extends ThemeExtension<JourneyThemeExtension> {
  const JourneyThemeExtension({
    required this.theme,
    required this.userTier,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.primaryGradient,
    required this.cardGradient,
    required this.glowColor,
    required this.isGlowEnabled,
    required this.iconTint,
  });

  /// Factory to create from JourneyTheme and UserTier
  factory JourneyThemeExtension.fromTheme({
    required JourneyTheme theme,
    required UserTier userTier,
    required Brightness brightness,
  }) {
    // Check which features are unlocked for this tier
    final isGlowUnlocked = theme.isFeatureUnlocked('glow_effects', userTier);

    // Adjust colors for dark mode
    Color adjustForBrightness(Color color) {
      if (brightness == Brightness.dark) {
        // Slightly desaturate and darken for dark mode
        final hsl = HSLColor.fromColor(color);
        return hsl
            .withLightness((hsl.lightness * 0.8).clamp(0.2, 0.8))
            .toColor();
      }
      return color;
    }

    final primary = adjustForBrightness(theme.primaryColor);
    final secondary = adjustForBrightness(theme.secondaryColor);
    final accent = adjustForBrightness(theme.accentColor);

    return JourneyThemeExtension(
      theme: theme,
      userTier: userTier,
      primaryColor: primary,
      secondaryColor: secondary,
      accentColor: accent,
      primaryGradient: LinearGradient(
        colors: [primary, secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      cardGradient: LinearGradient(
        colors: [
          primary.withValues(alpha: 0.1),
          secondary.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      glowColor: isGlowUnlocked ? primary.withValues(alpha: 0.3) : Colors.transparent,
      isGlowEnabled: isGlowUnlocked,
      iconTint: primary,
    );
  }

  /// Default extension (Hunter theme, Starter tier)
  factory JourneyThemeExtension.defaultExtension({
    Brightness brightness = Brightness.light,
  }) {
    return JourneyThemeExtension.fromTheme(
      theme: JourneyTheme.hunter,
      userTier: UserTier.starter,
      brightness: brightness,
    );
  }

  /// Current journey theme
  final JourneyTheme theme;

  /// User's current tier (determines unlocked features)
  final UserTier userTier;

  /// Primary color adjusted for brightness
  final Color primaryColor;

  /// Secondary color adjusted for brightness
  final Color secondaryColor;

  /// Accent color adjusted for brightness
  final Color accentColor;

  /// Primary gradient for hero sections, buttons
  final LinearGradient primaryGradient;

  /// Subtle gradient for card backgrounds
  final LinearGradient cardGradient;

  /// Glow color (if enabled for tier)
  final Color glowColor;

  /// Whether glow effects are unlocked
  final bool isGlowEnabled;

  /// Tint color for themed icons
  final Color iconTint;

  /// Theme emoji for display
  String get emoji => theme.emoji;

  /// Theme display name
  String get displayName => theme.displayName;

  /// Theme tagline
  String get tagline => theme.tagline;

  /// Unlock percentage (0.0 to 1.0)
  double get unlockPercentage => theme.getUnlockPercentage(userTier);

  /// Count of unlocked features
  int get unlockedFeaturesCount => theme.getUnlockedFeaturesCount(userTier);

  /// Total features available
  int get totalFeatures => theme.totalFeatures;

  /// Check if a specific feature is unlocked
  bool isFeatureUnlocked(String featureId) {
    return theme.isFeatureUnlocked(featureId, userTier);
  }

  /// Get box shadow with optional glow effect
  List<BoxShadow> getBoxShadow({
    double elevation = 4,
    bool includeGlow = true,
  }) {
    final shadows = <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
    ];

    if (includeGlow && isGlowEnabled) {
      shadows.add(BoxShadow(
        color: glowColor,
        blurRadius: elevation * 3,
        spreadRadius: 1,
      ));
    }

    return shadows;
  }

  /// Get card decoration with theme styling
  BoxDecoration getCardDecoration({
    BorderRadius? borderRadius,
    bool useGradient = false,
    bool includeGlow = true,
  }) {
    return BoxDecoration(
      gradient: useGradient ? cardGradient : null,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      boxShadow: getBoxShadow(includeGlow: includeGlow),
    );
  }

  @override
  JourneyThemeExtension copyWith({
    JourneyTheme? theme,
    UserTier? userTier,
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentColor,
    LinearGradient? primaryGradient,
    LinearGradient? cardGradient,
    Color? glowColor,
    bool? isGlowEnabled,
    Color? iconTint,
  }) {
    return JourneyThemeExtension(
      theme: theme ?? this.theme,
      userTier: userTier ?? this.userTier,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      cardGradient: cardGradient ?? this.cardGradient,
      glowColor: glowColor ?? this.glowColor,
      isGlowEnabled: isGlowEnabled ?? this.isGlowEnabled,
      iconTint: iconTint ?? this.iconTint,
    );
  }

  @override
  JourneyThemeExtension lerp(JourneyThemeExtension? other, double t) {
    if (other == null) return this;

    return JourneyThemeExtension(
      theme: t < 0.5 ? theme : other.theme,
      userTier: t < 0.5 ? userTier : other.userTier,
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      cardGradient: LinearGradient.lerp(cardGradient, other.cardGradient, t)!,
      glowColor: Color.lerp(glowColor, other.glowColor, t)!,
      isGlowEnabled: t < 0.5 ? isGlowEnabled : other.isGlowEnabled,
      iconTint: Color.lerp(iconTint, other.iconTint, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneyThemeExtension &&
          runtimeType == other.runtimeType &&
          theme == other.theme &&
          userTier == other.userTier &&
          primaryColor == other.primaryColor;

  @override
  int get hashCode => Object.hash(theme, userTier, primaryColor);

  @override
  String toString() =>
      'JourneyThemeExtension(${theme.displayName}, tier: ${userTier.displayName})';
}

/// BuildContext extension for easy access
extension JourneyThemeExtensionContext on BuildContext {
  /// Get the journey theme extension
  /// Returns null if not in the theme
  JourneyThemeExtension? get journeyTheme =>
      Theme.of(this).extension<JourneyThemeExtension>();

  /// Get journey theme with fallback to default
  JourneyThemeExtension get journeyThemeOrDefault =>
      journeyTheme ??
      JourneyThemeExtension.defaultExtension(
        brightness: Theme.of(this).brightness,
      );
}

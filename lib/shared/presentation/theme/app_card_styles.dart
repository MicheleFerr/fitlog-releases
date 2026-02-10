import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Unified card design tokens for template cards
///
/// Provides consistent styling across TemplateCard, WorkoutTemplateCard,
/// and CompactTemplateCard for visual coherence.
class AppCardStyles {
  AppCardStyles._();

  // ============== Corner Radius ==============

  /// Standard corner radius for template cards (16px)
  static const double cornerRadius = 16.0;

  /// Small corner radius for compact cards (12px)
  static const double cornerRadiusSmall = 12.0;

  // ============== Category Strip ==============

  /// Default strip width
  static const double stripWidth = 4.0;

  /// Strip width when pressed (expands for feedback)
  static const double stripWidthPressed = 6.0;

  /// Strip width for compact cards
  static const double stripWidthCompact = 3.0;

  // ============== Watermark ==============

  /// Watermark opacity
  static const double watermarkOpacity = 0.08;

  /// Watermark size based on card size
  static double watermarkSize(CardSize size) => switch (size) {
        CardSize.large => 120.0, // TemplateCard (200px height)
        CardSize.medium => 80.0, // WorkoutTemplateCard (grid)
        CardSize.small => 48.0, // CompactTemplateCard (horizontal)
      };

  // ============== Shadows ==============

  /// Card shadows for elevated appearance
  static List<BoxShadow> cardShadows(BuildContext context) {
    final isDark = context.isDarkMode;
    return [
      // Primary shadow for depth
      BoxShadow(
        color: context.colors.shadow.withValues(
          alpha: isDark ? 0.25 : 0.12,
        ),
        blurRadius: 16,
        offset: const Offset(0, 6),
        spreadRadius: 1,
      ),
      // Secondary subtle shadow
      BoxShadow(
        color: context.colors.onSurface.withValues(
          alpha: isDark ? 0.1 : 0.06,
        ),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Simple shadow for compact cards
  static List<BoxShadow> compactCardShadows(BuildContext context) {
    final isDark = context.isDarkMode;
    return [
      BoxShadow(
        color: context.colors.shadow.withValues(
          alpha: isDark ? 0.15 : 0.1,
        ),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  // ============== Animation Durations ==============

  /// Press animation duration
  static const Duration pressAnimationDuration = Duration(milliseconds: 150);

  /// Fade-in animation duration on mount
  static const Duration fadeInDuration = Duration(milliseconds: 500);

  // ============== Press Scale ==============

  /// Scale factor when card is pressed
  static const double pressedScale = 0.98;

  // ============== Glow Effect ==============

  /// Glow opacity for category strip
  static const double stripGlowOpacity = 0.3;

  /// Glow blur radius
  static const double stripGlowBlurRadius = 6.0;
}

/// Card size variants for responsive watermark sizing
enum CardSize {
  /// Large cards (200px height) - WorkoutScreen horizontal scroll
  large,

  /// Medium cards (grid layout) - TemplatesHomeScreen
  medium,

  /// Small/compact cards (horizontal scroll) - Discover tab
  small,
}

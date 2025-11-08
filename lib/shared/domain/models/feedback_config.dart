import 'package:gymbro_flutter_new/shared/domain/enums/feedback_tier.dart';
import 'package:gymbro_flutter_new/shared/domain/enums/haptic_feedback_style.dart';

/// Composable feedback configuration for interactive elements
///
/// Combines a base [FeedbackTier] with optional local overrides for:
/// - Duration (animation speed)
/// - Haptic feedback style
/// - Scale factor (animation intensity)
///
/// This pattern allows tier-based defaults with granular overrides when needed.
///
/// **Example: Use tier defaults**
/// ```dart
/// FeedbackConfig.high() // 0.95 scale, 150ms, medium haptic
/// ```
///
/// **Example: Override specific values**
/// ```dart
/// FeedbackConfig(
///   baseTier: FeedbackTier.high,
///   durationOverride: Duration(milliseconds: 100), // Faster than default 150ms
/// )
/// ```
class FeedbackConfig {
  /// Creates a feedback configuration with tier-based defaults and optional overrides
  ///
  /// - [baseTier]: Base tier for default values (required)
  /// - [durationOverride]: Override animation duration (null = use tier default)
  /// - [hapticOverride]: Override haptic style (null = use tier default)
  /// - [scaleOverride]: Override scale factor (null = use tier default)
  const FeedbackConfig({
    required this.baseTier,
    this.durationOverride,
    this.hapticOverride,
    this.scaleOverride,
  });

  /// Base tier for default feedback values
  final FeedbackTier baseTier;

  /// Override for animation duration (null = use tier default)
  final Duration? durationOverride;

  /// Override for haptic feedback style (null = use tier default)
  final HapticFeedbackStyle? hapticOverride;

  /// Override for scale factor (null = use tier default)
  final double? scaleOverride;

  // ============================================
  // Getters with Fallback Pattern
  // ============================================

  /// Animation duration (override or tier default)
  Duration get duration => durationOverride ?? baseTier.duration;

  /// Haptic feedback style (override or tier default)
  ///
  /// Returns null if both override and tier default are null (no haptic).
  HapticFeedbackStyle? get hapticStyle => hapticOverride ?? baseTier.hapticStyle;

  /// Scale factor for animation (override or tier default)
  double get scaleFactor => scaleOverride ?? baseTier.scaleFactor;

  // ============================================
  // Factory Constructors (Common Presets)
  // ============================================

  /// High-intensity feedback preset
  ///
  /// - Scale: 0.95 (pronounced)
  /// - Duration: 150ms
  /// - Haptic: Medium impact
  ///
  /// Use for: Primary CTAs, destructive actions, important interactions
  factory FeedbackConfig.high() => const FeedbackConfig(
        baseTier: FeedbackTier.high,
      );

  /// Standard feedback preset (default)
  ///
  /// - Scale: 0.98 (subtle)
  /// - Duration: 150ms
  /// - Haptic: Light impact
  ///
  /// Use for: Cards, list items, most interactive elements
  factory FeedbackConfig.standard() => const FeedbackConfig(
        baseTier: FeedbackTier.standard,
      );

  /// Minimal feedback preset
  ///
  /// - Scale: 0.98 (subtle)
  /// - Duration: 100ms (faster)
  /// - Haptic: None
  ///
  /// Use for: Secondary actions, high-frequency interactions
  factory FeedbackConfig.minimal() => const FeedbackConfig(
        baseTier: FeedbackTier.minimal,
      );

  // ============================================
  // Special Presets (Combinations)
  // ============================================

  /// High intensity but faster animation
  ///
  /// - Scale: 0.95 (pronounced)
  /// - Duration: 100ms (faster than standard 150ms)
  /// - Haptic: Medium impact
  ///
  /// Use for: Quick actions that need pronounced feedback but fast response
  factory FeedbackConfig.highButFast() => const FeedbackConfig(
        baseTier: FeedbackTier.high,
        durationOverride: Duration(milliseconds: 100),
      );

  /// Standard visual feedback without haptic
  ///
  /// - Scale: 0.98 (subtle)
  /// - Duration: 150ms
  /// - Haptic: None (override to null)
  ///
  /// Use for: Accessibility (reduce motion), silent interactions
  factory FeedbackConfig.visualOnly() => const FeedbackConfig(
        baseTier: FeedbackTier.standard,
        hapticOverride: null, // Explicit no haptic
      );
}

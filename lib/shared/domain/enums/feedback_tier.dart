import 'package:gymbro_flutter_new/shared/domain/enums/haptic_feedback_style.dart';

/// Feedback intensity tier for interactive elements
///
/// Defines three hierarchical levels of tap feedback intensity:
/// - **high**: Pronounced feedback (0.95 scale, 150ms, medium haptic)
/// - **standard**: Balanced feedback (0.98 scale, 150ms, light haptic)
/// - **minimal**: Subtle feedback (0.98 scale, 100ms, no haptic)
///
/// Use with [FeedbackConfig] for composable override patterns.
enum FeedbackTier {
  /// High intensity feedback
  ///
  /// - Scale: 0.95 (more pronounced)
  /// - Duration: 150ms
  /// - Haptic: Medium impact
  ///
  /// Use for: Primary CTAs, destructive actions, high-importance interactions
  high,

  /// Standard intensity feedback (default)
  ///
  /// - Scale: 0.98 (subtle)
  /// - Duration: 150ms
  /// - Haptic: Light impact
  ///
  /// Use for: Cards, list items, most interactive elements
  standard,

  /// Minimal intensity feedback
  ///
  /// - Scale: 0.98 (subtle)
  /// - Duration: 100ms (faster)
  /// - Haptic: None
  ///
  /// Use for: Secondary actions, high-frequency interactions
  minimal,
}

/// Extension methods for feedback tier configuration
extension FeedbackTierExt on FeedbackTier {
  /// Scale factor for AnimatedScale (1.0 → scaleFactor)
  double get scaleFactor {
    switch (this) {
      case FeedbackTier.high:
        return 0.95; // More pronounced
      case FeedbackTier.standard:
      case FeedbackTier.minimal:
        return 0.98; // Subtle, Apple-like
    }
  }

  /// Animation duration for scale transition
  Duration get duration {
    switch (this) {
      case FeedbackTier.high:
      case FeedbackTier.standard:
        return const Duration(milliseconds: 150);
      case FeedbackTier.minimal:
        return const Duration(milliseconds: 100); // Faster for high-frequency
    }
  }

  /// Haptic feedback style (null = no haptic)
  HapticFeedbackStyle? get hapticStyle {
    switch (this) {
      case FeedbackTier.high:
        return HapticFeedbackStyle.medium;
      case FeedbackTier.standard:
        return HapticFeedbackStyle.light;
      case FeedbackTier.minimal:
        return null; // No haptic for minimal
    }
  }
}

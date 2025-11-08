import 'package:flutter/services.dart';

/// Haptic feedback intensity levels
///
/// Maps to Flutter's HapticFeedback methods:
/// - **light**: Light impact (subtle)
/// - **medium**: Medium impact (balanced)
/// - **heavy**: Heavy impact (pronounced)
///
/// Use via extension method: `HapticFeedbackStyle.medium.trigger()`
enum HapticFeedbackStyle {
  /// Light haptic impact (subtle)
  ///
  /// Use for: Standard interactions, non-critical actions
  light,

  /// Medium haptic impact (balanced)
  ///
  /// Use for: Primary actions, important interactions
  medium,

  /// Heavy haptic impact (pronounced)
  ///
  /// Use for: Critical actions, warnings, errors
  heavy,
}

/// Extension method for triggering haptic feedback
extension HapticFeedbackStyleExt on HapticFeedbackStyle {
  /// Trigger the haptic feedback
  ///
  /// Asynchronously calls the appropriate HapticFeedback method.
  /// Safe to call on all platforms (no-op on platforms without haptic support).
  ///
  /// Example:
  /// ```dart
  /// await HapticFeedbackStyle.medium.trigger();
  /// ```
  Future<void> trigger() async {
    switch (this) {
      case HapticFeedbackStyle.light:
        await HapticFeedback.lightImpact();
      case HapticFeedbackStyle.medium:
        await HapticFeedback.mediumImpact();
      case HapticFeedbackStyle.heavy:
        await HapticFeedback.heavyImpact();
    }
  }
}

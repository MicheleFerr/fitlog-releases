/// Recovery Recommendation Localization
///
/// Extension to localize recovery recommendation keys from domain layer.
///
/// The domain layer returns recommendation keys (e.g., 'optimal', 'consecutive_bad_3:4')
/// and this extension provides the localized text for UI display.
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Extension to get localized recommendation text
extension RecoveryRecommendationL10n on String {
  /// Get localized recommendation text for UI display
  ///
  /// Handles keys:
  /// - 'consecutive_bad_3:N' - N consecutive nights under 6h
  /// - 'consecutive_bad_2' - 2 consecutive bad nights
  /// - 'optimal', 'good', 'moderate', 'low', 'critical' - category-based
  String localizedRecommendation(BuildContext context) {
    final l10n = context.l10n;

    // Handle consecutive bad nights with count
    if (startsWith('consecutive_bad_3:')) {
      final nights = split(':').last;
      return l10n.recoveryRecommendationConsecutiveBad3(nights);
    }

    // Handle other keys
    return switch (this) {
      'consecutive_bad_2' => l10n.recoveryRecommendationConsecutiveBad2,
      'optimal' => l10n.recoveryRecommendationOptimal,
      'good' => l10n.recoveryRecommendationGood,
      'moderate' => l10n.recoveryRecommendationModerate,
      'low' => l10n.recoveryRecommendationLow,
      'critical' => l10n.recoveryRecommendationCritical,
      // Fallback for legacy hardcoded strings or unknown keys
      _ => this,
    };
  }
}

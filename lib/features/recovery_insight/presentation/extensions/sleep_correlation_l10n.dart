/// Sleep Correlation Localization
///
/// Extension to localize sleep-workout correlation summary messages.
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Extension to get localized correlation summary
extension SleepCorrelationL10n on String {
  /// Get localized correlation summary message
  ///
  /// Handles keys:
  /// - 'not_enough_data' - needs more workout data
  /// - 'not_significant' - not enough for significant correlation
  /// - 'consistently_good:Xh:Ykg' - sleeps well consistently
  /// - 'consistently_poor:Xh:Ykg' - sleeps poorly consistently
  /// - 'significant:increase|decrease:increase|decrease:X%:Y%' - full summary
  String localizedCorrelationSummary(BuildContext context) {
    final l10n = context.l10n;

    if (this == 'not_enough_data') {
      return l10n.correlationNotEnoughData;
    }

    if (this == 'not_significant') {
      return l10n.correlationNotSignificant;
    }

    // Parse consistently_good key: consistently_good:avgSleep:avgVolume
    if (startsWith('consistently_good:')) {
      final parts = split(':');
      if (parts.length >= 3) {
        final avgSleep = parts[1];
        final avgVolume = parts[2];
        return l10n.correlationConsistentlyGood(avgSleep, avgVolume);
      }
    }

    // Parse consistently_poor key: consistently_poor:avgSleep:avgVolume
    if (startsWith('consistently_poor:')) {
      final parts = split(':');
      if (parts.length >= 3) {
        final avgSleep = parts[1];
        final avgVolume = parts[2];
        return l10n.correlationConsistentlyPoor(avgSleep, avgVolume);
      }
    }

    // Parse significant key: significant:goodEffect:poorEffect:goodChange:poorChange
    if (startsWith('significant:')) {
      final parts = split(':');
      if (parts.length >= 5) {
        final goodEffect = parts[1] == 'increase'
            ? l10n.correlationEffectIncrease
            : l10n.correlationEffectDecrease;
        final poorEffect = parts[2] == 'increase'
            ? l10n.correlationEffectIncrease
            : l10n.correlationEffectDecrease;
        final goodChange = parts[3];
        final poorChange = parts[4];

        return l10n.correlationSignificant(
          goodEffect,
          goodChange,
          poorEffect,
          poorChange,
        );
      }
    }

    // Fallback
    return this;
  }
}

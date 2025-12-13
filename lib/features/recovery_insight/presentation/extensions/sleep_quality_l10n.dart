/// Sleep Quality Localization Extension
///
/// Provides localized display names for SleepQuality enum.
///
/// **Architecture Rule**: Domain entities cannot depend on presentation layer,
/// so we create this extension in the presentation layer to provide localized
/// names using AppLocalizations (which requires BuildContext).
///
/// **Usage**:
/// ```dart
/// final quality = SleepQuality.optimal;
/// Text(quality.localizedName(context));  // "Optimal" / "Ottimale"
/// ```
library;

import 'package:flutter/widgets.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/sleep_record.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Extension for localized SleepQuality names
extension SleepQualityL10n on SleepQuality {
  /// Get localized name for the sleep quality
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case SleepQuality.critical:
        return l10n.sleepQualityCritical;
      case SleepQuality.suboptimal:
        return l10n.sleepQualitySuboptimal;
      case SleepQuality.optimal:
        return l10n.sleepQualityOptimal;
      case SleepQuality.excessive:
        return l10n.sleepQualityExcessive;
    }
  }
}

/// Recovery Category Localization Extension
///
/// Provides localized display names for RecoveryCategory enum.
///
/// **Architecture Rule**: Domain entities cannot depend on presentation layer,
/// so we create this extension in the presentation layer to provide localized
/// names using AppLocalizations (which requires BuildContext).
///
/// **Usage**:
/// ```dart
/// final category = RecoveryCategory.optimal;
/// Text(category.localizedName(context));  // "Optimal" / "Ottimale"
/// Text(category.localizedShortName(context));  // "Top"
/// ```
library;

import 'package:flutter/widgets.dart';
import 'package:gymbro_flutter_new/features/recovery_insight/domain/entities/recovery_insight.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Extension for localized RecoveryCategory names
extension RecoveryCategoryL10n on RecoveryCategory {
  /// Get localized full name for the category
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case RecoveryCategory.optimal:
        return l10n.recoveryCategoryOptimal;
      case RecoveryCategory.good:
        return l10n.recoveryCategoryGood;
      case RecoveryCategory.moderate:
        return l10n.recoveryCategoryModerate;
      case RecoveryCategory.low:
        return l10n.recoveryCategoryLow;
      case RecoveryCategory.critical:
        return l10n.recoveryCategoryCritical;
    }
  }

  /// Get localized short name for charts and compact displays
  String localizedShortName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case RecoveryCategory.optimal:
        return l10n.recoveryCategoryShortOptimal;
      case RecoveryCategory.good:
        return l10n.recoveryCategoryShortGood;
      case RecoveryCategory.moderate:
        return l10n.recoveryCategoryShortModerate;
      case RecoveryCategory.low:
        return l10n.recoveryCategoryShortLow;
      case RecoveryCategory.critical:
        return l10n.recoveryCategoryShortCritical;
    }
  }
}

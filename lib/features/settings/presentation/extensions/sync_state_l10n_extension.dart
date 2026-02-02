/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/extensions
/// 🎯 Feature: settings
/// 🔧 Type: extension (localization helper)
///
/// Localizes CloudSyncState strings for UI display
/// Solves the architecture constraint where providers cannot access BuildContext
library;

import 'package:flutter/widgets.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/providers/cloud_sync_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Extension to localize CloudSyncState messages
///
/// Usage in widgets:
/// ```dart
/// final syncState = ref.watch(cloudSyncProvider);
/// final message = syncState.getLocalizedStatusMessage(context);
/// ```
extension CloudSyncStateL10n on CloudSyncState {
  /// Get localized status message based on current sync state
  String getLocalizedStatusMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // If syncing, show progress message
    if (isSyncing) {
      return progress?.getLocalizedMessage(context) ?? l10n.syncing;
    }

    // If has errors, show first error (localized if possible)
    if (errors.isNotEmpty) {
      final errorCode = errors.first;
      return _localizeError(context, errorCode);
    }

    // Show time since last sync
    if (lastSyncTime != null) {
      final lastSync = DateTime.parse(lastSyncTime!);
      final diff = DateTime.now().difference(lastSync);

      if (diff.inMinutes < 1) {
        return l10n.syncedJustNow;
      } else if (diff.inHours < 1) {
        return l10n.syncedMinutesAgo(diff.inMinutes);
      } else if (diff.inDays < 1) {
        return l10n.syncedHoursAgo(diff.inHours);
      } else {
        return l10n.syncedDaysAgo(diff.inDays);
      }
    }

    return l10n.neverSynced;
  }

  /// Localize error messages from provider
  String _localizeError(BuildContext context, String errorMessage) {
    final l10n = AppLocalizations.of(context);

    // Map known error patterns to localized strings
    if (errorMessage.contains('not authenticated')) {
      return l10n.userNotAuthenticated;
    }

    if (errorMessage.startsWith('Sync failed:')) {
      // Extract error details if present
      final errorDetails = errorMessage.replaceFirst('Sync failed: ', '');
      return l10n.syncError(errorDetails);
    }

    // Return original message if no localization available
    return errorMessage;
  }

  /// Get localized error messages list
  List<String> getLocalizedErrors(BuildContext context) {
    return errors.map((error) => _localizeError(context, error)).toList();
  }
}

/// Extension to localize SyncProgress messages
extension SyncProgressL10n on SyncProgress {
  /// Get localized message for current sync progress
  String getLocalizedMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Map currentItem string to localization keys
    // Note: currentItem is set in provider with hardcoded English
    // We detect patterns to map to l10n keys

    if (currentItem.contains('Syncing workouts...')) {
      // Check if it has progress count
      if (currentItem.contains('(') && currentItem.contains('/')) {
        return l10n.syncingWorkoutsProgress(syncedItems, totalItems);
      }
      return l10n.syncingWorkouts;
    }

    if (currentItem.contains('Syncing templates...')) {
      return l10n.syncingTemplates;
    }

    if (currentItem.contains('Syncing exercises...')) {
      return l10n.syncingExercises;
    }

    if (currentItem.contains('Syncing personal records...')) {
      return l10n.syncingPersonalRecords;
    }

    if (currentItem.contains('Syncing settings...')) {
      return l10n.syncingSettings;
    }

    if (currentItem.contains('Sync complete!')) {
      return l10n.syncComplete;
    }

    // Fallback to original string if no match
    return currentItem;
  }

  /// Get localized percentage string
  String getLocalizedPercentage(BuildContext context) {
    return '${percentage.toStringAsFixed(0)}%';
  }
}

/// Extension to localize SyncSummary
extension SyncSummaryL10n on SyncSummary {
  /// Get localized summary message
  /// Example: "Synced 5 workouts, 3 templates, 10 exercises"
  String getLocalizedSummary(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final parts = <String>[];

    if (workoutsSynced > 0) {
      parts.add('$workoutsSynced ${_pluralize(context, workoutsSynced, l10n.workout, l10n.workouts)}');
    }

    if (templatesSynced > 0) {
      parts.add('$templatesSynced template${templatesSynced == 1 ? '' : 's'}');
    }

    if (exercisesSynced > 0) {
      parts.add('$exercisesSynced ${_pluralize(context, exercisesSynced, l10n.exercise, l10n.exercises)}');
    }

    if (personalRecordsSynced > 0) {
      parts.add('$personalRecordsSynced record${personalRecordsSynced == 1 ? '' : 's'}');
    }

    if (parts.isEmpty) {
      return l10n.neverSynced;
    }

    return '${l10n.syncCompleted}: ${parts.join(', ')}';
  }

  /// Helper to pluralize words
  String _pluralize(BuildContext context, int count, String singular, String plural) {
    return count == 1 ? singular : plural;
  }
}

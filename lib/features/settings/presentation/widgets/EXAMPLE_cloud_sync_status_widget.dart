/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/widgets
/// 🎯 Feature: settings
/// 🔧 Type: example widget
///
/// EXAMPLE: How to properly display localized CloudSyncProvider state
/// This demonstrates the CORRECT pattern for localizing provider strings
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/providers/cloud_sync_provider.dart';
import 'package:gymbro_flutter_new/features/settings/presentation/extensions/sync_state_l10n_extension.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Example widget showing proper localization of sync state
///
/// ✅ CORRECT PATTERN:
/// - Provider stores state with hardcoded strings (no BuildContext)
/// - Extension methods localize when rendering in widget (has BuildContext)
///
/// ❌ WRONG PATTERN:
/// - Trying to localize inside provider (no BuildContext available)
class ExampleCloudSyncStatusWidget extends ConsumerWidget {
  const ExampleCloudSyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(cloudSyncProvider);
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              l10n.syncStatus,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // ✅ CORRECT: Use extension method to get localized status
            Text(
              syncState.getLocalizedStatusMessage(context),
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            // Show progress if syncing
            if (syncState.isSyncing && syncState.progress != null) ...[
              const SizedBox(height: 12),
              // ✅ CORRECT: Use extension method for localized progress
              Text(
                syncState.progress!.getLocalizedMessage(context),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: syncState.progress!.percentage / 100,
              ),
              Text(
                syncState.progress!.getLocalizedPercentage(context),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],

            // Show errors if any
            if (syncState.errors.isNotEmpty) ...[
              const SizedBox(height: 12),
              // ✅ CORRECT: Use extension method for localized errors
              ...syncState.getLocalizedErrors(context).map((error) => Text(
                    error,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  )),
            ],

            // Show last sync summary if available
            if (syncState.lastSyncSummary != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                l10n.lastSynced,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              // ✅ CORRECT: Use extension method for localized summary
              Text(
                syncState.lastSyncSummary!.getLocalizedSummary(context),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],

            // Sync button
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: syncState.isSyncing
                  ? null
                  : () => ref.read(cloudSyncProvider.notifier).syncFromCloud(),
              child: Text(l10n.syncNow),
            ),
          ],
        ),
      ),
    );
  }
}

/// ❌ WRONG EXAMPLE - DO NOT DO THIS
///
/// This would NOT work because providers don't have BuildContext:
///
/// ```dart
/// // Inside cloud_sync_provider.dart
/// Future<void> syncFromCloud() async {
///   // ❌ ERROR: 'context' doesn't exist in provider!
///   state = state.copyWith(
///     progress: SyncProgress(
///       currentItem: context.l10n.syncingWorkouts, // ❌ NO CONTEXT!
///     ),
///   );
/// }
/// ```
///
/// ✅ CORRECT APPROACH:
///
/// 1. Provider stores hardcoded string or code:
/// ```dart
/// state = state.copyWith(
///   progress: SyncProgress(
///     currentItem: 'Syncing workouts...', // ✅ Hardcoded is OK here
///   ),
/// );
/// ```
///
/// 2. Extension method maps to localized string:
/// ```dart
/// extension SyncProgressL10n on SyncProgress {
///   String getLocalizedMessage(BuildContext context) {
///     if (currentItem.contains('workouts')) {
///       return context.l10n.syncingWorkouts; // ✅ Context available!
///     }
///     return currentItem;
///   }
/// }
/// ```
///
/// 3. Widget uses extension:
/// ```dart
/// Text(syncState.progress!.getLocalizedMessage(context))
/// ```

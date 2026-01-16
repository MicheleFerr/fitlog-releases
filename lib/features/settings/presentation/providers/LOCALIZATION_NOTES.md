# Cloud Sync Provider - Localization Architecture

## Problem Statement

The `cloud_sync_provider.dart` file contains hardcoded English strings that **CANNOT be directly localized** due to Clean Architecture constraints.

## Why Direct Localization is NOT Possible

### Architecture Constraint
- **Provider Layer** = Data/State Management Layer (NO BuildContext)
- **Localization** (`AppLocalizations`) requires `BuildContext`
- Providers run in isolation and cannot access UI context

### Affected Code Locations

#### ❌ Cannot Localize (No BuildContext)
```dart
// Lines 134-249: syncFromCloud() method
state = state.copyWith(errors: ['User not authenticated']); // Line 138
progress: SyncProgress(currentItem: 'Syncing workouts...', ...); // Line 163
progress: SyncProgress(currentItem: 'Syncing templates...', ...); // Line 173
progress: SyncProgress(currentItem: 'Sync complete!', ...); // Line 230
errors: ['Sync failed: $e']; // Line 246

// Lines 252-501: Private sync methods
'Syncing workouts... ($synced/${snapshot.docs.length})' // Line 290

// Lines 562-583: getSyncStatusMessage()
'Synced just now' // Line 572
'Synced ${diff.inMinutes} minutes ago' // Line 574
'Never synced' // Line 582
```

## Correct Solution: Localize at UI Consumption Point

### Pattern to Follow

**Provider stores keys/codes → UI widgets translate to localized strings**

```dart
// ✅ PROVIDER: Store error codes (not localized strings)
state = state.copyWith(
  errors: ['error_user_not_authenticated'], // Key, not string
);

// ✅ UI WIDGET: Translate when displaying
class SyncStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(cloudSyncProvider);

    // Translate error codes to localized messages
    final errorMessages = syncState.errors.map((errorCode) {
      switch (errorCode) {
        case 'error_user_not_authenticated':
          return context.l10n.userNotAuthenticated;
        case 'error_sync_failed':
          return context.l10n.syncError; // With parameter
        default:
          return errorCode; // Fallback
      }
    }).toList();

    return Text(errorMessages.join('\n'));
  }
}
```

### Alternative: Helper Extension (Recommended)

Create a BuildContext extension to translate sync states:

```dart
// lib/features/settings/presentation/extensions/sync_state_extensions.dart
extension CloudSyncStateL10n on CloudSyncState {
  String getLocalizedStatusMessage(BuildContext context) {
    if (isSyncing) {
      return progress?.getLocalizedMessage(context) ?? context.l10n.syncing;
    }

    if (lastSyncTime != null) {
      final lastSync = DateTime.parse(lastSyncTime!);
      final diff = DateTime.now().difference(lastSync);

      if (diff.inMinutes < 1) {
        return context.l10n.syncedJustNow;
      } else if (diff.inHours < 1) {
        return context.l10n.syncedMinutesAgo(diff.inMinutes);
      } else if (diff.inDays < 1) {
        return context.l10n.syncedHoursAgo(diff.inHours);
      } else {
        return context.l10n.syncedDaysAgo(diff.inDays);
      }
    }

    return context.l10n.neverSynced;
  }
}

extension SyncProgressL10n on SyncProgress {
  String getLocalizedMessage(BuildContext context) {
    // Map currentItem to l10n keys
    if (currentItem.contains('workouts')) {
      if (currentItem.contains('(')) {
        return context.l10n.syncingWorkoutsProgress(syncedItems, totalItems);
      }
      return context.l10n.syncingWorkouts;
    }
    if (currentItem.contains('templates')) {
      return context.l10n.syncingTemplates;
    }
    if (currentItem.contains('exercises')) {
      return context.l10n.syncingExercises;
    }
    if (currentItem.contains('personal records')) {
      return context.l10n.syncingPersonalRecords;
    }
    if (currentItem.contains('settings')) {
      return context.l10n.syncingSettings;
    }
    if (currentItem.contains('complete')) {
      return context.l10n.syncComplete;
    }
    return currentItem; // Fallback
  }
}
```

### Usage in UI

```dart
// Instead of:
final message = ref.read(syncStatusMessageProvider); // ❌ Returns hardcoded English

// Use:
final syncState = ref.watch(cloudSyncProvider);
final message = syncState.getLocalizedStatusMessage(context); // ✅ Localized
```

## Localization Keys Added

All required keys have been added to `app_en.arb` and `app_it.arb`:

### Existing Keys (Already Available)
- `userNotAuthenticated` - "User not authenticated" / "Utente non autenticato"
- `syncingWorkouts` - "Syncing workouts..." / "Sincronizzazione allenamenti..."
- `syncingSettings` - "Syncing settings..." / "Sincronizzazione impostazioni..."
- `neverSynced` - "Never synced" / "Mai sincronizzato"
- `syncCompleted` - "Sync completed" / "Sincronizzazione completata"

### New Keys Added
- `syncingTemplates` - "Syncing templates..." / "Sincronizzazione template..."
- `syncingExercises` - "Syncing exercises..." / "Sincronizzazione esercizi..."
- `syncingPersonalRecords` - "Syncing personal records..." / "Sincronizzazione record personali..."
- `syncComplete` - "Sync complete!" / "Sincronizzazione completata!"
- `syncedJustNow` - "Synced just now" / "Sincronizzato proprio ora"
- `syncedMinutesAgo` - "Synced {minutes} minutes ago" / "Sincronizzato {minutes} minuti fa"
- `syncedHoursAgo` - "Synced {hours} hours ago" / "Sincronizzato {hours} ore fa"
- `syncedDaysAgo` - "Synced {days} days ago" / "Sincronizzato {days} giorni fa"
- `syncingWorkoutsProgress` - "Syncing workouts... ({synced}/{total})" / "Sincronizzazione allenamenti... ({synced}/{total})"

## Migration Path

1. **Phase 1**: Keep existing hardcoded strings in provider (backward compatible)
2. **Phase 2**: Create extension methods for localization
3. **Phase 3**: Update UI widgets to use extensions
4. **Phase 4** (Optional): Refactor provider to use error codes instead of strings

## References

- [CLAUDE.md](/Users/michele/gymbro_flutter_new/CLAUDE.md) - "NO const with context.l10n"
- [DEVELOPMENT_RULES.md](/Users/michele/gymbro_flutter_new/docs/DEVELOPMENT_RULES.md) - Layer separation rules
- [ADR-001](/Users/michele/gymbro_flutter_new/docs/ADR/ADR-001-clean-architecture.md) - Clean Architecture adoption

## Summary

**TL;DR**: Provider strings CANNOT be localized directly due to missing BuildContext. Localization MUST happen in UI widgets that consume the provider state. All required l10n keys have been added to support this pattern.

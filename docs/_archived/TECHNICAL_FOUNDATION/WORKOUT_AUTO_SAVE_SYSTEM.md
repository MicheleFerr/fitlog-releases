# 🚀 Workout Auto-Save System: Crash Recovery & Draft Management

> **HIGH Priority System** - Prevents data loss during workouts
> **Location**: `lib/features/workout/presentation/providers/workout_auto_save_provider.dart`
> **Status**: Production (active protection)
> **Last Updated**: October 2025

## Overview

The **Workout Auto-Save System** protects user data by:
- **Periodic Auto-Save**: Every 10 minutes during active workout
- **Event-Triggered Save**: Immediate save on significant changes
- **Debounce Protection**: Prevents excessive saves (5-second minimum gap)
- **Draft Recovery**: Automatically recovers unsaved progress on app crash
- **Stale Draft Cleanup**: Removes old drafts automatically

## Architecture

### State Management
```dart
class WorkoutAutoSaveState {
  final bool isAutoSaveEnabled;     // User can disable
  final DateTime? lastSaveTime;     // When last saved
  final bool isSaving;              // Currently saving?
  final String? lastError;          // Last error if any
}
```

### Key Components

**WorkoutAutoSaveNotifier**: Manages auto-save logic
```dart
- _autoSaveInterval: 10 minutes (periodic save)
- _debounceDelay: 5 seconds (rapid-save protection)
- _lastSavedWorkout: Tracks last saved state
```

**WorkoutDraftRepository**: Persists drafts to Hive
```dart
- saveCurrentDraft(): Store workout draft
- getCurrentDraft(): Retrieve draft
- recoverDraft(): Restore after crash
- clearOldDrafts(): Cleanup >7 days old
```

## Save Triggers

1. **Manual Save**: User completes set
2. **Event-Based**: Exercise added, workout started
3. **Periodic**: Every 10 minutes automatically
4. **Lifecycle**: When app goes to background

## Recovery Flow

```
App crashes during workout
  ↓
User relaunches app
  ↓
System checks: hasRecoverableDraft()?
  ├─ No draft → Start fresh
  ├─ Draft too old → Discard
  └─ Valid draft → Recovery dialog
  ↓
User taps "Recover"
  ↓
Load draft into provider
  ↓
UI shows recovered state
  ↓
User can continue or discard
```

## Implementation

```dart
// In your workout screen
class WorkoutScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoSave = ref.watch(workoutAutoSaveProvider);

    useEffect(() {
      // Start auto-save when entering
      final workoutState = ref.read(currentWorkoutProvider);
      if (workoutState != null) {
        ref.read(workoutAutoSaveProvider.notifier)
            .startAutoSave(workoutState);
      }
      return null;
    }, []);

    // Save on specific events
    void onSetCompleted() {
      final workout = ref.read(currentWorkoutProvider)!;
      ref.read(workoutAutoSaveProvider.notifier)
          .triggerSave(workout);
    }

    return Scaffold(
      // Your workout UI
    );
  }
}
```

## Performance

| Metric | Value |
|--------|-------|
| **Save Duration** | 50-200ms |
| **Memory per Draft** | 100-500KB |
| **Max Drafts Stored** | 10 |
| **Auto-Save Frequency** | 10 minutes |
| **Debounce Delay** | 5 seconds |

## Troubleshooting

### Drafts Not Recovering
- Check `hasRecoverableDraft()` logic
- Verify draft has completed sets
- Check if draft > 7 days old

### Excessive Saves
- Debounce timer ensures minimum 5s gap
- Check if events firing too frequently
- Monitor performance impact

### Storage Issues
- Hive box limit: 500MB
- Clean old drafts: `clearOldDrafts()`
- Monitor draft repository size

---

**See Also**: `HYBRID_REPOSITORY_ARCHITECTURE.md` (persistence pattern)

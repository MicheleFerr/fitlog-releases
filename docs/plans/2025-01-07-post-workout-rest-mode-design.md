# Post-Workout Rest Mode Design

**Date**: 2025-01-07
**Status**: Validated ✅
**Priority**: B (User Experience Enhancement)

## Overview

Add "Rest Mode" state to SmartWorkoutCTA that shows congratulatory message and workout statistics when user has already completed a workout today (after 04:00 cutoff).

## Problem Statement

Current SmartWorkoutCTA always shows "INIZIA ALLENAMENTO" when there's an uncompleted workout in the routine, even if the user already worked out today. This doesn't respect rest requirements and may encourage overtraining.

**User Request**:
> "se ho fatto un allenamento non deve indicarmi l'inizio dell'allenamento almeno fino alle 04:00 del giorno successivo... dovrebbe uscirmi tipo: goditi il meritato riposo hai fatto un allenamento pazzesco con: Volume: xxxx kg della durata di: xxm xxs"

## Design Goals

### Primary Goals
- ✅ Detect if user worked out today (after 04:00 cutoff)
- ✅ Show congratulatory message with workout statistics
- ✅ Prevent "start workout" CTA when already trained today
- ✅ Encourage proper rest and recovery

### User Requirements (Validated)
- ✅ **Cutoff**: Fixed 04:00 (workout after 04:00 counts as "today")
- ✅ **Statistics**: Volume (kg), Duration (mm:ss), Sets completed
- ✅ **Interaction**: Not tappable (informational only)
- ✅ **Design**: Same gradient as active state (visual consistency)

## Architecture

### 1. New Provider: `todayCompletedWorkoutProvider`

**Type**: `FutureProvider.autoDispose<Workout?>`

**Purpose**: Check if user has completed a workout today (after 04:00 cutoff).

**Implementation**:
```dart
final todayCompletedWorkoutProvider = FutureProvider.autoDispose<Workout?>((ref) async {
  final userId = ref.watch(_currentUserIdProvider);

  if (kDebugMode) {
    debugPrint('🔍 [todayCompletedWorkoutProvider] START - userId: $userId');
  }

  if (userId == null) {
    if (kDebugMode) {
      debugPrint('⚠️ [todayCompletedWorkoutProvider] No userId, returning null');
    }
    return null;
  }

  final repository = ref.watch(workoutRepositoryProvider);

  try {
    // Get last completed workout with timeout
    final lastWorkout = await repository
        .getLastCompletedWorkout(userId)
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            if (kDebugMode) {
              debugPrint('⏱️ [todayCompletedWorkoutProvider] Timeout after 5s');
            }
            return null;
          },
        );

    if (lastWorkout == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [todayCompletedWorkoutProvider] No last workout found');
      }
      return null;
    }

    // Calculate today's 04:00 cutoff
    final now = DateTime.now();
    final todayCutoff = DateTime(now.year, now.month, now.day, 4, 0);

    // Check if workout was after cutoff
    if (lastWorkout.startTime.isAfter(todayCutoff)) {
      if (kDebugMode) {
        debugPrint('✅ [todayCompletedWorkoutProvider] Workout done today: ${lastWorkout.id}');
      }
      return lastWorkout;
    }

    if (kDebugMode) {
      debugPrint('⚠️ [todayCompletedWorkoutProvider] Last workout was before cutoff');
    }
    return null;

  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [todayCompletedWorkoutProvider] Error: $e');
    }
    return null; // Graceful fallback
  }
});
```

**Key Features**:
- ✅ 5-second timeout protection
- ✅ AutoDispose for automatic cleanup
- ✅ Graceful error recovery (returns null)
- ✅ Debug logging (START, no userId, timeout, success, error)
- ✅ 04:00 cutoff logic

### 2. Repository Method: `getLastCompletedWorkout()`

**Location**: `WorkoutRepository` interface + implementations

**Signature**:
```dart
Future<Workout?> getLastCompletedWorkout(String userId);
```

**Implementation** (Hive/Firebase):
- Query workouts for userId
- Filter by `endTime != null` (completed workouts only)
- Sort by `startTime` descending
- Return first result (most recent)

## UI Components

### Decision Flow

**Priority order** (top to bottom):
```
1. Loading state (both providers loading)
   ↓
2. Check: todayCompletedWorkout exists?
   ↓ YES → REST MODE (NEW)
   ↓ NO
3. Check: routine has uncompleted workout?
   ↓ YES → ACTIVE CTA (existing)
   ↓ NO → REST DAY (existing)
```

### Implementation

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final todayWorkoutAsync = ref.watch(todayCompletedWorkoutProvider);
  final routineAsync = ref.watch(safeActiveRoutineProvider);

  // Priority 1: Check if already worked out today
  return todayWorkoutAsync.when(
    loading: () => _buildLoadingState(context),
    error: (_, __) => _buildLoadingState(context), // Graceful fallback
    data: (todayWorkout) {
      if (todayWorkout != null) {
        // ✅ Workout done today → REST MODE
        return _buildRestModeState(context, todayWorkout);
      }

      // No workout today → check routine (existing logic)
      return routineAsync.when(
        loading: () => _buildLoadingState(context),
        error: (_, __) => _buildDisabledState(context, context.l10n.smartWorkoutCTAErrorLoading),
        data: (routine) {
          // ... existing active/disabled logic
        },
      );
    },
  );
}
```

### Rest Mode Card Layout

```
┌─────────────────────────────────────┐
│ 🏆 [Gradient Background]            │
│                                      │
│ 💪 Goditi il meritato riposo        │  ← Title (bold, large)
│ Hai fatto un allenamento pazzesco!  │  ← Subtitle
│                                      │
│ ┌──────────────────────────────────┐│
│ │ 📊 STATISTICHE                   ││  ← Stats container
│ │                                  ││
│ │ ⚖️  Volume: 4.250 kg             ││  ← Stat 1
│ │ ⏱️  Durata: 45m 32s               ││  ← Stat 2
│ │ ✅ Serie: 24                     ││  ← Stat 3
│ └──────────────────────────────────┘│
│                                      │
└─────────────────────────────────────┘
```

**Visual Design**:
- Same gradient as active state (primary → tertiary)
- Trophy icon (AppIcons.trophy)
- Stats container: semi-transparent white (alpha: 0.1)
- Each stat: icon + label + value
- NOT tappable (no InkWell, no haptic feedback)

### Statistics Calculation

**Helper Class**:
```dart
class WorkoutStats {
  final String volume;      // "4.250" (thousand separator)
  final String duration;    // "45m 32s"
  final int sets;           // 24

  const WorkoutStats({
    required this.volume,
    required this.duration,
    required this.sets,
  });
}
```

**Calculation Logic**:
```dart
WorkoutStats _calculateWorkoutStats(Workout workout) {
  // Volume: sum of all (weight × reps) across all sets
  double totalVolume = 0;
  int totalSets = 0;

  for (final exercise in workout.exercises) {
    for (final set in exercise.sets) {
      totalVolume += (set.weight ?? 0) * (set.reps ?? 0);
      totalSets++;
    }
  }

  // Duration: endTime - startTime
  final duration = workout.endTime != null
      ? workout.endTime!.difference(workout.startTime)
      : Duration.zero;

  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;

  return WorkoutStats(
    volume: NumberFormat('#,##0', 'it_IT').format(totalVolume.round()),
    duration: '${minutes}m ${seconds}s',
    sets: totalSets,
  );
}
```

**Key Points**:
- Volume: formatted with thousand separator (Italian locale)
- Duration: human-readable format "XXm YYs"
- Sets: simple integer count
- Null-safe for weight/reps (default to 0)

## Localization

### New Keys Required

**app_it.arb**:
```json
{
  "smartWorkoutCTARestModeTitle": "💪 Goditi il meritato riposo",
  "smartWorkoutCTARestModeSubtitle": "Hai fatto un allenamento pazzesco!",
  "smartWorkoutCTARestModeVolume": "Volume: {volume} kg",
  "@smartWorkoutCTARestModeVolume": {
    "placeholders": {
      "volume": {
        "type": "String"
      }
    }
  },
  "smartWorkoutCTARestModeDuration": "Durata: {duration}",
  "@smartWorkoutCTARestModeDuration": {
    "placeholders": {
      "duration": {
        "type": "String"
      }
    }
  },
  "smartWorkoutCTARestModeSets": "Serie: {sets}",
  "@smartWorkoutCTARestModeSets": {
    "placeholders": {
      "sets": {
        "type": "int"
      }
    }
  }
}
```

**app_en.arb**:
```json
{
  "smartWorkoutCTARestModeTitle": "💪 Enjoy your well-deserved rest",
  "smartWorkoutCTARestModeSubtitle": "You crushed an amazing workout!",
  "smartWorkoutCTARestModeVolume": "Volume: {volume} kg",
  "smartWorkoutCTARestModeDuration": "Duration: {duration}",
  "smartWorkoutCTARestModeSets": "Sets: {sets}"
}
```

## Implementation Checklist

### Phase 1: Repository & Provider
- [ ] Add `getLastCompletedWorkout()` to WorkoutRepository interface
- [ ] Implement in HiveWorkoutDataSource
- [ ] Implement in FirebaseWorkoutDataSource (if exists)
- [ ] Create `todayCompletedWorkoutProvider` in workout providers
- [ ] Test timeout behavior (5s)
- [ ] Test cutoff logic (04:00)

### Phase 2: Localization
- [ ] Add 6 keys to `app_it.arb`
- [ ] Add 6 keys to `app_en.arb`
- [ ] Run `flutter gen-l10n`
- [ ] Verify generated methods

### Phase 3: UI Components
- [ ] Add `_buildRestModeState()` widget method
- [ ] Add `_calculateWorkoutStats()` helper
- [ ] Add `_buildStatRow()` helper widget
- [ ] Update `build()` method with new decision flow
- [ ] Import `intl` package for NumberFormat

### Phase 4: Testing
- [ ] Test: No workout today → shows active CTA (existing)
- [ ] Test: Workout today after 04:00 → shows rest mode
- [ ] Test: Workout today before 04:00 (e.g., 03:30) → shows active CTA
- [ ] Test: Statistics calculation accurate (volume, duration, sets)
- [ ] Test: Both themes (dark/light)
- [ ] Test: Both locales (IT/EN)
- [ ] Test: Card not tappable in rest mode

## Success Criteria

### Must Have ✅
- ✅ Rest mode shows when workout done after 04:00
- ✅ Active CTA shows when no workout today
- ✅ Statistics accurate (volume, duration, sets)
- ✅ Full localization (IT/EN)
- ✅ 04:00 cutoff working correctly
- ✅ Card not tappable in rest mode

### Nice to Have ✨
- ✨ Smooth transition animation between states
- ✨ Personal records highlighted in stats

## Time Estimate

- **Phase 1** (Repository & Provider): 45 min
- **Phase 2** (Localization): 15 min
- **Phase 3** (UI Components): 45 min
- **Phase 4** (Testing): 30 min

**Total**: ~2 hours

## Edge Cases

### Workout started yesterday, ended today
**Scenario**: Started at 23:45 yesterday, ended at 00:30 today (after midnight but before 04:00)

**Expected**: Should NOT count as "today" (before 04:00 cutoff)

**Logic**: Use `startTime` for cutoff check, not `endTime`

### Multiple workouts in same day
**Scenario**: User does 2 workouts after 04:00

**Expected**: Show rest mode for entire day (04:00 to 03:59 next day)

**Logic**: Provider only checks "is there ANY completed workout after cutoff today?"

### Incomplete workout (no endTime)
**Scenario**: User started workout but didn't finish (app crash, forgot to end)

**Expected**: Should NOT count as completed workout

**Logic**: `getLastCompletedWorkout()` filters by `endTime != null`

## Rollback Plan

If issues arise:
1. Keep provider implementation (safe with timeout)
2. Remove rest mode UI state (revert to active/disabled only)
3. Keep localization keys (no harm)
4. Can re-enable later after fixing bugs

## Notes

- **Gradient preserved**: User explicitly requested same gradient as active state
- **Not tappable**: User validated this should be informational only
- **04:00 cutoff**: Aligns with fitness industry standard (training day ends at 4 AM)
- **Testing phase**: Single user (developer), breaking changes acceptable

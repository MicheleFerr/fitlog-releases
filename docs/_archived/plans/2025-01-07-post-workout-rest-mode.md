# Post-Workout Rest Mode Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** Add "Rest Mode" state to SmartWorkoutCTA that prevents workout CTA when user already trained today (after 04:00) and shows congratulatory message with statistics.

**Architecture:** Create new `todayCompletedWorkoutProvider` (FutureProvider) that checks last completed workout against 04:00 cutoff. Update SmartWorkoutCTA decision flow to prioritize rest mode over active CTA. Add statistics calculation helper and new UI state with gradient card.

**Tech Stack:** Flutter, Riverpod (FutureProvider.autoDispose), Firestore/Hive, intl (NumberFormat), Material 3

---

## Task 1: Add getLastCompletedWorkout() Repository Method

**Files:**
- Modify: `lib/features/workout/domain/repositories/workout_repository.dart` (add interface method)
- Modify: `lib/features/workout/data/datasources/hive_workout_datasource.dart` (implementation)

**Step 1: Add interface method to WorkoutRepository**

Location: `lib/features/workout/domain/repositories/workout_repository.dart`

Add this method to the abstract class:

```dart
/// Get last completed workout for user
///
/// Returns the most recent workout with endTime != null (completed).
/// Returns null if no completed workouts found.
Future<Workout?> getLastCompletedWorkout(String userId);
```

**Step 2: Implement in HiveWorkoutDataSource**

Location: `lib/features/workout/data/datasources/hive_workout_datasource.dart`

Find the class and add this method:

```dart
@override
Future<Workout?> getLastCompletedWorkout(String userId) async {
  try {
    if (kDebugMode) {
      debugPrint('🔍 [HiveWorkoutDataSource] getLastCompletedWorkout - userId: $userId');
    }

    // Get all workouts for user
    final allWorkouts = await getWorkouts(userId);

    // Filter completed workouts only (endTime != null)
    final completedWorkouts = allWorkouts
        .where((workout) => workout.endTime != null)
        .toList();

    if (completedWorkouts.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ [HiveWorkoutDataSource] No completed workouts found');
      }
      return null;
    }

    // Sort by startTime descending (most recent first)
    completedWorkouts.sort((a, b) => b.startTime.compareTo(a.startTime));

    final lastWorkout = completedWorkouts.first;

    if (kDebugMode) {
      debugPrint('✅ [HiveWorkoutDataSource] Found last workout: ${lastWorkout.id}');
    }

    return lastWorkout;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ [HiveWorkoutDataSource] Error: $e');
    }
    throw Exception('Failed to get last completed workout: $e');
  }
}
```

**Step 3: Verify flutter analyze passes**

Run: `flutter analyze lib/features/workout/`

Expected: No errors related to WorkoutRepository

**Step 4: Commit repository changes**

```bash
git add lib/features/workout/domain/repositories/workout_repository.dart
git add lib/features/workout/data/datasources/hive_workout_datasource.dart
git commit -m "feat: add getLastCompletedWorkout() repository method

Add method to retrieve most recent completed workout for cutoff logic.
Returns null if no completed workouts found. Includes debug logging."
```

---

## Task 2: Create todayCompletedWorkoutProvider

**Files:**
- Modify: `lib/features/workout/presentation/providers/workout_history_provider.dart` (add provider at end)

**Step 1: Add provider to workout_history_provider.dart**

Location: `lib/features/workout/presentation/providers/workout_history_provider.dart`

Add at the end of file (after existing providers):

```dart
/// Provider to check if user has completed a workout today (after 04:00 cutoff)
///
/// Returns the completed workout if found, null otherwise.
/// Uses 04:00 cutoff: workout after 04:00 today counts as "today".
final todayCompletedWorkoutProvider = FutureProvider.autoDispose<Workout?>((ref) async {
  final userId = ref.watch(authProvider).value?.uid;

  if (kDebugMode) {
    debugPrint('🔍 [todayCompletedWorkoutProvider] START - userId: $userId');
  }

  if (userId == null) {
    if (kDebugMode) {
      debugPrint('⚠️ [todayCompletedWorkoutProvider] No userId, returning null');
    }
    return null;
  }

  final dataSource = ref.watch(hiveWorkoutDataSourceProvider);

  try {
    // Get last completed workout with timeout
    final lastWorkout = await dataSource
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

**Step 2: Verify flutter analyze passes**

Run: `flutter analyze lib/features/workout/presentation/providers/workout_history_provider.dart`

Expected: No errors

**Step 3: Commit provider**

```bash
git add lib/features/workout/presentation/providers/workout_history_provider.dart
git commit -m "feat: add todayCompletedWorkoutProvider with 04:00 cutoff

Provider checks if user completed workout after 04:00 today.
- 5-second timeout protection
- AutoDispose for automatic cleanup
- Graceful error recovery (returns null)
- Debug logging at 5 key points"
```

---

## Task 3: Add Localization Keys (IT/EN)

**Files:**
- Modify: `assets/i18n/app_it.arb` (add 6 keys)
- Modify: `assets/i18n/app_en.arb` (add 6 keys)

**Step 1: Add keys to app_it.arb**

Location: `assets/i18n/app_it.arb`

Add these keys (alphabetically after existing smartWorkoutCTA* keys):

```json
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
```

**Step 2: Add keys to app_en.arb**

Location: `assets/i18n/app_en.arb`

Add these keys (same location as IT file):

```json
"smartWorkoutCTARestModeTitle": "💪 Enjoy your well-deserved rest",
"@smartWorkoutCTARestModeTitle": {
  "description": "Title for rest mode when user already worked out today"
},
"smartWorkoutCTARestModeSubtitle": "You crushed an amazing workout!",
"@smartWorkoutCTARestModeSubtitle": {
  "description": "Subtitle congratulating user on completed workout"
},
"smartWorkoutCTARestModeVolume": "Volume: {volume} kg",
"@smartWorkoutCTARestModeVolume": {
  "description": "Total volume lifted in workout",
  "placeholders": {
    "volume": {
      "type": "String"
    }
  }
},
"smartWorkoutCTARestModeDuration": "Duration: {duration}",
"@smartWorkoutCTARestModeDuration": {
  "description": "Total workout duration",
  "placeholders": {
    "duration": {
      "type": "String"
    }
  }
},
"smartWorkoutCTARestModeSets": "Sets: {sets}",
"@smartWorkoutCTARestModeSets": {
  "description": "Total sets completed",
  "placeholders": {
    "sets": {
      "type": "int"
    }
  }
}
```

**Step 3: Run flutter gen-l10n**

Run: `flutter gen-l10n`

Expected: Success, generates 6 new methods in app_localizations.dart

**Step 4: Verify generated methods**

Check: `lib/shared/presentation/l10n/generated/app_localizations.dart`

Should contain:
```dart
String get smartWorkoutCTARestModeTitle;
String get smartWorkoutCTARestModeSubtitle;
String smartWorkoutCTARestModeVolume(String volume);
String smartWorkoutCTARestModeDuration(String duration);
String smartWorkoutCTARestModeSets(int sets);
```

**Step 5: Commit localization**

```bash
git add assets/i18n/app_it.arb
git add assets/i18n/app_en.arb
git add lib/shared/presentation/l10n/generated/
git commit -m "feat: add rest mode localization keys (IT/EN)

Add 6 new keys for post-workout rest mode:
- Title and subtitle (congratulatory message)
- Volume, duration, sets statistics

Supports both Italian and English locales."
```

---

## Task 4: Add Statistics Calculation Helper

**Files:**
- Modify: `lib/features/home/presentation/widgets/smart_workout_cta.dart` (add helper class and method)

**Step 1: Add WorkoutStats helper class**

Location: `lib/features/home/presentation/widgets/smart_workout_cta.dart`

Add at the end of file (after all widgets, before closing):

```dart
/// Statistics calculated from completed workout
class WorkoutStats {
  final String volume;      // Formatted with thousand separator (e.g., "4.250")
  final String duration;    // Human-readable format (e.g., "45m 32s")
  final int sets;           // Total sets completed

  const WorkoutStats({
    required this.volume,
    required this.duration,
    required this.sets,
  });
}
```

**Step 2: Add imports for intl package**

Location: `lib/features/home/presentation/widgets/smart_workout_cta.dart` (top of file)

Add this import if not already present:

```dart
import 'package:intl/intl.dart';
```

**Step 3: Add _calculateWorkoutStats helper method**

Location: `lib/features/home/presentation/widgets/smart_workout_cta.dart`

Add inside the `_SmartWorkoutCTAState` class (after existing helper methods):

```dart
/// Calculate workout statistics from completed workout
WorkoutStats _calculateWorkoutStats(Workout workout) {
  // Volume: sum of all (weight × reps) across all sets
  double totalVolume = 0;
  int totalSets = 0;

  for (final exercise in workout.exercises) {
    for (final set in exercise.sets) {
      final weight = set.weight ?? 0;
      final reps = set.reps ?? 0;
      totalVolume += weight * reps;
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

**Step 4: Verify flutter analyze passes**

Run: `flutter analyze lib/features/home/presentation/widgets/smart_workout_cta.dart`

Expected: No errors (intl package should be in pubspec.yaml already)

**Step 5: Commit statistics helper**

```bash
git add lib/features/home/presentation/widgets/smart_workout_cta.dart
git commit -m "feat: add workout statistics calculation helper

Add WorkoutStats class and _calculateWorkoutStats method:
- Volume: formatted with thousand separator (IT locale)
- Duration: human-readable format (XXm YYs)
- Sets: total count with null-safety"
```

---

## Task 5: Add Rest Mode UI State

**Files:**
- Modify: `lib/features/home/presentation/widgets/smart_workout_cta.dart` (add _buildRestModeState method)

**Step 1: Add _buildRestModeState widget method**

Location: `lib/features/home/presentation/widgets/smart_workout_cta.dart`

Add inside the `_SmartWorkoutCTAState` class (after _buildActiveState method):

```dart
/// Rest mode state - Shows congratulatory message and workout statistics
Widget _buildRestModeState(BuildContext context, Workout workout) {
  final theme = Theme.of(context);
  final stats = _calculateWorkoutStats(workout);

  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.primary,
          theme.colorScheme.tertiary,
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + Title
          Row(
            children: [
              Icon(
                AppIcons.trophy,
                size: AppIconSize.large,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.smartWorkoutCTARestModeTitle,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            context.l10n.smartWorkoutCTARestModeSubtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),

          const SizedBox(height: 16),

          // Stats Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildStatRow(
                  context,
                  AppIcons.weight,
                  context.l10n.smartWorkoutCTARestModeVolume(stats.volume),
                ),
                const SizedBox(height: 8),
                _buildStatRow(
                  context,
                  AppIcons.timer,
                  context.l10n.smartWorkoutCTARestModeDuration(stats.duration),
                ),
                const SizedBox(height: 8),
                _buildStatRow(
                  context,
                  AppIcons.checkCircle,
                  context.l10n.smartWorkoutCTARestModeSets(stats.sets),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Helper to build a single stat row
Widget _buildStatRow(BuildContext context, IconData icon, String text) {
  return Row(
    children: [
      Icon(
        icon,
        size: AppIconSize.small,
        color: Colors.white.withValues(alpha: 0.9),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ),
    ],
  );
}
```

**Step 2: Add import for Workout entity**

Location: `lib/features/home/presentation/widgets/smart_workout_cta.dart` (top of file)

Add this import:

```dart
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
```

**Step 3: Verify flutter analyze passes**

Run: `flutter analyze lib/features/home/presentation/widgets/smart_workout_cta.dart`

Expected: No errors

**Step 4: Commit rest mode UI**

```bash
git add lib/features/home/presentation/widgets/smart_workout_cta.dart
git commit -m "feat: add rest mode UI state with workout statistics

Add _buildRestModeState widget method:
- Same gradient design as active state (user preference)
- Trophy icon + congratulatory message
- Stats container with volume, duration, sets
- Not tappable (no InkWell, informational only)"
```

---

## Task 6: Update Decision Flow Logic

**Files:**
- Modify: `lib/features/home/presentation/widgets/smart_workout_cta.dart` (update build method)

**Step 1: Add todayCompletedWorkoutProvider watch**

Location: `lib/features/home/presentation/widgets/smart_workout_cta.dart`

In the `build()` method, find this line:
```dart
final routineAsync = ref.watch(safeActiveRoutineProvider);
```

Add this line RIGHT AFTER it:
```dart
final todayWorkoutAsync = ref.watch(todayCompletedWorkoutProvider);
```

**Step 2: Update return statement with new priority logic**

Replace the entire `return` statement with:

```dart
// Priority 1: Check if already worked out today
return todayWorkoutAsync.when(
  loading: () => _buildLoadingState(context, theme),
  error: (_, __) => _buildLoadingState(context, theme), // Graceful fallback
  data: (todayWorkout) {
    if (todayWorkout != null) {
      // ✅ Workout done today → REST MODE
      return _buildRestModeState(context, todayWorkout);
    }

    // No workout today → check routine (existing logic)
    return routineAsync.when(
      loading: () => _buildLoadingState(context, theme),
      error: (_, __) => _buildDisabledState(
        context,
        theme,
        context.l10n.smartWorkoutCTAErrorLoading,
      ),
      data: (routine) {
        // Guard 1: Check if routine exists and has uncompleted workout
        if (routine == null || !routine.hasUncompletedWorkout()) {
          return _buildDisabledState(
            context,
            theme,
            context.l10n.smartWorkoutCTARestDay,
          );
        }

        // Guard 2: Get next uncompleted workout
        final nextWorkout = routine.getNextUncompletedWorkout();
        if (nextWorkout == null || nextWorkout.templateId == null) {
          return _buildDisabledState(
            context,
            theme,
            context.l10n.smartWorkoutCTAIncompleteRoutine,
          );
        }

        // ✅ Ready to show active CTA
        return _buildActiveState(
          context,
          ref,
          theme,
          nextWorkout.templateId!,
        );
      },
    );
  },
);
```

**Step 3: Add import for todayCompletedWorkoutProvider**

Location: `lib/features/home/presentation/widgets/smart_workout_cta.dart` (top of file)

Add this import:

```dart
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_history_provider.dart';
```

**Step 4: Verify flutter analyze passes**

Run: `flutter analyze lib/features/home/presentation/widgets/smart_workout_cta.dart`

Expected: No errors

**Step 5: Commit decision flow update**

```bash
git add lib/features/home/presentation/widgets/smart_workout_cta.dart
git commit -m "feat: update SmartWorkoutCTA decision flow with rest mode

Priority logic:
1. Check if workout done today (todayCompletedWorkoutProvider)
   → YES: Show rest mode with stats
   → NO: Continue to step 2
2. Check if routine has uncompleted workout
   → YES: Show active CTA
   → NO: Show rest day message

Rest mode takes priority over active CTA."
```

---

## Task 7: Manual Testing & Verification

**Prerequisites:**
- App running on device/simulator
- User logged in
- Workout data available

**Step 1: Test Scenario 1 - No workout today**

1. Ensure no workout completed today (after 04:00)
2. Navigate to home screen
3. Expected: SmartWorkoutCTA shows "INIZIA ALLENAMENTO" (active state)

Debug console should show:
```
🔍 [todayCompletedWorkoutProvider] START
⚠️ [todayCompletedWorkoutProvider] Last workout was before cutoff
```

**Step 2: Test Scenario 2 - Workout completed today**

1. Complete a workout (or manually set last workout to today after 04:00)
2. Navigate to home screen
3. Expected: SmartWorkoutCTA shows rest mode with:
   - Trophy icon
   - "Goditi il meritato riposo"
   - "Hai fatto un allenamento pazzesco!"
   - Volume: X.XXX kg
   - Durata: XXm XXs
   - Serie: XX

Debug console should show:
```
🔍 [todayCompletedWorkoutProvider] START
✅ [todayCompletedWorkoutProvider] Workout done today: <workout-id>
```

**Step 3: Test Scenario 3 - Workout before 04:00 cutoff**

1. Manually set last workout to today at 03:30 (before cutoff)
2. Navigate to home screen
3. Expected: SmartWorkoutCTA shows "INIZIA ALLENAMENTO" (active state)

**Step 4: Test Localization (IT/EN)**

1. Change app language to English (Settings → Language)
2. Navigate to home screen with completed workout
3. Expected: Rest mode shows:
   - "Enjoy your well-deserved rest"
   - "You crushed an amazing workout!"
   - Volume: X,XXX kg
   - Duration: XXm XXs
   - Sets: XX

**Step 5: Test Dark/Light Themes**

1. Toggle dark mode (Settings → Tema)
2. Verify rest mode card is visible in both themes
3. Gradient should adapt to theme colors

**Step 6: Test Not Tappable**

1. With rest mode showing, try tapping the card
2. Expected: No response (no navigation, no haptic feedback)

**Step 7: Test Statistics Accuracy**

1. Complete a known workout (e.g., 3 exercises, 4 sets each, known weights)
2. Calculate expected volume manually: (weight × reps) summed
3. Check displayed volume matches calculation
4. Check duration matches workout timer
5. Check sets count matches total sets

**Step 8: Verify flutter analyze passes**

Run: `flutter analyze`

Expected: No errors

**Step 9: Final commit**

```bash
git add .
git commit -m "test: verify post-workout rest mode implementation

Manual testing completed:
- ✅ No workout today → shows active CTA
- ✅ Workout today after 04:00 → shows rest mode
- ✅ Workout before 04:00 → shows active CTA
- ✅ Localization IT/EN working
- ✅ Dark/light themes working
- ✅ Card not tappable in rest mode
- ✅ Statistics accurate (volume, duration, sets)
- ✅ Flutter analyze passes"
```

---

## Verification Checklist

After completing all tasks, verify:

- [ ] `todayCompletedWorkoutProvider` returns workout when done after 04:00 today
- [ ] `todayCompletedWorkoutProvider` returns null when no workout or before cutoff
- [ ] 5-second timeout works (no hanging on network issues)
- [ ] Rest mode UI shows with gradient and statistics
- [ ] Statistics accurate: volume (thousand separator), duration (mm:ss), sets
- [ ] Localization works in both IT and EN
- [ ] Decision flow prioritizes rest mode over active CTA
- [ ] Card not tappable in rest mode (no InkWell)
- [ ] Dark/light themes both work
- [ ] Flutter analyze passes with 0 errors
- [ ] All commits made with descriptive messages

---

## Expected Commits

1. `feat: add getLastCompletedWorkout() repository method`
2. `feat: add todayCompletedWorkoutProvider with 04:00 cutoff`
3. `feat: add rest mode localization keys (IT/EN)`
4. `feat: add workout statistics calculation helper`
5. `feat: add rest mode UI state with workout statistics`
6. `feat: update SmartWorkoutCTA decision flow with rest mode`
7. `test: verify post-workout rest mode implementation`

**Total**: 7 commits

---

## Time Estimate

- Task 1: 10 minutes (repository method)
- Task 2: 15 minutes (provider with cutoff logic)
- Task 3: 15 minutes (localization IT/EN)
- Task 4: 10 minutes (statistics helper)
- Task 5: 20 minutes (rest mode UI)
- Task 6: 10 minutes (decision flow update)
- Task 7: 30 minutes (manual testing)

**Total**: ~1 hour 50 minutes

---

## Rollback Strategy

If issues occur:
1. Revert commits 5-6 (UI and decision flow)
2. Keep commits 1-4 (provider, localization, helpers - no risk)
3. Can re-enable rest mode UI after debugging

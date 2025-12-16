# Home Screen Smart CTA Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Differentiate SmartWorkoutCTA (green button) from FAB by implementing pre-loading workflow, reducing decision fatigue and improving workout completion rates by 35-50%.

**Architecture:**
- Data layer: Add `isPreloaded`, `preloadExpiry`, `exercisesModified`, `sessionId` fields to Workout entity
- Provider layer: Implement `createWorkoutFromRoutine()` with cleanup timer and pause/resume logic
- Presentation layer: Refactor SmartWorkoutCTA to show 3 states (loading/disabled/active) with defense coding, refactor WorkoutScreen to show pre-loaded view with "Cambio Programma" banner
- Analytics layer: 5-event funnel tracking with session ID correlation

**Tech Stack:** Flutter, Riverpod, Freezed, Firebase Analytics

---

## Phase 1: Data Layer Updates

### Task 1.1: Update Workout Entity with Pre-load Fields

**Files:**
- Modify: `lib/features/workout/domain/entities/workout.dart`

**Step 1: Read current Workout entity**

Run: `cat lib/features/workout/domain/entities/workout.dart | head -50`

Expected output shows current structure with `id`, `name`, `startedAt`, `exercises`, `isActive` fields.

**Step 2: Add new fields to Workout entity**

In `lib/features/workout/domain/entities/workout.dart`, find the `@freezed class Workout` and add these fields inside the factory constructor:

```dart
@freezed
class Workout with _$Workout {
  const factory Workout({
    required String id,
    required String name,
    required DateTime startedAt,
    required List<Exercise> exercises,
    required bool isActive,

    // 🆕 Pre-load management
    @Default(false) bool isPreloaded,
    DateTime? preloadExpiry,
    bool? exercisesModified,

    // 🆕 Analytics tracking
    String? sessionId,
  }) = _Workout;

  factory Workout.fromJson(Map<String, dynamic> json) => _$WorkoutFromJson(json);
}
```

**Step 3: Add isExpired extension**

Add this extension at the end of the same file, after the factory constructor:

```dart
extension WorkoutExtensions on Workout {
  /// Check if pre-loaded workout has expired
  bool get isExpired {
    if (!isPreloaded || preloadExpiry == null) return false;
    return DateTime.now().isAfter(preloadExpiry!);
  }
}
```

**Step 4: Regenerate Freezed code**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

Expected: Build completes successfully with message "Building with 3 dart:async imports" or similar.

**Step 5: Verify compilation**

Run: `flutter analyze lib/features/workout/domain/entities/workout.dart`

Expected: No errors.

**Step 6: Commit**

```bash
git add lib/features/workout/domain/entities/workout.dart
git commit -m "feat(workout): add pre-load management fields to Workout entity

- Add isPreloaded flag to identify pre-loaded workouts
- Add preloadExpiry for 15-minute timeout management
- Add exercisesModified to track template changes
- Add sessionId for analytics funnel correlation
- Add isExpired extension getter for expiry checks
"
```

---

### Task 1.2: Update Routine Entity with Helper Methods

**Files:**
- Modify: `lib/features/routine/domain/entities/routine.dart`

**Step 1: Find current Routine entity**

Run: `grep -n "hasProgrammedWorkoutToday\|isActiveToday" lib/features/routine/domain/entities/routine.dart`

Expected: Shows current method name (likely `isActiveToday` or similar).

**Step 2: Rename method and add new helper**

Find the existing method in Routine and replace with:

```dart
/// Check if today is a programmed workout day (more semantic than "isActiveToday")
bool hasProgrammedWorkoutToday() {
  if (!isActive) return false;

  final today = DateTime.now().weekday;
  return workouts.any((w) => w.dayIndex == today);
}

/// Get today's workout if scheduled, null otherwise
Workout? getTodayWorkout() {
  final today = DateTime.now().weekday;
  try {
    return workouts.firstWhere((w) => w.dayIndex == today);
  } catch (e) {
    return null;
  }
}
```

**Step 3: Update all usages of old method name**

Run: `grep -r "isActiveToday" lib/features/ --include="*.dart"`

Replace all occurrences with `hasProgrammedWorkoutToday()`.

**Step 4: Regenerate Freezed code**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

**Step 5: Verify compilation**

Run: `flutter analyze lib/features/routine/domain/entities/routine.dart`

Expected: No errors.

**Step 6: Commit**

```bash
git add lib/features/routine/domain/entities/routine.dart
git commit -m "refactor(routine): rename isActiveToday to hasProgrammedWorkoutToday

- More semantic method name: 'hasProgrammedWorkoutToday' clearly indicates
  'today is a scheduled workout day' vs 'routine is currently active'
- Add getTodayWorkout() helper to get today's workout safely
- Update all usages throughout codebase
"
```

---

### Task 1.3: Add createWorkoutFromRoutine() to WorkoutProvider

**Files:**
- Modify: `lib/features/workout/presentation/providers/workout_provider.dart`

**Step 1: Find WorkoutNotifier class**

Run: `grep -n "class WorkoutNotifier" lib/features/workout/presentation/providers/workout_provider.dart`

Expected: Shows line number of class definition.

**Step 2: Add new method inside WorkoutNotifier**

Add this method after the constructor and before any existing methods:

```dart
/// Creates workout from routine with pre-loaded exercises
Future<void> createWorkoutFromRoutine({
  required String routineName,
  required List<Exercise> exercises,
  required String sessionId,
}) async {
  final workout = Workout(
    id: const Uuid().v4(),
    name: routineName,
    startedAt: DateTime.now(),
    exercises: exercises,
    isActive: false, // User must tap "Avvia"
    isPreloaded: true, // Flag to identify pre-loaded state
    preloadExpiry: DateTime.now().add(const Duration(minutes: 15)), // 15-min timeout
    sessionId: sessionId, // Analytics tracking
  );

  state = workout;
  await _autoSave();
}
```

**Step 3: Add cleanup timer initialization**

Find the provider definition (bottom of file) that creates `WorkoutNotifier()`. It should look like:

```dart
final currentWorkoutProvider = StateNotifierProvider<WorkoutNotifier, Workout?>(
  (ref) {
    final notifier = WorkoutNotifier();
    // 🆕 ADD THIS:
    notifier._startCleanupTimer();

    ref.onDispose(() {
      notifier._cleanupTimer?.cancel();
    });

    return notifier;
  },
);
```

**Step 4: Add cleanup timer private method to WorkoutNotifier**

Add this method inside the class:

```dart
  Timer? _cleanupTimer;
  bool _timerPaused = false;

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_timerPaused) return; // Skip if paused

      final workout = state;
      if (workout?.isPreloaded == true && workout!.isExpired) {
        state = null; // Cleanup expired workout
        if (kDebugMode) debugPrint('🧹 Preloaded workout expired and removed');
      }
    });
  }

  void pauseCleanupTimer() {
    _timerPaused = true;
    if (kDebugMode) debugPrint('⏸️ Cleanup timer paused');
  }

  void resumeCleanupTimer() {
    _timerPaused = false;
    if (kDebugMode) debugPrint('▶️ Cleanup timer resumed');
  }

  Future<void> replaceExercisesFromTemplate(WorkoutTemplate template) async {
    final workout = state;
    if (workout == null) return;

    state = workout.copyWith(
      name: template.name,
      exercises: template.exercises,
      isPreloaded: false, // No longer pre-loaded
      exercisesModified: true, // Track modification
    );

    await _autoSave();
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    super.dispose();
  }
```

**Step 5: Verify imports**

Ensure these imports exist at top of file:

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
```

**Step 6: Run analyze**

Run: `flutter analyze lib/features/workout/presentation/providers/workout_provider.dart`

Expected: No errors.

**Step 7: Commit**

```bash
git add lib/features/workout/presentation/providers/workout_provider.dart
git commit -m "feat(workout): implement pre-load workflow with cleanup timer

- Add createWorkoutFromRoutine() method for routine-based pre-loading
- Implement 15-minute cleanup timer with pause/resume logic
- Add replaceExercisesFromTemplate() for flexible template switching
- Use ref.onDispose() to guarantee timer cleanup
- Add isPreloaded flag and sessionId for analytics correlation
"
```

---

## Phase 2: Analytics Setup

### Task 2.1: Create WorkoutAnalytics Service

**Files:**
- Create: `lib/features/workout/domain/services/workout_analytics.dart`

**Step 1: Create new service file**

Create the file with this content:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class WorkoutAnalytics {
  /// Track workout-related analytics events
  static Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    try {
      // Send to Firebase Analytics
      await FirebaseAnalytics.instance.logEvent(
        name: eventName,
        parameters: properties ?? {},
      );

      // Log in debug mode
      if (kDebugMode) {
        debugPrint('📊 Analytics: $eventName');
        if (properties != null) {
          debugPrint('   Properties: $properties');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics error: $e');
      }
    }
  }

  /// Calculate funnel drop-off rates for a session
  static Future<Map<String, bool>> getFunnelEvents(String sessionId) async {
    // TODO: Implement when Firebase Firestore queries are available
    // For now, return empty map
    return {};
  }
}
```

**Step 2: Test imports**

Run: `flutter analyze lib/features/workout/domain/services/workout_analytics.dart`

Expected: No errors.

**Step 3: Verify it can be imported**

Run: `grep -l "workout_analytics" lib/features/workout/domain/services/`

Expected: Shows `workout_analytics.dart` exists.

**Step 4: Commit**

```bash
git add lib/features/workout/domain/services/workout_analytics.dart
git commit -m "feat(analytics): create WorkoutAnalytics service

- Create centralized event tracking with Firebase Analytics integration
- Add debug logging for development visibility
- Prepare structure for future funnel analysis queries
"
```

---

### Task 2.2: Create WorkoutSessionProvider

**Files:**
- Create: `lib/features/home/presentation/providers/workout_session_provider.dart`

**Step 1: Create provider file**

Create the file with this content:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Manages the current workout session ID for analytics correlation
/// Each home screen view starts a new session ID for funnel tracking
final workoutSessionProvider = StateProvider<String?>((_) => null);

/// Generate a new session ID
String generateSessionId() => const Uuid().v4();
```

**Step 2: Test syntax**

Run: `dart analyze lib/features/home/presentation/providers/workout_session_provider.dart`

Expected: No errors.

**Step 3: Commit**

```bash
git add lib/features/home/presentation/providers/workout_session_provider.dart
git commit -m "feat(analytics): create WorkoutSessionProvider for session tracking

- Create StateProvider for session ID management
- Use UUID for unique session identification
- Enable funnel correlation across multiple analytics events
"
```

---

## Phase 3: SmartWorkoutCTA Refactor

### Task 3.1: Refactor SmartWorkoutCTA to Handle 3 States

**Files:**
- Modify: `lib/features/home/presentation/widgets/smart_workout_cta.dart`

**Step 1: Read current implementation**

Run: `wc -l lib/features/home/presentation/widgets/smart_workout_cta.dart`

Expected: Shows current line count.

**Step 2: Add required imports**

Add these imports at the top:

```dart
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/routine/domain/providers/routine_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_analytics.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/workout_session_provider.dart';
```

**Step 3: Replace build method**

Replace the entire `build` method with this new implementation:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final routineAsync = ref.watch(routineProvider);

  return routineAsync.when(
    loading: () => _buildLoadingState(context, theme),
    error: (_, __) => _buildDisabledState(
      context,
      theme,
      'Errore caricamento',
    ),
    data: (routine) {
      // Guard 1: Check if routine exists and has today scheduled
      if (routine == null || !routine.hasProgrammedWorkoutToday()) {
        return _buildDisabledState(
          context,
          theme,
          'Giorno di Riposo 🌟',
        );
      }

      // Guard 2: Get today's workout
      final todayWorkout = routine.getTodayWorkout();
      if (todayWorkout == null || todayWorkout.exercises.isEmpty) {
        return _buildDisabledState(
          context,
          theme,
          'Routine incompleta',
        );
      }

      // ✅ Ready to show active CTA
      return _buildActiveState(
        context,
        ref,
        theme,
        l10n,
        todayWorkout,
      );
    },
  );
}

// Loading state - skeleton
Widget _buildLoadingState(BuildContext context, ThemeData theme) {
  return Container(
    height: 100,
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(24),
    ),
    child: const Center(
      child: SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    ),
  );
}

// Disabled state - rest day or no routine
Widget _buildDisabledState(
  BuildContext context,
  ThemeData theme,
  String label,
) {
  return Container(
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Usa il pulsante "Sessione Libera" per un allenamento libero',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    ),
  );
}

// Active state - ready to pre-load
Widget _buildActiveState(
  BuildContext context,
  WidgetRef ref,
  ThemeData theme,
  AppLocalizations l10n,
  RoutineWorkout todayWorkout,
) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.primary,
          theme.colorScheme.tertiary,
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onSmartCTATap(context, ref, todayWorkout),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.rocket_launch,
                    color: theme.colorScheme.onPrimary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'INIZIA ALLENAMENTO',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                todayWorkout.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Suggerito per oggi • ~60 min',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> _onSmartCTATap(
  BuildContext context,
  WidgetRef ref,
  RoutineWorkout todayWorkout,
) async {
  // Generate session ID for analytics correlation
  final sessionId = generateSessionId();

  // Guard 1: Check AsyncValue state
  final routineAsync = ref.read(routineProvider);
  if (routineAsync is! AsyncData) {
    if (context.mounted) {
      context.goNamed('workout');
    }
    return;
  }

  final routine = routineAsync.value;

  // Guard 2: Routine null check
  if (routine == null || !routine.hasProgrammedWorkoutToday()) {
    if (context.mounted) {
      context.goNamed('workout');
    }
    return;
  }

  // Guard 3: getTodayWorkout() null check
  final todayWorkoutFresh = routine.getTodayWorkout();
  if (todayWorkoutFresh == null || todayWorkoutFresh.exercises.isEmpty) {
    if (context.mounted) {
      context.goNamed('workout');
    }
    return;
  }

  // Analytics: CTA tapped
  await WorkoutAnalytics.trackEvent(
    'smart_cta_tapped',
    properties: {
      'sessionId': sessionId,
      'templateName': todayWorkoutFresh.name,
      'exerciseCount': todayWorkoutFresh.exercises.length,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );

  // 🔥 Pre-load workout with exercises
  await ref.read(currentWorkoutProvider.notifier).createWorkoutFromRoutine(
    routineName: todayWorkoutFresh.name,
    exercises: todayWorkoutFresh.exercises,
    sessionId: sessionId,
  );

  if (context.mounted) {
    context.goNamed('workout', extra: {'sessionId': sessionId});
  }
}

String generateSessionId() => const Uuid().v4();
```

**Step 4: Add required imports for new state**

Ensure these imports exist:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/routine/domain/providers/routine_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_analytics.dart';
import 'package:uuid/uuid.dart';
```

**Step 5: Delete old code if present**

Remove the old `_getSuggestedWorkout()` and `_getEstimatedDuration()` methods that were in the original file.

**Step 6: Run analyze**

Run: `flutter analyze lib/features/home/presentation/widgets/smart_workout_cta.dart`

Expected: No errors.

**Step 7: Commit**

```bash
git add lib/features/home/presentation/widgets/smart_workout_cta.dart
git commit -m "feat(home): refactor SmartWorkoutCTA with 3-state system

- Loading state: Show skeleton while routine loads
- Disabled state: Rest day or no routine available
- Active state: Ready to pre-load today's workout
- Implement defense coding with 3 guard clauses
- Add analytics tracking with session ID correlation
- Pre-load workout directly without intermediate screen
"
```

---

## Phase 4: WorkoutScreen Refactor

### Task 4.1: Add Pre-loaded View to WorkoutScreen

**Files:**
- Modify: `lib/features/workout/presentation/workout_screen.dart`

**Step 1: Find the build method**

Run: `grep -n "Widget build" lib/features/workout/presentation/workout_screen.dart | head -1`

Expected: Shows line number of main build method.

**Step 2: Update build method to handle pre-loaded state**

Find the conditional that shows welcome view vs workout view. Replace with:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final currentWorkout = ref.watch(currentWorkoutProvider);
  final sessionId = (GoRouterState.of(context).extra as Map?)?['sessionId'] as String?;

  // Analytics: Track screen view
  ref.listen(currentWorkoutProvider, (prev, next) {
    if (next != null && prev == null) {
      WorkoutAnalytics.trackEvent(
        'workout_screen_viewed',
        properties: {
          'sessionId': sessionId ?? generateSessionId(),
          'sourceFlow': next.isPreloaded ? 'smart_cta' : 'fab',
          'exerciseCount': next.exercises.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  });

  // Conditional rendering
  if (currentWorkout == null) {
    return _buildWelcomeView(context, ref);
  }

  if (currentWorkout.exercises.isNotEmpty && currentWorkout.isPreloaded) {
    return _buildPreloadedView(context, ref, currentWorkout, sessionId!);
  }

  return _buildWelcomeView(context, ref);
}
```

**Step 3: Add pre-loaded view method**

Add this new method to the WorkoutScreen state class:

```dart
Widget _buildPreloadedView(
  BuildContext context,
  WidgetRef ref,
  Workout workout,
  String sessionId,
) {
  return Scaffold(
    appBar: AppBar(
      title: Row(
        children: [
          Expanded(
            child: Text(workout.name),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.autoAwesome,
                  size: AppIconSize.tiny,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Suggerito',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    body: Column(
      children: [
        // "Cambio Programma" banner
        _buildChangeWorkoutBanner(context, ref, sessionId),

        // Exercise list
        Expanded(
          child: ListView.builder(
            itemCount: workout.exercises.length,
            itemBuilder: (_, i) => ExerciseListTile(
              exercise: workout.exercises[i],
              index: i + 1,
            ),
          ),
        ),

        // Start button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _onStartWorkout(context, ref, workout, sessionId),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Avvia Workout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.success,
              foregroundColor: context.colors.onSuccess,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildChangeWorkoutBanner(
  BuildContext context,
  WidgetRef ref,
  String sessionId,
) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: context.colors.primary.withValues(alpha: 0.1),
      border: Border.all(
        color: context.colors.primary.withValues(alpha: 0.3),
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            context.l10n.notWhatYouWanted,
            style: context.textTheme.bodySmall,
          ),
        ),
        TextButton(
          onPressed: () => _showTemplateSelection(context, ref, sessionId),
          child: Text(context.l10n.browseTemplates),
        ),
      ],
    ),
  );
}

void _showTemplateSelection(
  BuildContext context,
  WidgetRef ref,
  String sessionId,
) {
  // Pause cleanup timer while selecting template
  ref.read(currentWorkoutProvider.notifier).pauseCleanupTimer();

  showModalBottomSheet(
    context: context,
    isDismissible: true,
    builder: (_) => WorkoutTemplateSelectionSheet(
      onTemplateSelected: (template) async {
        // Replace exercises
        await ref.read(currentWorkoutProvider.notifier).replaceExercisesFromTemplate(template);

        // Track modification
        await WorkoutAnalytics.trackEvent(
          'workout_template_changed',
          properties: {
            'sessionId': sessionId,
            'newTemplateName': template.name,
            'exerciseCount': template.exercises.length,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        if (context.mounted) {
          Navigator.pop(context);
          // Resume cleanup after modal closes
          ref.read(currentWorkoutProvider.notifier).resumeCleanupTimer();
        }
      },
      onCancelled: () {
        // Resume cleanup on dismiss
        ref.read(currentWorkoutProvider.notifier).resumeCleanupTimer();
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
    ),
  );
}

Future<void> _onStartWorkout(
  BuildContext context,
  WidgetRef ref,
  Workout workout,
  String sessionId,
) async {
  // Analytics: Workout started
  await WorkoutAnalytics.trackEvent(
    'workout_started',
    properties: {
      'sessionId': sessionId,
      'sourceFlow': workout.isPreloaded ? 'smart_cta' : 'fab',
      'exercisesModified': workout.exercisesModified ?? false,
      'exerciseCount': workout.exercises.length,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );

  // Activate workout and start timer
  await ref.read(currentWorkoutProvider.notifier).startWorkout();

  if (context.mounted) {
    // Navigate to active workout view
    // Implementation depends on your existing workout flow
  }
}
```

**Step 4: Add imports**

Ensure these imports exist:

```dart
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_analytics.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
```

**Step 5: Run analyze**

Run: `flutter analyze lib/features/workout/presentation/workout_screen.dart`

Expected: No errors (except potentially for missing `WorkoutTemplateSelectionSheet` widget which should exist).

**Step 6: Commit**

```bash
git add lib/features/workout/presentation/workout_screen.dart
git commit -m "feat(workout): add pre-loaded view with template change support

- Add _buildPreloadedView() for pre-loaded workouts from routine
- Show 'Suggerito' badge to identify pre-loaded state
- Add 'Cambio Programma' banner for flexible template switching
- Pause/resume cleanup timer during template selection
- Track analytics events for start and template modifications
- Support complete funnel correlation with sessionId
"
```

---

## Phase 5: FAB Rename & Localizations

### Task 5.1: Rename FAB and Add Localizations

**Files:**
- Modify: `lib/features/home/presentation/home_screen_optimized.dart`
- Modify: `assets/i18n/app_en.arb`
- Modify: `assets/i18n/app_it.arb`

**Step 1: Update FAB label in home screen**

Find the FAB definition (around line 460) and change:

```dart
// OLD:
label: l10n.quickStart,

// NEW:
label: l10n.freeSession,
```

Also add analytics tracking:

```dart
onPressed: () {
  // Analytics: FAB tapped
  WorkoutAnalytics.trackEvent(
    'fab_tapped',
    properties: {
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
  context.goNamed('workout');
},
```

**Step 2: Add missing localization keys to English**

Edit `assets/i18n/app_en.arb` and add these keys (find a good location in the file):

```json
  "freeSession": "Free Session",
  "suggested": "Suggested",
  "notWhatYouWanted": "💡 Not what you wanted?",
  "browseTemplates": "Browse Templates",
  "sessioneLibera": "Free Session"
```

**Step 3: Add missing localization keys to Italian**

Edit `assets/i18n/app_it.arb` and add:

```json
  "freeSession": "Sessione Libera",
  "suggested": "Suggerito",
  "notWhatYouWanted": "💡 Non è quello che volevi?",
  "browseTemplates": "Sfoglia Template",
  "sessioneLibera": "Sessione Libera"
```

**Step 4: Regenerate localizations**

Run: `flutter gen-l10n`

Expected: No errors, shows "Generating localizations for 16 untranslated messages."

**Step 5: Verify generated files**

Run: `grep -c "freeSession" lib/shared/presentation/l10n/generated/app_localizations_*.dart`

Expected: Shows count > 0 for both en and it variants.

**Step 6: Run analyze**

Run: `flutter analyze lib/features/home/presentation/home_screen_optimized.dart`

Expected: No errors.

**Step 7: Commit**

```bash
git add lib/features/home/presentation/home_screen_optimized.dart assets/i18n/app_*.arb lib/shared/presentation/l10n/generated/
git commit -m "feat(home): rename FAB to 'Sessione Libera' with analytics

- Rename FAB from 'Avvio Rapido' to 'Sessione Libera' (Free Session)
- Add analytics tracking for FAB taps
- Add missing localization keys for pre-load flow
- Regenerate localizations with full coverage
"
```

---

## Phase 6: Integration Tests

### Task 6.1: Write Integration Test for Complete Flow

**Files:**
- Create: `integration_test/smart_cta_preload_test.dart`

**Step 1: Create test file**

Create `integration_test/smart_cta_preload_test.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/app/app.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/providers/routine_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/workout_screen.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';

void main() {
  group('SmartCTA Pre-load Flow Integration Tests', () {
    testWidgets(
      'SmartCTA shows active state when routine has today scheduled',
      (WidgetTester tester) async {
        // Setup: Mock routine with Pull Day on Monday
        final mockRoutine = Routine(
          id: 'test-routine',
          name: 'PPL Split',
          isActive: true,
          workouts: [
            RoutineWorkout(
              name: 'Pull Day',
              dayIndex: 1, // Monday
              exercises: [
                mockExercise1,
                mockExercise2,
              ],
            ),
          ],
        );

        // Build app with mock routine
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              routineProvider.overrideWithValue(
                AsyncData(mockRoutine),
              ),
            ],
            child: const MyApp(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify SmartCTA shows active state
        expect(find.text('INIZIA ALLENAMENTO'), findsOneWidget);
        expect(find.text('Pull Day'), findsOneWidget);
      },
    );

    testWidgets(
      'SmartCTA shows disabled state on rest day',
      (WidgetTester tester) async {
        // Setup: Mock routine but today is rest day
        final mockRoutine = Routine(
          id: 'test-routine',
          name: 'PPL Split',
          isActive: true,
          workouts: [
            RoutineWorkout(
              name: 'Pull Day',
              dayIndex: 1, // Monday
              exercises: [mockExercise1],
            ),
            // Today (Wednesday) not in list = rest day
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              routineProvider.overrideWithValue(
                AsyncData(mockRoutine),
              ),
            ],
            child: const MyApp(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify SmartCTA shows disabled state
        expect(find.text('Giorno di Riposo 🌟'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping SmartCTA pre-loads workout and navigates to WorkoutScreen',
      (WidgetTester tester) async {
        final mockRoutine = Routine(
          id: 'test-routine',
          name: 'PPL Split',
          isActive: true,
          workouts: [
            RoutineWorkout(
              name: 'Pull Day',
              dayIndex: DateTime.monday,
              exercises: [mockExercise1, mockExercise2],
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              routineProvider.overrideWithValue(
                AsyncData(mockRoutine),
              ),
            ],
            child: const MyApp(),
          ),
        );

        await tester.pumpAndSettle();

        // Tap SmartCTA
        await tester.tap(find.text('INIZIA ALLENAMENTO'));
        await tester.pumpAndSettle();

        // Verify navigated to WorkoutScreen
        expect(find.byType(WorkoutScreen), findsOneWidget);

        // Verify pre-loaded workout shows
        expect(find.text('Pull Day'), findsOneWidget);
        expect(find.text('Suggerito'), findsOneWidget);

        // Verify "Cambio Programma" banner visible
        expect(find.text('💡 Non è quello che volevi?'), findsOneWidget);
      },
    );
  });
}

// Mock exercises
final mockExercise1 = Exercise(
  id: '1',
  name: 'Pull-ups',
  category: 'Back',
  mainMuscle: 'Back',
);

final mockExercise2 = Exercise(
  id: '2',
  name: 'Barbell Rows',
  category: 'Back',
  mainMuscle: 'Back',
);
```

**Step 2: Run test**

Run: `flutter test integration_test/smart_cta_preload_test.dart`

Expected: Tests pass (may need adjustments based on actual entity structure).

**Step 3: Commit**

```bash
git add integration_test/smart_cta_preload_test.dart
git commit -m "test: add integration tests for SmartCTA pre-load flow

- Test SmartCTA shows active state with scheduled workout
- Test SmartCTA shows disabled state on rest day
- Test tapping SmartCTA pre-loads and navigates correctly
- Verify 'Suggerito' badge and 'Cambio Programma' banner visible
"
```

---

## Summary of Implementation

**Total Tasks:** 11
**Estimated Time:** 5-7 days
**Commits:** 11 atomic, reviewable commits

**Phase Breakdown:**
- **Phase 1 (Data Layer):** Tasks 1.1-1.3 (1-2 days)
- **Phase 2 (Analytics):** Tasks 2.1-2.2 (0.5 day)
- **Phase 3 (SmartCTA):** Task 3.1 (1 day)
- **Phase 4 (WorkoutScreen):** Task 4.1 (1.5 days)
- **Phase 5 (Polish):** Task 5.1 (0.5 day)
- **Phase 6 (Testing):** Task 6.1 (1 day)

**Next Steps:**
1. Review this plan
2. Choose execution approach:
   - **Subagent-driven** (faster, fresh agent per task)
   - **Executing-plans** (focused session, batch execution)

**Success Criteria (After Implementation):**
- ✅ Time to start < 30 seconds
- ✅ SmartCTA pre-loads with defense coding
- ✅ WorkoutScreen shows pre-loaded view with change option
- ✅ 5-event analytics funnel working
- ✅ All tests passing
- ✅ Zero `flutter analyze` errors

# Workout Mini-Bar Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement a floating mini-bar that shows workout status when user navigates away from workout screen, with proper pause/resume timer tracking.

**Architecture:**
- Add pause duration tracking to Workout entity (freezed)
- Create WorkoutMiniBar widget with Spotify-style floating design
- Integrate mini-bar into MainShell above bottom navigation
- Add auto-pause setting to AppConfig

**Tech Stack:** Flutter, Riverpod, Freezed, Hive, Go Router

---

## Task 1: Add Pause Duration Tracking to Workout Entity

**Files:**
- Modify: `lib/features/workout/domain/entities/workout.dart`

**Step 1: Add new fields to Workout factory**

In `lib/features/workout/domain/entities/workout.dart`, add these fields after `sessionId`:

```dart
    // 🆕 Pause tracking for accurate duration
    @Default(Duration.zero) Duration pausedDuration,
    DateTime? lastPausedAt,
```

**Step 2: Update the `duration` getter to `activeDuration`**

Replace the existing `duration` getter (lines 42-46) with:

```dart
  // Computed properties
  /// Returns the active workout duration excluding paused time
  Duration? get activeDuration {
    if (startTime == null) return null;
    final end = endTime ?? DateTime.now();
    final total = end.difference(startTime!);

    // Calculate total paused time
    var totalPaused = pausedDuration;
    if (status == WorkoutStatus.paused && lastPausedAt != null) {
      totalPaused += DateTime.now().difference(lastPausedAt!);
    }

    final active = total - totalPaused;
    return active.isNegative ? Duration.zero : active;
  }

  /// Legacy getter for backward compatibility
  Duration? get duration => activeDuration;
```

**Step 3: Update pauseWorkout() method**

Replace the existing `pauseWorkout()` method (lines 113-118) with:

```dart
  Workout pauseWorkout() {
    return copyWith(
      status: WorkoutStatus.paused,
      lastPausedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
```

**Step 4: Update resumeWorkout() method**

Replace the existing `resumeWorkout()` method (lines 120-125) with:

```dart
  Workout resumeWorkout() {
    // Calculate paused duration and add to total
    final additionalPausedTime = lastPausedAt != null
        ? DateTime.now().difference(lastPausedAt!)
        : Duration.zero;

    return copyWith(
      status: WorkoutStatus.inProgress,
      pausedDuration: pausedDuration + additionalPausedTime,
      lastPausedAt: null,
      updatedAt: DateTime.now(),
    );
  }
```

**Step 5: Run freezed code generation**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: SUCCESS - Generated workout.freezed.dart and workout.g.dart

**Step 6: Run tests to verify**

Run: `flutter test test/features/workout/`
Expected: PASS (existing tests should still pass)

**Step 7: Commit**

```bash
git add lib/features/workout/domain/entities/workout.dart lib/features/workout/domain/entities/workout.freezed.dart lib/features/workout/domain/entities/workout.g.dart
git commit -m "feat(workout): add pause duration tracking to Workout entity

- Add pausedDuration and lastPausedAt fields
- Update activeDuration getter to exclude paused time
- Update pauseWorkout/resumeWorkout to track pause periods"
```

---

## Task 2: Add Auto-Pause Setting to AppConfig

**Files:**
- Modify: `lib/shared/domain/entities/app_config.dart`

**Step 1: Add new field to AppConfig constructor**

After line 54 (`autoAdjustRestFromRpe,`), add:

```dart
    this.autoPauseOnNavigateAway = true, // Auto-pause workout when leaving screen
```

**Step 2: Add HiveField annotation**

After line 224 (`final bool? autoAdjustRestFromRpe;`), add:

```dart

  @HiveField(45)
  final bool autoPauseOnNavigateAway;
```

**Step 3: Add to copyWith method**

In the copyWith parameters (around line 273), add after `autoAdjustRestFromRpe`:

```dart
    bool? autoPauseOnNavigateAway,
```

In the return statement, add after `autoAdjustRestFromRpe: autoAdjustRestFromRpe ?? this.autoAdjustRestFromRpe,`:

```dart
      autoPauseOnNavigateAway: autoPauseOnNavigateAway ?? this.autoPauseOnNavigateAway,
```

**Step 4: Run Hive type adapter generation**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: SUCCESS - Generated app_config.g.dart

**Step 5: Commit**

```bash
git add lib/shared/domain/entities/app_config.dart lib/shared/domain/entities/app_config.g.dart
git commit -m "feat(config): add autoPauseOnNavigateAway setting

Default: true - workout timer pauses when navigating away from workout screen"
```

---

## Task 3: Create WorkoutMiniBar Widget

**Files:**
- Create: `lib/features/workout/presentation/widgets/workout_mini_bar.dart`

**Step 1: Create the widget file**

Create `lib/features/workout/presentation/widgets/workout_mini_bar.dart`:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';

/// Floating mini-bar showing active workout status
/// Appears above bottom navigation when workout is active and user is not on workout screen
class WorkoutMiniBar extends ConsumerStatefulWidget {
  const WorkoutMiniBar({
    required this.workout,
    super.key,
  });

  final Workout workout;

  @override
  ConsumerState<WorkoutMiniBar> createState() => _WorkoutMiniBarState();
}

class _WorkoutMiniBarState extends ConsumerState<WorkoutMiniBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  Timer? _timerUpdateTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start entrance animation
    _animationController.forward();

    // Update timer display every second
    _timerUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timerUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;
    final isPaused = workout.status == WorkoutStatus.paused;
    final duration = workout.activeDuration ?? Duration.zero;
    final progress = workout.progressPercentage;

    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        onTap: () => _navigateToWorkout(context),
        child: Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Workout icon
                      Icon(
                        AppIcons.workout,
                        size: AppIconSize.medium,
                        color: isPaused
                            ? context.colors.onSurfaceVariant
                            : context.colors.primary,
                      ),
                      const SizedBox(width: 12),

                      // Workout name
                      Expanded(
                        child: Text(
                          workout.name,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Status icon
                      Icon(
                        isPaused ? AppIcons.pause : AppIcons.playArrow,
                        size: AppIconSize.small,
                        color: isPaused
                            ? context.colors.warning
                            : context.colors.primary,
                      ),
                      const SizedBox(width: 8),

                      // Timer
                      Text(
                        _formatDuration(duration),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: isPaused
                              ? context.colors.warning
                              : context.colors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Play/Pause button
                      _buildPlayPauseButton(context, isPaused),
                    ],
                  ),
                ),
              ),

              // Progress bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  color: context.colors.surfaceContainerLow,
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                      color: isPaused
                          ? context.colors.warning
                          : context.colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton(BuildContext context, bool isPaused) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _togglePause(isPaused),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.primary.withValues(alpha: 0.1),
          ),
          child: Icon(
            isPaused ? AppIcons.playArrow : AppIcons.pause,
            size: AppIconSize.medium,
            color: context.colors.primary,
          ),
        ),
      ),
    );
  }

  void _navigateToWorkout(BuildContext context) {
    HapticFeedback.lightImpact();
    context.go('/workout');
  }

  void _togglePause(bool isPaused) {
    HapticFeedback.selectionClick();
    final notifier = ref.read(currentWorkoutProvider.notifier);
    if (isPaused) {
      notifier.resumeWorkout();
    } else {
      notifier.pauseWorkout();
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
```

**Step 2: Verify the file compiles**

Run: `flutter analyze lib/features/workout/presentation/widgets/workout_mini_bar.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/workout/presentation/widgets/workout_mini_bar.dart
git commit -m "feat(ui): create WorkoutMiniBar widget

Spotify-style floating mini-bar with:
- Workout name and timer display
- Play/pause toggle button
- Progress bar showing completed sets
- Slide-up animation on appear"
```

---

## Task 4: Add Pause/Resume Methods to WorkoutProvider

**Files:**
- Modify: `lib/features/workout/presentation/providers/workout_provider.dart`

**Step 1: Find the CurrentWorkoutNotifier class and add pause/resume methods**

Add these methods after the existing `restoreWorkout` method (around line 243):

```dart
  /// Pause the current workout
  void pauseWorkout() {
    final workout = state;
    if (workout == null || workout.status != WorkoutStatus.inProgress) return;

    state = workout.pauseWorkout();
    _autoSaveIfNeeded();

    if (kDebugMode) {
      debugPrint('⏸️ [WorkoutProvider] Workout paused: ${workout.name}');
    }
  }

  /// Resume the paused workout
  void resumeWorkout() {
    final workout = state;
    if (workout == null || workout.status != WorkoutStatus.paused) return;

    state = workout.resumeWorkout();
    _autoSaveIfNeeded();

    if (kDebugMode) {
      debugPrint('▶️ [WorkoutProvider] Workout resumed: ${workout.name}');
    }
  }
```

**Step 2: Verify compilation**

Run: `flutter analyze lib/features/workout/presentation/providers/workout_provider.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/features/workout/presentation/providers/workout_provider.dart
git commit -m "feat(workout): add pauseWorkout/resumeWorkout methods to provider"
```

---

## Task 5: Integrate Mini-Bar into MainShell

**Files:**
- Modify: `lib/core/navigation/main_shell.dart`

**Step 1: Convert MainShell to ConsumerWidget and add imports**

Replace the imports (lines 24-29) with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/workout_mini_bar.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
```

**Step 2: Convert MainShell class**

Replace the entire MainShell class (lines 35-68) with:

```dart
/// Main shell widget containing bottom navigation and branch content
///
/// Uses [StatefulNavigationShell] to preserve branch state when switching tabs.
/// Implements Material 3 NavigationBar with animated transitions.
class MainShell extends ConsumerStatefulWidget {
  /// Creates the main shell with navigation
  const MainShell({
    required this.navigationShell,
    super.key,
  });

  /// The navigation shell containing branch content
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int? _previousIndex;

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(currentWorkoutProvider);
    final currentIndex = widget.navigationShell.currentIndex;

    // Check if we should show mini-bar:
    // - Workout exists
    // - Workout is in progress or paused
    // - User is NOT on workout tab (index 1)
    final showMiniBar = workout != null &&
        (workout.status == WorkoutStatus.inProgress ||
            workout.status == WorkoutStatus.paused) &&
        currentIndex != 1;

    // Handle auto-pause when navigating away from workout screen
    _handleAutoPause(currentIndex, workout);

    return Scaffold(
      body: Stack(
        children: [
          widget.navigationShell,
          // Mini-bar positioned above bottom nav
          if (showMiniBar)
            Positioned(
              left: 0,
              right: 0,
              bottom: 72, // 64pt nav + 8pt margin
              child: WorkoutMiniBar(workout: workout),
            ),
        ],
      ),
      bottomNavigationBar: _BottomNavigationBar(
        currentIndex: currentIndex,
        onDestinationSelected: (index) => _onDestinationSelected(context, index),
      ),
    );
  }

  void _handleAutoPause(int currentIndex, Workout? workout) {
    if (_previousIndex == null) {
      _previousIndex = currentIndex;
      return;
    }

    final config = ref.read(appConfigProvider);

    // If leaving workout tab (1) and auto-pause is enabled
    if (_previousIndex == 1 &&
        currentIndex != 1 &&
        config.autoPauseOnNavigateAway &&
        workout != null &&
        workout.status == WorkoutStatus.inProgress) {
      // Auto-pause the workout
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentWorkoutProvider.notifier).pauseWorkout();
      });
    }

    // If returning to workout tab and workout was paused by auto-pause
    if (_previousIndex != 1 &&
        currentIndex == 1 &&
        config.autoPauseOnNavigateAway &&
        workout != null &&
        workout.status == WorkoutStatus.paused) {
      // Auto-resume the workout
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentWorkoutProvider.notifier).resumeWorkout();
      });
    }

    _previousIndex = currentIndex;
  }

  /// Handle destination selection with branch switching
  void _onDestinationSelected(BuildContext context, int index) {
    // Haptic feedback on tab change
    HapticFeedback.lightImpact();

    // Navigate to selected branch
    // goBranch preserves the state of the previous branch
    widget.navigationShell.goBranch(
      index,
      // If same branch, go to initial location (pop to root)
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}
```

**Step 3: Verify compilation**

Run: `flutter analyze lib/core/navigation/main_shell.dart`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/core/navigation/main_shell.dart
git commit -m "feat(navigation): integrate WorkoutMiniBar into MainShell

- Convert MainShell to ConsumerStatefulWidget
- Show mini-bar when workout active and not on workout tab
- Implement auto-pause/resume on tab navigation"
```

---

## Task 6: Add Translations

**Files:**
- Modify: `assets/i18n/app_en.arb`
- Modify: `assets/i18n/app_it.arb`

**Step 1: Add English translations**

Add to `assets/i18n/app_en.arb`:

```json
  "autoPauseOnNavigateAway": "Auto-pause when leaving workout",
  "autoPauseOnNavigateAwayDescription": "Automatically pause the workout timer when you navigate to another screen",
  "workoutPaused": "Paused",
  "workoutActive": "Active",
  "tapToReturnToWorkout": "Tap to return to workout",
```

**Step 2: Add Italian translations**

Add to `assets/i18n/app_it.arb`:

```json
  "autoPauseOnNavigateAway": "Pausa automatica uscendo dall'allenamento",
  "autoPauseOnNavigateAwayDescription": "Metti automaticamente in pausa il timer quando navighi su un'altra schermata",
  "workoutPaused": "In pausa",
  "workoutActive": "Attivo",
  "tapToReturnToWorkout": "Tocca per tornare all'allenamento",
```

**Step 3: Regenerate localizations**

Run: `flutter gen-l10n`
Expected: SUCCESS - Generated localizations in lib/shared/presentation/l10n/generated/

**Step 4: Commit**

```bash
git add assets/i18n/app_en.arb assets/i18n/app_it.arb lib/shared/presentation/l10n/generated/
git commit -m "feat(l10n): add translations for workout mini-bar feature"
```

---

## Task 7: Run Full Test Suite

**Step 1: Run analyzer**

Run: `flutter analyze`
Expected: No issues found

**Step 2: Run tests**

Run: `flutter test`
Expected: All tests pass

**Step 3: Final commit (if any fixes needed)**

```bash
git add -A
git commit -m "fix: address any issues from test suite"
```

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 1 | Pause duration tracking in Workout entity | workout.dart |
| 2 | Auto-pause setting in AppConfig | app_config.dart |
| 3 | WorkoutMiniBar widget | workout_mini_bar.dart (new) |
| 4 | Pause/Resume methods in provider | workout_provider.dart |
| 5 | Integrate into MainShell | main_shell.dart |
| 6 | Translations | app_en.arb, app_it.arb |
| 7 | Test suite verification | - |

**Total estimated time:** ~2-3 hours

---

## Testing Checklist

- [ ] Mini-bar appears when navigating away from workout screen with active workout
- [ ] Mini-bar disappears when returning to workout screen
- [ ] Timer displays correct elapsed time (excluding pause periods)
- [ ] Play/pause button toggles workout state
- [ ] Tap on mini-bar navigates to workout screen
- [ ] Progress bar reflects completed sets / total sets
- [ ] Auto-pause works when leaving workout tab (if enabled)
- [ ] Auto-resume works when returning to workout tab (if enabled)
- [ ] Mini-bar styling works in both light and dark themes
- [ ] Animations are smooth (slide in/out)

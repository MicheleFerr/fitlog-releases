# Workout Mini-Bar - Design Document

**Generated**: 2025-01-27
**Status**: Approved for implementation
**Complexity**: MEDIUM
**Estimated Tasks**: 8-10

---

## 1. Overview

### Problem Statement
Quando l'utente naviga via dalla schermata workout (verso Home o Profile), non c'è indicazione visiva che un workout è ancora attivo. Inoltre, il timer globale del workout continua a contare anche quando il workout dovrebbe essere "in pausa", causando confusione.

### Solution
Implementare un **floating mini-bar** (stile Spotify Now Playing) che appare sopra la bottom navigation quando c'è un workout attivo e l'utente non è nella schermata workout.

---

## 2. User Research Summary

### Sources Consulted
- [Spotify Design: Now Playing Bar](https://spotify.design/article/small-but-mighty-weve-rolled-out-changes-to-the-now-playing-bar)
- [Material Design 3: Bottom Sheets](https://m3.material.io/components/bottom-sheets/guidelines)
- [Stormotion: Fitness App UX](https://stormotion.io/blog/fitness-app-ux/)
- [Arounda: Progress Trackers in UX](https://arounda.agency/blog/progress-trackers-in-ux-design-2)
- [UXCam: Mobile App Best Practices 2025](https://uxcam.com/blog/mobile-app-best-practices/)

### Key Findings
| Finding | Source | Impact |
|---------|--------|--------|
| Progress bar filling = **+30% engagement** | MoldStud/Stormotion | Include progress bar |
| "Glanceable stats" for compact views | Stormotion | Keep info minimal |
| "Transparency reduces anxiety" | Arounda UX | Show progress clearly |
| Floating design = "cleaner UI" | Spotify 2024 | Use floating style |
| 66% users compare to themselves | UX Study | Focus on time, not sets |

---

## 3. Design Specification

### 3.1 Visual Design

```
┌─────────────────────────────────────────────────┐
│              (Screen Content)                    │
│                                                  │
│                                                  │
├──────────────────────────────────────────────────┤
│  ╭────────────────────────────────────────────╮  │
│  │  🏋️  Push Day          ⏸ 12:34       ▶   │  │  ← Mini-bar (56pt height)
│  │  ▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │  │  ← Progress bar (4pt)
│  ╰────────────────────────────────────────────╯  │
│                    8pt margin                     │
├──────────────────────────────────────────────────┤
│       🏠          💪          👤                 │  ← Bottom Navigation
└──────────────────────────────────────────────────┘
```

### 3.2 Dimensions & Spacing

| Element | Value | Rationale |
|---------|-------|-----------|
| Mini-bar height | 56pt | Touch-friendly (Apple HIG: min 44pt) |
| Progress bar height | 4pt | Subtle but visible |
| Corner radius | 16pt | Modern rounded style (Spotify 2024) |
| Horizontal margin | 12pt | Breathing room from edges |
| Bottom margin | 8pt | Space above nav bar |
| Icon size | 24pt (AppIconSize.medium) | Consistent with design system |

### 3.3 Content Layout

```
┌─────────────────────────────────────────────────────┐
│  [Icon]  [Workout Name]     [State] [Timer]  [CTA] │
│  24pt    flex               16pt    mono     44pt  │
│                                                     │
│  [═══════════════════░░░░░░░░░░░░░░░░░░░░░░░░░░░░] │
│  Progress bar: completedSets / totalSets            │
└─────────────────────────────────────────────────────┘
```

### 3.4 States

#### Active (Timer Running)
- Icon: `AppIcons.workout` (primary color)
- State icon: `▶` (playing)
- Timer: counting up, white/onSurface color
- Progress bar: primary color fill
- Tap action: Navigate to workout screen

#### Paused (Timer Stopped)
- Icon: `AppIcons.workout` (muted color)
- State icon: `⏸` (paused)
- Timer: frozen value, warning/amber color
- Progress bar: warning color fill
- Tap action: Navigate to workout screen

### 3.5 Interactions

| Gesture | Action |
|---------|--------|
| **Tap anywhere** | Navigate to workout screen |
| **Tap play/pause** | Toggle timer state |
| **Swipe up** | Navigate to workout screen |
| **Long press** | Show quick actions menu (future) |

### 3.6 Animations

- **Appear**: Slide up from bottom (300ms, easeOutCubic)
- **Disappear**: Slide down (200ms, easeInCubic)
- **Timer pulse**: Subtle scale animation on state change (150ms)
- **Progress bar**: Smooth fill animation (200ms)

---

## 4. Timer Behavior Fix

### 4.1 Current Bug
```dart
// workout.dart - Current implementation
Duration? get duration {
  if (startTime == null) return null;
  final end = endTime ?? DateTime.now();
  return end.difference(startTime!);  // ❌ Ignores pause time!
}
```

### 4.2 Required Changes

#### New Fields in Workout Entity
```dart
@freezed
class Workout with _$Workout {
  const factory Workout({
    // ... existing fields ...

    // NEW: Pause tracking
    @Default(Duration.zero) Duration pausedDuration,
    DateTime? lastPausedAt,
  }) = _Workout;

  // FIXED: Duration calculation
  Duration? get activeDuration {
    if (startTime == null) return null;
    final end = endTime ?? DateTime.now();
    final total = end.difference(startTime!);

    // Subtract paused time
    var paused = pausedDuration;
    if (status == WorkoutStatus.paused && lastPausedAt != null) {
      paused += DateTime.now().difference(lastPausedAt!);
    }

    return total - paused;
  }
}
```

### 4.3 User Setting: Auto-Pause on Navigate Away

```dart
// In AppConfig or workout settings
bool autoPauseOnNavigateAway = true;  // Default: pause when leaving
```

**Behavior:**
- `true`: Timer pauses when user navigates away from workout screen
- `false`: Timer continues running (shows amber warning in mini-bar)

---

## 5. Architecture

### 5.1 New Files

```
lib/
├── features/workout/
│   └── presentation/
│       └── widgets/
│           └── workout_mini_bar.dart          # NEW: Mini-bar widget
├── core/
│   └── navigation/
│       └── main_shell.dart                    # MODIFY: Add mini-bar
└── shared/
    └── presentation/
        └── providers/
            └── active_workout_indicator_provider.dart  # NEW: State management
```

### 5.2 State Management

```dart
// active_workout_indicator_provider.dart
final activeWorkoutIndicatorProvider = Provider<ActiveWorkoutIndicator?>((ref) {
  final workout = ref.watch(currentWorkoutProvider);
  if (workout == null) return null;

  final currentRoute = ref.watch(currentRouteProvider);
  final isOnWorkoutScreen = currentRoute.startsWith('/workout');

  // Don't show if already on workout screen
  if (isOnWorkoutScreen) return null;

  return ActiveWorkoutIndicator(
    workoutName: workout.name,
    duration: workout.activeDuration ?? Duration.zero,
    isPaused: workout.status == WorkoutStatus.paused,
    progress: workout.progressPercentage,
  );
});
```

### 5.3 Widget Integration

```dart
// main_shell.dart
class MainShell extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicator = ref.watch(activeWorkoutIndicatorProvider);

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          if (indicator != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 72,  // Above nav bar (64pt) + margin (8pt)
              child: WorkoutMiniBar(indicator: indicator),
            ),
        ],
      ),
      bottomNavigationBar: _BottomNavigationBar(...),
    );
  }
}
```

---

## 6. Implementation Tasks

### Phase 1: Core Infrastructure
- [ ] **T1.1**: Add `pausedDuration` and `lastPausedAt` to Workout entity
- [ ] **T1.2**: Implement `activeDuration` getter with pause calculation
- [ ] **T1.3**: Add pause/resume methods to CurrentWorkoutNotifier
- [ ] **T1.4**: Add `autoPauseOnNavigateAway` setting

### Phase 2: Mini-Bar Widget
- [ ] **T2.1**: Create `WorkoutMiniBar` widget
- [ ] **T2.2**: Create `ActiveWorkoutIndicatorProvider`
- [ ] **T2.3**: Add animations (slide, pulse, progress)
- [ ] **T2.4**: Implement tap-to-navigate action

### Phase 3: Integration
- [ ] **T3.1**: Modify `MainShell` to show mini-bar
- [ ] **T3.2**: Add route detection for hiding on workout screen
- [ ] **T3.3**: Wire up auto-pause on navigate away

### Phase 4: Polish
- [ ] **T4.1**: Add haptic feedback
- [ ] **T4.2**: Add translations (EN/IT)
- [ ] **T4.3**: Test in dark/light themes
- [ ] **T4.4**: Accessibility (semantic labels)

---

## 7. Acceptance Criteria

- [ ] Mini-bar appears when workout active AND user not on workout screen
- [ ] Timer shows correct elapsed time (excluding paused periods)
- [ ] Tap navigates to workout screen
- [ ] Play/pause button toggles timer state
- [ ] Progress bar reflects completed sets / total sets
- [ ] Setting to enable/disable auto-pause on navigate away
- [ ] Works correctly in both light and dark themes
- [ ] Animations are smooth (60fps)
- [ ] Follows design system (AppIcons, AppIconSize, context.colors)

---

## 8. Out of Scope (Future)

- Long-press quick actions menu
- Swipe to dismiss workout
- Mini-bar on Lock Screen (Live Activities - separate feature)
- Sound/vibration notifications from mini-bar

---

## 9. References

- **Design System**: `docs/DESIGN_GUIDELINES.md`
- **Timer System**: `docs/TIMER_SYSTEM_DOCUMENTATION.md`
- **Workout Entity**: `lib/features/workout/domain/entities/workout.dart`
- **Main Shell**: `lib/core/navigation/main_shell.dart`

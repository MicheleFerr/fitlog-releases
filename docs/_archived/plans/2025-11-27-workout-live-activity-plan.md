# Workout Live Activity - Implementation Plan

**Generated**: 2025-11-27 10:30
**Status**: ✅ COMPLETED
**Complexity Score**: MEDIUM
**Total Tasks**: 7
**Actual Time**: ~3h
**Plan Version**: 1.0

---

## 📋 Original Request

> Implementare una Live Activity iOS per mostrare lo stato del workout attivo sulla Lock Screen e Dynamic Island, con progress degli esercizi/set completati.

---

## 🎯 Overview

Workout Live Activity mostra in tempo reale:
- Nome workout
- Timer elapsed (con supporto pause)
- Progress: X/Y esercizi completati
- Progress: X/Y set completati
- Stato: Running/Paused

**Piattaforma**: iOS 16.1+ (ActivityKit)
**Integrazione**: WorkoutProvider (Riverpod)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter Layer                          │
├─────────────────────────────────────────────────────────────┤
│  WorkoutProvider                                            │
│    ├── startWorkout() → _startWorkoutLiveActivity()        │
│    ├── pauseWorkout() → _updateWorkoutLiveActivity()       │
│    ├── resumeWorkout() → _updateWorkoutLiveActivity()      │
│    ├── completeSet() → _updateWorkoutLiveActivity()        │
│    ├── completeWorkout() → _endWorkoutLiveActivity()       │
│    └── clearWorkout() → _endWorkoutLiveActivity()          │
│                           ↓                                 │
│  WorkoutLiveActivityService (Platform Channel)              │
│    └── MethodChannel('com.gymbro.timer/live_activity')     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      iOS Native Layer                       │
├─────────────────────────────────────────────────────────────┤
│  LiveActivityHandler.swift                                  │
│    ├── startWorkoutLiveActivity(...)                       │
│    ├── updateWorkoutLiveActivity(...)                      │
│    └── endWorkoutLiveActivity(...)                         │
│                           ↓                                 │
│  GymBroWorkoutLiveActivity.swift (Widget)                  │
│    ├── Lock Screen View                                    │
│    ├── Dynamic Island Compact                              │
│    ├── Dynamic Island Expanded                             │
│    └── Dynamic Island Minimal                              │
│                           ↓                                 │
│  GymBroWorkoutAttributes.swift (Data Model)                │
│    ├── workoutName: String                                 │
│    ├── workoutId: String                                   │
│    └── ContentState: elapsedSeconds, isRunning, sets...   │
└─────────────────────────────────────────────────────────────┘
```

---

## ✅ Task Breakdown (COMPLETED)

### 1. iOS Native Layer

- [x] **Task 1.1**: Create GymBroWorkoutAttributes
  - **Layer**: iOS Native
  - **File**: `ios/GymBroTimerWidget/GymBroWorkoutAttributes.swift`
  - **Completed**: 2025-11-27
  - **Notes**: ActivityAttributes con ContentState per workout progress

- [x] **Task 1.2**: Create GymBroWorkoutLiveActivity Widget
  - **Layer**: iOS Native
  - **File**: `ios/GymBroTimerWidget/GymBroWorkoutLiveActivity.swift`
  - **Completed**: 2025-11-27
  - **Notes**: Lock Screen + Dynamic Island views

- [x] **Task 1.3**: Add LiveActivityHandler methods
  - **Layer**: iOS Native
  - **File**: `ios/Runner/LiveActivityHandler.swift`
  - **Completed**: 2025-11-27
  - **Notes**: startWorkoutLiveActivity, updateWorkoutLiveActivity, endWorkoutLiveActivity

- [x] **Task 1.4**: Register widget in bundle
  - **Layer**: iOS Native
  - **File**: `ios/GymBroTimerWidget/GymBroTimerWidgetBundle.swift`
  - **Completed**: 2025-11-27
  - **Notes**: Added GymBroWorkoutLiveActivity() to bundle

### 2. Flutter Layer

- [x] **Task 2.1**: Create WorkoutLiveActivityService
  - **Layer**: Data/Services
  - **File**: `lib/features/workout/data/services/workout_live_activity_service.dart`
  - **Completed**: 2025-11-27
  - **Notes**: Platform channel service con provider Riverpod

- [x] **Task 2.2**: Integrate with WorkoutProvider
  - **Layer**: Presentation/Providers
  - **File**: `lib/features/workout/presentation/providers/workout_provider.dart`
  - **Completed**: 2025-11-27
  - **Notes**: Helper methods + integration in all workout lifecycle methods

### 3. Configuration

- [x] **Task 3.1**: Verify iOS capabilities
  - **Layer**: iOS Config
  - **Files**: `ios/Runner/Info.plist`, `ios/Runner/Runner.entitlements`
  - **Completed**: 2025-11-27
  - **Verified**:
    - NSSupportsLiveActivities = true
    - NSSupportsLiveActivitiesFrequentUpdates = true
    - Push Notifications entitlement
    - App Groups configured

---

## 📱 UI Components

### Lock Screen View
```
┌────────────────────────────────────────┐
│ 🏋️ Push Day                           │
│                                        │
│ ⏱️ 45:32        📊 3/5 exercises      │
│ ▶️ Running      💪 12/20 sets         │
└────────────────────────────────────────┘
```

### Dynamic Island (Compact)
```
┌──────────────────┐
│ 🏋️ 45:32  3/5   │
└──────────────────┘
```

### Dynamic Island (Expanded)
```
┌────────────────────────────────────────┐
│ 🏋️ Push Day                   ⏱️ 45:32│
│ ━━━━━━━━━━━━━━━━━━━━░░░░░░░░░  60%    │
│ 3/5 exercises • 12/20 sets            │
└────────────────────────────────────────┘
```

---

## 🔗 Integration Points

| Workout Action | Live Activity Call |
|---------------|-------------------|
| `startWorkout()` | `startWorkoutLiveActivity(running: true)` |
| `startFromTemplate()` | `startWorkoutLiveActivity(running: true)` |
| `pauseWorkout()` | `updateWorkoutLiveActivity(running: false)` |
| `resumeWorkout()` | `updateWorkoutLiveActivity(running: true)` |
| `completeSet()` | `updateWorkoutLiveActivity(...)` |
| `completeWorkout()` | `endWorkoutLiveActivity(after_5s)` |
| `clearWorkout()` | `endWorkoutLiveActivity(immediate)` |

---

## 🧪 Testing Checklist

- [ ] Start workout → Live Activity appears on Lock Screen
- [ ] Pause workout → Live Activity shows "Paused" state
- [ ] Resume workout → Live Activity shows "Running" state
- [ ] Complete sets → Progress updates in real-time
- [ ] Complete workout → Live Activity dismissed after 5s
- [ ] Clear/discard workout → Live Activity dismissed immediately
- [ ] App killed → Live Activity persists (iOS handles)
- [ ] Dynamic Island → Compact/Expanded views work

---

## 📝 Notes & Decisions

- **2025-11-27**: Implementazione completata. Usa stesso MethodChannel del timer (`com.gymbro.timer/live_activity`)
- **Design Choice**: Riuso LiveActivityHandler esistente invece di creare nuovo handler
- **Error Handling**: Errori Live Activity sono non-critical, non bloccano workout flow

---

## 🔮 Future Enhancements

1. **Deep link tap**: Tap su Live Activity apre workout screen
2. **Button actions**: Pause/Resume buttons in Dynamic Island expanded
3. **Current exercise**: Mostra nome esercizio corrente
4. **Next set preview**: "Next: 3x10 Bench Press @ 80kg"

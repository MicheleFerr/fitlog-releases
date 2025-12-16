# iOS Native Layer Documentation

> **Files**: 30+ Swift files | **Target**: iOS 16.1+ | **Key**: Live Activities, Background Audio, Watch Connectivity

---

## Quick Navigation

| Section | Description |
|---------|-------------|
| [Managers](#managers) | Core iOS managers (Audio, Background, Notifications) |
| [Live Activity](#live-activity-widget) | GymBroTimerWidget for lock screen |
| [Watch App](#watch-connectivity) | Apple Watch companion communication |
| [Configuration](#configuration) | Feature flags, logging |

---

## Architecture Overview

```
ios/Runner/
├── AppDelegate.swift           # App lifecycle, Flutter setup
├── SceneDelegate.swift         # UIScene lifecycle (iOS 13+)
├── Config/
│   └── FeatureFlags.swift      # Feature flag management
└── Managers/
    ├── AudioSessionManager.swift      # AVAudioSession state machine
    ├── BackgroundAudioManager.swift   # Silent loop + timer audio
    ├── BackgroundTaskManager.swift    # BGTaskScheduler
    ├── WatchConnectivityManager.swift # WCSession bidirectional
    ├── HealthKitActivityManager.swift # Activity rings
    ├── NotificationDelegate.swift     # UNNotificationCenter
    ├── PermissionManager.swift        # System permissions
    └── Logger.swift                   # Centralized logging

ios/GymBroTimerWidget/
├── GymBroTimerWidgetLiveActivity.swift  # Live Activity UI
├── GymBroTimerAttributes.swift          # ActivityKit attributes
├── SharedTimerState.swift               # Shared state model
└── WidgetLocalization.swift             # i18n for widget

ios/FitLogWatch Watch App/
├── ContentView.swift           # Watch UI
└── Managers/
    └── NotificationManager.swift
```

---

## Managers

### AudioSessionManager

**File**: `ios/Runner/Managers/AudioSessionManager.swift`

**Purpose**: Manages AVAudioSession with state machine for safe transitions between foreground/background modes.

**Key Features**:
- State machine: `uninitialized` → `foreground` ↔ `background`
- Thread-safe via `stateQueue`
- Silent loop configuration for background timer audio
- Validation caching to reduce overhead

**Critical Methods**:
```swift
// Configure at app launch
AudioSessionManager.shared.configureForLaunch()

// Transitions
AudioSessionManager.shared.transitionToBackground()
AudioSessionManager.shared.transitionToForeground()

// Silent loop for background audio
try AudioSessionManager.shared.configureSilentLoopSession()

// Cleanup when timer skipped
AudioSessionManager.shared.cleanupForSkip()
```

**Audio Session Configuration**:
```swift
// Category: .playback (survives lock screen)
// Options: [.mixWithOthers] (no conflict with other audio)
// Mode: .default
```

**Known Issues Fixed**:
- OSStatus -50: Removed conflicting `.duckOthers` + `.mixWithOthers`
- Memory leaks: Proper `DispatchWorkItem` cancellation
- Race conditions: `stateQueue` protection

---

### BackgroundAudioManager

**File**: `ios/Runner/Managers/BackgroundAudioManager.swift`

**Purpose**: Manages timer audio in background using hybrid strategy (Silent Loop + Notifications).

**Key Features**:
- Silent loop keeps app alive for up to 10 minutes
- Smart notification scheduling with lockscreen support
- Audio deduplication to prevent double sounds
- Flutter integration via MethodChannel

**Timer Audio Strategy**:
```
Timer Duration | Strategy
--------------|----------
< 30s         | Background task + dispatch timer
30s - 600s    | Silent loop + dispatch timer + notification fallback
> 600s        | Notification only (iOS kills silent loop)
```

**Critical Methods**:
```swift
// Schedule timer audio
BackgroundAudioManager.shared.scheduleTimerAudio(
    duration: 90,
    soundName: "YehBuddie",
    skipNotification: false  // true if Live Activity handles it
)

// Cancel all scheduled audio
BackgroundAudioManager.shared.cancelScheduledAudio()

// Check if audio was played recently (deduplication)
BackgroundAudioManager.shared.hasAudioPlayedRecently(within: 5)
```

**Flutter Channel**: `com.gymbro.background_audio`
- `scheduleTimerAudio(duration, soundName)`
- `cancelAudio`
- `startSilentLoop(maxDuration)`
- `stopSilentLoop`
- `isSilentLoopActive`
- `getDebugStatus`

---

### BackgroundTaskManager

**File**: `ios/Runner/Managers/BackgroundTaskManager.swift`

**Purpose**: Manages BGTaskScheduler for iOS 13+ background refresh.

**Task Identifiers**:
- `com.gymbro.timer.refresh` - App refresh (every 60s)
- `com.gymbro.timer.processing` - Processing task (every 5min)

**Key Features**:
- Retry logic with exponential backoff
- Health metrics tracking
- Silent loop integration
- Legacy fallback for iOS < 13

**Critical Methods**:
```swift
// Register at app launch
BackgroundTaskManager.shared.registerTasks()

// Schedule tasks when entering background
BackgroundTaskManager.shared.scheduleAppRefresh()
BackgroundTaskManager.shared.scheduleProcessingTask()

// Cancel when entering foreground
BackgroundTaskManager.shared.cancelAllTasks()
```

---

### WatchConnectivityManager

**File**: `ios/Runner/Managers/WatchConnectivityManager.swift`

**Purpose**: Bidirectional communication between iPhone and Apple Watch.

**Communication Methods**:
1. **sendMessage** - Immediate, requires Watch app in foreground
2. **updateApplicationContext** - Guaranteed delivery when Watch opens
3. **transferUserInfo** - Background queue delivery

**Workout Companion Protocol**:
```
iPhone → Watch:
- workoutStarted (exercise, sets, weight, reps, RPE settings)
- workoutUpdate (set completed, exercise changed)
- workoutEnded
- restTimerStarted/Skipped/Paused/Resumed/Extended

Watch → iPhone:
- setCompleted (with optional RPE/RIR effort)
- skipRest
- endWorkout
- pauseWorkout
- setModification (Digital Crown adjustments)
- extendTimer
- healthMetrics (heart rate, calories)
```

**Flutter Channel**: `com.gymbro/watch_connectivity`

**State Caching**:
```swift
// Cached for instant Watch responses
private var currentWorkoutState: [String: Any]?
private var currentRestTimerState: [String: Any]?
```

---

### HealthKitActivityManager

**File**: `ios/Runner/Managers/HealthKitActivityManager.swift`

**Purpose**: Native HealthKit access for Activity Rings data.

**Data Retrieved**:
- Move calories + goal
- Exercise minutes + goal
- Stand hours + goal

**Flutter Channel**: `com.gymbro/healthkit_activity`
- `isHealthKitAvailable`
- `requestActivitySummaryPermission`
- `getActivitySummary`
- `getActivitySummaryForDate(timestamp)`

---

### NotificationDelegate

**File**: `ios/Runner/Managers/NotificationDelegate.swift`

**Purpose**: UNUserNotificationCenterDelegate for notification handling.

**Key Features**:
- Foreground notification presentation (banner only, no sound - Flutter handles audio)
- Notification tap handling
- Flutter notification via `com.gymbro.timer/unified` channel

---

### PermissionManager

**File**: `ios/Runner/Managers/PermissionManager.swift`

**Purpose**: Manages system permissions and user guidance.

**Permissions Managed**:
- Background App Refresh
- Notifications
- Live Activities (iOS 16.1+)

**Key Methods**:
```swift
PermissionManager.shared.checkAllPermissions()
PermissionManager.shared.requestNotificationPermissions { granted in }
PermissionManager.shared.getBackgroundRefreshStatus() // -> PermissionStatus
```

---

## Live Activity Widget

**Location**: `ios/GymBroTimerWidget/`

### GymBroTimerAttributes

**File**: `GymBroTimerAttributes.swift`

Defines the ActivityKit attributes for timer Live Activity:

```swift
struct GymBroTimerAttributes: ActivityAttributes {
    let exerciseName: String

    struct ContentState: Codable, Hashable {
        let remainingSeconds: Int
        let totalSeconds: Int
        let currentSet: Int
        let totalSets: Int
        let isRunning: Bool
        let startDate: Date?  // For native iOS timer
        let endDate: Date?    // For native iOS timer

        // Computed properties
        var progress: Double
        var formattedTime: String
        var progressColor: Color
        var setInfo: String
    }
}
```

### GymBroTimerWidgetLiveActivity

**File**: `GymBroTimerWidgetLiveActivity.swift`

**UI Components**:
1. **Lock Screen View** - Full timer display with progress bar
2. **Dynamic Island Expanded** - Exercise name, timer, progress
3. **Dynamic Island Compact** - Progress ring + time

**Native iOS Timer**:
```swift
// Uses Text(timerInterval:countsDown:) for automatic updates
Text(timerInterval: startDate...endDate, countsDown: true)
    .font(.title2)
    .fontWeight(.bold)
    .monospacedDigit()
```

### SharedTimerState

**File**: `SharedTimerState.swift`

Shared state model for App Group communication between main app and widget.

---

## Watch Connectivity

### Watch → iPhone Events

| Event | Description | Data |
|-------|-------------|------|
| `setCompleted` | User completed set on Watch | effort, effortScale |
| `skipRest` | User skipped rest timer | - |
| `endWorkout` | User ended workout | - |
| `pauseWorkout` | User paused workout | - |
| `setModification` | Digital Crown adjustment | weight, reps |
| `extendTimer` | Timer extension | seconds |
| `healthMetrics` | Real-time health data | heartRate, calories |

### iPhone → Watch Events

| Event | Description | Data |
|-------|-------------|------|
| `workoutStarted` | Workout began on iPhone | exerciseName, sets, weight, reps, RPE settings, locale, formCues, TUT |
| `workoutUpdate` | Exercise/set changed | updated fields |
| `workoutEnded` | Workout completed | - |
| `restTimerStarted` | Rest timer started | duration, startTime |
| `restTimerSkipped` | Rest skipped | - |
| `restTimerExtended` | Timer extended | addedSeconds, newDuration |

---

## Configuration

### FeatureFlags

**File**: `ios/Runner/Config/FeatureFlags.swift`

**Available Flags**:
| Flag | Default | Description |
|------|---------|-------------|
| `useNewAudioManager` | true | AudioSessionManager (OSStatus -50 fixed) |
| `useNewBackgroundTaskManager` | DEBUG | BGTaskScheduler wrapper |
| `useEnhancedLogging` | DEBUG | Detailed logging |
| `useErrorRecovery` | true | Error recovery system |
| `showDebugInfo` | DEBUG | Debug UI elements |

**Usage**:
```swift
if FeatureFlags.useNewAudioManager {
    AudioSessionManager.shared.configureForLaunch()
}
```

### Logger

**File**: `ios/Runner/Managers/Logger.swift`

**Log Levels**: `.debug`, `.info`, `.warning`, `.error`

**Categories**: `.general`, `.audioSession`, `.backgroundTask`, `.permission`

```swift
Logger.shared.log(.info, "Timer started", category: .audioSession)
```

---

## SceneDelegate

**File**: `ios/Runner/SceneDelegate.swift`

Extends `FlutterSceneDelegate` for UIScene lifecycle:

| Event | Action |
|-------|--------|
| `sceneDidBecomeActive` | Reactivate audio session |
| `sceneWillEnterForeground` | Transition to foreground, cancel background tasks |
| `sceneDidEnterBackground` | Transition to background, schedule background tasks |

---

## Flutter Integration Points

| Channel | Purpose |
|---------|---------|
| `com.gymbro.background_audio` | Background audio/timer management |
| `com.gymbro.timer/unified` | Unified timer coordination |
| `com.gymbro/watch_connectivity` | Apple Watch communication |
| `com.gymbro/healthkit_activity` | HealthKit Activity Rings |
| `com.gymbro/live_activity` | Live Activity control |

---

## Critical Files - DO NOT MODIFY Without Understanding

| File | Risk | Reason |
|------|------|--------|
| `AudioSessionManager.swift` | HIGH | Complex state machine, OSStatus errors |
| `BackgroundAudioManager.swift` | HIGH | Silent loop, deduplication logic |
| `GymBroTimerWidgetLiveActivity.swift` | MEDIUM | Live Activity UI, native timer |
| `WatchConnectivityManager.swift` | MEDIUM | Bidirectional sync, state caching |

---

## Debugging Tips

### Audio Issues
```swift
// Print current audio session state
AudioSessionManager.shared.debugPrintCurrentState()

// Test complete audio flow
BackgroundAudioManager.shared.testCompleteAudioFlow()

// Verify cleanup patterns
BackgroundAudioManager.shared.verifyCleanupPatterns()
```

### Watch Connectivity
```swift
// Check detailed status
print("⌚ isPaired: \(session.isPaired)")
print("⌚ isWatchAppInstalled: \(session.isWatchAppInstalled)")
print("⌚ isReachable: \(session.isReachable)")
```

### Background Tasks
```swift
// Get health metrics
let metrics = BackgroundTaskManager.shared.getHealthMetrics()
print("Success rate: \(metrics["successRate"])")
```

---

## See Also

- [INDEX.md](../INDEX.md) - Complete codebase map
- [ARCHITECTURE.md](../ARCHITECTURE.md) - Data flow patterns
- [features/timer.md](../features/timer.md) - Flutter timer feature

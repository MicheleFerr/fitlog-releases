# FitLog Watch App Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        APPLE WATCH                               │
│                     (Native SwiftUI App)                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐     │
│  │                 FitLogWatchApp.swift                   │     │
│  │              @main Entry Point                         │     │
│  │  @StateObject var connectivityManager                  │     │
│  └────────────────────────────────────────────────────────┘     │
│                           │                                      │
│                           ▼                                      │
│  ┌────────────────────────────────────────────────────────┐     │
│  │                  ContentView.swift                      │     │
│  │            Root View (WorkoutListView)                  │     │
│  └────────────────────────────────────────────────────────┘     │
│                           │                                      │
│           ┌───────────────┴────────────────┐                    │
│           ▼                                ▼                    │
│  ┌──────────────────┐          ┌──────────────────────┐         │
│  │ WorkoutListView  │          │ ActiveWorkoutView    │         │
│  │                  │          │                      │         │
│  │ - Quick Start    │   Nav    │ - MetricsView        │         │
│  │ - Templates      │  ────▶   │ - ControlsView       │         │
│  │ - Sync Button    │          │ - TabView UI         │         │
│  └──────────────────┘          └──────────────────────┘         │
│           │                                │                    │
│           │                                │                    │
│           ▼                                ▼                    │
│  ┌─────────────────────────────────────────────────────┐        │
│  │              MANAGERS LAYER                         │        │
│  ├─────────────────────────────────────────────────────┤        │
│  │                                                     │        │
│  │  ┌──────────────────────────────────────────────┐  │        │
│  │  │        WorkoutManager                        │  │        │
│  │  │        @MainActor ObservableObject           │  │        │
│  │  ├──────────────────────────────────────────────┤  │        │
│  │  │ @Published var heartRate: Double             │  │        │
│  │  │ @Published var activeCalories: Double        │  │        │
│  │  │ @Published var elapsedTime: TimeInterval     │  │        │
│  │  │ @Published var currentHeartRateZone          │  │        │
│  │  ├──────────────────────────────────────────────┤  │        │
│  │  │ - startWorkout(type:) async throws           │  │        │
│  │  │ - pauseWorkout()                             │  │        │
│  │  │ - resumeWorkout()                            │  │        │
│  │  │ - endWorkout() async throws                  │  │        │
│  │  └──────────────────────────────────────────────┘  │        │
│  │                      │                              │        │
│  │                      ▼                              │        │
│  │  ┌──────────────────────────────────────────────┐  │        │
│  │  │       ConnectivityManager                    │  │        │
│  │  │       @MainActor ObservableObject            │  │        │
│  │  │       Singleton Pattern                      │  │        │
│  │  ├──────────────────────────────────────────────┤  │        │
│  │  │ @Published var isReachable: Bool             │  │        │
│  │  │ @Published var receivedTemplates: [Template] │  │        │
│  │  ├──────────────────────────────────────────────┤  │        │
│  │  │ - sendWorkoutCompleted(_:) async             │  │        │
│  │  │ - requestTemplates() async                   │  │        │
│  │  │ - sendSetLogged(...)                         │  │        │
│  │  └──────────────────────────────────────────────┘  │        │
│  │                                                     │        │
│  └─────────────────────────────────────────────────────┘        │
│                           │                                      │
│                           │                                      │
└───────────────────────────┼──────────────────────────────────────┘
                            │
                 ┌──────────┴───────────┐
                 │                      │
                 ▼                      ▼
        ┌────────────────┐    ┌────────────────────┐
        │   HealthKit    │    │ WatchConnectivity  │
        │  HKWorkout     │    │    WCSession       │
        │  HKLiveBuilder │    │                    │
        └────────────────┘    └────────────────────┘
                 │                      │
                 │                      │ Bluetooth/WiFi
                 │                      ▼
                 │            ┌──────────────────────┐
                 │            │      iPHONE          │
                 │            │ (Flutter App)        │
                 │            ├──────────────────────┤
                 │            │                      │
                 │            │ WatchConnectivity    │
                 │            │      Bridge          │
                 │            │   (Swift Native)     │
                 │            │         │            │
                 │            │         ▼            │
                 │            │   MethodChannel      │
                 │            │         │            │
                 │            │         ▼            │
                 │            │  WatchConnectivity   │
                 │            │     Service.dart     │
                 │            │         │            │
                 │            │         ▼            │
                 │            │   Riverpod Provider  │
                 │            │         │            │
                 │            │         ▼            │
                 │            │   Flutter UI         │
                 │            │                      │
                 │            └──────────────────────┘
                 │                      │
                 ▼                      │
        ┌────────────────────────────────┼─┐
        │       Apple Health             │ │
        │    (Shared Database)           │ │
        │                                │ │
        │  - Workouts                    │ │
        │  - Heart Rate Samples          │ │
        │  - Active Energy               │ │
        │  - Activity Rings              │ │
        │                                │ │
        └────────────────────────────────┴─┘
```

## Data Flow Diagrams

### 1. Starting a Workout

```
User Action: Tap "Strength Training"
         │
         ▼
WorkoutListView
         │
         ▼
NavigationLink to ActiveWorkoutView
         │
         ▼
ActiveWorkoutView.onAppear()
         │
         ▼
WorkoutManager.startWorkout(type: .strengthTraining)
         │
         ├─▶ Request HealthKit Authorization
         │
         ├─▶ Create HKWorkoutConfiguration
         │
         ├─▶ Create HKWorkoutSession
         │
         ├─▶ Create HKLiveWorkoutBuilder
         │
         ├─▶ Set delegates (self)
         │
         ├─▶ Start session.startActivity(with: Date())
         │
         ├─▶ Start builder.beginCollection()
         │
         ├─▶ Start Timer (1 sec interval)
         │
         └─▶ Trigger haptic feedback
```

### 2. Real-Time Data Collection

```
HealthKit Sensors (Heart Rate, Energy)
         │
         ▼
HKLiveWorkoutBuilder collects samples
         │
         ▼
workoutBuilder(_:didCollectDataOf:) delegate callback
         │
         ▼
Task { @MainActor in
    - Update heartRate @Published property
    - Calculate currentHeartRateZone
    - Update activeCalories @Published property
}
         │
         ▼
SwiftUI View Auto-Updates (ObservableObject)
         │
         ▼
MetricsView displays updated values
```

### 3. Ending a Workout

```
User Action: Tap End Button
         │
         ▼
Confirmation Dialog
         │
         ▼ (confirmed)
WorkoutManager.endWorkout()
         │
         ├─▶ session.end()
         │
         ├─▶ builder.endCollection(at: Date())
         │
         ├─▶ builder.finishWorkout() → HKWorkout
         │
         ├─▶ ConnectivityManager.sendWorkoutCompleted(workout)
         │   │
         │   ├─▶ Check if iPhone reachable
         │   │
         │   ├─▶ YES: session.sendMessage() [immediate]
         │   │
         │   └─▶ NO: session.transferUserInfo() [background]
         │
         ├─▶ Cleanup: session = nil, builder = nil
         │
         ├─▶ Invalidate timer
         │
         ├─▶ Trigger success haptic
         │
         └─▶ Navigate back (dismiss)
```

### 4. Template Sync (iPhone → Watch)

```
iPhone App: User creates/updates template
         │
         ▼
WatchConnectivityBridge.sendTemplates(templates)
         │
         ▼
WCSession.updateApplicationContext(data)
         │
         │ [Bluetooth/WiFi Transfer]
         │
         ▼
Watch: WCSessionDelegate.didReceiveApplicationContext()
         │
         ▼
ConnectivityManager.parseTemplates(data)
         │
         ▼
Update @Published receivedTemplates array
         │
         ▼
WorkoutListView auto-updates with new templates
```

### 5. Workout Sync (Watch → iPhone)

```
Watch: WorkoutManager.endWorkout()
         │
         ▼
ConnectivityManager.sendWorkoutCompleted(workout)
         │
         ├─▶ Create data dictionary:
         │   {
         │     "type": "workoutCompleted",
         │     "duration": Double,
         │     "calories": Double,
         │     "startDate": TimeInterval,
         │     "endDate": TimeInterval,
         │     "workoutType": Int
         │   }
         │
         ├─▶ Check iPhone reachability
         │
         ▼
    [REACHABLE]
         │
         ▼
    session.sendMessage() → Immediate
         │
         │ [Over Bluetooth/WiFi]
         │
         ▼
iPhone: WCSessionDelegate.didReceiveMessage()
         │
         ▼
WatchConnectivityBridge notifies Flutter
         │
         ▼
MethodChannel: "workoutCompletedOnWatch"
         │
         ▼
Flutter: WatchConnectivityService.onWorkoutCompleted()
         │
         ▼
Save to Firestore + Local DB

    OR

    [NOT REACHABLE]
         │
         ▼
    session.transferUserInfo() → Background
         │
         │ [Queued for later delivery]
         │
         ▼
iPhone: WCSessionDelegate.didReceiveUserInfo()
         │
         └─▶ Same flow as above
```

## Component Responsibilities

### WorkoutManager
**Role**: Workout tracking engine
- Manages HKWorkoutSession lifecycle
- Collects real-time metrics from HealthKit
- Calculates heart rate zones
- Provides @Published properties for UI binding
- Handles start/pause/resume/end operations
- Triggers haptic feedback

**Dependencies**:
- HealthKit framework
- ConnectivityManager (for syncing)

**State Management**:
- @MainActor for thread safety
- ObservableObject for SwiftUI
- @Published properties for reactive updates

### ConnectivityManager
**Role**: Communication bridge
- Singleton managing WCSession
- Sends workout data to iPhone
- Receives templates from iPhone
- Handles reachability changes
- Provides background transfer fallback

**Dependencies**:
- WatchConnectivity framework
- None (standalone singleton)

**State Management**:
- @MainActor for thread safety
- ObservableObject for SwiftUI
- @Published properties for UI status

### WorkoutListView
**Role**: Main navigation UI
- Displays workout type options
- Shows synced templates
- Provides sync controls
- Shows connection status

**Dependencies**:
- ConnectivityManager (via EnvironmentObject)
- WorkoutManager (created locally)

### ActiveWorkoutView
**Role**: Live workout interface
- Displays real-time metrics
- Provides workout controls
- Manages workout lifecycle
- Handles user interactions

**Dependencies**:
- WorkoutManager (passed from parent)

**Sub-components**:
- MetricsView: Heart rate, calories, time
- ControlsView: Pause/Resume/End buttons

## Thread Safety

### @MainActor Usage
All UI-related classes are marked with @MainActor:
- WorkoutManager
- ConnectivityManager

This ensures:
- All UI updates happen on main thread
- No data races
- Safe @Published property updates

### Delegate Callbacks
Delegate methods are marked `nonisolated`:
```swift
nonisolated func workoutBuilder(
    _ workoutBuilder: HKLiveWorkoutBuilder,
    didCollectDataOf collectedTypes: Set<HKSampleType>
) {
    Task { @MainActor in
        // Safe UI updates here
    }
}
```

## Error Handling

### Async Operations
```swift
Task {
    do {
        try await workoutManager.startWorkout(type: type)
    } catch {
        print("❌ Failed to start workout: \(error)")
        // TODO: Show error alert
    }
}
```

### WatchConnectivity Errors
```swift
session.sendMessage(data, replyHandler: nil) { error in
    print("❌ Failed to send: \(error.localizedDescription)")
    // Fallback to background transfer
    session.transferUserInfo(data)
}
```

## Memory Management

### Weak Self in Closures
```swift
timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
    self?.updateElapsedTime()
}
```

### Cleanup on End
```swift
func endWorkout() async throws {
    // ... save workout ...

    // Cleanup
    self.session = nil
    self.builder = nil
    self.timer?.invalidate()
    self.timer = nil
}
```

## HealthKit Authorization Flow

```
First Launch
     │
     ▼
workoutManager.startWorkout() called
     │
     ▼
healthStore.requestAuthorization(toShare:read:)
     │
     ▼
System shows HealthKit permission dialog
     │
     ├─▶ [User Grants] → Continue
     │
     └─▶ [User Denies] → Throw error
```

Subsequent launches:
- Authorization cached by system
- No dialog shown
- Immediate access granted

## Background Processing

### Workout Processing Mode
Enabled via `Info.plist`:
```xml
<key>WKBackgroundModes</key>
<array>
    <string>workout-processing</string>
</array>
```

**Benefits**:
- Workout continues if app goes to background
- Screen can turn off during workout
- Data collection continues
- Battery efficient

### Background Delivery
Enabled via entitlements:
```xml
<key>com.apple.developer.healthkit.background-delivery</key>
<true/>
```

**Benefits**:
- HealthKit can deliver data in background
- Workout updates even when screen off
- Automatic sync to Apple Health

## Future Architecture Considerations

### Phase 2: Quick Logging
```
┌─────────────────────────┐
│   SetLogView.swift      │
├─────────────────────────┤
│ - Digital Crown picker  │
│ - Weight input          │
│ - Reps input            │
│ - Haptic confirmation   │
└─────────────────────────┘
         │
         ▼
ConnectivityManager.sendSetLogged()
         │
         ▼
iPhone receives and saves
```

### Phase 3: Complications
```
┌─────────────────────────────┐
│  ComplicationController     │
├─────────────────────────────┤
│ - Read from App Groups      │
│ - TimelineProvider          │
│ - Update every hour         │
└─────────────────────────────┘
         │
         ▼
UserDefaults(suiteName: "group.com.gymbro.flutter")
         │
         ▼
Watch Face Complications
```

### Phase 4: Local Storage
```
┌─────────────────────────────┐
│  CoreData / UserDefaults    │
├─────────────────────────────┤
│ - Store templates locally   │
│ - Workout history           │
│ - Offline mode support      │
└─────────────────────────────┘
```

## Code Organization Best Practices

1. **Separation of Concerns**:
   - Managers: Business logic
   - Views: UI only
   - Models: Data structures

2. **Protocol-Oriented**:
   - Delegates for callbacks
   - Protocols for testability

3. **Type Safety**:
   - Enums for workout types
   - Enums for heart rate zones
   - No magic numbers/strings

4. **Documentation**:
   - MARK: comments for organization
   - DocC-style comments for public APIs
   - Inline comments for complex logic

5. **Modern Swift**:
   - async/await (no completion handlers)
   - @MainActor (no DispatchQueue.main)
   - ObservableObject (no NotificationCenter)

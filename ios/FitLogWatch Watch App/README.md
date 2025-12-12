# FitLog Watch App

Native watchOS companion app for FitLog Pro fitness tracker.

## Architecture

### Managers
- **WorkoutManager.swift**: Manages HKWorkoutSession for real-time workout tracking
  - Heart rate monitoring with zone detection
  - Calorie tracking via HealthKit
  - Workout session lifecycle (start/pause/resume/end)
  - Haptic feedback integration

- **ConnectivityManager.swift**: Handles WatchConnectivity with iPhone
  - Bidirectional sync with iPhone app
  - Template sync from iPhone
  - Workout completion notifications
  - Background data transfer support

### Views
- **WorkoutListView.swift**: Main view showing workout types and templates
  - Quick start options (Strength, HIIT, Functional)
  - Template list from iPhone
  - Sync controls
  - Connection status indicator

- **ActiveWorkoutView.swift**: Live workout tracking interface
  - Real-time metrics display (heart rate, calories, duration)
  - Heart rate zone visualization
  - Pause/Resume/End controls
  - Swipeable TabView interface

### Models
- **WorkoutTemplate**: Simple model for synced workout templates

## Features

### MVP (Phase 1)
- [x] Start workouts directly from Watch
- [x] Real-time heart rate monitoring
- [x] Calorie tracking via HKWorkoutSession
- [x] Heart rate zones (Warmup, Fat Burn, Cardio, Peak, Extreme)
- [x] Pause/Resume/End controls
- [x] Sync completed workouts to iPhone
- [x] Receive templates from iPhone
- [x] Haptic feedback

### Future Phases
- [ ] Quick set logging (weight/reps picker)
- [ ] Rest timer
- [ ] Complications for watch face
- [ ] Always On Display optimization
- [ ] Offline mode improvements

## Requirements

- watchOS 10.0+
- iOS 17.0+ (companion iPhone app)
- HealthKit authorization
- WatchConnectivity framework

## HealthKit Permissions

The app requests the following HealthKit permissions:

**Read:**
- Heart Rate
- Active Energy Burned
- Distance Walking/Running

**Write:**
- Workout sessions

## Background Modes

- `workout-processing`: Allows workout tracking to continue in background

## App Groups

- `group.com.gymbro.flutter`: Shared container for complications data

## Setup Notes

1. **Xcode Project Configuration**:
   - Watch app target must be embedded in iOS app
   - Build Phases order: Embed Frameworks → Embed Watch Content → Thin Binary
   - Code signing: Use same team/provisioning as iOS app

2. **Entitlements**:
   - HealthKit capability enabled
   - Background delivery for HealthKit
   - App Groups for data sharing

3. **Testing**:
   - WatchConnectivity requires real devices (not simulator)
   - HKWorkoutSession requires real Apple Watch
   - Test on physical devices only

## Integration with Flutter App

The Watch app communicates with the Flutter app via:

1. **WatchConnectivity (Swift bridge on iPhone side)**:
   - Send workout completed events
   - Receive template updates
   - Real-time reachability status

2. **MethodChannel** (Flutter side):
   - Channel: `com.gymbro/watch_connectivity`
   - Methods: `sendTemplates`, `isWatchReachable`, `isWatchPaired`

See iPhone-side bridge implementation at: `ios/Runner/WatchConnectivityBridge.swift`

## Code Style

Following Apple's Swift guidelines:
- @MainActor for UI-related classes
- async/await for asynchronous operations
- Combine framework for reactive updates
- SwiftUI for all UI components
- Proper memory management with [weak self]

## Known Limitations

1. Flutter does NOT run on watchOS - this is a native Swift app
2. WatchConnectivity only works between paired devices
3. HKWorkoutSession requires Apple Watch hardware
4. Background workout processing requires `workout-processing` entitlement
5. Always On Display requires watchOS 5+ and specific device models

## Next Steps

To complete the Watch app integration:

1. **iPhone Bridge** (Swift): Create `WatchConnectivityBridge.swift` in iOS app
2. **Flutter Service** (Dart): Create `watch_connectivity_service.dart`
3. **Xcode Project**: Add Watch target to build phases
4. **Testing**: Deploy to real Apple Watch and iPhone

## Resources

- [Apple: Build a workout app for Apple Watch](https://developer.apple.com/documentation/healthkit/workouts_and_activity_rings/build_a_workout_app_for_apple_watch)
- [Apple: WatchConnectivity](https://developer.apple.com/documentation/watchconnectivity)
- [WWDC21: Build a workout app](https://developer.apple.com/videos/play/wwdc2021/10009/)

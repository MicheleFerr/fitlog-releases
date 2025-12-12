# Apple Watch Integration Checklist

## Phase 1: Watch App (✅ COMPLETED)

- [x] Create Watch app target structure
- [x] Implement WorkoutManager.swift
- [x] Implement ConnectivityManager.swift
- [x] Create WorkoutListView.swift
- [x] Create ActiveWorkoutView.swift
- [x] Update ContentView.swift
- [x] Update FitLogWatchApp.swift
- [x] Create FitLogWatch.entitlements
- [x] Create Info.plist with background modes
- [x] Create documentation

## Phase 2: Xcode Project Configuration (TODO)

### 2.1 Add Watch Target to Xcode Project
- [ ] Open `/Users/michele/gymbro_flutter_new/ios/Runner.xcworkspace` in Xcode
- [ ] Verify "FitLogWatch Watch App" target exists
- [ ] Check target membership for all Swift files:
  - [ ] WorkoutManager.swift
  - [ ] ConnectivityManager.swift
  - [ ] WorkoutListView.swift
  - [ ] ActiveWorkoutView.swift
  - [ ] ContentView.swift
  - [ ] FitLogWatchApp.swift

### 2.2 Configure Build Phases (Runner target)
- [ ] Open Runner target → Build Phases
- [ ] Verify order:
  1. Embed Frameworks
  2. **Embed Watch Content** ← Must be here
  3. Thin Binary
- [ ] Add "FitLogWatch Watch App" to Embed Watch Content if missing

### 2.3 Signing & Capabilities (Watch App)
- [ ] Select "FitLogWatch Watch App" target
- [ ] Go to "Signing & Capabilities"
- [ ] Enable capabilities:
  - [ ] HealthKit
  - [ ] Background Modes → workout-processing
  - [ ] App Groups → group.com.gymbro.flutter
- [ ] Set Team and Provisioning Profile

### 2.4 Build Settings (Watch App)
- [ ] Product Bundle Identifier: `com.gymbro.flutter.watchkitapp`
- [ ] Deployment Target: watchOS 10.0
- [ ] Swift Language Version: Swift 5
- [ ] Code Signing Entitlements: `FitLogWatch.entitlements`

### 2.5 Runner App Configuration
- [ ] Select "Runner" target
- [ ] Go to "Signing & Capabilities"
- [ ] Verify App Groups includes: `group.com.gymbro.flutter`
- [ ] Verify bundle ID: `com.gymbro.flutter`

## Phase 3: iPhone Bridge Implementation (TODO)

### 3.1 Create Swift Bridge
File: `/Users/michele/gymbro_flutter_new/ios/Runner/Managers/WatchConnectivityBridge.swift`

```swift
import Foundation
import WatchConnectivity
import Flutter

class WatchConnectivityBridge: NSObject {
    static let shared = WatchConnectivityBridge()
    private var session: WCSession?
    private var methodChannel: FlutterMethodChannel?

    func setupChannel(with messenger: FlutterBinaryMessenger) {
        methodChannel = FlutterMethodChannel(
            name: "com.gymbro/watch_connectivity",
            binaryMessenger: messenger
        )

        methodChannel?.setMethodCallHandler { [weak self] call, result in
            // Handle Flutter method calls
        }

        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
}

extension WatchConnectivityBridge: WCSessionDelegate {
    // Implement required delegate methods
}
```

Tasks:
- [ ] Create WatchConnectivityBridge.swift
- [ ] Implement `setupChannel()`
- [ ] Implement method handlers:
  - [ ] `isWatchPaired`
  - [ ] `isWatchReachable`
  - [ ] `sendMessage`
  - [ ] `sendTemplates`
- [ ] Implement WCSessionDelegate methods:
  - [ ] `session(_:activationDidCompleteWith:error:)`
  - [ ] `sessionDidBecomeInactive(_:)`
  - [ ] `sessionDidDeactivate(_:)`
  - [ ] `session(_:didReceiveMessage:replyHandler:)`
  - [ ] `session(_:didReceiveUserInfo:)`

### 3.2 Register Bridge in AppDelegate
File: `/Users/michele/gymbro_flutter_new/ios/Runner/AppDelegate.swift`

```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController

        // Setup Watch Connectivity Bridge
        WatchConnectivityBridge.shared.setupChannel(
            with: controller.binaryMessenger
        )

        // ... other setup ...

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

Tasks:
- [ ] Import WatchConnectivity bridge
- [ ] Call `setupChannel()` in `didFinishLaunchingWithOptions`

## Phase 4: Flutter Implementation (TODO)

### 4.1 Create Watch Connectivity Service
File: `/Users/michele/gymbro_flutter_new/lib/features/watch/data/services/watch_connectivity_service.dart`

```dart
import 'package:flutter/services.dart';

class WatchConnectivityService {
  static const _channel = MethodChannel('com.gymbro/watch_connectivity');

  // Callbacks
  Function(Map<String, dynamic>)? onWorkoutCompleted;
  Function(Map<String, dynamic>)? onSetLogged;
  Function()? onTemplatesRequested;
  Function(bool)? onReachabilityChanged;

  WatchConnectivityService() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<void> _handleMethod(MethodCall call) async {
    // Handle callbacks from Watch
  }

  Future<bool> isWatchPaired() async {
    return await _channel.invokeMethod<bool>('isWatchPaired') ?? false;
  }

  Future<bool> sendTemplates(List<Map<String, dynamic>> templates) async {
    // Implement
  }
}
```

Tasks:
- [ ] Create directory: `lib/features/watch/`
- [ ] Create WatchConnectivityService
- [ ] Implement method call handlers
- [ ] Implement public API methods:
  - [ ] `isWatchPaired()`
  - [ ] `isWatchReachable()`
  - [ ] `sendTemplates()`
  - [ ] `sendMessage()`

### 4.2 Create Riverpod Provider
File: `/Users/michele/gymbro_flutter_new/lib/features/watch/presentation/providers/watch_connectivity_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
class WatchConnectivity extends _$WatchConnectivity {
  late WatchConnectivityService _service;

  @override
  Future<WatchState> build() async {
    _service = WatchConnectivityService();

    // Setup callbacks
    _service.onWorkoutCompleted = _handleWorkoutCompleted;

    return WatchState(
      isPaired: await _service.isWatchPaired(),
      isReachable: await _service.isWatchReachable(),
    );
  }

  Future<void> syncTemplates() async {
    // Get templates from repository
    // Send to watch
  }
}
```

Tasks:
- [ ] Create WatchConnectivityProvider
- [ ] Implement state management
- [ ] Add callback handlers
- [ ] Add public methods:
  - [ ] `syncTemplates()`
  - [ ] `checkStatus()`

### 4.3 Create Watch Status Widget
File: `/Users/michele/gymbro_flutter_new/lib/features/watch/presentation/widgets/watch_status_card.dart`

Tasks:
- [ ] Create watch status indicator widget
- [ ] Show paired/reachable status
- [ ] Add sync templates button
- [ ] Add to settings or profile screen

## Phase 5: Testing (TODO)

### 5.1 Prerequisites
- [ ] Real Apple Watch (Series 4+)
- [ ] Real iPhone (iPhone 6s+)
- [ ] Watch paired with iPhone
- [ ] Both devices on same Apple ID
- [ ] Development certificates configured

### 5.2 Build & Deploy
- [ ] Build Watch app in Xcode
- [ ] Deploy to physical Apple Watch
- [ ] Build iOS app in Xcode
- [ ] Deploy to physical iPhone
- [ ] Verify both apps installed

### 5.3 Basic Functionality Tests
- [ ] Launch Watch app
- [ ] Verify connection status shows "Connected"
- [ ] Tap "Strength Training"
- [ ] Wait for HealthKit permission dialog
- [ ] Grant HealthKit permissions
- [ ] Verify workout starts
- [ ] Verify heart rate displays
- [ ] Verify calories update
- [ ] Verify timer updates
- [ ] Test pause button
- [ ] Test resume button
- [ ] Test end workout
- [ ] Verify workout saves to Health app

### 5.4 Sync Tests
- [ ] Open iPhone app
- [ ] Create a workout template
- [ ] On Watch app, tap "Sync Templates"
- [ ] Verify template appears on Watch
- [ ] On Watch, complete a workout
- [ ] Verify workout syncs to iPhone app
- [ ] Check Firestore for workout data

### 5.5 Edge Cases
- [ ] Test with iPhone out of range
  - [ ] Start workout on Watch
  - [ ] Move iPhone away (Bluetooth range)
  - [ ] Complete workout
  - [ ] Bring iPhone back
  - [ ] Verify background sync works
- [ ] Test with Watch screen off
  - [ ] Start workout
  - [ ] Lower wrist (screen off)
  - [ ] Wait 30 seconds
  - [ ] Raise wrist
  - [ ] Verify data collection continued
- [ ] Test Always On Display
  - [ ] Start workout
  - [ ] Lower wrist (Always On)
  - [ ] Verify simplified metrics shown

## Phase 6: App Store Submission (TODO)

### 6.1 Metadata
- [ ] App Store Connect: Add Watch screenshots
- [ ] Add Watch app description
- [ ] Add Watch app keywords
- [ ] Specify Watch OS requirement (10.0+)

### 6.2 Review Notes
- [ ] Explain Watch app requires physical device
- [ ] Provide test account
- [ ] Provide demo video of Watch functionality
- [ ] Note HealthKit usage for workout tracking

### 6.3 Submission
- [ ] Archive iOS app + Watch app
- [ ] Upload to App Store Connect
- [ ] Submit for review
- [ ] Monitor review status

## Quick Reference Commands

### Build Watch App
```bash
cd /Users/michele/gymbro_flutter_new/ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme "FitLogWatch Watch App" \
  -configuration Debug \
  -destination 'platform=watchOS,name=Apple Watch' \
  clean build
```

### Check Watch Connectivity
```swift
// In Swift
print("WCSession.isSupported: \(WCSession.isSupported())")
print("WCSession.isPaired: \(WCSession.default.isPaired)")
print("WCSession.isReachable: \(WCSession.default.isReachable)")
```

### Flutter Debug
```dart
// In Dart
final isPaired = await WatchConnectivityService().isWatchPaired();
print('Watch paired: $isPaired');
```

## Troubleshooting

### Watch App Not Installing
- Check bundle identifier matches
- Verify Watch target in build phases
- Clean build folder (Cmd+Shift+K)
- Verify deployment target (watchOS 10.0)

### WatchConnectivity Not Working
- Must use real devices (not simulator)
- Watch must be paired and unlocked
- Both apps must activate WCSession
- Check Bluetooth is enabled

### HealthKit Authorization Failing
- Verify entitlements include HealthKit
- Check Info.plist has usage descriptions
- Reset permissions in Settings → Privacy
- Verify signing with same team ID

### Data Not Syncing
- Check WCSession.isReachable
- Verify message format matches
- Check delegates are set
- Enable verbose logging

## Success Criteria

- [ ] Watch app installs successfully
- [ ] Watch app launches without crashes
- [ ] HealthKit permissions granted
- [ ] Workout tracking works
- [ ] Heart rate displays in real-time
- [ ] Calories update correctly
- [ ] Workout saves to Apple Health
- [ ] Workout syncs to iPhone app
- [ ] Templates sync from iPhone to Watch
- [ ] Connection status displays correctly
- [ ] Background workout processing works
- [ ] App passes App Store review

## Documentation

- [x] Watch app architecture diagram
- [x] Implementation summary
- [x] README in Watch app folder
- [ ] Update main project README
- [ ] Add user guide for Watch features
- [ ] Create troubleshooting guide

## Resources

- Plan document: `/Users/michele/gymbro_flutter_new/docs/plans/WATCH_COMPANION_APP_PLAN.md`
- Architecture: `/Users/michele/gymbro_flutter_new/docs/WATCH_APP_ARCHITECTURE.md`
- Implementation: `/Users/michele/gymbro_flutter_new/docs/WATCH_APP_IMPLEMENTATION_SUMMARY.md`
- Watch README: `/Users/michele/gymbro_flutter_new/ios/FitLogWatch Watch App/README.md`

## Notes

- Current status: **Watch app native code complete, needs Xcode project integration**
- Next step: Configure Xcode build phases and signing
- Estimated time to complete: 2-3 hours for Xcode config + iPhone bridge
- Testing time: 1-2 hours with real devices

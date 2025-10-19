# 🍎 iOS Native Integration & Platform Channels: Live Activities, Dynamic Island & Background Tasks

> **Platform-Specific System** - iOS-native functionality bridge
> **Location**: `lib/features/notifications/presentation/adapters/ios_notification_adapter.dart`
> **Native Side**: `ios/Runner/` (Swift code)
> **Status**: Production (Live Activities active, Dynamic Island support)
> **Last Updated**: October 2025

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Platform Channels](#platform-channels)
4. [Method Channel Setup](#method-channel-setup)
5. [Live Activities System](#live-activities-system)
6. [Permission Management](#permission-management)
7. [Implementation Guide](#implementation-guide)
8. [iOS-Specific Features](#ios-specific-features)
9. [Error Handling](#error-handling)
10. [Testing & Debugging](#testing--debugging)
11. [Troubleshooting](#troubleshooting)
12. [Migration Guide](#migration-guide)

---

## Overview

### 🎯 Purpose

The **iOS Native Integration** system bridges Flutter and native iOS code, enabling:
- **Live Activities** (iOS 16.1+) - Persistent timers on lock screen & Dynamic Island
- **Method Channels** - Bidirectional Dart ↔ Swift communication
- **Critical Alerts** - Special permission required notifications
- **Background Tasks** - App continues timers when backgrounded
- **Platform-Specific APIs** - Access to iOS-only features

### 📱 iOS Exclusive Features

| Feature | iOS Version | Capability |
|---------|-------------|-----------|
| **Live Activities** | 16.1+ | Lock screen + Dynamic Island display |
| **Dynamic Island** | 14 Pro+ | Floating notification experience |
| **Critical Alerts** | 12+ | Sound + haptic bypass DND |
| **HealthKit** | 8+ | Apple Health integration |
| **Siri Shortcuts** | 12+ | Voice commands automation |

### 🔗 Architecture Overview

```
Dart Layer (Flutter)
├─ ios_notification_adapter.dart
├─ Method calls (async)
└─ Receives callbacks

    ↓ Platform Channel ↓

Native Layer (Swift)
├─ NotificationManager.swift
├─ LiveActivityManager.swift
├─ BackgroundTaskManager.swift
└─ Responds with results

    ↓ Permissions & Capabilities ↓

iOS System
├─ UserNotifications.framework
├─ ActivityKit.framework
├─ BackgroundTasks.framework
└─ APNs (Apple Push Notification service)
```

---

## Architecture

### 📦 Component Breakdown

#### **Dart Adapter (Flutter Side)**
```dart
class IOSNotificationAdapter implements NotificationPlatformAdapter {
  static const MethodChannel _channel = MethodChannel('com.gymbro.notifications.ios');
  static const MethodChannel _liveActivityChannel = MethodChannel('com.gymbro.live_activities');

  Future<void> initialize() async {
    // Setup method call handlers
    _channel.setMethodCallHandler(_handleMethodCall);
    _liveActivityChannel.setMethodCallHandler(_handleLiveActivityCall);

    // Initialize native iOS components
    await _channel.invokeMethod('initialize', {...});
  }
}
```

#### **Swift Native (iOS Side)**
```swift
// ios/Runner/NotificationManager.swift
class NotificationManager: NSObject {
  static let channel = FlutterMethodChannel(
    name: "com.gymbro.notifications.ios",
    binaryMessenger: controller.binaryMessenger
  )

  // Receive calls from Dart
  channel.setMethodCallHandler { (call, result) in
    switch call.method {
    case "initialize":
      self.initializeNotifications(call.arguments, result)
    case "setBadgeCount":
      self.setBadgeCount(call.arguments, result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
```

### 🔄 Data Flow

```
User Action (save workout)
  │
  ├─ Dart: await scheduleLocalNotification(notification)
  │
  ├─ Method Channel call:
  │  └─ invokeMethod('scheduleLocalNotification', {...})
  │
  ├─ Swift: Receives method call
  │  └─ Creates iOS notification with UNNotificationRequest
  │
  ├─ iOS System: UserNotifications.framework
  │  └─ Schedules notification in system queue
  │
  └─ Result: Promise resolved
     └─ Returns notification ID to Dart

Notification triggers (at scheduled time)
  │
  ├─ iOS System: Fires notification
  │
  ├─ Swift: Receives notification delivery event
  │  └─ Converts to Dart callback
  │
  ├─ Method Channel response:
  │  └─ invokeMethod('onNotificationDelivered', {...})
  │
  └─ Dart: Handles callback
     └─ Updates UI, analytics, etc.
```

---

## Platform Channels

### 🔗 Method Channel Basics

**Method Channel**: Synchronous Dart ↔ Swift bidirectional communication

```dart
// Dart side: Call native method
try {
  final result = await channel.invokeMethod('methodName', {
    'param1': value1,
    'param2': value2,
  });
} on PlatformException catch (e) {
  print("Native error: ${e.message}");
}

// Swift side: Receive and respond
channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
  switch call.method {
  case "methodName":
    let param1 = call.arguments["param1"]
    let response = performAction(param1)
    result(response)  // Send back result
  default:
    result(FlutterMethodNotImplemented)
  }
}
```

### 📡 GymBro's Two Channels

#### **Primary Channel: Notifications**
```
Channel name: 'com.gymbro.notifications.ios'
Purpose: General notification operations
Methods:
  - initialize() - Setup iOS framework
  - setBadgeCount(count) - Set app badge
  - getBadgeCount() - Get current badge
  - requestCriticalAlertPermissions() - Request special permissions
  - setNotificationSound(type, soundName) - Change sound
  - applyQuietHours(quietHours) - Set quiet mode
```

#### **Secondary Channel: Live Activities**
```
Channel name: 'com.gymbro.live_activities'
Purpose: iOS 16.1+ Lock Screen notifications
Methods:
  - startLiveActivity(activityData) - Start timer on lock screen
  - updateLiveActivity(activityId, data) - Update live data
  - cancelLiveActivity(activityId) - Stop activity
```

### 🔐 Channel Security

```dart
// ✅ CORRECT: Verified channel names
static const MethodChannel _channel = MethodChannel(
  'com.gymbro.notifications.ios'  // Must match iOS side
);

// ⚠️ Make sure iOS side matches exactly
// ios/Runner/GeneratedPluginRegistrant.swift
// com.gymbro.notifications.ios → NotificationManager
```

---

## Method Channel Setup

### 📱 Dart Setup (Flutter Side)

```dart
// lib/features/notifications/presentation/adapters/ios_notification_adapter.dart

class IOSNotificationAdapter {
  // Define channels
  static const MethodChannel _channel = MethodChannel(
    'com.gymbro.notifications.ios'
  );
  static const MethodChannel _liveActivityChannel = MethodChannel(
    'com.gymbro.live_activities'
  );

  // Initialize handlers
  Future<void> initialize() async {
    try {
      // Set up method call handler for main channel
      _channel.setMethodCallHandler(_handleMethodCall);

      // Set up method call handler for live activity channel
      _liveActivityChannel.setMethodCallHandler(_handleLiveActivityCall);

      // Invoke native initialize
      await _channel.invokeMethod('initialize', {
        'sounds': _getAvailableSounds(),
        'categories': _getNotificationCategories(),
      });

      _isInitialized = true;
    } catch (error) {
      throw Exception('Failed to initialize: $error');
    }
  }

  // Handle callbacks from Swift
  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onNotificationDelivered':
        await trackNotificationDelivered(
          call.arguments['notificationId'],
          call.arguments['metadata'],
        );
        break;
      case 'onNotificationInteraction':
        await trackNotificationInteraction(
          call.arguments['notificationId'],
          call.arguments['interactionType'],
        );
        break;
      default:
        debugPrint('Unhandled method: ${call.method}');
    }
  }
}
```

### 🍎 Swift Setup (iOS Side)

```swift
// ios/Runner/NotificationManager.swift
import UserNotifications
import Foundation

class NotificationManager: NSObject, FlutterPlugin {
  static let channelName = "com.gymbro.notifications.ios"
  static var methodChannel: FlutterMethodChannel?

  static func register(with registrar: FlutterPluginRegistrar!) {
    let messenger = registrar.messenger()
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: messenger
    )

    let instance = NotificationManager()
    registrar.addMethodCallDelegate(instance, channel: channel)
    methodChannel = channel  // Keep reference for calling back to Dart
  }

  // Handle method calls from Dart
  func dummyMethodToEnforceBundling(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      handleInitialize(call.arguments as? [String: Any], result: result)

    case "setBadgeCount":
      if let args = call.arguments as? [String: Any],
         let count = args["count"] as? NSNumber {
        UIApplication.shared.applicationIconBadgeNumber = count.intValue
        result(true)
      } else {
        result(false)
      }

    case "requestCriticalAlertPermissions":
      requestCriticalAlertPermissions(result: result)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // Call back to Dart
  func callDart(method: String, arguments: [String: Any]) {
    NotificationManager.methodChannel?.invokeMethod(method, arguments: arguments)
  }
}
```

---

## Live Activities System

### 🔴 What are Live Activities?

**Live Activities** (iOS 16.1+): Persistent notifications on lock screen that update in real-time

```
Lock Screen Display:
┌─────────────────────────────────────────┐
│ Time: 9:41                          📶📡  │
│                                         │
│  🏋️ GymBro TrackLog                   │
│  Rest Timer: 01:25                      │
│  Next: Squats (5 reps)                  │
│                                    [X] [>]│
└─────────────────────────────────────────┘

Dynamic Island (iPhone 14 Pro+):
┌──────────────────────────────────────┐
│ 🏋️ GymBro - Rest Timer: 01:25 [X][>] │
└──────────────────────────────────────┘
```

### 🎯 Live Activity Flow

```
User starts workout → scheduleLocalNotification()
  │
  ├─ Dart detects: type == timerComplete OR workoutId != null
  │
  ├─ Calls: _startLiveActivity(notification)
  │  └─ Sends to Swift via _liveActivityChannel
  │
  ├─ Swift: Creates ActivityAttributes
  │  └─ Defines what data updates in real-time
  │
  ├─ Swift: StartLiveActivityRequest(attributes, content)
  │  └─ Requests ActivityKit to display on lock screen
  │
  ├─ iOS: Displays on lock screen/Dynamic Island
  │
  ├─ Timer updates every 1 second
  │  └─ Swift: await activity.update(...)
  │
  └─ Timer expires or user stops
     └─ Swift: await activity.end(...)
```

### 📦 ActivityAttributes (Swift Data Model)

```swift
// ios/Runner/WorkoutTimerAttributes.swift
import Foundation
import ActivityKit

// Data that DOESN'T change (static content)
struct WorkoutTimerAttributes: ActivityAttributes {
  public typealias TimerStatus = ContentState

  // Static content
  struct ContentState: Codable, Hashable {
    // Variables that update in real-time
    var remainingSeconds: Int
    var currentExercise: String
    var repsRemaining: Int
    var isRunning: Bool
  }

  // Static info (set once at start)
  var workoutId: String
  var workoutName: String
  var totalExercises: Int
}

// Initial content for lock screen
let attributes = WorkoutTimerAttributes(
  workoutId: "w123",
  workoutName: "Upper Body",
  totalExercises: 5
)

let initialState = WorkoutTimerAttributes.TimerStatus(
  remainingSeconds: 90,
  currentExercise: "Bench Press",
  repsRemaining: 5,
  isRunning: true
)

// Start the activity
let activity = try? Activity.request(
  attributes: attributes,
  content: .init(state: initialState, staleDate: nil),
  pushType: .token  // For remote updates via APNs
)
```

### 🔄 Updating Live Activity

```dart
// Dart: Every 1 second update from timer
Timer.periodic(Duration(seconds: 1), (timer) async {
  // Update live activity
  await _liveActivityChannel.invokeMethod('updateLiveActivity', {
    'activityId': activityId,
    'data': {
      'remainingSeconds': remainingSeconds,
      'isRunning': true,
      'currentExercise': 'Bench Press',
    },
  });
});

// Swift side
channel.setMethodCallHandler { (call, result) in
  case "updateLiveActivity":
    if let args = call.arguments as? [String: Any],
       let activityId = args["activityId"] as? String,
       let data = args["data"] as? [String: Any],
       let remainingSeconds = data["remainingSeconds"] as? Int {

      // Find and update the activity
      for activity in Activity<WorkoutTimerAttributes>.all {
        var contentState = activity.content.state
        contentState.remainingSeconds = remainingSeconds

        // Update on lock screen
        await activity.update(
          ActivityContent(state: contentState, staleDate: nil)
        )
      }
      result(true)
    }
}
```

---

## Permission Management

### 🔐 iOS Permission Types

```dart
enum NotificationPermissionType {
  /// Basic notifications (alert, sound, badge)
  basic,

  /// Critical alerts (bypass Do Not Disturb)
  critical,

  /// Provisional (shows first 5 notifications silently)
  provisional,
}
```

### 📋 Permission Request Flow

```
User launches app
  │
  ├─ Dart: checkPermissions()
  │  └─ Swift: UNUserNotificationCenter.current().getNotificationSettings()
  │
  ├─ Result: PermissionStatus.denied
  │
  ├─ Dart shows permission request UI
  │  └─ "Allow notifications?" dialog
  │
  ├─ User taps "Allow"
  │
  ├─ Dart: requestPermissions()
  │  └─ Swift: requestAuthorization(options: [.alert, .sound, .badge])
  │
  ├─ iOS shows system permission dialog
  │
  ├─ User confirms
  │
  └─ Permission granted: notifications work
```

### 🛡️ Critical Alert Permissions

**Critical Alerts**: Special permission to bypass "Do Not Disturb" mode

```dart
// Request critical alert permission (separate from normal notifications)
Future<bool> requestCriticalAlertPermissions() async {
  try {
    final result = await _channel.invokeMethod<bool>(
      'requestCriticalAlertPermissions'
    );
    return result ?? false;
  } catch (e) {
    return false;
  }
}

// Swift side
func requestCriticalAlertPermissions(result: @escaping FlutterResult) {
  UNUserNotificationCenter.current().requestAuthorization(
    options: [.alert, .sound, .badge, .criticalAlert]
  ) { (granted, error) in
    result(granted)
  }
}
```

**Requirements for Critical Alerts**:
1. App must be approved by Apple for specific use case (medical, emergency, etc.)
2. User must explicitly grant permission
3. Can only be used for emergency/medical/urgent information
4. Not for marketing or casual notifications

---

## Implementation Guide

### Step 1: Initialize Adapter on App Startup

```dart
// main.dart or AppStartup widget
class AppStartup extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      // Initialize iOS adapter
      ref.read(iosNotificationAdapterProvider.notifier).initialize();
      return null;
    }, []);

    return YourApp();
  }
}

// Provider
final iosNotificationAdapterProvider = StateNotifierProvider((ref) {
  return IOSNotificationAdapter();
});
```

### Step 2: Request Permissions

```dart
class NotificationPermissionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Request notification permissions
            final adapter = ref.read(iosNotificationAdapterProvider.notifier);
            final granted = await adapter.requestPermissions();

            if (granted) {
              SnackBar(content: Text('✅ Permissions granted'));
            } else {
              SnackBar(content: Text('❌ Permissions denied'));
            }
          },
          child: Text('Enable Notifications'),
        ),
      ),
    );
  }
}
```

### Step 3: Schedule Notifications/Live Activities

```dart
// Schedule workout notification with Live Activity
Future<void> scheduleWorkoutNotification(Workout workout) async {
  final adapter = ref.read(iosNotificationAdapterProvider.notifier);

  final notification = UnifiedNotification(
    id: workout.id,
    type: NotificationType.timerComplete,
    title: 'Get ready for your workout!',
    body: 'Time to start: ${workout.name}',
    scheduledTime: workout.scheduledTime,
    workoutId: workout.id,  // Triggers Live Activity
    priority: NotificationPriority.high,
  );

  // Schedule (will show as Live Activity on lock screen)
  final id = await adapter.scheduleLocalNotification(notification);

  if (id != null) {
    print('✅ Workout notification scheduled, Live Activity ID: $id');
  }
}
```

---

## iOS-Specific Features

### 🎵 Notification Sounds

```dart
// Available sounds in GymBro
List<String> _getAvailableSounds() {
  return [
    'timer_complete.caf',           // Ding! Timer done
    'achievement_unlocked.caf',     // Chime for achievements
    'workout_reminder.caf',         // Gentle reminder
    'progress_milestone.caf',       // Success sound
    'rest_timer_complete.caf',      // Rest period over
  ];
}

// Set sound for notification type
await adapter.setNotificationSound(
  NotificationType.timerComplete,
  'timer_complete.caf'
);
```

**Sound Requirements**:
- Format: `.caf` (Core Audio Format)
- Size: < 1MB
- Location: `ios/Runner/Sounds/`
- Add to Xcode project: Build Phases → Copy Bundle Resources

### 📲 Notification Categories & Actions

iOS lets users respond to notifications without opening app:

```dart
List<Map<String, dynamic>> _getNotificationCategories() {
  return [
    {
      'identifier': 'TIMER_COMPLETE',
      'actions': [
        {'identifier': 'STOP_TIMER', 'title': 'Stop', 'options': ['destructive']},
        {'identifier': 'START_REST', 'title': 'Start Rest', 'options': []},
      ],
    },
    {
      'identifier': 'WORKOUT_REMINDER',
      'actions': [
        {'identifier': 'START_WORKOUT', 'title': 'Start Now', 'options': []},
        {'identifier': 'SNOOZE_REMINDER', 'title': 'Remind Later', 'options': []},
      ],
    },
  ];
}
```

**Result in iOS**:
```
Notification appears:
┌─────────────────────────────┐
│ 🏋️ Rest Timer Complete      │
│ 90 seconds up, time to work! │
│                             │
│ [Stop Timer]  [Start Rest]  │
└─────────────────────────────┘

User taps action → Dart receives callback
  └─ `trackNotificationInteraction('id', 'START_REST')`
```

### 🔔 Badge Management

```dart
// Update app badge count
await adapter.setBadgeCount(5);  // Shows "5" on app icon

// Get current badge
final count = await adapter.getBadgeCount();

// Clear badge
await adapter.clearBadge();
```

### 🕐 Quiet Hours

```dart
// Don't show notifications during sleep
await adapter.applyQuietHours([
  TimeRange(
    startHour: 22,  // 10 PM
    endHour: 8,     // 8 AM next day
  ),
]);
```

---

## Error Handling

### 🚨 Common Errors

```dart
try {
  await adapter.scheduleLocalNotification(notification);
} on PlatformException catch (e) {
  switch (e.code) {
    case 'PERMISSION_DENIED':
      // User didn't grant permission
      showPermissionRequest();
      break;

    case 'NOTIFICATION_LIMIT':
      // Too many scheduled notifications (iOS limit: 64)
      cancelOldestNotification();
      reschedule();
      break;

    case 'INVALID_DATA':
      // Notification data format issue
      logError('Invalid notification format');
      break;

    case 'NATIVE_ERROR':
      // Unknown Swift error
      crashReporter.recordException(e);
      break;

    default:
      print('Unknown error: ${e.message}');
  }
}
```

### ✅ Validation

```dart
// Validate configuration before starting
final issues = await adapter.validateConfiguration();

if (issues.isNotEmpty) {
  print('⚠️ Configuration issues:');
  for (final issue in issues) {
    print('  - $issue');
  }
  // Log or report to analytics
}
```

---

## Testing & Debugging

### 🧪 Test Notification

```dart
// Send test notification immediately
await adapter.sendTestNotification(
  'Test Title',
  'This is a test notification'
);

// Check if notification appears in 5 seconds
```

### 🐛 Debug Info

```dart
// Get detailed debug information
final debugInfo = await adapter.getDebugInfo();

print('''
iOS Notification Debug Info:
  App Badge: ${debugInfo['currentBadge']}
  Notifications Pending: ${debugInfo['pendingCount']}
  Notifications Delivered: ${debugInfo['deliveredCount']}
  Live Activities Active: ${debugInfo['liveActivitiesCount']}
  Last Error: ${debugInfo['lastError']}
''');
```

### 📊 Performance Metrics

```dart
// Get notification performance metrics
final metrics = await adapter.getPerformanceMetrics();

print('''
Performance:
  Average Delivery Latency: ${metrics.averageDeliveryLatency.inMilliseconds}ms
  Total Scheduled: ${metrics.totalNotificationsScheduled}
  Total Delivered: ${metrics.totalNotificationsDelivered}
  Memory Usage: ${metrics.memoryUsageMB} MB
''');
```

### ⚕️ Health Check

```dart
// Comprehensive system health check
final isHealthy = await adapter.performHealthCheck();

if (!isHealthy) {
  final issues = await adapter.validateConfiguration();
  // Fix issues before using notifications
}
```

---

## Troubleshooting

### ❌ Issue: Notifications Not Appearing

**Diagnosis**:
```dart
// 1. Check permissions
final hasPermissions = await adapter.hasPermissions();
print('Permissions: $hasPermissions');

// 2. Validate configuration
final issues = await adapter.validateConfiguration();
print('Issues: $issues');

// 3. Check pending notifications
final pending = await adapter.getPendingNotificationIds();
print('Pending: ${pending.length}');
```

**Solutions**:
- Request permissions: `await adapter.requestPermissions()`
- Check system settings: User may have disabled notifications
- Check Do Not Disturb: Quiet hours or system DND active
- Check battery: Low power mode may delay notifications

### ❌ Issue: Live Activities Not Showing

**Symptoms**: Timer scheduled but doesn't appear on lock screen

**Cause**: Likely iOS version < 16.1 or notification not marked as timer type

```dart
// ✅ Fix: Ensure notification type triggers Live Activity
final notification = UnifiedNotification(
  type: NotificationType.timerComplete,  // ← Must be timer type
  workoutId: 'w123',                     // ← Must have workoutId
  // ...
);
```

### ❌ Issue: Method Channel Error

**Symptoms**: "Unable to establish connection on channel"

**Cause**: Channel name mismatch between Dart and Swift

```dart
// Verify channel names match EXACTLY
// Dart:
const MethodChannel('com.gymbro.notifications.ios')

// Swift:
FlutterMethodChannel(
  name: "com.gymbro.notifications.ios",  // ← Must match exactly
  binaryMessenger: messenger
)
```

---

## Migration Guide

### 📚 Migrating from Old Notification System

If you have existing code using different pattern:

```dart
// ❌ OLD (Don't use)
await LocalNotificationService.scheduleNotification(...)

// ✅ NEW (Use this)
final adapter = ref.read(iosNotificationAdapterProvider.notifier);
await adapter.scheduleLocalNotification(unifiedNotification)
```

### 🔄 Add Live Activities to Existing Feature

```dart
// 1. Update UnifiedNotification to include workoutId
final notification = UnifiedNotification(
  // ... existing fields
  workoutId: workout.id,  // ← Add this
);

// 2. Rest of code stays the same
await adapter.scheduleLocalNotification(notification);

// Live Activity now automatically shows!
```

---

## Related Documentation

- **Hybrid Repository Architecture**: `HYBRID_REPOSITORY_ARCHITECTURE.md`
- **Notification System KB**: `NOTIFICATION_SYSTEM_KB.md`
- **iOS Error Analysis**: `ios_native_error_analysis.md`
- **Background Tasks**: iOS `BackgroundTaskManager.swift`

---

## Changelog

| Date | Change | Impact |
|------|--------|--------|
| **Oct 2025** | Documentation created | 📚 Reference for iOS integration |
| | Method channels documented | 🔗 Setup guide for Dart↔Swift |
| | Live Activities system | 🔴 Lock screen + Dynamic Island |

---

## Resources

### Apple Documentation
- [UserNotifications Framework](https://developer.apple.com/documentation/usernotifications)
- [ActivityKit (Live Activities)](https://developer.apple.com/documentation/activitykit)
- [Push Notifications](https://developer.apple.com/notifications/)

### GymBro Code
- Native: `ios/Runner/NotificationManager.swift`
- Native: `ios/Runner/LiveActivityManager.swift`
- Dart: `lib/features/notifications/presentation/adapters/`

---

**Last Updated**: October 19, 2025
**Author**: Michele (GymBro Development Team)
**Status**: 📚 Production Documentation - Platform-Specific System

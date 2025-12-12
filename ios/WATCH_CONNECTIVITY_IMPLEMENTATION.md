# WatchConnectivity iPhone Bridge Implementation

## Implementation Summary

The iPhone-side WatchConnectivity bridge has been successfully implemented to enable bidirectional communication between the GymBro Flutter app and Apple Watch companion app.

## Files Created/Modified

### Created:
- `/ios/Runner/Managers/WatchConnectivityManager.swift` - Main bridge implementation

### Modified:
- `/ios/Runner/AppDelegate.swift` - Added WatchConnectivityManager registration

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   APPLE WATCH                            │
│  (SwiftUI + WatchConnectivity)                          │
└──────────────────┬──────────────────────────────────────┘
                   │ Bluetooth/WiFi
                   │
┌──────────────────▼──────────────────────────────────────┐
│  WatchConnectivityManager.swift                          │
│  - WCSessionDelegate implementation                      │
│  - Handles bidirectional messaging                       │
│  - Background transfers support                          │
└──────────────────┬──────────────────────────────────────┘
                   │ FlutterMethodChannel
                   │
┌──────────────────▼──────────────────────────────────────┐
│  Flutter App (Dart)                                      │
│  - WatchConnectivityService                             │
│  - Workout sync, template sync                          │
└─────────────────────────────────────────────────────────┘
```

## Method Channel API

### Channel Name
`com.gymbro/watch_connectivity`

### Flutter → iOS Methods

| Method | Arguments | Return | Description |
|--------|-----------|--------|-------------|
| `isWatchPaired` | none | `bool` | Check if Apple Watch is paired |
| `isWatchAppInstalled` | none | `bool` | Check if Watch app is installed |
| `isWatchReachable` | none | `bool` | Check if Watch is currently reachable |
| `sendTemplates` | `List<Map>` | `bool` | Send workout templates to Watch |
| `sendMessage` | `Map` | `Map?` | Send immediate message (requires reachable) |
| `updateApplicationContext` | `Map` | `bool` | Update shared state (background delivery) |

### iOS → Flutter Events

| Event | Arguments | Description |
|-------|-----------|-------------|
| `onWatchStateChanged` | `Map` | Watch pairing/reachability changed |
| `onWorkoutReceived` | `Map` | Workout completed on Watch |
| `onSetLogged` | `Map` | Set logged on Watch |
| `onTemplatesRequested` | `Map` | Watch requested templates |
| `onWorkoutPaused` | `Map` | Workout paused on Watch |
| `onWorkoutResumed` | `Map` | Workout resumed on Watch |
| `onApplicationContextReceived` | `Map` | Context update from Watch |
| `onBackgroundDataReceived` | `Map` | Background transfer from Watch |

## Key Features

### 1. State Management
- Thread-safe state tracking with dedicated dispatch queue
- Automatic session activation and reactivation (for watch switching)
- Connection state monitoring with Flutter callbacks

### 2. Communication Modes

#### Immediate Messaging (Reachable)
```swift
// Used when Watch is actively connected
session.sendMessage(data, replyHandler: { response in
    // Handle immediate response
})
```

#### Application Context (Background)
```swift
// Used for state sync (latest value only)
try session.updateApplicationContext(data)
```

#### Background Transfers (Reliable)
```swift
// Used when Watch not reachable (queued delivery)
session.transferUserInfo(data)
```

### 3. Message Handling

The manager handles various message types from Watch:
- **workoutCompleted**: Sync finished workout to iPhone
- **setLogged**: Log individual set during workout
- **requestTemplates**: Watch needs latest templates
- **workoutPaused/Resumed**: Real-time workout state changes

### 4. Logging Integration

Uses existing `Logger.shared` for comprehensive logging:
- Connection state changes
- Message send/receive events
- Error conditions with detailed context
- Debug information for troubleshooting

## Flutter Integration Example

```dart
// Create service instance
final watchService = WatchConnectivityService();

// Setup callbacks
watchService.onWorkoutCompleted = (data) {
  // Handle workout from Watch
  final duration = data['duration'] as double;
  final calories = data['calories'] as double;
  // Save to database...
};

watchService.onTemplatesRequested = () {
  // Send templates to Watch
  final templates = await getActiveTemplates();
  watchService.sendTemplates(templates);
};

// Check Watch status
final isPaired = await watchService.isWatchPaired();
final isReachable = await watchService.isWatchReachable();

// Send templates
final success = await watchService.sendTemplates([
  {
    'id': 'template-1',
    'name': 'Push Day',
    'exercises': [...]
  }
]);
```

## Testing Requirements

### Device Requirements
- **Physical iPhone** and **physical Apple Watch** required
- WatchConnectivity does NOT work reliably in simulators
- Both devices must be paired via Watch app on iPhone

### Test Scenarios
1. **Pairing State**
   - Verify `isWatchPaired()` returns correct state
   - Check `isWatchAppInstalled()` when Watch app present/absent

2. **Message Delivery**
   - Test immediate messaging when Watch reachable
   - Test background transfer when Watch not reachable
   - Verify message queuing and delivery

3. **Template Sync**
   - Send templates from iPhone to Watch
   - Verify templates received and displayed on Watch

4. **Workout Sync**
   - Complete workout on Watch
   - Verify data appears in iPhone app
   - Check HealthKit integration

5. **Connection Changes**
   - Test with Watch out of range
   - Test airplane mode scenarios
   - Verify automatic reconnection

## Error Handling

The implementation includes comprehensive error handling:

1. **Session Not Available**
   - Gracefully handles devices without WatchConnectivity support
   - Returns appropriate error codes to Flutter

2. **Connection Lost**
   - Automatically falls back to background transfers
   - Queues data for delivery when reconnected

3. **Message Failures**
   - Logs detailed error information
   - Returns Flutter errors with descriptive messages

## Performance Considerations

### Battery Impact
- Minimizes polling and background activity
- Uses delegate pattern for reactive updates
- Batches template updates to reduce transfers

### Memory Management
- Weak self references to prevent retain cycles
- Proper cleanup in delegate methods
- Efficient JSON serialization

### Network Efficiency
- Application context for state (replaces previous value)
- User info transfers for reliable queued delivery
- Direct messages only when immediate response needed

## Next Steps

### Flutter Implementation (Required)
Create `lib/features/watch/data/services/watch_connectivity_service.dart`:
```dart
class WatchConnectivityService {
  static const _channel = MethodChannel('com.gymbro/watch_connectivity');

  // Implement Flutter side of bridge
  // See plan document for complete implementation
}
```

### Watch App Implementation (Required)
1. Create watchOS target in Xcode
2. Implement `ConnectivityManager.swift` on Watch side
3. Create SwiftUI views for Watch app
4. Configure entitlements and capabilities

See `/docs/plans/WATCH_COMPANION_APP_PLAN.md` for complete implementation guide.

## Dependencies

### Frameworks Used
- `WatchConnectivity.framework` - Bidirectional messaging
- `Flutter` - Platform channel integration
- Foundation - Core Swift types

### iOS Version Requirements
- **Minimum**: iOS 13.0 (WatchConnectivity available)
- **Recommended**: iOS 17.0+ for best performance
- **Watch**: watchOS 10.0+ recommended

## Debugging

### Enable Verbose Logging
```swift
// In FeatureFlags.swift or AppDelegate
Logger.shared.configure(minimumLevel: .debug)
```

### Check Connection State
```dart
// Flutter
final isPaired = await watchService.isWatchPaired();
final isInstalled = await watchService.isWatchAppInstalled();
final isReachable = await watchService.isWatchReachable();

print('Watch Status:');
print('  Paired: $isPaired');
print('  App Installed: $isInstalled');
print('  Reachable: $isReachable');
```

### Monitor Messages
Watch Xcode console for log messages:
```
[WatchConnectivity] WCSession activated: 2
[WatchConnectivity] 📩 Received Watch message: workoutCompleted
[WatchConnectivity] ✅ Sent 5 templates to Watch
```

## Known Limitations

1. **Simulator Support**: WatchConnectivity requires physical devices
2. **Message Size**: Large payloads may timeout (keep under 64KB)
3. **Delivery Timing**: Background transfers not guaranteed immediate
4. **Session Lifecycle**: Must handle inactive/deactivated states

## Resources

- [WatchConnectivity Documentation](https://developer.apple.com/documentation/watchconnectivity)
- [WWDC21: Data Transfer on Apple Watch](https://developer.apple.com/videos/play/wwdc2021/10003/)
- Project Plan: `/docs/plans/WATCH_COMPANION_APP_PLAN.md`

---

**Implementation Date**: December 8, 2024
**iOS Version**: 13.0+
**Status**: ✅ iPhone Bridge Complete - Watch App Implementation Pending

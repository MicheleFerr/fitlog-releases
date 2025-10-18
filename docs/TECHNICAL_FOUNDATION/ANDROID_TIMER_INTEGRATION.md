# 📱 Android Timer Integration Guide

## Overview

This guide explains how to integrate the Android Foreground Service timer with the existing GymBro timer system.

Android **does NOT have Live Activities** like iOS. Instead, we use:
- **Foreground Service** → Keeps app running in background
- **Persistent Notification** → Shows timer with progress and actions
- **Quick Actions** → Pause/Resume/Stop buttons in notification

## 🎯 Features Implemented

### Rich Notification
```
┌─────────────────────────────────────┐
│ ⏱ 1:23 remaining                   │
│ Bench Press • Set 2/4 • Workout A  │
│ ═══════════════════════ 45%        │
│ [⏸ Pause]  [⏹ Stop]                │
└─────────────────────────────────────┘
```

- Real-time countdown
- Progress bar visualization
- Exercise and set information
- Quick actions (no need to open app)

### Architecture

```
┌─────────────────────────────────────┐
│         Flutter Layer               │
│  (UnifiedTimerCoordinator)          │
└────────────┬────────────────────────┘
             │
             ├─ iOS → LiveActivityHandler
             │        (ActivityKit)
             │
             └─ Android → AndroidTimerService
                          (Foreground Service)
```

## 📝 Integration Steps

### 1. Initialize Android Service

In your app initialization (e.g., `main.dart` or timer coordinator):

```dart
import 'dart:io';
import 'package:gymbro_flutter_new/features/workout/data/services/android_timer_service.dart';

Future<void> initializeTimerServices() async {
  if (Platform.isAndroid) {
    await AndroidTimerService.initialize(
      onTimerAction: (action) {
        // Handle quick actions from notification
        switch (action) {
          case 'pause':
            // Pause timer in your state management
            break;
          case 'resume':
            // Resume timer in your state management
            break;
          case 'stop':
            // Stop timer in your state management
            break;
        }
      },
    );
  }
}
```

### 2. Start Timer (Platform-Specific)

```dart
Future<void> startPlatformTimer({
  required String exerciseName,
  String? workoutName,
  required int remainingSeconds,
  required int totalSeconds,
  required int currentSet,
  required int totalSets,
}) async {
  if (Platform.isIOS) {
    // iOS Live Activity
    await liveActivityChannel.invokeMethod('startLiveActivity', {
      'exerciseName': exerciseName,
      // ... iOS specific params
    });
  } else if (Platform.isAndroid) {
    // Android Foreground Service
    await AndroidTimerService.startTimer(
      exerciseName: exerciseName,
      workoutName: workoutName,
      remainingSeconds: remainingSeconds,
      totalSeconds: totalSeconds,
      currentSet: currentSet,
      totalSets: totalSets,
    );
  }
}
```

### 3. Update Timer Every Second

```dart
// In your timer tick callback
void onTimerTick(int remainingSeconds) {
  if (Platform.isIOS) {
    // Update Live Activity
    liveActivityChannel.invokeMethod('updateLiveActivity', {
      'remainingSeconds': remainingSeconds,
      // ... other params
    });
  } else if (Platform.isAndroid) {
    // Update Android notification
    AndroidTimerService.updateTimer(
      remainingSeconds: remainingSeconds,
      isRunning: isTimerRunning,
      currentSet: currentSet,
    );
  }
}
```

### 4. Stop Timer

```dart
Future<void> stopPlatformTimer() async {
  if (Platform.isIOS) {
    await liveActivityChannel.invokeMethod('endLiveActivity');
  } else if (Platform.isAndroid) {
    await AndroidTimerService.stopTimer();
  }
}
```

## 🔧 Advanced: Full Timer Coordinator Integration

```dart
class UnifiedTimerCoordinator {
  // Initialize on app start
  Future<void> initialize() async {
    if (Platform.isAndroid) {
      await AndroidTimerService.initialize(
        onTimerAction: _handleAndroidTimerAction,
      );
    }
  }

  // Handle Android quick actions
  void _handleAndroidTimerAction(String action) {
    switch (action) {
      case 'pause':
        pauseTimer();
        break;
      case 'resume':
        resumeTimer();
        break;
      case 'stop':
        stopTimer();
        break;
    }
  }

  // Start timer (platform-aware)
  Future<void> startTimer({
    required Exercise exercise,
    required int restSeconds,
    required int currentSet,
    required int totalSets,
  }) async {
    if (Platform.isIOS) {
      await _startIOSLiveActivity(/* params */);
    } else if (Platform.isAndroid) {
      await AndroidTimerService.startTimer(
        exerciseName: exercise.name,
        workoutName: _currentWorkout?.name,
        remainingSeconds: restSeconds,
        totalSeconds: restSeconds,
        currentSet: currentSet,
        totalSets: totalSets,
      );
    }
  }

  // Update on every tick
  void _onTimerTick() {
    final remaining = _getRemainingSeconds();

    if (Platform.isIOS) {
      _updateIOSLiveActivity(remaining);
    } else if (Platform.isAndroid) {
      AndroidTimerService.updateTimer(
        remainingSeconds: remaining,
        isRunning: _isRunning,
        currentSet: _currentSet,
      );
    }
  }
}
```

## 📊 Platform Differences

| Feature | iOS Live Activity | Android Foreground Service |
|---------|-------------------|----------------------------|
| **Update Frequency** | Every 1-5s (optimized) | Only on state change |
| **Battery Impact** | Medium (with throttling) | Low |
| **Visibility** | Lock screen widget | Notification drawer |
| **Interactions** | Dynamic Island | Quick action buttons |
| **Background** | Automatic | Foreground service |

## 🧪 Testing on Emulator

### Android Emulator

```bash
# 1. Start emulator
flutter emulators --launch <emulator_name>

# 2. Run app
flutter run

# 3. Test timer
# - Start a workout with rest timer
# - Lock device (Power button in emulator)
# - See notification with timer countdown
# - Test Pause/Resume/Stop buttons
# - Unlock device and verify timer syncs

# 4. Test quick actions
# - Click Pause button in notification
# - Timer should pause in app
# - Click Resume button
# - Timer should resume
```

### What Works in Emulator

✅ Foreground service
✅ Persistent notification
✅ Progress bar updates
✅ Quick action buttons
✅ Background execution
✅ Lock screen notification

⚠️ Battery testing needs real device

## 🚀 Performance Optimization

### iOS vs Android Update Strategy

**iOS (Live Activities):**
```dart
// Updates every second when < 60s
// Updates every 5s when >= 60s (battery optimization)
Timer.periodic(Duration(seconds: 1), (timer) {
  if (remainingSeconds < 60) {
    updateLiveActivity(); // Every second
  } else if (timer.tick % 5 == 0) {
    updateLiveActivity(); // Every 5 seconds
  }
});
```

**Android (Foreground Service):**
```dart
// Update every second always
// No throttling needed - notification is lightweight
Timer.periodic(Duration(seconds: 1), (timer) {
  AndroidTimerService.updateTimer(
    remainingSeconds: remainingSeconds,
    isRunning: isRunning,
    currentSet: currentSet,
  );
});
```

## 🎨 Customization

### Custom Notification Icon

Replace the default icon in `TimerForegroundService.kt`:

```kotlin
val builder = NotificationCompat.Builder(this, CHANNEL_ID)
    .setSmallIcon(R.drawable.ic_timer) // Your custom icon
```

Add icon to: `android/app/src/main/res/drawable/ic_timer.xml`

### Custom Notification Style

```kotlin
// In TimerForegroundService.kt
builder.setStyle(
    androidx.media.app.NotificationCompat.MediaStyle()
        .setShowActionsInCompactView(0, 1) // Show both buttons
)
```

## 🐛 Troubleshooting

### Service Not Starting

**Issue:** Timer notification doesn't appear

**Solution:**
1. Check permission: `POST_NOTIFICATIONS` (Android 13+)
2. Check service in manifest
3. Check logs: `adb logcat | grep TimerForegroundService`

### Quick Actions Not Working

**Issue:** Pause/Stop buttons don't work

**Solution:**
1. Verify `onTimerAction` callback is set
2. Check broadcast receiver registration
3. Test with logs in `MainActivity.kt`

### Notification Disappears in Background

**Issue:** Notification dismissed when app goes to background

**Solution:**
1. Ensure `setOngoing(true)` in notification
2. Verify foreground service is started correctly
3. Check battery optimization settings on device

## 📚 Files Reference

- **Service:** `android/app/.../TimerForegroundService.kt`
- **Bridge:** `android/app/.../MainActivity.kt`
- **Dart Wrapper:** `lib/features/workout/data/services/android_timer_service.dart`
- **Manifest:** `android/app/src/main/AndroidManifest.xml`

## ✅ Checklist Before Testing

- [ ] Service declared in AndroidManifest.xml
- [ ] Permissions added (FOREGROUND_SERVICE, FOREGROUND_SERVICE_HEALTH)
- [ ] MethodChannel configured in MainActivity
- [ ] AndroidTimerService initialized in Flutter
- [ ] Timer coordinator updated for platform-specific calls
- [ ] Emulator or device ready

## 🎯 Next Steps

1. **Test on Emulator:** Verify basic functionality
2. **Test on Real Device:** Check battery impact and lock screen behavior
3. **Integrate with Coordinator:** Update UnifiedTimerCoordinator
4. **Add Analytics:** Track Android timer usage
5. **Iterate UI:** Improve notification design based on user feedback

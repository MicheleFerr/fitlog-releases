# Test Plan for Custom Notification Sounds

## Test Scenarios

### 1. App in Foreground
- Start a timer with custom sound (LightWeight.caf or YehBuddie.caf)
- Let timer complete while app is visible
- **Expected**: Custom sound plays immediately via AVAudioPlayer

### 2. App in Background (< 30 seconds)
- Start a timer with custom sound
- Put app in background (home button/swipe up)
- Wait for timer to complete within 30 seconds
- **Expected**: Custom sound plays via AVAudioPlayer or notification

### 3. App in Background (> 30 seconds) - CRITICAL TEST
- Start a timer with custom sound for 45+ seconds
- Put app in background immediately
- Lock the device
- Wait for timer to complete
- **Expected**: Notification appears with custom sound (LightWeight or YehBuddie)

### 4. App Terminated
- Start a timer with custom sound
- Force quit the app
- **Expected**: Timer should be cancelled (iOS limitation)

## Sound Files Status
- ✅ timer_complete.caf (15K, ima4 format)
- ✅ LightWeight.caf (42K, ima4 format)  
- ✅ YehBuddie.caf (40K, ima4 format)

## Key Implementation Points
1. **BackgroundAudioManager.swift**: Uses sound name WITHOUT .caf extension for notifications
2. **DirectNotificationManager.swift**: Bypasses flutter_local_notifications bug
3. **TimerSoundFix.swift**: Handles immediate playback with fallbacks
4. **UnifiedTimerCoordinator.swift**: Coordinates between Flutter and native iOS

## Console Logs to Watch
- "🔊 scheduleTimerNotification" - Notification being scheduled
- "📢 Custom sound file verified" - Sound file found
- "✅ Notification scheduled successfully" - Notification created
- "🎵 Playing timer completion sound" - Sound playback attempt
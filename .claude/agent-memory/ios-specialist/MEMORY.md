# iOS Specialist - Persistent Memory

## Project: FitLog Pro (GymBro Flutter)

## Key File Paths

- `ios/Runner/AppDelegate.swift` - App lifecycle, channel setup, manager initialization
- `ios/Runner/LiveActivityHandler.swift` - Live Activity start/update/end, notification scheduling
- `ios/Runner/Managers/UnifiedTimerCoordinator.swift` (747 lines) - Central Flutter channel handler
- `ios/Runner/Managers/BackgroundAudioManager.swift` (1699 lines) - Silent loop + dispatch timer audio
- `ios/Runner/Managers/AudioSessionManager.swift` (507 lines) - AVAudioSession state machine
- `ios/Runner/Managers/DirectNotificationManager.swift` (1075 lines) - Sole UNUserNotificationCenterDelegate
- `ios/Runner/Managers/TimerSoundFix.swift` (954 lines) - Pre-loaded AVAudioPlayer fallback
- `ios/GymBroTimerWidget/GymBroTimerAttributes.swift` - ActivityKit ContentState
- `ios/GymBroTimerWidget/GymBroTimerWidgetLiveActivity.swift` - Lock screen + Dynamic Island UI

## Platform Channel Names (from ChannelNames enum)

- `ChannelNames.unified` - UnifiedTimerCoordinator (main timer channel)
- `ChannelNames.liveActivity` - LiveActivityHandler
- `ChannelNames.notifications` - AppDelegate notification channel
- `ChannelNames.featureFlags` - Feature flag control

## Audio Architecture - 4 Completion Paths

Timer completion plays audio through 4 parallel paths (risk: double sound):

1. **Dispatch Timer (Path A)** - `BackgroundAudioManager.scheduleShortTimerAudio()` - `DispatchWorkItem` fires after `duration`, calls `playCompletionSound()` with AVAudioPlayer. Used for timers <= 600s.

2. **TimerSoundFix (Path B)** - Backup inside `playCompletionSound()`. Only called if AVAudioPlayer in Path A FAILS. Pre-loaded player in `TimerSoundFix.shared`. 5 strategies: preloaded AVAudioPlayer, fresh AVAudioPlayer, default sound, SystemSoundID, system alert.

3. **UNNotification (Path C)** - `scheduleBackupNotification()` in BackgroundAudioManager. Uses `DirectNotificationManager.scheduleTimerNotificationWithId()`. Sound file `.caf` in notification content. Fallback when app is killed.

4. **willPresent handler (Path D)** - `DirectNotificationManager.willPresent()`. Fires when notification arrives while app is foreground. Checks `wasAudioPlayedRecently(withinSeconds: 3.0)` FIRST. If audio already played: suppress notification sound (banner only). If not: calls `playNotificationAudio()` + vibrate. Does NOT pass `.sound` in `completionHandler`.

## Audio Mutex / Deduplication Pattern

```swift
// In BackgroundAudioManager.stateQueue.sync:
if let lastTimestamp = audioPlayedTimestamp {
    if Date().timeIntervalSince(lastTimestamp) < 2.0 { return false }
}
audioPlayedTimestamp = Date()  // Claim the execution slot immediately

// Cross-manager check in DirectNotificationManager.willPresent:
let audioAlreadyPlayed = BackgroundAudioManager.shared.wasAudioPlayedRecently(withinSeconds: 3.0)
// Also in UnifiedTimerCoordinator.handlePlayCompletionSound:
if backgroundAudio.wasAudioPlayedRecently(withinSeconds: 3.0) { return "skipped_primary_already_played" }
```

## AVAudioSession Configuration (CRITICAL)

**ALWAYS use `.mixWithOthers` ONLY. NEVER combine with `.duckOthers`** (causes OSStatus -50).

```swift
// Correct pattern used throughout codebase:
try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
// Do NOT deactivate before reconfiguring - causes error 561015905 in background
try? session.setActive(true)  // Use try? to tolerate already-active errors
```

**State machine**: `AudioSessionManager` has states: `uninitialized → foreground → background → transitioning`.

**Background activation timing**: Must be called in FOREGROUND. `BackgroundAudioManager.preactivateAudioSession()` is called when timer starts (before app goes background). iOS refuses new activation when already backgrounded.

## Silent Loop Strategy

- `silent_loop.caf` (0.01 volume, `numberOfLoops = -1`) keeps app process alive in background
- Started for ALL timers (removed 30s minimum threshold). Max duration: 600s (10 min)
- Retry mechanism: 3 attempts with different strategies, each after 0.5s delay
- **Critical**: Trust `play()` return value, NOT `isPlaying` (known iOS bug with silent/short files)
- Silent loop stops 0.5s before timer completion (via `completeSilentLoopSetup`) + auto-stop after full duration + 2s safety

## BackgroundTask (UIBackgroundTaskIdentifier)

Only started for timers < 30s (`useBackgroundTask = duration < 30`). Auto-terminated at 28s safety timer. For longer timers: silent loop keeps app alive instead.

BGTaskScheduler: `com.gymbro.timer.refresh` (BGAppRefreshTask) + `com.gymbro.timer.processing` (BGProcessingTask). Scheduled when app enters background.

## Live Activity Lifecycle (iOS 16.1+)

1. Flutter calls `startLiveActivity` → `UnifiedTimerCoordinator` → `LiveActivityHandler.startLiveActivityDirectly()`
2. Ends all existing activities first (`endAllActivities(keepCurrent: false)`) + 0.5s delay
3. Creates `Activity<GymBroTimerAttributes>.request()` with `startDate`/`endDate` for native iOS timer
4. Simultaneously calls `BackgroundAudioManager.scheduleTimerAudio(skipNotification: false)` for audio
5. Update: `activity.update(using:)` throttled to 3s intervals
6. End: `activity.end(..., dismissalPolicy: .immediate)`

**No Watch notification scheduled** (WATCH-FIX): Prevents "rest in progress" conflict. Flutter handles completion notification with proper localization.

## DirectNotificationManager - Sole Delegate

AppDelegate comment confirms: `DirectNotificationManager` is the SOLE `UNUserNotificationCenterDelegate`. `NotificationDelegate` in Managers/ is dead code (kept for compatibility). Do not re-register any other delegate.

## Skip / Race Condition Prevention

- `cancelAllTimerNotifications()` sets `isSkipInProgress = true` for 0.5s
- `resetSkipFlag()` called when new timer starts to allow new notifications
- `cancelAllPendingNotifications()` (no flag) used when replacing a notification immediately

## Sound Files in Bundle

```
sound.caf           - default/primary
timer_complete.caf  - alternative
LightWeight.caf/.wav
YehBuddie.caf/.wav
silent_loop.caf/.wav  - CRITICAL: silent background keep-alive
metronome_tick.caf  - TUT metronome
timer_complete_old.caf, LightWeight_old.caf, YehBuddie_old.caf  - obsolete
```

## Feature Flags (FeatureFlags.*)

- `useNewAudioManager` - AudioSessionManager vs legacy inline code
- `useNewBackgroundTaskManager` - BackgroundTaskManager vs legacy BGTaskScheduler
- `useOptimizedTimer` - optimized timer path

## Known Issues / Pitfalls

1. **Double sound**: Path A (dispatch timer) + Path D (willPresent) can both fire simultaneously. Fixed by `wasAudioPlayedRecently(withinSeconds:)` in both willPresent and handlePlayCompletionSound.

2. **OSStatus -50**: `.duckOthers + .mixWithOthers` are mutually exclusive. Use only `.mixWithOthers`.

3. **Error 561015905** (kAudioSessionAlreadyInitialized): Calling `setActive(false)` then `setActive(true)` in background fails. Solution: NEVER deactivate first, use `try? setActive(true)`.

4. **AVAudioPlayer dealloc**: Must store as `self.audioPlayer` (instance property), not local variable. `TimerSoundFix` uses `activePlayers: [AVAudioPlayer]` array to prevent ARC dealloc.

5. **Thread deadlock risk**: `AudioSessionManager.isAppInBackground` uses cached `_isAppInBackground` flag (from `currentState.didSet`) instead of `DispatchQueue.main.sync { UIApplication.shared.applicationState }` to avoid deadlock on background threads.

6. **Bluetooth A2DP**: Switching category options while BT A2DP is active causes PlayerRemoteXPC errors (-12860). Keep `.mixWithOthers` stable throughout.

7. **Live Activity visibility error**: iOS throttles activities. Handle "visibility" error with 1s retry. Fallback: timer still works, just no LA.

8. **isPlaying unreliable**: For silent/short audio files, `AVAudioPlayer.isPlaying` may return false even when playing. Trust `play()` return value.

## Notification Sound Rules

- Notifications use `.caf` format (with full filename e.g. `sound.caf`)
- Max 30 seconds / ~5MB for notification sounds
- `timeSensitive` interruption level bypasses Focus/DND for visual display
- Sound respects mute switch via notifications, but AVAudioPlayer with `.playback` + `.mixWithOthers` bypasses mute
- `verifyAudioFile()` checks file exists AND size before using custom sound

## Worker Queue Labels (for debugging)

```
com.gymbro.audio.state          - AudioSessionManager.stateQueue
com.gymbro.backgroundaudio.state - BackgroundAudioManager.stateQueue
com.gymbro.backgroundaudio.silentloop - silentLoopQueue (concurrent reader-writer)
com.gymbro.notification.tracking - DirectNotificationManager.trackingQueue
com.gymbro.liveactivity.state   - LiveActivityHandler.activityQueue
com.gymbro.timer.coordination   - UnifiedTimerCoordinator.coordinationQueue
com.gymbro.background.tasks     - BackgroundTaskManager.queue
```

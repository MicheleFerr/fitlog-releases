# 🔬 Timer Audio Investigation Plan

**Bug**: Timer audio intermittent (sometimes plays, sometimes doesn't, sometimes plays twice)
**Status**: Investigation phase (Option C)
**Created**: 2026-01-22
**Framework**: Systematic Debug - Phase 3

---

## 📋 Pre-Investigation Checklist

✅ Root cause analysis completed (5 Whys + Fishbone)
✅ Distributed tracing implemented with trace IDs
⏳ Device context collection (next step)
⏳ Reproduction with logs (next step)

---

## 🎯 Identified Root Causes

### Problem 1: Triple Audio Path Race Condition
**Paths competing simultaneously:**
1. **Silent loop + Dispatch timer** → AVAudioPlayer
2. **Smart notification** → System notification sound
3. **Live Activity** → iOS notification (when `skipNotification=true`)

**Evidence:**
- `scheduleTimerAudio()` line 129-139: Silent loop starts
- `scheduleTimerAudio()` line 148-163: Notification scheduled (if `!skipNotification`)
- `scheduleTimerAudio()` line 169-181: Dispatch timer scheduled
- All 3 can execute for same timer!

### Problem 2: Non-Thread-Safe Deduplication
**Location:** `BackgroundAudioManager.swift` line 427-432

```swift
// ❌ PROBLEM: No mutex protecting this check
if let lastTimestamp = audioPlayedTimestamp,
   Date().timeIntervalSince(lastTimestamp) < 2.0 {
    return  // Skip duplicate
}
audioPlayedTimestamp = Date()  // Race condition here!
```

**Race scenario:**
```
Thread A (AVAudioPlayer):   Check timestamp (nil) → pass → [interrupted]
Thread B (Notification):    Check timestamp (nil) → pass → set timestamp → play
Thread A (resumed):         set timestamp → play (DUPLICATE!)
```

### Problem 3: Cancel AFTER Play (Too Late!)
**Location:** `playCompletionSound()` line 486, 548

```swift
if audioPlayer?.play() == true {  // Play first
    // ...
    cancelAllTimerNotifications()  // Cancel AFTER (too late!)
}
```

**Problem:** Notification already fired before cancellation!

### Problem 4: Live Activity Not Synchronized
**Scenario:** When `skipNotification=true`, Live Activity sends notification, but `BackgroundAudioManager` doesn't know → AVAudioPlayer also plays → double sound

### Problem 5: Silent Loop Initialization Failure
**Problem:** If app backgrounds BEFORE silent loop starts, iOS blocks `AVAudioSession.setActive()` → silent loop fails → dispatch timer fails → no sound

---

## 🔬 Distributed Tracing Implementation

### How It Works

Each timer gets **unique trace ID** tracking all audio paths:

```
┌─ [trace-abc123]
│  Started: 14:30:00
│  Duration: 90s
│  Timeline:
│    [+0.0s] SILENT-LOOP → STARTED
│    [+0.1s] NOTIFICATION → SCHEDULED
│    [+0.2s] DISPATCH-TIMER → SCHEDULED
│    [+90.0s] DISPATCH-TIMER → COMPLETED
│    [+90.1s] DEDUPLICATION → COMPLETED (allow)
│    [+90.2s] AUDIO-PLAYER → PLAYED (AVAudioPlayer, background+silentLoop)
│    [+90.3s] NOTIFICATION → CANCELLED (AFTER_PLAY)  ⚠️ TOO LATE!
└─
```

### Trace Events Logged

| Path | Events | Metadata |
|------|--------|----------|
| **Silent Loop** | STARTED, COMPLETED, CANCELLED | loopDuration |
| **Dispatch Timer** | SCHEDULED, COMPLETED, CANCELLED | duration, appState |
| **Notification** | SCHEDULED, PLAYED, CANCELLED | sound, reason, timing |
| **Live Activity** | SCHEDULED | reason |
| **Audio Player** | PLAYED, SKIPPED | method, context, sound |
| **Deduplication** | COMPLETED (allow/block), BLOCKED | timeSinceLastPlay |

### Reading Traces

**In Xcode Console:**
```
🔬 [abc12345] [SILENT-LOOP] STARTED | loopDuration: 100.0
🔬 [abc12345] [NOTIFICATION] SCHEDULED | duration: 90.0, sound: sound
🔬 [abc12345] [DISPATCH-TIMER] SCHEDULED | duration: 90.0
🔬 [abc12345] [DISPATCH-TIMER] COMPLETED | appState: background
🔬 [abc12345] [DEDUPLICATION] COMPLETED | timeSinceLastPlay: -1, decision: allow
🔬 [abc12345] [AUDIO-PLAYER] PLAYED | method: AVAudioPlayer, context: background+silentLoop
🔬 [abc12345] [NOTIFICATION] CANCELLED | reason: AVAudioPlayer played successfully, timing: AFTER_PLAY

══════════════════════════════════════════════════════════
🎬 TRACE SUMMARY [abc12345]
══════════════════════════════════════════════════════════
Duration: 90.0s
Elapsed: 90.2s
Sound: sound
Skip notification: false
Final action: COMPLETED

Active paths: SILENT-LOOP, NOTIFICATION, DISPATCH-TIMER, AUDIO-PLAYER
Total events: 7
Audio played: 1 time(s)
Cancellations: 1

⚠️ WARNING: Notification cancelled AFTER audio play (race condition detected)
══════════════════════════════════════════════════════════
```

---

## 📱 Device Context Collection

### Required Information

Before testing, collect:

```bash
# Device info
Device Model: iPhone _____ (from Settings → General → About)
iOS Version: _____
App Version: _____ (from app settings)
Build Number: _____ (from Xcode or TestFlight)

# Environment
Network: WiFi / Cellular / Offline
Battery: ____%
Low Power Mode: Yes / No
Do Not Disturb: On / Off
Other audio apps running: _____ (Spotify, Podcasts, etc.)

# FitLog settings
Workout sound preference: sound / other
Notifications enabled: Yes / No
Live Activities enabled: Yes / No (iOS Settings → FitLog → Live Activities)
```

### Capturing Logs

**Method 1: Xcode Console (best detail)**
```bash
1. Connect iPhone via USB
2. Open Xcode → Window → Devices and Simulators
3. Select your device → Open Console
4. Filter: "FitLog" or "AudioSession"
5. Start test → Capture all output
6. Save to file: Right-click → Export
```

**Method 2: Mac Console App**
```bash
1. Connect iPhone via USB
2. Open Console.app (Mac)
3. Select device from sidebar
4. Filter: process:Runner subsystem:com.gymbro.tracklog
5. Start test → Capture
```

**Method 3: iOS Settings Logs** (if USB not available)
```bash
1. Settings → Privacy & Security → Analytics & Improvements
2. Analytics Data → Find recent crash or hang logs
3. Share via AirDrop or email
```

---

## 🧪 Reproduction Test Plan

### Test Matrix

Run each test 5 times, record results:

| Test # | Timer Duration | App State | Live Activity | Other Audio | Expected Result | Actual Result | Trace ID |
|--------|----------------|-----------|---------------|-------------|-----------------|---------------|----------|
| TC-1 | 30s | Foreground | Inactive | None | 1x sound | _____ | _____ |
| TC-2 | 90s | Background (locked) | Inactive | None | 1x sound | _____ | _____ |
| TC-3 | 90s | Background (locked) | **Active** | None | 1x sound | _____ | _____ |
| TC-4 | 30s | Foreground | **Active** | Spotify playing | 1x sound | _____ | _____ |
| TC-5 | 90s | Background | **Active** | Spotify playing | 1x sound | _____ | _____ |
| TC-6 | 10s | Foreground | Inactive | None | 1x sound | _____ | _____ |
| TC-7 | 10s → 10s | Foreground | Inactive | None (rapid) | 2x sound | _____ | _____ |
| TC-8 | 120s | Background (locked) | **Active** | None | 1x sound | _____ | _____ |

**Result codes:**
- ✅ 1x = Sound played once (correct)
- ❌ 0x = No sound (BUG!)
- ❌ 2x = Sound played twice (BUG!)
- ⚠️ ?x = Inconsistent/unclear

### Test Procedure (Detailed)

#### TC-1: Foreground Timer (30s, no Live Activity)

```bash
1. Fresh app launch
2. Start workout
3. Start 30s rest timer (Live Activity disabled)
4. Keep app OPEN and unlocked
5. Wait for timer completion
6. Observe:
   - Did sound play? (yes/no)
   - How many times? (1/2/0)
   - Any notification shown? (yes/no)
7. Check Xcode Console for trace summary
8. Record trace ID from logs
```

#### TC-2: Background Timer (90s, no Live Activity)

```bash
1. Fresh app launch
2. Start workout
3. Start 90s rest timer (Live Activity disabled)
4. Lock device immediately (< 5 seconds)
5. Wait for timer completion (keep screen locked)
6. Observe:
   - Did sound play? (check for audio + vibration)
   - How many times?
   - Notification shown on lock screen?
7. Unlock device → check Xcode Console
8. Record trace ID
```

#### TC-3: Background Timer WITH Live Activity (90s)

```bash
1. Enable Live Activities: Settings → FitLog → Live Activities → ON
2. Fresh app launch
3. Start workout
4. Start 90s rest timer (Live Activity should appear)
5. Verify Live Activity visible on lock screen
6. Lock device
7. Wait for timer completion
8. Observe:
   - Live Activity sound/notification?
   - AVAudioPlayer sound?
   - Total sounds heard?
9. Check trace for LIVE-ACTIVITY path
10. Record trace ID
```

#### TC-4: Foreground with Background Audio (30s + Spotify)

```bash
1. Start Spotify/Apple Music playback
2. Keep music playing
3. Launch FitLog (music should continue)
4. Start workout
5. Start 30s rest timer
6. Keep app open
7. Observe:
   - Did timer sound play?
   - Did music duck/pause/continue?
   - How many timer sounds?
8. Record trace ID
```

#### TC-7: Rapid Timer Succession (< 2 second gap)

```bash
1. Start workout
2. Start 10s timer #1
3. Wait for completion → sound plays
4. IMMEDIATELY start 10s timer #2 (< 1 second gap)
5. Wait for completion
6. Observe:
   - Did second timer play?
   - Was it blocked by deduplication?
7. Check trace for DEDUPLICATION → BLOCKED event
8. Record both trace IDs
```

---

## 📊 Expected Trace Patterns

### ✅ CORRECT (Single Play)

```
🔬 [trace-id] [SILENT-LOOP] STARTED
🔬 [trace-id] [DISPATCH-TIMER] SCHEDULED
🔬 [trace-id] [NOTIFICATION] SCHEDULED
🔬 [trace-id] [DISPATCH-TIMER] COMPLETED
🔬 [trace-id] [DEDUPLICATION] COMPLETED (allow)
🔬 [trace-id] [AUDIO-PLAYER] PLAYED
🔬 [trace-id] [NOTIFICATION] CANCELLED (AFTER_PLAY)

Summary:
- Audio played: 1 time ✅
- Cancellations: 1
```

### ❌ BUG: Double Play

```
🔬 [trace-id] [AUDIO-PLAYER] PLAYED (method: AVAudioPlayer)
🔬 [trace-id] [NOTIFICATION] CANCELLED (AFTER_PLAY)  ← Too late!
🔬 [trace-id] [NOTIFICATION] PLAYED (method: system)  ← Fired before cancel!

Summary:
- Audio played: 2 times ❌
- WARNING: Notification played after cancellation attempt
```

### ❌ BUG: No Play

```
🔬 [trace-id] [SILENT-LOOP] STARTED
🔬 [trace-id] [DISPATCH-TIMER] SCHEDULED
🔬 [trace-id] [DISPATCH-TIMER] CANCELLED (work item cancelled)
🔬 [trace-id] [NOTIFICATION] CANCELLED

Summary:
- Audio played: 0 times ❌
- WARNING: No audio playback detected
```

### ❌ BUG: Deduplication Block (Rapid Timers)

```
🔬 [trace-1] [AUDIO-PLAYER] PLAYED
🔬 [trace-2] [DEDUPLICATION] BLOCKED (timeSinceLastPlay: 0.5s)

Summary:
- Legitimate second timer blocked incorrectly ❌
- Deduplication threshold too aggressive (2 seconds)
```

---

## 🔍 Analysis Guidelines

### After Each Test

1. **Extract trace ID** from Xcode Console (format: `🆔 [TRACE-START] New trace: Trace ID: <uuid>`)

2. **Find trace summary** (search for `TRACE SUMMARY [<trace-id>]`)

3. **Check for warnings:**
   - ⚠️ Audio played X times (expected 1)
   - ⚠️ Audio did NOT play
   - ⚠️ X concurrent audio paths (expected 1-2)

4. **Analyze timeline** for race conditions:
   - NOTIFICATION cancelled AFTER audio played?
   - Multiple PLAYED events?
   - BLOCKED events when should play?

5. **Compare expected vs actual:**
   - Test matrix "Expected Result" vs "Actual Result"
   - Consistent pattern across 5 runs?

### Pattern Detection

**If sound plays TWICE:**
- Look for 2x `AUDIO-PLAYER → PLAYED` OR
- `AUDIO-PLAYER → PLAYED` + `NOTIFICATION → PLAYED`
- **Root cause**: Cancellation too late (AFTER_PLAY timing)

**If sound DOESN'T play:**
- Look for `DISPATCH-TIMER → CANCELLED` OR
- `DEDUPLICATION → BLOCKED` OR
- Missing `AUDIO-PLAYER → PLAYED`
- **Root cause**: Timer cancelled early OR deduplication false positive

**If sound plays SOMETIMES:**
- Compare successful vs failed traces
- Check app state differences (foreground vs background)
- Check `SILENT-LOOP` presence
- **Root cause**: Silent loop initialization race condition

---

## 📝 Reporting Results

### Format

```markdown
## Test Results Summary

**Device:** iPhone 14 Pro, iOS 17.2.1
**App Version:** 1.0.0 (build 42)
**Date:** 2026-01-22

### TC-1: Foreground Timer (30s)
- Runs: 5
- Success rate: 5/5 (100%) ✅
- Trace IDs: abc123, def456, ghi789, jkl012, mno345
- Notes: Consistent, no issues

### TC-2: Background Timer (90s)
- Runs: 5
- Success rate: 3/5 (60%) ⚠️
- Double play: 2/5 runs
- Trace IDs (failures): xyz789, uvw012
- Notes: Sound plays twice on lock screen 40% of time

### TC-3: Live Activity (90s)
- Runs: 5
- Success rate: 1/5 (20%) ❌
- Double play: 4/5 runs
- Trace IDs (failures): pqr345, stu678, vwx901, yza234
- Notes: CRITICAL - Live Activity + AVAudioPlayer both play

### Pattern Analysis
- Live Activity ALWAYS causes double play
- Background without Live Activity 60% reliable
- Foreground always works (100%)
- **Hypothesis confirmed:** Live Activity not synchronized with BackgroundAudioManager
```

### Next Steps Based on Results

**If 90%+ tests PASS:**
- Bug might be environmental (specific device, iOS version, etc.)
- Collect more device context
- Test on different devices

**If 50-90% tests FAIL:**
- Clear race condition confirmed
- Proceed with fix implementation (mutex + cancel-before-play)

**If 90%+ tests FAIL:**
- Critical systematic issue
- Re-analyze root cause (might have missed something)

---

## 🛠️ Diagnostic Commands (Manual Testing)

### Get Current Diagnostic Report

Add this to Flutter DevTools or Xcode:

```swift
// In BackgroundAudioManager
let report = BackgroundAudioManager.shared.getAudioDiagnosticReport()
print(report)
```

This prints:
```
════════════════════════════════════════════════════════════
📊 AUDIO TRACE DIAGNOSTIC REPORT
════════════════════════════════════════════════════════════

Active Traces: 2
History Size: 47 events
Time: 2026-01-22 14:45:00

🔴 ACTIVE TRACES:

┌─ [abc12345]
│  Started: 14:44:30
│  Duration: 90.0s
│  Elapsed: 30.0s
│  Remaining: 60.0s
│  Sound: sound
│  Skip notification: false
│  Events: 3
│  Timeline:
│    [+0.0s] SILENT-LOOP → STARTED
│    [+0.1s] NOTIFICATION → SCHEDULED
│    [+0.2s] DISPATCH-TIMER → SCHEDULED
└─

⚠️ DETECTED ISSUES:
  ⚠️ [abc12345] RACE: Silent loop + Notification both active

📜 RECENT HISTORY (last 10 events):
  [abc12345] SILENT-LOOP → STARTED at 14:44:30
  [abc12345] NOTIFICATION → SCHEDULED at 14:44:30
  ...
════════════════════════════════════════════════════════════
```

### Detect Race Conditions in Real-Time

```swift
let warnings = BackgroundAudioManager.shared.detectAudioRaceConditions()
for warning in warnings {
    print(warning)
}
```

Output:
```
⚠️ [abc12345] RACE: Silent loop + Notification both active
⚠️ [def67890] RACE: AVAudioPlayer + Notification both active
⚠️ [ghi01234] DUPLICATE: Audio played 2 times
```

---

## ⏭️ Next Phase: Fix Implementation

After completing investigation, choose fix strategy based on findings:

### Hotfix (if 50%+ success rate)
- Add mutex to deduplication check
- Cancel notifications BEFORE audio play
- Add emergency logging

### Structural Fix (if <50% success rate)
- Centralized AudioCoordinator
- State machine for audio paths
- Live Activity synchronization

---

## 📚 References

- **Systematic Debug Skill**: `.claude/commands/systematic-debug.md`
- **Root Cause Analysis**: `docs/debugging/TIMER_AUDIO_RCA.md` (to be created)
- **BackgroundAudioManager**: `ios/Runner/Managers/BackgroundAudioManager.swift`
- **AudioTraceLogger**: `ios/Runner/Managers/AudioTraceLogger.swift`
- **LiveActivityHandler**: `ios/Runner/LiveActivityHandler.swift`

---

**Status**: 🟡 Ready for testing
**Approval needed**: Device access + time for 8 test cases × 5 runs = 40 test runs (est. 2-3 hours)

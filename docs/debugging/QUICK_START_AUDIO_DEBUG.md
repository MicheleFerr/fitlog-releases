# ⚡ Quick Start: Timer Audio Debug

**Goal**: Reproduce and capture logs for intermittent timer audio bug
**Time needed**: 30 minutes
**Prerequisites**: iPhone with FitLog installed, Mac with Xcode

---

## 🚀 Step 1: Setup (5 minutes)

### A. Add AudioTraceLogger to Xcode Project

```bash
# In Terminal:
cd /Users/michele/gymbro_flutter_new

# Open Xcode project
open ios/Runner.xcworkspace
```

**In Xcode:**
1. Right-click on `Runner/Managers` folder
2. **Add Files to "Runner"...**
3. Select: `ios/Runner/Managers/AudioTraceLogger.swift`
4. ✅ Check: **Copy items if needed**
5. ✅ Check: **Add to targets: Runner**
6. Click **Add**

### B. Rebuild App

```bash
# In Xcode:
Product → Clean Build Folder (⇧⌘K)
Product → Build (⌘B)

# OR in Terminal:
cd ios
pod install
cd ..
flutter clean
flutter build ios
```

### C. Open Console for Logging

**Option 1: Xcode Console (best)**
```bash
# In Xcode:
Window → Devices and Simulators
Select your iPhone → Open Console
Filter: "AudioSession" or "TRACE"
```

**Option 2: Mac Console App**
```bash
# Open Console.app
Select your iPhone from sidebar
Filter: subsystem:com.gymbro.tracklog
```

---

## 🧪 Step 2: Run Quick Tests (10 minutes)

### Test A: Foreground Timer (Baseline - should ALWAYS work)

```bash
1. Launch FitLog on iPhone
2. Start any workout
3. Start 30s rest timer
4. Keep app OPEN
5. Wait for timer completion
6. Listen for sound

Expected: 1x sound ✅
```

**In Xcode Console, look for:**
```
🆔 [TRACE-START] New trace: Trace ID: <copy this UUID>
...
🔬 [abc12345] [AUDIO-PLAYER] PLAYED
...
🎬 TRACE SUMMARY [abc12345]
Audio played: 1 time(s) ✅
```

### Test B: Background Timer WITHOUT Live Activity (Bug Hunt)

```bash
1. Launch FitLog
2. Start workout
3. Disable Live Activities:
   - Settings → FitLog → Live Activities → OFF
4. Start 90s rest timer
5. LOCK DEVICE immediately (< 5 seconds)
6. Wait for timer completion
7. Count sounds heard

Expected: 1x sound
Actual: _____ sounds (record this!)
```

**In Console, check:**
```
🔬 [xyz98765] [SILENT-LOOP] STARTED
🔬 [xyz98765] [NOTIFICATION] SCHEDULED
🔬 [xyz98765] [AUDIO-PLAYER] PLAYED
🔬 [xyz98765] [NOTIFICATION] CANCELLED

⚠️ WARNING: Check if "CANCELLED" comes AFTER "PLAYED"!
```

### Test C: Background Timer WITH Live Activity (Critical Test)

```bash
1. Launch FitLog
2. Enable Live Activities:
   - Settings → FitLog → Live Activities → ON
3. Start workout
4. Start 90s rest timer
5. Verify Live Activity appears on lock screen
6. LOCK DEVICE
7. Wait for timer completion
8. Count sounds

Expected: 1x sound
Actual: _____ sounds (if 2x = BUG CONFIRMED! 🐛)
```

**In Console, look for:**
```
🔬 [pqr45678] [LIVE-ACTIVITY] SCHEDULED
🔬 [pqr45678] [AUDIO-PLAYER] PLAYED
🔬 [pqr45678] [NOTIFICATION] PLAYED  ← DUPLICATE!

⚠️ WARNING: Audio played 2 times (expected 1)
```

---

## 📸 Step 3: Capture Evidence (5 minutes)

### A. Export Console Logs

**In Xcode Console:**
```bash
1. Right-click in console window
2. Select "Export to File..."
3. Save as: timer_audio_logs_<date>.txt
4. Save to: ~/Desktop/fitlog_debug/
```

**In Mac Console.app:**
```bash
1. Click "Save" button (top right)
2. Save to: ~/Desktop/fitlog_debug/
```

### B. Record Test Results

Create file: `~/Desktop/fitlog_debug/test_results.md`

```markdown
## Quick Test Results

**Date:** 2026-01-22
**Device:** iPhone ____ (Settings → General → About)
**iOS:** _____
**App Version:** _____ (FitLog → Settings → About)

### Test A: Foreground (30s)
- Sound played: Yes / No
- Times: 1 / 2 / 0
- Trace ID: _____
- Result: ✅ PASS / ❌ FAIL

### Test B: Background No LA (90s)
- Sound played: Yes / No
- Times: 1 / 2 / 0
- Trace ID: _____
- Result: ✅ PASS / ❌ FAIL

### Test C: Background WITH LA (90s)
- Sound played: Yes / No
- Times: 1 / 2 / 0
- Trace ID: _____
- Result: ✅ PASS / ❌ FAIL
- **Bug confirmed?** YES / NO
```

---

## 📊 Step 4: Analyze (5 minutes)

### Check Trace Summaries

In your console logs, find all `TRACE SUMMARY` blocks:

```bash
# In Terminal:
grep -A 15 "TRACE SUMMARY" ~/Desktop/fitlog_debug/timer_audio_logs_*.txt
```

### Look for These Patterns

**✅ CORRECT (single play):**
```
Audio played: 1 time(s)
Cancellations: 1
```

**❌ DOUBLE PLAY BUG:**
```
Audio played: 2 time(s)  ← BUG!
WARNING: Audio played 2 times (expected 1)
```

**❌ NO SOUND BUG:**
```
Audio played: 0 times  ← BUG!
WARNING: Audio did NOT play
```

**⚠️ RACE CONDITION:**
```
Active paths: SILENT-LOOP, NOTIFICATION, LIVE-ACTIVITY  ← 3 paths!
WARNING: 3 concurrent audio paths (expected 1-2)
```

---

## 🎯 Step 5: Report Findings (5 minutes)

### If Bug Reproduced

Share these files:
1. `test_results.md` (your test results)
2. `timer_audio_logs_*.txt` (Xcode Console export)
3. Screenshot of trace summary showing "Audio played: 2 times"

### Quick Summary Template

```
Bug confirmed! 🐛

Test C (Live Activity + Background):
- Expected: 1x sound
- Actual: 2x sound
- Trace ID: abc12345-6789-0def

Pattern detected in logs:
- AUDIO-PLAYER PLAYED at +90.2s
- NOTIFICATION PLAYED at +90.5s
- Both fired! (race condition)

Root cause: Live Activity notification not synchronized with BackgroundAudioManager

Console logs attached.
```

---

## 🔧 Troubleshooting

### "AudioTraceLogger.swift not found" compile error

**Fix:**
```bash
# Verify file exists:
ls ios/Runner/Managers/AudioTraceLogger.swift

# If missing, it wasn't created properly
# Re-create from docs/debugging/TIMER_AUDIO_INVESTIGATION_PLAN.md
```

### "No logs in Xcode Console"

**Fix:**
```bash
# In Xcode Console filter box, clear all filters
# Type: "TrackLog" or "AudioSession"
# Make sure "All Messages" is selected (not "Errors only")
```

### "Can't reproduce the bug"

**Try these variations:**
```bash
# Variation 1: Start Spotify BEFORE timer
1. Play music on Spotify
2. Open FitLog (music continues)
3. Start timer
4. Lock device
5. Wait for completion

# Variation 2: Rapid timers (< 2 second gap)
1. Start 10s timer #1
2. Wait for completion
3. IMMEDIATELY start 10s timer #2 (< 1 second)
4. Does second timer play? Or blocked by deduplication?

# Variation 3: App backgrounded AFTER timer starts
1. Start 90s timer
2. Wait 5 seconds (silent loop should have started)
3. THEN lock device
4. Does this always work? Compare with locking immediately.
```

---

## 📚 Full Documentation

For comprehensive testing (40 test runs):
- **Full Plan**: `docs/debugging/TIMER_AUDIO_INVESTIGATION_PLAN.md`

For Root Cause Analysis details:
- **5 Whys + Fishbone**: See previous conversation summary

For Fix Implementation:
- **Systematic Debug Skill**: `.claude/commands/systematic-debug.md`

---

## ⏭️ Next Steps

**If bug confirmed (2x or 0x sound):**
1. Share evidence (logs + test results)
2. Decide: Hotfix (mutex + cancel-before-play) OR Structural fix (AudioCoordinator)
3. Implement fix
4. Re-test with same test plan
5. Deploy canary (10% users) → monitor

**If bug NOT reproduced:**
1. Environmental issue (specific device, iOS version, etc.)
2. Test on different devices
3. Check Firestore data differences
4. Monitor production logs for pattern

---

**Estimated time**: 30 minutes
**Output**: Test results + console logs proving/disproving bug
**Value**: Concrete evidence for fix decision 🎯

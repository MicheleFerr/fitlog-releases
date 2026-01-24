# ✅ Ready to Test - Timer Audio Debugging

**Status**: 🟢 Setup Complete
**Date**: 2026-01-22
**Mode**: Profile (recommended) or Release

---

## 🎯 What's Been Done

### ✅ Distributed Tracing Implemented
- **AudioTraceLogger.swift** created with unique trace IDs
- **BackgroundAudioManager.swift** instrumented with logging at all critical points
- **Xcode project** updated (AudioTraceLogger added to build)

### ✅ Scripts Created
1. **analyze_audio_traces.sh** - Automatic log analysis (Option B)
2. **add_audio_trace_logger.rb** - Ruby script for Xcode (backup)

### ✅ Documentation Complete
- **QUICK_START_AUDIO_DEBUG.md** - 30-minute quick tests
- **TIMER_AUDIO_INVESTIGATION_PLAN.md** - Full test matrix (40 tests)
- **READY_TO_TEST.md** - This file

---

## 🚀 How to Test (3 Options)

### Option 1: Quick Profile Mode Test (RECOMMENDED - 30 min)

```bash
# Build in profile mode (best for debugging + performance)
flutter run --profile --device-id=<your-iphone>

# Open Xcode Console to capture logs
open -a "Xcode"
# Window → Devices and Simulators → Select iPhone → Open Console
# Filter: "AudioSession" or "TRACE"

# Run quick tests from QUICK_START_AUDIO_DEBUG.md:
# - Test A: Foreground timer (30s)
# - Test B: Background timer NO Live Activity (90s)
# - Test C: Background timer WITH Live Activity (90s)

# Export logs when done:
# Right-click console → Export → Save to ~/Desktop/fitlog_debug/
```

### Option 2: Release Mode Test (Production-Like)

```bash
# Build release
flutter build ios --release
flutter install --device-id=<your-iphone>

# Logs will be less verbose but timer audio should work
# Check iOS Console.app for crash logs if bugs occur
```

### Option 3: Xcode Direct Build

```bash
cd ios
open Runner.xcworkspace

# In Xcode:
# 1. Select your iPhone device
# 2. Edit Scheme → Run → Build Configuration → Profile
# 3. Product → Run (⌘R)
# 4. Window → Devices and Simulators → Console (capture logs)
```

---

## 📊 Testing with Script Analyzer (Option B)

After running tests and exporting logs:

```bash
# Make script executable (if not already)
chmod +x scripts/analyze_audio_traces.sh

# Analyze exported logs
./scripts/analyze_audio_traces.sh ~/Desktop/fitlog_debug/timer_audio_logs_2026-01-22.txt

# Output:
# - Bug report (auto-detected double play, no sound, race conditions)
# - Trace summaries extracted
# - Timeline visualization
# - Per-trace logs
# - Success rate calculation
# - Recommended fix strategy

# View results
cat ~/Desktop/fitlog_debug/analysis_*/SUMMARY.md
```

**Expected Output:**
```
📊 AUDIO TRACE ANALYSIS SUMMARY

Results Overview:
Total traces: 3
Trace summaries found: 3
Double play bugs: 1  ← Test C: Live Activity
No sound bugs: 0
Race conditions: 1
Success rate: 66%

⚠️ Hotfix Recommended

Recommendations:
1. Add mutex to deduplication check
2. Cancel notifications BEFORE audio play
3. Add emergency logging
```

---

## 🔍 What to Look For in Logs

### ✅ CORRECT Pattern (Single Play)

```
🆔 [TRACE-START] New trace: Trace ID: abc12345...
🔬 [abc12345] [SILENT-LOOP] STARTED | loopDuration: 100.0
🔬 [abc12345] [NOTIFICATION] SCHEDULED | duration: 90.0
🔬 [abc12345] [DISPATCH-TIMER] SCHEDULED | duration: 90.0
... (90 seconds later) ...
🔬 [abc12345] [DISPATCH-TIMER] COMPLETED | appState: background
🔬 [abc12345] [DEDUPLICATION] COMPLETED | decision: allow
🔬 [abc12345] [AUDIO-PLAYER] PLAYED | method: AVAudioPlayer
🔬 [abc12345] [NOTIFICATION] CANCELLED | timing: AFTER_PLAY

🎬 TRACE SUMMARY [abc12345]
Audio played: 1 time(s) ✅
```

### ❌ BUG Pattern (Double Play)

```
🔬 [xyz98765] [LIVE-ACTIVITY] SCHEDULED
🔬 [xyz98765] [AUDIO-PLAYER] PLAYED | method: AVAudioPlayer
🔬 [xyz98765] [NOTIFICATION] CANCELLED | timing: AFTER_PLAY  ← Too late!
🔬 [xyz98765] [NOTIFICATION] PLAYED | method: system  ← DUPLICATE!

🎬 TRACE SUMMARY [xyz98765]
Audio played: 2 time(s) ❌
⚠️ WARNING: Audio played 2 times (expected 1)
```

### ❌ BUG Pattern (No Sound)

```
🔬 [pqr45678] [DISPATCH-TIMER] CANCELLED | reason: work item cancelled
🔬 [pqr45678] [NOTIFICATION] CANCELLED

🎬 TRACE SUMMARY [pqr45678]
Audio played: 0 times ❌
⚠️ WARNING: Audio did NOT play
```

---

## 🐛 Expected Bugs to Confirm

Based on root cause analysis, we expect:

| Test | Expected Result | Bug Pattern |
|------|-----------------|-------------|
| Test A (Foreground) | ✅ Always works | None |
| Test B (Background NO LA) | ⚠️ 60% success | Occasional double play |
| Test C (Background WITH LA) | ❌ Consistently fails | Double play (LA + AVAudioPlayer) |

**If these patterns appear → Root cause CONFIRMED → Proceed with fix**

---

## 📝 Reporting Results

### Quick Report Template

```markdown
## Test Results

**Device:** iPhone _____
**iOS:** _____
**Mode:** Profile / Release

### Test A: Foreground (30s)
- Result: ✅ / ❌
- Sounds heard: 1 / 2 / 0
- Trace ID: _____

### Test B: Background No LA (90s)
- Result: ✅ / ❌
- Sounds heard: 1 / 2 / 0
- Trace ID: _____

### Test C: Background WITH LA (90s)
- Result: ✅ / ❌
- Sounds heard: 1 / 2 / 0
- Trace ID: _____

### Bug Confirmed?
- Double play: YES / NO
- No sound: YES / NO
- Consistent pattern: YES / NO

### Next Steps
- Hotfix (if 50-90% fail)
- Structural fix (if >90% fail)
- More testing (if <50% fail or inconsistent)
```

---

## ⏭️ After Testing

### If Bugs Confirmed (Expected)

**Option A: Hotfix (1-2 hours)**
```swift
// 1. Add mutex to deduplication
private let deduplicationLock = NSLock()

// 2. Cancel BEFORE play (not after)
cancelAllTimerNotifications()  // Move before audioPlayer?.play()

// 3. Synchronize Live Activity
LiveActivityHandler.shared.notifyAudioWillPlay(traceId)
```

**Option B: Structural Fix (1-2 days)**
```swift
// Centralized AudioCoordinator
class AudioCoordinator {
    enum Strategy { case avPlayer, notification, liveActivity }
    func play(sound: String, strategy: Strategy, traceId: String) { ... }
}
```

### If No Bugs Found (Unlikely)

- Test on different devices (iPhone models, iOS versions)
- Check production logs for patterns
- Environmental issue (specific user contexts)

---

## 🛠️ Troubleshooting

### "AudioTraceLogger.swift not found" compile error

```bash
# Verify file exists
ls ios/Runner/Managers/AudioTraceLogger.swift

# If missing or project.pbxproj corrupted:
git checkout ios/Runner.xcodeproj/project.pbxproj.backup
open ios/Runner.xcworkspace
# Manually add file: Right-click Managers → Add Files → AudioTraceLogger.swift
```

### "No trace logs in console"

```bash
# Check filter in Xcode Console
# Should be: "AudioSession" or "TRACE" or "FitLog"
# NOT "Errors only" - must be "All Messages"

# Verify AudioTraceLogger is compiled:
# Xcode → Project Navigator → Managers → AudioTraceLogger.swift (should be listed)

# Clean and rebuild:
# Product → Clean Build Folder (⇧⌘K)
# Product → Build (⌘B)
```

### "Script permission denied"

```bash
chmod +x scripts/analyze_audio_traces.sh
./scripts/analyze_audio_traces.sh <log_file>
```

---

## 📚 Reference Docs

| Document | Purpose |
|----------|---------|
| **QUICK_START_AUDIO_DEBUG.md** | 30-min quick start guide |
| **TIMER_AUDIO_INVESTIGATION_PLAN.md** | Full 40-test matrix |
| **READY_TO_TEST.md** | This file (setup verification) |
| **.claude/commands/systematic-debug.md** | Complete debugging methodology |

---

## ⏱️ Time Estimates

- **Quick Test (3 tests)**: 30 minutes
- **Full Test Matrix (40 tests)**: 2-3 hours
- **Log Analysis (script)**: 2 minutes
- **Hotfix Implementation**: 1-2 hours
- **Structural Fix**: 1-2 days

---

## 🎯 Success Criteria

✅ **Investigation Complete When:**
- [ ] All 3 quick tests run (A, B, C)
- [ ] Logs exported with trace summaries
- [ ] Script analysis run (SUMMARY.md generated)
- [ ] Bug pattern confirmed or ruled out
- [ ] Fix strategy decided (hotfix vs structural)

✅ **Fix Complete When:**
- [ ] Success rate > 95% across all tests
- [ ] No double play bugs in 20 consecutive tests
- [ ] No silent failures in 20 consecutive tests
- [ ] Trace logs show single AUDIO-PLAYER → PLAYED per timer

---

**Status**: 🟢 Ready to test
**Next step**: Run `flutter run --profile` → Execute 3 quick tests → Analyze logs
**Estimated time to results**: 30 minutes

Good luck! 🚀

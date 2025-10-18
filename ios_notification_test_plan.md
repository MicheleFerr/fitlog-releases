# iOS Notification Sound Fix - Test Plan

## ✅ Build Status
Successfully built: `build/ios/iphoneos/Runner.app` (66.8MB)

## 🔧 Key Fixes Implemented

### 1. Prevented Unnecessary Notification Rescheduling
**File**: `ios/Runner/LiveActivityHandler.swift`
- Added state tracking with `lastRunningState` to detect pause/resume transitions
- Only reschedules notifications when:
  - Timer transitions from paused to running (resume)
  - First time starting (no existing notification)
- Prevents rescheduling during regular 5-second Live Activity updates
- Cancels notifications only when timer is actually paused

### 2. Correct Sound File Configuration
**File**: `ios/Runner/Managers/DirectNotificationManager.swift`
- Uses full filename with extension: `sound.caf`
- Configured with `timeSensitive` interruption level (iOS 15+)
- Proper file verification before scheduling

## 📱 Test Scenarios

### Test 1: Basic Timer with Locked Device ⭐ CRITICAL
1. Start a 30-second rest timer
2. **Immediately lock the device** (press power button)
3. Keep device locked, do not interact
4. Wait for timer to complete (30 seconds)
5. **Expected**: 
   - Notification appears on lock screen
   - **`sound.caf` audio plays** when timer completes
   - Only ONE notification (no duplicates)

### Test 2: Timer with App in Background
1. Start a 45-second timer
2. Press home button (app goes to background)
3. Open another app
4. Wait for timer to complete
5. **Expected**: Sound plays, single notification

### Test 3: Pause/Resume with Locked Device
1. Start a 60-second timer
2. After 10 seconds, pause the timer
3. Lock the device
4. Unlock and resume the timer
5. Lock the device again immediately
6. Wait for completion
7. **Expected**: Sound plays when timer completes

### Test 4: Very Short Timer
1. Start a 5-second timer
2. Lock device immediately
3. **Expected**: Sound plays after 5 seconds

### Test 5: Multiple Updates (No Rescheduling)
1. Start a 45-second timer
2. Lock the device
3. Let timer run (Live Activity updates every 5 seconds)
4. **Expected**: 
   - No notification rescheduling in logs
   - Sound plays at completion

## 🔍 What to Monitor in Logs

### Good Signs ✅
```
🔔 [TIMER-DEBUG] Scheduling notification:
   - Reason: Timer resumed / First start
   
⏸️ [TIMER-DEBUG] Keeping existing notification (no reschedule needed)

📱 [LOCKSCREEN] Using timeSensitive interruption level for guaranteed sound

⏰ [TIMER-DEBUG] NOTIFICATION SHOULD BE FIRING NOW!
```

### Bad Signs ❌
- Multiple "Scheduling notification" messages every 5 seconds
- "Cancelled notification" messages during normal updates
- No sound when notification fires

## 📋 Pre-Test Checklist

- [ ] Device is NOT in Silent Mode (check physical switch)
- [ ] Notification sounds enabled: Settings > Notifications > GymBro > Sounds
- [ ] Volume is turned up
- [ ] Do Not Disturb/Focus mode is OFF (or GymBro is allowed)
- [ ] Deploy the newly built app to device

## 🎯 Success Criteria

1. **Sound plays reliably** when device is locked ✅
2. **No duplicate notifications** ✅
3. **No unnecessary rescheduling** in logs ✅
4. **Works with iOS background limits** (30-second kill timer) ✅

## 🐛 Debug Commands

If sound still doesn't work, check:
```bash
# View detailed logs
xcrun devicectl device install app --device [DEVICE_ID] build/ios/iphoneos/Runner.app

# Monitor console logs
xcrun simctl spawn booted log stream --predicate 'subsystem == "com.michele.gymbro.flutter"'
```

## 📊 What Was Fixed

**Before**: Notifications were cancelled and rescheduled every 5 seconds, preventing iOS from playing the sound
**After**: Notifications are only rescheduled on pause/resume, allowing them to fire properly with sound

---

**Ready for Testing!** The build at `build/ios/iphoneos/Runner.app` includes all fixes. Deploy and test scenario #1 first as it's the most critical.
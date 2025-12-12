# WatchConnectivity Framework Setup Guide

## 🔧 Xcode Configuration Required

The WatchConnectivity framework needs to be manually linked in Xcode. Follow these steps:

## Step 1: Add WatchConnectivity Framework

1. **Open Xcode Project**
   ```bash
   open /Users/michele/gymbro_flutter_new/ios/Runner.xcworkspace
   ```

2. **Select Runner Target**
   - In Project Navigator (left sidebar), click on "Runner" (blue icon at top)
   - In the main editor, ensure "Runner" target is selected (not "RunnerTests")

3. **Add Framework**
   - Click on "Frameworks, Libraries, and Embedded Content" section
   - Click the "+" button below the list
   - In the dialog, search for "WatchConnectivity.framework"
   - Select it and click "Add"
   - Ensure "Do Not Embed" is selected (it's a system framework)

## Step 2: Verify Build Settings

### Check Framework Search Paths
- Select Runner target → Build Settings tab
- Search for "Framework Search Paths"
- Should include: `$(inherited) $(PROJECT_DIR)/Flutter`

### Check Linker Flags
- Search for "Other Linker Flags"
- Should include: `$(inherited) -framework Flutter`

## Step 3: Build and Test

### Clean Build
```bash
cd /Users/michele/gymbro_flutter_new/ios
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
xcodebuild clean -workspace Runner.xcworkspace -scheme Runner
```

### Build for Device
```bash
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  build
```

### Expected Output
You should see:
```
** BUILD SUCCEEDED **
```

## Step 4: Verify Implementation

### Check Import Statement
The import should work without errors:
```swift
import WatchConnectivity  // Should compile without errors
```

### Test Framework Availability
Add this to any Swift file temporarily:
```swift
#if DEBUG
print("WatchConnectivity supported: \(WCSession.isSupported())")
#endif
```

## Alternative: Manual Framework Linking (If Step 1 Fails)

If the automatic method doesn't work:

1. **Build Phases**
   - Select Runner target → Build Phases tab
   - Expand "Link Binary With Libraries"
   - Click "+" button
   - Search and add "WatchConnectivity.framework"

2. **Verify**
   - Framework should appear with "Required" status
   - No red errors in the list

## Troubleshooting

### Error: "No such module 'WatchConnectivity'"

**Solution 1: Clean Derived Data**
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
```

**Solution 2: Reset Package Caches**
```bash
cd ios
pod deintegrate
pod install
```

**Solution 3: Check Deployment Target**
- WatchConnectivity requires iOS 9.0+
- Runner target → General → Deployment Info
- Ensure "iOS Deployment Target" is 9.0 or higher

### Error: "Framework not found WatchConnectivity"

This usually means the framework isn't properly linked. Repeat Step 1 carefully.

### Build Succeeds but Runtime Error

Check that WCSession.isSupported() returns true:
```swift
if WCSession.isSupported() {
    // Safe to use WatchConnectivity
} else {
    print("WatchConnectivity not supported on this device")
}
```

## Post-Setup Verification Checklist

- [ ] Project builds without errors
- [ ] No "module not found" warnings
- [ ] WatchConnectivityManager.swift compiles
- [ ] App launches without crashes
- [ ] Console shows: "WatchConnectivity session activated" (if Watch paired)

## Flutter Integration (Next Step)

After Xcode setup is complete, implement the Flutter side:

```dart
// lib/features/watch/data/services/watch_connectivity_service.dart
import 'package:flutter/services.dart';

class WatchConnectivityService {
  static const _channel = MethodChannel('com.gymbro/watch_connectivity');

  Future<bool> isWatchPaired() async {
    try {
      return await _channel.invokeMethod<bool>('isWatchPaired') ?? false;
    } catch (e) {
      print('Error checking watch paired: $e');
      return false;
    }
  }

  // ... implement other methods
}
```

## Testing on Physical Device

**IMPORTANT**: WatchConnectivity ONLY works on physical devices!

1. **Connect iPhone**
   - USB cable required
   - Trust computer if prompted

2. **Pair Apple Watch**
   - Use Watch app on iPhone
   - Ensure Watch is on wrist and unlocked

3. **Run App**
   ```bash
   flutter run -d <device-id>
   ```

4. **Check Console**
   Look for:
   ```
   ✅ WCSession activated: 2
   Watch paired: true
   Watch app installed: false  # Expected until Watch app is built
   ```

## Watch App Setup (Future)

After iPhone bridge is working:
1. Create watchOS target in Xcode
2. Implement ConnectivityManager on Watch side
3. Configure entitlements for both targets
4. Test bidirectional messaging

See: `/docs/plans/WATCH_COMPANION_APP_PLAN.md` for Watch app implementation.

---

**Status**: 🟡 Framework Linking Required
**Next Action**: Open Xcode and follow Step 1-3
**Documentation**: See WATCH_CONNECTIVITY_IMPLEMENTATION.md for API details

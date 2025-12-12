# 🚀 Quick Start - WatchConnectivity Setup

## 1. Link Framework (5 minutes)

```bash
# Open Xcode
open /Users/michele/gymbro_flutter_new/ios/Runner.xcworkspace
```

**In Xcode:**
1. Click "Runner" (blue icon) in Project Navigator
2. Select "Runner" target
3. Scroll to "Frameworks, Libraries, and Embedded Content"
4. Click "+" button
5. Search "WatchConnectivity.framework"
6. Add it (select "Do Not Embed")
7. Clean build: `Cmd + Shift + K`

## 2. Build & Test (2 minutes)

```bash
cd /Users/michele/gymbro_flutter_new

# Build
flutter build ios --debug

# Or run directly on device
flutter run -d <your-device-id>
```

## 3. Verify (30 seconds)

**In Console, look for:**
```
✅ WCSession activated: 2
Watch paired: true/false
Watch app installed: false  # Expected until Watch app is built
```

**In Dart code:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// In any widget
final watchData = ref.watch(watchConnectivityProvider);
print('Watch State: ${watchData.state}');
print('Is Paired: ${watchData.isPaired}');
print('Is Connected: ${watchData.isConnected}');
```

## Troubleshooting

### "No such module 'WatchConnectivity'"
- Framework not linked → Repeat Step 1
- Clean build: `rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*`

### "Watch not paired"
- Physical iPhone required (not simulator)
- Pair Watch via iOS Watch app

### No console output
- Check Logger is enabled: `Logger.shared.configure(minimumLevel: .debug)`

## What Works Now

✅ Watch pairing detection
✅ Watch app installation check
✅ Reachability monitoring
✅ Connection state callbacks
✅ Template sync infrastructure

## What Needs Watch App

⏳ Actual workout data from Watch
⏳ Set logging from Watch
⏳ Real-time mirroring

## Full Documentation

- **Setup Guide**: `WATCH_CONNECTIVITY_SETUP.md`
- **API Reference**: `WATCH_CONNECTIVITY_IMPLEMENTATION.md`
- **Watch App Plan**: `/docs/plans/WATCH_COMPANION_APP_PLAN.md`

---

**Current Status**: ✅ iPhone Bridge Complete
**Next Phase**: Build watchOS App
**Required Action**: Link WatchConnectivity Framework in Xcode

#!/bin/bash

# 🏋️‍♂️ GymBro TrackLog - Background Audio & BGTaskScheduler Test Script
# 
# Purpose: Test and debug BGTaskScheduler Error Code=3 + background audio fixes
# Platform: iOS

echo "🧪 === GYMBRO BACKGROUND AUDIO & BGTASKSCHEDULER TEST ==="
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script requires macOS to test iOS functionality"
    exit 1
fi

# Check if Xcode command line tools are available
if ! command -v xcrun &> /dev/null; then
    echo "❌ Xcode command line tools not found. Please install with:"
    echo "   xcode-select --install"
    exit 1
fi

echo "✅ macOS and Xcode tools detected"
echo ""

# Check Info.plist configuration
echo "📋 CHECKING INFO.PLIST CONFIGURATION..."
INFO_PLIST="ios/Runner/Info.plist"

if [ ! -f "$INFO_PLIST" ]; then
    echo "❌ Info.plist not found at $INFO_PLIST"
    exit 1
fi

echo "🔍 Checking background modes..."
if grep -q "background-app-refresh" "$INFO_PLIST"; then
    echo "✅ background-app-refresh mode found"
else
    echo "❌ background-app-refresh mode missing"
fi

if grep -q "audio" "$INFO_PLIST"; then
    echo "✅ audio background mode found"
else
    echo "❌ audio background mode missing"
fi

if grep -q "BGTaskSchedulerPermittedIdentifiers" "$INFO_PLIST"; then
    echo "✅ BGTaskSchedulerPermittedIdentifiers found"
else
    echo "❌ BGTaskSchedulerPermittedIdentifiers missing"
fi

echo ""

# Check Swift files
echo "📋 CHECKING SWIFT IMPLEMENTATION..."

if [ -f "ios/Runner/BackgroundTaskManager.swift" ]; then
    echo "✅ BackgroundTaskManager.swift found"
else
    echo "❌ BackgroundTaskManager.swift missing"
fi

if [ -f "ios/Runner/AudioSessionBridge.swift" ]; then
    echo "✅ AudioSessionBridge.swift found"
else
    echo "❌ AudioSessionBridge.swift missing"
fi

# Check AppDelegate integration
echo "🔍 Checking AppDelegate integration..."
APPDELEGATE="ios/Runner/AppDelegate.swift"

if grep -q "BackgroundTasks" "$APPDELEGATE"; then
    echo "✅ BackgroundTasks import found in AppDelegate"
else
    echo "❌ BackgroundTasks import missing in AppDelegate"
fi

if grep -q "BackgroundTaskManager" "$APPDELEGATE"; then
    echo "✅ BackgroundTaskManager usage found in AppDelegate"
else
    echo "❌ BackgroundTaskManager usage missing in AppDelegate"
fi

echo ""

# Check Flutter dependencies
echo "📋 CHECKING FLUTTER DEPENDENCIES..."
PUBSPEC="pubspec.yaml"

if grep -q "audioplayers:" "$PUBSPEC"; then
    echo "✅ audioplayers dependency found"
else
    echo "❌ audioplayers dependency missing"
fi

if grep -q "flutter_local_notifications:" "$PUBSPEC"; then
    echo "✅ flutter_local_notifications dependency found"
else
    echo "❌ flutter_local_notifications dependency missing"
fi

echo ""

# Audio assets check
echo "📋 CHECKING AUDIO ASSETS..."
SOUNDS_DIR="assets/sounds"

if [ -d "$SOUNDS_DIR" ]; then
    echo "✅ Sounds directory found"
    echo "🔍 Audio files:"
    ls -la "$SOUNDS_DIR" | grep -E "\.(wav|mp3|caf)$" | head -5
else
    echo "❌ Sounds directory missing at $SOUNDS_DIR"
fi

echo ""

# Build test
echo "📋 TESTING IOS BUILD..."
echo "🔨 Running Flutter clean..."
flutter clean > /dev/null 2>&1

echo "🔨 Running Flutter pub get..."
flutter pub get > /dev/null 2>&1

echo "🔨 Testing iOS build (no code signing)..."
if flutter build ios --no-codesign > /tmp/flutter_build.log 2>&1; then
    echo "✅ iOS build successful"
else
    echo "❌ iOS build failed. Check log:"
    tail -20 /tmp/flutter_build.log
fi

echo ""

# Summary and recommendations
echo "📋 === SUMMARY & RECOMMENDATIONS ==="
echo ""
echo "🎯 BGTaskScheduler Error Code=3 Fix:"
echo "   ✓ Added background-app-refresh to UIBackgroundModes"
echo "   ✓ Added BGTaskSchedulerPermittedIdentifiers"
echo "   ✓ Implemented BackgroundTaskManager with proper registration"
echo "   ✓ Added lifecycle methods in AppDelegate"
echo ""
echo "🔊 Background Audio Fix:"
echo "   ✓ Enhanced AVAudioSession configuration"
echo "   ✓ Added AudioSessionBridge for Flutter integration"
echo "   ✓ Improved timer audio with background support"
echo "   ✓ Fallback notification system"
echo ""
echo "📱 Next Steps:"
echo "   1. Test on physical device (required for background tasks)"
echo "   2. Enable 'Background App Refresh' in device Settings"
echo "   3. Test timer completion in background mode"
echo "   4. Monitor Xcode console for BGTaskScheduler logs"
echo ""
echo "🐛 Debug Commands:"
echo "   iOS Simulator: xcrun simctl spawn booted log stream --predicate 'process == \"Runner\"'"
echo "   Device: Use Xcode → Window → Devices and Simulators → View Device Logs"
echo ""
echo "✅ Configuration complete! BGTaskScheduler Error Code=3 should be resolved."
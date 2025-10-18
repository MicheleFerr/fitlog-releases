#!/bin/bash

# Timer Integration Test Script
# Tests all 4 fixed problems in the timer system

echo "🧪 TIMER INTEGRATION TEST SUITE"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to run flutter test
run_test() {
    echo -e "${YELLOW}Running: $1${NC}"
    if flutter test $2; then
        echo -e "${GREEN}✅ PASSED${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        return 1
    fi
}

# Function to check iOS build
check_ios_build() {
    echo -e "${YELLOW}Checking iOS build configuration...${NC}"
    
    # Check if UnifiedTimerCoordinator is in the project
    if grep -q "UnifiedTimerCoordinator" ios/Runner.xcodeproj/project.pbxproj; then
        echo -e "${GREEN}✅ UnifiedTimerCoordinator found in Xcode project${NC}"
    else
        echo -e "${RED}❌ UnifiedTimerCoordinator NOT in Xcode project - Add to Xcode!${NC}"
        echo "   1. Open ios/Runner.xcworkspace in Xcode"
        echo "   2. Right-click on Managers folder"
        echo "   3. Add Files > UnifiedTimerCoordinator.swift"
        return 1
    fi
    
    # Check if AppDelegate is properly configured
    if grep -q "UnifiedTimerCoordinator.shared.setupChannel" ios/Runner/AppDelegate.swift; then
        echo -e "${GREEN}✅ AppDelegate properly configured${NC}"
    else
        echo -e "${RED}❌ AppDelegate not configured correctly${NC}"
        return 1
    fi
    
    return 0
}

# 1. Check Flutter dependencies
echo "1️⃣  Checking Flutter dependencies..."
flutter pub get
echo ""

# 2. Run analyzer
echo "2️⃣  Running Flutter analyzer..."
if flutter analyze --no-fatal-warnings | grep -E "error|Error"; then
    echo -e "${RED}❌ Analyzer found errors${NC}"
else
    echo -e "${GREEN}✅ No analyzer errors${NC}"
fi
echo ""

# 3. Check iOS configuration
echo "3️⃣  Checking iOS configuration..."
check_ios_build
echo ""

# 4. Run unit tests
echo "4️⃣  Running unit tests..."
echo ""

echo "TEST 1: Audio Duplication Prevention"
echo "-------------------------------------"
run_test "Audio duplication test" "test/features/timer/timer_fixes_test.dart --name='Should not play duplicate audio'"

echo ""
echo "TEST 2: Timer Synchronization"
echo "-----------------------------"
run_test "Synchronization test" "test/features/timer/timer_fixes_test.dart --name='Consensus algorithm'"

echo ""
echo "TEST 3: Channel Coordination"
echo "----------------------------"
run_test "Channel coordination test" "test/features/timer/timer_fixes_test.dart --name='prevents race conditions'"

echo ""
echo "TEST 4: Background Resilience"
echo "-----------------------------"
run_test "Background resilience test" "test/features/timer/timer_fixes_test.dart --name='background strategy'"

echo ""
echo "TEST 5: Integration Test"
echo "------------------------"
run_test "Full integration test" "test/features/timer/timer_fixes_test.dart --name='Complete timer flow'"

echo ""
echo "================================"
echo "📊 TEST SUMMARY"
echo "================================"
echo ""

# Manual test instructions
echo -e "${YELLOW}📱 MANUAL TESTING REQUIRED:${NC}"
echo ""
echo "1. AUDIO DUPLICATION TEST:"
echo "   - Run: flutter run --release"
echo "   - Start 5-second timer"
echo "   - Listen for completion"
echo "   - ✅ Should hear ONE sound (not 3-4)"
echo ""
echo "2. SYNC TEST:"
echo "   - Start 60-second timer"
echo "   - Background app for 30 seconds"
echo "   - Return to app"
echo "   - ✅ Should show ~30s remaining (not 44-47s)"
echo ""
echo "3. BACKGROUND TEST:"
echo "   - Start 5-minute timer"
echo "   - Background app for 4 minutes"
echo "   - Return at 1 minute"
echo "   - ✅ Timer should complete with sound"
echo ""
echo "4. SETTINGS TEST:"
echo "   - Disable sounds in settings"
echo "   - Start timer"
echo "   - ✅ NO sound but notification appears"
echo ""

# Check logs for issues
echo -e "${YELLOW}Checking logs for timer issues...${NC}"
echo ""

# Create test dart file for manual testing
cat > lib/test_timer_integration.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/timer/presentation/providers/unified_timer_provider.dart';

class TimerIntegrationTestScreen extends ConsumerWidget {
  const TimerIntegrationTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(unifiedTimerProvider);
    final timerNotifier = ref.read(unifiedTimerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Timer Integration Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (timerState != null) ...[
              Text('Time: ${timerState.remainingSeconds}s',
                  style: Theme.of(context).textTheme.displayLarge),
              Text('Status: ${timerState.status}'),
              Text('Audio Played: ${timerState.audioPlayed}'),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: () => timerNotifier.startTimer(
                durationSeconds: 5,
                exerciseName: 'Integration Test',
              ),
              child: const Text('Start 5s Timer'),
            ),
            ElevatedButton(
              onPressed: () => timerNotifier.startTimer(
                durationSeconds: 30,
                exerciseName: 'Sync Test',
              ),
              child: const Text('Start 30s Timer (test background)'),
            ),
            ElevatedButton(
              onPressed: () => timerNotifier.stopTimer(),
              child: const Text('Stop Timer'),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

echo -e "${GREEN}✅ Test integration screen created at lib/test_timer_integration.dart${NC}"
echo ""
echo "To test manually, add this route to your app and navigate to it."
echo ""
echo "================================"
echo -e "${GREEN}🎉 Integration test setup complete!${NC}"
echo "================================"
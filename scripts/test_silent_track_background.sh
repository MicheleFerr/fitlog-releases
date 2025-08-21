#!/bin/bash

# 🧪 GymBro Silent Track Background Audio Testing Script
# 
# Tests the new silent track + completion audio system for iOS background functionality
# 
# REQUIREMENTS:
# - iOS device connected and configured for development
# - Flutter development environment setup
# - GymBro app installed in debug mode

set -e

echo "🧪 ========================================"
echo "🧪 GYMBRO SILENT TRACK BACKGROUND TEST"
echo "🧪 ========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TEST_DURATION=30  # Test timer duration in seconds
APP_BUNDLE_ID="com.gymbro.tracklog"
DEVICE_TYPE="device"  # Change to "simulator" if needed

echo "📋 TEST CONFIGURATION:"
echo "   Timer Duration: ${TEST_DURATION}s"
echo "   App Bundle ID: ${APP_BUNDLE_ID}"
echo "   Target: ${DEVICE_TYPE}"
echo ""

# Step 1: Verify Flutter and device connection
echo -e "${BLUE}🔍 STEP 1: Environment Verification${NC}"
echo -n "   Checking Flutter installation... "
if command -v flutter &> /dev/null; then
    echo -e "${GREEN}✅ Found${NC}"
else
    echo -e "${RED}❌ Flutter not found${NC}"
    exit 1
fi

echo -n "   Checking connected devices... "
DEVICE_COUNT=$(flutter devices --machine | jq length 2>/dev/null || echo "0")
if [ "$DEVICE_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ ${DEVICE_COUNT} device(s) connected${NC}"
    flutter devices
else
    echo -e "${RED}❌ No devices connected${NC}"
    exit 1
fi
echo ""

# Step 2: Build and deploy app in release mode for background testing
echo -e "${BLUE}🔧 STEP 2: Building Release Version for Background Testing${NC}"
echo "   Building iOS release version..."
echo "   Note: Background audio requires release build to function properly"

if [ "$DEVICE_TYPE" = "device" ]; then
    flutter build ios --no-codesign --release
    echo -e "${GREEN}✅ Release build completed${NC}"
else
    echo -e "${YELLOW}⚠️ Using debug build on simulator (limited background capabilities)${NC}"
fi
echo ""

# Step 3: Install and launch app
echo -e "${BLUE}📱 STEP 3: App Installation and Launch${NC}"
echo "   Installing app on device..."

if [ "$DEVICE_TYPE" = "device" ]; then
    # For physical device
    echo "   NOTE: Manual installation required for release builds"
    echo "   Please install the app via Xcode or your preferred method"
    echo "   Press ENTER when the app is installed and ready..."
    read -r
else
    # For simulator
    flutter run --release -d ios &
    FLUTTER_PID=$!
    sleep 10  # Wait for app to launch
fi

echo -e "${GREEN}✅ App should be running${NC}"
echo ""

# Step 4: Guided background audio test
echo -e "${BLUE}🧪 STEP 4: Background Audio Test Protocol${NC}"
echo ""
echo "📋 TEST PROTOCOL - Please follow these steps:"
echo ""
echo "1️⃣  START TIMER:"
echo "   - Open GymBro app"
echo "   - Start a rest timer (${TEST_DURATION}s recommended)"
echo "   - Confirm timer is running and showing countdown"
echo ""
echo "2️⃣  ENTER BACKGROUND:"
echo "   - Press home button (or swipe up) to put app in background"
echo "   - Verify Live Activity shows timer continuing"
echo "   - Wait for timer completion while app is backgrounded"
echo ""
echo "3️⃣  OBSERVE BEHAVIOR:"
echo "   - Listen for completion audio (should play even in background)"
echo "   - Check Live Activity for completion indication"
echo "   - Note any notifications received"
echo ""
echo "4️⃣  RETURN TO FOREGROUND:"
echo "   - Return to GymBro app"
echo "   - Verify app state matches Live Activity"
echo "   - Check for any sync issues"
echo ""

echo -e "${YELLOW}⏰ Starting ${TEST_DURATION}s countdown for test completion...${NC}"
echo ""

# Countdown for test duration
for ((i=TEST_DURATION; i>=1; i--)); do
    echo -ne "\r   ⏰ Test time remaining: ${i}s  "
    sleep 1
done
echo ""
echo ""

# Step 5: Verification checklist
echo -e "${BLUE}✅ STEP 5: Test Results Verification${NC}"
echo ""
echo "Please confirm the following test results:"
echo ""

# Function to ask yes/no question
ask_test_result() {
    local question="$1"
    local result_var="$2"
    
    while true; do
        echo -n "   $question (y/n): "
        read -r answer
        case $answer in
            [Yy]* ) 
                eval "$result_var=true"
                echo -e "     ${GREEN}✅ PASS${NC}"
                break
                ;;
            [Nn]* ) 
                eval "$result_var=false"
                echo -e "     ${RED}❌ FAIL${NC}"
                break
                ;;
            * ) 
                echo "     Please answer yes (y) or no (n)."
                ;;
        esac
    done
}

# Test result variables
silent_audio_result=false
completion_audio_result=false
live_activity_result=false
notification_result=false
sync_result=false

echo "🔍 SILENT TRACK SYSTEM TESTS:"
ask_test_result "Did the timer continue running in background?" silent_audio_result
ask_test_result "Did completion audio play while app was backgrounded?" completion_audio_result
ask_test_result "Did Live Activity show correct timer state?" live_activity_result
ask_test_result "Did you receive completion notification?" notification_result
ask_test_result "Did app sync properly when returning to foreground?" sync_result

echo ""

# Calculate test score
total_tests=5
passed_tests=0

[ "$silent_audio_result" = true ] && ((passed_tests++))
[ "$completion_audio_result" = true ] && ((passed_tests++))
[ "$live_activity_result" = true ] && ((passed_tests++))
[ "$notification_result" = true ] && ((passed_tests++))
[ "$sync_result" = true ] && ((passed_tests++))

echo -e "${BLUE}📊 TEST RESULTS SUMMARY${NC}"
echo "================================"
echo "   Total tests: $total_tests"
echo "   Passed: $passed_tests"
echo "   Failed: $((total_tests - passed_tests))"
echo "   Success rate: $((passed_tests * 100 / total_tests))%"
echo ""

if [ $passed_tests -eq $total_tests ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED! Silent track system is working correctly.${NC}"
    test_status="SUCCESS"
elif [ $passed_tests -ge 3 ]; then
    echo -e "${YELLOW}⚠️ PARTIAL SUCCESS: Silent track system mostly working, some issues detected.${NC}"
    test_status="PARTIAL"
else
    echo -e "${RED}❌ MULTIPLE FAILURES: Silent track system needs debugging.${NC}"
    test_status="FAILURE"
fi

echo ""

# Step 6: Detailed diagnosis if needed
if [ "$test_status" != "SUCCESS" ]; then
    echo -e "${BLUE}🔧 STEP 6: Failure Diagnosis and Recommendations${NC}"
    echo ""
    
    if [ "$silent_audio_result" = false ]; then
        echo -e "${RED}❌ Timer stopped in background${NC}"
        echo "   Possible causes:"
        echo "   - Background App Refresh disabled"
        echo "   - Silent audio track not playing properly"
        echo "   - AVAudioSession configuration issue"
        echo "   Recommendation: Check iOS Settings > GymBro > Background App Refresh"
        echo ""
    fi
    
    if [ "$completion_audio_result" = false ]; then
        echo -e "${RED}❌ Completion audio not playing in background${NC}"
        echo "   Possible causes:"
        echo "   - Audio session interrupted"
        echo "   - Silent track system not maintaining background execution"
        echo "   - Audio file loading issue"
        echo "   Recommendation: Check device Console logs for audio errors"
        echo ""
    fi
    
    if [ "$live_activity_result" = false ]; then
        echo -e "${RED}❌ Live Activity not updating correctly${NC}"
        echo "   Possible causes:"
        echo "   - Live Activities disabled in settings"
        echo "   - Timer state sync issue"
        echo "   - Widget extension problems"
        echo "   Recommendation: Check iOS Settings > GymBro > Live Activities"
        echo ""
    fi
    
    if [ "$notification_result" = false ]; then
        echo -e "${RED}❌ Notifications not received${NC}"
        echo "   Possible causes:"
        echo "   - Notification permissions denied"
        echo "   - Do Not Disturb mode active"
        echo "   - Notification service failure"
        echo "   Recommendation: Check iOS Settings > Notifications > GymBro"
        echo ""
    fi
    
    if [ "$sync_result" = false ]; then
        echo -e "${RED}❌ App state sync failed${NC}"
        echo "   Possible causes:"
        echo "   - State persistence issue"
        echo "   - Background/foreground lifecycle problems"
        echo "   - Timer state corruption"
        echo "   Recommendation: Check app logs for sync errors"
        echo ""
    fi
fi

# Step 7: Generate test report
echo -e "${BLUE}📋 STEP 7: Generating Test Report${NC}"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="gymbro_silent_track_test_${TIMESTAMP}.log"

cat > "$REPORT_FILE" << EOF
# GymBro Silent Track Background Audio Test Report
Generated: $(date)
Device: $(flutter devices --machine | jq -r '.[0].name' 2>/dev/null || echo "Unknown")
Flutter Version: $(flutter --version | head -n 1)

## Test Configuration
- Timer Duration: ${TEST_DURATION}s
- Target: ${DEVICE_TYPE}
- Bundle ID: ${APP_BUNDLE_ID}

## Test Results
1. Silent track background execution: $([ "$silent_audio_result" = true ] && echo "✅ PASS" || echo "❌ FAIL")
2. Completion audio in background: $([ "$completion_audio_result" = true ] && echo "✅ PASS" || echo "❌ FAIL")  
3. Live Activity updates: $([ "$live_activity_result" = true ] && echo "✅ PASS" || echo "❌ FAIL")
4. Notification delivery: $([ "$notification_result" = true ] && echo "✅ PASS" || echo "❌ FAIL")
5. Foreground sync: $([ "$sync_result" = true ] && echo "✅ PASS" || echo "❌ FAIL")

## Summary
- Tests Passed: $passed_tests/$total_tests
- Success Rate: $((passed_tests * 100 / total_tests))%
- Overall Status: $test_status

## Recommendations
$(if [ "$test_status" != "SUCCESS" ]; then
    echo "- Review failed test items above"
    echo "- Check device settings (Background App Refresh, Notifications, Live Activities)"
    echo "- Verify audio session configuration in AppDelegate.swift"
    echo "- Test on multiple devices to isolate device-specific issues"
else
    echo "- Silent track system is functioning correctly"
    echo "- Background audio implementation successful"
    echo "- Ready for production deployment"
fi)
EOF

echo "   Test report saved: $REPORT_FILE"
echo ""

# Cleanup
if [ -n "$FLUTTER_PID" ]; then
    echo "🧹 Cleaning up Flutter process..."
    kill $FLUTTER_PID 2>/dev/null || true
fi

echo -e "${BLUE}🏁 TEST COMPLETED${NC}"
echo ""
echo "Next steps:"
if [ "$test_status" = "SUCCESS" ]; then
    echo "  1. ✅ Silent track implementation verified"
    echo "  2. 🚀 Ready for production testing with real users"
    echo "  3. 📊 Monitor user feedback and audio performance"
else
    echo "  1. 🔧 Address failed test items"
    echo "  2. 🧪 Re-run test after fixes"
    echo "  3. 📋 Review device Console logs for detailed errors"
fi

echo ""
echo "📄 Full test report: $REPORT_FILE"
echo ""
echo "🧪 ========================================"
echo "🧪 SILENT TRACK BACKGROUND TEST COMPLETE"
echo "🧪 ========================================"
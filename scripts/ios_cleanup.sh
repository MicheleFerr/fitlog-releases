#!/bin/bash

echo "🧹 iOS Cleanup & Verification Script for GymBro"
echo "================================================"

# 1. Clean Flutter build
echo ""
echo "1️⃣ Cleaning Flutter build..."
flutter clean

# 2. Clean iOS build
echo ""
echo "2️⃣ Cleaning iOS build folders..."
cd ios
rm -rf build/
rm -rf ~/Library/Developer/Xcode/DerivedData/*GymBro*
pod cache clean --all

# 3. Reinstall pods
echo ""
echo "3️⃣ Reinstalling CocoaPods..."
pod deintegrate
pod install --repo-update

# 4. Verify SKAdNetwork IDs
echo ""
echo "4️⃣ Verifying SKAdNetwork IDs..."
echo "Found $(grep -c "SKAdNetworkIdentifier" Runner/Info.plist) network IDs"

# Check for the 6 specific networks
echo "Checking required networks:"
networks=("prcb7njmu6" "v9wttpbfk9" "6xzpu9s2p4")
for network in "${networks[@]}"; do
    if grep -q "$network" Runner/Info.plist; then
        echo "✅ $network.skadnetwork - FOUND"
    else
        echo "❌ $network.skadnetwork - MISSING"
    fi
done

# 5. Check for trailing spaces in plist
echo ""
echo "5️⃣ Checking for trailing spaces in SKAdNetwork entries..."
if grep -E "\.skadnetwork </string>" Runner/Info.plist; then
    echo "⚠️ Found trailing spaces in SKAdNetwork IDs - FIX REQUIRED"
else
    echo "✅ No trailing spaces found"
fi

# 6. Reset Simulator (optional)
echo ""
echo "6️⃣ Reset Simulator? (y/n) - Fixes LaunchServices error"
read -r response
if [[ "$response" == "y" ]]; then
    xcrun simctl shutdown all
    xcrun simctl erase all
    echo "✅ Simulator reset complete"
fi

cd ..
echo ""
echo "✅ Cleanup complete! Now run:"
echo "   flutter run --verbose"
echo ""
echo "Expected results:"
echo "- No Audio Session Error -50 (optimized async handling)"
echo "- No SKAdNetwork warnings (cleaned cache)"
echo "- No LaunchServices error (if Simulator reset)"
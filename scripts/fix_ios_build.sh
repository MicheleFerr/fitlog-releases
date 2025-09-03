#!/bin/bash

echo "🔧 Fixing iOS Build Issues..."

# 1. Clean Xcode DerivedData
echo "📱 Cleaning Xcode DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*

# 2. Clean Flutter build
echo "🧹 Cleaning Flutter build..."
flutter clean

# 3. Get Flutter packages
echo "📦 Getting Flutter packages..."
flutter pub get

# 4. Clean iOS build folder
echo "🗑️ Cleaning iOS build folder..."
cd ios
rm -rf build/
rm -rf Pods/
rm -rf .symlinks/
rm -f Podfile.lock

# 5. Clean pod cache
echo "🧽 Cleaning pod cache..."
pod cache clean --all

# 6. Install pods
echo "📥 Installing pods..."
pod install --repo-update

# 7. Open Xcode and clean build folder
echo "🔨 Opening Xcode..."
echo "⚠️ IMPORTANT: In Xcode, go to Product → Clean Build Folder (Shift+Cmd+K)"

cd ..

echo "✅ iOS build fix complete!"
echo ""
echo "📝 Next steps:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. Clean Build Folder: Product → Clean Build Folder (Shift+Cmd+K)"
echo "3. Build again: Product → Build (Cmd+B)"
echo ""
echo "If the issue persists, try:"
echo "- Update CocoaPods: sudo gem install cocoapods"
echo "- Update Flutter: flutter upgrade"
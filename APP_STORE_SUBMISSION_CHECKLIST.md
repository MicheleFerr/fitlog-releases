# App Store Submission Checklist - Build 25

## ✅ Fixed Issues (ITMS-90683)
- [x] Added NSPhotoLibraryUsageDescription to Info.plist
- [x] Added NSPhotoLibraryAddUsageDescription to Info.plist  
- [x] Added NSCameraUsageDescription to Info.plist
- [x] Added ITSAppUsesNonExemptEncryption (set to false)
- [x] Incremented build number to 25

## 📱 Privacy Permissions Added
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>GymBro needs access to your photo library to save and share workout progress photos</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>GymBro needs permission to save workout progress photos to your photo library</string>

<key>NSCameraUsageDescription</key>
<string>GymBro needs camera access to take workout progress photos</string>
```

## 🔧 Build Commands
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build ios --release --build-number=25

# Open in Xcode
open ios/Runner.xcworkspace
```

## 📤 Xcode Upload Steps
1. Open Xcode: `Product` → `Archive`
2. Wait for archive to complete
3. Click `Distribute App`
4. Select `App Store Connect`
5. Select `Upload`
6. Keep all default options
7. Sign with automatic signing
8. Review and upload

## ⏰ Post-Upload
- Build usually appears in App Store Connect within 30-60 minutes
- Check TestFlight tab for processing status
- If not visible after 1 hour, check email for any issues

## 🚨 Common Issues & Solutions

### Build Not Appearing in App Store Connect
1. Check email for rejection notices
2. Verify build number is unique (we're using 25)
3. Check App Store Connect > Activity tab for processing status
4. Ensure app bundle ID matches: `com.michele.gymbro.flutter`

### Export Compliance
- Already added `ITSAppUsesNonExemptEncryption = false`
- This prevents the export compliance warning

## 📧 Support Contacts
- If issues persist: Contact Apple Developer Support
- Check: https://developer.apple.com/contact/

## ✅ Current Status
- Build 25 is being compiled with all fixes
- All privacy permissions added
- Export compliance configured
- Ready for App Store submission once build completes
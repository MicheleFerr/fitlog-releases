# 🔥 Firestore Connection Debug Guide

**Last Updated**: 2025-10-20
**Status**: Active Debugging Protocol

---

## 📋 Quick Diagnosis

### Symptoms
```
11.15.0 - [FirebaseFirestore][I-FST000001] Could not reach Cloud Firestore backend
flutter: ❌ Failed to get remote version: [cloud_firestore/unavailable]
```

### Impact
- App operates in **offline mode** (Hive cache only)
- Workout/template sync fails
- Exercise database version check disabled
- User profile updates blocked

---

## 🔍 Root Cause Analysis

### Possible Causes (Priority Order)

#### 1. Firebase API Restrictions (MOST COMMON)
**Probability**: ⚠️ HIGH (70%)

**Check**:
1. Open [Firebase Console](https://console.firebase.google.com)
2. Select project: `gymbro-flutter-new`
3. Navigate to: **Project Settings → Service Accounts**
4. Check: **API & Services → Credentials**
5. Verify: No restrictions on Cloud Firestore API

**Expected Configuration**:
```yaml
API Restrictions:
  - Cloud Firestore API: ✅ UNRESTRICTED
  - OR iOS Bundle ID Whitelist: com.gymbro.app
```

**Fix**:
```bash
# Firebase Console
Project Settings → API Restrictions
→ Remove restrictions OR add bundle ID: com.gymbro.app
→ Save changes
→ Wait 5-10 minutes for propagation
```

**Reference**: `docs/audit/FIREBASE_API_RESTRICTIONS_GUIDE.md`

---

#### 2. Firestore Region Mismatch
**Probability**: ⚠️ MEDIUM (20%)

**Check**:
1. Firebase Console → Firestore Database
2. Verify region: **eur3** (Europe-west3, Belgium)
   - ⚠️ **VERIFIED 2025-10-20**: Region is `eur3`, NOT `europe-west1`
3. Check app config: `lib/core/config/firebase_options.dart`

**Expected Configuration**:
```dart
// FirebaseOptions should match project region
projectId: 'gymbro-flutter-new'
// Region: eur3 (Europe-west3, Belgium)
databaseURL: 'https://gymbro-flutter-new.eur3.firebasedatabase.app'
// OR alternative endpoint:
// https://firestore.googleapis.com/v1/projects/gymbro-flutter-new/databases/(default)
```

**Fix**:
If region mismatch detected:
1. Cannot change database region (permanent)
2. Update app config to match actual region
3. Re-generate `firebase_options.dart`:
   ```bash
   flutterfire configure
   ```

---

#### 3. iOS Simulator Network Issues
**Probability**: 💡 LOW (10%)

**Characteristics**:
- Works on Android Simulator ✅
- Works on physical iOS device ✅
- Fails ONLY on iOS Simulator ❌

**Fix**:
```bash
# Test on real device
flutter build ios --release
flutter run --release --device-id=<YOUR_DEVICE_ID>

# List available devices
flutter devices
```

**Network Config** (already applied):
```swift
// ios/Runner/AppDelegate.swift:30-32
NetworkConfiguration.shared
NetworkConfiguration.preferIPv4ForFirebase()
```

---

## 🛠️ Step-by-Step Debug Protocol

### Step 1: Verify Firebase Console Configuration

**Actions**:
```bash
# 1. Check Firebase Project
https://console.firebase.google.com/project/gymbro-flutter-new/settings/general

# 2. Verify iOS App Registration
Bundle ID: com.gymbro.app
App ID: 1:206648824958:ios:XXXXXXXXXX

# 3. Check API Restrictions
https://console.firebase.google.com/project/gymbro-flutter-new/settings/serviceaccounts
```

**Expected Result**:
- ✅ iOS app registered with correct bundle ID
- ✅ GoogleService-Info.plist downloaded
- ✅ No API restrictions active OR bundle ID whitelisted

---

### Step 2: Test Firestore Rules

**Current Rules** (check in Firebase Console → Firestore → Rules):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Allow authenticated users to read exercises (public data)
    match /exercises/{exerciseId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == resource.data.createdBy;
    }

    // Allow authenticated users to manage their workouts
    match /workouts/{userId}/workouts/{workoutId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

**Test Rules** (temporary, for debugging ONLY):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null; // ⚠️ TEMPORARY ONLY
    }
  }
}
```

**IMPORTANT**: ⚠️ Revert to proper rules after testing!

---

### Step 3: Enable Debug Logging

**Enable Firestore Debug Logs**:
```dart
// lib/main.dart (temporary, for debugging)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ ENABLE DEBUG LOGGING
  if (kDebugMode) {
    FirebaseFirestore.setLoggingEnabled(true);
  }

  runApp(MyApp());
}
```

**iOS Console Logs** (Xcode → Window → Devices and Simulators → Open Console):
```
# Look for these patterns:
11.15.0 - [FirebaseFirestore][I-FST000001] ...
flutter: 🔥 Firestore operation: ...
```

---

### Step 4: Test on Physical Device

**Why Physical Device?**
- Simulator has known network quirks
- IPv6/IPv4 routing different
- Sandbox environment more restrictive

**Test Protocol**:
```bash
# 1. Connect iPhone via USB
flutter devices

# 2. Build and run release mode
flutter build ios --release
flutter run --release --device-id=<DEVICE_ID>

# 3. Monitor logs
flutter logs --device-id=<DEVICE_ID> | grep -i firestore
```

**Expected Behavior**:
- ✅ Connection succeeds on device
- ❌ Connection fails on Simulator → Simulator-specific issue (ignore)

---

## 🔧 Quick Fixes

### Fix 1: Disable API Restrictions (5 minutes)

**Firebase Console**:
```
1. Go to: https://console.cloud.google.com/apis/credentials
2. Select project: gymbro-flutter-new
3. Click on iOS API Key
4. Under "API restrictions": Select "Don't restrict key"
5. Save
6. Wait 5-10 minutes
7. Re-test app
```

---

### Fix 2: Re-generate Firebase Config (10 minutes)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Re-configure Firebase
flutterfire configure \
  --project=gymbro-flutter-new \
  --platforms=ios,android \
  --ios-bundle-id=com.gymbro.app

# Replace generated files
cp lib/firebase_options.dart lib/core/config/firebase_options.dart
cp ios/Runner/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist

# Clean and rebuild
flutter clean
flutter pub get
pod install --repo-update --project-directory=ios
```

---

### Fix 3: Verify Network Permissions (5 minutes)

**Check Info.plist** (`ios/Runner/Info.plist`):
```xml
<!-- Should already exist -->
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <false/>
  <key>NSExceptionDomains</key>
  <dict>
    <key>firebaseio.com</key>
    <dict>
      <key>NSIncludesSubdomains</key>
      <true/>
      <key>NSThirdPartyExceptionRequiresForwardSecrecy</key>
      <false/>
    </dict>
  </dict>
</dict>
```

---

## 📊 Verification Checklist

After applying fixes, verify:

- [ ] **Console Logs**: No more `[cloud_firestore/unavailable]` errors
- [ ] **User Profile**: Syncs from Firestore (check `flutter: 🔄 Refreshing profile from Firestore...`)
- [ ] **Exercise Database**: Version check succeeds (`flutter: ✅ No updates available`)
- [ ] **Workout Sync**: Templates load from cloud (check `flutter: 🔍 customWorkoutTemplatesProvider: Got X unified templates`)
- [ ] **Offline → Online**: App reconnects after network interruption

---

## 🚨 Known Issues

### Issue 1: Intermittent Disconnects (Transient)
**Symptom**: Connection works, then fails after 5-10 minutes
**Cause**: Firestore idle timeout or network change
**Fix**: Automatic retry with exponential backoff (already implemented)

### Issue 2: Simulator-Only Failures
**Symptom**: Works on device, fails on Simulator
**Cause**: Simulator network sandbox
**Fix**: ✅ Expected behavior, ignore

### Issue 3: First Launch After Install
**Symptom**: First launch fails to connect, subsequent launches work
**Cause**: Firebase initialization race condition
**Fix**: Add delay before Firestore operations:
```dart
// In app initialization
await Firebase.initializeApp();
await Future.delayed(Duration(seconds: 1)); // ✅ Wait for Firebase to be ready
```

---

## 📖 Related Documentation

- **API Restrictions**: `docs/audit/FIREBASE_API_RESTRICTIONS_GUIDE.md`
- **Security Audit**: `docs/audit/SECURITY_AUDIT_2025-10-20.md`
- **Network Config**: `ios/Runner/Config/NetworkConfiguration.swift`
- **Firebase Options**: `lib/core/config/firebase_options.dart`

---

## 🔍 Advanced Debugging

### Enable Charles Proxy (SSL Inspection)

**Setup**:
1. Install Charles Proxy
2. Configure iPhone proxy: Settings → Wi-Fi → (i) → HTTP Proxy → Manual
3. Host: Mac IP, Port: 8888
4. Install Charles SSL Certificate on iPhone
5. Trust certificate: Settings → General → About → Certificate Trust Settings

**Monitor Traffic**:
```
Look for:
- firestore.googleapis.com requests
- HTTP 403 (API restrictions)
- HTTP 500 (server error)
- Connection timeouts
```

---

### Check Firestore Quotas

**Firebase Console → Firestore → Usage**:
```yaml
Daily Limits (Spark Plan):
  - Reads: 50,000/day
  - Writes: 20,000/day
  - Deletes: 20,000/day

If exceeded:
  - ❌ All requests return [cloud_firestore/unavailable]
  - ✅ Fix: Upgrade to Blaze plan OR wait 24h
```

---

## 💡 Support & Help

**If issue persists after all fixes**:
1. Export logs: `flutter logs > firestore_debug.log`
2. Check Firebase Status: https://status.firebase.google.com
3. Review Recent Changes: `git log --oneline -10`
4. Contact Firebase Support with:
   - Project ID: `gymbro-flutter-new`
   - Error logs
   - Steps to reproduce

---

**End of Guide** 🔥

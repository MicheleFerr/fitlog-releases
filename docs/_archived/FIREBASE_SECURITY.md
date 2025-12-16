# 🔐 Firebase Security Documentation

**Version**: 1.0
**Last Updated**: 2025-01-06
**Status**: ✅ Production Ready

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Firebase App Check Setup](#firebase-app-check-setup)
3. [Console Configuration Checklist](#console-configuration-checklist)
4. [Debug Token Workflow](#debug-token-workflow)
5. [Rate Limiting Configuration](#rate-limiting-configuration)
6. [Production vs Debug Configuration](#production-vs-debug-configuration)
7. [Troubleshooting Guide](#troubleshooting-guide)
8. [Security Best Practices](#security-best-practices)
9. [Monitoring and Alerts](#monitoring-and-alerts)

---

## 🎯 Overview

Firebase App Check is a **critical security layer** that protects your Firebase resources from abuse and unauthorized access. It verifies that incoming traffic to your Firebase services originates from your legitimate app instances.

### Why App Check is Critical

**Without App Check:**
- ❌ Anyone with your API keys can scrape data
- ❌ Automated bots can abuse your Firebase quota
- ❌ Stolen API keys expose your entire database
- ❌ Unlimited read/write operations drain budget

**With App Check:**
- ✅ Only verified app instances can access Firebase
- ✅ Rate limiting prevents quota abuse
- ✅ Device attestation ensures app authenticity
- ✅ Protected against scrapers and bots

### Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│                    GymBro Flutter App                        │
│  ┌────────────────────────────────────────────────────┐     │
│  │         App Check Token Provider                   │     │
│  │  • iOS: App Attest (hardware attestation)          │     │
│  │  • Android: Play Integrity API                     │     │
│  │  • Web: reCAPTCHA v3                               │     │
│  └────────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────┘
                           ↓ (attested token)
┌──────────────────────────────────────────────────────────────┐
│                  Firebase App Check                          │
│  • Validates token authenticity                              │
│  • Checks device/app integrity                               │
│  • Enforces rate limits                                      │
│  • Issues time-limited tokens                                │
└──────────────────────────────────────────────────────────────┘
                           ↓ (verified request)
┌──────────────────────────────────────────────────────────────┐
│               Firebase Backend Services                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Firestore  │  │  Functions  │  │   Storage   │        │
│  │  (Enforce)  │  │  (Enforce)  │  │  (Enforce)  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└──────────────────────────────────────────────────────────────┘
```

---

## 🚀 Firebase App Check Setup

### Prerequisites

Before enabling App Check, ensure you have:

- ✅ Firebase project set up (`gymprogressapp-184bc`)
- ✅ iOS app registered in Firebase Console
- ✅ Android app registered in Firebase Console
- ✅ Web app registered (if deploying to web)
- ✅ Owner or Editor access to Firebase project

### Platform-Specific Setup

#### iOS Setup (App Attest)

**App Attest** is Apple's hardware-backed attestation service (iOS 14+, more secure than DeviceCheck).

1. **Enable App Attest in Apple Developer Console:**
   - Sign in to [Apple Developer](https://developer.apple.com)
   - Navigate to **Certificates, Identifiers & Profiles**
   - Select your app identifier (`com.yourcompany.gymbro`)
   - Enable **App Attest** capability
   - Save changes

2. **Register iOS App in Firebase Console:**
   - Go to [Firebase Console → App Check](https://console.firebase.google.com/project/gymprogressapp-184bc/appcheck/apps)
   - Click **iOS** tab
   - Find your iOS app bundle ID
   - Click **Register**
   - Select **App Attest** as provider
   - Save configuration

3. **Verify in Xcode:**
   ```bash
   # Check Info.plist has correct bundle ID
   cat ios/Runner/Info.plist | grep -A 1 "CFBundleIdentifier"
   ```

   Expected output:
   ```xml
   <key>CFBundleIdentifier</key>
   <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
   ```

4. **Test App Attest Integration:**
   ```bash
   # Build and run on physical iOS device (required for App Attest)
   flutter run --release -d <device-id>

   # Check console for App Check initialization
   # Should see: "✅ [App Check] Successfully initialized"
   ```

**Notes:**
- App Attest requires **physical device** (iOS 14+)
- Simulator uses DeviceCheck fallback
- Fallback to DeviceCheck on iOS 11-13

#### Android Setup (Play Integrity API)

**Play Integrity API** verifies app is from Google Play and not tampered.

1. **Enable Play Integrity API in Google Cloud Console:**
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Select project linked to Firebase (`gymprogressapp-184bc`)
   - Navigate to **APIs & Services → Library**
   - Search for **Play Integrity API**
   - Click **Enable**

2. **Link Google Play Console:**
   - Sign in to [Google Play Console](https://play.google.com/console)
   - Select your app
   - Go to **Setup → API access**
   - Link to Firebase project (if not already linked)
   - Grant necessary permissions

3. **Register Android App in Firebase Console:**
   - Go to [Firebase Console → App Check](https://console.firebase.google.com/project/gymprogressapp-184bc/appcheck/apps)
   - Click **Android** tab
   - Find your Android package name
   - Click **Register**
   - Select **Play Integrity** as provider
   - Save configuration

4. **Test Play Integrity Integration:**
   ```bash
   # Build signed release APK
   flutter build apk --release

   # Install on physical Android device
   adb install build/app/outputs/flutter-apk/app-release.apk

   # Check logcat for App Check initialization
   adb logcat | grep "App Check"
   # Should see: "✅ [App Check] Successfully initialized"
   ```

**Notes:**
- Play Integrity requires **signed release build**
- Debug builds need debug tokens (see [Debug Token Workflow](#debug-token-workflow))
- App must be uploaded to Google Play (internal/alpha track minimum)

#### Web Setup (reCAPTCHA v3)

**reCAPTCHA v3** protects web app from bots and abuse.

1. **Get reCAPTCHA Site Key:**
   - Go to [Firebase Console → App Check](https://console.firebase.google.com/project/gymprogressapp-184bc/appcheck/apps)
   - Click **Web** tab
   - Click **Register** for your web app
   - Select **reCAPTCHA v3**
   - Copy the **reCAPTCHA site key**

2. **Update App Check Configuration:**
   ```dart
   // lib/core/security/app_check_config.dart
   providerWeb: ReCaptchaV3Provider(
     'YOUR_RECAPTCHA_SITE_KEY_HERE', // ← Replace with your site key
   ),
   ```

3. **Test reCAPTCHA Integration:**
   ```bash
   # Run web app in release mode
   flutter run -d chrome --release

   # Check browser console for App Check initialization
   # Should see: "✅ [App Check] Successfully initialized"
   ```

---

## ✅ Console Configuration Checklist

### Step 1: Navigate to Firebase Console

1. **Open Firebase Console:**
   - URL: https://console.firebase.google.com/project/gymprogressapp-184bc/appcheck/apps
   - Sign in with project owner/editor account

2. **Verify Current Status:**
   - Check **Enforcement Status** for each service
   - Note current mode (Monitor vs Enforce)

### Step 2: Enable Enforcement Mode

**⚠️ CRITICAL**: This is the **MANUAL STEP** you must complete in Firebase Console.

**For Each Service:**

1. **Cloud Firestore:**
   - Navigate to **App Check** → **Apps**
   - Find **Cloud Firestore** section
   - Current mode: **Monitor** (allows unauthenticated requests, logs violations)
   - **Action Required:** Change to **Enforce** mode
   - Click **Enforce** button
   - Confirm: "Enable enforcement for Cloud Firestore?"
   - ✅ **Status**: Enforce mode enabled

2. **Cloud Functions:**
   - Find **Cloud Functions** section
   - Current mode: **Monitor**
   - **Action Required:** Change to **Enforce** mode
   - Click **Enforce** button
   - Confirm: "Enable enforcement for Cloud Functions?"
   - ✅ **Status**: Enforce mode enabled

3. **Firebase Storage:**
   - Find **Firebase Storage** section
   - Current mode: **Monitor**
   - **Action Required:** Change to **Enforce** mode
   - Click **Enforce** button
   - Confirm: "Enable enforcement for Firebase Storage?"
   - ✅ **Status**: Enforce mode enabled

### Step 3: Configure Rate Limiting

**Purpose:** Prevent quota abuse from legitimate users making excessive requests.

1. **Set Rate Limits:**
   - In **App Check** settings, find **Rate Limiting** section
   - Configure per-device limits:
     - **Firestore**: 1000 requests/minute per device
     - **Functions**: 1000 requests/minute per device
     - **Storage**: 1000 requests/minute per device
   - Save configuration

2. **Monitor Rate Limit Violations:**
   - Check **App Check** → **Metrics** for violations
   - Adjust limits based on legitimate usage patterns

### Step 4: Take Screenshot for Verification

**Documentation Proof:**

1. Take screenshot showing:
   - ✅ Firestore: **Enforce** mode enabled
   - ✅ Functions: **Enforce** mode enabled
   - ✅ Storage: **Enforce** mode enabled
   - ✅ Rate limits configured (1000 req/min)

2. Save screenshot as:
   - Filename: `firebase-appcheck-enforcement-enabled.png`
   - Location: `docs/screenshots/` (create folder if needed)

### Step 5: Verify Configuration

**Checklist:**

- [ ] ✅ Cloud Firestore in **Enforce** mode
- [ ] ✅ Cloud Functions in **Enforce** mode
- [ ] ✅ Firebase Storage in **Enforce** mode
- [ ] ✅ Rate limits set to 1000 req/min per device
- [ ] ✅ Screenshot saved for documentation
- [ ] ✅ No debug tokens registered (removed after testing)

**Verification Command:**
```bash
# Check Firestore security rules include App Check validation
# (Already deployed ✅)
firebase firestore:rules:get
```

---

## 🐛 Debug Token Workflow

### When to Use Debug Tokens

**Scenarios:**
- 🧪 **Local development:** Testing on emulator/simulator
- 🐛 **Debugging:** Investigating App Check failures
- 🧪 **CI/CD pipelines:** Running integration tests
- 🚧 **Pre-production testing:** Before enabling Enforce mode

**⚠️ NEVER use debug tokens in production builds!**

### How to Generate Debug Token

**Option 1: Automatic Token Generation (DELETED - See Option 2)**

The debug token generator file (`lib/main_debug_appcheck.dart`) has been **removed for security**. Use Option 2 instead.

**Option 2: Runtime Console Output (Recommended)**

1. **Enable Debug Mode in App Check:**
   ```dart
   // lib/core/security/app_check_config.dart
   // Temporarily change provider for debugging:

   await FirebaseAppCheck.instance.activate(
     appleProvider: AppleProvider.debug, // ← Debug mode
     androidProvider: AndroidProvider.debug, // ← Debug mode
   );
   ```

2. **Run App and Get Token:**
   ```bash
   # iOS Simulator
   flutter run -d ios_simulator

   # Android Emulator
   flutter run -d emulator

   # Check console output for debug token
   # Look for: "Firebase App Check debug token: XXXXX-YYYY-ZZZZ"
   ```

3. **Copy Token from Console:**
   - iOS: Check Xcode Console
   - Android: Check `adb logcat | grep "App Check"`
   - Token format: `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`

**Option 3: Manual Debug Token Creation (Recreate Temporarily)**

If you need the old debug token generator temporarily:

```dart
// Create temporary file: lib/main_debug_token.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:gymbro_flutter_new/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    appleProvider: AppleProvider.debug,
    androidProvider: AndroidProvider.debug,
  );

  if (kDebugMode) {
    final token = await FirebaseAppCheck.instance.getToken();
    debugPrint('🔐 DEBUG TOKEN: $token');
  }

  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: Text('Check console for debug token'),
      ),
    ),
  ));
}
```

Run:
```bash
flutter run lib/main_debug_token.dart
```

**⚠️ Remember to delete `lib/main_debug_token.dart` after getting token!**

### Registering Debug Token in Firebase Console

1. **Navigate to Debug Tokens:**
   - Go to [Firebase Console → App Check → Debug tokens](https://console.firebase.google.com/project/gymprogressapp-184bc/appcheck/debug)
   - Click **Add debug token** button

2. **Add Token:**
   - Paste token copied from console
   - Add description: "Local development - [Your Name] - [Device]"
   - Example: "Local development - Michele - iPhone 15 Simulator"
   - Click **Save**

3. **Wait for Propagation:**
   - Tokens take **5-10 minutes** to activate
   - You'll see 403 errors until token activates
   - Check Firebase Console for token status: **Active**

4. **Test with Debug Token:**
   ```bash
   # Run app in debug mode
   flutter run

   # Try Firebase operation (e.g., create workout)
   # Should succeed with debug token
   ```

### Managing Debug Tokens

**Best Practices:**
- ✅ Use descriptive names (include device and developer name)
- ✅ Set expiration dates (e.g., 30 days)
- ✅ Delete tokens after debugging session
- ✅ Audit tokens monthly and remove unused ones
- ❌ Never share debug tokens
- ❌ Never commit debug tokens to git

**Audit Command:**
```bash
# List all debug tokens in Firebase Console
# Go to: App Check → Debug tokens
# Review and delete old/unused tokens
```

### Disabling Debug Mode (Production)

**Before release, ensure:**

```dart
// lib/core/security/app_check_config.dart
await FirebaseAppCheck.instance.activate(
  appleProvider: AppleProvider.appAttestWithDeviceCheckFallback, // ✅ Production
  androidProvider: AndroidProvider.playIntegrity, // ✅ Production
);
```

**Checklist:**
- [ ] ✅ Debug providers removed from production code
- [ ] ✅ All debug tokens deleted from Firebase Console
- [ ] ✅ Enforce mode enabled for all services
- [ ] ✅ No `lib/main_debug_appcheck.dart` or `lib/main_debug_token.dart` in git

---

## ⚡ Rate Limiting Configuration

### Why Rate Limiting Matters

**Without rate limiting:**
- 😱 User accidentally triggers infinite loop → 1M requests in 1 minute
- 💸 Firebase quota exhausted → app stops working for all users
- 🚨 Billing surprise → unexpected $1000+ charges

**With rate limiting:**
- ✅ Protects against runaway code
- ✅ Prevents quota exhaustion
- ✅ Limits blast radius of bugs
- ✅ Predictable Firebase costs

### Recommended Limits

**Per-Device Limits (per minute):**

| Service | Limit | Reasoning |
|---------|-------|-----------|
| **Firestore** | 1000 req/min | 16 req/sec = reasonable for workout tracking |
| **Functions** | 1000 req/min | Batch operations, analytics |
| **Storage** | 1000 req/min | Image uploads, profile pictures |

**Calculating Appropriate Limits:**

1. **Measure Normal Usage:**
   ```dart
   // Enable Firebase Performance Monitoring
   // Check Firebase Console → Performance for baseline metrics

   // Typical workout session:
   // - 50 exercise cards × 5 sets = 250 Firestore reads
   // - 1 workout save = 1 Firestore write
   // - 1 analytics update = 1 Cloud Function call
   // Total: ~250 requests/workout (well under 1000/min)
   ```

2. **Add Safety Buffer:**
   - Normal usage: 250 req/workout
   - Safety buffer: 4x
   - Rate limit: 1000 req/min ✅

3. **Monitor in Production:**
   - Check **App Check → Metrics** for rate limit violations
   - Adjust limits if legitimate users hitting limits
   - Investigate anomalies (sudden spikes)

### Configuring Rate Limits

**Firebase Console:**

1. **Navigate to Rate Limiting:**
   - Go to [Firebase Console → App Check](https://console.firebase.google.com/project/gymprogressapp-184bc/appcheck/apps)
   - Click **Rate Limiting** tab

2. **Set Per-Service Limits:**
   - **Firestore**: 1000 requests/minute per device
   - **Functions**: 1000 requests/minute per device
   - **Storage**: 1000 requests/minute per device

3. **Save Configuration**

**Terraform/Infrastructure as Code (Future):**

```hcl
# terraform/firebase_appcheck.tf
resource "google_firebase_app_check_config" "default" {
  project = "gymprogressapp-184bc"

  rate_limits {
    firestore {
      requests_per_minute = 1000
    }
    functions {
      requests_per_minute = 1000
    }
    storage {
      requests_per_minute = 1000
    }
  }
}
```

### Monitoring Rate Limit Violations

**Firebase Console:**

1. **Check Metrics:**
   - Go to **App Check → Metrics**
   - Filter by **Rate Limit Violations**
   - Graph shows violations over time

2. **Investigate Anomalies:**
   - Click on spike to see details
   - Identify affected device/user
   - Check app logs for root cause

**Alerts Setup:**

```yaml
# firebase_alerts.yaml
alerts:
  - name: "App Check Rate Limit Exceeded"
    condition: "rate_limit_violations > 100/hour"
    notification:
      email: "dev-team@yourcompany.com"
      slack: "#firebase-alerts"
    severity: "high"
```

**Client-Side Handling:**

```dart
// lib/shared/data/network/firebase_client.dart
class FirebaseClient {
  Future<T> executeWithRateLimit<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on FirebaseException catch (e) {
      if (e.code == 'resource-exhausted') {
        // Rate limit hit - back off and retry
        await Future.delayed(Duration(seconds: 60));
        return await operation();
      }
      rethrow;
    }
  }
}
```

---

## 🔄 Production vs Debug Configuration

### Configuration Comparison

| Aspect | Debug Mode | Production Mode |
|--------|------------|-----------------|
| **iOS Provider** | `AppleProvider.debug` | `AppleProvider.appAttestWithDeviceCheckFallback` |
| **Android Provider** | `AndroidProvider.debug` | `AndroidProvider.playIntegrity` |
| **Enforcement** | Monitor mode (logs only) | Enforce mode (blocks invalid requests) |
| **Debug Tokens** | Allowed | ❌ Disabled |
| **Token Lifetime** | Unlimited | 1 hour (auto-refresh) |
| **Device Verification** | ❌ Skipped | ✅ Required (hardware attestation) |
| **Rate Limiting** | ⚠️ Loose (10,000 req/min) | ✅ Strict (1000 req/min) |

### Current Production Configuration

**File:** `lib/core/security/app_check_config.dart`

```dart
await FirebaseAppCheck.instance.activate(
  // iOS: App Attest (hardware attestation) with DeviceCheck fallback
  // ✅ PRODUCTION: Most secure option
  appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,

  // Android: Play Integrity API
  // ✅ PRODUCTION: Verifies app from Google Play, not tampered
  androidProvider: AndroidProvider.playIntegrity,

  // Web: reCAPTCHA v3
  // ⚠️ TODO: Replace with your actual reCAPTCHA site key
  providerWeb: ReCaptchaV3Provider(
    'your-recaptcha-v3-site-key-here',
  ),
);
```

**Enforcement Status:**
- ✅ **Firestore:** Enforce mode
- ✅ **Functions:** Enforce mode
- ✅ **Storage:** Enforce mode

**Verification:**
```bash
# Check production configuration
grep -A 5 "appleProvider" lib/core/security/app_check_config.dart

# Expected output:
# appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,
# androidProvider: AndroidProvider.playIntegrity,
```

### Debug Configuration (Local Development Only)

**⚠️ Use only for local development/testing!**

```dart
// Temporary debug configuration
await FirebaseAppCheck.instance.activate(
  appleProvider: AppleProvider.debug,
  androidProvider: AndroidProvider.debug,
);
```

**When to use:**
- Local development on simulator/emulator
- Integration tests in CI/CD
- Debugging App Check issues

**When NOT to use:**
- ❌ Production releases
- ❌ TestFlight builds
- ❌ Internal testing tracks

### Switching Between Debug and Production

**Development:**
```bash
# Switch to debug mode for local testing
# Edit: lib/core/security/app_check_config.dart
# Change providers to .debug

flutter run
```

**Production Release:**
```bash
# ALWAYS revert to production providers before release
# Edit: lib/core/security/app_check_config.dart
# Ensure providers are:
# - appleProvider: AppleProvider.appAttestWithDeviceCheckFallback
# - androidProvider: AndroidProvider.playIntegrity

# Build release
flutter build ios --release
flutter build apk --release
```

**Pre-commit Hook (Recommended):**
```bash
# .git/hooks/pre-commit
#!/bin/bash
# Check for debug providers in production code

if grep -q "AppleProvider.debug\|AndroidProvider.debug" lib/core/security/app_check_config.dart; then
  echo "❌ ERROR: Debug App Check providers detected!"
  echo "   Change to production providers before committing."
  exit 1
fi
```

---

## 🔧 Troubleshooting Guide

### Common Issues and Solutions

#### 1. App Check Token Validation Failures

**Symptom:**
```
FirebaseException: [firebase_app_check/fetch-status-error]
Token fetch failed with status: 403
```

**Possible Causes:**

**A. App Not Registered in Firebase Console**

Solution:
```bash
# 1. Check bundle ID matches Firebase Console
cat ios/Runner/Info.plist | grep -A 1 "CFBundleIdentifier"
cat android/app/build.gradle | grep applicationId

# 2. Verify app registered in Firebase Console
# Go to: Firebase Console → App Check → Apps
# Ensure iOS/Android app is listed and registered
```

**B. Debug Token Not Activated**

Solution:
```bash
# 1. Get debug token from console
flutter run
# Look for: "Firebase App Check debug token: XXXXX"

# 2. Register in Firebase Console
# Go to: App Check → Debug tokens → Add debug token

# 3. Wait 5-10 minutes for propagation

# 4. Retry
flutter run
```

**C. Enforce Mode Enabled Without Valid Provider**

Solution:
```bash
# Option 1: Temporarily disable Enforce mode
# Firebase Console → App Check → Switch to "Monitor" mode

# Option 2: Fix provider configuration
# Edit: lib/core/security/app_check_config.dart
# Ensure correct provider for platform
```

#### 2. Rate Limit Exceeded

**Symptom:**
```
FirebaseException: [resource-exhausted]
Rate limit exceeded for Firebase service
```

**Diagnosis:**
```bash
# Check Firebase Console metrics
# Go to: App Check → Metrics → Rate Limit Violations

# Look for spikes in request rate
```

**Solutions:**

**A. Legitimate High Usage:**
```bash
# Increase rate limits in Firebase Console
# Go to: App Check → Rate Limiting
# Adjust limits based on usage patterns
```

**B. Runaway Code (Infinite Loop):**
```dart
// Find and fix infinite loop
// Example bad code:
while (true) { // ❌ Infinite loop!
  await firestore.collection('workouts').get();
}

// Fixed:
for (int i = 0; i < 10; i++) { // ✅ Finite loop
  await firestore.collection('workouts').get();
}
```

**C. Implement Exponential Backoff:**
```dart
// lib/shared/data/network/firebase_client.dart
Future<T> executeWithBackoff<T>(Future<T> Function() operation) async {
  int retries = 0;
  const maxRetries = 3;
  const baseDelay = Duration(seconds: 1);

  while (retries < maxRetries) {
    try {
      return await operation();
    } on FirebaseException catch (e) {
      if (e.code == 'resource-exhausted' && retries < maxRetries - 1) {
        final delay = baseDelay * (1 << retries); // 1s, 2s, 4s
        await Future.delayed(delay);
        retries++;
      } else {
        rethrow;
      }
    }
  }
  throw Exception('Max retries exceeded');
}
```

#### 3. iOS App Attest Failures

**Symptom:**
```
App Attest is not available on this device
```

**Causes:**
- Running on iOS Simulator (App Attest requires physical device)
- iOS version < 14.0
- App Attest not enabled in Apple Developer Console

**Solutions:**

**A. Use DeviceCheck Fallback (Already Configured):**
```dart
// lib/core/security/app_check_config.dart
// Fallback already configured:
appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,
```

**B. Test on Physical Device:**
```bash
# Get connected device ID
flutter devices

# Run on physical device
flutter run -d <device-id>
```

**C. Enable App Attest in Apple Developer:**
```bash
# 1. Go to: developer.apple.com
# 2. Certificates, Identifiers & Profiles
# 3. Select app identifier
# 4. Enable "App Attest" capability
# 5. Save and sync with Xcode
```

#### 4. Android Play Integrity Failures

**Symptom:**
```
Play Integrity API is not available
```

**Causes:**
- App not uploaded to Google Play
- Google Play Services not installed (emulator)
- Play Integrity API not enabled

**Solutions:**

**A. Enable Play Integrity API:**
```bash
# 1. Go to: console.cloud.google.com
# 2. Select Firebase project
# 3. APIs & Services → Library
# 4. Search "Play Integrity API"
# 5. Click "Enable"
```

**B. Upload to Internal Testing Track:**
```bash
# Build signed APK
flutter build apk --release

# Upload to Google Play Console
# Go to: play.google.com/console
# Release → Internal testing
# Upload APK
```

**C. Test with Debug Token (Development):**
```bash
# Use debug provider for local testing
# lib/core/security/app_check_config.dart
androidProvider: AndroidProvider.debug,
```

#### 5. Network Connectivity Issues

**Symptom:**
```
Failed to fetch App Check token: network error
```

**Solutions:**

**A. Check Internet Connection:**
```bash
# Ping Firebase servers
ping firestore.googleapis.com

# Check Firebase status
# Go to: status.firebase.google.com
```

**B. Check Firewall/Proxy Settings:**
```bash
# Verify app can reach Firebase domains:
# - firestore.googleapis.com
# - firebase.googleapis.com
# - identitytoolkit.googleapis.com
```

**C. Implement Retry Logic (Already Configured):**
```dart
// lib/core/security/app_check_config.dart
// Exponential backoff retry already implemented:
// Attempts: 3 retries
// Delays: 1s, 2s, 4s
```

### Diagnostic Commands

**Check App Check Status:**
```dart
// In app code
final isActivated = await AppCheckConfig.isActivated();
debugPrint('App Check activated: $isActivated');

final token = await AppCheckConfig.getToken();
debugPrint('App Check token: ${token?.substring(0, 20)}...');
```

**Check Firebase Console Logs:**
```bash
# Go to: console.firebase.google.com
# Select project → App Check → Metrics
# Filter by:
# - Time range (last 1 hour)
# - Status (errors, warnings)
# - Platform (iOS, Android, Web)
```

**Check Device Logs:**
```bash
# iOS
# Xcode → Window → Devices and Simulators
# Select device → View Console
# Filter: "App Check"

# Android
adb logcat | grep "App Check"
```

---

## 🛡️ Security Best Practices

### Do's ✅

1. **Always Use Enforce Mode in Production**
   - Monitor mode logs violations but doesn't block
   - Enforce mode blocks unauthorized requests
   - Test thoroughly in Monitor mode first

2. **Rotate Debug Tokens Regularly**
   - Set expiration dates (30 days max)
   - Delete after debugging session
   - Audit tokens monthly

3. **Use Production Providers in Release Builds**
   - App Attest for iOS (hardware attestation)
   - Play Integrity for Android (Google Play verification)
   - Never ship debug providers

4. **Monitor App Check Metrics Daily**
   - Check Firebase Console for anomalies
   - Set up alerts for high violation rates
   - Investigate spikes immediately

5. **Implement Client-Side Rate Limiting**
   - Exponential backoff on errors
   - Cache data locally (reduce requests)
   - Batch operations when possible

6. **Keep Firebase SDK Updated**
   - Latest security patches
   - Performance improvements
   - Bug fixes

7. **Test App Check Before Enforcement**
   - Enable Monitor mode first
   - Check metrics for 1-2 weeks
   - Ensure no false positives
   - Then enable Enforce mode

### Don'ts ❌

1. **Never Commit Debug Tokens to Git**
   - Add to .gitignore
   - Use environment variables
   - Rotate if accidentally committed

2. **Never Share Debug Tokens**
   - Tokens are per-developer
   - Compromise allows bypassing App Check
   - Revoke immediately if shared

3. **Never Disable App Check in Production**
   - Exposes Firebase resources to abuse
   - Allows quota exhaustion
   - Opens door to data scraping

4. **Never Use Debug Providers in Release**
   - Debug providers skip device verification
   - Production apps must use production providers
   - App Store/Play Store rejection risk

5. **Never Ignore Rate Limit Violations**
   - Indicates runaway code or attack
   - Can exhaust Firebase quota
   - Investigate and fix immediately

6. **Never Set Rate Limits Too High**
   - Defeats purpose of rate limiting
   - Allows quota abuse
   - Start conservative, adjust up if needed

7. **Never Skip Platform-Specific Setup**
   - App Attest requires Apple Developer setup
   - Play Integrity requires Google Play enrollment
   - Incomplete setup = App Check failures

### Security Checklist

**Pre-Production:**
- [ ] ✅ App Check enabled for Firestore, Functions, Storage
- [ ] ✅ Monitor mode active for 1-2 weeks
- [ ] ✅ No high violation rates in metrics
- [ ] ✅ All debug tokens deleted
- [ ] ✅ Production providers configured

**Production Launch:**
- [ ] ✅ Switch to Enforce mode
- [ ] ✅ Rate limits configured (1000 req/min)
- [ ] ✅ Monitoring/alerts set up
- [ ] ✅ Rollback plan documented
- [ ] ✅ Team trained on troubleshooting

**Post-Launch:**
- [ ] ✅ Monitor metrics daily (first week)
- [ ] ✅ Check for false positives
- [ ] ✅ Audit debug tokens weekly
- [ ] ✅ Review rate limit violations
- [ ] ✅ Update documentation as needed

---

## 📊 Monitoring and Alerts

### Firebase Console Metrics

**Key Metrics to Monitor:**

1. **App Check Token Validation Rate:**
   - **Good:** >99% success rate
   - **Warning:** 95-99% success rate
   - **Critical:** <95% success rate

2. **Rate Limit Violations:**
   - **Good:** <10 violations/day
   - **Warning:** 10-100 violations/day
   - **Critical:** >100 violations/day

3. **Device Attestation Failures:**
   - **Good:** <1% failure rate
   - **Warning:** 1-5% failure rate
   - **Critical:** >5% failure rate

**Dashboard Setup:**

```bash
# Go to Firebase Console
# Navigation: Project → App Check → Metrics

# Configure dashboard:
# 1. Time Range: Last 7 days
# 2. Granularity: 1 hour
# 3. Filters: All platforms (iOS, Android, Web)
# 4. Charts:
#    - Token validation success rate (line chart)
#    - Rate limit violations (bar chart)
#    - Device attestation failures (pie chart)
```

### Alerting Setup

**Google Cloud Monitoring (Recommended):**

```yaml
# alerting_policy.yaml
displayName: "App Check Token Validation Failure Rate"
conditions:
  - displayName: "High failure rate"
    conditionThreshold:
      filter: 'resource.type = "firebase_app_check"
               AND metric.type = "firebase.googleapis.com/appcheck/token_validation_failure_rate"'
      comparison: COMPARISON_GT
      thresholdValue: 0.05 # 5% failure rate
      duration: 300s # 5 minutes
notificationChannels:
  - projects/gymprogressapp-184bc/notificationChannels/email-dev-team
  - projects/gymprogressapp-184bc/notificationChannels/slack-firebase-alerts
```

**Email Alerts:**
```bash
# Set up in Firebase Console
# Navigation: Project → Alerts

# Create alert:
# Name: "App Check Enforcement Failures"
# Condition: "Token validation failure rate > 5%"
# Duration: 5 minutes
# Notification: email-dev-team@yourcompany.com
```

**Slack Integration:**
```javascript
// Cloud Function: functions/src/alerts.ts
import * as functions from 'firebase-functions';
import { WebClient } from '@slack/web-api';

export const appCheckAlert = functions.firestore
  .document('app_check_violations/{docId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const slack = new WebClient(process.env.SLACK_TOKEN);

    await slack.chat.postMessage({
      channel: '#firebase-alerts',
      text: `🚨 App Check Violation Detected
      Device: ${data.deviceId}
      Platform: ${data.platform}
      Reason: ${data.reason}
      Time: ${data.timestamp}`,
    });
  });
```

### Daily Monitoring Checklist

**Morning Review (5 minutes):**
- [ ] Check Firebase Console → App Check → Metrics
- [ ] Review token validation success rate (should be >99%)
- [ ] Check for rate limit violations (should be <10/day)
- [ ] Review any alerts from previous 24 hours

**Weekly Review (15 minutes):**
- [ ] Analyze trends in App Check metrics
- [ ] Audit debug tokens (delete unused)
- [ ] Review enforcement mode status (all services)
- [ ] Check for platform-specific issues (iOS vs Android)
- [ ] Update documentation if configuration changed

**Monthly Review (30 minutes):**
- [ ] Deep dive into App Check violations
- [ ] Review rate limit thresholds (adjust if needed)
- [ ] Check for new Firebase security updates
- [ ] Audit team access to Firebase Console
- [ ] Test rollback procedures

---

## 📝 Production Deployment Checklist

**Pre-Deployment:**
- [ ] ✅ `lib/main_debug_appcheck.dart` deleted (confirmed)
- [ ] ✅ Production providers configured in `app_check_config.dart`
- [ ] ✅ All debug tokens deleted from Firebase Console
- [ ] ✅ Monitor mode tested for 1-2 weeks (no false positives)
- [ ] ✅ Rate limits configured (1000 req/min per device)
- [ ] ✅ Documentation updated (this file)
- [ ] ✅ Screenshot saved (enforcement enabled)

**Deployment:**
- [ ] Enable Enforce mode for Firestore ✅
- [ ] Enable Enforce mode for Cloud Functions ✅
- [ ] Enable Enforce mode for Firebase Storage ✅
- [ ] Build release APK/IPA with production providers
- [ ] Test on physical devices (iOS and Android)
- [ ] Monitor Firebase Console for first hour
- [ ] Check for spike in validation failures

**Post-Deployment:**
- [ ] Monitor metrics daily for first week
- [ ] Set up alerts for violation thresholds
- [ ] Document any issues encountered
- [ ] Train team on troubleshooting procedures
- [ ] Schedule monthly security audits

---

## 🆘 Support and Resources

### Documentation Links

- **Firebase App Check Official Docs:** https://firebase.google.com/docs/app-check
- **iOS Setup (App Attest):** https://firebase.google.com/docs/app-check/ios/app-attest-provider
- **Android Setup (Play Integrity):** https://firebase.google.com/docs/app-check/android/play-integrity-provider
- **Firebase Security Rules:** https://firebase.google.com/docs/firestore/security/get-started
- **Rate Limiting:** https://firebase.google.com/docs/app-check/quota

### Internal Resources

- **Codebase:** `lib/core/security/app_check_config.dart`
- **Firestore Rules:** `firestore.rules` (App Check validation already deployed)
- **Design Document:** `docs/plans/2025-01-06-security-hardening-design.md`

### Getting Help

**Issues with App Check Setup:**
1. Check [Troubleshooting Guide](#troubleshooting-guide) above
2. Review Firebase Console → App Check → Metrics
3. Check device logs (iOS: Xcode Console, Android: logcat)
4. Contact Firebase Support (support.google.com/firebase)

**Security Concerns:**
1. Review [Security Best Practices](#security-best-practices)
2. Audit Firebase Console → App Check → Debug tokens
3. Check for unauthorized access in Firebase Analytics
4. Contact security team immediately

---

## 📋 Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-06 | Security Team | Initial documentation, Enforce mode enabled |

---

**END OF DOCUMENTATION**

*This documentation is part of the Firebase Security Hardening initiative for GymBro Flutter app. For questions or updates, contact the development team.*

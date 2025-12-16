# 🔐 Firebase Console Configuration Checklist

**Task**: Enable App Check Enforcement Mode
**Status**: ⚠️ **MANUAL ACTION REQUIRED**
**Time Required**: 5-10 minutes
**URL**: https://console.firebase.google.com/project/gymprogressapp-184bc/appcheck/apps

---

## 📝 Overview

This checklist guides you through enabling App Check **Enforce mode** in the Firebase Console. This is a **manual step** that cannot be automated via code.

**Why Manual?**
- Firebase Console enforcement settings are not exposed via API
- Requires human verification to prevent accidental blocking
- Critical security decision that needs explicit approval

---

## ✅ Step-by-Step Instructions

### Step 1: Sign In to Firebase Console

1. **Navigate to Firebase Console:**
   - URL: https://console.firebase.google.com/project/gymprogressapp-184bc/appcheck/apps
   - Sign in with your Google account (must have Owner or Editor role)

2. **Verify Project:**
   - Confirm you're in project: **gymprogressapp-184bc**
   - Check top navigation shows correct project name

### Step 2: Review Current Status

1. **Navigate to App Check Section:**
   - Click **App Check** in left sidebar
   - Click **Apps** tab

2. **Check Current Enforcement Mode:**
   - [ ] Cloud Firestore: Current mode = **Monitor**
   - [ ] Cloud Functions: Current mode = **Monitor**
   - [ ] Firebase Storage: Current mode = **Monitor**

**Monitor Mode** = Logs violations but allows unauthenticated requests (development mode)

### Step 3: Enable Enforcement for Cloud Firestore

1. **Find Firestore Section:**
   - Scroll to **Cloud Firestore** section
   - Current status should show: **Monitor**

2. **Enable Enforce Mode:**
   - [ ] Click **Enforce** button
   - [ ] Confirm dialog: "Enable enforcement for Cloud Firestore?"
   - [ ] Click **Enable**
   - [ ] Wait for confirmation: **Enforce mode enabled**

**Expected Result:**
- Cloud Firestore shows **Enforce** badge (green)
- Invalid App Check tokens are now **blocked**

### Step 4: Enable Enforcement for Cloud Functions

1. **Find Functions Section:**
   - Scroll to **Cloud Functions** section
   - Current status should show: **Monitor**

2. **Enable Enforce Mode:**
   - [ ] Click **Enforce** button
   - [ ] Confirm dialog: "Enable enforcement for Cloud Functions?"
   - [ ] Click **Enable**
   - [ ] Wait for confirmation: **Enforce mode enabled**

**Expected Result:**
- Cloud Functions shows **Enforce** badge (green)
- Calls without valid tokens are **rejected with 403**

### Step 5: Enable Enforcement for Firebase Storage

1. **Find Storage Section:**
   - Scroll to **Firebase Storage** section
   - Current status should show: **Monitor**

2. **Enable Enforce Mode:**
   - [ ] Click **Enforce** button
   - [ ] Confirm dialog: "Enable enforcement for Firebase Storage?"
   - [ ] Click **Enable**
   - [ ] Wait for confirmation: **Enforce mode enabled**

**Expected Result:**
- Firebase Storage shows **Enforce** badge (green)
- Upload/download without tokens are **blocked**

### Step 6: Configure Rate Limiting

1. **Navigate to Rate Limiting:**
   - Click **Rate Limiting** tab in App Check section
   - Or scroll to **Rate Limiting** section

2. **Set Per-Device Limits:**
   - [ ] **Firestore**: Set to **1000 requests/minute per device**
   - [ ] **Functions**: Set to **1000 requests/minute per device**
   - [ ] **Storage**: Set to **1000 requests/minute per device**

3. **Save Configuration:**
   - [ ] Click **Save** button
   - [ ] Wait for confirmation

**Why 1000 req/min?**
- Normal workout session: ~250 requests
- Safety buffer: 4x normal usage
- Prevents quota exhaustion from bugs

### Step 7: Remove Debug Tokens

1. **Navigate to Debug Tokens:**
   - Click **Debug tokens** tab
   - Review list of registered tokens

2. **Delete All Debug Tokens:**
   - [ ] Identify debug tokens (usually have description like "Local development")
   - [ ] Click **Delete** for each token
   - [ ] Confirm deletion
   - [ ] Verify: **0 debug tokens registered**

**Why Delete?**
- Debug tokens bypass App Check verification
- Production should NEVER use debug tokens
- Tokens may have been shared or compromised

### Step 8: Take Screenshot for Documentation

1. **Capture Evidence:**
   - [ ] Take screenshot showing:
     - ✅ Firestore: **Enforce** mode enabled
     - ✅ Functions: **Enforce** mode enabled
     - ✅ Storage: **Enforce** mode enabled
     - ✅ Rate limits: 1000 req/min
     - ✅ Debug tokens: 0 registered

2. **Save Screenshot:**
   - Filename: `firebase-appcheck-enforcement-enabled.png`
   - Location: `docs/screenshots/` (create folder if needed)

---

## ✅ Verification Checklist

**Before closing Firebase Console, verify:**

- [ ] ✅ Cloud Firestore in **Enforce** mode (green badge)
- [ ] ✅ Cloud Functions in **Enforce** mode (green badge)
- [ ] ✅ Firebase Storage in **Enforce** mode (green badge)
- [ ] ✅ Rate limits configured: 1000 req/min per device
- [ ] ✅ All debug tokens deleted (0 registered)
- [ ] ✅ Screenshot saved in `docs/screenshots/`

---

## 🧪 Testing Instructions

**After enabling Enforce mode:**

1. **Wait 5 Minutes:**
   - Enforcement takes ~5 minutes to propagate
   - Don't test immediately

2. **Build Release App:**
   ```bash
   # iOS
   flutter build ios --release

   # Android
   flutter build apk --release
   ```

3. **Test on Physical Device:**
   - Install release build on physical device
   - Launch app
   - Try creating a workout
   - Expected: **Should work normally** (App Check passes)

4. **Monitor Firebase Console:**
   - Go to **App Check → Metrics**
   - Check **Token validation success rate**
   - Expected: **>99% success rate**

5. **Check for Errors:**
   - Go to **Firebase Crashlytics**
   - Filter last 1 hour
   - Look for `SecurityException` or `AppCheckException`
   - Expected: **0 App Check errors**

---

## 🚨 Troubleshooting

### Problem: App Fails After Enabling Enforce Mode

**Symptom:**
```
FirebaseException: [firebase_app_check/fetch-status-error]
Token fetch failed with status: 403
```

**Solution 1: Wait for Propagation**
```bash
# Enforcement takes 5-10 minutes to propagate
# Wait and retry
```

**Solution 2: Check Provider Configuration**
```dart
// lib/core/security/app_check_config.dart
// Ensure production providers:
appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,
androidProvider: AndroidProvider.playIntegrity,
```

**Solution 3: Temporarily Disable Enforce Mode**
```bash
# In Firebase Console:
# 1. Go to App Check → Apps
# 2. Switch back to "Monitor" mode
# 3. Debug the issue
# 4. Re-enable Enforce after fix
```

### Problem: High Validation Failure Rate

**Symptom:**
- Firebase Console shows <95% token validation success rate

**Solution:**
1. Check **App Check → Metrics** for failure reasons
2. Common causes:
   - App not registered in Firebase Console
   - iOS: App Attest not enabled in Apple Developer
   - Android: Play Integrity API not enabled
3. Review setup guide: `docs/FIREBASE_SECURITY.md`

### Problem: Rate Limit Violations

**Symptom:**
```
FirebaseException: [resource-exhausted]
Rate limit exceeded
```

**Solution:**
1. Check **App Check → Metrics → Rate Limit Violations**
2. Identify affected device/user
3. Options:
   - **If legitimate**: Increase rate limits (e.g., 2000 req/min)
   - **If bug**: Fix runaway code causing excessive requests

---

## 📊 Success Metrics

**Monitor these metrics for 24-48 hours:**

| Metric | Good | Warning | Critical |
|--------|------|---------|----------|
| **Token Validation Rate** | >99% | 95-99% | <95% |
| **Rate Limit Violations** | <10/day | 10-100/day | >100/day |
| **Device Attestation Failures** | <1% | 1-5% | >5% |

**Alert Thresholds:**
- 🚨 Token validation rate drops below 95%
- 🚨 Rate limit violations exceed 100/day
- 🚨 New `SecurityException` crashes in Crashlytics

---

## 🔄 Rollback Plan

**If something goes wrong:**

### Emergency Rollback (5 minutes)

1. **Disable Enforce Mode:**
   - Go to Firebase Console → App Check → Apps
   - Switch **Firestore** to **Monitor** mode
   - Switch **Functions** to **Monitor** mode
   - Switch **Storage** to **Monitor** mode
   - Wait 5 minutes for propagation

2. **Verify App Works:**
   - Test app on physical device
   - Create/save workout
   - Should work normally in Monitor mode

3. **Debug Issue:**
   - Review Firebase Console → App Check → Metrics
   - Check device logs for errors
   - Consult troubleshooting guide: `docs/FIREBASE_SECURITY.md`

4. **Fix and Re-Enable:**
   - Fix configuration issue
   - Re-enable Enforce mode
   - Monitor metrics for 1 hour

---

## 📚 Additional Resources

**Documentation:**
- **Full Setup Guide**: `docs/FIREBASE_SECURITY.md` (1,259 lines, comprehensive)
- **Design Document**: `docs/plans/2025-01-06-security-hardening-design.md`
- **App Check Config**: `lib/core/security/app_check_config.dart`

**Firebase Docs:**
- **App Check Official**: https://firebase.google.com/docs/app-check
- **iOS Setup**: https://firebase.google.com/docs/app-check/ios/app-attest-provider
- **Android Setup**: https://firebase.google.com/docs/app-check/android/play-integrity-provider

**Firebase Console Links:**
- **App Check Apps**: https://console.firebase.google.com/project/gymprogressapp-184bc/appcheck/apps
- **Debug Tokens**: https://console.firebase.google.com/project/gymprogressapp-184bc/appcheck/debug
- **Metrics**: https://console.firebase.google.com/project/gymprogressapp-184bc/appcheck/metrics

---

## ✅ Completion Confirmation

**When finished, confirm:**

- [ ] ✅ All enforcement modes enabled
- [ ] ✅ Rate limits configured
- [ ] ✅ Debug tokens deleted
- [ ] ✅ Screenshot saved
- [ ] ✅ App tested on physical device
- [ ] ✅ No errors in Firebase Console
- [ ] ✅ Metrics show >99% success rate

**Sign off:**
- Date completed: ______________
- Completed by: ______________
- Notes: ______________

---

**END OF CHECKLIST**

*This checklist is part of the Firebase Security Hardening initiative for GymBro Flutter app. For questions, consult `docs/FIREBASE_SECURITY.md` or contact the development team.*

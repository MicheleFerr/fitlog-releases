# 🔥 Firestore Quick Fix Checklist

**Date**: 2025-10-20
**Time to Complete**: ~15 minutes
**Difficulty**: Easy (Console-only, no coding)

---

## 🎯 Goal

Fix Firestore connection error: `[cloud_firestore/unavailable]`

---

## ✅ 3-Step Quick Fix

### Step 1: Verify Bundle ID (5 min)

1. Open: https://console.cloud.google.com/apis/credentials?project=gymbro-flutter-new
2. Click: **iOS API Key** (auto-created)
3. Scroll to: **Application restrictions**
4. Check: `com.gymbro.app` is listed under "iOS apps"
5. **If missing**:
   - Click "Add an item"
   - Enter: `com.gymbro.app`
   - Click "Save"

**Expected Result**:
```yaml
Application restrictions:
  Type: iOS apps
  Bundle IDs:
    ✅ com.gymbro.app
```

---

### Step 2: Remove API Restrictions (3 min)

1. Same page (iOS API Key)
2. Scroll to: **API restrictions**
3. Select: **"Don't restrict key"**
4. Click: **"Save"**
5. Wait: **10 minutes** for changes to propagate

**Expected Result**:
```yaml
API restrictions: ✅ Don't restrict key
```

⚠️ **Note**: For production, can re-enable restrictions later with Firestore API whitelisted.

---

### Step 3: Verify Security Rules (2 min)

1. Open: https://console.firebase.google.com/project/gymbro-flutter-new/firestore/rules
2. Check current rule matches:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth.uid != null;
    }
  }
}
```
3. If different: **Copy-paste** rule above
4. Click: **"Publish"**

**Expected Result**:
```
✅ Rules published successfully
✅ Last modified: [today's date]
```

---

## 🧪 Test (5 min)

### Clean Build & Run

```bash
# Terminal
cd /Users/michele/gymbro_flutter_new
flutter clean
flutter run --verbose
```

### Monitor Logs

Look for **SUCCESS** indicators:
```
✅ flutter: 🔄 Refreshing profile from Firestore...
✅ flutter: ✅ Profile refreshed and cached
✅ flutter: 🔍 customWorkoutTemplatesProvider: Got X unified templates
```

Look for **ABSENCE** of errors:
```
❌ NO MORE: [FirebaseFirestore][I-FST000001] Could not reach Cloud Firestore backend
❌ NO MORE: flutter: ❌ Failed to get remote version: [cloud_firestore/unavailable]
```

---

## 🎉 Success Checklist

After waiting 10 minutes from Step 2:

- [ ] App starts without Firestore errors in logs
- [ ] User profile loads from cloud (not just cache)
- [ ] Workout templates sync from Firestore
- [ ] Can create new workout → syncs to cloud
- [ ] Firebase Console → Firestore Data shows new documents

---

## 🐛 Still Failing? (Troubleshooting)

### Issue: Still Getting [unavailable] Error

**Quick Checks**:
```bash
# 1. Waited 10 minutes after Step 2?
# 2. Did flutter clean before testing?
# 3. Testing on physical device (not Simulator)?
```

**Advanced Debug**:
```bash
# Enable Firestore debug logging
# Add to lib/main.dart (after Firebase.initializeApp):
if (kDebugMode) {
  FirebaseFirestore.setLoggingEnabled(true);
}

# Re-run and check logs
flutter run --verbose 2>&1 | tee firestore_debug.log
```

---

## 📖 Detailed Guides

If quick fix doesn't work, see:
- **Full Debug Protocol**: `docs/FIRESTORE_CONNECTION_DEBUG_GUIDE.md`
- **Configuration Verification**: `docs/FIREBASE_CONFIGURATION_VERIFICATION.md`

---

## 📞 Console URLs (Quick Access)

| Resource | URL |
|----------|-----|
| API Credentials | https://console.cloud.google.com/apis/credentials?project=gymbro-flutter-new |
| Firestore Rules | https://console.firebase.google.com/project/gymbro-flutter-new/firestore/rules |
| Firestore Data | https://console.firebase.google.com/project/gymbro-flutter-new/firestore/data |
| Firebase Project | https://console.firebase.google.com/project/gymbro-flutter-new |

---

## ⏱️ Timeline

| Step | Duration | Cumulative |
|------|----------|------------|
| Step 1: Bundle ID | 5 min | 5 min |
| Step 2: API Restrictions | 3 min | 8 min |
| Wait (propagation) | 10 min | 18 min |
| Step 3: Security Rules | 2 min | 20 min |
| Test | 5 min | 25 min |
| **TOTAL** | **~25 min** | **(including wait)** |

---

**Quick Fix Created**: 2025-10-20
**Last Updated**: 2025-10-20
**Status**: ✅ Ready to Execute

**Print this page and follow step-by-step!** 📋

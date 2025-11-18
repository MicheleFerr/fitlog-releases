# 🚀 Notification System v2.0 - Quick Start Guide

**For**: User deploying notification system v2.0 to production
**Time**: 30 minutes (excluding manual testing)
**Prerequisites**: Firebase CLI installed, project configured

---

## ⚡ 3-Step Deployment

### Step 1: Firebase Deployment (5 min)

```bash
# Navigate to project root
cd /Users/michele/gymbro_flutter_new

# Deploy all Firebase components (rules + indexes + functions)
./firebase/deploy_notification_v2.sh

# OR deploy individually:
# firebase deploy --only firestore:rules
# firebase deploy --only firestore:indexes
# firebase deploy --only functions
```

**What this deploys**:
- ✅ Firestore security rules (v2.0 NotificationSettings validation)
- ✅ 3 composite indexes (for history queries)
- ✅ 3 Cloud Functions (cleanup scheduler + test function + GDPR deletion)

**Verify deployment**:
```bash
# Check indexes building (takes 5-10 min)
firebase firestore:indexes

# Check Cloud Scheduler job created
gcloud scheduler jobs list | grep notificationCleanup
```

---

### Step 2: App Integration (15 min)

#### 2A. Initialize SharedPreferences Provider

**File**: `lib/main.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override SharedPreferences provider with instance
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}
```

#### 2B. Add Navigation Route

**File**: `lib/shared/presentation/routes/app_routes.dart` (or your routes file)

```dart
// Add route constant
static const notificationSettingsV2 = '/notification-settings-v2';

// Add route mapping
case AppRoutes.notificationSettingsV2:
  return MaterialPageRoute(
    builder: (_) => const NotificationSettingsScreenV2(),
  );
```

#### 2C. Update Settings Screen Link

**File**: `lib/features/settings/presentation/settings_screen.dart` (or equivalent)

```dart
import 'package:gymbro_flutter_new/features/notifications/presentation/screens/notification_settings_screen_v2.dart';

// Replace old notification settings tile with:
ListTile(
  leading: Icon(AppIcons.notifications, size: AppIconSize.medium),
  title: Text(context.l10n.notificationSettings),
  subtitle: Text('Manage notification preferences'), // Optional
  onTap: () => Navigator.pushNamed(context, AppRoutes.notificationSettingsV2),
)
```

#### 2D. Show GDPR Consent on First Launch (Optional)

**File**: `lib/features/onboarding/presentation/onboarding_screen.dart` (or main.dart)

```dart
import 'package:gymbro_flutter_new/features/notifications/presentation/widgets/privacy_consent_dialog.dart';

// After onboarding or on first app launch:
Future<void> _showConsentDialogIfNeeded(BuildContext context, WidgetRef ref) async {
  final settings = await ref.read(notificationSettingsV2Provider.future);

  if (!settings.hasValidConsent) {
    final consented = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Force decision
      builder: (_) => const PrivacyConsentDialog(consentVersion: '1.0'),
    );

    if (consented != true) {
      // User declined - disable notifications
      final updatedSettings = settings.copyWith(
        enableWorkoutReminders: false,
        enableRecoveryAlerts: false,
        enableStreakMotivation: false,
      );
      await ref.read(notificationSettingsV2Provider.notifier).updateSettings(updatedSettings);
    }
  }
}
```

---

### Step 3: Verification (10 min)

#### 3A. Code Compilation Check

```bash
# Ensure code compiles without errors
flutter analyze

# Expected: Notification v2.0 files should have 0 errors
# (Pre-existing 4050 issues are unrelated to v2.0)
```

#### 3B. Migration Test (Simulator)

```bash
# Run app in simulator with v1.0 settings
flutter run

# Expected behavior:
# 1. App launches successfully
# 2. Settings migrate from v1.0 → v2.0 automatically
# 3. Old v1.0 SharedPreferences keys deleted
# 4. New v2.0 settings visible in Firestore Console
```

#### 3C. Firestore Verification

1. Open Firebase Console > Firestore Database
2. Navigate to: `users/{YOUR_USER_ID}/notificationSettings`
3. Verify document contains v2.0 fields:
   - `settingsVersion: 2`
   - `frequencyCapPreferences: {...}`
   - `consentTimestamp: timestamp`
   - `dataRetentionDays: 90`

#### 3D. Cloud Functions Test

```bash
# Test cleanup logic (no actual deletion)
curl -X POST https://us-central1-YOUR_PROJECT.cloudfunctions.net/testNotificationCleanup \
  -H "Content-Type: application/json" \
  -d '{"userId": "YOUR_TEST_USER_ID"}'

# Expected response:
# {
#   "success": true,
#   "userId": "...",
#   "retentionDays": 90,
#   "oldEntriesCount": 0,
#   "message": "Test completed (no data deleted)"
# }
```

---

## 📋 Post-Deployment Checklist

- [ ] ✅ Firebase deployed (rules + indexes + functions)
- [ ] ✅ Cloud Scheduler job created (`gcloud scheduler jobs list`)
- [ ] ✅ SharedPreferences provider initialized in `main.dart`
- [ ] ✅ Navigation route added for `NotificationSettingsScreenV2`
- [ ] ✅ Settings screen link updated
- [ ] ✅ GDPR consent dialog shown on first launch (optional)
- [ ] ✅ Migration tested (v1.0 → v2.0 automatic)
- [ ] ✅ Firestore settings verified in Console
- [ ] ✅ Cloud Functions tested (testNotificationCleanup)
- [ ] ⏳ **Manual device testing** (user will do)

---

## 🐛 Common Issues & Fixes

### Issue 1: "Missing sharedPreferencesProvider"

**Error**: `Provider was not found`

**Fix**: Add override in `main.dart`:
```dart
final prefs = await SharedPreferences.getInstance();
runApp(
  ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: MyApp(),
  ),
);
```

### Issue 2: "User not authenticated" (Cloud Functions)

**Error**: `Unauthenticated` when calling `deleteUserNotificationData`

**Fix**: Ensure user is signed in with Firebase Auth:
```dart
final user = FirebaseAuth.instance.currentUser;
if (user == null) throw Exception('User not authenticated');
```

### Issue 3: Firestore indexes not built

**Error**: `The query requires an index`

**Fix**:
1. Click error link in Firebase Console (auto-creates index)
2. Or wait 5-10 minutes for index building to complete
3. Check status: `firebase firestore:indexes`

### Issue 4: Migration not triggering

**Issue**: Settings still show as v1.0

**Fix**: Delete app data and reinstall (forces fresh migration):
```bash
# iOS Simulator
xcrun simctl uninstall booted com.your.bundle.id
flutter run

# Android Emulator
adb uninstall com.your.bundle.id
flutter run
```

---

## 🧪 Manual Testing Scenarios (User Will Do)

### Scenario 1: v1.0 → v2.0 Migration
1. Install app with v1.0 settings (from previous version)
2. Update to v2.0 build
3. Launch app
4. Verify:
   - ✅ Settings migrated (all 11 v1.0 fields preserved)
   - ✅ New v2.0 fields added (frequency caps, quiet hours, etc.)
   - ✅ Old v1.0 keys deleted from SharedPreferences

### Scenario 2: Cross-Device Sync
1. Configure settings on Device A (iPhone)
2. Wait 5 minutes (debounce delay)
3. Open app on Device B (iPad) with same user account
4. Verify:
   - ✅ Settings synced from Device A
   - ✅ Changes on Device B sync back to Device A

### Scenario 3: GDPR Consent Flow
1. Fresh install (no existing consent)
2. Launch app → consent dialog appears
3. Test paths:
   - **Decline** → verify no data collection
   - **Accept** → verify `consentTimestamp` recorded
   - **Revoke** → verify dialog confirmation
   - **Delete All** → verify complete erasure

### Scenario 4: Frequency Caps
1. Set cap: 2/day, 3/week
2. Trigger notifications:
   - 2 in same day → verify 3rd blocked
   - 3 across week → verify 4th blocked
3. Verify cap resets at midnight (daily) and Monday (weekly)

### Scenario 5: Quiet Hours
1. Set quiet hours: 22:00 - 08:00 (overnight)
2. Schedule notifications:
   - 23:00 → verify blocked
   - 09:00 → verify delivered
3. Test priority bypass (allow high-priority during quiet hours)

### Scenario 6: Data Retention Cleanup
1. Set retention: 30 days
2. Create old notification history (35 days ago manually)
3. Wait for scheduled cleanup (2:00 AM UTC) OR trigger manually:
   ```bash
   gcloud scheduler jobs run firebase-schedule-notificationCleanup-YOUR_REGION
   ```
4. Verify:
   - ✅ Old entries (>30 days) deleted
   - ✅ Recent entries (<30 days) preserved

---

## 📊 Success Metrics (Week 1)

Monitor these in Firebase Console:

| Metric | Target | Where to Check |
|--------|--------|----------------|
| User adoption | >95% on v2.0 | Firestore: Count docs with `settingsVersion: 2` |
| Migration success | 100% | Cloud Functions logs: Check for errors |
| Consent rate | >80% | Firestore: Count docs with `consentTimestamp != null` |
| Sync success | >99% | Cloud Functions logs: Check sync errors |
| Cloud Function uptime | 100% | Cloud Scheduler: Check job runs |
| Firestore cost reduction | -80% | Firebase Usage dashboard |

---

## 📚 Full Documentation

**Complete guides**:
- Technical: `docs/features/notifications/NOTIFICATION_SYSTEM_V2_COMPLETE_DOCUMENTATION.md`
- Release notes: `docs/features/notifications/RELEASE_NOTES_V2.md`
- Integration checklist: `docs/features/notifications/INTEGRATION_CHECKLIST.md`
- Firebase deployment: `firebase/DEPLOYMENT_GUIDE.md`
- Autonomous completion report: `docs/features/notifications/AUTONOMOUS_COMPLETION_REPORT.md`

**Quick commands**:
```bash
# Deploy Firebase
./firebase/deploy_notification_v2.sh

# Test Cloud Functions
curl https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/testNotificationCleanup

# Check indexes
firebase firestore:indexes

# View Cloud Function logs
firebase functions:log --only notificationCleanup

# Manual cleanup trigger
gcloud scheduler jobs run firebase-schedule-notificationCleanup-YOUR_REGION
```

---

**🎉 You're ready to deploy Notification System v2.0!**

**Estimated total time**: 30 min (Firebase + integration) + your manual testing time

**Next step**: Run `./firebase/deploy_notification_v2.sh`

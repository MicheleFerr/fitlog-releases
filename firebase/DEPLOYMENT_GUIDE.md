# 🚀 Firebase Deployment Guide - Notification System v2.0

Complete guide for deploying Firestore security rules, indexes, and Cloud Functions for the notification system v2.0.

---

## 📋 Prerequisites

- Firebase CLI installed: `npm install -g firebase-tools`
- Firebase project initialized: `firebase init`
- Authenticated: `firebase login`
- Node.js 14+ (for Cloud Functions)

---

## 1. 🔐 Firestore Security Rules

### Deploy Security Rules

```bash
# Deploy from project root
firebase deploy --only firestore:rules

# Or specify rules file explicitly
firebase deploy --only firestore:rules --project your-project-id
```

### Rules File Location

- **Source**: `firebase/firestore_security_rules_v2.rules`
- **Target**: Firebase Console > Firestore Database > Rules

### Verify Deployment

```bash
# Test rules in Firebase Console > Firestore > Rules > Rules Playground

# Test case 1: User can read own settings
# - Authentication: user-id-123
# - Location: /users/user-id-123/notificationSettings
# - Operation: get
# Expected: ✅ Allow

# Test case 2: User cannot read other user's settings
# - Authentication: user-id-123
# - Location: /users/user-id-456/notificationSettings
# - Operation: get
# Expected: ❌ Deny

# Test case 3: Valid v2.0 settings write
# - Authentication: user-id-123
# - Location: /users/user-id-123/notificationSettings
# - Operation: create
# - Data: { settingsVersion: 2, enableWorkoutReminders: true, ... }
# Expected: ✅ Allow

# Test case 4: Invalid settings write (missing required fields)
# - Authentication: user-id-123
# - Location: /users/user-id-123/notificationSettings
# - Operation: create
# - Data: { settingsVersion: 2 } (missing required fields)
# Expected: ❌ Deny
```

---

## 2. 🗂️ Firestore Indexes

### Required Composite Indexes

**Index 1: Notification history query by timestamp**

```
Collection: users/{userId}/notificationHistory
Fields:
  - timestamp (Ascending)
Query scopes: Collection
```

**Index 2: Notification history query by type and timestamp**

```
Collection: users/{userId}/notificationHistory
Fields:
  - type (Ascending)
  - timestamp (Descending)
Query scopes: Collection
```

**Index 3: Notification history unread filter**

```
Collection: users/{userId}/notificationHistory
Fields:
  - isRead (Ascending)
  - timestamp (Descending)
Query scopes: Collection
```

### Create Indexes (Option 1: Firebase Console)

1. Go to Firebase Console > Firestore Database > Indexes
2. Click "Create Index"
3. Configure index as shown above
4. Click "Create"

### Create Indexes (Option 2: firestore.indexes.json)

Create `firebase/firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "notificationHistory",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "timestamp",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "notificationHistory",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "type",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "timestamp",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "notificationHistory",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "isRead",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "timestamp",
          "order": "DESCENDING"
        }
      ]
    }
  ],
  "fieldOverrides": []
}
```

Deploy indexes:

```bash
firebase deploy --only firestore:indexes
```

### Verify Indexes

```bash
# Check index status
firebase firestore:indexes

# Expected output:
# ✔ notificationHistory (timestamp ASC) - READY
# ✔ notificationHistory (type ASC, timestamp DESC) - READY
# ✔ notificationHistory (isRead ASC, timestamp DESC) - READY
```

---

## 3. ⚡ Cloud Functions

### Setup Cloud Functions

```bash
# Navigate to functions directory
cd firebase/functions

# Install dependencies
npm install firebase-functions@latest firebase-admin@latest

# Verify package.json has:
# - firebase-functions: ^4.0.0 or later
# - firebase-admin: ^11.0.0 or later
# - node: 14 or higher (engines field)
```

### Deploy Cloud Functions

```bash
# Deploy all notification-related functions
firebase deploy --only functions:notificationCleanup,functions:testNotificationCleanup,functions:deleteUserNotificationData

# Or deploy individually
firebase deploy --only functions:notificationCleanup
firebase deploy --only functions:testNotificationCleanup
firebase deploy --only functions:deleteUserNotificationData
```

### Cloud Scheduler Setup (for notificationCleanup)

The `notificationCleanup` function runs on a schedule (daily at 2:00 AM UTC). Cloud Scheduler must be enabled:

```bash
# Enable Cloud Scheduler API
gcloud services enable cloudscheduler.googleapis.com

# Verify scheduler job created (after first deploy)
gcloud scheduler jobs list

# Expected output:
# ID: firebase-schedule-notificationCleanup-{region}
# SCHEDULE: 0 2 * * *
# TIME_ZONE: UTC
# STATE: ENABLED
```

### Test Cloud Functions

**Test 1: Manual cleanup test**

```bash
# Test cleanup logic for a specific user (no data deleted)
curl -X POST https://us-central1-{project-id}.cloudfunctions.net/testNotificationCleanup \
  -H "Content-Type: application/json" \
  -d '{"userId": "your-test-user-id"}'

# Expected response:
# {
#   "success": true,
#   "userId": "your-test-user-id",
#   "retentionDays": 90,
#   "cutoffDate": "2024-10-15T02:00:00.000Z",
#   "oldEntriesCount": 12,
#   "message": "Test completed (no data deleted)"
# }
```

**Test 2: GDPR deletion (callable function)**

```dart
// From Flutter app
import 'package:cloud_functions/cloud_functions.dart';

final functions = FirebaseFunctions.instance;
final result = await functions.httpsCallable('deleteUserNotificationData').call();

print(result.data);
// Expected: { success: true, settingsDeleted: 1, historyDeleted: 45, message: "..." }
```

**Test 3: Scheduled cleanup (manual trigger)**

```bash
# Manually trigger scheduled function (requires Cloud Console)
# 1. Go to Cloud Console > Cloud Scheduler
# 2. Find job: firebase-schedule-notificationCleanup-{region}
# 3. Click "RUN NOW"
# 4. Check Cloud Functions logs:
firebase functions:log --only notificationCleanup --lines 50
```

---

## 4. 📊 Monitoring & Logs

### View Cloud Function Logs

```bash
# View logs for scheduled cleanup
firebase functions:log --only notificationCleanup

# View logs for GDPR deletion
firebase functions:log --only deleteUserNotificationData

# Follow logs in real-time
firebase functions:log --only notificationCleanup --follow
```

### Firebase Console Monitoring

1. Go to Firebase Console > Functions
2. Click on function name (e.g., `notificationCleanup`)
3. View metrics:
   - Invocations
   - Execution time
   - Memory usage
   - Error rate

### Set Up Alerts

1. Go to Firebase Console > Functions > Health
2. Click "Create Alert"
3. Configure:
   - **Metric**: Error rate
   - **Threshold**: > 5% for 5 minutes
   - **Notification**: Email to admin

---

## 5. 🧪 Integration Testing

### Test Full Workflow

**Step 1: Create test user with v2.0 settings**

```dart
// Flutter app
final settings = NotificationSettings.defaults().copyWith(
  consentTimestamp: DateTime.now(),
  dataRetentionDays: 30, // Short retention for testing
  enableAnalytics: true,
);

await ref.read(notificationSettingsV2Provider.notifier).updateSettings(settings);
```

**Step 2: Create old notification history entries**

```dart
// Create entries with timestamps > 30 days ago
final oldEntry = NotificationHistoryEntry(
  id: 'test-entry-1',
  type: NotificationType.workoutReminder,
  title: 'Old notification',
  body: 'This should be deleted',
  timestamp: DateTime.now().subtract(const Duration(days: 35)),
  isRead: true,
);

await historyRepository.saveEntry(oldEntry);
```

**Step 3: Wait for scheduled cleanup (or trigger manually)**

```bash
# Manually trigger cleanup
gcloud scheduler jobs run firebase-schedule-notificationCleanup-{region}

# Check logs
firebase functions:log --only notificationCleanup --lines 20
```

**Step 4: Verify old entries deleted**

```dart
// Query all entries
final allEntries = await historyRepository.getAllEntries();

// Verify: No entries older than 30 days
final hasOldEntries = allEntries.any((entry) =>
  entry.timestamp.isBefore(DateTime.now().subtract(const Duration(days: 30)))
);

expect(hasOldEntries, false); // Should be false
```

---

## 6. 🔒 Security Checklist

Before production deployment:

- [ ] ✅ Firestore security rules deployed and tested
- [ ] ✅ All composite indexes created (3 total)
- [ ] ✅ Cloud Functions deployed (3 functions)
- [ ] ✅ Cloud Scheduler enabled and job created
- [ ] ✅ Test manual cleanup function (testNotificationCleanup)
- [ ] ✅ Test GDPR deletion function (deleteUserNotificationData)
- [ ] ✅ Test scheduled cleanup (notificationCleanup)
- [ ] ✅ Monitoring alerts configured
- [ ] ✅ Function logs verified (no errors)
- [ ] ✅ Cost estimates reviewed (Cloud Functions, Firestore writes)

---

## 7. 💰 Cost Estimation

### Firestore Costs

**Assumptions**:
- 1000 active users
- Average 5 notifications/week per user
- 90-day retention (default)

**Monthly Costs**:
- **Writes**: 20,000/month (1000 users × 5 notif/week × 4 weeks) = $0.36
- **Reads**: 40,000/month (2× writes for sync + queries) = $0.14
- **Storage**: 1000 users × 90 days × 5 notif/week × 1KB = 1.8 GB = $0.32
- **Deletions**: 20,000/month (cleanup) = $0.04

**Total Firestore**: ~$0.86/month

### Cloud Functions Costs

**Assumptions**:
- notificationCleanup: Daily (30 invocations/month)
- Average 2 seconds execution time
- 256 MB memory

**Monthly Costs**:
- **Invocations**: 30/month = FREE (2M free tier)
- **Compute time**: 30 × 2s × 256MB = FREE (400,000 GB-seconds free tier)
- **Network egress**: <1 GB = FREE (5 GB free tier)

**Total Cloud Functions**: $0.00/month (within free tier)

### Total Monthly Cost (1000 users)

**~$0.86/month** (Firestore only)

**Cost Optimization Tips**:
1. Use debounced writes (already implemented, -80% writes)
2. Enable TTL for old documents (Firestore native TTL)
3. Batch cleanup operations (already implemented)
4. Cache frequently accessed settings locally (already implemented)

---

## 8. 🚨 Troubleshooting

### Issue 1: Security rules deployment fails

**Error**: `Permission denied: Missing or insufficient permissions.`

**Solution**:
```bash
# Check Firebase project permissions
firebase projects:list

# Re-authenticate
firebase login --reauth

# Use specific project
firebase use your-project-id
```

### Issue 2: Cloud Function not triggering on schedule

**Error**: Scheduled function doesn't run at 2:00 AM UTC

**Solution**:
```bash
# Verify Cloud Scheduler job exists
gcloud scheduler jobs list

# Check job status
gcloud scheduler jobs describe firebase-schedule-notificationCleanup-{region}

# Verify time zone
gcloud scheduler jobs describe firebase-schedule-notificationCleanup-{region} | grep timezone

# Manually trigger to test
gcloud scheduler jobs run firebase-schedule-notificationCleanup-{region}
```

### Issue 3: Firestore index not building

**Error**: `The query requires an index`

**Solution**:
1. Click on error link in Firebase Console (auto-creates index)
2. Or manually create index in Firestore > Indexes
3. Wait for index to build (can take 5-10 minutes)
4. Retry query

### Issue 4: GDPR deletion function fails

**Error**: `Unauthenticated`

**Solution**:
```dart
// Ensure user is authenticated before calling
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
  throw Exception('User not authenticated');
}

final result = await functions.httpsCallable('deleteUserNotificationData').call();
```

---

## 9. 📚 References

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Cloud Functions for Firebase](https://firebase.google.com/docs/functions)
- [Cloud Scheduler Documentation](https://cloud.google.com/scheduler/docs)
- [Firestore Indexes](https://firebase.google.com/docs/firestore/query-data/indexing)
- [GDPR Compliance Guide](https://firebase.google.com/support/privacy)

---

**Deployment Status**: 🟡 Pending deployment (files ready)

**Next Steps**:
1. Deploy Firestore security rules
2. Create Firestore indexes
3. Deploy Cloud Functions
4. Run integration tests
5. Enable production monitoring

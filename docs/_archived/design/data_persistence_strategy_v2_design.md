# Data Layer & Persistence Strategy v2.0 Design

**Document Version**: 1.0
**Created**: 2025-01-16
**Author**: Claude Code (task-master.dev integration)
**Status**: ✅ Design Complete - Ready for Implementation
**Phase**: PHASE 3: DESIGN - Task 3.5

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Current State Analysis](#current-state-analysis)
3. [Persistence Architecture](#persistence-architecture)
4. [Firestore Schema Design](#firestore-schema-design)
5. [SharedPreferences Strategy](#sharedpreferences-strategy)
6. [Cross-Device Synchronization](#cross-device-synchronization)
7. [Repository Layer Updates](#repository-layer-updates)
8. [Data Migration Strategy](#data-migration-strategy)
9. [Performance & Optimization](#performance--optimization)
10. [Privacy & GDPR Compliance](#privacy--gdpr-compliance)
11. [Error Handling & Resilience](#error-handling--resilience)
12. [Implementation Checklist](#implementation-checklist)

---

## 1. Executive Summary

### 🎯 Objectives

Design a **robust, scalable data persistence strategy** for the notification system v2.0 that:

1. ✅ **Supports NotificationSettings v2.0** with 22 fields (12 new from Task 3.2)
2. ✅ **Cross-device sync** via Firestore with conflict resolution
3. ✅ **90-day notification history** with efficient querying
4. ✅ **GDPR-compliant data retention** (explicit consent, deletion)
5. ✅ **Offline-first architecture** with local cache + background sync
6. ✅ **Migration path** from v1.0 (SharedPreferences only) to v2.0 (Firestore + local)
7. ✅ **Performance optimized** for mobile (minimal reads/writes, batch operations)

### 📊 Key Metrics

| Metric | Target | Strategy |
|--------|--------|----------|
| **Firestore Reads/Day** | <100 per user | Aggressive caching, sync only on change |
| **Firestore Writes/Day** | <20 per user | Batch updates, debouncing (5min) |
| **Sync Latency** | <2 seconds | Last-write-wins, no complex merging |
| **Offline Support** | 100% | SharedPreferences fallback |
| **Data Retention** | 90 days (history) | Auto-cleanup background task |
| **Storage Size** | <5MB per user | Efficient schema, compressed JSON |

### 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                          │
│  (NotificationSettingsScreen, NotificationCenterScreen)     │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│              RIVERPOD PROVIDERS                              │
│  (notificationSettingsProvider, notificationHistoryProvider) │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│           REPOSITORY LAYER (Domain Interface)                │
│  NotificationRepository + NotificationSettingsRepository     │
└─────────────────┬───────────────────────────────────────────┘
                  │
        ┌─────────┴──────────┐
        ▼                    ▼
┌──────────────────┐  ┌──────────────────┐
│ DATA LAYER       │  │ DATA LAYER       │
│ Local Source     │  │ Remote Source    │
│ (SharedPref)     │  │ (Firestore)      │
└──────────────────┘  └──────────────────┘
        │                    │
        └─────────┬──────────┘
                  ▼
        ┌──────────────────┐
        │  SYNC MANAGER    │
        │  (Debounce +     │
        │   Conflict Res.) │
        └──────────────────┘
```

**Dual-Source Strategy**:
- **Local (SharedPreferences)**: Instant access, offline support, cache layer
- **Remote (Firestore)**: Cross-device sync, backup, analytics aggregation
- **Sync Manager**: Coordinates local ↔ remote sync with last-write-wins

---

## 2. Current State Analysis

### 📦 v1.0 Implementation (Current)

**NotificationSettings Persistence** (`notification_providers.dart`):

```dart
// Current v1.0 approach (SharedPreferences only)
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationSettings(
      enableWorkoutReminders: prefs.getBool('notif_workout_reminders') ?? true,
      enableRecoveryAlerts: prefs.getBool('notif_recovery_alerts') ?? true,
      enableStreakMotivation: prefs.getBool('notif_streak_motivation') ?? false,
      enableRestDayReminders: prefs.getBool('notif_rest_day_reminders') ?? false,
      preferredTime: NotificationTimePreference.values[
        prefs.getInt('notif_preferred_time') ?? 0
      ],
      customTime: _parseCustomTime(prefs.getString('notif_custom_time')),
      enableSmartScheduling: prefs.getBool('notif_smart_scheduling') ?? true,
      doNotDisturbEnabled: prefs.getBool('notif_dnd_enabled') ?? false,
      doNotDisturbStart: _parseTime(prefs.getString('notif_dnd_start')),
      doNotDisturbEnd: _parseTime(prefs.getString('notif_dnd_end')),
      reminderMinutesBefore: prefs.getInt('notif_reminder_minutes') ?? 60,
    );
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_workout_reminders', state.enableWorkoutReminders);
    await prefs.setBool('notif_recovery_alerts', state.enableRecoveryAlerts);
    // ... 11 more individual saves (inefficient!)
  }
}
```

**Problems with v1.0**:
1. ❌ **No cross-device sync** - settings lost when switching devices
2. ❌ **Inefficient writes** - 11+ individual `setBool/setInt` calls per update
3. ❌ **No GDPR compliance** - no consent tracking, no explicit deletion
4. ❌ **No notification history** - can't show past notifications
5. ❌ **No analytics** - can't track delivery rates, engagement
6. ❌ **No versioning** - hard to migrate schema in future
7. ❌ **Tightly coupled** - SharedPreferences logic in Notifier (should be in repository)

**Notification History** (v1.0):
- **Status**: ❌ Not implemented
- flutter_local_notifications provides only pending notifications (future), not history (past)
- No local database (Hive/SQLite)
- No Firestore collection

**Delivery Tracking** (v1.0):
- **Status**: ❌ Stub implementations only (see `local_notification_repository.dart:432-632`)
- All methods return mock/empty data
- No real delivery receipts, metrics, or error tracking

---

## 3. Persistence Architecture

### 🏛️ Three-Tier Persistence Model

```
┌────────────────────────────────────────────────────────────┐
│  TIER 1: IN-MEMORY CACHE (Riverpod State)                  │
│  - Duration: Session lifetime                               │
│  - Purpose: UI reactivity, instant updates                  │
│  - Storage: Dart objects in StateNotifier                   │
└────────────────────────────────────────────────────────────┘
                        ▼
┌────────────────────────────────────────────────────────────┐
│  TIER 2: LOCAL PERSISTENCE (SharedPreferences)             │
│  - Duration: Permanent (until app uninstall)                │
│  - Purpose: Offline support, fast cold-start               │
│  - Storage: JSON strings in SharedPreferences              │
│  - Sync: Read on app start, write on every change          │
└────────────────────────────────────────────────────────────┘
                        ▼
┌────────────────────────────────────────────────────────────┐
│  TIER 3: REMOTE PERSISTENCE (Firestore)                    │
│  - Duration: Permanent (until user deletion)                │
│  - Purpose: Cross-device sync, backup, analytics           │
│  - Storage: Firestore documents                             │
│  - Sync: Debounced (5min) + manual trigger                 │
└────────────────────────────────────────────────────────────┘
```

### 📁 Data Sources

#### **Local Data Source** (`NotificationLocalDataSource`)

**Responsibilities**:
- ✅ Read/write NotificationSettings from SharedPreferences
- ✅ Read/write notification history (last 7 days) from SharedPreferences
- ✅ Caching layer for Firestore data (reduces reads)
- ✅ Offline fallback when Firestore unavailable

**Technology**: SharedPreferences (Flutter standard)

**Why SharedPreferences over Hive/SQLite?**
- ✅ Simpler API, no schema migrations
- ✅ Already used in app (consistent pattern)
- ✅ Sufficient for <5MB data (our use case)
- ✅ Key-value store = perfect for settings

**Schema**:
```dart
// Single JSON string per entity type
SharedPreferences keys:
  'notification_settings_v2'       // NotificationSettings JSON
  'notification_history_ids'       // List<String> (last 100 IDs)
  'notification_history_{id}'      // Individual notification JSON
  'notification_delivery_{id}'     // Delivery receipt JSON
  'notification_metrics'           // Aggregated metrics JSON
  'notification_last_sync'         // DateTime ISO8601
```

#### **Remote Data Source** (`NotificationRemoteDataSource`)

**Responsibilities**:
- ✅ Read/write NotificationSettings to Firestore
- ✅ Read/write notification history (90 days) to Firestore
- ✅ Read/write delivery receipts to Firestore
- ✅ Aggregate analytics queries

**Technology**: Firestore (Firebase)

**Why Firestore?**
- ✅ Real-time sync across devices
- ✅ Offline support built-in (local cache)
- ✅ Powerful querying (date ranges, filters)
- ✅ Automatic indexing
- ✅ ACID transactions (atomic updates)
- ✅ Already integrated in app

**Collections Structure** (see Section 4 for detailed schema):
```
users/{userId}/
  └─ notificationSettings (document)
  └─ notificationHistory/{notificationId} (collection)
  └─ notificationDelivery/{notificationId} (collection)
  └─ notificationMetrics (document)
```

---

## 4. Firestore Schema Design

### 📄 Collection: `users/{userId}/notificationSettings`

**Document Structure** (v2.0 - aligned with Task 3.2 design):

```typescript
{
  // === v1.0 Fields (Backward Compatible) ===
  enableWorkoutReminders: boolean;           // true
  enableRecoveryAlerts: boolean;             // true
  enableStreakMotivation: boolean;           // false
  enableRestDayReminders: boolean;           // false
  preferredTime: string;                     // 'morning' | 'afternoon' | 'evening' | 'custom'
  customTime: Timestamp | null;              // If preferredTime = 'custom'
  enableSmartScheduling: boolean;            // true
  doNotDisturbEnabled: boolean;              // false
  doNotDisturbStart: Timestamp | null;       // 22:00
  doNotDisturbEnd: Timestamp | null;         // 08:00
  reminderMinutesBefore: number;             // 60

  // === v2.0 New Fields (From Task 3.2) ===

  // Custom Time Per Notification Type
  customTimePerType: {
    [key: string]: Timestamp;                // 'workoutReminder' -> 09:00, 'recoveryAlert' -> 18:00
  };

  // Per-Category Quiet Hours
  categoryQuietHours: {
    [key: string]: {
      startTime: Timestamp;
      endTime: Timestamp;
      allowPriorityBypass: boolean;
      daysOfWeek: number[];                  // [1,2,3,4,5] = Mon-Fri
    };
  };

  // Frequency Caps (Research-Backed Defaults)
  frequencyCapPreferences: {
    maxPerDay: number;                       // 3
    maxPerWeek: number;                      // 5 (research: 64% quit if >5/week)
    minIntervalHours: number;                // 2
  };

  categoryFrequencyCaps: {
    [key: string]: {
      maxPerDay: number;
      maxPerWeek: number;
      minIntervalHours: number;
    };
  };

  // GDPR Compliance (Article 7.1)
  consentTimestamp: Timestamp | null;        // When user explicitly opted in
  consentVersion: string;                    // '1.0' (for future consent changes)
  enableAnalytics: boolean;                  // false (opt-in required)
  dataRetentionDays: number;                 // 90 (GDPR Article 5.1.e)

  // Cross-Device Sync Metadata
  lastSyncedAt: Timestamp;                   // Server-side timestamp
  deviceId: string;                          // Last device that modified settings
  settingsVersion: number;                   // 2 (schema version for migrations)

  // Platform Permissions (iOS/Android)
  platformPermissions: {
    granted: boolean;
    requestedAt: Timestamp | null;
    deniedAt: Timestamp | null;
    platform: string;                        // 'ios' | 'android'
  };

  // Audit Trail
  createdAt: Timestamp;                      // Server-side timestamp
  updatedAt: Timestamp;                      // Server-side timestamp
  migrationSource: string | null;            // 'v1_sharedprefs' if migrated
}
```

**Indexes** (for Firestore queries):
```typescript
// Single-field indexes (automatic)
- lastSyncedAt (DESC) - Find recently synced users
- settingsVersion (ASC) - Migration queries
- consentTimestamp (DESC) - GDPR audit

// Composite indexes (manual creation required)
- [enableWorkoutReminders, enableRecoveryAlerts] - Quick opt-out check
```

**Security Rules** (`firestore.rules`):
```javascript
match /users/{userId}/notificationSettings {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow write: if request.auth != null
                && request.auth.uid == userId
                && request.resource.data.settingsVersion is number
                && request.resource.data.settingsVersion >= 2; // Prevent downgrades
}
```

**Document Size Estimate**:
- **v1.0 fields**: ~400 bytes
- **v2.0 new fields**: ~800 bytes
- **Total**: ~1.2 KB (well within Firestore 1MB limit)

---

### 📄 Collection: `users/{userId}/notificationHistory/{notificationId}`

**Document Structure**:

```typescript
{
  // Notification Identity
  id: string;                                // 'notif_2025_01_15_abc123'
  type: string;                              // 'workoutReminder' | 'recoveryAlert' | 'achievement' | 'streakMotivation'

  // Content
  title: string;                             // 'Time for Leg Day! 💪'
  body: string;                              // 'Your routine "Push Day" is ready to start'
  imageUrl: string | null;                   // Optional rich media

  // Scheduling
  scheduledTime: Timestamp;                  // When notification was scheduled to appear
  deliveredAt: Timestamp | null;             // When actually delivered (null if not yet)
  readAt: Timestamp | null;                  // When user opened/interacted

  // Context
  workoutId: string | null;                  // Associated workout/routine ID
  payload: {                                 // Deep-link data
    [key: string]: any;
  };

  // Priority & Behavior
  priority: string;                          // 'low' | 'normal' | 'high' | 'critical'
  category: string;                          // Android notification channel

  // Delivery Status
  status: string;                            // 'scheduled' | 'delivered' | 'failed' | 'canceled' | 'expired'
  deliveryAttempts: number;                  // How many times delivery was attempted
  lastError: string | null;                  // Error message if failed

  // User Interaction
  isRead: boolean;                           // User opened notification
  actionTaken: string | null;                // 'started_workout' | 'snoozed' | 'dismissed' | null

  // Retention Policy
  expiresAt: Timestamp;                      // Auto-delete after 90 days (TTL)

  // Audit
  createdAt: Timestamp;                      // Server-side timestamp
  updatedAt: Timestamp;                      // Last modification
}
```

**Indexes** (for efficient querying):
```typescript
// Composite indexes (create in Firestore console)
1. [userId, scheduledTime DESC] - "Show recent notifications"
2. [userId, type, scheduledTime DESC] - "Show workout reminders only"
3. [userId, isRead, scheduledTime DESC] - "Show unread notifications"
4. [userId, expiresAt ASC] - Cleanup query (find expired)
```

**Security Rules**:
```javascript
match /users/{userId}/notificationHistory/{notificationId} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow create: if request.auth != null
                 && request.auth.uid == userId
                 && request.resource.data.expiresAt is timestamp
                 && request.resource.data.expiresAt <= request.time + duration.days(90); // Max 90 days
  allow update: if request.auth != null && request.auth.uid == userId;
  allow delete: if request.auth != null && request.auth.uid == userId;
}
```

**TTL (Time-To-Live) Setup**:
Firestore doesn't have built-in TTL yet. Two approaches:

**Approach A: Cloud Function (Recommended)**
```typescript
// functions/src/index.ts
export const cleanupExpiredNotifications = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const expiredQuery = await admin.firestore()
      .collectionGroup('notificationHistory')
      .where('expiresAt', '<=', now)
      .limit(500) // Batch delete to avoid timeout
      .get();

    const batch = admin.firestore().batch();
    expiredQuery.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();

    console.log(`Deleted ${expiredQuery.size} expired notifications`);
  });
```

**Approach B: Client-Side Cleanup (Fallback)**
```dart
// lib/features/notifications/data/repositories/notification_firestore_repository.dart
class NotificationFirestoreRepository {
  Future<void> cleanupExpiredNotifications() async {
    final now = Timestamp.now();
    final expiredQuery = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notificationHistory')
        .where('expiresAt', isLessThanOrEqualTo: now)
        .limit(100)
        .get();

    final batch = _firestore.batch();
    for (final doc in expiredQuery.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
```

**Document Size Estimate**:
- **Per notification**: ~600 bytes
- **100 notifications**: ~60 KB
- **Storage cost**: Negligible (Firestore free tier = 1GB)

---

### 📄 Collection: `users/{userId}/notificationDelivery/{notificationId}`

**Document Structure** (delivery receipt):

```typescript
{
  notificationId: string;                    // Reference to notificationHistory doc

  // Delivery Status
  status: string;                            // 'pending' | 'delivered' | 'failed' | 'bounced'

  // Timing
  attemptedAt: Timestamp;                    // When delivery was attempted
  deliveredAt: Timestamp | null;             // Actual delivery timestamp (platform confirmed)

  // Platform Data
  platform: string;                          // 'ios' | 'android'
  platformData: {
    messageId: string | null;                // Platform-specific ID (FCM token, APNS ID)
    deviceToken: string | null;              // FCM/APNS token
    errorCode: string | null;                // Platform error code if failed
  };

  // Error Details (if failed)
  errorMessage: string | null;               // Human-readable error
  errorContext: {
    permissionDenied: boolean;
    networkError: boolean;
    deviceOffline: boolean;
  } | null;

  // Retry Logic
  retryCount: number;                        // How many times retried
  maxRetries: number;                        // 3 (give up after)
  nextRetryAt: Timestamp | null;             // Exponential backoff schedule

  // Audit
  createdAt: Timestamp;
}
```

**Indexes**:
```typescript
- [userId, status, attemptedAt DESC] - Find failed deliveries
- [userId, nextRetryAt ASC] - Retry queue processing
```

**Security Rules**:
```javascript
match /users/{userId}/notificationDelivery/{deliveryId} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow write: if request.auth != null && request.auth.uid == userId;
}
```

---

### 📄 Document: `users/{userId}/notificationMetrics`

**Document Structure** (aggregated analytics):

```typescript
{
  // Counters (all-time)
  totalScheduled: number;                    // 150
  totalDelivered: number;                    // 142
  totalFailed: number;                       // 5
  totalRead: number;                         // 98
  duplicatesPrevented: number;               // 12

  // Per-Type Breakdown
  deliveryByType: {
    workoutReminder: {
      scheduled: number;
      delivered: number;
      read: number;
      actionTaken: number;                   // User started workout
    };
    recoveryAlert: { /* ... */ };
    achievement: { /* ... */ };
    streakMotivation: { /* ... */ };
  };

  // Performance
  averageSchedulingLatency: number;          // Milliseconds (how long to schedule)
  averageDeliveryLatency: number;            // Milliseconds (scheduled → delivered)

  // Errors (recent)
  recentErrors: {
    timestamp: Timestamp;
    message: string;
    notificationId: string;
  }[];

  // Cleanup Tracking
  lastCleanupTime: Timestamp;                // When last ran cleanupExpiredNotifications
  notificationsDeleted: number;              // Count deleted in last cleanup

  // Battery Impact (estimate)
  batteryImpact: number;                     // 0.0 - 1.0 (percentage)

  // Last Updated
  updatedAt: Timestamp;
}
```

**Update Strategy**:
- **Incremental updates** (not full recalculation) using Firestore transactions
- **Update on events**: notification delivered, notification read, cleanup completed
- **Batch writes**: Update once per hour max (reduce write costs)

**Security Rules**:
```javascript
match /users/{userId}/notificationMetrics {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow write: if request.auth != null && request.auth.uid == userId;
}
```

---

## 5. SharedPreferences Strategy

### 🗄️ Local Storage Schema

**Key-Value Pairs**:

```dart
// === NotificationSettings v2.0 ===
'notification_settings_v2': '{"enableWorkoutReminders":true,...}' // JSON string

// === Notification History (Last 100 IDs only) ===
'notification_history_ids': '["notif_1","notif_2",...]' // JSON array

// Individual notification documents (cached)
'notification_history_notif_1': '{"id":"notif_1","title":"..."}' // JSON string
'notification_history_notif_2': '{"id":"notif_2","title":"..."}' // JSON string

// === Delivery Receipts (Last 50) ===
'notification_delivery_notif_1': '{"status":"delivered",...}' // JSON string

// === Metrics (Aggregated) ===
'notification_metrics': '{"totalScheduled":150,...}' // JSON string

// === Sync Metadata ===
'notification_last_sync': '2025-01-15T14:30:00.000Z' // ISO8601 timestamp
'notification_sync_failed_count': '0' // Consecutive failures (for backoff)
```

### 📝 Read/Write Operations

**Example: Save NotificationSettings v2.0**

```dart
// lib/features/notifications/data/datasources/notification_local_datasource.dart

class NotificationLocalDataSource {
  final SharedPreferences _prefs;

  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    // Serialize to JSON (efficient: single write operation)
    final json = settings.toJson();
    final jsonString = jsonEncode(json);

    // Save to SharedPreferences
    await _prefs.setString('notification_settings_v2', jsonString);

    // Update last modified timestamp
    await _prefs.setString('notification_settings_updated_at',
                           DateTime.now().toIso8601String());
  }

  Future<NotificationSettings?> getNotificationSettings() async {
    // Read JSON string
    final jsonString = _prefs.getString('notification_settings_v2');

    if (jsonString == null) {
      // Check for v1.0 settings (migration path)
      return _migrateV1Settings();
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return NotificationSettings.fromJson(json);
    } catch (e) {
      // Corrupted JSON → return null, will trigger re-sync from Firestore
      debugPrint('⚠️ Failed to parse notification settings: $e');
      return null;
    }
  }

  // v1.0 → v2.0 migration helper
  Future<NotificationSettings?> _migrateV1Settings() async {
    // Read old v1.0 keys
    final enableWorkout = _prefs.getBool('notif_workout_reminders');
    if (enableWorkout == null) return null; // No v1.0 settings

    // Create v2.0 settings from v1.0 data
    final v2Settings = NotificationSettings(
      enableWorkoutReminders: enableWorkout,
      enableRecoveryAlerts: _prefs.getBool('notif_recovery_alerts') ?? true,
      // ... map all v1.0 fields

      // v2.0 defaults for new fields
      settingsVersion: 2,
      migrationSource: 'v1_sharedprefs',
    );

    // Save as v2.0 format
    await saveNotificationSettings(v2Settings);

    // Delete old v1.0 keys (cleanup)
    await _prefs.remove('notif_workout_reminders');
    await _prefs.remove('notif_recovery_alerts');
    // ... remove all v1.0 keys

    return v2Settings;
  }
}
```

**Example: Cache Notification History (Last 100)**

```dart
Future<void> cacheNotificationHistory(List<UnifiedNotification> notifications) async {
  // Only cache last 100 to prevent SharedPreferences bloat
  final recent = notifications.take(100).toList();

  // Save IDs list (for quick enumeration)
  final ids = recent.map((n) => n.id).toList();
  await _prefs.setString('notification_history_ids', jsonEncode(ids));

  // Save each notification individually (allows partial updates)
  for (final notification in recent) {
    final key = 'notification_history_${notification.id}';
    await _prefs.setString(key, jsonEncode(notification.toJson()));
  }

  // Remove old cached notifications (cleanup)
  final allKeys = _prefs.getKeys();
  final historyKeys = allKeys.where((k) => k.startsWith('notification_history_'));
  for (final key in historyKeys) {
    if (!ids.contains(key.replaceFirst('notification_history_', ''))) {
      await _prefs.remove(key);
    }
  }
}

Future<List<UnifiedNotification>> getCachedNotificationHistory() async {
  final idsJson = _prefs.getString('notification_history_ids');
  if (idsJson == null) return [];

  final ids = (jsonDecode(idsJson) as List).cast<String>();
  final notifications = <UnifiedNotification>[];

  for (final id in ids) {
    final key = 'notification_history_$id';
    final json = _prefs.getString(key);
    if (json != null) {
      try {
        final notification = UnifiedNotification.fromJson(
          jsonDecode(json) as Map<String, dynamic>,
        );
        notifications.add(notification);
      } catch (e) {
        // Skip corrupted entry
        debugPrint('⚠️ Skipping corrupted notification $id: $e');
      }
    }
  }

  return notifications;
}
```

### 🔄 Sync Strategy

**When to read from SharedPreferences**:
1. ✅ App cold-start (before Firestore fetch completes)
2. ✅ Offline mode (Firestore unavailable)
3. ✅ After every write (confirm persistence)

**When to write to SharedPreferences**:
1. ✅ User changes settings (immediate)
2. ✅ After successful Firestore sync (confirm consistency)
3. ✅ Notification delivered/read (update history)

**When to invalidate cache**:
1. ✅ User logs out (clear all notification data)
2. ✅ Firestore sync detects newer version (conflict resolution)
3. ✅ Manual "Reset to defaults" action

---

## 6. Cross-Device Synchronization

### 🔄 Sync Architecture

**Sync Flow** (Local → Remote):

```
User changes setting in UI
         ↓
Riverpod provider updates state
         ↓
Write to SharedPreferences (instant feedback)
         ↓
Debounce 5 minutes (prevent spam writes)
         ↓
Write to Firestore (batch update)
         ↓
Update lastSyncedAt timestamp
```

**Sync Flow** (Remote → Local):

```
App starts / User switches device
         ↓
Read from SharedPreferences (show cached UI)
         ↓
Fetch from Firestore (background)
         ↓
Compare lastSyncedAt timestamps
         ↓
If Firestore newer → Update local cache
         ↓
Notify UI to refresh (Riverpod)
```

### ⚔️ Conflict Resolution: Last-Write-Wins

**Strategy**: Simple timestamp-based resolution (no complex merging)

**Why Last-Write-Wins?**
- ✅ **Simple**: No complex merge logic, easy to reason about
- ✅ **Fast**: Single comparison, no diffing
- ✅ **Sufficient**: User rarely edits settings on multiple devices simultaneously
- ✅ **Industry standard**: Used by iCloud, Google Drive, Dropbox

**Algorithm**:

```dart
// lib/features/notifications/data/repositories/notification_sync_manager.dart

class NotificationSyncManager {
  Future<NotificationSettings> resolveConflict({
    required NotificationSettings localSettings,
    required NotificationSettings remoteSettings,
  }) async {
    final localTimestamp = localSettings.lastSyncedAt;
    final remoteTimestamp = remoteSettings.lastSyncedAt;

    if (localTimestamp == null && remoteTimestamp == null) {
      // Both are fresh → prefer local (user just made changes)
      return localSettings;
    }

    if (localTimestamp == null) {
      // Local never synced → use remote
      return remoteSettings;
    }

    if (remoteTimestamp == null) {
      // Remote never synced → use local
      return localSettings;
    }

    // Compare timestamps → newest wins
    if (remoteTimestamp.isAfter(localTimestamp)) {
      debugPrint('🔄 Sync conflict: Remote newer (${remoteTimestamp}) vs Local (${localTimestamp})');
      return remoteSettings;
    } else {
      debugPrint('🔄 Sync conflict: Local newer (${localTimestamp}) vs Remote (${remoteTimestamp})');
      return localSettings;
    }
  }
}
```

**Edge Case Handling**:

| Scenario | Resolution | Reasoning |
|----------|------------|-----------|
| **Both null timestamps** | Prefer local | User just edited settings |
| **Local only null** | Use remote | Local is fresh/unsynced |
| **Remote only null** | Use local | Remote is fresh/unsynced |
| **Network error mid-sync** | Retry with exponential backoff | Resilience |
| **User edits during sync** | Queue next sync | Debouncer handles |
| **Clock skew (device time wrong)** | Use server timestamp | Firestore `FieldValue.serverTimestamp()` |

**Server Timestamp** (eliminates clock skew issues):

```dart
// When writing to Firestore, use server timestamp
await _firestore
    .collection('users')
    .doc(userId)
    .set({
      ...settings.toJson(),
      'lastSyncedAt': FieldValue.serverTimestamp(), // Firestore server time
    });
```

### ⏱️ Debouncing Strategy

**Problem**: User changes 5 settings in 10 seconds → 5 Firestore writes (expensive!)

**Solution**: Debounce writes to 1 write per 5 minutes

**Implementation**:

```dart
// lib/features/notifications/presentation/providers/notification_settings_provider.dart

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  Timer? _syncDebounceTimer;
  static const _syncDebounceDelay = Duration(minutes: 5);

  Future<void> updateSettings(NotificationSettings newSettings) async {
    // Update in-memory state (instant UI feedback)
    state = newSettings;

    // Write to SharedPreferences (instant persistence)
    await _localDataSource.saveNotificationSettings(newSettings);

    // Debounce Firestore write
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = Timer(_syncDebounceDelay, () {
      _syncToFirestore(newSettings);
    });
  }

  Future<void> _syncToFirestore(NotificationSettings settings) async {
    try {
      await _remoteDataSource.saveNotificationSettings(settings);
      debugPrint('✅ Synced settings to Firestore');
    } catch (e) {
      debugPrint('⚠️ Failed to sync to Firestore: $e');
      // Retry with exponential backoff (handled by SyncManager)
    }
  }

  // Force immediate sync (e.g., user navigates away from settings screen)
  Future<void> forceSyncNow() async {
    _syncDebounceTimer?.cancel();
    await _syncToFirestore(state);
  }

  @override
  void dispose() {
    _syncDebounceTimer?.cancel();
    super.dispose();
  }
}
```

**Debounce Delays**:
- **Settings changes**: 5 minutes (user tweaking settings)
- **Notification delivered**: 30 seconds (history update)
- **Force sync**: Immediate (user logs out, app backgrounded)

---

## 7. Repository Layer Updates

### 🏛️ Repository Pattern (Clean Architecture)

**Current**: Single `NotificationRepository` (too broad)

**Proposed v2.0**: Split into focused repositories

```
NotificationRepository (existing - refactor)
  ├─ Scheduling operations (schedule, cancel)
  ├─ Permission management
  └─ System health checks

NotificationSettingsRepository (NEW)
  ├─ CRUD for NotificationSettings v2.0
  ├─ Cross-device sync
  └─ Migration v1.0 → v2.0

NotificationHistoryRepository (NEW)
  ├─ CRUD for notification history
  ├─ Filtering & search
  └─ Auto-cleanup (90-day TTL)

NotificationAnalyticsRepository (NEW)
  ├─ Delivery metrics
  ├─ Engagement tracking
  └─ Error reporting
```

### 📋 Interface: `NotificationSettingsRepository`

```dart
// lib/features/notifications/domain/repositories/notification_settings_repository.dart

abstract class NotificationSettingsRepository {
  // === CRUD Operations ===

  /// Get current notification settings (local cache first, fallback to Firestore)
  Future<NotificationSettings> getSettings();

  /// Update notification settings (write to local + debounced sync to Firestore)
  Future<void> updateSettings(NotificationSettings settings);

  /// Reset to default settings
  Future<void> resetToDefaults();

  // === Synchronization ===

  /// Force immediate sync to Firestore (bypass debounce)
  Future<void> syncNow();

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime();

  /// Check if settings are out of sync
  Future<bool> isOutOfSync();

  // === Migration ===

  /// Migrate v1.0 settings to v2.0 (SharedPreferences → Firestore)
  Future<NotificationSettings> migrateFromV1();

  /// Check if migration is needed
  Future<bool> needsMigration();

  // === GDPR Compliance ===

  /// Record user consent (GDPR Article 7.1)
  Future<void> recordConsent(String consentVersion);

  /// Revoke consent and delete all data
  Future<void> revokeConsentAndDeleteData();

  /// Check if user has given consent
  Future<bool> hasValidConsent();

  // === Stream (Real-Time Updates) ===

  /// Stream of settings changes (from Firestore real-time)
  Stream<NotificationSettings> watchSettings();
}
```

### 📋 Interface: `NotificationHistoryRepository`

```dart
// lib/features/notifications/domain/repositories/notification_history_repository.dart

abstract class NotificationHistoryRepository {
  // === CRUD Operations ===

  /// Get notification history with filters
  Future<List<UnifiedNotification>> getHistory({
    int limit = 50,
    DateTime? since,
    DateTime? until,
    List<NotificationType>? types,
    bool unreadOnly = false,
  });

  /// Get single notification by ID
  Future<UnifiedNotification?> getNotificationById(String id);

  /// Save notification to history (after delivery)
  Future<void> saveNotification(UnifiedNotification notification);

  /// Mark notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all as read
  Future<void> markAllAsRead();

  /// Delete notification
  Future<void> deleteNotification(String notificationId);

  // === Search & Filter ===

  /// Search notifications by text (title/body)
  Future<List<UnifiedNotification>> searchNotifications(String query);

  /// Get unread count
  Future<int> getUnreadCount();

  // === Cleanup ===

  /// Delete notifications older than 90 days
  Future<int> cleanupExpiredNotifications();

  /// Get storage size estimate
  Future<int> getStorageSizeBytes();

  // === Stream (Real-Time Updates) ===

  /// Stream of new notifications (Firestore real-time)
  Stream<UnifiedNotification> watchNewNotifications();

  /// Stream of unread count changes
  Stream<int> watchUnreadCount();
}
```

### 🔧 Implementation Example: `NotificationSettingsRepositoryImpl`

```dart
// lib/features/notifications/data/repositories/notification_settings_repository_impl.dart

class NotificationSettingsRepositoryImpl implements NotificationSettingsRepository {
  final NotificationLocalDataSource _localDataSource;
  final NotificationRemoteDataSource _remoteDataSource;
  final NotificationSyncManager _syncManager;

  NotificationSettingsRepositoryImpl({
    required NotificationLocalDataSource localDataSource,
    required NotificationRemoteDataSource remoteDataSource,
    required NotificationSyncManager syncManager,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _syncManager = syncManager;

  @override
  Future<NotificationSettings> getSettings() async {
    // 1. Try local cache first (instant)
    final localSettings = await _localDataSource.getNotificationSettings();
    if (localSettings != null) {
      // Start background sync to check for updates
      unawaited(_backgroundSync(localSettings));
      return localSettings;
    }

    // 2. Fetch from Firestore (first launch or cache miss)
    final remoteSettings = await _remoteDataSource.getNotificationSettings();
    if (remoteSettings != null) {
      // Cache locally for next time
      await _localDataSource.saveNotificationSettings(remoteSettings);
      return remoteSettings;
    }

    // 3. Fallback to defaults (new user)
    final defaults = NotificationSettings.defaults();
    await _localDataSource.saveNotificationSettings(defaults);
    return defaults;
  }

  Future<void> _backgroundSync(NotificationSettings localSettings) async {
    try {
      final remoteSettings = await _remoteDataSource.getNotificationSettings();
      if (remoteSettings == null) return;

      // Resolve conflicts using last-write-wins
      final resolved = await _syncManager.resolveConflict(
        localSettings: localSettings,
        remoteSettings: remoteSettings,
      );

      // Update local cache if remote was newer
      if (resolved != localSettings) {
        await _localDataSource.saveNotificationSettings(resolved);
        // Notify UI via stream (handled by provider)
      }
    } catch (e) {
      debugPrint('⚠️ Background sync failed: $e');
      // Silent failure (offline is OK)
    }
  }

  @override
  Future<void> updateSettings(NotificationSettings settings) async {
    // 1. Update local immediately (instant feedback)
    await _localDataSource.saveNotificationSettings(settings);

    // 2. Debounced sync to Firestore (via SyncManager)
    await _syncManager.enqueueSyncTask(() async {
      await _remoteDataSource.saveNotificationSettings(settings);
    });
  }

  @override
  Future<void> syncNow() async {
    // Force immediate sync (bypass debounce)
    final settings = await _localDataSource.getNotificationSettings();
    if (settings != null) {
      await _remoteDataSource.saveNotificationSettings(settings);
    }
  }

  @override
  Future<NotificationSettings> migrateFromV1() async {
    // Check if v1.0 settings exist in SharedPreferences
    final v1Settings = await _localDataSource.migrateV1Settings();
    if (v1Settings == null) {
      throw Exception('No v1.0 settings found to migrate');
    }

    // Save as v2.0 to Firestore
    await _remoteDataSource.saveNotificationSettings(v1Settings);

    return v1Settings;
  }

  @override
  Future<void> recordConsent(String consentVersion) async {
    final settings = await getSettings();
    final updated = settings.copyWith(
      consentTimestamp: DateTime.now(),
      consentVersion: consentVersion,
    );
    await updateSettings(updated);
  }

  @override
  Future<void> revokeConsentAndDeleteData() async {
    // 1. Delete from Firestore (all notification data)
    await _remoteDataSource.deleteAllNotificationData();

    // 2. Clear local cache
    await _localDataSource.clearAllNotificationData();
  }

  @override
  Stream<NotificationSettings> watchSettings() {
    // Real-time stream from Firestore
    return _remoteDataSource.watchNotificationSettings();
  }
}
```

---

## 8. Data Migration Strategy

### 🔄 Migration Paths

**Migration 1**: v1.0 (SharedPreferences only) → v2.0 (Firestore + SharedPreferences)

**Trigger**: User launches app with v2.0 for first time

**Steps**:

```dart
// lib/features/notifications/domain/usecases/migrate_notification_settings.dart

class MigrateNotificationSettings {
  final NotificationSettingsRepository _repository;

  Future<NotificationSettings> execute() async {
    // 1. Check if migration needed
    final needsMigration = await _repository.needsMigration();
    if (!needsMigration) {
      return await _repository.getSettings(); // Already v2.0
    }

    // 2. Read v1.0 settings from SharedPreferences
    final v1Settings = await _readV1Settings();

    // 3. Transform to v2.0 structure
    final v2Settings = _transformV1ToV2(v1Settings);

    // 4. Save to Firestore (new home)
    await _repository.updateSettings(v2Settings);

    // 5. Delete old v1.0 keys (cleanup)
    await _deleteV1Keys();

    // 6. Mark migration complete
    await _prefs.setBool('notification_migration_v2_complete', true);

    return v2Settings;
  }

  NotificationSettings _transformV1ToV2(Map<String, dynamic> v1) {
    return NotificationSettings(
      // v1.0 fields (copy directly)
      enableWorkoutReminders: v1['enableWorkoutReminders'] ?? true,
      enableRecoveryAlerts: v1['enableRecoveryAlerts'] ?? true,
      enableStreakMotivation: v1['enableStreakMotivation'] ?? false,
      enableRestDayReminders: v1['enableRestDayReminders'] ?? false,
      preferredTime: v1['preferredTime'] ?? NotificationTimePreference.morning,
      customTime: v1['customTime'],
      enableSmartScheduling: v1['enableSmartScheduling'] ?? true,
      doNotDisturbEnabled: v1['doNotDisturbEnabled'] ?? false,
      doNotDisturbStart: v1['doNotDisturbStart'],
      doNotDisturbEnd: v1['doNotDisturbEnd'],
      reminderMinutesBefore: v1['reminderMinutesBefore'] ?? 60,

      // v2.0 defaults for new fields
      customTimePerType: {},
      categoryQuietHours: {},
      frequencyCapPreferences: const FrequencyCap(
        maxPerDay: 3,
        maxPerWeek: 5,
        minIntervalHours: 2,
      ),
      categoryFrequencyCaps: {},
      consentTimestamp: DateTime.now(), // Assume implicit consent (grandfather)
      consentVersion: '1.0',
      enableAnalytics: false, // Opt-in required
      dataRetentionDays: 90,
      lastSyncedAt: null, // Will be set on first Firestore write
      deviceId: _getDeviceId(),
      settingsVersion: 2,
      migrationSource: 'v1_sharedprefs',
    );
  }
}
```

**Migration 2**: Add new field to v2.0 (e.g., v2.0 → v2.1)

**Approach**: Graceful defaults in `fromJson`

```dart
// lib/features/notifications/domain/entities/notification_settings.dart

@freezed
class NotificationSettings with _$NotificationSettings {
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      // ... existing fields

      // 🆕 v2.1 field (graceful default if missing)
      newFieldV21: json['newFieldV21'] as bool? ?? false, // Default to false
    );
  }
}
```

**Migration 3**: Breaking change (remove field)

**Strategy**: Bump `settingsVersion` to 3, refuse to load v2 docs

```dart
@override
Future<NotificationSettings> getSettings() async {
  final json = await _getSettingsJson();
  final version = json['settingsVersion'] as int? ?? 1;

  if (version < 3) {
    // Force migration from v2 → v3
    return await _migrateV2ToV3(json);
  }

  return NotificationSettings.fromJson(json);
}
```

---

## 9. Performance & Optimization

### ⚡ Firestore Query Optimization

**Problem**: Firestore charges per document read

**Optimizations**:

1. **Limit queries** (`limit: 50`)
   ```dart
   // Only fetch last 50 notifications
   final query = _firestore
       .collection('users/$userId/notificationHistory')
       .orderBy('scheduledTime', descending: true)
       .limit(50);
   ```

2. **Index-backed queries** (create composite indexes)
   ```dart
   // Requires index: [userId, isRead, scheduledTime]
   final unreadQuery = _firestore
       .collectionGroup('notificationHistory')
       .where('userId', isEqualTo: userId)
       .where('isRead', isEqualTo: false)
       .orderBy('scheduledTime', descending: true);
   ```

3. **Pagination** (infinite scroll for history)
   ```dart
   // Use startAfter for pagination
   DocumentSnapshot? lastDoc;

   Future<List<UnifiedNotification>> getNextPage() async {
     var query = _firestore
         .collection('users/$userId/notificationHistory')
         .orderBy('scheduledTime', descending: true)
         .limit(20);

     if (lastDoc != null) {
       query = query.startAfterDocument(lastDoc!);
     }

     final snapshot = await query.get();
     if (snapshot.docs.isNotEmpty) {
       lastDoc = snapshot.docs.last;
     }

     return snapshot.docs.map((doc) =>
       UnifiedNotification.fromJson(doc.data())).toList();
   }
   ```

4. **Batch writes** (update metrics once per hour)
   ```dart
   // Instead of 50 individual writes, batch into 1 transaction
   final batch = _firestore.batch();
   for (final notification in notificationsToSave) {
     batch.set(
       _firestore.collection('users/$userId/notificationHistory').doc(notification.id),
       notification.toJson(),
     );
   }
   await batch.commit(); // Single write operation
   ```

### 🗜️ Data Compression

**Firestore Document Size Reduction**:

```dart
// Bad: Store full ISO8601 timestamps everywhere (30 bytes each)
{
  "createdAt": "2025-01-15T14:30:00.000Z",
  "updatedAt": "2025-01-15T14:35:00.000Z",
  "scheduledTime": "2025-01-15T16:00:00.000Z",
}

// Good: Use Firestore Timestamp (8 bytes each)
{
  "createdAt": Timestamp(seconds: 1705329000, nanoseconds: 0),
  "updatedAt": Timestamp(seconds: 1705329300, nanoseconds: 0),
  "scheduledTime": Timestamp(seconds: 1705334400, nanoseconds: 0),
}

// Size reduction: 90 bytes → 24 bytes (73% smaller!)
```

**Enum Storage**:

```dart
// Bad: Store full enum names (15+ bytes)
{ "type": "workoutReminder" }

// Good: Store enum index (1 byte) or abbreviation (2-3 bytes)
{ "type": "wr" } // 'wr' = workoutReminder

// Decode in fromJson:
NotificationType _decodeType(String abbr) {
  switch (abbr) {
    case 'wr': return NotificationType.workoutReminder;
    case 'ra': return NotificationType.recoveryAlert;
    case 'ach': return NotificationType.achievement;
    default: return NotificationType.workoutReminder;
  }
}
```

### 📊 Batch Operations

**Debounced Metric Updates**:

```dart
// Instead of updating metrics on every notification (expensive):
class NotificationMetricsAggregator {
  final List<MetricEvent> _pendingEvents = [];
  Timer? _flushTimer;

  void recordEvent(MetricEvent event) {
    _pendingEvents.add(event);

    // Flush after 1 hour or 100 events (whichever comes first)
    _flushTimer?.cancel();
    _flushTimer = Timer(const Duration(hours: 1), _flushToFirestore);

    if (_pendingEvents.length >= 100) {
      _flushToFirestore();
    }
  }

  Future<void> _flushToFirestore() async {
    if (_pendingEvents.isEmpty) return;

    // Aggregate events locally
    final aggregated = _aggregateEvents(_pendingEvents);

    // Single Firestore transaction (instead of 100 writes!)
    await _firestore.runTransaction((transaction) async {
      final metricsRef = _firestore.doc('users/$userId/notificationMetrics');
      final current = await transaction.get(metricsRef);

      final updated = _mergeMetrics(current.data(), aggregated);
      transaction.set(metricsRef, updated);
    });

    _pendingEvents.clear();
  }
}
```

**Cost Analysis**:

| Operation | Firestore Cost (per 100k operations) | Optimization | New Cost |
|-----------|--------------------------------------|--------------|----------|
| **Write settings** | $1.80 (100k writes) | Debounce 5min | $0.36 (20k writes) |
| **Read history** | $0.36 (100k reads) | Local cache | $0.036 (10k reads) |
| **Update metrics** | $1.80 (100k writes) | Batch hourly | $0.036 (2k writes) |
| **Total (daily per user)** | ~$0.0004 | ~$0.00008 | **80% reduction** |

---

## 10. Privacy & GDPR Compliance

### 🔒 GDPR Requirements (Regulation EU 2016/679)

**Article 7.1**: Explicit consent required for data processing

**Implementation**:

```dart
// lib/features/notifications/domain/entities/notification_settings.dart

@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    // ... other fields

    /// GDPR Article 7.1: Timestamp when user gave explicit consent
    /// NULL = no consent given (grandfathered users assumed implicit consent)
    DateTime? consentTimestamp,

    /// Version of consent agreement user agreed to
    /// Format: 'MAJOR.MINOR' (e.g., '1.0', '1.1', '2.0')
    /// Increment when consent terms change (requires re-consent)
    @Default('1.0') String consentVersion,

    /// User opted in to analytics data collection
    /// Default: false (GDPR requires opt-in, not opt-out)
    @Default(false) bool enableAnalytics,

    /// GDPR Article 5.1.e: Data retention period (in days)
    /// Default: 90 days (industry standard for notification history)
    /// User can adjust: 30, 60, 90, 180, 365, or 'forever' (9999)
    @Default(90) int dataRetentionDays,
  }) = _NotificationSettings;
}
```

**Consent Flow** (see Task 3.3 - Presentation Layer UX):

```dart
// Step 4 of onboarding flow
class GDPRConsentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(context.l10n.weRespectYourPrivacy),
        Text(context.l10n.dataWeCollect),
        // - Notification delivery status
        // - Notification open/read timestamps
        // - Device type (iOS/Android)
        // - Settings preferences

        // GDPR-compliant checkbox (unchecked by default)
        CheckboxListTile(
          value: _analyticsConsent,
          onChanged: (val) => setState(() => _analyticsConsent = val ?? false),
          title: Text(context.l10n.optInAnalytics),
          subtitle: Text(context.l10n.helpUsImproveExperience),
        ),

        // Required consent (cannot proceed without)
        ElevatedButton(
          onPressed: () {
            // Record consent with timestamp
            ref.read(notificationSettingsProvider.notifier).recordConsent(
              consentVersion: '1.0',
              enableAnalytics: _analyticsConsent,
            );
            // Continue to app
          },
          child: Text(context.l10n.agreeAndContinue),
        ),

        // Privacy policy link (GDPR Article 13)
        TextButton(
          onPressed: () => _openPrivacyPolicy(),
          child: Text(context.l10n.readPrivacyPolicy),
        ),
      ],
    );
  }
}
```

### 🗑️ Right to Erasure (GDPR Article 17)

**Implementation**:

```dart
// lib/features/notifications/domain/usecases/delete_all_notification_data.dart

class DeleteAllNotificationData {
  final NotificationSettingsRepository _settingsRepo;
  final NotificationHistoryRepository _historyRepo;
  final FirebaseAuth _auth;

  Future<void> execute() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // 1. Delete from Firestore (all collections)
    final batch = _firestore.batch();

    // Delete notificationSettings
    batch.delete(_firestore.doc('users/$userId/notificationSettings'));

    // Delete all notificationHistory (batched - max 500 per batch)
    final historyQuery = await _firestore
        .collection('users/$userId/notificationHistory')
        .limit(500)
        .get();
    for (final doc in historyQuery.docs) {
      batch.delete(doc.reference);
    }

    // Delete all notificationDelivery
    final deliveryQuery = await _firestore
        .collection('users/$userId/notificationDelivery')
        .limit(500)
        .get();
    for (final doc in deliveryQuery.docs) {
      batch.delete(doc.reference);
    }

    // Delete notificationMetrics
    batch.delete(_firestore.doc('users/$userId/notificationMetrics'));

    await batch.commit();

    // 2. Clear local cache (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    final keysToDelete = prefs.getKeys().where((key) =>
        key.startsWith('notification_'));
    for (final key in keysToDelete) {
      await prefs.remove(key);
    }

    // 3. Cancel all scheduled notifications
    await _notificationRepo.cancelAllNotifications();

    debugPrint('✅ GDPR: All notification data deleted for user $userId');
  }
}
```

**UI Integration** (Settings screen):

```dart
// In NotificationSettingsScreen
ListTile(
  leading: Icon(AppIcons.delete, color: context.colors.error),
  title: Text(context.l10n.deleteAllNotificationData),
  subtitle: Text(context.l10n.gdprDataDeletion),
  onTap: () async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.confirmDataDeletion),
        content: Text(context.l10n.thisActionCannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            child: Text(context.l10n.deleteEverything),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(deleteAllNotificationDataProvider).execute();
      if (context.mounted) {
        SnackBarService.showSuccess(
          context,
          context.l10n.allNotificationDataDeleted,
        );
      }
    }
  },
),
```

### 📜 Data Retention Policy

**Auto-Cleanup Job** (Cloud Function):

```typescript
// functions/src/scheduled/cleanupExpiredNotifications.ts

export const cleanupExpiredNotifications = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    // Fetch all users with notification history
    const usersSnapshot = await db.collection('users').get();

    let totalDeleted = 0;

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      const settingsDoc = await db.doc(`users/${userId}/notificationSettings`).get();
      const retentionDays = settingsDoc.data()?.dataRetentionDays || 90;

      // Calculate expiration date
      const expirationDate = new Date();
      expirationDate.setDate(expirationDate.getDate() - retentionDays);
      const expirationTimestamp = admin.firestore.Timestamp.fromDate(expirationDate);

      // Find expired notifications
      const expiredQuery = await db
        .collection(`users/${userId}/notificationHistory`)
        .where('scheduledTime', '<=', expirationTimestamp)
        .limit(500) // Batch delete
        .get();

      // Delete in batches
      const batch = db.batch();
      expiredQuery.docs.forEach(doc => batch.delete(doc.ref));
      await batch.commit();

      totalDeleted += expiredQuery.size;
    }

    console.log(`✅ Cleanup complete: Deleted ${totalDeleted} expired notifications`);
    return null;
  });
```

---

## 11. Error Handling & Resilience

### 🛡️ Error Scenarios

| Error Scenario | Detection | Recovery Strategy | User Experience |
|----------------|-----------|-------------------|-----------------|
| **Firestore offline** | `FirebaseException.code == 'unavailable'` | Use SharedPreferences cache | ✅ App works offline, sync when online |
| **Permission denied** | `FirebaseException.code == 'permission-denied'` | Log out user, show re-auth | ⚠️ "Session expired, please log in" |
| **Quota exceeded** | `FirebaseException.code == 'resource-exhausted'` | Exponential backoff, reduce sync frequency | ⚠️ "Sync delayed, will retry soon" |
| **Network timeout** | Timeout after 30 seconds | Retry with exponential backoff (3 attempts) | ⏳ Show loading indicator |
| **Corrupted JSON** | `FormatException` during `jsonDecode` | Delete corrupted entry, re-sync from Firestore | 🔄 "Reloading settings..." |
| **Version mismatch** | `settingsVersion < 2` | Auto-migrate or force update | 📲 "Updating settings format..." |
| **Clock skew** | Local timestamp in future | Use server timestamp (`FieldValue.serverTimestamp()`) | ✅ Transparent fix |

### 🔄 Retry Logic with Exponential Backoff

```dart
// lib/shared/utils/exponential_backoff.dart

class ExponentialBackoff {
  Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double multiplier = 2.0,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempt++;

        if (attempt >= maxAttempts) {
          rethrow; // Give up after max attempts
        }

        debugPrint('⚠️ Retry attempt $attempt/$maxAttempts after $delay');
        await Future.delayed(delay);
        delay *= multiplier; // Exponential backoff
      }
    }

    throw Exception('Retry failed after $maxAttempts attempts');
  }
}
```

**Usage**:

```dart
// In NotificationSettingsRepositoryImpl
Future<void> syncToFirestore(NotificationSettings settings) async {
  await ExponentialBackoff().retry(
    operation: () => _remoteDataSource.saveNotificationSettings(settings),
    maxAttempts: 3,
    initialDelay: const Duration(seconds: 2),
    multiplier: 2.0, // 2s, 4s, 8s
  );
}
```

### 🔍 Error Monitoring

**Log to Firestore** (for debugging):

```dart
// lib/features/notifications/data/datasources/notification_error_logger.dart

class NotificationErrorLogger {
  final FirebaseFirestore _firestore;

  Future<void> logError({
    required String message,
    required StackTrace stackTrace,
    String? notificationId,
    Map<String, dynamic>? context,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return; // Don't log if not authenticated

    await _firestore.collection('notificationErrors').add({
      'userId': userId,
      'message': message,
      'stackTrace': stackTrace.toString(),
      'notificationId': notificationId,
      'context': context,
      'timestamp': FieldValue.serverTimestamp(),
      'platform': Platform.isIOS ? 'ios' : 'android',
      'appVersion': _packageInfo.version,
    });
  }
}
```

**Analytics Integration** (Firebase Crashlytics):

```dart
// In NotificationSettingsRepositoryImpl
Future<void> updateSettings(NotificationSettings settings) async {
  try {
    await _localDataSource.saveNotificationSettings(settings);
    await _syncManager.enqueueSyncTask(() async {
      await _remoteDataSource.saveNotificationSettings(settings);
    });
  } catch (e, stackTrace) {
    // Log to Crashlytics
    FirebaseCrashlytics.instance.recordError(
      e,
      stackTrace,
      reason: 'Failed to update notification settings',
      information: ['userId: ${_auth.currentUser?.uid}'],
    );

    // Also log to Firestore for debugging
    await _errorLogger.logError(
      message: 'Settings update failed',
      stackTrace: stackTrace,
      context: {'settings': settings.toJson()},
    );

    rethrow;
  }
}
```

---

## 12. Implementation Checklist

### ✅ PHASE 4: IMPLEMENTATION - Domain & Data (Task 4.1-4.2)

**Task 4.1: Domain Layer Refactoring** (1.5h estimated):

- [ ] Create `NotificationSettingsRepository` interface
- [ ] Create `NotificationHistoryRepository` interface
- [ ] Create `NotificationAnalyticsRepository` interface
- [ ] Add FrequencyCap entity (from Task 3.2)
- [ ] Add QuietHours entity (from Task 3.2)
- [ ] Update NotificationSettings entity to v2.0 (22 fields)
- [ ] Add migration helper `MigrateNotificationSettings` use case
- [ ] Add GDPR use cases (`RecordConsent`, `DeleteAllNotificationData`)

**Task 4.2: Data Layer Repository Implementation** (1.5h estimated):

- [ ] Create `NotificationLocalDataSource` (SharedPreferences)
  - [ ] Implement `saveNotificationSettings`
  - [ ] Implement `getNotificationSettings`
  - [ ] Implement `migrateV1Settings`
  - [ ] Implement `cacheNotificationHistory`
  - [ ] Implement `getCachedNotificationHistory`
  - [ ] Implement `clearAllNotificationData`

- [ ] Create `NotificationRemoteDataSource` (Firestore)
  - [ ] Implement `saveNotificationSettings`
  - [ ] Implement `getNotificationSettings`
  - [ ] Implement `watchNotificationSettings` (real-time stream)
  - [ ] Implement `saveNotificationHistory`
  - [ ] Implement `getNotificationHistory` (with filters)
  - [ ] Implement `deleteAllNotificationData`

- [ ] Create `NotificationSyncManager`
  - [ ] Implement debounce logic (5min delay)
  - [ ] Implement `resolveConflict` (last-write-wins)
  - [ ] Implement `enqueueSyncTask`
  - [ ] Implement exponential backoff retry

- [ ] Create `NotificationSettingsRepositoryImpl`
  - [ ] Implement all interface methods (see Section 7)
  - [ ] Integrate local + remote data sources
  - [ ] Integrate sync manager

- [ ] Create `NotificationHistoryRepositoryImpl`
  - [ ] Implement CRUD operations
  - [ ] Implement search & filtering
  - [ ] Implement cleanup (90-day TTL)

**Task 4.3: Riverpod Provider Architecture** (1.5h estimated):

- [ ] Refactor `notificationSettingsProvider` to use new repository
- [ ] Create `notificationHistoryProvider`
- [ ] Create `notificationMetricsProvider`
- [ ] Create `notificationSyncStatusProvider` (show sync indicator in UI)
- [ ] Update providers to use new v2.0 entities

### ✅ Firestore Setup (Manual - DevOps)

- [ ] Create Firestore collections:
  - [ ] `users/{userId}/notificationSettings`
  - [ ] `users/{userId}/notificationHistory/{notificationId}`
  - [ ] `users/{userId}/notificationDelivery/{notificationId}`
  - [ ] `users/{userId}/notificationMetrics`

- [ ] Create Firestore indexes (via Firebase Console):
  - [ ] Composite index: `[userId, scheduledTime DESC]`
  - [ ] Composite index: `[userId, type, scheduledTime DESC]`
  - [ ] Composite index: `[userId, isRead, scheduledTime DESC]`
  - [ ] Composite index: `[userId, expiresAt ASC]`

- [ ] Update Firestore security rules (`firestore.rules`):
  - [ ] Add rules for `notificationSettings`
  - [ ] Add rules for `notificationHistory`
  - [ ] Add rules for `notificationDelivery`
  - [ ] Add rules for `notificationMetrics`

- [ ] Deploy Cloud Functions (optional, for auto-cleanup):
  - [ ] `cleanupExpiredNotifications` (daily job)

### ✅ Testing (PHASE 5)

- [ ] Unit tests for `NotificationLocalDataSource`
- [ ] Unit tests for `NotificationRemoteDataSource`
- [ ] Unit tests for `NotificationSyncManager` (conflict resolution)
- [ ] Unit tests for `MigrateNotificationSettings` use case
- [ ] Integration tests for repository implementations
- [ ] E2E tests for cross-device sync (2 emulators)

---

## 📚 References & Resources

**GDPR Compliance**:
- [GDPR Article 7.1 - Conditions for consent](https://gdpr-info.eu/art-7-gdpr/)
- [GDPR Article 17 - Right to erasure](https://gdpr-info.eu/art-17-gdpr/)
- [GDPR Article 5.1.e - Storage limitation](https://gdpr-info.eu/art-5-gdpr/)

**Firestore Best Practices**:
- [Firestore Data Model](https://firebase.google.com/docs/firestore/data-model)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firestore Query Optimization](https://firebase.google.com/docs/firestore/query-data/queries)
- [Firestore Pricing Calculator](https://firebase.google.com/pricing)

**Flutter Persistence**:
- [SharedPreferences Package](https://pub.dev/packages/shared_preferences)
- [Freezed Package](https://pub.dev/packages/freezed) (immutable entities)
- [Riverpod State Management](https://riverpod.dev/)

**Related Design Documents**:
- Task 3.2: [user_preference_model_v2_design.md](./user_preference_model_v2_design.md) - NotificationSettings v2.0 entity
- Task 3.3: [presentation_layer_ux_redesign.md](./presentation_layer_ux_redesign.md) - UI for settings & history
- Task 3.4: [live_activities_notification_integration.md](./live_activities_notification_integration.md) - iOS Live Activities
- Task 3.1: [notification_rules_engine_v2_design.md](./notification_rules_engine_v2_design.md) - Smart scheduling rules

---

## ✅ Design Sign-Off

**Created By**: Claude Code (task-master.dev integration - Phase 3, Task 3.5)
**Reviewed By**: (Pending - will be reviewed in Task 7.1)
**Approved By**: (Pending implementation)
**Last Updated**: 2025-01-16

**Status**: ✅ **Design Complete - Ready for Implementation**

**Next Steps**: Proceed to **PHASE 4: IMPLEMENTATION** (Task 4.1 - Domain Layer Refactoring)

---

*End of Data Layer & Persistence Strategy v2.0 Design Document*

/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/domain/repositories
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: repository_interface
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// NOTIFICATION SETTINGS REPOSITORY - Settings persistence & sync
library;

import 'package:gymbro_flutter_new/features/notifications/domain/entities/workout_notification.dart';

/// Repository interface for notification settings operations
///
/// **Responsibilities**:
/// - CRUD for NotificationSettings v2.0
/// - Cross-device synchronization (local ↔ Firestore)
/// - Migration v1.0 → v2.0
/// - GDPR compliance (consent tracking, data deletion)
///
/// **Data Flow**:
/// 1. Local cache (SharedPreferences) - Instant access, offline support
/// 2. Remote persistence (Firestore) - Cross-device sync, backup
/// 3. Sync manager - Debounced writes, conflict resolution
abstract class NotificationSettingsRepository {
  // === CRUD Operations ===

  /// Get current notification settings
  ///
  /// **Strategy**: Local cache first, fallback to Firestore
  /// - Read from SharedPreferences (instant)
  /// - If cache miss: Fetch from Firestore + cache locally
  /// - If both fail: Return defaults
  ///
  /// **Background sync**: Starts after returning local cache
  Future<NotificationSettings> getSettings();

  /// Update notification settings
  ///
  /// **Strategy**: Write local immediately, debounced sync to Firestore
  /// - Write to SharedPreferences (instant feedback)
  /// - Enqueue Firestore sync (debounced 5min)
  ///
  /// **Debounce**: Prevents spam writes (e.g., user tweaking 5 settings → 1 Firestore write)
  Future<void> updateSettings(NotificationSettings settings);

  /// Reset to default settings (v2.0 defaults)
  ///
  /// **Effect**:
  /// - Clear local cache
  /// - Clear Firestore document
  /// - Return fresh defaults
  Future<void> resetToDefaults();

  // === Synchronization ===

  /// Force immediate sync to Firestore (bypass debounce)
  ///
  /// **Use cases**:
  /// - User navigates away from settings screen
  /// - User logs out
  /// - App goes to background
  Future<void> syncNow();

  /// Get last sync timestamp
  ///
  /// **Returns**: DateTime of last successful Firestore sync, or null if never synced
  Future<DateTime?> getLastSyncTime();

  /// Check if settings are out of sync (local vs remote)
  ///
  /// **Returns**: true if remote has newer version than local
  Future<bool> isOutOfSync();

  // === Migration ===

  /// Migrate v1.0 settings to v2.0
  ///
  /// **Source**: SharedPreferences (v1.0 individual keys)
  /// **Target**: NotificationSettings v2.0 JSON + Firestore
  ///
  /// **Steps**:
  /// 1. Read v1.0 settings from SharedPreferences (11 individual keys)
  /// 2. Transform to v2.0 structure (add default values for 12 new fields)
  /// 3. Save as v2.0 JSON to SharedPreferences
  /// 4. Sync to Firestore
  /// 5. Delete old v1.0 keys (cleanup)
  ///
  /// **Returns**: Migrated NotificationSettings v2.0
  Future<NotificationSettings> migrateFromV1();

  /// Check if migration is needed
  ///
  /// **Returns**: true if v1.0 settings detected (settingsVersion < 2)
  Future<bool> needsMigration();

  // === GDPR Compliance ===

  /// Record user consent (GDPR Article 7.1)
  ///
  /// **Effect**:
  /// - Set consentTimestamp to now
  /// - Set consentVersion (e.g., '1.0')
  /// - Sync to Firestore immediately (no debounce)
  ///
  /// **GDPR Requirement**: Explicit consent before data processing
  Future<void> recordConsent(String consentVersion);

  /// Revoke consent and delete all notification data
  ///
  /// **GDPR Right to Erasure (Article 17)**
  ///
  /// **Effect**:
  /// - Delete notificationSettings from Firestore
  /// - Delete notificationHistory collection from Firestore
  /// - Delete notificationDelivery collection from Firestore
  /// - Delete notificationMetrics from Firestore
  /// - Clear all local cache (SharedPreferences)
  /// - Cancel all scheduled notifications
  ///
  /// **Warning**: Irreversible operation
  Future<void> revokeConsentAndDeleteData();

  /// Check if user has given valid consent
  ///
  /// **Returns**: true if consentTimestamp is not null
  Future<bool> hasValidConsent();

  // === Real-Time Streams ===

  /// Stream of settings changes (from Firestore real-time)
  ///
  /// **Use case**: Show sync indicator when remote changes detected
  ///
  /// **Emits**: NotificationSettings when Firestore document changes
  Stream<NotificationSettings> watchSettings();
}

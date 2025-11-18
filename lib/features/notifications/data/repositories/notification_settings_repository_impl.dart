/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/data/repositories
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: repository_implementation
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// NOTIFICATION SETTINGS REPOSITORY IMPLEMENTATION
library;

import 'package:gymbro_flutter_new/features/notifications/domain/entities/workout_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_settings_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/data/datasources/notification_local_datasource.dart';
import 'package:gymbro_flutter_new/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:gymbro_flutter_new/features/notifications/data/sync/notification_sync_manager.dart';

/// Implementation of NotificationSettingsRepository
///
/// **Data Flow**:
/// ```
/// User updates setting
///       ↓
/// updateSettings() called
///       ↓
/// 1. Save to SharedPreferences (instant)
/// 2. Enqueue Firestore sync (debounced 5 min)
///       ↓
/// After 5 min (or syncNow())
///       ↓
/// Sync to Firestore with conflict resolution
/// ```
///
/// **Offline Support**:
/// - Read: SharedPreferences first, Firestore fallback
/// - Write: SharedPreferences immediate, Firestore debounced
class NotificationSettingsRepositoryImpl
    implements NotificationSettingsRepository {
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

  // === CRUD Operations ===

  @override
  Future<NotificationSettings> getSettings() async {
    // 1. Try local first (offline support)
    final localSettings = await _localDataSource.getNotificationSettings();

    if (localSettings != null) {
      // Check if out of sync (last sync > 24h)
      final isOutOfSync = await _syncManager.isOutOfSync();

      if (!isOutOfSync) {
        return localSettings; // Use local (recently synced)
      }

      // Out of sync → fetch from Firestore
      final remoteSettings =
          await _remoteDataSource.getNotificationSettings();

      if (remoteSettings != null) {
        // Remote exists → save to local and return
        await _localDataSource.saveNotificationSettings(remoteSettings);
        await _localDataSource.setLastSyncTime(DateTime.now());
        return remoteSettings;
      }

      // Remote doesn't exist → use local
      return localSettings;
    }

    // 2. No local settings → try Firestore
    final remoteSettings = await _remoteDataSource.getNotificationSettings();

    if (remoteSettings != null) {
      // Cache to local
      await _localDataSource.saveNotificationSettings(remoteSettings);
      await _localDataSource.setLastSyncTime(DateTime.now());
      return remoteSettings;
    }

    // 3. No settings anywhere → return defaults
    final defaultSettings = NotificationSettings.defaults();
    await _localDataSource.saveNotificationSettings(defaultSettings);
    return defaultSettings;
  }

  @override
  Future<void> updateSettings(NotificationSettings settings) async {
    // Enqueue debounced sync (5 min)
    await _syncManager.enqueueSyncTask(settings);
  }

  @override
  Future<void> resetToDefaults() async {
    final defaultSettings = NotificationSettings.defaults();

    // Save to local immediately
    await _localDataSource.saveNotificationSettings(defaultSettings);

    // Sync to Firestore immediately (critical change)
    await _syncManager.syncNow(defaultSettings);
  }

  // === Sync Operations ===

  @override
  Future<void> syncNow() async {
    final currentSettings = await getSettings();
    await _syncManager.syncNow(currentSettings);
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    return await _syncManager.getLastSyncTime();
  }

  @override
  Future<bool> isOutOfSync() async {
    return await _syncManager.isOutOfSync();
  }

  // === Migration Operations ===

  @override
  Future<NotificationSettings> migrateFromV1() async {
    // Check if migration already done
    final currentSettings = await _localDataSource.getNotificationSettings();

    if (currentSettings != null && !currentSettings.needsMigration) {
      return currentSettings; // Already v2.0
    }

    // Migration happens in local datasource (_migrateV1Settings)
    // It's automatically called in getNotificationSettings()
    final migratedSettings = await getSettings();

    // Verify migration was successful
    if (migratedSettings.needsMigration) {
      throw Exception('Migration failed: settings still v1.0');
    }

    return migratedSettings;
  }

  @override
  Future<bool> needsMigration() async {
    final settings = await _localDataSource.getNotificationSettings();

    if (settings == null) {
      // Check if v1.0 keys exist (will trigger migration on next getSettings)
      // For now, assume no migration needed if no settings
      return false;
    }

    return settings.needsMigration;
  }

  // === GDPR Operations ===

  @override
  Future<void> recordConsent(String consentVersion) async {
    final currentSettings = await getSettings();

    final updatedSettings = currentSettings.copyWith(
      consentTimestamp: DateTime.now(),
      consentVersion: consentVersion,
    );

    // Save to local immediately
    await _localDataSource.saveNotificationSettings(updatedSettings);

    // Sync to Firestore immediately (critical GDPR compliance)
    await _syncManager.syncNow(updatedSettings);
  }

  @override
  Future<void> revokeConsentAndDeleteData() async {
    // 1. Delete from Firestore (all collections)
    await _remoteDataSource.deleteAllNotificationData();

    // 2. Delete from SharedPreferences
    await _localDataSource.clearAllNotificationData();

    // 3. Reset to defaults (opt-out state)
    final optOutSettings = NotificationSettings.defaults().copyWith(
      consentTimestamp: null, // No consent
      enableAnalytics: false,
      enableWorkoutReminders: false,
      enableRecoveryAlerts: false,
      enableStreakMotivation: false,
      enableRestDayReminders: false,
    );

    await _localDataSource.saveNotificationSettings(optOutSettings);
  }

  @override
  Future<bool> hasValidConsent() async {
    final settings = await getSettings();
    return settings.hasValidConsent;
  }

  // === Real-Time Streams ===

  @override
  Stream<NotificationSettings> watchSettings() {
    // Watch Firestore for real-time updates
    return _remoteDataSource.watchNotificationSettings().asyncMap((remote) async {
      if (remote == null) {
        // No remote settings → use local
        return await getSettings();
      }

      // Update local cache
      await _localDataSource.saveNotificationSettings(remote);
      await _localDataSource.setLastSyncTime(DateTime.now());

      return remote;
    });
  }
}

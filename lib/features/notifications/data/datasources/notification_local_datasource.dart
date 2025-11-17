/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/data/datasources
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: datasource
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// LOCAL DATA SOURCE - SharedPreferences persistence
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/frequency_cap.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/quiet_hours.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/workout_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/unified_notification.dart';

/// Local data source for notification persistence (SharedPreferences)
///
/// **Responsibilities**:
/// - Read/write NotificationSettings v2.0 (single JSON string)
/// - Cache notification history (last 100)
/// - Migration v1.0 → v2.0 (individual keys → JSON)
/// - Offline fallback
class NotificationLocalDataSource {
  final SharedPreferences _prefs;

  // SharedPreferences keys
  static const _keySettingsV2 = 'notification_settings_v2';
  static const _keySettingsUpdatedAt = 'notification_settings_updated_at';
  static const _keyHistoryIds = 'notification_history_ids';
  static const _keyHistoryPrefix = 'notification_history_';
  static const _keyDeliveryPrefix = 'notification_delivery_';
  static const _keyMetrics = 'notification_metrics';
  static const _keyLastSync = 'notification_last_sync';
  static const _keySyncFailedCount = 'notification_sync_failed_count';

  // v1.0 keys (for migration)
  static const _v1Keys = [
    'notif_workout_reminders',
    'notif_recovery_alerts',
    'notif_streak_motivation',
    'notif_rest_day_reminders',
    'notif_preferred_time',
    'notif_custom_time',
    'notif_smart_scheduling',
    'notif_dnd_enabled',
    'notif_dnd_start',
    'notif_dnd_end',
    'notif_reminder_minutes',
  ];

  NotificationLocalDataSource(this._prefs);

  // === NotificationSettings Operations ===

  /// Save NotificationSettings v2.0 (single JSON write)
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    try {
      final json = settings.toJson();
      final jsonString = jsonEncode(json);

      await _prefs.setString(_keySettingsV2, jsonString);
      await _prefs.setString(
        _keySettingsUpdatedAt,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('❌ Failed to save notification settings: $e');
      rethrow;
    }
  }

  /// Get NotificationSettings v2.0
  Future<NotificationSettings?> getNotificationSettings() async {
    try {
      final jsonString = _prefs.getString(_keySettingsV2);

      if (jsonString == null) {
        // Check for v1.0 settings (migration path)
        return await _migrateV1Settings();
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return NotificationSettings.fromJson(json);
    } catch (e) {
      debugPrint('⚠️ Failed to parse notification settings: $e');
      return null; // Corrupted → will trigger Firestore re-sync
    }
  }

  /// Migrate v1.0 settings to v2.0
  Future<NotificationSettings?> _migrateV1Settings() async {
    // Check if v1.0 settings exist
    final enableWorkout = _prefs.getBool('notif_workout_reminders');
    if (enableWorkout == null) {
      return null; // No v1.0 settings found
    }

    debugPrint('🔄 Migrating v1.0 settings to v2.0...');

    // Create v2.0 settings from v1.0 data
    final v2Settings = NotificationSettings(
      // v1.0 fields
      enableWorkoutReminders: enableWorkout,
      enableRecoveryAlerts: _prefs.getBool('notif_recovery_alerts') ?? true,
      enableStreakMotivation:
          _prefs.getBool('notif_streak_motivation') ?? false,
      enableRestDayReminders:
          _prefs.getBool('notif_rest_day_reminders') ?? false,
      preferredTime: NotificationTimePreference.values[
          _prefs.getInt('notif_preferred_time') ?? 0],
      customTime: _parseDateTime(_prefs.getString('notif_custom_time')),
      enableSmartScheduling: _prefs.getBool('notif_smart_scheduling') ?? true,
      doNotDisturbEnabled: _prefs.getBool('notif_dnd_enabled') ?? false,
      doNotDisturbStart: _parseDateTime(_prefs.getString('notif_dnd_start')),
      doNotDisturbEnd: _parseDateTime(_prefs.getString('notif_dnd_end')),
      reminderMinutesBefore: _prefs.getInt('notif_reminder_minutes') ?? 60,

      // v2.0 defaults
      frequencyCapPreferences: const FrequencyCap(
        maxPerDay: 3,
        maxPerWeek: 5,
        minIntervalHours: 2,
      ),
      consentTimestamp: DateTime.now(), // Grandfathered consent
      consentVersion: '1.0',
      enableAnalytics: false,
      dataRetentionDays: 90,
      settingsVersion: 2,
      migrationSource: 'v1_sharedprefs',
    );

    // Save as v2.0
    await saveNotificationSettings(v2Settings);

    // Delete old v1.0 keys (cleanup)
    for (final key in _v1Keys) {
      await _prefs.remove(key);
    }

    debugPrint('✅ Migration v1.0 → v2.0 complete');
    return v2Settings;
  }

  DateTime? _parseDateTime(String? isoString) {
    if (isoString == null) return null;
    try {
      return DateTime.parse(isoString);
    } catch (e) {
      return null;
    }
  }

  // === Notification History Operations ===

  /// Cache notification history (last 100)
  Future<void> cacheNotificationHistory(
      List<UnifiedNotification> notifications) async {
    final recent = notifications.take(100).toList();
    final ids = recent.map((n) => n.id).toList();

    // Save IDs list
    await _prefs.setString(_keyHistoryIds, jsonEncode(ids));

    // Save individual notifications
    for (final notification in recent) {
      final key = '$_keyHistoryPrefix${notification.id}';
      await _prefs.setString(key, jsonEncode(notification.toJson()));
    }

    // Cleanup old cached notifications
    final allKeys = _prefs.getKeys();
    final historyKeys =
        allKeys.where((k) => k.startsWith(_keyHistoryPrefix));
    for (final key in historyKeys) {
      final id = key.replaceFirst(_keyHistoryPrefix, '');
      if (!ids.contains(id)) {
        await _prefs.remove(key);
      }
    }
  }

  /// Get cached notification history
  Future<List<UnifiedNotification>> getCachedNotificationHistory() async {
    final idsJson = _prefs.getString(_keyHistoryIds);
    if (idsJson == null) return [];

    final ids = (jsonDecode(idsJson) as List).cast<String>();
    final notifications = <UnifiedNotification>[];

    for (final id in ids) {
      final key = '$_keyHistoryPrefix$id';
      final json = _prefs.getString(key);
      if (json != null) {
        try {
          final notification = UnifiedNotification.fromJson(
            jsonDecode(json) as Map<String, dynamic>,
          );
          notifications.add(notification);
        } catch (e) {
          debugPrint('⚠️ Skipping corrupted notification $id: $e');
        }
      }
    }

    return notifications;
  }

  // === Cleanup Operations ===

  /// Clear all notification data (GDPR right to erasure)
  Future<void> clearAllNotificationData() async {
    // Clear settings
    await _prefs.remove(_keySettingsV2);
    await _prefs.remove(_keySettingsUpdatedAt);

    // Clear history
    await _prefs.remove(_keyHistoryIds);
    final allKeys = _prefs.getKeys();
    for (final key in allKeys.where((k) =>
        k.startsWith(_keyHistoryPrefix) ||
        k.startsWith(_keyDeliveryPrefix))) {
      await _prefs.remove(key);
    }

    // Clear metrics
    await _prefs.remove(_keyMetrics);

    // Clear sync metadata
    await _prefs.remove(_keyLastSync);
    await _prefs.remove(_keySyncFailedCount);

    debugPrint('✅ All notification data cleared from local storage');
  }

  // === Sync Metadata Operations ===

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    final isoString = _prefs.getString(_keyLastSync);
    return _parseDateTime(isoString);
  }

  /// Set last sync timestamp
  Future<void> setLastSyncTime(DateTime timestamp) async {
    await _prefs.setString(_keyLastSync, timestamp.toIso8601String());
  }

  /// Increment sync failed count (for exponential backoff)
  Future<void> incrementSyncFailedCount() async {
    final count = _prefs.getInt(_keySyncFailedCount) ?? 0;
    await _prefs.setInt(_keySyncFailedCount, count + 1);
  }

  /// Reset sync failed count
  Future<void> resetSyncFailedCount() async {
    await _prefs.setInt(_keySyncFailedCount, 0);
  }

  /// Get sync failed count
  Future<int> getSyncFailedCount() async {
    return _prefs.getInt(_keySyncFailedCount) ?? 0;
  }
}

/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/notifications/domain/usecases
/// 🎯 Feature: smart_notifications_v2
/// 🔧 Type: use_case
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// MIGRATE NOTIFICATION SETTINGS USE CASE - v1.0 → v2.0 migration
library;

import 'package:gymbro_flutter_new/features/notifications/domain/entities/frequency_cap.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/workout_notification.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_settings_repository.dart';

/// Use case for migrating NotificationSettings from v1.0 to v2.0
///
/// **Migration Path**: SharedPreferences (v1.0 individual keys) → NotificationSettings v2.0 JSON
///
/// **Changes v1.0 → v2.0**:
/// - v1.0: 11 fields stored as individual SharedPreferences keys
/// - v2.0: 22 fields stored as single JSON string + Firestore sync
///
/// **New v2.0 Fields** (12 total):
/// - customTimePerType (Map<String, DateTime>)
/// - categoryQuietHours (Map<String, QuietHours>)
/// - frequencyCapPreferences (FrequencyCap)
/// - categoryFrequencyCaps (Map<String, FrequencyCap>)
/// - consentTimestamp (DateTime?)
/// - consentVersion (String)
/// - enableAnalytics (bool)
/// - dataRetentionDays (int)
/// - lastSyncedAt (DateTime?)
/// - deviceId (String?)
/// - settingsVersion (int)
/// - migrationSource (String?)
///
/// **GDPR Note**: Grandfathered users assumed implicit consent (consentTimestamp = now)
class MigrateNotificationSettings {
  final NotificationSettingsRepository _repository;

  MigrateNotificationSettings(this._repository);

  /// Execute migration
  ///
  /// **Steps**:
  /// 1. Check if migration needed (settingsVersion < 2)
  /// 2. Read v1.0 settings from SharedPreferences
  /// 3. Transform to v2.0 structure
  /// 4. Save to Firestore + local cache
  /// 5. Delete old v1.0 keys
  /// 6. Mark migration complete
  ///
  /// **Returns**: Migrated NotificationSettings v2.0
  ///
  /// **Throws**: Exception if no v1.0 settings found or migration fails
  Future<NotificationSettings> execute() async {
    // 1. Check if migration needed
    final needsMigration = await _repository.needsMigration();

    if (!needsMigration) {
      // Already v2.0, return current settings
      return await _repository.getSettings();
    }

    // 2-5. Delegate to repository (data layer handles low-level migration)
    final migratedSettings = await _repository.migrateFromV1();

    // 6. Sync to Firestore immediately (no debounce for migration)
    await _repository.syncNow();

    return migratedSettings;
  }
}

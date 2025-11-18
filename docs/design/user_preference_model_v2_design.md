# User Preference Model v2.0 - Design Document

**Created**: 2025-11-15
**Status**: ✅ DESIGN COMPLETE
**Phase**: PHASE 3: DESIGN - Task 3.2
**Related**: notification_rules_engine_v2_design.md, notification_gdpr_audit.md

---

## 📋 Executive Summary

Enhanced NotificationSettings entity with:
- ✅ **Per-category quiet hours** (not just global DND)
- ✅ **GDPR consent tracking** (Article 7.1 compliance)
- ✅ **Frequency cap preferences** (user-customizable 5/week default)
- ✅ **Enhanced time picker** (custom per notification type)
- ✅ **Cross-device sync** structure
- ✅ **Analytics opt-in/out**
- ✅ **Data retention preferences**

**Backward Compatibility**: ✅ Full backward compatibility with v1.0 via optional fields + migration helper

---

## 🎯 Problem Statement

### Current NotificationSettings Gaps (from weaknesses audit)

| Gap | Impact | Priority |
|-----|--------|----------|
| **No per-category quiet hours** | High-priority notifications get blocked | 🔴 CRITICAL |
| **No GDPR consent tracking** | Legal risk - Article 7.1 violation | 🔴 CRITICAL |
| **Hardcoded frequency caps** | Users can't customize spam tolerance | 🟡 HIGH |
| **Global DND only** | Workout reminders blocked during gym time | 🟡 HIGH |
| **No sync metadata** | Settings lost on device change | 🟡 HIGH |
| **No analytics opt-in** | GDPR compliance gap | 🔴 CRITICAL |

### User Scenarios Requiring Enhancement

**Scenario 1: Power User with Custom Preferences**
```
User: "I want workout reminders during lunch (12:30), but NO
       notifications during meetings (9-11 AM and 2-4 PM)"

Current: ❌ Can only set global DND (22:00-7:00)
v2.0: ✅ Per-category quiet hours + custom time per type
```

**Scenario 2: Privacy-Conscious User**
```
User: "I want GDPR compliance proof. Show me when I consented
       and what data you're storing"

Current: ❌ No consent timestamp, no audit trail
v2.0: ✅ Consent tracking + data retention preferences + audit log
```

**Scenario 3: Multi-Device User**
```
User: "I changed notification settings on iPhone, but Android
       still shows old preferences"

Current: ❌ SharedPreferences (local only, no sync)
v2.0: ✅ Firestore sync with conflict resolution
```

---

## 🏗️ Architecture Design

### Entity Structure v2.0

#### 1. NotificationSettings v2.0 (Enhanced)

**Location**: `lib/features/notifications/domain/entities/notification_settings.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_type.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/frequency_cap.dart';

part 'notification_settings.freezed.dart';
part 'notification_settings.g.dart';

/// Enhanced notification settings entity (v2.0)
///
/// **Backward Compatibility**: All new fields are optional or have defaults
/// **GDPR Compliance**: Consent tracking + data retention
/// **Per-Category Control**: Quiet hours, frequency caps, custom times
///
/// **Changelog v2.0**:
/// - Added per-category quiet hours (categoryQuietHours)
/// - Added GDPR consent tracking (consentTimestamp, consentVersion)
/// - Added frequency cap preferences (frequencyCapPreferences)
/// - Added analytics opt-in (enableAnalytics)
/// - Added data retention preferences (dataRetentionDays)
/// - Added cross-device sync metadata (lastSyncedAt, deviceId)
/// - Enhanced custom time support (customTimePerType)
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 🔔 NOTIFICATION TYPE TOGGLES (v1.0 - unchanged)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    @Default(true) bool enableWorkoutReminders,
    @Default(true) bool enableRecoveryAlerts,
    @Default(false) bool enableStreakMotivation,
    @Default(false) bool enableRestDayReminders,

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ⏰ TIME PREFERENCES (v1.0 - enhanced in v2.0)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    @Default(NotificationTimePreference.morning)
    NotificationTimePreference preferredTime,
    DateTime? customTime, // Global custom time (v1.0)

    /// 🆕 v2.0: Custom time per notification type
    /// Example: { NotificationType.workoutReminder: DateTime(2000,1,1,12,30) }
    @Default({}) Map<NotificationType, DateTime> customTimePerType,

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 🤖 SMART SCHEDULING (v1.0 - unchanged)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    @Default(true) bool enableSmartScheduling,
    @Default(60) int reminderMinutesBefore,

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 🌙 QUIET HOURS (v1.0 - global DND, enhanced in v2.0)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    @Default(false) bool doNotDisturbEnabled,
    DateTime? doNotDisturbStart, // Global DND start (v1.0)
    DateTime? doNotDisturbEnd, // Global DND end (v1.0)

    /// 🆕 v2.0: Per-category quiet hours
    /// Example: { NotificationType.workoutReminder: QuietHours(...) }
    /// **Priority logic**: High-priority notifications can bypass quiet hours
    @Default({}) Map<NotificationType, QuietHours> categoryQuietHours,

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 📊 FREQUENCY CAPS (v2.0 - NEW)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    /// 🆕 v2.0: User-customizable frequency caps
    /// **Default**: FrequencyCap(maxPerWeek: 5, maxPerDay: 3, minIntervalHours: 2)
    /// **Research-backed**: 64% users quit if >5/week
    FrequencyCap? frequencyCapPreferences,

    /// 🆕 v2.0: Per-category frequency caps
    /// Example: { NotificationType.streakReminder: FrequencyCap(maxPerWeek: 2) }
    @Default({}) Map<NotificationType, FrequencyCap> categoryFrequencyCaps,

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 🔒 GDPR COMPLIANCE (v2.0 - NEW)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    /// 🆕 v2.0: GDPR Article 7.1 consent timestamp
    /// **Requirement**: Must record when user consented
    /// **Format**: ISO 8601 UTC timestamp
    DateTime? consentTimestamp,

    /// 🆕 v2.0: GDPR consent version
    /// **Purpose**: Track which privacy policy version user consented to
    /// **Format**: "1.0", "1.1", etc.
    @Default('1.0') String consentVersion,

    /// 🆕 v2.0: Explicit consent for notification analytics
    /// **GDPR Article 6**: Requires explicit consent for data processing
    @Default(false) bool enableAnalytics,

    /// 🆕 v2.0: Data retention preference (days)
    /// **Default**: 90 days (GDPR Article 5.1.e - storage limitation)
    /// **Options**: 30, 60, 90, 180 days
    @Default(90) int dataRetentionDays,

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // ☁️ CROSS-DEVICE SYNC (v2.0 - NEW)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    /// 🆕 v2.0: Last sync timestamp (UTC)
    /// **Purpose**: Track when settings were last synced to Firestore
    DateTime? lastSyncedAt,

    /// 🆕 v2.0: Device ID that last modified settings
    /// **Purpose**: Conflict resolution (last-write-wins)
    String? deviceId,

    /// 🆕 v2.0: Settings version (for migration)
    /// **Purpose**: Track schema version for backward compatibility
    @Default(2) int settingsVersion,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);
}
```

#### 2. QuietHours Entity (NEW)

**Location**: `lib/features/notifications/domain/entities/quiet_hours.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiet_hours.freezed.dart';
part 'quiet_hours.g.dart';

/// Per-category quiet hours entity
///
/// **Purpose**: Allow different quiet hours per notification type
/// **Example**: Block workout reminders during meetings (9-11 AM, 2-4 PM)
///
/// **Priority Bypass**: High-priority notifications can bypass quiet hours
/// if `allowPriorityBypass` is true
@freezed
class QuietHours with _$QuietHours {
  const factory QuietHours({
    /// Start time (hour + minute only, date ignored)
    required DateTime startTime,

    /// End time (hour + minute only, date ignored)
    required DateTime endTime,

    /// Allow high-priority notifications to bypass quiet hours
    /// **Default**: true (urgent notifications always shown)
    @Default(true) bool allowPriorityBypass,

    /// Days of week when quiet hours apply
    /// **Format**: [1-7] where 1=Monday, 7=Sunday
    /// **Default**: All days (empty list = all days)
    @Default([]) List<int> daysOfWeek,
  }) = _QuietHours;

  factory QuietHours.fromJson(Map<String, dynamic> json) =>
      _$QuietHoursFromJson(json);
}

/// Extension for QuietHours operations
extension QuietHoursExtensions on QuietHours {
  /// Check if current time is in quiet hours
  bool isInQuietHours(DateTime time) {
    // Check day of week if specified
    if (daysOfWeek.isNotEmpty && !daysOfWeek.contains(time.weekday)) {
      return false;
    }

    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    // Handle overnight quiet hours (e.g., 22:00 - 7:00)
    if (startMinutes > endMinutes) {
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }

    return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
  }

  /// Adjust time to avoid quiet hours
  DateTime adjustTimeForQuietHours(DateTime scheduledTime) {
    if (!isInQuietHours(scheduledTime)) {
      return scheduledTime;
    }

    // Move to end of quiet hours
    return DateTime(
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      endTime.hour,
      endTime.minute,
    );
  }
}
```

#### 3. NotificationSettingsExtensions (Enhanced)

**Location**: `lib/features/notifications/domain/entities/notification_settings.dart` (same file)

```dart
/// Enhanced extensions for NotificationSettings v2.0
extension NotificationSettingsExtensions on NotificationSettings {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ⏰ TIME PREFERENCE HELPERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Get preferred notification time for specific type
  /// **v2.0 Enhancement**: Supports per-type custom times
  DateTime getPreferredTimeForDate(
    DateTime date, {
    NotificationType? type,
  }) {
    // Check per-type custom time first (v2.0)
    if (type != null && customTimePerType.containsKey(type)) {
      final customTypeTime = customTimePerType[type]!;
      return DateTime(
        date.year,
        date.month,
        date.day,
        customTypeTime.hour,
        customTypeTime.minute,
      );
    }

    // Fall back to global preference (v1.0 logic)
    switch (preferredTime) {
      case NotificationTimePreference.morning:
        return DateTime(date.year, date.month, date.day, 8, 0); // 8:00
      case NotificationTimePreference.midday:
        return DateTime(date.year, date.month, date.day, 12, 30); // 12:30
      case NotificationTimePreference.afternoon:
        return DateTime(date.year, date.month, date.day, 16, 0); // 16:00
      case NotificationTimePreference.evening:
        return DateTime(date.year, date.month, date.day, 19, 0); // 19:00
      case NotificationTimePreference.custom:
        if (customTime != null) {
          return DateTime(
            date.year,
            date.month,
            date.day,
            customTime!.hour,
            customTime!.minute,
          );
        }
        return DateTime(date.year, date.month, date.day, 8, 0); // Default
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🌙 QUIET HOURS HELPERS (v2.0 - Per-Category)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Check if time is in quiet hours (global OR per-category)
  /// **v2.0 Enhancement**: Checks per-category quiet hours first
  bool isInQuietHours(
    DateTime time, {
    NotificationType? type,
    NotificationPriority? priority,
  }) {
    // 1. Check per-category quiet hours first (v2.0)
    if (type != null && categoryQuietHours.containsKey(type)) {
      final categoryQH = categoryQuietHours[type]!;
      if (categoryQH.isInQuietHours(time)) {
        // Allow priority bypass if enabled
        if (categoryQH.allowPriorityBypass &&
            priority == NotificationPriority.high) {
          return false; // Not in quiet hours (bypassed)
        }
        return true; // In quiet hours
      }
    }

    // 2. Fall back to global DND (v1.0 logic)
    if (!doNotDisturbEnabled ||
        doNotDisturbStart == null ||
        doNotDisturbEnd == null) {
      return false;
    }

    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = doNotDisturbStart!.hour * 60 + doNotDisturbStart!.minute;
    final endMinutes = doNotDisturbEnd!.hour * 60 + doNotDisturbEnd!.minute;

    // Handle overnight DND (e.g., 22:00 - 7:00)
    if (startMinutes > endMinutes) {
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }

    return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
  }

  /// Adjust time to avoid quiet hours (global AND per-category)
  /// **v2.0 Enhancement**: Uses per-category quiet hours if available
  DateTime adjustForQuietHours(
    DateTime scheduledTime, {
    NotificationType? type,
    NotificationPriority? priority,
  }) {
    // Try per-category adjustment first (v2.0)
    if (type != null && categoryQuietHours.containsKey(type)) {
      final categoryQH = categoryQuietHours[type]!;
      if (categoryQH.isInQuietHours(scheduledTime)) {
        // Allow priority bypass
        if (categoryQH.allowPriorityBypass &&
            priority == NotificationPriority.high) {
          return scheduledTime; // Don't adjust
        }
        return categoryQH.adjustTimeForQuietHours(scheduledTime);
      }
    }

    // Fall back to global DND adjustment (v1.0 logic)
    if (!isInQuietHours(scheduledTime, type: type, priority: priority)) {
      return scheduledTime;
    }

    if (doNotDisturbEnd != null) {
      return DateTime(
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day,
        doNotDisturbEnd!.hour,
        doNotDisturbEnd!.minute,
      );
    }

    return scheduledTime;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 📊 FREQUENCY CAP HELPERS (v2.0 - NEW)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Get frequency cap for specific notification type
  /// **Priority**: Per-category > Global > Default (5/week, 3/day, 2h)
  FrequencyCap getFrequencyCapForType(NotificationType type) {
    // 1. Check per-category cap
    if (categoryFrequencyCaps.containsKey(type)) {
      return categoryFrequencyCaps[type]!;
    }

    // 2. Check global user preference
    if (frequencyCapPreferences != null) {
      return frequencyCapPreferences!;
    }

    // 3. Use research-backed defaults
    return const FrequencyCap(
      maxPerDay: 3,
      maxPerWeek: 5, // 64% quit risk if exceeded
      minIntervalHours: 2,
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🔒 GDPR COMPLIANCE HELPERS (v2.0 - NEW)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Check if user has valid GDPR consent
  /// **Article 7.1**: Consent must be recorded
  bool hasValidConsent() {
    return consentTimestamp != null;
  }

  /// Check if consent is expired (>2 years old)
  /// **Best Practice**: Re-confirm consent every 2 years
  bool isConsentExpired() {
    if (consentTimestamp == null) return true;

    final daysSinceConsent = DateTime.now().difference(consentTimestamp!).inDays;
    return daysSinceConsent > 730; // 2 years
  }

  /// Check if data retention period is compliant
  /// **GDPR Article 5.1.e**: Data shouldn't be kept longer than necessary
  bool isDataRetentionCompliant() {
    return dataRetentionDays >= 30 && dataRetentionDays <= 180;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ☁️ SYNC HELPERS (v2.0 - NEW)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Check if settings need sync
  /// **Threshold**: >5 minutes since last sync
  bool needsSync() {
    if (lastSyncedAt == null) return true;

    final minutesSinceSync = DateTime.now().difference(lastSyncedAt!).inMinutes;
    return minutesSinceSync > 5;
  }

  /// Create settings snapshot for sync
  NotificationSettings withSyncMetadata(String currentDeviceId) {
    return copyWith(
      lastSyncedAt: DateTime.now().toUtc(),
      deviceId: currentDeviceId,
    );
  }
}
```

---

## 🔄 Migration Strategy

### v1.0 → v2.0 Migration Helper

**Location**: `lib/features/notifications/domain/usecases/migrate_notification_settings.dart`

```dart
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_settings.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/frequency_cap.dart';

/// Migration helper for NotificationSettings v1.0 → v2.0
///
/// **Purpose**: Ensure backward compatibility during upgrade
/// **Strategy**: Add default values for new fields
class MigrateNotificationSettings {
  /// Migrate v1.0 settings to v2.0
  ///
  /// **Changes**:
  /// - Adds default FrequencyCap (5/week, 3/day, 2h)
  /// - Adds consent timestamp (current time if notifications enabled)
  /// - Initializes empty per-category maps
  /// - Sets settings version to 2
  NotificationSettings execute(NotificationSettings v1Settings) {
    // Check if already v2.0
    if (v1Settings.settingsVersion >= 2) {
      return v1Settings;
    }

    // Migrate to v2.0
    return v1Settings.copyWith(
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // 📊 FREQUENCY CAPS
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      frequencyCapPreferences: const FrequencyCap(
        maxPerDay: 3,
        maxPerWeek: 5, // Research-backed default
        minIntervalHours: 2,
      ),
      categoryFrequencyCaps: {}, // Empty by default

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // 🌙 QUIET HOURS
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      categoryQuietHours: {}, // Empty by default
      customTimePerType: {}, // Empty by default

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // 🔒 GDPR COMPLIANCE
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // Add consent timestamp if user has notifications enabled
      consentTimestamp: (v1Settings.enableWorkoutReminders ||
              v1Settings.enableRecoveryAlerts ||
              v1Settings.enableStreakMotivation ||
              v1Settings.enableRestDayReminders)
          ? DateTime.now().toUtc()
          : null,
      consentVersion: '1.0',
      enableAnalytics: false, // Default to opt-out (GDPR-safe)
      dataRetentionDays: 90, // GDPR-compliant default

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // ☁️ SYNC METADATA
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      lastSyncedAt: null, // Will be set on first sync
      deviceId: null, // Will be set on first save
      settingsVersion: 2, // Mark as v2.0
    );
  }
}
```

### Migration Testing Strategy

```dart
// test/features/notifications/domain/usecases/migrate_notification_settings_test.dart

void main() {
  group('MigrateNotificationSettings', () {
    late MigrateNotificationSettings useCase;

    setUp(() {
      useCase = MigrateNotificationSettings();
    });

    test('should migrate v1.0 settings to v2.0 with defaults', () {
      // Arrange
      const v1Settings = NotificationSettings(
        enableWorkoutReminders: true,
        enableRecoveryAlerts: true,
        preferredTime: NotificationTimePreference.morning,
        settingsVersion: 1, // v1.0
      );

      // Act
      final v2Settings = useCase.execute(v1Settings);

      // Assert
      expect(v2Settings.settingsVersion, 2);
      expect(v2Settings.frequencyCapPreferences, isNotNull);
      expect(v2Settings.frequencyCapPreferences!.maxPerWeek, 5);
      expect(v2Settings.consentTimestamp, isNotNull); // Notifications enabled
      expect(v2Settings.dataRetentionDays, 90);
    });

    test('should not migrate if already v2.0', () {
      // Arrange
      final v2Settings = NotificationSettings(
        settingsVersion: 2,
        consentTimestamp: DateTime(2025, 1, 1),
      );

      // Act
      final result = useCase.execute(v2Settings);

      // Assert
      expect(result, same(v2Settings)); // No changes
    });

    test('should not add consent timestamp if notifications disabled', () {
      // Arrange
      const v1Settings = NotificationSettings(
        enableWorkoutReminders: false,
        enableRecoveryAlerts: false,
        settingsVersion: 1,
      );

      // Act
      final v2Settings = useCase.execute(v1Settings);

      // Assert
      expect(v2Settings.consentTimestamp, isNull); // No consent needed
    });
  });
}
```

---

## 📱 UI Enhancement Examples

### 1. Per-Category Quiet Hours UI

**Screen**: NotificationSettingsScreen → Advanced Settings

```dart
// lib/features/notifications/presentation/screens/advanced_notification_settings_screen.dart

class AdvancedNotificationSettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.advancedNotificationSettings),
      ),
      body: ListView(
        children: [
          // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          // 🌙 PER-CATEGORY QUIET HOURS
          // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          _buildSectionHeader(
            context,
            context.l10n.perCategoryQuietHours,
            context.l10n.perCategoryQuietHoursSubtitle,
          ),

          _buildCategoryQuietHoursTile(
            context,
            ref,
            NotificationType.workoutReminder,
            context.l10n.workoutReminders,
          ),

          _buildCategoryQuietHoursTile(
            context,
            ref,
            NotificationType.recoveryAlert,
            context.l10n.recoveryAlerts,
          ),

          // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          // 📊 FREQUENCY CAP PREFERENCES
          // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          _buildSectionHeader(
            context,
            context.l10n.frequencyCapPreferences,
            context.l10n.frequencyCapSubtitle,
          ),

          _buildFrequencyCapSlider(
            context,
            ref,
            label: context.l10n.maxNotificationsPerWeek,
            value: settings.frequencyCapPreferences?.maxPerWeek ?? 5,
            min: 2,
            max: 10,
            onChanged: (value) {
              final newCap = settings.getFrequencyCapForType(
                NotificationType.workoutReminder,
              ).copyWith(maxPerWeek: value.toInt());

              ref.read(notificationSettingsProvider.notifier).updateSettings(
                settings.copyWith(frequencyCapPreferences: newCap),
              );
            },
          ),

          // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          // 🔒 GDPR DATA PREFERENCES
          // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          _buildSectionHeader(
            context,
            context.l10n.privacyDataSettings,
            context.l10n.gdprCompliantDataHandling,
          ),

          SwitchListTile(
            title: Text(context.l10n.enableNotificationAnalytics),
            subtitle: Text(context.l10n.analyticsHelpImproveExperience),
            value: settings.enableAnalytics,
            onChanged: (enabled) {
              ref.read(notificationSettingsProvider.notifier).updateSettings(
                settings.copyWith(enableAnalytics: enabled),
              );
            },
          ),

          _buildDataRetentionDropdown(context, ref, settings),

          // Show consent info
          if (settings.consentTimestamp != null)
            ListTile(
              leading: Icon(AppIcons.checkCircle, color: context.iconSuccess),
              title: Text(context.l10n.consentGranted),
              subtitle: Text(
                context.l10n.consentGrantedOn(
                  DateFormat.yMMMd().format(settings.consentTimestamp!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryQuietHoursTile(
    BuildContext context,
    WidgetRef ref,
    NotificationType type,
    String label,
  ) {
    final settings = ref.watch(notificationSettingsProvider);
    final hasQuietHours = settings.categoryQuietHours.containsKey(type);
    final quietHours = settings.categoryQuietHours[type];

    return ListTile(
      leading: Icon(AppIcons.moonStars),
      title: Text(label),
      subtitle: hasQuietHours
          ? Text(context.l10n.quietHoursActive(
              '${quietHours!.startTime.hour}:${quietHours.startTime.minute.toString().padLeft(2, '0')}',
              '${quietHours.endTime.hour}:${quietHours.endTime.minute.toString().padLeft(2, '0')}',
            ))
          : Text(context.l10n.noQuietHoursSet),
      trailing: Icon(AppIcons.chevronRight),
      onTap: () {
        _showQuietHoursPicker(context, ref, type);
      },
    );
  }

  Future<void> _showQuietHoursPicker(
    BuildContext context,
    WidgetRef ref,
    NotificationType type,
  ) async {
    // Show time picker dialog for start/end times
    // Implementation in Task 3.3 (Presentation Layer UX Redesign)
  }
}
```

### 2. GDPR Consent Dialog

**Location**: `lib/features/notifications/presentation/widgets/gdpr_consent_dialog.dart`

```dart
class GDPRConsentDialog extends StatelessWidget {
  const GDPRConsentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.notificationPermissionTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.gdprConsentMessage),
            const SizedBox(height: 16),

            // What data we collect
            Text(
              context.l10n.dataWeCollect,
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(context.l10n.notificationDataList),
            const SizedBox(height: 16),

            // How we use it
            Text(
              context.l10n.howWeUseYourData,
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(context.l10n.notificationDataUsage),
            const SizedBox(height: 16),

            // Your rights
            Text(
              context.l10n.yourRights,
              style: context.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(context.l10n.gdprRightsList),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.decline),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.acceptAndContinue),
        ),
      ],
    );
  }

  /// Show consent dialog and record consent timestamp
  static Future<bool> show(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GDPRConsentDialog(),
    );

    if (result == true) {
      // Record consent
      final settings = ref.read(notificationSettingsProvider);
      await ref.read(notificationSettingsProvider.notifier).updateSettings(
        settings.copyWith(
          consentTimestamp: DateTime.now().toUtc(),
          consentVersion: '1.0',
        ),
      );
    }

    return result ?? false;
  }
}
```

---

## 🔄 Cross-Device Sync Architecture

### Firestore Schema

**Collection**: `users/{userId}/notificationSettings`

**Document Structure**:
```json
{
  "enableWorkoutReminders": true,
  "enableRecoveryAlerts": true,
  "preferredTime": "morning",
  "frequencyCapPreferences": {
    "maxPerDay": 3,
    "maxPerWeek": 5,
    "minIntervalHours": 2
  },
  "categoryQuietHours": {
    "workoutReminder": {
      "startTime": "2000-01-01T09:00:00Z",
      "endTime": "2000-01-01T11:00:00Z",
      "allowPriorityBypass": true,
      "daysOfWeek": [1, 2, 3, 4, 5]
    }
  },
  "consentTimestamp": "2025-01-15T14:30:00Z",
  "consentVersion": "1.0",
  "enableAnalytics": false,
  "dataRetentionDays": 90,
  "lastSyncedAt": "2025-01-15T14:35:00Z",
  "deviceId": "iPhone_15_Pro",
  "settingsVersion": 2
}
```

### Sync Strategy

**Repository Method** (to be implemented in Task 4.2):
```dart
// lib/features/notifications/data/repositories/notification_settings_repository_impl.dart

class NotificationSettingsRepositoryImpl {
  Future<NotificationSettings> syncSettings(
    String userId,
    NotificationSettings localSettings,
  ) async {
    // 1. Fetch remote settings
    final remoteSettings = await _fetchRemoteSettings(userId);

    // 2. Conflict resolution (last-write-wins based on lastSyncedAt)
    final resolvedSettings = _resolveConflicts(localSettings, remoteSettings);

    // 3. Save back to Firestore
    await _saveRemoteSettings(userId, resolvedSettings);

    // 4. Update local with sync metadata
    return resolvedSettings.withSyncMetadata(_deviceId);
  }

  NotificationSettings _resolveConflicts(
    NotificationSettings local,
    NotificationSettings? remote,
  ) {
    // If no remote, use local
    if (remote == null) return local;

    // Compare lastSyncedAt timestamps
    final localTimestamp = local.lastSyncedAt ?? DateTime(2000);
    final remoteTimestamp = remote.lastSyncedAt ?? DateTime(2000);

    // Last-write-wins
    return remoteTimestamp.isAfter(localTimestamp) ? remote : local;
  }
}
```

---

## 📊 Comparison: v1.0 vs v2.0

| Feature | v1.0 | v2.0 | Status |
|---------|------|------|--------|
| **Global DND** | ✅ Yes | ✅ Yes (backward compatible) | Unchanged |
| **Per-Category Quiet Hours** | ❌ No | ✅ Yes | 🆕 NEW |
| **Custom Time** | ✅ Global only | ✅ Global + Per-Type | Enhanced |
| **Frequency Caps** | ❌ No | ✅ Yes (user-customizable) | 🆕 NEW |
| **GDPR Consent Tracking** | ❌ No | ✅ Yes (timestamp + version) | 🆕 NEW |
| **Analytics Opt-In** | ❌ No | ✅ Yes (explicit consent) | 🆕 NEW |
| **Data Retention** | ❌ No | ✅ Yes (30-180 days) | 🆕 NEW |
| **Cross-Device Sync** | ❌ No | ✅ Yes (Firestore) | 🆕 NEW |
| **Priority Bypass** | ❌ No | ✅ Yes (high-priority) | 🆕 NEW |
| **Settings Version** | ❌ No | ✅ Yes (migration support) | 🆕 NEW |

---

## ✅ Implementation Checklist

### Domain Layer (Task 4.1)

- [ ] Create QuietHours entity (`quiet_hours.dart`)
- [ ] Update NotificationSettings entity with v2.0 fields
- [ ] Add NotificationSettingsExtensions enhancements
- [ ] Create MigrateNotificationSettings use case
- [ ] Run `flutter pub run build_runner build`

### Data Layer (Task 4.2)

- [ ] Update NotificationSettingsNotifier to handle new fields
- [ ] Implement Firestore sync repository
- [ ] Add SharedPreferences persistence for new fields
- [ ] Implement conflict resolution logic

### Presentation Layer (Task 5.1)

- [ ] Create AdvancedNotificationSettingsScreen
- [ ] Create GDPRConsentDialog
- [ ] Add per-category quiet hours picker
- [ ] Add frequency cap sliders
- [ ] Add data retention dropdown

### Testing (Task 6.1)

- [ ] Unit tests for QuietHours entity
- [ ] Unit tests for MigrateNotificationSettings
- [ ] Unit tests for NotificationSettingsExtensions
- [ ] Widget tests for GDPR consent dialog

---

## 📚 Related Documentation

- **Rules Engine v2.0**: `notification_rules_engine_v2_design.md` (Task 3.1)
- **GDPR Audit**: `notification_gdpr_audit.md` (Task 2.4)
- **Weaknesses Audit**: `notification_system_weaknesses.md` (Task 2.2)
- **Retention Study**: `notification_retention_study.md` (Task 1.2)

---

## 🎯 Success Criteria

✅ **GDPR Compliance**: Consent tracking + data retention + analytics opt-in
✅ **User Flexibility**: Per-category quiet hours + frequency caps
✅ **Cross-Device Sync**: Settings persist across devices
✅ **Backward Compatibility**: v1.0 settings migrate seamlessly
✅ **Transparent Control**: Users understand what data is collected and why

---

**Document Version**: 1.0
**Last Updated**: 2025-11-15
**Next Task**: 3.3 - Presentation Layer UX Redesign

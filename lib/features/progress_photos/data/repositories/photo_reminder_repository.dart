import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/progress_photos/domain/entities/photo_reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for storing and retrieving photo reminder settings
///
/// Uses SharedPreferences for local storage since:
/// - Settings are user-local (no sync needed)
/// - Simple key-value structure
/// - Fast access for notification scheduling
class PhotoReminderRepository {
  final SharedPreferences _prefs;

  /// Key for storing reminder settings
  static const String _settingsKey = 'photo_reminder_settings';

  /// Key for storing reminder history
  static const String _historyKey = 'photo_reminder_history';

  PhotoReminderRepository({required SharedPreferences prefs}) : _prefs = prefs;

  /// Get current reminder settings
  PhotoReminderSettings getSettings() {
    final json = _prefs.getString(_settingsKey);
    if (json == null) {
      return PhotoReminderSettings.defaults();
    }

    try {
      return PhotoReminderSettings.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PhotoReminderRepo] Error parsing settings: $e');
      }
      return PhotoReminderSettings.defaults();
    }
  }

  /// Save reminder settings
  Future<bool> saveSettings(PhotoReminderSettings settings) async {
    try {
      final json = jsonEncode(settings.toJson());
      final result = await _prefs.setString(_settingsKey, json);

      if (kDebugMode) {
        debugPrint('[PhotoReminderRepo] Settings saved: ${settings.isEnabled}');
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PhotoReminderRepo] Error saving settings: $e');
      }
      return false;
    }
  }

  /// Update settings with a modifier function
  Future<PhotoReminderSettings> updateSettings(
    PhotoReminderSettings Function(PhotoReminderSettings current) modifier,
  ) async {
    final current = getSettings();
    final updated = modifier(current);
    await saveSettings(updated);
    return updated;
  }

  /// Enable reminders with optional configuration
  Future<PhotoReminderSettings> enableReminders({
    PhotoReminderFrequency frequency = PhotoReminderFrequency.monthly,
    int hour = 9,
    int minute = 0,
  }) async {
    return updateSettings(
      (current) => current.copyWith(
        isEnabled: true,
        frequency: frequency,
        reminderHour: hour,
        reminderMinute: minute,
        consecutiveIgnores: 0,
        disabledByAntiSpam: false,
      ),
    );
  }

  /// Disable reminders
  Future<PhotoReminderSettings> disableReminders({
    bool byAntiSpam = false,
  }) async {
    return updateSettings(
      (current) => current.copyWith(
        isEnabled: false,
        disabledByAntiSpam: byAntiSpam,
        notificationId: null,
      ),
    );
  }

  /// Update next scheduled reminder
  Future<PhotoReminderSettings> updateNextReminder(
    DateTime nextReminder,
  ) async {
    return updateSettings(
      (current) => current.copyWith(nextReminderScheduled: nextReminder),
    );
  }

  /// Record that a reminder was sent
  Future<PhotoReminderSettings> recordReminderSent({
    required DateTime sentAt,
    required int notificationId,
  }) async {
    return updateSettings(
      (current) => current.copyWith(
        lastReminderSent: sentAt,
        notificationId: notificationId,
      ),
    );
  }

  /// Record that a reminder was opened
  Future<PhotoReminderSettings> recordReminderOpened() async {
    return updateSettings(
      (current) => current.copyWith(
        consecutiveIgnores: 0, // Reset ignore counter
      ),
    );
  }

  /// Record that a reminder was ignored (for anti-spam)
  Future<PhotoReminderSettings> recordReminderIgnored() async {
    final current = getSettings();
    final newIgnoreCount = current.consecutiveIgnores + 1;

    // Check if we should auto-disable
    if (current.maxIgnoresBeforeDisable > 0 &&
        newIgnoreCount >= current.maxIgnoresBeforeDisable) {
      if (kDebugMode) {
        debugPrint(
          '[PhotoReminderRepo] Auto-disabling after $newIgnoreCount ignores',
        );
      }
      return disableReminders(byAntiSpam: true);
    }

    return updateSettings(
      (current) => current.copyWith(consecutiveIgnores: newIgnoreCount),
    );
  }

  /// Get reminder history
  List<PhotoReminderRecord> getHistory() {
    final json = _prefs.getString(_historyKey);
    if (json == null) return [];

    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => PhotoReminderRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PhotoReminderRepo] Error parsing history: $e');
      }
      return [];
    }
  }

  /// Add a record to history
  Future<void> addToHistory(PhotoReminderRecord record) async {
    final history = getHistory();
    history.insert(0, record); // Most recent first

    // Keep only last 50 records
    final trimmed = history.take(50).toList();

    final json = jsonEncode(trimmed.map((r) => r.toJson()).toList());
    await _prefs.setString(_historyKey, json);
  }

  /// Clear all reminder data
  Future<void> clearAll() async {
    await _prefs.remove(_settingsKey);
    await _prefs.remove(_historyKey);

    if (kDebugMode) {
      debugPrint('[PhotoReminderRepo] All reminder data cleared');
    }
  }
}

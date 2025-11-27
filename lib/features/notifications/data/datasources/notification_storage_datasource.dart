/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/notifications/data/datasources
/// Feature: Local Notifications System
/// Type: DataSource - Storage (Hive)
///
/// Persists notification records for anti-spam tracking and analytics.
library;

import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_type.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_record.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_config.dart';

/// DataSource for storing and retrieving notification records using Hive.
class NotificationStorageDatasource {
  static const String _boxName = 'notification_records';
  static const String _statsBoxName = 'notification_stats';

  Box<Map>? _recordsBox;
  Box<Map>? _statsBox;

  /// Initialize the datasource and open Hive boxes
  Future<void> initialize() async {
    _recordsBox = await Hive.openBox<Map>(_boxName);
    _statsBox = await Hive.openBox<Map>(_statsBoxName);
  }

  /// Save a notification record
  Future<void> saveRecord(NotificationRecord record) async {
    final box = _recordsBox;
    if (box == null) return;

    await box.put(record.id, record.toJson());

    // Update stats for this notification type
    await _updateStats(record.type, wasOpened: false);
  }

  /// Mark a notification as opened
  Future<void> markAsOpened(String recordId) async {
    final box = _recordsBox;
    if (box == null) return;

    final recordJson = box.get(recordId);
    if (recordJson == null) return;

    final record = NotificationRecord.fromJson(Map<String, dynamic>.from(recordJson));
    final updatedRecord = record.copyWith(openedAt: DateTime.now());

    await box.put(recordId, updatedRecord.toJson());

    // Update stats - reset consecutive ignores since user opened
    await _updateStats(record.type, wasOpened: true);
  }

  /// Mark a notification as canceled
  Future<void> markAsCanceled(String recordId) async {
    final box = _recordsBox;
    if (box == null) return;

    final recordJson = box.get(recordId);
    if (recordJson == null) return;

    final record = NotificationRecord.fromJson(Map<String, dynamic>.from(recordJson));
    final updatedRecord = record.copyWith(wasCanceled: true);

    await box.put(recordId, updatedRecord.toJson());
  }

  /// Get all records for a notification type
  Future<List<NotificationRecord>> getRecordsByType(NotificationType type) async {
    final box = _recordsBox;
    if (box == null) return [];

    return box.values
        .map((json) => NotificationRecord.fromJson(Map<String, dynamic>.from(json)))
        .where((record) => record.type == type)
        .toList()
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
  }

  /// Get records sent within a time period
  Future<List<NotificationRecord>> getRecordsSince(DateTime since) async {
    final box = _recordsBox;
    if (box == null) return [];

    return box.values
        .map((json) => NotificationRecord.fromJson(Map<String, dynamic>.from(json)))
        .where((record) => record.sentAt.isAfter(since) && !record.wasCanceled)
        .toList()
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
  }

  /// Get the most recent record for a type
  Future<NotificationRecord?> getLastRecordByType(NotificationType type) async {
    final records = await getRecordsByType(type);
    return records.isNotEmpty ? records.first : null;
  }

  /// Get stats for a notification type
  Future<NotificationStats> getStats(NotificationType type) async {
    final box = _statsBox;
    if (box == null) {
      return const NotificationStats(
        totalSent: 0,
        totalOpened: 0,
        consecutiveIgnores: 0,
      );
    }

    final statsJson = box.get(type.name);
    if (statsJson == null) {
      return const NotificationStats(
        totalSent: 0,
        totalOpened: 0,
        consecutiveIgnores: 0,
      );
    }

    return NotificationStats.fromJson(Map<String, dynamic>.from(statsJson));
  }

  /// Check if we can send a notification (respects anti-spam rules)
  Future<bool> canSendNotification(NotificationType type) async {
    // Check 1: Global cooldown (24h between any notifications)
    final recentRecords = await getRecordsSince(
      DateTime.now().subtract(NotificationConfig.globalCooldown),
    );
    if (recentRecords.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('📵 Notification blocked: global cooldown (last sent ${recentRecords.first.sentAt})');
      }
      return false;
    }

    // Check 2: Weekly cap (max 3/week)
    final weekStart = DateTime.now().subtract(const Duration(days: 7));
    final weekRecords = await getRecordsSince(weekStart);
    if (weekRecords.length >= NotificationConfig.maxNotificationsPerWeek) {
      if (kDebugMode) {
        debugPrint('📵 Notification blocked: weekly cap (${weekRecords.length}/${NotificationConfig.maxNotificationsPerWeek})');
      }
      return false;
    }

    // Check 3: Quiet hours
    if (NotificationConfig.isQuietHours(DateTime.now())) {
      if (kDebugMode) {
        debugPrint('📵 Notification blocked: quiet hours');
      }
      return false;
    }

    // Check 4: Stop-after-ignore (too many consecutive ignores for this type)
    final stats = await getStats(type);
    if (stats.shouldStopSending(type.maxIgnoreCount)) {
      if (kDebugMode) {
        debugPrint('📵 Notification blocked: stop-after-ignore (${stats.consecutiveIgnores} ignores for ${type.name})');
      }
      return false;
    }

    return true;
  }

  /// Get the last message key used for a notification type (for rotation)
  Future<String?> getLastMessageKey(NotificationType type) async {
    final stats = await getStats(type);
    return stats.lastMessageKey;
  }

  /// Count notifications sent this week
  Future<int> getWeeklyNotificationCount() async {
    final weekStart = DateTime.now().subtract(const Duration(days: 7));
    final records = await getRecordsSince(weekStart);
    return records.length;
  }

  /// Clean up old records (older than 30 days)
  Future<void> cleanupOldRecords() async {
    final box = _recordsBox;
    if (box == null) return;

    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final keysToDelete = <String>[];

    for (final entry in box.toMap().entries) {
      final record = NotificationRecord.fromJson(Map<String, dynamic>.from(entry.value));
      if (record.sentAt.isBefore(cutoff)) {
        keysToDelete.add(entry.key);
      }
    }

    for (final key in keysToDelete) {
      await box.delete(key);
    }

    if (kDebugMode && keysToDelete.isNotEmpty) {
      debugPrint('🧹 Cleaned up ${keysToDelete.length} old notification records');
    }
  }

  /// Update stats for a notification type
  Future<void> _updateStats(NotificationType type, {required bool wasOpened}) async {
    final box = _statsBox;
    if (box == null) return;

    final currentStats = await getStats(type);

    final updatedStats = NotificationStats(
      totalSent: wasOpened ? currentStats.totalSent : currentStats.totalSent + 1,
      totalOpened: wasOpened ? currentStats.totalOpened + 1 : currentStats.totalOpened,
      consecutiveIgnores: wasOpened ? 0 : currentStats.consecutiveIgnores + 1,
      lastSentAt: wasOpened ? currentStats.lastSentAt : DateTime.now(),
      lastMessageKey: currentStats.lastMessageKey,
    );

    await box.put(type.name, updatedStats.toJson());
  }

  /// Update the last message key used (for rotation tracking)
  Future<void> updateLastMessageKey(NotificationType type, String messageKey) async {
    final box = _statsBox;
    if (box == null) return;

    final currentStats = await getStats(type);
    final updatedStats = NotificationStats(
      totalSent: currentStats.totalSent,
      totalOpened: currentStats.totalOpened,
      consecutiveIgnores: currentStats.consecutiveIgnores,
      lastSentAt: currentStats.lastSentAt,
      lastMessageKey: messageKey,
    );

    await box.put(type.name, updatedStats.toJson());
  }

  /// Reset consecutive ignores for a type (called when user actively uses the app)
  Future<void> resetConsecutiveIgnores(NotificationType type) async {
    final box = _statsBox;
    if (box == null) return;

    final currentStats = await getStats(type);
    if (currentStats.consecutiveIgnores == 0) return;

    final updatedStats = NotificationStats(
      totalSent: currentStats.totalSent,
      totalOpened: currentStats.totalOpened,
      consecutiveIgnores: 0,
      lastSentAt: currentStats.lastSentAt,
      lastMessageKey: currentStats.lastMessageKey,
    );

    await box.put(type.name, updatedStats.toJson());
  }

  /// Close the datasource
  Future<void> close() async {
    await _recordsBox?.close();
    await _statsBox?.close();
  }
}

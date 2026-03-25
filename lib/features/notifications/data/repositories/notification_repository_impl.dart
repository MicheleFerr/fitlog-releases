/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/notifications/data/repositories
/// Feature: Local Notifications System
/// Type: Repository Implementation
///
/// Implements NotificationRepository using local datasources.
library;

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_type.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_record.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/notification_message_pool.dart';
import 'package:gymbro_flutter_new/features/notifications/data/datasources/local_notification_datasource.dart';
import 'package:gymbro_flutter_new/features/notifications/data/datasources/notification_storage_datasource.dart';

/// Implementation of NotificationRepository.
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required LocalNotificationDatasource localNotificationDatasource,
    required NotificationStorageDatasource storageDatasource,
    this.onDeepLinkNavigation,
  }) : _localDatasource = localNotificationDatasource,
       _storageDatasource = storageDatasource;

  final LocalNotificationDatasource _localDatasource;
  final NotificationStorageDatasource _storageDatasource;

  /// Callback invoked when a notification tap requires navigation.
  final void Function(String deepLink)? onDeepLinkNavigation;

  final _uuid = const Uuid();

  // Track notification ID to record ID mapping
  final Map<int, String> _notificationIdToRecordId = {};
  final Map<int, NotificationType> _notificationIdToType = {};

  @override
  Future<void> initialize() async {
    await _storageDatasource.initialize();
    await _localDatasource.initialize(
      onNotificationTap: _handleNotificationTap,
    );
    // Clean up old records on init
    await cleanupOldRecords();
    await _restorePendingMappings();
  }

  @override
  Future<String?> scheduleNotification({
    required NotificationType type,
    required NotificationMessage message,
    required DateTime scheduledTime,
    String? context,
    int? inactivityDay,
    String? deepLinkPath,
  }) async {
    // Check anti-spam rules
    if (!await canSendNotification(type)) {
      return null;
    }

    final recordId = _uuid.v4();
    final notificationId = _localDatasource.generateNotificationId(type);

    // Create and save record
    final record = NotificationRecord(
      id: recordId,
      type: type,
      sentAt: scheduledTime,
      messageKey: message.key,
      context: context,
      inactivityDay: inactivityDay,
    );

    await _localDatasource.scheduleNotification(
      id: notificationId,
      title: message.title,
      body: message.body,
      scheduledTime: scheduledTime,
      type: type,
      payload: _createPayload(recordId, type, deepLinkPath: deepLinkPath),
    );

    try {
      await _storageDatasource.saveRecord(record);
      await _storageDatasource.updateLastMessageKey(type, message.key);
    } catch (_) {
      await _localDatasource.cancelNotification(notificationId);
      rethrow;
    }

    _trackNotification(notificationId, recordId, type);

    if (kDebugMode) {
      debugPrint('✅ Scheduled ${type.name} notification for $scheduledTime');
    }

    return recordId;
  }

  @override
  Future<String?> showNotificationNow({
    required NotificationType type,
    required NotificationMessage message,
    String? context,
    String? deepLinkPath,
  }) async {
    // Check anti-spam rules
    if (!await canSendNotification(type)) {
      return null;
    }

    final recordId = _uuid.v4();
    final notificationId = _localDatasource.generateNotificationId(type);

    // Create and save record
    final record = NotificationRecord(
      id: recordId,
      type: type,
      sentAt: DateTime.now(),
      messageKey: message.key,
      context: context,
    );

    await _localDatasource.showNotification(
      id: notificationId,
      title: message.title,
      body: message.body,
      type: type,
      payload: _createPayload(recordId, type, deepLinkPath: deepLinkPath),
    );

    try {
      await _storageDatasource.saveRecord(record);
      await _storageDatasource.updateLastMessageKey(type, message.key);
    } catch (_) {
      await _localDatasource.cancelNotification(notificationId);
      rethrow;
    }

    _trackNotification(notificationId, recordId, type);

    if (kDebugMode) {
      debugPrint('✅ Showed ${type.name} notification immediately');
    }

    return recordId;
  }

  @override
  Future<void> cancelNotification(String recordId) async {
    // Find notification ID from record ID
    final notificationId = _notificationIdToRecordId.entries
        .firstWhere(
          (e) => e.value == recordId,
          orElse: () => const MapEntry(-1, ''),
        )
        .key;

    if (notificationId != -1) {
      await _localDatasource.cancelNotification(notificationId);
      _untrackNotification(notificationId);
    }

    await _storageDatasource.markAsCanceled(recordId);
  }

  @override
  Future<void> cancelNotificationsByType(NotificationType type) async {
    await _localDatasource.cancelNotificationsByType(type);

    final notificationIds = _notificationIdToType.entries
        .where((entry) => entry.value == type)
        .map((entry) => entry.key)
        .toList(growable: false);

    for (final notificationId in notificationIds) {
      final recordId = _notificationIdToRecordId[notificationId];
      if (recordId != null) {
        await _storageDatasource.markAsCanceled(recordId);
      }
      _untrackNotification(notificationId);
    }
  }

  @override
  Future<void> markNotificationOpened(String recordId) async {
    await _storageDatasource.markAsOpened(recordId);
  }

  @override
  Future<bool> canSendNotification(NotificationType type) async {
    return _storageDatasource.canSendNotification(type);
  }

  @override
  Future<NotificationStats> getNotificationStats(NotificationType type) async {
    return _storageDatasource.getStats(type);
  }

  @override
  Future<String?> getLastMessageKey(NotificationType type) async {
    return _storageDatasource.getLastMessageKey(type);
  }

  @override
  Future<int> getWeeklyNotificationCount() async {
    return _storageDatasource.getWeeklyNotificationCount();
  }

  @override
  Future<void> cleanupOldRecords() async {
    await _storageDatasource.cleanupOldRecords();
  }

  @override
  Future<void> resetIgnoreCount(NotificationType type) async {
    await _storageDatasource.resetConsecutiveIgnores(type);
  }

  @override
  Future<void> close() async {
    await _storageDatasource.close();
  }

  Future<void> _restorePendingMappings() async {
    final pendingNotifications = await _localDatasource
        .getPendingNotifications();

    for (final pendingNotification in pendingNotifications) {
      final parsed = _parsePayload(pendingNotification.payload);
      if (parsed == null) continue;

      final recordId = parsed['recordId'];
      final typeName = parsed['type'];
      if (recordId == null || typeName == null) continue;

      final notificationType = _notificationTypeFromName(typeName);
      if (notificationType == null) continue;

      _trackNotification(pendingNotification.id, recordId, notificationType);
    }
  }

  void _trackNotification(
    int notificationId,
    String recordId,
    NotificationType type,
  ) {
    _notificationIdToRecordId[notificationId] = recordId;
    _notificationIdToType[notificationId] = type;
  }

  void _untrackNotification(int notificationId) {
    _notificationIdToRecordId.remove(notificationId);
    _notificationIdToType.remove(notificationId);
  }

  NotificationType? _notificationTypeFromName(String typeName) {
    for (final type in NotificationType.values) {
      if (type.name == typeName) {
        return type;
      }
    }
    return null;
  }

  /// Create payload string for notification
  String _createPayload(
    String recordId,
    NotificationType type, {
    String? deepLinkPath,
  }) {
    final resolvedDeepLink = deepLinkPath ?? type.deepLinkPath;
    return '${type.name}:$recordId:$resolvedDeepLink';
  }

  /// Parse payload from notification tap
  Map<String, String>? _parsePayload(String? payload) {
    if (payload == null) return null;

    final parts = payload.split(':');
    if (parts.length >= 3) {
      return {
        'type': parts[0],
        'recordId': parts[1],
        'deepLink': parts.sublist(2).join(':'),
      };
    }
    return null;
  }

  /// Handle notification tap — marks as opened and triggers navigation.
  void _handleNotificationTap(String? payload) {
    final parsed = _parsePayload(payload);
    if (parsed == null) return;

    final recordId = parsed['recordId'];
    if (recordId != null) {
      markNotificationOpened(recordId);
    }

    // Navigate to deep link path
    final deepLink = parsed['deepLink'];
    if (deepLink != null && deepLink.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('📲 Notification tapped → navigating to: $deepLink');
      }
      onDeepLinkNavigation?.call(deepLink);
    }
  }
}

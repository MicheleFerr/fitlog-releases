/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: test/features/notifications/data
/// Feature: Local Notifications System
/// Type: Unit Tests - NotificationRepositoryImpl
///
/// Tests all public methods of NotificationRepositoryImpl using manual fakes.
/// No code generation, no Mockito — pure flutter_test.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:gymbro_flutter_new/features/notifications/data/datasources/local_notification_datasource.dart';
import 'package:gymbro_flutter_new/features/notifications/data/datasources/notification_storage_datasource.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_type.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_record.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/notification_message_pool.dart';

// ---------------------------------------------------------------------------
// Fake datasources — manual implementations, no Mockito
// ---------------------------------------------------------------------------

/// Fake [LocalNotificationDatasource] that captures calls without touching
/// the flutter_local_notifications plugin.
class FakeLocalNotificationDatasource extends LocalNotificationDatasource {
  // Captured calls
  bool wasInitialized = false;
  void Function(String?)? capturedTapCallback;

  final List<Map<String, dynamic>> scheduledNotifications = [];
  final List<Map<String, dynamic>> shownNotifications = [];
  final List<int> canceledIds = [];
  final List<NotificationType> canceledByType = [];
  List<PendingLocalNotification> pendingNotifications = const [];

  // Configurable behaviour
  int nextGeneratedId = 1042; // default non-zero value
  bool shouldFailSchedule = false;
  bool shouldFailShow = false;

  @override
  Future<void> initialize({void Function(String?)? onNotificationTap}) async {
    wasInitialized = true;
    capturedTapCallback = onNotificationTap;
  }

  @override
  int generateNotificationId(NotificationType type) => nextGeneratedId;

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required NotificationType type,
    String? payload,
  }) async {
    if (shouldFailSchedule) throw Exception('schedule failed');
    scheduledNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime,
      'type': type,
      'payload': payload,
    });
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required NotificationType type,
    String? payload,
  }) async {
    if (shouldFailShow) throw Exception('show failed');
    shownNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'payload': payload,
    });
  }

  @override
  Future<void> cancelNotification(int id) async {
    canceledIds.add(id);
  }

  @override
  Future<void> cancelNotificationsByType(NotificationType type) async {
    canceledByType.add(type);
  }

  @override
  Future<List<PendingLocalNotification>> getPendingNotifications() async {
    return pendingNotifications;
  }
}

/// Fake [NotificationStorageDatasource] that holds state in memory.
class FakeNotificationStorageDatasource extends NotificationStorageDatasource {
  bool wasInitialized = false;
  bool wasCleanupCalled = false;
  bool wasCloseCalled = false;

  // In-memory stores
  final Map<String, NotificationRecord> _records = {};
  final Map<String, NotificationStats> _stats = {};
  final Map<String, String> _lastMessageKeys = {};

  // Configurable anti-spam responses
  bool canSendResponse = true;
  int weeklyCountResponse = 0;

  // Spy lists
  final List<String> openedRecordIds = [];
  final List<String> canceledRecordIds = [];
  final List<NotificationType> resetIgnoreTypes = [];
  final List<MapEntry<NotificationType, String>> updatedMessageKeys = [];

  @override
  Future<void> initialize() async {
    wasInitialized = true;
  }

  @override
  Future<void> saveRecord(NotificationRecord record) async {
    _records[record.id] = record;
  }

  @override
  Future<void> markAsOpened(String recordId) async {
    openedRecordIds.add(recordId);
    final record = _records[recordId];
    if (record != null) {
      _records[recordId] = record.copyWith(openedAt: DateTime.now());
    }
  }

  @override
  Future<void> markAsCanceled(String recordId) async {
    canceledRecordIds.add(recordId);
    final record = _records[recordId];
    if (record != null) {
      _records[recordId] = record.copyWith(wasCanceled: true);
    }
  }

  @override
  Future<bool> canSendNotification(NotificationType type) async {
    return canSendResponse;
  }

  @override
  Future<NotificationStats> getStats(NotificationType type) async {
    return _stats[type.name] ??
        const NotificationStats(
          totalSent: 0,
          totalOpened: 0,
          consecutiveIgnores: 0,
        );
  }

  /// Helper to seed stats for a type (used in tests).
  void seedStats(NotificationType type, NotificationStats stats) {
    _stats[type.name] = stats;
  }

  @override
  Future<String?> getLastMessageKey(NotificationType type) async {
    return _lastMessageKeys[type.name];
  }

  @override
  Future<void> updateLastMessageKey(
    NotificationType type,
    String messageKey,
  ) async {
    _lastMessageKeys[type.name] = messageKey;
    updatedMessageKeys.add(MapEntry(type, messageKey));
  }

  @override
  Future<int> getWeeklyNotificationCount() async {
    return weeklyCountResponse;
  }

  @override
  Future<void> cleanupOldRecords() async {
    wasCleanupCalled = true;
  }

  @override
  Future<void> resetConsecutiveIgnores(NotificationType type) async {
    resetIgnoreTypes.add(type);
  }

  @override
  Future<void> close() async {
    wasCloseCalled = true;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

NotificationMessage _makeMessage({
  String key = 'test_key',
  String title = 'Test Title',
  String body = 'Test Body',
}) => NotificationMessage(key: key, title: title, body: body);

NotificationRepositoryImpl _makeRepo({
  FakeLocalNotificationDatasource? local,
  FakeNotificationStorageDatasource? storage,
  void Function(String)? onDeepLink,
}) {
  return NotificationRepositoryImpl(
    localNotificationDatasource: local ?? FakeLocalNotificationDatasource(),
    storageDatasource: storage ?? FakeNotificationStorageDatasource(),
    onDeepLinkNavigation: onDeepLink,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // initialize()
  // =========================================================================

  group('initialize', () {
    test('calls initialize on both datasources', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource();
      final repo = _makeRepo(local: local, storage: storage);

      await repo.initialize();

      expect(local.wasInitialized, isTrue);
      expect(storage.wasInitialized, isTrue);
    });

    test('calls cleanupOldRecords during initialization', () async {
      final storage = FakeNotificationStorageDatasource();
      final repo = _makeRepo(storage: storage);

      await repo.initialize();

      expect(storage.wasCleanupCalled, isTrue);
    });

    test('registers tap callback on local datasource', () async {
      final local = FakeLocalNotificationDatasource();
      final repo = _makeRepo(local: local);

      await repo.initialize();

      expect(local.capturedTapCallback, isNotNull);
    });

    test('rehydrates pending notification mappings from payloads', () async {
      final local = FakeLocalNotificationDatasource()
        ..pendingNotifications = const [
          PendingLocalNotification(id: 2007, payload: 'inactivity:rec-123:/'),
        ];
      final storage = FakeNotificationStorageDatasource();
      final repo = _makeRepo(local: local, storage: storage);

      await repo.initialize();
      await repo.cancelNotification('rec-123');

      expect(local.canceledIds, contains(2007));
      expect(storage.canceledRecordIds, contains('rec-123'));
    });
  });

  // =========================================================================
  // scheduleNotification()
  // =========================================================================

  group('scheduleNotification', () {
    test('returns record ID when anti-spam allows', () async {
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(storage: storage);

      final recordId = await repo.scheduleNotification(
        type: NotificationType.insightPr,
        message: _makeMessage(),
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(recordId, isNotNull);
      expect(recordId, isA<String>());
    });

    test('returns null when anti-spam blocks notification', () async {
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = false;
      final repo = _makeRepo(storage: storage);

      final recordId = await repo.scheduleNotification(
        type: NotificationType.insightPr,
        message: _makeMessage(),
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(recordId, isNull);
    });

    test('saves record to storage datasource', () async {
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(storage: storage);

      await repo.scheduleNotification(
        type: NotificationType.workoutForgotten,
        message: _makeMessage(key: 'wf_key'),
        scheduledTime: DateTime.now().add(const Duration(minutes: 30)),
      );

      expect(storage._records, isNotEmpty);
      final savedRecord = storage._records.values.first;
      expect(savedRecord.type, equals(NotificationType.workoutForgotten));
      expect(savedRecord.messageKey, equals('wf_key'));
    });

    test('passes correct message title and body to local datasource', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(local: local, storage: storage);

      await repo.scheduleNotification(
        type: NotificationType.insightStreak,
        message: _makeMessage(title: 'Streak!', body: '7 days strong'),
        scheduledTime: DateTime.now().add(const Duration(hours: 2)),
      );

      expect(local.scheduledNotifications, hasLength(1));
      expect(local.scheduledNotifications.first['title'], equals('Streak!'));
      expect(
        local.scheduledNotifications.first['body'],
        equals('7 days strong'),
      );
    });

    test('stores inactivity day in record', () async {
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(storage: storage);

      await repo.scheduleNotification(
        type: NotificationType.inactivity,
        message: _makeMessage(),
        scheduledTime: DateTime.now().add(const Duration(days: 3)),
        inactivityDay: 3,
      );

      final savedRecord = storage._records.values.first;
      expect(savedRecord.inactivityDay, equals(3));
    });

    test('stores optional context in record', () async {
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(storage: storage);

      await repo.scheduleNotification(
        type: NotificationType.insightPr,
        message: _makeMessage(),
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
        context: 'Bench Press',
      );

      final savedRecord = storage._records.values.first;
      expect(savedRecord.context, equals('Bench Press'));
    });

    test('updates last message key in storage', () async {
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(storage: storage);

      await repo.scheduleNotification(
        type: NotificationType.insightVolume,
        message: _makeMessage(key: 'vol_msg_2'),
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(storage.updatedMessageKeys, hasLength(1));
      expect(
        storage.updatedMessageKeys.first.key,
        NotificationType.insightVolume,
      );
      expect(storage.updatedMessageKeys.first.value, equals('vol_msg_2'));
    });

    test('does not call local datasource when anti-spam blocks', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = false;
      final repo = _makeRepo(local: local, storage: storage);

      await repo.scheduleNotification(
        type: NotificationType.insightPr,
        message: _makeMessage(),
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(local.scheduledNotifications, isEmpty);
    });

    test('tracks notification ID to record ID mapping', () async {
      final local = FakeLocalNotificationDatasource()..nextGeneratedId = 3042;
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(local: local, storage: storage);

      final recordId = await repo.scheduleNotification(
        type: NotificationType.insightPr,
        message: _makeMessage(),
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      );

      // Cancel by record ID — should find mapping and cancel via local datasource
      await repo.cancelNotification(recordId!);
      expect(local.canceledIds, contains(3042));
    });

    test('does not save record when local scheduling fails', () async {
      final local = FakeLocalNotificationDatasource()
        ..shouldFailSchedule = true;
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(local: local, storage: storage);

      await expectLater(
        repo.scheduleNotification(
          type: NotificationType.insightPr,
          message: _makeMessage(),
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
        ),
        throwsException,
      );

      expect(storage._records, isEmpty);
      expect(storage.updatedMessageKeys, isEmpty);
    });
  });

  // =========================================================================
  // showNotificationNow()
  // =========================================================================

  group('showNotificationNow', () {
    test('returns record ID when anti-spam allows', () async {
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(storage: storage);

      final recordId = await repo.showNotificationNow(
        type: NotificationType.insightPr,
        message: _makeMessage(),
      );

      expect(recordId, isNotNull);
    });

    test('returns null when anti-spam blocks', () async {
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = false;
      final repo = _makeRepo(storage: storage);

      final recordId = await repo.showNotificationNow(
        type: NotificationType.insightPr,
        message: _makeMessage(),
      );

      expect(recordId, isNull);
    });

    test('calls showNotification on local datasource', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(local: local, storage: storage);

      await repo.showNotificationNow(
        type: NotificationType.workoutForgotten,
        message: _makeMessage(title: 'Workout!', body: 'Still going?'),
      );

      expect(local.shownNotifications, hasLength(1));
      expect(local.shownNotifications.first['title'], equals('Workout!'));
      expect(local.shownNotifications.first['body'], equals('Still going?'));
    });

    test('saves record with correct type to storage', () async {
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(storage: storage);

      await repo.showNotificationNow(
        type: NotificationType.insightStreak,
        message: _makeMessage(key: 'streak_7'),
      );

      expect(storage._records, isNotEmpty);
      expect(
        storage._records.values.first.type,
        equals(NotificationType.insightStreak),
      );
      expect(storage._records.values.first.messageKey, equals('streak_7'));
    });

    test('record has no inactivityDay when not provided', () async {
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(storage: storage);

      await repo.showNotificationNow(
        type: NotificationType.insightPr,
        message: _makeMessage(),
      );

      expect(storage._records.values.first.inactivityDay, isNull);
    });

    test('does not call show when blocked', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = false;
      final repo = _makeRepo(local: local, storage: storage);

      await repo.showNotificationNow(
        type: NotificationType.insightPr,
        message: _makeMessage(),
      );

      expect(local.shownNotifications, isEmpty);
    });

    test('does not save record when local show fails', () async {
      final local = FakeLocalNotificationDatasource()..shouldFailShow = true;
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(local: local, storage: storage);

      await expectLater(
        repo.showNotificationNow(
          type: NotificationType.insightPr,
          message: _makeMessage(),
        ),
        throwsException,
      );

      expect(storage._records, isEmpty);
      expect(storage.updatedMessageKeys, isEmpty);
    });
  });

  // =========================================================================
  // cancelNotification()
  // =========================================================================

  group('cancelNotification', () {
    test('cancels local notification via mapped ID', () async {
      final local = FakeLocalNotificationDatasource()..nextGeneratedId = 4055;
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(local: local, storage: storage);

      final recordId = await repo.showNotificationNow(
        type: NotificationType.insightStreak,
        message: _makeMessage(),
      );

      await repo.cancelNotification(recordId!);

      expect(local.canceledIds, contains(4055));
    });

    test('marks record as canceled in storage', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(local: local, storage: storage);

      final recordId = await repo.showNotificationNow(
        type: NotificationType.insightPr,
        message: _makeMessage(),
      );

      await repo.cancelNotification(recordId!);

      expect(storage.canceledRecordIds, contains(recordId));
    });

    test('does not crash when record ID is unknown', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource();
      final repo = _makeRepo(local: local, storage: storage);

      // Should complete without exception
      await expectLater(
        repo.cancelNotification('nonexistent-record-id'),
        completes,
      );
    });

    test('does not call local cancel when mapping is missing', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource();
      final repo = _makeRepo(local: local, storage: storage);

      await repo.cancelNotification('unknown-id');

      // No notification ID found, so local cancel is not called
      expect(local.canceledIds, isEmpty);
      // But storage cancel is always called
      expect(storage.canceledRecordIds, contains('unknown-id'));
    });

    test('removes mapping after cancellation', () async {
      final local = FakeLocalNotificationDatasource()..nextGeneratedId = 5010;
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(local: local, storage: storage);

      final recordId = await repo.showNotificationNow(
        type: NotificationType.insightVolume,
        message: _makeMessage(),
      );

      await repo.cancelNotification(recordId!);

      // Second cancel should NOT find the mapping again
      local.canceledIds.clear();
      await repo.cancelNotification(recordId);
      expect(local.canceledIds, isEmpty);
    });
  });

  // =========================================================================
  // cancelNotificationsByType()
  // =========================================================================

  group('cancelNotificationsByType', () {
    test('delegates to local datasource with correct type', () async {
      final local = FakeLocalNotificationDatasource();
      final repo = _makeRepo(local: local);

      await repo.cancelNotificationsByType(NotificationType.inactivity);

      expect(local.canceledByType, contains(NotificationType.inactivity));
    });

    test('marks tracked records as canceled in storage', () async {
      final local = FakeLocalNotificationDatasource()..nextGeneratedId = 2010;
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(local: local, storage: storage);

      final recordId = await repo.scheduleNotification(
        type: NotificationType.inactivity,
        message: _makeMessage(),
        scheduledTime: DateTime.now().add(const Duration(days: 1)),
      );

      await repo.cancelNotificationsByType(NotificationType.inactivity);

      expect(storage.canceledRecordIds, contains(recordId));
    });

    test('removes in-memory mappings in the correct ID range', () async {
      final local = FakeLocalNotificationDatasource()
        ..nextGeneratedId = 2010; // inactivity range 2000-2099
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(local: local, storage: storage);

      // Schedule a notification — maps notificationId 2010 -> some recordId
      await repo.scheduleNotification(
        type: NotificationType.inactivity,
        message: _makeMessage(),
        scheduledTime: DateTime.now().add(const Duration(days: 3)),
      );

      // Now cancel all inactivity notifications
      await repo.cancelNotificationsByType(NotificationType.inactivity);

      // After cancellation, canceling by recordId should NOT call local cancel again
      final recordId = storage._records.values.first.id;
      local.canceledIds.clear();
      await repo.cancelNotification(recordId);
      expect(local.canceledIds, isEmpty);
    });

    test('does not remove mappings outside target type range', () async {
      final local = FakeLocalNotificationDatasource()
        ..nextGeneratedId = 3015; // insightPr range 3000-3099
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(local: local, storage: storage);

      await repo.showNotificationNow(
        type: NotificationType.insightPr,
        message: _makeMessage(),
      );

      // Cancel inactivity (different range) — should not affect insightPr mapping
      await repo.cancelNotificationsByType(NotificationType.inactivity);

      final recordId = storage._records.values.first.id;
      local.canceledIds.clear();
      await repo.cancelNotification(recordId);
      // The mapping for insightPr (3015) should still be there
      expect(local.canceledIds, contains(3015));
    });
  });

  // =========================================================================
  // markNotificationOpened()
  // =========================================================================

  group('markNotificationOpened', () {
    test('delegates to storage datasource', () async {
      final storage = FakeNotificationStorageDatasource();
      final repo = _makeRepo(storage: storage);

      await repo.markNotificationOpened('rec-abc-123');

      expect(storage.openedRecordIds, contains('rec-abc-123'));
    });

    test('marks correct record when multiple records exist', () async {
      final storage = FakeNotificationStorageDatasource();
      final repo = _makeRepo(storage: storage);

      await repo.markNotificationOpened('rec-1');
      await repo.markNotificationOpened('rec-2');

      expect(storage.openedRecordIds, containsAll(['rec-1', 'rec-2']));
    });
  });

  // =========================================================================
  // canSendNotification()
  // =========================================================================

  group('canSendNotification', () {
    test('returns true when storage allows', () async {
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(storage: storage);

      final result = await repo.canSendNotification(NotificationType.insightPr);

      expect(result, isTrue);
    });

    test('returns false when storage blocks', () async {
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = false;
      final repo = _makeRepo(storage: storage);

      final result = await repo.canSendNotification(
        NotificationType.inactivity,
      );

      expect(result, isFalse);
    });
  });

  // =========================================================================
  // getNotificationStats()
  // =========================================================================

  group('getNotificationStats', () {
    test('returns stats from storage datasource', () async {
      final storage = FakeNotificationStorageDatasource();
      const expectedStats = NotificationStats(
        totalSent: 5,
        totalOpened: 3,
        consecutiveIgnores: 1,
      );
      storage.seedStats(NotificationType.insightPr, expectedStats);
      final repo = _makeRepo(storage: storage);

      final stats = await repo.getNotificationStats(NotificationType.insightPr);

      expect(stats.totalSent, equals(5));
      expect(stats.totalOpened, equals(3));
      expect(stats.consecutiveIgnores, equals(1));
    });

    test('returns zero stats for unknown type', () async {
      final storage = FakeNotificationStorageDatasource();
      final repo = _makeRepo(storage: storage);

      final stats = await repo.getNotificationStats(
        NotificationType.insightVolume,
      );

      expect(stats.totalSent, equals(0));
      expect(stats.totalOpened, equals(0));
      expect(stats.consecutiveIgnores, equals(0));
    });

    test('open rate computed correctly', () async {
      final storage = FakeNotificationStorageDatasource();
      storage.seedStats(
        NotificationType.insightStreak,
        const NotificationStats(
          totalSent: 10,
          totalOpened: 4,
          consecutiveIgnores: 0,
        ),
      );
      final repo = _makeRepo(storage: storage);

      final stats = await repo.getNotificationStats(
        NotificationType.insightStreak,
      );

      expect(stats.openRate, closeTo(0.4, 0.001));
    });
  });

  // =========================================================================
  // getWeeklyNotificationCount()
  // =========================================================================

  group('getWeeklyNotificationCount', () {
    test('returns count from storage datasource', () async {
      final storage = FakeNotificationStorageDatasource()
        ..weeklyCountResponse = 2;
      final repo = _makeRepo(storage: storage);

      final count = await repo.getWeeklyNotificationCount();

      expect(count, equals(2));
    });

    test('returns zero when no notifications this week', () async {
      final storage = FakeNotificationStorageDatasource()
        ..weeklyCountResponse = 0;
      final repo = _makeRepo(storage: storage);

      final count = await repo.getWeeklyNotificationCount();

      expect(count, equals(0));
    });
  });

  // =========================================================================
  // cleanupOldRecords()
  // =========================================================================

  group('cleanupOldRecords', () {
    test('delegates to storage datasource', () async {
      final storage = FakeNotificationStorageDatasource();
      final repo = _makeRepo(storage: storage);

      await repo.cleanupOldRecords();

      expect(storage.wasCleanupCalled, isTrue);
    });
  });

  // =========================================================================
  // resetIgnoreCount()
  // =========================================================================

  group('resetIgnoreCount', () {
    test('calls resetConsecutiveIgnores on storage', () async {
      final storage = FakeNotificationStorageDatasource();
      final repo = _makeRepo(storage: storage);

      await repo.resetIgnoreCount(NotificationType.inactivity);

      expect(storage.resetIgnoreTypes, contains(NotificationType.inactivity));
    });

    test('passes correct type for each notification type', () async {
      final storage = FakeNotificationStorageDatasource();
      final repo = _makeRepo(storage: storage);

      for (final type in NotificationType.values) {
        await repo.resetIgnoreCount(type);
      }

      expect(storage.resetIgnoreTypes, containsAll(NotificationType.values));
    });
  });

  // =========================================================================
  // close()
  // =========================================================================

  group('close', () {
    test('closes storage datasource', () async {
      final storage = FakeNotificationStorageDatasource();
      final repo = _makeRepo(storage: storage);

      await repo.close();

      expect(storage.wasCloseCalled, isTrue);
    });
  });

  // =========================================================================
  // Notification ID mapping
  // =========================================================================

  group('notification ID mapping', () {
    test('each schedule call gets a unique generated ID', () async {
      // Two separate repo instances with different fake ID generators.
      final local1 = FakeLocalNotificationDatasource()..nextGeneratedId = 1011;
      final local2 = FakeLocalNotificationDatasource()..nextGeneratedId = 1022;

      final storage1 = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo1 = _makeRepo(local: local1, storage: storage1);
      await repo1.showNotificationNow(
        type: NotificationType.workoutForgotten,
        message: _makeMessage(key: 'msg_a'),
      );

      final storage2 = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo2 = _makeRepo(local: local2, storage: storage2);
      await repo2.showNotificationNow(
        type: NotificationType.workoutForgotten,
        message: _makeMessage(key: 'msg_b'),
      );

      expect(local1.shownNotifications.first['id'], equals(1011));
      expect(local2.shownNotifications.first['id'], equals(1022));
    });

    test('ID range start is 1000 for workoutForgotten', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(local: local, storage: storage);

      // Use an ID in the workoutForgotten range (1000-1099)
      local.nextGeneratedId = 1050;

      await repo.showNotificationNow(
        type: NotificationType.workoutForgotten,
        message: _makeMessage(),
      );

      // When we cancel all by type, IDs 1000-1099 should be removed
      await repo.cancelNotificationsByType(NotificationType.workoutForgotten);

      final recordId = storage._records.values.first.id;
      local.canceledIds.clear();
      await repo.cancelNotification(recordId);
      // Mapping should be gone
      expect(local.canceledIds, isEmpty);
    });

    test('ID ranges do not overlap between types', () {
      // Verify the expected ranges are distinct (static knowledge test)
      const ranges = {
        'workoutForgotten': (1000, 1099),
        'inactivity': (2000, 2099),
        'insightPr': (3000, 3099),
        'insightStreak': (4000, 4099),
        'insightVolume': (5000, 5099),
      };

      final allIds = <int>{};
      for (final range in ranges.values) {
        for (var id = range.$1; id <= range.$2; id++) {
          expect(
            allIds.contains(id),
            isFalse,
            reason: 'ID $id is in multiple ranges',
          );
          allIds.add(id);
        }
      }
      expect(allIds.length, equals(5 * 100));
    });
  });

  // =========================================================================
  // Payload creation and deep-link parsing
  // =========================================================================

  group('payload creation and deep-link parsing', () {
    test('payload format is type:recordId:deepLinkPath', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(local: local, storage: storage);

      await repo.showNotificationNow(
        type: NotificationType.insightPr,
        message: _makeMessage(),
      );

      final payload = local.shownNotifications.first['payload'] as String?;
      expect(payload, isNotNull);

      final parts = payload!.split(':');
      expect(parts.length, greaterThanOrEqualTo(3));
      expect(parts[0], equals('insightPr'));
      // parts[1] is the UUID recordId
      expect(parts[1], isNotEmpty);
      // parts[2] onward is the deep link path
      final deepLink = parts.sublist(2).join(':');
      expect(deepLink, equals('/stats'));
    });

    test('custom deepLinkPath overrides the type default', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(local: local, storage: storage);

      await repo.scheduleNotification(
        type: NotificationType.insightPr,
        message: _makeMessage(),
        scheduledTime: DateTime.now().add(const Duration(minutes: 15)),
        deepLinkPath:
            '/stats/analytics/exercise/Bench%20Press?source=notification',
      );

      final payload = local.scheduledNotifications.first['payload'] as String;
      final deepLink = payload.split(':').sublist(2).join(':');
      expect(
        deepLink,
        equals('/stats/analytics/exercise/Bench%20Press?source=notification'),
      );
    });

    test('workoutForgotten payload carries /workout deep link', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(local: local, storage: storage);

      await repo.showNotificationNow(
        type: NotificationType.workoutForgotten,
        message: _makeMessage(),
      );

      final payload = local.shownNotifications.first['payload'] as String;
      final deepLink = payload.split(':').sublist(2).join(':');
      expect(deepLink, equals('/workout'));
    });

    test('inactivity payload carries / deep link', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(local: local, storage: storage);

      await repo.scheduleNotification(
        type: NotificationType.inactivity,
        message: _makeMessage(),
        scheduledTime: DateTime.now().add(const Duration(days: 3)),
      );

      final payload = local.scheduledNotifications.first['payload'] as String;
      final deepLink = payload.split(':').sublist(2).join(':');
      expect(deepLink, equals('/'));
    });

    test(
      'notification tap with valid payload calls onDeepLinkNavigation',
      () async {
        final local = FakeLocalNotificationDatasource();
        final storage = FakeNotificationStorageDatasource()
          ..canSendResponse = true;

        String? navigatedTo;
        final repo = _makeRepo(
          local: local,
          storage: storage,
          onDeepLink: (link) => navigatedTo = link,
        );

        await repo.initialize();
        await repo.showNotificationNow(
          type: NotificationType.insightPr,
          message: _makeMessage(),
        );

        final payload = local.shownNotifications.first['payload'] as String;

        // Simulate tap by invoking the captured callback
        local.capturedTapCallback!(payload);

        expect(navigatedTo, equals('/stats'));
      },
    );

    test('notification tap marks record as opened', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final repo = _makeRepo(local: local, storage: storage);

      await repo.initialize();
      final recordId = await repo.showNotificationNow(
        type: NotificationType.insightPr,
        message: _makeMessage(),
      );

      final payload = local.shownNotifications.first['payload'] as String;
      local.capturedTapCallback!(payload);

      // Allow markNotificationOpened (async) to complete
      await Future<void>.delayed(Duration.zero);

      expect(storage.openedRecordIds, contains(recordId));
    });

    test('notification tap with null payload does not navigate', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource();

      String? navigatedTo;
      final repo = _makeRepo(
        local: local,
        storage: storage,
        onDeepLink: (link) => navigatedTo = link,
      );

      await repo.initialize();
      local.capturedTapCallback!(null);

      expect(navigatedTo, isNull);
    });

    test('notification tap with malformed payload does not navigate', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource();

      String? navigatedTo;
      final repo = _makeRepo(
        local: local,
        storage: storage,
        onDeepLink: (link) => navigatedTo = link,
      );

      await repo.initialize();
      // Only 2 parts — minimum is 3
      local.capturedTapCallback!('workoutForgotten:some-record-id');

      expect(navigatedTo, isNull);
    });

    test('payload with colon in deep link path is handled correctly', () async {
      // The _parsePayload uses sublist(2).join(':') so colons in the path
      // are preserved. This test verifies the join behaviour.
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;

      String? navigatedTo;
      final repo = _makeRepo(
        local: local,
        storage: storage,
        onDeepLink: (link) => navigatedTo = link,
      );

      await repo.initialize();

      // Manually craft a payload with colon in deep link (edge case)
      const fakePayload = 'insightPr:record-id:/stats:extra';
      local.capturedTapCallback!(fakePayload);

      await Future<void>.delayed(Duration.zero);

      // deepLink = parts.sublist(2).join(':') = '/stats:extra'
      expect(navigatedTo, equals('/stats:extra'));
    });
  });

  // =========================================================================
  // Anti-spam rules (via canSendNotification delegation)
  // =========================================================================

  group('anti-spam integration', () {
    test('scheduleNotification respects canSend=false from storage', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = false;
      final repo = _makeRepo(local: local, storage: storage);

      final result = await repo.scheduleNotification(
        type: NotificationType.insightStreak,
        message: _makeMessage(),
        scheduledTime: DateTime.now().add(const Duration(hours: 9)),
      );

      expect(result, isNull);
      expect(local.scheduledNotifications, isEmpty);
      // No record should be saved when blocked
      expect(storage._records, isEmpty);
    });

    test('showNotificationNow respects canSend=false from storage', () async {
      final local = FakeLocalNotificationDatasource();
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = false;
      final repo = _makeRepo(local: local, storage: storage);

      final result = await repo.showNotificationNow(
        type: NotificationType.insightVolume,
        message: _makeMessage(),
      );

      expect(result, isNull);
      expect(local.shownNotifications, isEmpty);
      expect(storage._records, isEmpty);
    });

    test('shouldStopSending logic respected via stats', () async {
      // When consecutiveIgnores >= maxIgnoreCount, storage returns canSend=false
      // This test verifies the repository correctly uses the storage answer.
      final storage = FakeNotificationStorageDatasource();
      storage.seedStats(
        NotificationType.inactivity,
        const NotificationStats(
          totalSent: 3,
          totalOpened: 0,
          consecutiveIgnores: 3, // equals maxIgnoreCount for inactivity
        ),
      );
      storage.canSendResponse = false; // simulates the storage check result

      final local = FakeLocalNotificationDatasource();
      final repo = _makeRepo(local: local, storage: storage);

      final result = await repo.showNotificationNow(
        type: NotificationType.inactivity,
        message: _makeMessage(),
      );

      expect(result, isNull);
      expect(local.shownNotifications, isEmpty);
    });

    test('can send when canSendResponse is true after reset', () async {
      final storage = FakeNotificationStorageDatasource()
        ..canSendResponse = true;
      final local = FakeLocalNotificationDatasource();
      final repo = _makeRepo(local: local, storage: storage);

      await repo.resetIgnoreCount(NotificationType.inactivity);

      final result = await repo.showNotificationNow(
        type: NotificationType.inactivity,
        message: _makeMessage(),
      );

      expect(result, isNotNull);
      expect(local.shownNotifications, hasLength(1));
    });
  });

  // =========================================================================
  // NotificationStats entity — unit tests
  // =========================================================================

  group('NotificationStats', () {
    test('openRate is 0 when totalSent is 0', () {
      const stats = NotificationStats(
        totalSent: 0,
        totalOpened: 0,
        consecutiveIgnores: 0,
      );
      expect(stats.openRate, equals(0.0));
    });

    test('openRate calculates correctly', () {
      const stats = NotificationStats(
        totalSent: 8,
        totalOpened: 2,
        consecutiveIgnores: 0,
      );
      expect(stats.openRate, closeTo(0.25, 0.001));
    });

    test('shouldStopSending is false when below max', () {
      const stats = NotificationStats(
        totalSent: 5,
        totalOpened: 0,
        consecutiveIgnores: 2,
      );
      expect(stats.shouldStopSending(3), isFalse);
    });

    test('shouldStopSending is true when equal to max', () {
      const stats = NotificationStats(
        totalSent: 5,
        totalOpened: 0,
        consecutiveIgnores: 3,
      );
      expect(stats.shouldStopSending(3), isTrue);
    });

    test('shouldStopSending is true when above max', () {
      const stats = NotificationStats(
        totalSent: 10,
        totalOpened: 0,
        consecutiveIgnores: 5,
      );
      expect(stats.shouldStopSending(3), isTrue);
    });
  });

  // =========================================================================
  // NotificationRecord entity — unit tests
  // =========================================================================

  group('NotificationRecord', () {
    test('wasOpened returns false when openedAt is null', () {
      final record = NotificationRecord(
        id: 'r1',
        type: NotificationType.insightPr,
        sentAt: DateTime(2026, 1, 1),
        messageKey: 'key_1',
      );
      expect(record.wasOpened, isFalse);
    });

    test('wasOpened returns true when openedAt is set', () {
      final record = NotificationRecord(
        id: 'r2',
        type: NotificationType.insightPr,
        sentAt: DateTime(2026, 1, 1),
        messageKey: 'key_1',
        openedAt: DateTime(2026, 1, 1, 10),
      );
      expect(record.wasOpened, isTrue);
    });

    test('wasIgnored is true when not canceled and not opened', () {
      final record = NotificationRecord(
        id: 'r3',
        type: NotificationType.inactivity,
        sentAt: DateTime(2026, 1, 1),
        messageKey: 'key_2',
      );
      expect(record.wasIgnored, isTrue);
    });

    test('wasIgnored is false when record was canceled', () {
      final record = NotificationRecord(
        id: 'r4',
        type: NotificationType.inactivity,
        sentAt: DateTime(2026, 1, 1),
        messageKey: 'key_2',
        wasCanceled: true,
      );
      expect(record.wasIgnored, isFalse);
    });

    test('wasIgnored is false when record was opened', () {
      final record = NotificationRecord(
        id: 'r5',
        type: NotificationType.inactivity,
        sentAt: DateTime(2026, 1, 1),
        messageKey: 'key_2',
        openedAt: DateTime(2026, 1, 1, 12),
      );
      expect(record.wasIgnored, isFalse);
    });
  });
}

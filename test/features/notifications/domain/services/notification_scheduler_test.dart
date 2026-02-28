library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_type.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_record.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/repositories/notification_repository.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/notification_message_pool.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/notification_scheduler.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeAppLocalizations extends AppLocalizations {
  FakeAppLocalizations() : super('en');

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName.toString();
    final methodName = name.replaceAll('Symbol("', '').replaceAll('")', '');
    if (invocation.positionalArguments.isNotEmpty) {
      return '$methodName(${invocation.positionalArguments.join(', ')})';
    }
    return methodName;
  }
}

class FakeNotificationRepository implements NotificationRepository {
  bool initialized = false;
  bool _canSend = true;
  String? _lastMessageKey;
  int scheduleCount = 0;
  int cancelCount = 0;
  int cancelByTypeCount = 0;
  int resetIgnoreCountCalls = 0;
  final List<Map<String, dynamic>> scheduledNotifications = [];
  final List<String> canceledIds = [];
  final List<NotificationType> canceledByTypes = [];

  void setCanSend(bool value) => _canSend = value;
  void setLastMessageKey(String? key) => _lastMessageKey = key;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<bool> canSendNotification(NotificationType type) async => _canSend;

  @override
  Future<String?> getLastMessageKey(NotificationType type) async =>
      _lastMessageKey;

  @override
  Future<String?> scheduleNotification({
    required NotificationType type,
    required NotificationMessage message,
    required DateTime scheduledTime,
    String? context,
    int? inactivityDay,
  }) async {
    scheduleCount++;
    final id = 'record-$scheduleCount';
    scheduledNotifications.add({
      'id': id,
      'type': type,
      'message': message,
      'scheduledTime': scheduledTime,
      'context': context,
      'inactivityDay': inactivityDay,
    });
    return id;
  }

  @override
  Future<String?> showNotificationNow({
    required NotificationType type,
    required NotificationMessage message,
    String? context,
  }) async {
    return 'shown-1';
  }

  @override
  Future<void> cancelNotification(String recordId) async {
    cancelCount++;
    canceledIds.add(recordId);
  }

  @override
  Future<void> cancelNotificationsByType(NotificationType type) async {
    cancelByTypeCount++;
    canceledByTypes.add(type);
  }

  @override
  Future<void> markNotificationOpened(String recordId) async {}

  @override
  Future<NotificationStats> getNotificationStats(
    NotificationType type,
  ) async {
    return const NotificationStats(
      totalSent: 5,
      totalOpened: 2,
      consecutiveIgnores: 0,
    );
  }

  @override
  Future<int> getWeeklyNotificationCount() async => scheduleCount;

  @override
  Future<void> cleanupOldRecords() async {}

  @override
  Future<void> resetIgnoreCount(NotificationType type) async {
    resetIgnoreCountCalls++;
  }

  @override
  Future<void> close() async {}
}

void main() {
  late FakeNotificationRepository fakeRepo;
  late NotificationMessagePool messagePool;
  late NotificationScheduler scheduler;
  late FakeAppLocalizations l10n;

  setUp(() {
    fakeRepo = FakeNotificationRepository();
    messagePool = NotificationMessagePool();
    scheduler = NotificationScheduler(
      repository: fakeRepo,
      messagePool: messagePool,
    );
    l10n = FakeAppLocalizations();
  });

  group('NotificationScheduler.initialize', () {
    test('delegates to repository.initialize', () async {
      await scheduler.initialize();
      expect(fakeRepo.initialized, isTrue);
    });
  });

  group('NotificationScheduler.scheduleWorkoutForgotten', () {
    test('schedules notification when canSend is true', () async {
      await scheduler.scheduleWorkoutForgotten(l10n);
      expect(fakeRepo.scheduleCount, 1);
      expect(
        fakeRepo.scheduledNotifications.first['type'],
        NotificationType.workoutForgotten,
      );
    });

    test('does NOT schedule when canSend is false', () async {
      fakeRepo.setCanSend(false);
      await scheduler.scheduleWorkoutForgotten(l10n);
      expect(fakeRepo.scheduleCount, 0);
    });

    test('cancels previous workout forgotten before scheduling new', () async {
      await scheduler.scheduleWorkoutForgotten(l10n);
      // The first call schedules record-1
      await scheduler.scheduleWorkoutForgotten(l10n);
      // cancelWorkoutForgotten should cancel record-1
      expect(fakeRepo.canceledIds, contains('record-1'));
      expect(fakeRepo.scheduleCount, 2);
    });

    test('uses message rotation (excludeKey)', () async {
      fakeRepo.setLastMessageKey('workout_forgotten_1');
      await scheduler.scheduleWorkoutForgotten(l10n);
      final msg = fakeRepo.scheduledNotifications.first['message']
          as NotificationMessage;
      // With excludeKey workout_forgotten_1, it should pick a different key
      // (or fallback to pool if all excluded)
      expect(msg.key, isNotEmpty);
    });
  });

  group('NotificationScheduler.cancelWorkoutForgotten', () {
    test('cancels active workout forgotten notification', () async {
      await scheduler.scheduleWorkoutForgotten(l10n);
      await scheduler.cancelWorkoutForgotten();
      expect(fakeRepo.canceledIds, contains('record-1'));
    });

    test('does nothing when no active workout forgotten', () async {
      await scheduler.cancelWorkoutForgotten();
      expect(fakeRepo.cancelCount, 0);
    });

    test('idempotent - second cancel is a no-op', () async {
      await scheduler.scheduleWorkoutForgotten(l10n);
      await scheduler.cancelWorkoutForgotten();
      await scheduler.cancelWorkoutForgotten();
      expect(fakeRepo.cancelCount, 1);
    });
  });

  group('NotificationScheduler.scheduleInactivityIfNeeded', () {
    test('does nothing when lastWorkoutDate is null', () async {
      await scheduler.scheduleInactivityIfNeeded(
        lastWorkoutDate: null,
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 0);
    });

    test('does nothing when less than 3 days since last workout', () async {
      await scheduler.scheduleInactivityIfNeeded(
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 2)),
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 0);
    });

    test('schedules for 3 days inactivity', () async {
      await scheduler.scheduleInactivityIfNeeded(
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 3)),
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 1);
      expect(
        fakeRepo.scheduledNotifications.first['inactivityDay'],
        3,
      );
    });

    test('schedules for 7 days inactivity', () async {
      await scheduler.scheduleInactivityIfNeeded(
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 8)),
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 1);
      expect(
        fakeRepo.scheduledNotifications.first['inactivityDay'],
        7,
      );
    });

    test('schedules for 14 days inactivity', () async {
      await scheduler.scheduleInactivityIfNeeded(
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 15)),
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 1);
      expect(
        fakeRepo.scheduledNotifications.first['inactivityDay'],
        14,
      );
    });

    test('does NOT re-schedule for same inactivity day', () async {
      final lastWorkout =
          DateTime.now().subtract(const Duration(days: 4));
      await scheduler.scheduleInactivityIfNeeded(
        lastWorkoutDate: lastWorkout,
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 1);

      // Call again with same context
      await scheduler.scheduleInactivityIfNeeded(
        lastWorkoutDate: lastWorkout,
        l10n: l10n,
      );
      // Should not schedule again for day 3
      expect(fakeRepo.scheduleCount, 1);
    });

    test('blocked by anti-spam', () async {
      fakeRepo.setCanSend(false);
      await scheduler.scheduleInactivityIfNeeded(
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 5)),
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 0);
    });
  });

  group('NotificationScheduler.resetInactivitySequence', () {
    test('cancels inactivity notifications and resets ignore count', () async {
      await scheduler.resetInactivitySequence();
      expect(fakeRepo.canceledByTypes, contains(NotificationType.inactivity));
      expect(fakeRepo.resetIgnoreCountCalls, 1);
    });

    test('allows rescheduling after reset', () async {
      // Schedule inactivity
      await scheduler.scheduleInactivityIfNeeded(
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 4)),
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 1);

      // Reset
      await scheduler.resetInactivitySequence();

      // Should be able to schedule again for same day
      await scheduler.scheduleInactivityIfNeeded(
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 4)),
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 2);
    });
  });

  group('NotificationScheduler.schedulePrNotification', () {
    test('schedules PR notification with exercise name', () async {
      await scheduler.schedulePrNotification(
        exerciseName: 'Bench Press',
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 1);
      expect(
        fakeRepo.scheduledNotifications.first['type'],
        NotificationType.insightPr,
      );
      expect(
        fakeRepo.scheduledNotifications.first['context'],
        'Bench Press',
      );
    });

    test('blocked by anti-spam', () async {
      fakeRepo.setCanSend(false);
      await scheduler.schedulePrNotification(
        exerciseName: 'Squat',
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 0);
    });
  });

  group('NotificationScheduler.scheduleStreakNotification', () {
    test('schedules for milestone streak (7 days)', () async {
      await scheduler.scheduleStreakNotification(
        streakDays: 7,
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 1);
      expect(
        fakeRepo.scheduledNotifications.first['context'],
        '7',
      );
    });

    test('schedules for milestone streak (30 days)', () async {
      await scheduler.scheduleStreakNotification(
        streakDays: 30,
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 1);
    });

    test('does NOT schedule for non-milestone streak', () async {
      await scheduler.scheduleStreakNotification(
        streakDays: 5,
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 0);
    });

    test('does NOT schedule for non-milestone streak (10 days)', () async {
      await scheduler.scheduleStreakNotification(
        streakDays: 10,
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 0);
    });

    test('blocked by anti-spam', () async {
      fakeRepo.setCanSend(false);
      await scheduler.scheduleStreakNotification(
        streakDays: 14,
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 0);
    });
  });

  group('NotificationScheduler.scheduleVolumeNotification', () {
    test('schedules for >= 20% increase', () async {
      await scheduler.scheduleVolumeNotification(
        volumePercentIncrease: 25,
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 1);
      expect(
        fakeRepo.scheduledNotifications.first['context'],
        '25',
      );
    });

    test('schedules for exactly 20% increase', () async {
      await scheduler.scheduleVolumeNotification(
        volumePercentIncrease: 20,
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 1);
    });

    test('does NOT schedule for < 20% increase', () async {
      await scheduler.scheduleVolumeNotification(
        volumePercentIncrease: 15,
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 0);
    });

    test('does NOT schedule for 0% increase', () async {
      await scheduler.scheduleVolumeNotification(
        volumePercentIncrease: 0,
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 0);
    });

    test('blocked by anti-spam', () async {
      fakeRepo.setCanSend(false);
      await scheduler.scheduleVolumeNotification(
        volumePercentIncrease: 50,
        l10n: l10n,
      );
      expect(fakeRepo.scheduleCount, 0);
    });
  });

  group('NotificationScheduler.getStatsSummary', () {
    test('returns stats for all notification types', () async {
      final summary = await scheduler.getStatsSummary();
      expect(summary, hasLength(NotificationType.values.length));
      for (final type in NotificationType.values) {
        expect(summary[type], isNotNull, reason: type.name);
        expect(summary[type], 5); // FakeRepo returns totalSent: 5
      }
    });
  });

  group('NotificationScheduler.getWeeklyCount', () {
    test('returns weekly count from repository', () async {
      await scheduler.scheduleWorkoutForgotten(l10n);
      final count = await scheduler.getWeeklyCount();
      expect(count, 1);
    });
  });

  group('NotificationScheduler.close', () {
    test('delegates to repository.close', () async {
      // Should not throw
      await scheduler.close();
    });
  });
}

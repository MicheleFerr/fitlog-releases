/// ScheduledWorkout entity tests - covers .g.dart JSON, computed properties,
/// ScheduleStatus enum, and ScheduleStatusExtension.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/scheduling/domain/entities/scheduled_workout.dart';

void main() {
  group('ScheduleStatus enum', () {
    test('has 5 values', () {
      expect(ScheduleStatus.values.length, 5);
    });
  });

  group('ScheduleStatusExtension', () {
    test('isActionable for pending and due', () {
      expect(ScheduleStatus.pending.isActionable, isTrue);
      expect(ScheduleStatus.due.isActionable, isTrue);
      expect(ScheduleStatus.completed.isActionable, isFalse);
      expect(ScheduleStatus.skipped.isActionable, isFalse);
      expect(ScheduleStatus.missed.isActionable, isFalse);
    });

    test('isCompleted only for completed', () {
      expect(ScheduleStatus.completed.isCompleted, isTrue);
      expect(ScheduleStatus.pending.isCompleted, isFalse);
      expect(ScheduleStatus.due.isCompleted, isFalse);
    });

    test('isPast for completed, skipped, missed', () {
      expect(ScheduleStatus.completed.isPast, isTrue);
      expect(ScheduleStatus.skipped.isPast, isTrue);
      expect(ScheduleStatus.missed.isPast, isTrue);
      expect(ScheduleStatus.pending.isPast, isFalse);
      expect(ScheduleStatus.due.isPast, isFalse);
    });
  });

  group('ScheduledWorkout', () {
    ScheduledWorkout buildWorkout({
      String id = 'w1',
      String templateId = 't1',
      String templateName = 'Push Day',
      DateTime? scheduledDate,
      int reminderHour = 9,
      int reminderMinute = 30,
      ScheduleStatus status = ScheduleStatus.pending,
      DateTime? completedAt,
      DateTime? createdAt,
      String? notificationId,
    }) {
      return ScheduledWorkout(
        id: id,
        templateId: templateId,
        templateName: templateName,
        scheduledDate: scheduledDate ?? DateTime(2025, 6, 15),
        reminderHour: reminderHour,
        reminderMinute: reminderMinute,
        status: status,
        completedAt: completedAt,
        createdAt: createdAt,
        notificationId: notificationId,
      );
    }

    test('factory constructor with defaults', () {
      final w = buildWorkout();
      expect(w.id, 'w1');
      expect(w.templateId, 't1');
      expect(w.templateName, 'Push Day');
      expect(w.status, ScheduleStatus.pending);
      expect(w.completedAt, isNull);
      expect(w.createdAt, isNull);
      expect(w.notificationId, isNull);
    });

    test('reminderTime computed property', () {
      final w = buildWorkout(reminderHour: 14, reminderMinute: 45);
      expect(w.reminderTime, const TimeOfDay(hour: 14, minute: 45));
    });

    test('formattedReminderTime', () {
      expect(buildWorkout(reminderHour: 9, reminderMinute: 5).formattedReminderTime, '09:05');
      expect(buildWorkout(reminderHour: 14, reminderMinute: 30).formattedReminderTime, '14:30');
      expect(buildWorkout(reminderHour: 0, reminderMinute: 0).formattedReminderTime, '00:00');
    });

    test('reminderDateTime combines date and time', () {
      final w = buildWorkout(
        scheduledDate: DateTime(2025, 3, 10),
        reminderHour: 8,
        reminderMinute: 15,
      );
      expect(w.reminderDateTime, DateTime(2025, 3, 10, 8, 15));
    });

    test('isToday returns true for today', () {
      final now = DateTime.now();
      final w = buildWorkout(scheduledDate: DateTime(now.year, now.month, now.day));
      expect(w.isToday, isTrue);
    });

    test('isToday returns false for other days', () {
      final w = buildWorkout(scheduledDate: DateTime(2020, 1, 1));
      expect(w.isToday, isFalse);
    });

    test('isTomorrow returns true for tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final w = buildWorkout(scheduledDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day));
      expect(w.isTomorrow, isTrue);
    });

    test('isTomorrow returns false for today', () {
      final now = DateTime.now();
      final w = buildWorkout(scheduledDate: DateTime(now.year, now.month, now.day));
      expect(w.isTomorrow, isFalse);
    });

    test('isPastDue returns true for past dates', () {
      final w = buildWorkout(scheduledDate: DateTime(2020, 1, 1));
      expect(w.isPastDue, isTrue);
    });

    test('isPastDue returns false for today', () {
      final now = DateTime.now();
      final w = buildWorkout(scheduledDate: DateTime(now.year, now.month, now.day));
      expect(w.isPastDue, isFalse);
    });

    test('isPastDue returns false for future dates', () {
      final w = buildWorkout(scheduledDate: DateTime(2099, 12, 31));
      expect(w.isPastDue, isFalse);
    });

    group('JSON round-trip', () {
      test('basic round-trip', () {
        final original = buildWorkout(
          createdAt: DateTime(2025, 1, 1, 10, 0),
          notificationId: 'notif-1',
        );
        final json = original.toJson();
        final restored = ScheduledWorkout.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.templateId, original.templateId);
        expect(restored.templateName, original.templateName);
        expect(restored.reminderHour, original.reminderHour);
        expect(restored.reminderMinute, original.reminderMinute);
        expect(restored.status, original.status);
        expect(restored.notificationId, original.notificationId);
      });

      test('round-trip with all statuses', () {
        for (final status in ScheduleStatus.values) {
          final w = buildWorkout(status: status);
          final json = w.toJson();
          final restored = ScheduledWorkout.fromJson(json);
          expect(restored.status, status);
        }
      });

      test('round-trip with completedAt', () {
        final w = buildWorkout(
          status: ScheduleStatus.completed,
          completedAt: DateTime(2025, 6, 15, 17, 30),
        );
        final json = w.toJson();
        final restored = ScheduledWorkout.fromJson(json);
        expect(restored.completedAt, w.completedAt);
      });

      test('round-trip with null optional fields', () {
        final w = buildWorkout();
        final json = w.toJson();
        final restored = ScheduledWorkout.fromJson(json);
        expect(restored.completedAt, isNull);
        expect(restored.createdAt, isNull);
        expect(restored.notificationId, isNull);
      });

      test('fromJson with missing status defaults to pending', () {
        final json = {
          'id': 'w1',
          'templateId': 't1',
          'templateName': 'Test',
          'scheduledDate': '2025-06-15T00:00:00.000',
          'reminderHour': 9,
          'reminderMinute': 0,
        };
        final w = ScheduledWorkout.fromJson(json);
        expect(w.status, ScheduleStatus.pending);
      });
    });

    group('create factory', () {
      test('creates with current createdAt', () {
        final before = DateTime.now();
        final w = ScheduledWorkout.create(
          id: 'c1',
          templateId: 't1',
          templateName: 'Legs',
          scheduledDate: DateTime(2025, 7, 1, 14, 30),
          reminderTime: const TimeOfDay(hour: 8, minute: 0),
        );
        final after = DateTime.now();

        expect(w.id, 'c1');
        expect(w.templateName, 'Legs');
        expect(w.reminderHour, 8);
        expect(w.reminderMinute, 0);
        expect(w.status, ScheduleStatus.pending);
        // scheduledDate should be normalized to midnight
        expect(w.scheduledDate, DateTime(2025, 7, 1));
        // createdAt should be between before and after
        expect(w.createdAt, isNotNull);
        expect(w.createdAt!.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(w.createdAt!.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });
    });

    test('copyWith works', () {
      final w = buildWorkout();
      final copy = w.copyWith(templateName: 'Pull Day', status: ScheduleStatus.completed);
      expect(copy.templateName, 'Pull Day');
      expect(copy.status, ScheduleStatus.completed);
      expect(copy.id, w.id); // unchanged
    });

    test('equality', () {
      final a = buildWorkout();
      final b = buildWorkout();
      expect(a, equals(b));
    });

    test('inequality with different id', () {
      final a = buildWorkout(id: 'a');
      final b = buildWorkout(id: 'b');
      expect(a, isNot(equals(b)));
    });
  });
}

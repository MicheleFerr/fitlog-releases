/// ScheduledWorkout entity tests - status, computed properties, formatting.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/scheduling/domain/entities/scheduled_workout.dart';

void main() {
  group('ScheduleStatus', () {
    test('has 5 values', () {
      expect(ScheduleStatus.values.length, 5);
    });

    test('isActionable', () {
      expect(ScheduleStatus.pending.isActionable, isTrue);
      expect(ScheduleStatus.due.isActionable, isTrue);
      expect(ScheduleStatus.completed.isActionable, isFalse);
      expect(ScheduleStatus.skipped.isActionable, isFalse);
      expect(ScheduleStatus.missed.isActionable, isFalse);
    });

    test('isCompleted', () {
      expect(ScheduleStatus.completed.isCompleted, isTrue);
      expect(ScheduleStatus.pending.isCompleted, isFalse);
    });

    test('isPast', () {
      expect(ScheduleStatus.completed.isPast, isTrue);
      expect(ScheduleStatus.skipped.isPast, isTrue);
      expect(ScheduleStatus.missed.isPast, isTrue);
      expect(ScheduleStatus.pending.isPast, isFalse);
      expect(ScheduleStatus.due.isPast, isFalse);
    });
  });

  group('ScheduledWorkout', () {
    ScheduledWorkout makeWorkout({
      DateTime? scheduledDate,
      int reminderHour = 9,
      int reminderMinute = 0,
      ScheduleStatus status = ScheduleStatus.pending,
    }) {
      return ScheduledWorkout(
        id: 'sw1',
        templateId: 't1',
        templateName: 'Push Day',
        scheduledDate: scheduledDate ?? DateTime.now(),
        reminderHour: reminderHour,
        reminderMinute: reminderMinute,
        status: status,
      );
    }

    test('reminderTime', () {
      final workout = makeWorkout(reminderHour: 14, reminderMinute: 30);
      expect(workout.reminderTime.hour, 14);
      expect(workout.reminderTime.minute, 30);
    });

    test('isToday with today date', () {
      final workout = makeWorkout(scheduledDate: DateTime.now());
      expect(workout.isToday, isTrue);
    });

    test('isToday with yesterday date', () {
      final workout = makeWorkout(
        scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(workout.isToday, isFalse);
    });

    test('isTomorrow', () {
      final workout = makeWorkout(
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(workout.isTomorrow, isTrue);
    });

    test('isTomorrow false for today', () {
      final workout = makeWorkout(scheduledDate: DateTime.now());
      expect(workout.isTomorrow, isFalse);
    });

    test('isPastDue for past date', () {
      final workout = makeWorkout(
        scheduledDate: DateTime.now().subtract(const Duration(days: 2)),
      );
      expect(workout.isPastDue, isTrue);
    });

    test('isPastDue false for today', () {
      final workout = makeWorkout(scheduledDate: DateTime.now());
      expect(workout.isPastDue, isFalse);
    });

    test('isPastDue false for future', () {
      final workout = makeWorkout(
        scheduledDate: DateTime.now().add(const Duration(days: 5)),
      );
      expect(workout.isPastDue, isFalse);
    });

    test('reminderDateTime combines date and time', () {
      final workout = makeWorkout(
        scheduledDate: DateTime(2025, 6, 15),
        reminderHour: 14,
        reminderMinute: 30,
      );
      expect(workout.reminderDateTime, DateTime(2025, 6, 15, 14, 30));
    });

    test('formattedReminderTime', () {
      expect(makeWorkout(reminderHour: 9, reminderMinute: 5).formattedReminderTime, '09:05');
      expect(makeWorkout(reminderHour: 14, reminderMinute: 30).formattedReminderTime, '14:30');
      expect(makeWorkout(reminderHour: 0, reminderMinute: 0).formattedReminderTime, '00:00');
    });

    test('create factory', () {
      final workout = ScheduledWorkout.create(
        id: 'sw2',
        templateId: 't2',
        templateName: 'Pull Day',
        scheduledDate: DateTime(2025, 6, 15, 10, 30, 45),
        reminderTime: const TimeOfDay(hour: 8, minute: 0),
      );
      expect(workout.id, 'sw2');
      expect(workout.templateName, 'Pull Day');
      // scheduledDate should be normalized to midnight
      expect(workout.scheduledDate.hour, 0);
      expect(workout.scheduledDate.minute, 0);
      expect(workout.reminderHour, 8);
      expect(workout.reminderMinute, 0);
      expect(workout.status, ScheduleStatus.pending);
      expect(workout.createdAt, isNotNull);
    });

    test('default status is pending', () {
      final workout = makeWorkout();
      expect(workout.status, ScheduleStatus.pending);
    });

    test('JSON round-trip', () {
      final workout = makeWorkout(
        scheduledDate: DateTime(2025, 6, 15),
        reminderHour: 14,
        reminderMinute: 30,
      );
      final json = workout.toJson();
      final restored = ScheduledWorkout.fromJson(json);
      expect(restored.id, 'sw1');
      expect(restored.templateName, 'Push Day');
      expect(restored.reminderHour, 14);
      expect(restored.reminderMinute, 30);
    });
  });
}

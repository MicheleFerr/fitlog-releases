// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_config.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_record.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_type.dart';
import 'package:gymbro_flutter_new/features/scheduling/domain/entities/scheduled_workout.dart';

void main() {
  // ---------------------------------------------------------------------------
  // SCHEDULING DOMAIN
  // ---------------------------------------------------------------------------

  group('ScheduleStatus', () {
    group('enum values', () {
      test('has exactly five values', () {
        expect(ScheduleStatus.values.length, 5);
      });

      test('contains all expected values', () {
        expect(
          ScheduleStatus.values,
          containsAll([
            ScheduleStatus.pending,
            ScheduleStatus.due,
            ScheduleStatus.completed,
            ScheduleStatus.skipped,
            ScheduleStatus.missed,
          ]),
        );
      });
    });

    group('ScheduleStatusExtension.isActionable', () {
      test('pending is actionable', () {
        expect(ScheduleStatus.pending.isActionable, isTrue);
      });

      test('due is actionable', () {
        expect(ScheduleStatus.due.isActionable, isTrue);
      });

      test('completed is not actionable', () {
        expect(ScheduleStatus.completed.isActionable, isFalse);
      });

      test('skipped is not actionable', () {
        expect(ScheduleStatus.skipped.isActionable, isFalse);
      });

      test('missed is not actionable', () {
        expect(ScheduleStatus.missed.isActionable, isFalse);
      });
    });

    group('ScheduleStatusExtension.isCompleted', () {
      test('completed returns true', () {
        expect(ScheduleStatus.completed.isCompleted, isTrue);
      });

      test('pending returns false', () {
        expect(ScheduleStatus.pending.isCompleted, isFalse);
      });

      test('due returns false', () {
        expect(ScheduleStatus.due.isCompleted, isFalse);
      });

      test('skipped returns false', () {
        expect(ScheduleStatus.skipped.isCompleted, isFalse);
      });

      test('missed returns false', () {
        expect(ScheduleStatus.missed.isCompleted, isFalse);
      });
    });

    group('ScheduleStatusExtension.isPast', () {
      test('completed is past', () {
        expect(ScheduleStatus.completed.isPast, isTrue);
      });

      test('skipped is past', () {
        expect(ScheduleStatus.skipped.isPast, isTrue);
      });

      test('missed is past', () {
        expect(ScheduleStatus.missed.isPast, isTrue);
      });

      test('pending is not past', () {
        expect(ScheduleStatus.pending.isPast, isFalse);
      });

      test('due is not past', () {
        expect(ScheduleStatus.due.isPast, isFalse);
      });
    });
  });

  // ---------------------------------------------------------------------------

  group('ScheduledWorkout', () {
    // Helper that builds a workout anchored to a given date.
    ScheduledWorkout makeWorkout({
      required DateTime scheduledDate,
      int reminderHour = 8,
      int reminderMinute = 30,
      ScheduleStatus status = ScheduleStatus.pending,
    }) {
      return ScheduledWorkout(
        id: 'test-id',
        templateId: 'template-1',
        templateName: 'Push Day',
        scheduledDate: scheduledDate,
        reminderHour: reminderHour,
        reminderMinute: reminderMinute,
        status: status,
      );
    }

    group('factory constructor ScheduledWorkout.create', () {
      test('sets createdAt to current time', () {
        final before = DateTime.now();
        final workout = ScheduledWorkout.create(
          id: 'c-1',
          templateId: 't-1',
          templateName: 'Leg Day',
          scheduledDate: DateTime(2030, 6, 15),
          reminderTime: const TimeOfDay(hour: 7, minute: 0),
        );
        final after = DateTime.now();

        expect(workout.createdAt, isNotNull);
        expect(
          workout.createdAt!.isAfter(before) ||
              workout.createdAt!.isAtSameMomentAs(before),
          isTrue,
        );
        expect(
          workout.createdAt!.isBefore(after) ||
              workout.createdAt!.isAtSameMomentAs(after),
          isTrue,
        );
      });

      test('status defaults to pending', () {
        final workout = ScheduledWorkout.create(
          id: 'c-2',
          templateId: 't-1',
          templateName: 'Pull Day',
          scheduledDate: DateTime(2030, 6, 15),
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
        );

        expect(workout.status, ScheduleStatus.pending);
      });

      test('strips time from scheduledDate (stores date only)', () {
        // Pass a DateTime with non-zero time components.
        final workout = ScheduledWorkout.create(
          id: 'c-3',
          templateId: 't-1',
          templateName: 'Core',
          scheduledDate: DateTime(2030, 6, 15, 14, 30, 45),
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
        );

        expect(workout.scheduledDate.hour, 0);
        expect(workout.scheduledDate.minute, 0);
        expect(workout.scheduledDate.second, 0);
      });

      test('stores reminderHour and reminderMinute from TimeOfDay', () {
        final workout = ScheduledWorkout.create(
          id: 'c-4',
          templateId: 't-1',
          templateName: 'Cardio',
          scheduledDate: DateTime(2030, 6, 15),
          reminderTime: const TimeOfDay(hour: 17, minute: 45),
        );

        expect(workout.reminderHour, 17);
        expect(workout.reminderMinute, 45);
      });
    });

    group('isToday', () {
      test('returns true when scheduledDate is today', () {
        final today = DateTime.now();
        final workout = makeWorkout(
          scheduledDate: DateTime(today.year, today.month, today.day),
        );

        expect(workout.isToday, isTrue);
      });

      test('returns false when scheduledDate is yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final workout = makeWorkout(
          scheduledDate:
              DateTime(yesterday.year, yesterday.month, yesterday.day),
        );

        expect(workout.isToday, isFalse);
      });

      test('returns false when scheduledDate is tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final workout = makeWorkout(
          scheduledDate:
              DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
        );

        expect(workout.isToday, isFalse);
      });

      test('returns false when scheduledDate is far in the past', () {
        final workout = makeWorkout(scheduledDate: DateTime(2000, 1, 1));

        expect(workout.isToday, isFalse);
      });

      test('returns false when scheduledDate is far in the future', () {
        final workout = makeWorkout(scheduledDate: DateTime(2099, 12, 31));

        expect(workout.isToday, isFalse);
      });
    });

    group('isTomorrow', () {
      test('returns true when scheduledDate is tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final workout = makeWorkout(
          scheduledDate:
              DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
        );

        expect(workout.isTomorrow, isTrue);
      });

      test('returns false when scheduledDate is today', () {
        final today = DateTime.now();
        final workout = makeWorkout(
          scheduledDate: DateTime(today.year, today.month, today.day),
        );

        expect(workout.isTomorrow, isFalse);
      });

      test('returns false when scheduledDate is two days from now', () {
        final twoDays = DateTime.now().add(const Duration(days: 2));
        final workout = makeWorkout(
          scheduledDate: DateTime(twoDays.year, twoDays.month, twoDays.day),
        );

        expect(workout.isTomorrow, isFalse);
      });

      test('returns false when scheduledDate is in the past', () {
        final workout = makeWorkout(scheduledDate: DateTime(2000, 1, 1));

        expect(workout.isTomorrow, isFalse);
      });
    });

    group('isPastDue', () {
      test('returns false when scheduledDate is today', () {
        final today = DateTime.now();
        final workout = makeWorkout(
          scheduledDate: DateTime(today.year, today.month, today.day),
        );

        // Today is NOT past due — only strictly before today is.
        expect(workout.isPastDue, isFalse);
      });

      test('returns true when scheduledDate is yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final workout = makeWorkout(
          scheduledDate:
              DateTime(yesterday.year, yesterday.month, yesterday.day),
        );

        expect(workout.isPastDue, isTrue);
      });

      test('returns true when scheduledDate is far in the past', () {
        final workout = makeWorkout(scheduledDate: DateTime(2000, 1, 1));

        expect(workout.isPastDue, isTrue);
      });

      test('returns false when scheduledDate is tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final workout = makeWorkout(
          scheduledDate:
              DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
        );

        expect(workout.isPastDue, isFalse);
      });

      test('returns false when scheduledDate is far in the future', () {
        final workout = makeWorkout(scheduledDate: DateTime(2099, 12, 31));

        expect(workout.isPastDue, isFalse);
      });
    });

    group('reminderTime getter', () {
      test('returns TimeOfDay matching stored hour and minute', () {
        final workout = makeWorkout(
          scheduledDate: DateTime(2030, 6, 15),
          reminderHour: 6,
          reminderMinute: 45,
        );

        expect(workout.reminderTime.hour, 6);
        expect(workout.reminderTime.minute, 45);
      });

      test('handles midnight (00:00)', () {
        final workout = makeWorkout(
          scheduledDate: DateTime(2030, 6, 15),
          reminderHour: 0,
          reminderMinute: 0,
        );

        expect(workout.reminderTime.hour, 0);
        expect(workout.reminderTime.minute, 0);
      });

      test('handles end of day (23:59)', () {
        final workout = makeWorkout(
          scheduledDate: DateTime(2030, 6, 15),
          reminderHour: 23,
          reminderMinute: 59,
        );

        expect(workout.reminderTime.hour, 23);
        expect(workout.reminderTime.minute, 59);
      });
    });

    group('formattedReminderTime', () {
      test('pads single-digit hour and minute with leading zeros', () {
        final workout = makeWorkout(
          scheduledDate: DateTime(2030, 6, 15),
          reminderHour: 7,
          reminderMinute: 5,
        );

        expect(workout.formattedReminderTime, '07:05');
      });

      test('formats double-digit hour and minute without padding', () {
        final workout = makeWorkout(
          scheduledDate: DateTime(2030, 6, 15),
          reminderHour: 14,
          reminderMinute: 30,
        );

        expect(workout.formattedReminderTime, '14:30');
      });

      test('formats midnight as 00:00', () {
        final workout = makeWorkout(
          scheduledDate: DateTime(2030, 6, 15),
          reminderHour: 0,
          reminderMinute: 0,
        );

        expect(workout.formattedReminderTime, '00:00');
      });

      test('formats 23:59 correctly', () {
        final workout = makeWorkout(
          scheduledDate: DateTime(2030, 6, 15),
          reminderHour: 23,
          reminderMinute: 59,
        );

        expect(workout.formattedReminderTime, '23:59');
      });

      test('pads only hour when minute has two digits', () {
        final workout = makeWorkout(
          scheduledDate: DateTime(2030, 6, 15),
          reminderHour: 9,
          reminderMinute: 45,
        );

        expect(workout.formattedReminderTime, '09:45');
      });

      test('result always has exactly five characters (HH:MM)', () {
        // Exhaustively check a sample of times
        for (final hour in [0, 1, 9, 10, 23]) {
          for (final minute in [0, 1, 9, 10, 59]) {
            final workout = makeWorkout(
              scheduledDate: DateTime(2030, 1, 1),
              reminderHour: hour,
              reminderMinute: minute,
            );

            expect(
              workout.formattedReminderTime.length,
              5,
              reason:
                  'Expected length 5 for $hour:$minute but got '
                  '"${workout.formattedReminderTime}"',
            );
          }
        }
      });
    });

    group('reminderDateTime', () {
      test('combines scheduledDate with reminder hour and minute', () {
        final workout = makeWorkout(
          scheduledDate: DateTime(2030, 3, 22),
          reminderHour: 9,
          reminderMinute: 15,
        );

        final dt = workout.reminderDateTime;
        expect(dt.year, 2030);
        expect(dt.month, 3);
        expect(dt.day, 22);
        expect(dt.hour, 9);
        expect(dt.minute, 15);
      });

      test('midnight reminder is at 00:00 on scheduledDate', () {
        final workout = makeWorkout(
          scheduledDate: DateTime(2030, 12, 31),
          reminderHour: 0,
          reminderMinute: 0,
        );

        final dt = workout.reminderDateTime;
        expect(dt.day, 31);
        expect(dt.hour, 0);
        expect(dt.minute, 0);
      });

      test('end-of-day reminder is at 23:59 on scheduledDate', () {
        final workout = makeWorkout(
          scheduledDate: DateTime(2030, 12, 31),
          reminderHour: 23,
          reminderMinute: 59,
        );

        final dt = workout.reminderDateTime;
        expect(dt.hour, 23);
        expect(dt.minute, 59);
        expect(dt.second, 0);
      });
    });

    group('copyWith immutability', () {
      test('updating status does not mutate the original', () {
        final original = makeWorkout(
          scheduledDate: DateTime(2030, 6, 15),
          status: ScheduleStatus.pending,
        );

        final updated = original.copyWith(status: ScheduleStatus.completed);

        expect(original.status, ScheduleStatus.pending);
        expect(updated.status, ScheduleStatus.completed);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // NOTIFICATIONS DOMAIN
  // ---------------------------------------------------------------------------

  group('NotificationType', () {
    group('enum values', () {
      test('has exactly five values', () {
        expect(NotificationType.values.length, 5);
      });

      test('contains all expected types', () {
        expect(
          NotificationType.values,
          containsAll([
            NotificationType.workoutForgotten,
            NotificationType.inactivity,
            NotificationType.insightPr,
            NotificationType.insightStreak,
            NotificationType.insightVolume,
          ]),
        );
      });
    });

    group('channelId', () {
      test('workoutForgotten returns workout_reminder', () {
        expect(
          NotificationType.workoutForgotten.channelId,
          'workout_reminder',
        );
      });

      test('inactivity returns inactivity_reminder', () {
        expect(NotificationType.inactivity.channelId, 'inactivity_reminder');
      });

      test('insightPr returns insights', () {
        expect(NotificationType.insightPr.channelId, 'insights');
      });

      test('insightStreak returns insights', () {
        expect(NotificationType.insightStreak.channelId, 'insights');
      });

      test('insightVolume returns insights', () {
        expect(NotificationType.insightVolume.channelId, 'insights');
      });
    });

    group('channelName', () {
      test('workoutForgotten has Workout Reminders channel name', () {
        expect(
          NotificationType.workoutForgotten.channelName,
          'Workout Reminders',
        );
      });

      test('inactivity has Inactivity Reminders channel name', () {
        expect(
          NotificationType.inactivity.channelName,
          'Inactivity Reminders',
        );
      });

      test('all insight types share same channel name', () {
        const insightsName = 'Insights & Achievements';
        expect(NotificationType.insightPr.channelName, insightsName);
        expect(NotificationType.insightStreak.channelName, insightsName);
        expect(NotificationType.insightVolume.channelName, insightsName);
      });
    });

    group('channelDescription', () {
      test('workoutForgotten has non-empty description', () {
        expect(
          NotificationType.workoutForgotten.channelDescription,
          isNotEmpty,
        );
      });

      test('inactivity has non-empty description', () {
        expect(NotificationType.inactivity.channelDescription, isNotEmpty);
      });

      test('all insight types share the same description', () {
        expect(
          NotificationType.insightPr.channelDescription,
          equals(NotificationType.insightStreak.channelDescription),
        );
        expect(
          NotificationType.insightPr.channelDescription,
          equals(NotificationType.insightVolume.channelDescription),
        );
      });
    });

    group('deepLinkPath', () {
      test('workoutForgotten deep-links to /workout', () {
        expect(NotificationType.workoutForgotten.deepLinkPath, '/workout');
      });

      test('inactivity deep-links to /', () {
        expect(NotificationType.inactivity.deepLinkPath, '/');
      });

      test('insight types deep-link to /stats', () {
        expect(NotificationType.insightPr.deepLinkPath, '/stats');
        expect(NotificationType.insightStreak.deepLinkPath, '/stats');
        expect(NotificationType.insightVolume.deepLinkPath, '/stats');
      });
    });

    group('isHighValue', () {
      test('workoutForgotten is high value', () {
        expect(NotificationType.workoutForgotten.isHighValue, isTrue);
      });

      test('insightPr is high value', () {
        expect(NotificationType.insightPr.isHighValue, isTrue);
      });

      test('inactivity is not high value', () {
        expect(NotificationType.inactivity.isHighValue, isFalse);
      });

      test('insightStreak is not high value', () {
        expect(NotificationType.insightStreak.isHighValue, isFalse);
      });

      test('insightVolume is not high value', () {
        expect(NotificationType.insightVolume.isHighValue, isFalse);
      });
    });

    group('maxIgnoreCount', () {
      test('workoutForgotten maxIgnoreCount is 1', () {
        expect(NotificationType.workoutForgotten.maxIgnoreCount, 1);
      });

      test('inactivity maxIgnoreCount is 3', () {
        expect(NotificationType.inactivity.maxIgnoreCount, 3);
      });

      test('insight types maxIgnoreCount is 5', () {
        expect(NotificationType.insightPr.maxIgnoreCount, 5);
        expect(NotificationType.insightStreak.maxIgnoreCount, 5);
        expect(NotificationType.insightVolume.maxIgnoreCount, 5);
      });
    });
  });

  // ---------------------------------------------------------------------------

  group('NotificationRecord', () {
    // Shared base record for tests that just need a valid instance.
    final baseRecord = NotificationRecord(
      id: 'rec-1',
      type: NotificationType.inactivity,
      sentAt: DateTime(2030, 1, 10, 9, 0),
      messageKey: 'msg_inactivity_1',
    );

    group('wasOpened', () {
      test('returns false when openedAt is null', () {
        expect(baseRecord.wasOpened, isFalse);
      });

      test('returns true when openedAt is set', () {
        final opened = baseRecord.copyWith(
          openedAt: DateTime(2030, 1, 10, 10, 30),
        );

        expect(opened.wasOpened, isTrue);
      });
    });

    group('wasIgnored', () {
      test('returns true when not canceled and not opened', () {
        // Default wasCanceled is false, openedAt is null.
        expect(baseRecord.wasIgnored, isTrue);
      });

      test('returns false when notification was opened', () {
        final opened = baseRecord.copyWith(
          openedAt: DateTime(2030, 1, 10, 10, 0),
        );

        expect(opened.wasIgnored, isFalse);
      });

      test('returns false when notification was canceled', () {
        final canceled = baseRecord.copyWith(wasCanceled: true);

        expect(canceled.wasIgnored, isFalse);
      });

      test('returns false when both canceled and opened', () {
        // Edge case: both flags set (e.g., data inconsistency).
        final both = baseRecord.copyWith(
          wasCanceled: true,
          openedAt: DateTime(2030, 1, 10, 10, 0),
        );

        // wasCanceled takes precedence in the formula: !wasCanceled && openedAt == null
        expect(both.wasIgnored, isFalse);
      });
    });

    group('wasCanceled default', () {
      test('defaults to false when not provided', () {
        expect(baseRecord.wasCanceled, isFalse);
      });
    });

    group('optional fields', () {
      test('context defaults to null', () {
        expect(baseRecord.context, isNull);
      });

      test('inactivityDay defaults to null', () {
        expect(baseRecord.inactivityDay, isNull);
      });

      test('context and inactivityDay can be set', () {
        final withExtras = baseRecord.copyWith(
          context: 'Bench Press',
          inactivityDay: 7,
        );

        expect(withExtras.context, 'Bench Press');
        expect(withExtras.inactivityDay, 7);
      });
    });
  });

  // ---------------------------------------------------------------------------

  group('NotificationStats', () {
    group('openRate', () {
      test('returns 0.0 when totalSent is 0', () {
        const stats = NotificationStats(
          totalSent: 0,
          totalOpened: 0,
          consecutiveIgnores: 0,
        );

        expect(stats.openRate, 0.0);
      });

      test('returns 1.0 when all notifications were opened', () {
        const stats = NotificationStats(
          totalSent: 10,
          totalOpened: 10,
          consecutiveIgnores: 0,
        );

        expect(stats.openRate, 1.0);
      });

      test('returns 0.5 for 50% open rate', () {
        const stats = NotificationStats(
          totalSent: 10,
          totalOpened: 5,
          consecutiveIgnores: 0,
        );

        expect(stats.openRate, closeTo(0.5, 1e-9));
      });

      test('returns 0.0 when none were opened but some were sent', () {
        const stats = NotificationStats(
          totalSent: 5,
          totalOpened: 0,
          consecutiveIgnores: 5,
        );

        expect(stats.openRate, 0.0);
      });

      test('returns correct fractional value', () {
        const stats = NotificationStats(
          totalSent: 3,
          totalOpened: 1,
          consecutiveIgnores: 0,
        );

        expect(stats.openRate, closeTo(1 / 3, 1e-9));
      });

      test('result is always between 0.0 and 1.0 inclusive', () {
        final cases = [
          const NotificationStats(totalSent: 0, totalOpened: 0, consecutiveIgnores: 0),
          const NotificationStats(totalSent: 1, totalOpened: 0, consecutiveIgnores: 1),
          const NotificationStats(totalSent: 1, totalOpened: 1, consecutiveIgnores: 0),
          const NotificationStats(totalSent: 100, totalOpened: 50, consecutiveIgnores: 2),
        ];

        for (final stats in cases) {
          expect(
            stats.openRate,
            inInclusiveRange(0.0, 1.0),
            reason: 'openRate ${stats.openRate} out of range for $stats',
          );
        }
      });
    });

    group('shouldStopSending', () {
      test('returns false when consecutiveIgnores is below maxIgnores', () {
        const stats = NotificationStats(
          totalSent: 5,
          totalOpened: 0,
          consecutiveIgnores: 2,
        );

        expect(stats.shouldStopSending(3), isFalse);
      });

      test('returns true when consecutiveIgnores equals maxIgnores', () {
        const stats = NotificationStats(
          totalSent: 5,
          totalOpened: 0,
          consecutiveIgnores: 3,
        );

        expect(stats.shouldStopSending(3), isTrue);
      });

      test('returns true when consecutiveIgnores exceeds maxIgnores', () {
        const stats = NotificationStats(
          totalSent: 10,
          totalOpened: 0,
          consecutiveIgnores: 5,
        );

        expect(stats.shouldStopSending(3), isTrue);
      });

      test('returns false when consecutiveIgnores is 0 (any maxIgnores)', () {
        const stats = NotificationStats(
          totalSent: 3,
          totalOpened: 3,
          consecutiveIgnores: 0,
        );

        expect(stats.shouldStopSending(1), isFalse);
      });

      test('works correctly with maxIgnores from NotificationConfig.defaultMaxIgnores', () {
        const stats = NotificationStats(
          totalSent: 3,
          totalOpened: 0,
          consecutiveIgnores: NotificationConfig.defaultMaxIgnores,
        );

        expect(
          stats.shouldStopSending(NotificationConfig.defaultMaxIgnores),
          isTrue,
        );
      });

      test('stops sending for workoutForgotten after 1 ignore', () {
        const stats = NotificationStats(
          totalSent: 1,
          totalOpened: 0,
          consecutiveIgnores: 1,
        );

        expect(
          stats.shouldStopSending(
            NotificationType.workoutForgotten.maxIgnoreCount,
          ),
          isTrue,
        );
      });

      test('does not stop sending insights after 4 ignores (threshold is 5)', () {
        const stats = NotificationStats(
          totalSent: 4,
          totalOpened: 0,
          consecutiveIgnores: 4,
        );

        expect(
          stats.shouldStopSending(NotificationType.insightPr.maxIgnoreCount),
          isFalse,
        );
      });

      test('stops sending insights after 5 consecutive ignores', () {
        const stats = NotificationStats(
          totalSent: 5,
          totalOpened: 0,
          consecutiveIgnores: 5,
        );

        expect(
          stats.shouldStopSending(NotificationType.insightPr.maxIgnoreCount),
          isTrue,
        );
      });
    });

    group('optional fields', () {
      test('lastSentAt and lastMessageKey default to null', () {
        const stats = NotificationStats(
          totalSent: 0,
          totalOpened: 0,
          consecutiveIgnores: 0,
        );

        expect(stats.lastSentAt, isNull);
        expect(stats.lastMessageKey, isNull);
      });
    });
  });

  // ---------------------------------------------------------------------------

  group('NotificationConfig', () {
    group('constants', () {
      test('globalCooldown is 24 hours', () {
        expect(
          NotificationConfig.globalCooldown,
          const Duration(hours: 24),
        );
      });

      test('maxNotificationsPerWeek is 3', () {
        expect(NotificationConfig.maxNotificationsPerWeek, 3);
      });

      test('maxScheduledNotifications is 10', () {
        expect(NotificationConfig.maxScheduledNotifications, 10);
      });

      test('quietHoursStart is 22:00', () {
        expect(NotificationConfig.quietHoursStart.hour, 22);
        expect(NotificationConfig.quietHoursStart.minute, 0);
      });

      test('quietHoursEnd is 08:00', () {
        expect(NotificationConfig.quietHoursEnd.hour, 8);
        expect(NotificationConfig.quietHoursEnd.minute, 0);
      });

      test('defaultScheduleTime is 09:00', () {
        expect(NotificationConfig.defaultScheduleTime.hour, 9);
        expect(NotificationConfig.defaultScheduleTime.minute, 0);
      });

      test('workoutForgottenDelay is 25 minutes', () {
        expect(
          NotificationConfig.workoutForgottenDelay,
          const Duration(minutes: 25),
        );
      });

      test('noSetActivityThreshold is 25 minutes', () {
        expect(
          NotificationConfig.noSetActivityThreshold,
          const Duration(minutes: 25),
        );
      });

      test('inactivityDay1 is 3', () {
        expect(NotificationConfig.inactivityDay1, 3);
      });

      test('inactivityDay2 is 7', () {
        expect(NotificationConfig.inactivityDay2, 7);
      });

      test('inactivityDay3 is 14', () {
        expect(NotificationConfig.inactivityDay3, 14);
      });

      test('inactivitySequence contains days 3, 7, 14 in order', () {
        expect(
          NotificationConfig.inactivitySequence,
          [
            NotificationConfig.inactivityDay1,
            NotificationConfig.inactivityDay2,
            NotificationConfig.inactivityDay3,
          ],
        );
      });

      test('prNotificationDelay is 20 minutes', () {
        expect(
          NotificationConfig.prNotificationDelay,
          const Duration(minutes: 20),
        );
      });

      test('volumeIncreaseThreshold is 20%', () {
        expect(NotificationConfig.volumeIncreaseThreshold, closeTo(0.20, 1e-9));
      });

      test('messageRotationCooldown is 7 days', () {
        expect(
          NotificationConfig.messageRotationCooldown,
          const Duration(days: 7),
        );
      });

      test('defaultMaxIgnores is 3', () {
        expect(NotificationConfig.defaultMaxIgnores, 3);
      });

      test('streakMilestones contains expected values', () {
        expect(
          NotificationConfig.streakMilestones,
          containsAll([7, 14, 30, 60, 90, 180, 365]),
        );
      });
    });

    group('isQuietHours', () {
      test('10:00 is NOT quiet hours', () {
        expect(
          NotificationConfig.isQuietHours(DateTime(2030, 1, 1, 10, 0)),
          isFalse,
        );
      });

      test('09:00 is NOT quiet hours', () {
        expect(
          NotificationConfig.isQuietHours(DateTime(2030, 1, 1, 9, 0)),
          isFalse,
        );
      });

      test('08:00 is NOT quiet hours (boundary exclusive)', () {
        // quiet hours are BEFORE 08:00, at 08:00 it ends
        expect(
          NotificationConfig.isQuietHours(DateTime(2030, 1, 1, 8, 0)),
          isFalse,
        );
      });

      test('07:59 IS quiet hours', () {
        expect(
          NotificationConfig.isQuietHours(DateTime(2030, 1, 1, 7, 59)),
          isTrue,
        );
      });

      test('00:00 IS quiet hours (midnight)', () {
        expect(
          NotificationConfig.isQuietHours(DateTime(2030, 1, 1, 0, 0)),
          isTrue,
        );
      });

      test('22:00 IS quiet hours (boundary inclusive)', () {
        expect(
          NotificationConfig.isQuietHours(DateTime(2030, 1, 1, 22, 0)),
          isTrue,
        );
      });

      test('23:59 IS quiet hours', () {
        expect(
          NotificationConfig.isQuietHours(DateTime(2030, 1, 1, 23, 59)),
          isTrue,
        );
      });

      test('21:59 is NOT quiet hours', () {
        expect(
          NotificationConfig.isQuietHours(DateTime(2030, 1, 1, 21, 59)),
          isFalse,
        );
      });

      test('12:00 (noon) is NOT quiet hours', () {
        expect(
          NotificationConfig.isQuietHours(DateTime(2030, 6, 15, 12, 0)),
          isFalse,
        );
      });
    });

    group('getNextAvailableTime', () {
      test('returns same time when not in quiet hours', () {
        final input = DateTime(2030, 1, 1, 14, 30); // 14:30 - not quiet

        final result = NotificationConfig.getNextAvailableTime(input);

        expect(result, equals(input));
      });

      test('schedules for today 09:00 when before 08:00 (quiet hours before dawn)', () {
        final input = DateTime(2030, 3, 15, 2, 0); // 02:00 - quiet hours

        final result = NotificationConfig.getNextAvailableTime(input);

        expect(result.year, 2030);
        expect(result.month, 3);
        expect(result.day, 15); // same day
        expect(result.hour, 9);
        expect(result.minute, 0);
      });

      test('schedules for tomorrow 09:00 when after 22:00', () {
        final input = DateTime(2030, 3, 15, 23, 0); // 23:00 - quiet hours

        final result = NotificationConfig.getNextAvailableTime(input);

        expect(result.year, 2030);
        expect(result.month, 3);
        expect(result.day, 16); // next day
        expect(result.hour, 9);
        expect(result.minute, 0);
      });

      test('schedules for tomorrow 09:00 exactly at 22:00 boundary', () {
        final input = DateTime(2030, 5, 10, 22, 0);

        final result = NotificationConfig.getNextAvailableTime(input);

        expect(result.day, 11); // next day
        expect(result.hour, 9);
        expect(result.minute, 0);
      });

      test('non-quiet-hours time is returned unchanged at 08:01', () {
        final input = DateTime(2030, 1, 1, 8, 1);

        final result = NotificationConfig.getNextAvailableTime(input);

        expect(result, equals(input));
      });
    });

    group('getNextInactivityDay', () {
      test('returns inactivityDay1 (3) when currentDay is null', () {
        expect(NotificationConfig.getNextInactivityDay(null), 3);
      });

      test('returns inactivityDay2 (7) when currentDay is 3', () {
        expect(NotificationConfig.getNextInactivityDay(3), 7);
      });

      test('returns inactivityDay3 (14) when currentDay is 7', () {
        expect(NotificationConfig.getNextInactivityDay(7), 14);
      });

      test('returns null (sequence exhausted) when currentDay is 14', () {
        expect(NotificationConfig.getNextInactivityDay(14), isNull);
      });

      test('returns null when currentDay is not in sequence', () {
        // Unknown day → sequence exhausted / not found.
        expect(NotificationConfig.getNextInactivityDay(99), isNull);
      });
    });

    group('isStreakMilestone', () {
      test('returns true for all defined milestones', () {
        for (final milestone in NotificationConfig.streakMilestones) {
          expect(
            NotificationConfig.isStreakMilestone(milestone),
            isTrue,
            reason: 'Expected $milestone to be a streak milestone',
          );
        }
      });

      test('returns false for a day between milestones', () {
        expect(NotificationConfig.isStreakMilestone(8), isFalse);
        expect(NotificationConfig.isStreakMilestone(1), isFalse);
        expect(NotificationConfig.isStreakMilestone(100), isFalse);
      });

      test('returns false for 0 days', () {
        expect(NotificationConfig.isStreakMilestone(0), isFalse);
      });

      test('returns true for 365 days (one year)', () {
        expect(NotificationConfig.isStreakMilestone(365), isTrue);
      });
    });
  });
}

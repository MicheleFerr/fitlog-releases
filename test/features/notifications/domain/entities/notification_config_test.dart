library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_config.dart';

void main() {
  group('NotificationConfig constants', () {
    test('globalCooldown is 24 hours', () {
      expect(
        NotificationConfig.globalCooldown,
        const Duration(hours: 24),
      );
    });

    test('maxNotificationsPerWeek is 3', () {
      expect(NotificationConfig.maxNotificationsPerWeek, 3);
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

    test('maxScheduledNotifications is 10', () {
      expect(NotificationConfig.maxScheduledNotifications, 10);
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

    test('inactivitySequence is [3, 7, 14]', () {
      expect(NotificationConfig.inactivitySequence, [3, 7, 14]);
    });

    test('prNotificationDelay is 20 minutes', () {
      expect(
        NotificationConfig.prNotificationDelay,
        const Duration(minutes: 20),
      );
    });

    test('streakMilestones contains expected values', () {
      expect(
        NotificationConfig.streakMilestones,
        [7, 14, 30, 60, 90, 180, 365],
      );
    });

    test('volumeIncreaseThreshold is 0.20', () {
      expect(NotificationConfig.volumeIncreaseThreshold, 0.20);
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
  });

  group('NotificationConfig.isQuietHours', () {
    test('returns true at 22:00 (start of quiet hours)', () {
      final dt = DateTime(2026, 1, 15, 22, 0);
      expect(NotificationConfig.isQuietHours(dt), isTrue);
    });

    test('returns true at 23:30 (late night)', () {
      final dt = DateTime(2026, 1, 15, 23, 30);
      expect(NotificationConfig.isQuietHours(dt), isTrue);
    });

    test('returns true at 00:00 (midnight)', () {
      final dt = DateTime(2026, 1, 15, 0, 0);
      expect(NotificationConfig.isQuietHours(dt), isTrue);
    });

    test('returns true at 03:00 (early morning)', () {
      final dt = DateTime(2026, 1, 15, 3, 0);
      expect(NotificationConfig.isQuietHours(dt), isTrue);
    });

    test('returns true at 07:59 (just before quiet hours end)', () {
      final dt = DateTime(2026, 1, 15, 7, 59);
      expect(NotificationConfig.isQuietHours(dt), isTrue);
    });

    test('returns false at 08:00 (quiet hours end)', () {
      final dt = DateTime(2026, 1, 15, 8, 0);
      expect(NotificationConfig.isQuietHours(dt), isFalse);
    });

    test('returns false at 12:00 (midday)', () {
      final dt = DateTime(2026, 1, 15, 12, 0);
      expect(NotificationConfig.isQuietHours(dt), isFalse);
    });

    test('returns false at 18:00 (evening)', () {
      final dt = DateTime(2026, 1, 15, 18, 0);
      expect(NotificationConfig.isQuietHours(dt), isFalse);
    });

    test('returns false at 21:59 (just before quiet hours start)', () {
      final dt = DateTime(2026, 1, 15, 21, 59);
      expect(NotificationConfig.isQuietHours(dt), isFalse);
    });
  });

  group('NotificationConfig.getNextAvailableTime', () {
    test('returns same time when NOT in quiet hours', () {
      final dt = DateTime(2026, 1, 15, 14, 30);
      expect(NotificationConfig.getNextAvailableTime(dt), dt);
    });

    test('returns next day 09:00 when after 22:00', () {
      final dt = DateTime(2026, 1, 15, 22, 30);
      final result = NotificationConfig.getNextAvailableTime(dt);
      expect(result, DateTime(2026, 1, 16, 9, 0));
    });

    test('returns today 09:00 when before 08:00', () {
      final dt = DateTime(2026, 1, 15, 5, 30);
      final result = NotificationConfig.getNextAvailableTime(dt);
      expect(result, DateTime(2026, 1, 15, 9, 0));
    });

    test('returns today 09:00 at midnight', () {
      final dt = DateTime(2026, 1, 15, 0, 0);
      final result = NotificationConfig.getNextAvailableTime(dt);
      expect(result, DateTime(2026, 1, 15, 9, 0));
    });

    test('returns same time at 08:00 boundary', () {
      final dt = DateTime(2026, 1, 15, 8, 0);
      expect(NotificationConfig.getNextAvailableTime(dt), dt);
    });
  });

  group('NotificationConfig.getNextInactivityDay', () {
    test('returns 3 when currentDay is null (first in sequence)', () {
      expect(NotificationConfig.getNextInactivityDay(null), 3);
    });

    test('returns 7 when currentDay is 3', () {
      expect(NotificationConfig.getNextInactivityDay(3), 7);
    });

    test('returns 14 when currentDay is 7', () {
      expect(NotificationConfig.getNextInactivityDay(7), 14);
    });

    test('returns null when currentDay is 14 (sequence exhausted)', () {
      expect(NotificationConfig.getNextInactivityDay(14), isNull);
    });

    test('returns null when currentDay is not in sequence', () {
      expect(NotificationConfig.getNextInactivityDay(5), isNull);
    });

    test('returns null when currentDay is 99 (unknown value)', () {
      expect(NotificationConfig.getNextInactivityDay(99), isNull);
    });
  });

  group('NotificationConfig.isStreakMilestone', () {
    test('returns true for all milestone values', () {
      for (final milestone in [7, 14, 30, 60, 90, 180, 365]) {
        expect(
          NotificationConfig.isStreakMilestone(milestone),
          isTrue,
          reason: '$milestone should be a milestone',
        );
      }
    });

    test('returns false for non-milestone values', () {
      for (final nonMilestone in [1, 2, 5, 10, 15, 20, 50, 100, 200]) {
        expect(
          NotificationConfig.isStreakMilestone(nonMilestone),
          isFalse,
          reason: '$nonMilestone should not be a milestone',
        );
      }
    });

    test('returns false for 0', () {
      expect(NotificationConfig.isStreakMilestone(0), isFalse);
    });

    test('returns false for negative values', () {
      expect(NotificationConfig.isStreakMilestone(-7), isFalse);
    });
  });
}

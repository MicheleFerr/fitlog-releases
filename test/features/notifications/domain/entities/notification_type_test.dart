library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_type.dart';

void main() {
  group('NotificationType', () {
    test('has 5 values', () {
      expect(NotificationType.values, hasLength(5));
    });

    test('values are in expected order', () {
      expect(NotificationType.values, [
        NotificationType.workoutForgotten,
        NotificationType.inactivity,
        NotificationType.insightPr,
        NotificationType.insightStreak,
        NotificationType.insightVolume,
      ]);
    });
  });

  group('NotificationTypeX.channelId', () {
    test('workoutForgotten returns workout_reminder', () {
      expect(NotificationType.workoutForgotten.channelId, 'workout_reminder');
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

  group('NotificationTypeX.channelName', () {
    test('workoutForgotten returns Workout Reminders', () {
      expect(
        NotificationType.workoutForgotten.channelName,
        'Workout Reminders',
      );
    });

    test('inactivity returns Inactivity Reminders', () {
      expect(
        NotificationType.inactivity.channelName,
        'Inactivity Reminders',
      );
    });

    test('insight types return Insights & Achievements', () {
      expect(
        NotificationType.insightPr.channelName,
        'Insights & Achievements',
      );
      expect(
        NotificationType.insightStreak.channelName,
        'Insights & Achievements',
      );
      expect(
        NotificationType.insightVolume.channelName,
        'Insights & Achievements',
      );
    });
  });

  group('NotificationTypeX.channelDescription', () {
    test('each type has a non-empty description', () {
      for (final type in NotificationType.values) {
        expect(type.channelDescription, isNotEmpty, reason: type.name);
      }
    });

    test('workoutForgotten description mentions active workout', () {
      expect(
        NotificationType.workoutForgotten.channelDescription,
        contains('active workout'),
      );
    });

    test('inactivity description mentions haven\'t worked out', () {
      expect(
        NotificationType.inactivity.channelDescription,
        contains("haven't worked out"),
      );
    });
  });

  group('NotificationTypeX.deepLinkPath', () {
    test('workoutForgotten links to /workout', () {
      expect(NotificationType.workoutForgotten.deepLinkPath, '/workout');
    });

    test('inactivity links to /', () {
      expect(NotificationType.inactivity.deepLinkPath, '/');
    });

    test('insightPr links to /stats', () {
      expect(NotificationType.insightPr.deepLinkPath, '/stats');
    });

    test('insightStreak links to /stats', () {
      expect(NotificationType.insightStreak.deepLinkPath, '/stats');
    });

    test('insightVolume links to /stats', () {
      expect(NotificationType.insightVolume.deepLinkPath, '/stats');
    });
  });

  group('NotificationTypeX.isHighValue', () {
    test('workoutForgotten is high value', () {
      expect(NotificationType.workoutForgotten.isHighValue, isTrue);
    });

    test('insightPr is high value', () {
      expect(NotificationType.insightPr.isHighValue, isTrue);
    });

    test('inactivity is NOT high value', () {
      expect(NotificationType.inactivity.isHighValue, isFalse);
    });

    test('insightStreak is NOT high value', () {
      expect(NotificationType.insightStreak.isHighValue, isFalse);
    });

    test('insightVolume is NOT high value', () {
      expect(NotificationType.insightVolume.isHighValue, isFalse);
    });
  });

  group('NotificationTypeX.maxIgnoreCount', () {
    test('workoutForgotten has max 1', () {
      expect(NotificationType.workoutForgotten.maxIgnoreCount, 1);
    });

    test('inactivity has max 3', () {
      expect(NotificationType.inactivity.maxIgnoreCount, 3);
    });

    test('insight types have max 5', () {
      expect(NotificationType.insightPr.maxIgnoreCount, 5);
      expect(NotificationType.insightStreak.maxIgnoreCount, 5);
      expect(NotificationType.insightVolume.maxIgnoreCount, 5);
    });

    test('all values are positive', () {
      for (final type in NotificationType.values) {
        expect(type.maxIgnoreCount, greaterThan(0), reason: type.name);
      }
    });
  });
}

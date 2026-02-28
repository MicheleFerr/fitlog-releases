library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/notifications/data/datasources/local_notification_datasource.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_type.dart';

/// Tests only the pure logic of LocalNotificationDatasource.
/// Plugin-dependent methods (initialize, scheduleNotification, showNotification,
/// cancelNotification, etc.) require the flutter_local_notifications plugin
/// which needs native platform bindings — not testable in pure unit tests.
void main() {
  late LocalNotificationDatasource datasource;

  setUp(() {
    datasource = LocalNotificationDatasource();
  });

  group('generateNotificationId', () {
    test('generates ID in workoutForgotten range (1000-1099)', () {
      final id = datasource.generateNotificationId(
        NotificationType.workoutForgotten,
      );
      expect(id, greaterThanOrEqualTo(1000));
      expect(id, lessThan(1100));
    });

    test('generates ID in inactivity range (2000-2099)', () {
      final id = datasource.generateNotificationId(
        NotificationType.inactivity,
      );
      expect(id, greaterThanOrEqualTo(2000));
      expect(id, lessThan(2100));
    });

    test('generates ID in insightPr range (3000-3099)', () {
      final id = datasource.generateNotificationId(
        NotificationType.insightPr,
      );
      expect(id, greaterThanOrEqualTo(3000));
      expect(id, lessThan(3100));
    });

    test('generates ID in insightStreak range (4000-4099)', () {
      final id = datasource.generateNotificationId(
        NotificationType.insightStreak,
      );
      expect(id, greaterThanOrEqualTo(4000));
      expect(id, lessThan(4100));
    });

    test('generates ID in insightVolume range (5000-5099)', () {
      final id = datasource.generateNotificationId(
        NotificationType.insightVolume,
      );
      expect(id, greaterThanOrEqualTo(5000));
      expect(id, lessThan(5100));
    });

    test('each type generates different ID ranges', () {
      final ids = NotificationType.values
          .map((t) => datasource.generateNotificationId(t))
          .toList();

      // Each ID should fall in a different 1000-range bucket
      final buckets = ids.map((id) => id ~/ 1000).toSet();
      expect(buckets, hasLength(NotificationType.values.length));
    });
  });
}

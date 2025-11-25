import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/usecases/schedule_workout_reminders.dart';

void main() {
  late ScheduleWorkoutReminders usecase;

  setUp(() {
    usecase = ScheduleWorkoutReminders();
  });

  group('ScheduleWorkoutReminders', () {
    test('should return notification times for user with no recent workout', () {
      // Arrange
      final now = DateTime(2025, 1, 15, 9, 0); // 9 AM
      final lastWorkoutDate = now.subtract(const Duration(days: 3));

      // Act
      final result = usecase.execute(
        lastWorkoutDate: lastWorkoutDate,
        lastNotificationDate: null,
        currentTime: now,
        preferredNotificationHour: 18, // 6 PM
      );

      // Assert
      expect(result.shouldSchedule, true);
      expect(result.scheduledTime.hour, 18);
      expect(result.scheduledTime.day, now.day);
    });

    test('should NOT schedule if user already worked out today', () {
      // Arrange
      final now = DateTime(2025, 1, 15, 10, 0);
      final lastWorkoutDate = now.subtract(const Duration(hours: 2));

      // Act
      final result = usecase.execute(
        lastWorkoutDate: lastWorkoutDate,
        lastNotificationDate: null,
        currentTime: now,
        preferredNotificationHour: 18,
      );

      // Assert
      expect(result.shouldSchedule, false);
      expect(result.reason, contains('Already worked out today'));
    });

    test('should schedule for tomorrow if preferred time already passed today', () {
      // Arrange
      final now = DateTime(2025, 1, 15, 19, 0); // 7 PM
      final lastWorkoutDate = now.subtract(const Duration(days: 2));

      // Act
      final result = usecase.execute(
        lastWorkoutDate: lastWorkoutDate,
        lastNotificationDate: null,
        currentTime: now,
        preferredNotificationHour: 18, // 6 PM (already passed)
      );

      // Assert
      expect(result.shouldSchedule, true);
      expect(result.scheduledTime.day, now.day + 1); // Tomorrow
      expect(result.scheduledTime.hour, 18);
    });

    test('should use notification rules engine for decision logic', () {
      // Arrange
      final now = DateTime(2025, 1, 15, 12, 0);
      final lastWorkoutDate = now.subtract(const Duration(days: 5));
      final lastNotificationDate = now.subtract(const Duration(hours: 12));

      // Act
      final result = usecase.execute(
        lastWorkoutDate: lastWorkoutDate,
        lastNotificationDate: lastNotificationDate,
        currentTime: now,
        preferredNotificationHour: 17,
      );

      // Assert - Should delegate to CheckNotificationRules
      expect(result.shouldSchedule, false);
      expect(result.reason, contains('Already notified today'));
    });
  });
}

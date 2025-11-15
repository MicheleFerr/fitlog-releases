import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/usecases/check_notification_rules.dart';

void main() {
  late CheckNotificationRules usecase;

  setUp(() {
    usecase = CheckNotificationRules();
  });

  group('CheckNotificationRules', () {
    test('should allow notification if no recent workouts', () {
      // Arrange
      final lastWorkoutDate = DateTime.now().subtract(const Duration(days: 3));
      final lastNotificationDate = DateTime.now().subtract(const Duration(days: 2));

      // Act
      final result = usecase.execute(
        lastWorkoutDate: lastWorkoutDate,
        lastNotificationDate: lastNotificationDate,
        currentDate: DateTime.now(),
      );

      // Assert
      expect(result.shouldNotify, true);
      expect(result.reason, contains('48+ hours since last workout'));
    });

    test('should NOT allow notification if user worked out today', () {
      // Arrange
      final today = DateTime.now();
      final lastWorkoutDate = today.subtract(const Duration(hours: 2));
      final lastNotificationDate = today.subtract(const Duration(days: 1));

      // Act
      final result = usecase.execute(
        lastWorkoutDate: lastWorkoutDate,
        lastNotificationDate: lastNotificationDate,
        currentDate: today,
      );

      // Assert
      expect(result.shouldNotify, false);
      expect(result.reason, contains('Already worked out today'));
    });

    test('should NOT allow notification if already notified today', () {
      // Arrange
      final today = DateTime.now();
      final lastWorkoutDate = today.subtract(const Duration(days: 2));
      final lastNotificationDate = today.subtract(const Duration(hours: 5));

      // Act
      final result = usecase.execute(
        lastWorkoutDate: lastWorkoutDate,
        lastNotificationDate: lastNotificationDate,
        currentDate: today,
      );

      // Assert
      expect(result.shouldNotify, false);
      expect(result.reason, contains('Already notified today'));
    });

    test('should allow notification if 48+ hours since last workout', () {
      // Arrange
      final now = DateTime.now();
      final lastWorkoutDate = now.subtract(const Duration(hours: 49));
      final lastNotificationDate = now.subtract(const Duration(days: 3));

      // Act
      final result = usecase.execute(
        lastWorkoutDate: lastWorkoutDate,
        lastNotificationDate: lastNotificationDate,
        currentDate: now,
      );

      // Assert
      expect(result.shouldNotify, true);
      expect(result.reason, contains('48+ hours since last workout'));
    });

    test('should NOT spam if notified less than 24 hours ago', () {
      // Arrange
      final now = DateTime.now();
      final lastWorkoutDate = now.subtract(const Duration(days: 3));
      final lastNotificationDate = now.subtract(const Duration(hours: 12));

      // Act
      final result = usecase.execute(
        lastWorkoutDate: lastWorkoutDate,
        lastNotificationDate: lastNotificationDate,
        currentDate: now,
      );

      // Assert
      expect(result.shouldNotify, false);
      expect(result.reason, contains('Already notified today'));
    });
  });
}

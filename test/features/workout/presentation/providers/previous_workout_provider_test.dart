import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/previous_workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

void main() {
  group('WeightRecoveryData', () {
    test('should create from null workout with hasData=false', () {
      final data = WeightRecoveryData.fromWorkout(null);

      expect(data.hasData, isFalse);
      expect(data.daysSinceLastSession, equals(0));
      expect(data.previousWorkout, isNull);
      expect(data.lastSessionDate, isNull);
    });

    test('should create from workout with null endTime with hasData=false', () {
      final workout = Workout(
        id: 'workout-1',
        name: 'Test Workout',
        exercises: [],
        startTime: DateTime.now(),
        endTime: null, // null endTime
        status: WorkoutStatus.completed,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final data = WeightRecoveryData.fromWorkout(workout);

      expect(data.hasData, isFalse);
      expect(data.daysSinceLastSession, equals(0));
      expect(data.previousWorkout, isNull);
      expect(data.lastSessionDate, isNull);
    });

    test('should create from valid workout with hasData=true and calculate days', () {
      final endTime = DateTime.now().subtract(const Duration(days: 5));
      final workout = Workout(
        id: 'workout-1',
        name: 'Test Workout',
        exercises: [],
        startTime: DateTime.now(),
        endTime: endTime,
        status: WorkoutStatus.completed,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final data = WeightRecoveryData.fromWorkout(workout);

      expect(data.hasData, isTrue);
      expect(data.daysSinceLastSession, equals(5)); // 5 days ago
      expect(data.previousWorkout, equals(workout));
      expect(data.lastSessionDate, equals(endTime));
    });

    test('should handle workout from today (0 days)', () {
      final endTime = DateTime.now();
      final workout = Workout(
        id: 'workout-1',
        name: 'Test Workout',
        exercises: [],
        startTime: DateTime.now(),
        endTime: endTime,
        status: WorkoutStatus.completed,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final data = WeightRecoveryData.fromWorkout(workout);

      expect(data.hasData, isTrue);
      expect(data.daysSinceLastSession, equals(0)); // Today
      expect(data.previousWorkout, equals(workout));
    });

    test('should handle workout from many days ago', () {
      final endTime = DateTime.now().subtract(const Duration(days: 30));
      final workout = Workout(
        id: 'workout-1',
        name: 'Test Workout',
        exercises: [],
        startTime: DateTime.now(),
        endTime: endTime,
        status: WorkoutStatus.completed,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final data = WeightRecoveryData.fromWorkout(workout);

      expect(data.hasData, isTrue);
      expect(data.daysSinceLastSession, equals(30));
      expect(data.previousWorkout, equals(workout));
    });

    test('should create with direct constructor (all fields)', () {
      final endTime = DateTime.now().subtract(const Duration(days: 3));
      final workout = Workout(
        id: 'workout-1',
        name: 'Test Workout',
        exercises: [],
        startTime: DateTime.now(),
        endTime: endTime,
        status: WorkoutStatus.completed,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final data = WeightRecoveryData(
        previousWorkout: workout,
        lastSessionDate: endTime,
        daysSinceLastSession: 3,
        hasData: true,
      );

      expect(data.hasData, isTrue);
      expect(data.daysSinceLastSession, equals(3));
      expect(data.previousWorkout, equals(workout));
      expect(data.lastSessionDate, equals(endTime));
    });

    test('should create with direct constructor (minimal fields)', () {
      final data = WeightRecoveryData(
        daysSinceLastSession: 0,
        hasData: false,
      );

      expect(data.hasData, isFalse);
      expect(data.daysSinceLastSession, equals(0));
      expect(data.previousWorkout, isNull);
      expect(data.lastSessionDate, isNull);
    });
  });
}

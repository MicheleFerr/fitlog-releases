import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

void main() {
  group('WorkoutMetrics', () {
    test('should calculate correct total volume', () {
      // Arrange
      final sets = [
        ExerciseSet(
          setNumber: 1,
          weight: 100,
          reps: 10,
          isCompleted: true,
        ),
        ExerciseSet(
          setNumber: 2,
          weight: 100,
          reps: 8,
          isCompleted: true,
        ),
        ExerciseSet(
          setNumber: 3,
          weight: 90,
          reps: 10,
          isCompleted: true,
        ),
      ];

      final exercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: sets,
      );

      final workout = Workout(
        name: 'Chest Day',
        exercises: [exercise],
        status: WorkoutStatus.inProgress,
        startTime: DateTime.now().subtract(const Duration(minutes: 30)),
      );

      // Act
      final metrics = WorkoutMetrics.fromWorkout(workout);

      // Assert
      expect(metrics.totalVolume, equals(2700)); // (100*10) + (100*8) + (90*10)
      expect(metrics.completedSets, equals(3));
      expect(metrics.totalSets, equals(3));
    });

    test('should calculate correct training density', () {
      // Arrange
      final exercise = Exercise(
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 100,
            reps: 10,
            isCompleted: true,
          ),
        ],
      );

      final workout = Workout(
        name: 'Leg Day',
        exercises: [exercise],
        status: WorkoutStatus.inProgress,
        startTime: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      // Act
      final metrics = WorkoutMetrics.fromWorkout(workout);

      // Assert
      expect(metrics.trainingDensity, equals(100)); // 1000kg / 10 minutes
    });

    test('should identify strong workout', () {
      // Arrange
      final sets = List.generate(
        10,
        (index) => ExerciseSet(
          setNumber: index + 1,
          weight: 100,
          reps: 10,
          isCompleted: true,
          rpe: 8,
        ),
      );

      final exercise = Exercise(
        name: 'Deadlift',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
        sets: sets,
      );

      final workout = Workout(
        name: 'Back Day',
        exercises: [exercise],
        status: WorkoutStatus.inProgress,
        startTime: DateTime.now().subtract(const Duration(minutes: 40)),
      );

      // Act
      final metrics = WorkoutMetrics.fromWorkout(workout);

      // Assert
      expect(metrics.totalVolume, equals(10000)); // 10 sets * 100kg * 10 reps
      expect(metrics.averageRPE, equals(8));
      expect(metrics.isStrongWorkout, isTrue);
    });

    test('should calculate quality score correctly', () {
      // Arrange
      final exercise = Exercise(
        name: 'Pull-ups',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 0,
            reps: 10,
            isCompleted: true,
            rpe: 7,
          ),
          ExerciseSet(
            setNumber: 2,
            weight: 0,
            reps: 8,
            isCompleted: true,
            rpe: 8,
          ),
        ],
      );

      final workout = Workout(
        name: 'Pull Day',
        exercises: [exercise],
        status: WorkoutStatus.inProgress,
        startTime: DateTime.now().subtract(const Duration(minutes: 20)),
      );

      // Act
      final metrics = WorkoutMetrics.fromWorkout(workout);
      final qualityScore = metrics.qualityScore;

      // Assert
      expect(qualityScore, greaterThanOrEqualTo(0));
      expect(qualityScore, lessThanOrEqualTo(100));
    });

    test('should handle empty workout correctly', () {
      // Arrange
      final workout = Workout(
        name: 'Empty Workout',
        exercises: [],
        status: WorkoutStatus.planned,
      );

      // Act
      final metrics = WorkoutMetrics.fromWorkout(workout);

      // Assert
      expect(metrics.totalVolume, equals(0));
      expect(metrics.completedSets, equals(0));
      expect(metrics.averageRPE, equals(0));
      expect(metrics.qualityScore, equals(0));
    });

    test('should format metrics correctly', () {
      // Arrange
      final exercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 100.5,
            reps: 10,
            isCompleted: true,
          ),
        ],
      );

      final workout = Workout(
        name: 'Test Workout',
        exercises: [exercise],
        status: WorkoutStatus.inProgress,
        startTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      );

      // Act
      final metrics = WorkoutMetrics.fromWorkout(workout);

      // Assert
      expect(metrics.formattedVolume, equals('1005 kg'));
      expect(metrics.formattedDuration, equals('1h 15m'));
      expect(metrics.formattedDensity, matches(RegExp(r'\d+\.\d kg/min')));
    });

    test('should group volume by muscle correctly', () {
      // Arrange
      final chestExercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 100,
            reps: 10,
            isCompleted: true,
          ),
        ],
      );

      final backExercise = Exercise(
        name: 'Deadlift',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 150,
            reps: 5,
            isCompleted: true,
          ),
        ],
      );

      final workout = Workout(
        name: 'Upper Body',
        exercises: [chestExercise, backExercise],
        status: WorkoutStatus.inProgress,
        startTime: DateTime.now().subtract(const Duration(minutes: 45)),
      );

      // Act
      final metrics = WorkoutMetrics.fromWorkout(workout);

      // Assert
      expect(metrics.volumeByMuscleGroup[ExerciseCategory.chest], equals(1000));
      expect(metrics.volumeByMuscleGroup[ExerciseCategory.back], equals(750));
    });
  });
}
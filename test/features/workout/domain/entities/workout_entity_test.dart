import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
// ExerciseSet is defined in exercise.dart

void main() {
  group('Workout Entity Tests', () {
    test('creates workout with required fields', () {
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Morning Workout',
      );

      expect(workout.id, isNotEmpty);
      expect(workout.name, 'Morning Workout');
      expect(workout.exercises, isEmpty);
      expect(workout.endTime, isNull);
      expect(workout.status, WorkoutStatus.planned);
      expect(workout.isActive, false); // planned status means not active
    });

    test('creates in-progress workout', () {
      final startTime = DateTime(2024, 1, 1, 9, 0);
      
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Active Workout',
        status: WorkoutStatus.inProgress,
        startTime: startTime,
      );

      expect(workout.status, WorkoutStatus.inProgress);
      expect(workout.startTime, startTime);
      expect(workout.isActive, true);
      expect(workout.isCompleted, false);
    });

    test('creates completed workout', () {
      final startTime = DateTime(2024, 1, 1, 9, 0);
      final endTime = DateTime(2024, 1, 1, 10, 30);
      
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Completed Workout',
        status: WorkoutStatus.completed,
        startTime: startTime,
        endTime: endTime,
      );

      expect(workout.status, WorkoutStatus.completed);
      expect(workout.endTime, endTime);
      expect(workout.isActive, false);
      expect(workout.isCompleted, true);
    });

    test('calculates workout duration', () {
      final startTime = DateTime(2024, 1, 1, 9, 0);
      final endTime = DateTime(2024, 1, 1, 10, 30);
      
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Test',
        startTime: startTime,
        endTime: endTime,
      );

      final duration = workout.duration;
      expect(duration, isNotNull);
      expect(duration!.inMinutes, 90);
      expect(duration.inHours, 1);
    });

    test('calculates total sets correctly', () {
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Set Count Test',
        exercises: [
          Exercise(
            name: 'Bench Press',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [
              ExerciseSet(setNumber: 1, weight: 60, reps: 10),
              ExerciseSet(setNumber: 2, weight: 65, reps: 8),
            ],
          ),
          Exercise(
            name: 'Squats',
            type: ExerciseType.single,
            category: ExerciseCategory.legs,
            sets: [
              ExerciseSet(setNumber: 1, weight: 80, reps: 10),
            ],
          ),
        ],
      );

      expect(workout.totalSets, 3);
      expect(workout.completedSets, 0); // None are completed yet
    });

    test('calculates completed sets correctly', () {
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Completed Sets Test',
        exercises: [
          Exercise(
            name: 'Bench Press',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [
              ExerciseSet(setNumber: 1, weight: 60, reps: 10, isCompleted: true),
              ExerciseSet(setNumber: 2, weight: 65, reps: 8, isCompleted: false),
            ],
          ),
          Exercise(
            name: 'Squats',
            type: ExerciseType.single,
            category: ExerciseCategory.legs,
            sets: [
              ExerciseSet(setNumber: 1, weight: 80, reps: 10, isCompleted: true),
            ],
          ),
        ],
      );

      expect(workout.totalSets, 3);
      expect(workout.completedSets, 2);
      expect(workout.progressPercentage, closeTo(0.67, 0.01));
    });

    test('calculates completed exercises correctly', () {
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Exercise Completion Test',
        exercises: [
          Exercise(
            name: 'Bench Press',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [
              ExerciseSet(setNumber: 1, weight: 60, reps: 10, isCompleted: true),
              ExerciseSet(setNumber: 2, weight: 65, reps: 8, isCompleted: true),
            ],
          ),
          Exercise(
            name: 'Squats',
            type: ExerciseType.single,
            category: ExerciseCategory.legs,
            sets: [
              ExerciseSet(setNumber: 1, weight: 80, reps: 10, isCompleted: false),
            ],
          ),
        ],
      );

      expect(workout.completedExercises, 1); // Only bench press fully completed
    });

    test('copyWith creates new instance with updated values', () {
      final original = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Original',
        status: WorkoutStatus.planned,
      );

      final modified = original.copyWith(
        name: 'Modified',
        status: WorkoutStatus.inProgress,
        startTime: DateTime(2024, 1, 1, 9, 0),
      );

      expect(original.name, 'Original');
      expect(original.status, WorkoutStatus.planned);
      expect(modified.name, 'Modified');
      expect(modified.status, WorkoutStatus.inProgress);
      expect(modified.startTime, DateTime(2024, 1, 1, 9, 0));
      expect(modified.id, original.id); // ID should remain same
    });

    test('addExercise updates exercises list', () {
      final workout = Workout(
      id: 'test-id',
        name: 'Test',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final exercise = Exercise(
        name: 'Push-ups',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      final updated = workout.addExercise(exercise);

      expect(workout.exercises, isEmpty); // Original unchanged
      expect(updated.exercises.length, 1);
      expect(updated.exercises.first.name, 'Push-ups');
    });

    test('removeExercise updates exercises list', () {
      final exercise = Exercise(
        name: 'Push-ups',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );
      
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Test',
        exercises: [exercise],
      );

      final updated = workout.removeExercise(exercise.id);

      expect(workout.exercises.length, 1); // Original unchanged
      expect(updated.exercises, isEmpty);
    });

    test('toJson serialization', () {
      final startTime = DateTime(2024, 1, 1, 9, 0);
      final endTime = DateTime(2024, 1, 1, 10, 30);
      
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'Serialization Test',
        status: WorkoutStatus.completed,
        startTime: startTime,
        endTime: endTime,
        notes: 'Great workout!',
        exercises: [
          Exercise(
            name: 'Bench Press',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [
              ExerciseSet(setNumber: 1, weight: 60, reps: 10),
            ],
          ),
        ],
      );

      final json = workout.toJson();

      expect(json['name'], 'Serialization Test');
      expect(json['status'], 'completed');
      expect(json['startTime'], startTime.toIso8601String());
      expect(json['endTime'], endTime.toIso8601String());
      expect(json['notes'], 'Great workout!');
      expect(json['exercises'], hasLength(1));
    });

    test('fromJson deserialization', () {
      final startTime = DateTime(2024, 1, 1, 9, 0);
      final endTime = DateTime(2024, 1, 1, 10, 30);
      
      final json = {
        'id': 'workout-123',
        'name': 'Deserialization Test',
        'status': 'inProgress',
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'notes': 'Test notes',
        'exercises': [
          {
            'id': 'ex-1',
            'name': 'Push-ups',
            'type': 'single',
            'category': 'chest',
            'sets': [
              {
                'id': 'set-1',
                'setNumber': 1,
                'weight': 0.0,
                'reps': 20,
                'isCompleted': false,
              }
            ],
            'createdAt': DateTime(2024, 1, 1).toIso8601String(),
            'updatedAt': DateTime(2024, 1, 2).toIso8601String(),
          }
        ],
        'createdAt': DateTime(2024, 1, 1).toIso8601String(),
        'updatedAt': DateTime(2024, 1, 2).toIso8601String(),
      };

      final workout = Workout.fromJson(json);

      expect(workout.id, 'workout-123');
      expect(workout.name, 'Deserialization Test');
      expect(workout.status, WorkoutStatus.inProgress);
      expect(workout.startTime, startTime);
      expect(workout.endTime, endTime);
      expect(workout.notes, 'Test notes');
      expect(workout.exercises.length, 1);
      expect(workout.exercises.first.name, 'Push-ups');
    });

    test('workout identity and copyWith', () {
      final workout1 = Workout(
      id: 'test-id-1',
        name: 'Test',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final workout2 = Workout(
      id: 'test-id-2',
        name: 'Test',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final workout3 = workout1.copyWith();

      expect(workout1 == workout2, false); // Different objects
      expect(workout1 == workout3, false); // copyWith creates new object
      expect(workout1 == workout1, true); // Same object reference
      expect(workout3.name, workout1.name); // copyWith preserves values
      expect(workout3.id, workout1.id); // copyWith preserves ID
    });

    test('workout with RPE tracking', () {
      final workout = Workout(
      id: 'test-id',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        name: 'RPE Test',
        exercises: [
          Exercise(
            name: 'Bench Press',
            type: ExerciseType.single,
            category: ExerciseCategory.chest,
            sets: [
              ExerciseSet(
                setNumber: 1,
                weight: 60,
                reps: 10,
                rpe: 7, // RPE value
                isCompleted: true,
              ),
            ],
          ),
        ],
      );

      final exercise = workout.exercises.first;
      final set = exercise.sets.first;
      
      expect(set.rpe, 7);
      expect(set.isCompleted, true);
    });
  });
}
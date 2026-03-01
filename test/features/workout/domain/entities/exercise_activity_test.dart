/// ExerciseActivity and ExerciseActivitySet entity tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

void main() {
  group('ExerciseActivitySet', () {
    test('constructor', () {
      final actSet = ExerciseActivitySet(
        set: 1,
        weight: '80',
        reps: '10',
        done: true,
        effort: 3,
      );
      expect(actSet.set, 1);
      expect(actSet.weight, '80');
      expect(actSet.reps, '10');
      expect(actSet.done, true);
      expect(actSet.effort, 3);
      expect(actSet.isWarmup, false);
    });

    test('fromFirestore with all fields', () {
      final data = {
        'set': 1,
        'weight': 80,
        'reps': 10,
        'actualReps': '12',
        'rpe': 8,
        'rir': 2,
        'done': true,
        'effort': 4,
        'setDurationMillis': 45000.0,
        'isWarmup': true,
      };
      final actSet = ExerciseActivitySet.fromFirestore(data);
      expect(actSet.set, 1);
      expect(actSet.weight, '80');
      expect(actSet.reps, '10');
      expect(actSet.actualReps, '12');
      expect(actSet.rpe, 8);
      expect(actSet.rir, 2);
      expect(actSet.done, true);
      expect(actSet.effort, 4);
      expect(actSet.setDurationMillis, 45000.0);
      expect(actSet.isWarmup, true);
    });

    test('fromFirestore with null values', () {
      final data = <String, dynamic>{};
      final actSet = ExerciseActivitySet.fromFirestore(data);
      expect(actSet.set, 0);
      expect(actSet.weight, '0');
      expect(actSet.reps, '0');
      expect(actSet.actualReps, isNull);
      expect(actSet.rpe, isNull);
      expect(actSet.done, false);
      expect(actSet.effort, 3);
      expect(actSet.isWarmup, false);
    });

    test('fromFirestore handles String int values', () {
      final data = {
        'set': '3',
        'weight': '75.5',
        'reps': '8',
        'rpe': '9',
        'effort': '4',
        'done': true,
      };
      final actSet = ExerciseActivitySet.fromFirestore(data);
      expect(actSet.set, 3);
      expect(actSet.rpe, 9);
      expect(actSet.effort, 4);
    });

    test('fromFirestore handles double int values', () {
      final data = {
        'set': 2.0,
        'weight': 80,
        'reps': 10,
        'done': true,
        'effort': 3.0,
        'setDurationMillis': 30000,
      };
      final actSet = ExerciseActivitySet.fromFirestore(data);
      expect(actSet.set, 2);
      expect(actSet.effort, 3);
      expect(actSet.setDurationMillis, 30000.0);
    });

    test('toFirestore', () {
      final actSet = ExerciseActivitySet(
        set: 1,
        weight: '80',
        reps: '10',
        actualReps: '9',
        rpe: 8,
        rir: 2,
        done: true,
        effort: 4,
        setDurationMillis: 30000.0,
        isWarmup: true,
      );
      final data = actSet.toFirestore();
      expect(data['set'], 1);
      expect(data['weight'], '80');
      expect(data['reps'], '10');
      expect(data['actualReps'], '9');
      expect(data['rpe'], 8);
      expect(data['rir'], 2);
      expect(data['done'], true);
      expect(data['effort'], 4);
      expect(data['isWarmup'], true);
    });

    test('copyWith', () {
      final original = ExerciseActivitySet(
        set: 1,
        weight: '80',
        reps: '10',
        done: false,
        effort: 3,
      );
      final copy = original.copyWith(done: true, effort: 5);
      expect(copy.done, true);
      expect(copy.effort, 5);
      expect(copy.set, 1);
      expect(copy.weight, '80');
    });
  });

  group('ExerciseActivity', () {
    test('fromExercise with completed sets', () {
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, weight: 80.0, reps: 10, isCompleted: true, rpe: 8),
          ExerciseSet(setNumber: 2, weight: 80.0, reps: 8, isCompleted: true),
          ExerciseSet(setNumber: 3, weight: 80.0, reps: 10, isCompleted: false),
        ],
      );

      final activity = ExerciseActivity.fromExercise(
        exercise: exercise,
        userEmail: 'user@test.com',
        workoutName: 'Push Day',
      );

      expect(activity.exerciseId, 'ex-1');
      expect(activity.exerciseName, 'Bench Press');
      expect(activity.email, 'user@test.com');
      expect(activity.schedaName, 'Push Day');
      expect(activity.sets.length, 2); // Only completed sets
      expect(activity.category, ExerciseCategory.chest);
    });

    test('fromExercise calculates effort from RPE', () {
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, weight: 80.0, reps: 10, actualReps: 10, rpe: 10, isCompleted: true),
          ExerciseSet(setNumber: 2, weight: 80.0, reps: 10, actualReps: 10, rpe: 6, isCompleted: true),
        ],
      );

      final activity = ExerciseActivity.fromExercise(
        exercise: exercise,
        userEmail: 'user@test.com',
        workoutName: 'Test',
      );

      // RPE 10 -> effort 5
      expect(activity.sets[0].effort, 5);
      // RPE 6 -> effort 1
      expect(activity.sets[1].effort, 1);
    });

    test('fromExercise calculates RIR from RPE', () {
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, weight: 80.0, reps: 10, actualReps: 10, rpe: 8, isCompleted: true),
        ],
      );

      final activity = ExerciseActivity.fromExercise(
        exercise: exercise,
        userEmail: 'user@test.com',
        workoutName: 'Test',
      );

      // RIR = 10 - 8 = 2
      expect(activity.sets[0].rir, 2);
    });

    test('fromExercise with no RPE calculates effort from weight/reps', () {
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, weight: 100.0, reps: 15, isCompleted: true),
          ExerciseSet(setNumber: 2, weight: 3.0, reps: 3, isCompleted: true),
        ],
      );

      final activity = ExerciseActivity.fromExercise(
        exercise: exercise,
        userEmail: 'user@test.com',
        workoutName: 'Test',
      );

      // 15 reps >= 15 -> effort 5
      expect(activity.sets[0].effort, 5);
      // 3 reps < 5 and 3 weight < 5 -> effort 1
      expect(activity.sets[1].effort, 1);
    });

    test('fromExercise with custom workoutDate', () {
      final customDate = DateTime(2024, 6, 15);
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [ExerciseSet(setNumber: 1, isCompleted: true)],
      );

      final activity = ExerciseActivity.fromExercise(
        exercise: exercise,
        userEmail: 'user@test.com',
        workoutName: 'Test',
        workoutDate: customDate,
      );

      expect(activity.createdAt, customDate);
    });

    test('fromExercise includes default exercise image', () {
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Bench',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [ExerciseSet(setNumber: 1, isCompleted: true)],
      );

      final activity = ExerciseActivity.fromExercise(
        exercise: exercise,
        userEmail: 'user@test.com',
        workoutName: 'Test',
      );

      expect(activity.exerciseImage, contains('bench-press'));
    });

    test('fromExercise with custom exerciseImageUrl', () {
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [ExerciseSet(setNumber: 1, isCompleted: true)],
      );

      final activity = ExerciseActivity.fromExercise(
        exercise: exercise,
        userEmail: 'user@test.com',
        workoutName: 'Test',
        exerciseImageUrl: 'https://custom.com/image.jpg',
      );

      expect(activity.exerciseImage, 'https://custom.com/image.jpg');
    });

    test('fromExercise preserves session notes', () {
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        notes: 'Felt strong today',
        sets: [ExerciseSet(setNumber: 1, isCompleted: true)],
      );

      final activity = ExerciseActivity.fromExercise(
        exercise: exercise,
        userEmail: 'user@test.com',
        workoutName: 'Test',
      );

      expect(activity.sessionNotes, 'Felt strong today');
    });

    test('default images for each category', () {
      for (final category in ExerciseCategory.values) {
        final exercise = Exercise(
          id: 'test',
          name: 'Test',
          type: ExerciseType.single,
          category: category,
          sets: [ExerciseSet(setNumber: 1, isCompleted: true)],
        );

        final activity = ExerciseActivity.fromExercise(
          exercise: exercise,
          userEmail: 'test@test.com',
          workoutName: 'Test',
        );

        expect(activity.exerciseImage, isNotNull,
            reason: 'Image should exist for category ${category.name}');
        expect(activity.exerciseImage, isNotEmpty);
      }
    });

    test('copyWith', () {
      final activity = ExerciseActivity(
        id: 'act-1',
        email: 'test@test.com',
        exerciseId: 'ex-1',
        exerciseName: 'Bench',
        schedaName: 'Push',
        sets: [],
        createdAt: DateTime(2024, 1, 1),
        lastModified: DateTime(2024, 1, 1),
        category: ExerciseCategory.chest,
      );
      final copy = activity.copyWith(exerciseName: 'Incline Bench');
      expect(copy.exerciseName, 'Incline Bench');
      expect(copy.exerciseId, 'ex-1');
      expect(copy.id, 'act-1');
    });

    test('effort levels by RPE', () {
      // Test each RPE -> effort mapping
      final rpeToEffort = {
        6: 1,
        7: 2,
        8: 3,
        9: 4,
        10: 5,
      };

      for (final entry in rpeToEffort.entries) {
        final exercise = Exercise(
          id: 'ex-1',
          name: 'Test',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(
              setNumber: 1,
              weight: 80.0,
              reps: 10,
              actualReps: 10,
              rpe: entry.key,
              isCompleted: true,
            ),
          ],
        );

        final activity = ExerciseActivity.fromExercise(
          exercise: exercise,
          userEmail: 'test@test.com',
          workoutName: 'Test',
        );

        expect(activity.sets[0].effort, entry.value,
            reason: 'RPE ${entry.key} should map to effort ${entry.value}');
      }
    });

    test('effort without RPE - moderate reps/weight', () {
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, weight: 12.0, reps: 10, isCompleted: true),
        ],
      );

      final activity = ExerciseActivity.fromExercise(
        exercise: exercise,
        userEmail: 'test@test.com',
        workoutName: 'Test',
      );

      expect(activity.sets[0].effort, 3); // reps >= 8 -> effort 3
    });

    test('effort without RPE - light reps/weight', () {
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, weight: 6.0, reps: 5, isCompleted: true),
        ],
      );

      final activity = ExerciseActivity.fromExercise(
        exercise: exercise,
        userEmail: 'test@test.com',
        workoutName: 'Test',
      );

      expect(activity.sets[0].effort, 2); // reps >= 5 -> effort 2
    });

    test('warmup sets preserved', () {
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, weight: 40.0, reps: 10, isCompleted: true, isWarmup: true),
          ExerciseSet(setNumber: 2, weight: 80.0, reps: 10, isCompleted: true, isWarmup: false),
        ],
      );

      final activity = ExerciseActivity.fromExercise(
        exercise: exercise,
        userEmail: 'test@test.com',
        workoutName: 'Test',
      );

      expect(activity.sets[0].isWarmup, true);
      expect(activity.sets[1].isWarmup, false);
    });

    test('setDurationMillis preserved', () {
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, isCompleted: true, setDurationMillis: 45000.0),
        ],
      );

      final activity = ExerciseActivity.fromExercise(
        exercise: exercise,
        userEmail: 'test@test.com',
        workoutName: 'Test',
      );

      expect(activity.sets[0].setDurationMillis, 45000.0);
    });
  });
}

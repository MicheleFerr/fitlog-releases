/// Extended PersonalRecord tests - covering all PRType formattedValue/description
/// paths, copyWith, PRDetectionResult, PRDetector.detectForWorkout, and edge cases
/// not covered by personal_record_test.dart.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/personal_record.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

void main() {
  // ---------------------------------------------------------------------------
  // PRType
  // ---------------------------------------------------------------------------
  group('PRType', () {
    test('has 7 values', () {
      expect(PRType.values.length, 7);
    });

    test('all enum values exist', () {
      expect(PRType.values, contains(PRType.weight));
      expect(PRType.values, contains(PRType.volume));
      expect(PRType.values, contains(PRType.reps));
      expect(PRType.values, contains(PRType.oneRM));
      expect(PRType.values, contains(PRType.totalVolume));
      expect(PRType.values, contains(PRType.totalSets));
      expect(PRType.values, contains(PRType.time));
    });
  });

  // ---------------------------------------------------------------------------
  // PRStatus
  // ---------------------------------------------------------------------------
  group('PRStatus', () {
    test('has 4 values', () {
      expect(PRStatus.values.length, 4);
    });
  });

  // ---------------------------------------------------------------------------
  // PersonalRecord.formattedValue - all PRType paths
  // ---------------------------------------------------------------------------
  group('PersonalRecord formattedValue', () {
    PersonalRecord makePR(PRType type, double value) {
      return PersonalRecord(
        id: 'pr-1',
        exerciseName: 'Test Exercise',
        exerciseId: 'ex-1',
        type: type,
        value: value,
        achievedAt: DateTime(2025, 3, 1),
        workoutId: 'w-1',
      );
    }

    test('weight type formats with 1 decimal and kg', () {
      expect(makePR(PRType.weight, 100.0).formattedValue, '100.0 kg');
      expect(makePR(PRType.weight, 87.5).formattedValue, '87.5 kg');
    });

    test('volume type formats as integer kg', () {
      expect(makePR(PRType.volume, 1500.0).formattedValue, '1500 kg');
      expect(makePR(PRType.volume, 2000.5).formattedValue, '2001 kg'); // rounded
    });

    test('reps type formats as integer reps', () {
      expect(makePR(PRType.reps, 50.0).formattedValue, '50 reps');
      expect(makePR(PRType.reps, 12.0).formattedValue, '12 reps');
    });

    test('oneRM type formats with 1 decimal and 1RM label', () {
      expect(makePR(PRType.oneRM, 133.33).formattedValue, '133.3 kg (1RM)');
      expect(makePR(PRType.oneRM, 100.0).formattedValue, '100.0 kg (1RM)');
    });

    test('totalVolume type formats as integer kg total', () {
      expect(makePR(PRType.totalVolume, 5000.0).formattedValue, '5000 kg total');
      expect(makePR(PRType.totalVolume, 3750.5).formattedValue, '3751 kg total');
    });

    test('totalSets type formats as integer sets', () {
      expect(makePR(PRType.totalSets, 3.0).formattedValue, '3 sets');
      expect(makePR(PRType.totalSets, 10.0).formattedValue, '10 sets');
    });

    test('time type formats in minutes', () {
      // 60 seconds = 1.0 min
      expect(makePR(PRType.time, 60.0).formattedValue, '1.0 min');
      // 90 seconds = 1.5 min
      expect(makePR(PRType.time, 90.0).formattedValue, '1.5 min');
      // 120 seconds = 2.0 min
      expect(makePR(PRType.time, 120.0).formattedValue, '2.0 min');
    });
  });

  // ---------------------------------------------------------------------------
  // PersonalRecord.description - all paths
  // ---------------------------------------------------------------------------
  group('PersonalRecord description', () {
    test('weight type with reps - shows weight x reps', () {
      final pr = PersonalRecord(
        id: 'pr-1',
        exerciseName: 'Bench Press',
        exerciseId: 'ex-1',
        type: PRType.weight,
        value: 100.0,
        reps: 5,
        achievedAt: DateTime(2025, 3, 1),
        workoutId: 'w-1',
      );

      expect(pr.description, '100.0 kg × 5 reps');
    });

    test('weight type without reps - shows formatted value only', () {
      final pr = PersonalRecord(
        id: 'pr-1',
        exerciseName: 'Bench Press',
        exerciseId: 'ex-1',
        type: PRType.weight,
        value: 100.0,
        // no reps
        achievedAt: DateTime(2025, 3, 1),
        workoutId: 'w-1',
      );

      expect(pr.description, '100.0 kg');
    });

    test('reps type with weight - shows reps @ weight', () {
      final pr = PersonalRecord(
        id: 'pr-2',
        exerciseName: 'Curl',
        exerciseId: 'ex-2',
        type: PRType.reps,
        value: 20.0,
        weight: 30.0,
        achievedAt: DateTime(2025, 3, 1),
        workoutId: 'w-1',
      );

      expect(pr.description, '20 reps @ 30.0 kg');
    });

    test('reps type without weight - shows formatted value only', () {
      final pr = PersonalRecord(
        id: 'pr-2',
        exerciseName: 'Pull-up',
        exerciseId: 'ex-2',
        type: PRType.reps,
        value: 15.0,
        // no weight
        achievedAt: DateTime(2025, 3, 1),
        workoutId: 'w-1',
      );

      expect(pr.description, '15 reps');
    });

    test('volume type with weight and reps - shows calculation breakdown', () {
      final pr = PersonalRecord(
        id: 'pr-3',
        exerciseName: 'Deadlift',
        exerciseId: 'ex-3',
        type: PRType.volume,
        value: 1500.0,
        weight: 150.0,
        reps: 10,
        achievedAt: DateTime(2025, 3, 1),
        workoutId: 'w-1',
      );

      expect(pr.description, '150.0 kg × 10 = 1500 kg');
    });

    test('volume type without weight and reps - shows formatted value', () {
      final pr = PersonalRecord(
        id: 'pr-3',
        exerciseName: 'Deadlift',
        exerciseId: 'ex-3',
        type: PRType.volume,
        value: 1500.0,
        // no weight, no reps
        achievedAt: DateTime(2025, 3, 1),
        workoutId: 'w-1',
      );

      expect(pr.description, '1500 kg');
    });

    test('oneRM type returns formatted value', () {
      final pr = PersonalRecord(
        id: 'pr-4',
        exerciseName: 'Squat',
        exerciseId: 'ex-4',
        type: PRType.oneRM,
        value: 133.33,
        achievedAt: DateTime(2025, 3, 1),
        workoutId: 'w-1',
      );

      expect(pr.description, '133.3 kg (1RM)');
    });

    test('totalVolume type returns formatted value', () {
      final pr = PersonalRecord(
        id: 'pr-5',
        exerciseName: 'Bench Press',
        exerciseId: 'ex-5',
        type: PRType.totalVolume,
        value: 3000.0,
        achievedAt: DateTime(2025, 3, 1),
        workoutId: 'w-1',
      );

      expect(pr.description, '3000 kg total');
    });

    test('totalSets type returns formatted value', () {
      final pr = PersonalRecord(
        id: 'pr-6',
        exerciseName: 'Bench Press',
        exerciseId: 'ex-6',
        type: PRType.totalSets,
        value: 5.0,
        achievedAt: DateTime(2025, 3, 1),
        workoutId: 'w-1',
      );

      expect(pr.description, '5 sets');
    });

    test('time type returns formatted value', () {
      final pr = PersonalRecord(
        id: 'pr-7',
        exerciseName: 'Plank',
        exerciseId: 'ex-7',
        type: PRType.time,
        value: 90.0,
        achievedAt: DateTime(2025, 3, 1),
        workoutId: 'w-1',
      );

      expect(pr.description, '1.5 min');
    });
  });

  // ---------------------------------------------------------------------------
  // PersonalRecord.fromSet - all PRType paths
  // ---------------------------------------------------------------------------
  group('PersonalRecord.fromSet all type paths', () {
    test('volume type uses set.volume', () {
      final set = ExerciseSet(
        setNumber: 1,
        weight: 100.0,
        reps: 10,
        isCompleted: true,
      );

      final pr = PersonalRecord.fromSet(
        exerciseName: 'Deadlift',
        exerciseId: 'ex-1',
        set: set,
        type: PRType.volume,
        workoutId: 'w-1',
      );

      expect(pr.value, 1000.0); // 100 * 10
    });

    test('reps type uses actualReps when available', () {
      final set = ExerciseSet(
        setNumber: 1,
        weight: 80.0,
        reps: 10,
        actualReps: 12, // performed more reps
        isCompleted: true,
      );

      final pr = PersonalRecord.fromSet(
        exerciseName: 'Bench Press',
        exerciseId: 'ex-1',
        set: set,
        type: PRType.reps,
        workoutId: 'w-1',
      );

      expect(pr.value, 12.0);
    });

    test('reps type falls back to reps when no actualReps', () {
      final set = ExerciseSet(
        setNumber: 1,
        weight: 80.0,
        reps: 10,
        isCompleted: true,
      );

      final pr = PersonalRecord.fromSet(
        exerciseName: 'Bench Press',
        exerciseId: 'ex-1',
        set: set,
        type: PRType.reps,
        workoutId: 'w-1',
      );

      expect(pr.value, 10.0);
    });

    test('time type uses seconds', () {
      final set = ExerciseSet(
        setNumber: 1,
        seconds: 120,
        isCompleted: true,
      );

      final pr = PersonalRecord.fromSet(
        exerciseName: 'Plank',
        exerciseId: 'ex-1',
        set: set,
        type: PRType.time,
        workoutId: 'w-1',
      );

      expect(pr.value, 120.0);
    });

    test('totalVolume type uses set.volume', () {
      final set = ExerciseSet(
        setNumber: 1,
        weight: 50.0,
        reps: 15,
        isCompleted: true,
      );

      final pr = PersonalRecord.fromSet(
        exerciseName: 'Curl',
        exerciseId: 'ex-1',
        set: set,
        type: PRType.totalVolume,
        workoutId: 'w-1',
      );

      expect(pr.value, 750.0);
    });

    test('totalSets type returns 1.0', () {
      final set = ExerciseSet(
        setNumber: 1,
        weight: 50.0,
        reps: 10,
        isCompleted: true,
      );

      final pr = PersonalRecord.fromSet(
        exerciseName: 'Squat',
        exerciseId: 'ex-1',
        set: set,
        type: PRType.totalSets,
        workoutId: 'w-1',
      );

      expect(pr.value, 1.0);
    });

    test('metadata includes setNumber, isWarmup, and rpe', () {
      final set = ExerciseSet(
        setNumber: 3,
        weight: 100.0,
        reps: 5,
        rpe: 9,
        isWarmup: false,
        isCompleted: true,
      );

      final pr = PersonalRecord.fromSet(
        exerciseName: 'Squat',
        exerciseId: 'ex-1',
        set: set,
        type: PRType.weight,
        workoutId: 'w-1',
      );

      expect(pr.metadata['setNumber'], 3);
      expect(pr.metadata['isWarmup'], false);
      expect(pr.metadata['rpe'], 9);
    });

    test('id includes exerciseId and type name', () {
      final set = ExerciseSet(
        setNumber: 1,
        weight: 100.0,
        reps: 5,
        isCompleted: true,
      );

      final pr = PersonalRecord.fromSet(
        exerciseName: 'Bench Press',
        exerciseId: 'ex-bench',
        set: set,
        type: PRType.weight,
        workoutId: 'w-1',
      );

      expect(pr.id, startsWith('ex-bench_weight_'));
    });

    test('completedAt used from set when available', () {
      final completedAt = DateTime(2025, 3, 1, 10, 30);
      final set = ExerciseSet(
        setNumber: 1,
        weight: 100.0,
        reps: 5,
        isCompleted: true,
        completedAt: completedAt,
      );

      final pr = PersonalRecord.fromSet(
        exerciseName: 'Bench Press',
        exerciseId: 'ex-1',
        set: set,
        type: PRType.weight,
        workoutId: 'w-1',
      );

      expect(pr.achievedAt, completedAt);
    });
  });

  // ---------------------------------------------------------------------------
  // PersonalRecord.copyWith
  // ---------------------------------------------------------------------------
  group('PersonalRecord copyWith', () {
    final basePR = PersonalRecord(
      id: 'pr-base',
      exerciseName: 'Squat',
      exerciseId: 'ex-squat',
      type: PRType.weight,
      value: 100.0,
      reps: 5,
      weight: 100.0,
      achievedAt: DateTime(2025, 3, 1),
      workoutId: 'w-original',
      metadata: {'setNumber': 1},
    );

    test('updates exerciseName', () {
      final updated = basePR.copyWith(exerciseName: 'Back Squat');
      expect(updated.exerciseName, 'Back Squat');
      expect(updated.exerciseId, 'ex-squat'); // unchanged
    });

    test('updates type', () {
      final updated = basePR.copyWith(type: PRType.oneRM);
      expect(updated.type, PRType.oneRM);
    });

    test('updates value', () {
      final updated = basePR.copyWith(value: 110.0);
      expect(updated.value, 110.0);
    });

    test('updates reps', () {
      final updated = basePR.copyWith(reps: 8);
      expect(updated.reps, 8);
    });

    test('updates weight', () {
      final updated = basePR.copyWith(weight: 105.0);
      expect(updated.weight, 105.0);
    });

    test('updates achievedAt', () {
      final newDate = DateTime(2025, 4, 1);
      final updated = basePR.copyWith(achievedAt: newDate);
      expect(updated.achievedAt, newDate);
    });

    test('updates workoutId', () {
      final updated = basePR.copyWith(workoutId: 'w-new');
      expect(updated.workoutId, 'w-new');
    });

    test('updates metadata', () {
      final updated = basePR.copyWith(metadata: {'setNumber': 3, 'extra': 'data'});
      expect(updated.metadata['setNumber'], 3);
      expect(updated.metadata['extra'], 'data');
    });

    test('preserves id and exerciseId through copyWith', () {
      final updated = basePR.copyWith(value: 200.0);
      expect(updated.id, 'pr-base');
      expect(updated.exerciseId, 'ex-squat');
    });
  });

  // ---------------------------------------------------------------------------
  // PersonalRecord toJson / fromJson
  // ---------------------------------------------------------------------------
  group('PersonalRecord toJson / fromJson', () {
    test('round-trip preserves all fields', () {
      final original = PersonalRecord(
        id: 'pr-full',
        exerciseName: 'Deadlift',
        exerciseId: 'ex-deadlift',
        type: PRType.oneRM,
        value: 185.5,
        reps: 5,
        weight: 160.0,
        achievedAt: DateTime(2025, 3, 1, 10, 0, 0),
        workoutId: 'w-full',
        metadata: {'setNumber': 2, 'rpe': 9},
      );

      final json = original.toJson();

      expect(json['id'], 'pr-full');
      expect(json['exerciseName'], 'Deadlift');
      expect(json['exerciseId'], 'ex-deadlift');
      expect(json['type'], 'oneRM');
      expect(json['value'], 185.5);
      expect(json['reps'], 5);
      expect(json['weight'], 160.0);
      expect(json['workoutId'], 'w-full');

      final restored = PersonalRecord.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.exerciseName, original.exerciseName);
      expect(restored.type, original.type);
      expect(restored.value, original.value);
      expect(restored.reps, original.reps);
      expect(restored.weight, original.weight);
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'pr-min',
        'exerciseName': 'Squat',
        'exerciseId': 'ex-squat',
        'type': 'weight',
        'value': 100.0,
        'reps': null,
        'weight': null,
        'achievedAt': DateTime(2025, 3, 1).toIso8601String(),
        'workoutId': 'w-1',
        'metadata': {},
      };

      final pr = PersonalRecord.fromJson(json);
      expect(pr.reps, isNull);
      expect(pr.weight, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // PRDetectionResult
  // ---------------------------------------------------------------------------
  group('PRDetectionResult', () {
    test('hasNewPR is true when newPRs is not empty', () {
      final result = PRDetectionResult(
        exerciseId: 'ex-1',
        exerciseName: 'Bench Press',
        newPRs: [
          PersonalRecord(
            id: 'pr-1',
            exerciseName: 'Bench Press',
            exerciseId: 'ex-1',
            type: PRType.weight,
            value: 100.0,
            achievedAt: DateTime.now(),
            workoutId: 'w-1',
          ),
        ],
        status: PRStatus.newPR,
      );

      expect(result.hasNewPR, isTrue);
    });

    test('hasNewPR is false when newPRs is empty', () {
      const result = PRDetectionResult(
        exerciseId: 'ex-1',
        exerciseName: 'Bench Press',
        status: PRStatus.normal,
      );

      expect(result.hasNewPR, isFalse);
    });

    test('isNearPR is true for nearPR status', () {
      const result = PRDetectionResult(
        exerciseId: 'ex-1',
        exerciseName: 'Bench Press',
        status: PRStatus.nearPR,
        proximityPercentage: 97.0,
      );

      expect(result.isNearPR, isTrue);
    });

    test('isNearPR is true for approaching status', () {
      const result = PRDetectionResult(
        exerciseId: 'ex-1',
        exerciseName: 'Bench Press',
        status: PRStatus.approaching,
        proximityPercentage: 92.0,
      );

      expect(result.isNearPR, isTrue);
    });

    test('isNearPR is false for newPR status', () {
      final result = PRDetectionResult(
        exerciseId: 'ex-1',
        exerciseName: 'Bench Press',
        newPRs: [
          PersonalRecord(
            id: 'pr-1',
            exerciseName: 'Bench Press',
            exerciseId: 'ex-1',
            type: PRType.weight,
            value: 100.0,
            achievedAt: DateTime.now(),
            workoutId: 'w-1',
          ),
        ],
        status: PRStatus.newPR,
      );

      expect(result.isNearPR, isFalse);
    });

    test('isNearPR is false for normal status', () {
      const result = PRDetectionResult(
        exerciseId: 'ex-1',
        exerciseName: 'Bench Press',
        status: PRStatus.normal,
      );

      expect(result.isNearPR, isFalse);
    });

    test('getMotivationalMessage for approaching status', () {
      const result = PRDetectionResult(
        exerciseId: 'ex-1',
        exerciseName: 'Bench Press',
        status: PRStatus.approaching,
        proximityPercentage: 92.0,
      );

      expect(result.getMotivationalMessage(), contains('Getting closer'));
    });

    test('getMotivationalMessage for normal status returns empty string', () {
      const result = PRDetectionResult(
        exerciseId: 'ex-1',
        exerciseName: 'Bench Press',
        status: PRStatus.normal,
      );

      expect(result.getMotivationalMessage(), '');
    });

    test('getMotivationalMessage for newPR status', () {
      final result = PRDetectionResult(
        exerciseId: 'ex-1',
        exerciseName: 'Bench Press',
        newPRs: [
          PersonalRecord(
            id: 'pr-1',
            exerciseName: 'Bench Press',
            exerciseId: 'ex-1',
            type: PRType.weight,
            value: 100.0,
            achievedAt: DateTime.now(),
            workoutId: 'w-1',
          ),
        ],
        status: PRStatus.newPR,
      );

      expect(result.getMotivationalMessage(), contains('NEW PERSONAL RECORD'));
    });
  });

  // ---------------------------------------------------------------------------
  // PRDetector.detectForWorkout
  // ---------------------------------------------------------------------------
  group('PRDetector.detectForWorkout', () {
    test('returns result for each exercise in workout', () {
      const detector = PRDetector(historicalPRs: {});

      final exercises = [
        Exercise(
          id: 'ex-1',
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(
              setNumber: 1,
              weight: 80.0,
              reps: 10,
              isCompleted: true,
              isWarmup: false,
            ),
          ],
        ),
        Exercise(
          id: 'ex-2',
          name: 'Squat',
          type: ExerciseType.single,
          category: ExerciseCategory.legs,
          sets: [
            ExerciseSet(
              setNumber: 1,
              weight: 100.0,
              reps: 8,
              isCompleted: true,
              isWarmup: false,
            ),
          ],
        ),
      ];

      final results = detector.detectForWorkout(exercises, 'workout-1');

      expect(results.length, 2);
      expect(results[0].exerciseName, 'Bench Press');
      expect(results[1].exerciseName, 'Squat');
    });

    test('returns empty list for empty workout', () {
      const detector = PRDetector(historicalPRs: {});

      final results = detector.detectForWorkout([], 'workout-1');

      expect(results, isEmpty);
    });

    test('all exercises get their PRs detected', () {
      const detector = PRDetector(historicalPRs: {});

      final exercises = [
        Exercise(
          id: 'ex-1',
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(
              setNumber: 1,
              weight: 80.0,
              reps: 10,
              isCompleted: true,
              isWarmup: false,
            ),
          ],
        ),
        Exercise(
          id: 'ex-2',
          name: 'Deadlift',
          type: ExerciseType.single,
          category: ExerciseCategory.back,
          sets: [
            ExerciseSet(
              setNumber: 1,
              weight: 140.0,
              reps: 5,
              isCompleted: true,
              isWarmup: false,
            ),
          ],
        ),
      ];

      final results = detector.detectForWorkout(exercises, 'workout-1');

      // Both exercises should have PRs (no historical data)
      expect(results.every((r) => r.hasNewPR), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // PRDetector - approaching status threshold
  // ---------------------------------------------------------------------------
  group('PRDetector approaching status', () {
    test('detects approaching status when 90-95% of PR', () {
      final achievedAt = DateTime.now().subtract(const Duration(days: 7));
      final historicalPRs = {
        'ex1': [
          PersonalRecord(
            id: 'pr1',
            exerciseName: 'Squat',
            exerciseId: 'ex1',
            type: PRType.weight,
            value: 100.0,
            achievedAt: achievedAt,
            workoutId: 'old_workout',
          ),
          PersonalRecord(
            id: 'pr2',
            exerciseName: 'Squat',
            exerciseId: 'ex1',
            type: PRType.volume,
            value: 1000.0, // 91 * 10 = 910, so volume is NOT a PR
            achievedAt: achievedAt,
            workoutId: 'old_workout',
          ),
          PersonalRecord(
            id: 'pr3',
            exerciseName: 'Squat',
            exerciseId: 'ex1',
            type: PRType.reps,
            value: 15.0,
            weight: 91.0,
            achievedAt: achievedAt,
            workoutId: 'old_workout',
          ),
          PersonalRecord(
            id: 'pr4',
            exerciseName: 'Squat',
            exerciseId: 'ex1',
            type: PRType.oneRM,
            value: 130.0,
            achievedAt: achievedAt,
            workoutId: 'old_workout',
          ),
          PersonalRecord(
            id: 'pr5',
            exerciseName: 'Squat',
            exerciseId: 'ex1',
            type: PRType.totalVolume,
            value: 1000.0,
            achievedAt: achievedAt,
            workoutId: 'old_workout',
          ),
        ],
      };

      final detector = PRDetector(historicalPRs: historicalPRs);

      final exercise = Exercise(
        id: 'ex1',
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 91.0, // 91% of 100 = approaching (90-95%)
            reps: 10,
            isCompleted: true,
            isWarmup: false,
          ),
        ],
      );

      final result = detector.detectForExercise(exercise, 'current_workout');

      expect(result.hasNewPR, isFalse);
      expect(result.status, equals(PRStatus.approaching));
    });

    test('detects normal status when below 90% of PR', () {
      final achievedAt = DateTime.now().subtract(const Duration(days: 7));
      final historicalPRs = {
        'ex1': [
          PersonalRecord(
            id: 'pr1',
            exerciseName: 'Squat',
            exerciseId: 'ex1',
            type: PRType.weight,
            value: 100.0,
            achievedAt: achievedAt,
            workoutId: 'old_workout',
          ),
          PersonalRecord(
            id: 'pr2',
            exerciseName: 'Squat',
            exerciseId: 'ex1',
            type: PRType.volume,
            value: 2000.0, // way above 80*10=800
            achievedAt: achievedAt,
            workoutId: 'old_workout',
          ),
          PersonalRecord(
            id: 'pr3',
            exerciseName: 'Squat',
            exerciseId: 'ex1',
            type: PRType.reps,
            value: 20.0,
            weight: 80.0,
            achievedAt: achievedAt,
            workoutId: 'old_workout',
          ),
          PersonalRecord(
            id: 'pr4',
            exerciseName: 'Squat',
            exerciseId: 'ex1',
            type: PRType.oneRM,
            value: 200.0,
            achievedAt: achievedAt,
            workoutId: 'old_workout',
          ),
          PersonalRecord(
            id: 'pr5',
            exerciseName: 'Squat',
            exerciseId: 'ex1',
            type: PRType.totalVolume,
            value: 2000.0,
            achievedAt: achievedAt,
            workoutId: 'old_workout',
          ),
        ],
      };

      final detector = PRDetector(historicalPRs: historicalPRs);

      final exercise = Exercise(
        id: 'ex1',
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
        sets: [
          ExerciseSet(
            setNumber: 1,
            weight: 80.0, // 80% of 100 = normal
            reps: 10,
            isCompleted: true,
            isWarmup: false,
          ),
        ],
      );

      final result = detector.detectForExercise(exercise, 'current_workout');

      expect(result.hasNewPR, isFalse);
      expect(result.status, equals(PRStatus.normal));
    });
  });
}

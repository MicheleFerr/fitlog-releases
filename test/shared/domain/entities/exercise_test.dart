/// Exercise entity tests - Exercise, ExerciseSet, SupersetExerciseData, enums.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';

void main() {
  group('ExerciseType enum', () {
    test('has 4 values', () {
      expect(ExerciseType.values.length, 4);
    });

    test('contains all types', () {
      expect(ExerciseType.values, containsAll([
        ExerciseType.single,
        ExerciseType.superset,
        ExerciseType.dropset,
        ExerciseType.restPause,
      ]));
    });
  });

  group('ExerciseCategory enum', () {
    test('has 8 values', () {
      expect(ExerciseCategory.values.length, 8);
    });

    test('contains all categories', () {
      expect(
        ExerciseCategory.values,
        containsAll([
          ExerciseCategory.chest,
          ExerciseCategory.back,
          ExerciseCategory.shoulders,
          ExerciseCategory.arms,
          ExerciseCategory.legs,
          ExerciseCategory.abs,
          ExerciseCategory.cardio,
          ExerciseCategory.other,
        ]),
      );
    });
  });

  group('MovementType', () {
    test('has 4 values', () {
      expect(MovementType.values.length, 4);
    });

    test('recoveryHours', () {
      expect(MovementType.compoundHeavy.recoveryHours, 96);
      expect(MovementType.compoundMedium.recoveryHours, 72);
      expect(MovementType.isolationHeavy.recoveryHours, 72);
      expect(MovementType.isolationLight.recoveryHours, 48);
    });

    test('recoveryDays', () {
      expect(MovementType.compoundHeavy.recoveryDays, 4.0);
      expect(MovementType.compoundMedium.recoveryDays, 3.0);
      expect(MovementType.isolationHeavy.recoveryDays, 3.0);
      expect(MovementType.isolationLight.recoveryDays, 2.0);
    });

    test('cnsStressFactor', () {
      expect(MovementType.compoundHeavy.cnsStressFactor, 0.7);
      expect(MovementType.compoundMedium.cnsStressFactor, 0.85);
      expect(MovementType.isolationHeavy.cnsStressFactor, 1.0);
      expect(MovementType.isolationLight.cnsStressFactor, 1.0);
    });

    test('stressMultiplier', () {
      expect(MovementType.compoundHeavy.stressMultiplier, 1.5);
      expect(MovementType.compoundMedium.stressMultiplier, 1.2);
      expect(MovementType.isolationHeavy.stressMultiplier, 1.0);
      expect(MovementType.isolationLight.stressMultiplier, 0.8);
    });

    test('displayName', () {
      expect(MovementType.compoundHeavy.displayName, 'Compound Heavy');
      expect(MovementType.compoundMedium.displayName, 'Compound Medium');
      expect(MovementType.isolationHeavy.displayName, 'Isolation Heavy');
      expect(MovementType.isolationLight.displayName, 'Isolation Light');
    });

    test('examples', () {
      expect(MovementType.compoundHeavy.examples, contains('Squat'));
      expect(MovementType.compoundMedium.examples, contains('Bench Press'));
      expect(MovementType.isolationHeavy.examples, contains('Leg Press'));
      expect(MovementType.isolationLight.examples, contains('Bicep Curl'));
    });
  });

  group('AutoAdjustmentType', () {
    test('has rpe value', () {
      expect(AutoAdjustmentType.values.length, 1);
      expect(AutoAdjustmentType.rpe, isNotNull);
    });
  });

  group('ExerciseSet', () {
    test('constructor with defaults', () {
      final set = ExerciseSet(setNumber: 1);
      expect(set.setNumber, 1);
      expect(set.weight, isNull);
      expect(set.reps, isNull);
      expect(set.isCompleted, false);
      expect(set.isWarmup, false);
      expect(set.restTimerSkipped, false);
      expect(set.id, isNotEmpty);
    });

    test('constructor with all fields', () {
      final now = DateTime(2024, 1, 1);
      final set = ExerciseSet(
        id: 'test-id',
        setNumber: 2,
        weight: 80.0,
        reps: 10,
        minReps: 8,
        maxReps: 12,
        actualReps: 9,
        rpe: 8,
        seconds: 60,
        distance: 1000.0,
        isCompleted: true,
        notes: 'Good set',
        completedAt: now,
        setDurationMillis: 45000.0,
        setStartedAt: now,
        isWarmup: true,
        restTime: 90,
        restTimerSkipped: true,
        restTimerSecondsRemaining: 30,
        restTimerSecondsAdded: 15,
        actualRestSeconds: 75,
      );
      expect(set.id, 'test-id');
      expect(set.weight, 80.0);
      expect(set.reps, 10);
      expect(set.minReps, 8);
      expect(set.maxReps, 12);
      expect(set.actualReps, 9);
      expect(set.rpe, 8);
      expect(set.seconds, 60);
      expect(set.distance, 1000.0);
      expect(set.isCompleted, true);
      expect(set.notes, 'Good set');
      expect(set.isWarmup, true);
      expect(set.restTime, 90);
      expect(set.restTimerSkipped, true);
      expect(set.restTimerSecondsRemaining, 30);
      expect(set.restTimerSecondsAdded, 15);
      expect(set.actualRestSeconds, 75);
    });

    test('fromJson', () {
      final json = {
        'id': 'set-1',
        'setNumber': 1,
        'weight': 100.0,
        'reps': 5,
        'minReps': 3,
        'maxReps': 6,
        'actualReps': 5,
        'rpe': 9,
        'seconds': 30,
        'distance': 500.0,
        'isCompleted': true,
        'notes': 'PR attempt',
        'completedAt': '2024-01-01T10:00:00.000',
        'setDurationMillis': 30000.0,
        'setStartedAt': '2024-01-01T09:59:00.000',
        'isWarmup': false,
        'restTime': 120,
        'restTimerSkipped': true,
        'restTimerSecondsRemaining': 20,
        'restTimerSecondsAdded': 30,
        'actualRestSeconds': 130,
      };
      final set = ExerciseSet.fromJson(json);
      expect(set.id, 'set-1');
      expect(set.weight, 100.0);
      expect(set.reps, 5);
      expect(set.minReps, 3);
      expect(set.maxReps, 6);
      expect(set.actualReps, 5);
      expect(set.rpe, 9);
      expect(set.isCompleted, true);
      expect(set.isWarmup, false);
      expect(set.restTimerSkipped, true);
      expect(set.setDurationMillis, 30000.0);
      expect(set.distance, 500.0);
      expect(set.restTimerSecondsRemaining, 20);
      expect(set.restTimerSecondsAdded, 30);
      expect(set.actualRestSeconds, 130);
    });

    test('fromJson normalizes minReps > maxReps', () {
      final json = {
        'setNumber': 1,
        'minReps': 12,
        'maxReps': 8,
      };
      final set = ExerciseSet.fromJson(json);
      // Should swap
      expect(set.minReps, 8);
      expect(set.maxReps, 12);
    });

    test('fromJson with null minReps/maxReps keeps null', () {
      final json = {'setNumber': 1};
      final set = ExerciseSet.fromJson(json);
      expect(set.minReps, isNull);
      expect(set.maxReps, isNull);
    });

    test('fromJson with only minReps preserves it without normalization', () {
      final json = {'setNumber': 1, 'minReps': 8};
      final set = ExerciseSet.fromJson(json);
      expect(set.minReps, 8);
      expect(set.maxReps, isNull);
    });

    test('fromJson with only maxReps preserves it without normalization', () {
      final json = {'setNumber': 1, 'maxReps': 12};
      final set = ExerciseSet.fromJson(json);
      expect(set.minReps, isNull);
      expect(set.maxReps, 12);
    });

    test('fromJson defaults', () {
      final json = {'setNumber': 1};
      final set = ExerciseSet.fromJson(json);
      expect(set.isCompleted, false);
      expect(set.isWarmup, false);
      expect(set.restTimerSkipped, false);
    });

    test('fromJson parses setStartedAt', () {
      final json = {
        'setNumber': 1,
        'setStartedAt': '2024-06-15T08:30:00.000',
      };
      final set = ExerciseSet.fromJson(json);
      expect(set.setStartedAt, DateTime(2024, 6, 15, 8, 30));
    });

    test('toJson round-trip', () {
      final set = ExerciseSet(
        setNumber: 1,
        weight: 80.0,
        reps: 10,
        isCompleted: true,
        isWarmup: true,
        restTime: 90,
      );
      final json = set.toJson();
      expect(json['setNumber'], 1);
      expect(json['weight'], 80.0);
      expect(json['reps'], 10);
      expect(json['isCompleted'], true);
      expect(json['isWarmup'], true);
      expect(json['restTime'], 90);
    });

    test('toJson omits null optional keys', () {
      final set = ExerciseSet(setNumber: 1);
      final json = set.toJson();
      expect(json.containsKey('minReps'), false);
      expect(json.containsKey('maxReps'), false);
      expect(json.containsKey('restTime'), false);
      expect(json.containsKey('restTimerSecondsRemaining'), false);
      expect(json.containsKey('restTimerSecondsAdded'), false);
      expect(json.containsKey('actualRestSeconds'), false);
    });

    test('toJson includes restTimerSecondsRemaining when set', () {
      final set = ExerciseSet(
        setNumber: 1,
        restTimerSecondsRemaining: 45,
        restTimerSecondsAdded: 30,
        actualRestSeconds: 75,
      );
      final json = set.toJson();
      expect(json['restTimerSecondsRemaining'], 45);
      expect(json['restTimerSecondsAdded'], 30);
      expect(json['actualRestSeconds'], 75);
    });

    test('copyWith preserves and overrides', () {
      final original = ExerciseSet(setNumber: 1, weight: 80.0, reps: 10);
      final copy = original.copyWith(weight: 90.0);
      expect(copy.weight, 90.0);
      expect(copy.reps, 10);
      expect(copy.setNumber, 1);
    });

    test('copyWith with id override', () {
      final original = ExerciseSet(id: 'original-id', setNumber: 1);
      final copy = original.copyWith(id: 'new-id');
      expect(copy.id, 'new-id');
    });

    test('copyWith with all rest timer fields', () {
      final original = ExerciseSet(setNumber: 1);
      final copy = original.copyWith(
        restTimerSkipped: true,
        restTimerSecondsRemaining: 20,
        restTimerSecondsAdded: 10,
        actualRestSeconds: 50,
      );
      expect(copy.restTimerSkipped, true);
      expect(copy.restTimerSecondsRemaining, 20);
      expect(copy.restTimerSecondsAdded, 10);
      expect(copy.actualRestSeconds, 50);
    });

    test('copyWith with completedAt and setStartedAt', () {
      final original = ExerciseSet(setNumber: 1);
      final now = DateTime(2024, 1, 1, 12, 0);
      final copy = original.copyWith(
        completedAt: now,
        setStartedAt: now,
        setDurationMillis: 30000.0,
        distance: 500.0,
        isWarmup: true,
      );
      expect(copy.completedAt, now);
      expect(copy.setStartedAt, now);
      expect(copy.setDurationMillis, 30000.0);
      expect(copy.distance, 500.0);
      expect(copy.isWarmup, true);
    });

    test('volume calculation', () {
      final set = ExerciseSet(setNumber: 1, weight: 80.0, reps: 10);
      expect(set.volume, 800.0);
    });

    test('volume uses actualReps when available', () {
      final set = ExerciseSet(setNumber: 1, weight: 80.0, reps: 10, actualReps: 8);
      expect(set.volume, 640.0);
    });

    test('volume with null weight/reps', () {
      final set = ExerciseSet(setNumber: 1);
      expect(set.volume, 0.0);
    });

    test('volume with only reps no weight', () {
      final set = ExerciseSet(setNumber: 1, reps: 10);
      expect(set.volume, 0.0);
    });

    test('hasRepRange', () {
      final noRange = ExerciseSet(setNumber: 1, reps: 10);
      expect(noRange.hasRepRange, false);

      final sameRange = ExerciseSet(setNumber: 1, minReps: 10, maxReps: 10);
      expect(sameRange.hasRepRange, false);

      final withRange = ExerciseSet(setNumber: 1, minReps: 8, maxReps: 12);
      expect(withRange.hasRepRange, true);
    });

    test('repsDisplay', () {
      expect(ExerciseSet(setNumber: 1, reps: 10).repsDisplay, '10');
      expect(ExerciseSet(setNumber: 1, minReps: 8, maxReps: 12).repsDisplay, '8-12');
      expect(ExerciseSet(setNumber: 1).repsDisplay, '-');
      // minReps only (no maxReps)
      expect(ExerciseSet(setNumber: 1, minReps: 8).repsDisplay, '8');
      // maxReps only (no minReps)
      expect(ExerciseSet(setNumber: 1, maxReps: 12).repsDisplay, '12');
    });

    test('isAboveRange', () {
      final set = ExerciseSet(setNumber: 1, minReps: 8, maxReps: 12, actualReps: 15);
      expect(set.isAboveRange, true);

      final inRange = ExerciseSet(setNumber: 1, minReps: 8, maxReps: 12, actualReps: 10);
      expect(inRange.isAboveRange, false);

      final noRange = ExerciseSet(setNumber: 1, reps: 10, actualReps: 15);
      expect(noRange.isAboveRange, false);

      // No actualReps
      final noActual = ExerciseSet(setNumber: 1, minReps: 8, maxReps: 12);
      expect(noActual.isAboveRange, false);
    });

    test('isFullyCompleted', () {
      final full = ExerciseSet(setNumber: 1, reps: 10, actualReps: 10, isCompleted: true);
      expect(full.isFullyCompleted, true);

      final partial = ExerciseSet(setNumber: 1, reps: 10, actualReps: 8, isCompleted: true);
      expect(partial.isFullyCompleted, false);

      final rangeOk = ExerciseSet(setNumber: 1, minReps: 8, maxReps: 12, actualReps: 9, isCompleted: true);
      expect(rangeOk.isFullyCompleted, true);

      // Not completed
      final notCompleted = ExerciseSet(setNumber: 1, reps: 10, actualReps: 10, isCompleted: false);
      expect(notCompleted.isFullyCompleted, false);

      // No actualReps
      final noActual = ExerciseSet(setNumber: 1, reps: 10, isCompleted: true);
      expect(noActual.isFullyCompleted, false);

      // No reps target
      final noTarget = ExerciseSet(setNumber: 1, actualReps: 10, isCompleted: true);
      expect(noTarget.isFullyCompleted, false);
    });

    test('isPartiallyCompleted', () {
      final partial = ExerciseSet(setNumber: 1, reps: 10, actualReps: 8, isCompleted: true);
      expect(partial.isPartiallyCompleted, true);

      final full = ExerciseSet(setNumber: 1, reps: 10, actualReps: 10, isCompleted: true);
      expect(full.isPartiallyCompleted, false);

      final rangeFail = ExerciseSet(setNumber: 1, minReps: 8, maxReps: 12, actualReps: 6, isCompleted: true);
      expect(rangeFail.isPartiallyCompleted, true);

      // Not completed at all
      final notCompleted = ExerciseSet(setNumber: 1, reps: 10, actualReps: 8, isCompleted: false);
      expect(notCompleted.isPartiallyCompleted, false);

      // No actualReps
      final noActual = ExerciseSet(setNumber: 1, reps: 10, isCompleted: true);
      expect(noActual.isPartiallyCompleted, false);

      // No reps target
      final noTarget = ExerciseSet(setNumber: 1, actualReps: 5, isCompleted: true);
      expect(noTarget.isPartiallyCompleted, false);
    });

    test('hasValidRPE', () {
      expect(ExerciseSet(setNumber: 1, rpe: 8).hasValidRPE, true);
      expect(ExerciseSet(setNumber: 1, rpe: 5).hasValidRPE, true);
      expect(ExerciseSet(setNumber: 1, rpe: 10).hasValidRPE, true);
      expect(ExerciseSet(setNumber: 1, rpe: 4).hasValidRPE, false);
      expect(ExerciseSet(setNumber: 1, rpe: 11).hasValidRPE, false);
      expect(ExerciseSet(setNumber: 1).hasValidRPE, false);
    });

    test('rpeText', () {
      expect(ExerciseSet(setNumber: 1, rpe: 8).rpeText, 'RPE: 8/10');
      expect(ExerciseSet(setNumber: 1).rpeText, '');
    });

    test('repsText', () {
      expect(ExerciseSet(setNumber: 1, reps: 10, actualReps: 8).repsText, '8/10 reps');
      expect(ExerciseSet(setNumber: 1, actualReps: 8).repsText, '8 reps');
      expect(ExerciseSet(setNumber: 1, reps: 10).repsText, '10 reps (target)');
      expect(ExerciseSet(setNumber: 1).repsText, '');
    });

    test('repsText with range', () {
      // When actualReps is set and hasRepRange → "actualReps/range reps"
      final set = ExerciseSet(setNumber: 1, minReps: 8, maxReps: 12, actualReps: 10);
      expect(set.repsText, '10/8-12 reps');
    });

    test('completeWithRPE', () {
      final set = ExerciseSet(setNumber: 1, weight: 80.0, reps: 10);
      final completed = set.completeWithRPE(actualReps: 9, rpe: 8, notes: 'Good');
      expect(completed.actualReps, 9);
      expect(completed.rpe, 8);
      expect(completed.isCompleted, true);
      expect(completed.completedAt, isNotNull);
      expect(completed.notes, 'Good');
    });

    test('completeWithRPE without notes', () {
      final set = ExerciseSet(setNumber: 1, reps: 10);
      final completed = set.completeWithRPE(actualReps: 10, rpe: 7);
      expect(completed.isCompleted, true);
      expect(completed.notes, isNull);
    });

    group('isValid', () {
      test('weighted requires weight and reps', () {
        expect(ExerciseSet(setNumber: 1, weight: 80.0, reps: 10).isValid(ExerciseCountingMode.weighted), true);
        expect(ExerciseSet(setNumber: 1, reps: 10).isValid(ExerciseCountingMode.weighted), false);
        expect(ExerciseSet(setNumber: 1, weight: 80.0).isValid(ExerciseCountingMode.weighted), false);
      });

      test('weighted requires positive values', () {
        expect(ExerciseSet(setNumber: 1, weight: 0.0, reps: 10).isValid(ExerciseCountingMode.weighted), false);
        expect(ExerciseSet(setNumber: 1, weight: 80.0, reps: 0).isValid(ExerciseCountingMode.weighted), false);
      });

      test('reps requires only reps', () {
        expect(ExerciseSet(setNumber: 1, reps: 10).isValid(ExerciseCountingMode.reps), true);
        expect(ExerciseSet(setNumber: 1).isValid(ExerciseCountingMode.reps), false);
      });

      test('reps requires positive reps', () {
        expect(ExerciseSet(setNumber: 1, reps: 0).isValid(ExerciseCountingMode.reps), false);
      });

      test('time requires seconds', () {
        expect(ExerciseSet(setNumber: 1, seconds: 60).isValid(ExerciseCountingMode.time), true);
        expect(ExerciseSet(setNumber: 1).isValid(ExerciseCountingMode.time), false);
      });

      test('time requires positive seconds', () {
        expect(ExerciseSet(setNumber: 1, seconds: 0).isValid(ExerciseCountingMode.time), false);
      });
    });

    group('getMissingFields', () {
      test('weighted missing both', () {
        final fields = ExerciseSet(setNumber: 1).getMissingFields(ExerciseCountingMode.weighted);
        expect(fields, containsAll(['weight', 'reps']));
      });

      test('weighted missing only reps', () {
        final fields = ExerciseSet(setNumber: 1, weight: 80.0).getMissingFields(ExerciseCountingMode.weighted);
        expect(fields, ['reps']);
      });

      test('weighted missing only weight', () {
        final fields = ExerciseSet(setNumber: 1, reps: 10).getMissingFields(ExerciseCountingMode.weighted);
        expect(fields, ['weight']);
      });

      test('reps missing reps', () {
        final fields = ExerciseSet(setNumber: 1).getMissingFields(ExerciseCountingMode.reps);
        expect(fields, ['reps']);
      });

      test('time missing seconds', () {
        final fields = ExerciseSet(setNumber: 1).getMissingFields(ExerciseCountingMode.time);
        expect(fields, ['seconds']);
      });

      test('valid returns empty', () {
        final fields = ExerciseSet(setNumber: 1, weight: 80.0, reps: 10)
            .getMissingFields(ExerciseCountingMode.weighted);
        expect(fields, isEmpty);
      });

      test('valid time returns empty', () {
        final fields = ExerciseSet(setNumber: 1, seconds: 60)
            .getMissingFields(ExerciseCountingMode.time);
        expect(fields, isEmpty);
      });
    });

    group('getDisplayText', () {
      test('weighted', () {
        final text = ExerciseSet(setNumber: 1, weight: 80.0, reps: 10)
            .getDisplayText(ExerciseCountingMode.weighted);
        expect(text, '80.0 kg × 10 reps');
      });

      test('weighted with actualReps', () {
        final text = ExerciseSet(setNumber: 1, weight: 80.0, reps: 10, actualReps: 8)
            .getDisplayText(ExerciseCountingMode.weighted);
        expect(text, '80.0 kg × 8 reps');
      });

      test('weighted with no weight uses ?', () {
        final text = ExerciseSet(setNumber: 1, reps: 10)
            .getDisplayText(ExerciseCountingMode.weighted);
        expect(text, '? kg × 10 reps');
      });

      test('weighted with no reps uses ?', () {
        final text = ExerciseSet(setNumber: 1, weight: 80.0)
            .getDisplayText(ExerciseCountingMode.weighted);
        expect(text, '80.0 kg × ? reps');
      });

      test('reps', () {
        final text = ExerciseSet(setNumber: 1, reps: 15)
            .getDisplayText(ExerciseCountingMode.reps);
        expect(text, '15 reps');
      });

      test('reps with actualReps', () {
        final text = ExerciseSet(setNumber: 1, reps: 15, actualReps: 12)
            .getDisplayText(ExerciseCountingMode.reps);
        expect(text, '12 reps');
      });

      test('time with minutes', () {
        final text = ExerciseSet(setNumber: 1, seconds: 90)
            .getDisplayText(ExerciseCountingMode.time);
        expect(text, '1m 30s');
      });

      test('time seconds only', () {
        final text = ExerciseSet(setNumber: 1, seconds: 45)
            .getDisplayText(ExerciseCountingMode.time);
        expect(text, '45s');
      });

      test('time with exactly 60 seconds', () {
        final text = ExerciseSet(setNumber: 1, seconds: 60)
            .getDisplayText(ExerciseCountingMode.time);
        expect(text, '1m 0s');
      });

      test('time with null seconds defaults to 0', () {
        final text = ExerciseSet(setNumber: 1)
            .getDisplayText(ExerciseCountingMode.time);
        expect(text, '0s');
      });
    });
  });

  group('Exercise', () {
    test('constructor generates UUID', () {
      final exercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );
      expect(exercise.id, isNotEmpty);
      expect(exercise.name, 'Bench Press');
      expect(exercise.type, ExerciseType.single);
      expect(exercise.category, ExerciseCategory.chest);
      expect(exercise.sets, isEmpty);
      expect(exercise.countingMode, ExerciseCountingMode.weighted);
    });

    test('constructor with custom id', () {
      final exercise = Exercise(
        id: 'custom-id',
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
      );
      expect(exercise.id, 'custom-id');
    });

    test('constructor with all advanced fields', () {
      final now = DateTime(2024, 6, 1);
      final exercise = Exercise(
        id: 'ex-adv',
        name: 'Deadlift',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
        notes: 'Heavy',
        restTime: 180,
        restAfterExercise: 120,
        tut: '3-1-2-0',
        createdAt: now,
        updatedAt: now,
        autoAdjustmentType: AutoAdjustmentType.rpe,
        calculated1RM: 200.0,
        calculated3RM: 185.0,
        calculated6RM: 170.0,
        calculated10RM: 155.0,
        lastCalculationDate: now,
        calculationMetadata: 'Based on 5 sets, High confidence',
        targetRPEMin: 7.5,
        targetRPEMax: 9.0,
        targetRIR: 2,
        countingMode: ExerciseCountingMode.weighted,
        movementType: MovementType.compoundHeavy,
      );
      expect(exercise.tut, '3-1-2-0');
      expect(exercise.restAfterExercise, 120);
      expect(exercise.autoAdjustmentType, AutoAdjustmentType.rpe);
      expect(exercise.calculated1RM, 200.0);
      expect(exercise.calculated3RM, 185.0);
      expect(exercise.calculated6RM, 170.0);
      expect(exercise.calculated10RM, 155.0);
      expect(exercise.lastCalculationDate, now);
      expect(exercise.calculationMetadata, 'Based on 5 sets, High confidence');
      expect(exercise.targetRPEMin, 7.5);
      expect(exercise.targetRPEMax, 9.0);
      expect(exercise.targetRIR, 2);
      expect(exercise.movementType, MovementType.compoundHeavy);
    });

    test('isCompleted true when all sets completed', () {
      final exercise = Exercise(
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, isCompleted: true),
          ExerciseSet(setNumber: 2, isCompleted: true),
        ],
      );
      expect(exercise.isCompleted, true);
    });

    test('isCompleted false when empty sets', () {
      final exercise = Exercise(
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );
      expect(exercise.isCompleted, false);
    });

    test('isCompleted false when some sets incomplete', () {
      final exercise = Exercise(
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, isCompleted: true),
          ExerciseSet(setNumber: 2, isCompleted: false),
        ],
      );
      expect(exercise.isCompleted, false);
    });

    test('totalVolume', () {
      final exercise = Exercise(
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, weight: 80.0, reps: 10),
          ExerciseSet(setNumber: 2, weight: 80.0, reps: 8),
        ],
      );
      expect(exercise.totalVolume, 1440.0);
    });

    test('totalVolume with empty sets is zero', () {
      final exercise = Exercise(
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );
      expect(exercise.totalVolume, 0.0);
    });

    test('completedAt returns latest', () {
      final earlier = DateTime(2024, 1, 1, 10, 0);
      final later = DateTime(2024, 1, 1, 10, 30);
      final exercise = Exercise(
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [
          ExerciseSet(setNumber: 1, isCompleted: true, completedAt: earlier),
          ExerciseSet(setNumber: 2, isCompleted: true, completedAt: later),
        ],
      );
      expect(exercise.completedAt, later);
    });

    test('completedAt null when no completed sets', () {
      final exercise = Exercise(
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [ExerciseSet(setNumber: 1)],
      );
      expect(exercise.completedAt, isNull);
    });

    test('completedAt null when sets have no completedAt timestamp', () {
      final exercise = Exercise(
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [ExerciseSet(setNumber: 1, isCompleted: true)],
      );
      expect(exercise.completedAt, isNull);
    });

    test('copyWith preserves and overrides', () {
      final original = Exercise(
        name: 'Bench',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        restTime: 90,
      );
      final copy = original.copyWith(name: 'Incline Bench', clearRestTime: true);
      expect(copy.name, 'Incline Bench');
      expect(copy.restTime, isNull);
      expect(copy.category, ExerciseCategory.chest);
    });

    test('copyWith clearRestAfterExercise', () {
      final original = Exercise(
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        restAfterExercise: 120,
      );
      final copy = original.copyWith(clearRestAfterExercise: true);
      expect(copy.restAfterExercise, isNull);
    });

    test('copyWith with id override', () {
      final original = Exercise(
        id: 'original',
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );
      final copy = original.copyWith(id: 'new-id');
      expect(copy.id, 'new-id');
    });

    test('copyWith with advanced fields', () {
      final original = Exercise(
        name: 'Test',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );
      final now = DateTime(2024, 1, 1);
      final copy = original.copyWith(
        calculated1RM: 180.0,
        calculated3RM: 165.0,
        calculated6RM: 150.0,
        calculated10RM: 135.0,
        lastCalculationDate: now,
        calculationMetadata: 'High confidence',
        targetRPEMin: 7.0,
        targetRPEMax: 9.0,
        targetRIR: 2,
        autoAdjustmentType: AutoAdjustmentType.rpe,
        movementType: MovementType.compoundMedium,
        countingMode: ExerciseCountingMode.reps,
        tut: '2-1-2-0',
        restAfterExercise: 90,
      );
      expect(copy.calculated1RM, 180.0);
      expect(copy.calculated3RM, 165.0);
      expect(copy.calculated6RM, 150.0);
      expect(copy.calculated10RM, 135.0);
      expect(copy.lastCalculationDate, now);
      expect(copy.calculationMetadata, 'High confidence');
      expect(copy.targetRPEMin, 7.0);
      expect(copy.targetRPEMax, 9.0);
      expect(copy.targetRIR, 2);
      expect(copy.autoAdjustmentType, AutoAdjustmentType.rpe);
      expect(copy.movementType, MovementType.compoundMedium);
      expect(copy.countingMode, ExerciseCountingMode.reps);
      expect(copy.tut, '2-1-2-0');
      expect(copy.restAfterExercise, 90);
    });

    test('fromJson creates base Exercise', () {
      final json = {
        'id': 'ex-1',
        'name': 'Curl',
        'type': 'single',
        'category': 'arms',
        'sets': [
          {'setNumber': 1, 'weight': 15.0, 'reps': 12, 'isCompleted': false}
        ],
        'notes': 'Focus on form',
        'restTime': 60,
        'countingMode': 'weighted',
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise.id, 'ex-1');
      expect(exercise.name, 'Curl');
      expect(exercise.type, ExerciseType.single);
      expect(exercise.category, ExerciseCategory.arms);
      expect(exercise.sets.length, 1);
      expect(exercise.notes, 'Focus on form');
      expect(exercise.restTime, 60);
    });

    test('fromJson with exerciseId key (template format)', () {
      final json = {
        'exerciseId': 'tmpl-ex-1',
        'exerciseName': 'Push-up',
        'type': 'single',
        'category': 'chest',
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise.id, 'tmpl-ex-1');
      expect(exercise.name, 'Push-up');
    });

    test('fromJson with createdAt and updatedAt', () {
      final json = {
        'name': 'Test',
        'type': 'single',
        'category': 'chest',
        'createdAt': '2024-01-01T09:00:00.000',
        'updatedAt': '2024-06-01T12:00:00.000',
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise.createdAt, DateTime(2024, 1, 1, 9, 0));
      expect(exercise.updatedAt, DateTime(2024, 6, 1, 12, 0));
    });

    test('fromJson with all advanced fields', () {
      final json = {
        'id': 'ex-adv',
        'name': 'Deadlift',
        'type': 'single',
        'category': 'back',
        'restAfterExercise': 120,
        'tut': '3-1-2-0',
        'autoAdjustmentType': 'rpe',
        'calculated1RM': 200.0,
        'calculated3RM': 185.0,
        'calculated6RM': 170.0,
        'calculated10RM': 155.0,
        'lastCalculationDate': '2024-01-01T00:00:00.000',
        'calculationMetadata': 'High confidence',
        'targetRPEMin': 7.5,
        'targetRPEMax': 9.0,
        'targetRIR': 2,
        'countingMode': 'weighted',
        'movementType': 'compoundHeavy',
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise.tut, '3-1-2-0');
      expect(exercise.restAfterExercise, 120);
      expect(exercise.autoAdjustmentType, AutoAdjustmentType.rpe);
      expect(exercise.calculated1RM, 200.0);
      expect(exercise.calculated3RM, 185.0);
      expect(exercise.calculated6RM, 170.0);
      expect(exercise.calculated10RM, 155.0);
      expect(exercise.calculationMetadata, 'High confidence');
      expect(exercise.targetRPEMin, 7.5);
      expect(exercise.targetRPEMax, 9.0);
      expect(exercise.targetRIR, 2);
      expect(exercise.movementType, MovementType.compoundHeavy);
    });

    test('fromJson restTime as double (Firebase format)', () {
      final json = {
        'name': 'Test',
        'type': 'single',
        'category': 'chest',
        'restTime': 90.0, // Firebase stores as double
        'restAfterExercise': 60.0,
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise.restTime, 90); // Must be int
      expect(exercise.restAfterExercise, 60); // Must be int
    });

    test('fromJson with unknown category defaults to other', () {
      final json = {
        'name': 'Test',
        'type': 'single',
        'category': 'unknown_category',
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise.category, ExerciseCategory.other);
    });

    test('fromJson with unknown movementType defaults to isolationLight', () {
      final json = {
        'name': 'Test',
        'type': 'single',
        'category': 'chest',
        'movementType': 'unknown_type',
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise.movementType, MovementType.isolationLight);
    });

    test('fromJson with unknown autoAdjustmentType defaults to rpe', () {
      final json = {
        'name': 'Test',
        'type': 'single',
        'category': 'chest',
        'autoAdjustmentType': 'unknown',
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise.autoAdjustmentType, AutoAdjustmentType.rpe);
    });

    test('fromJson with null countingMode defaults to weighted', () {
      final json = {
        'name': 'Test',
        'type': 'single',
        'category': 'chest',
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise.countingMode, ExerciseCountingMode.weighted);
    });

    test('fromJson with unknown type defaults to single', () {
      final json = {
        'name': 'Test',
        'type': 'unknown_type',
        'category': 'other',
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise.type, ExerciseType.single);
    });

    test('fromJson with missing name uses fallback', () {
      final json = {
        'type': 'single',
        'category': 'other',
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise.name, 'Unknown Exercise');
    });

    test('toJson round-trip', () {
      final exercise = Exercise(
        id: 'ex-1',
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [ExerciseSet(setNumber: 1, weight: 80.0, reps: 10)],
        restTime: 90,
        movementType: MovementType.compoundMedium,
      );
      final json = exercise.toJson();
      expect(json['id'], 'ex-1');
      expect(json['name'], 'Bench Press');
      expect(json['type'], 'single');
      expect(json['category'], 'chest');
      expect(json['restTime'], 90);
      expect(json['movementType'], 'compoundMedium');
      expect((json['sets'] as List).length, 1);
    });

    test('toJson with all advanced fields', () {
      final now = DateTime(2024, 1, 1);
      final exercise = Exercise(
        id: 'ex-full',
        name: 'Deadlift',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
        tut: '3-1-2-0',
        restAfterExercise: 120,
        autoAdjustmentType: AutoAdjustmentType.rpe,
        calculated1RM: 200.0,
        calculated3RM: 185.0,
        calculated6RM: 170.0,
        calculated10RM: 155.0,
        lastCalculationDate: now,
        calculationMetadata: 'High confidence',
        targetRPEMin: 7.5,
        targetRPEMax: 9.0,
        targetRIR: 2,
        countingMode: ExerciseCountingMode.reps,
      );
      final json = exercise.toJson();
      expect(json['tut'], '3-1-2-0');
      expect(json['restAfterExercise'], 120);
      expect(json['autoAdjustmentType'], 'rpe');
      expect(json['calculated1RM'], 200.0);
      expect(json['calculated3RM'], 185.0);
      expect(json['calculated6RM'], 170.0);
      expect(json['calculated10RM'], 155.0);
      expect(json['calculationMetadata'], 'High confidence');
      expect(json['targetRPEMin'], 7.5);
      expect(json['targetRPEMax'], 9.0);
      expect(json['targetRIR'], 2);
      expect(json['countingMode'], 'reps');
    });

    test('fromJson dispatches superset type', () {
      final json = {
        'name': 'Super',
        'type': 'superset',
        'category': 'chest',
        'exercises': [
          {'name': 'A', 'type': 'single', 'category': 'chest', 'sets': []},
        ],
        'supersetSets': [],
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise, isA<SupersetExercise>());
    });

    test('fromJson dispatches dropset type', () {
      final json = {
        'name': 'Drop',
        'type': 'dropset',
        'category': 'chest',
        'stages': [
          {'weight': 80.0, 'reps': 10, 'isCompleted': false},
        ],
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise, isA<DropSetExercise>());
    });

    test('fromJson dispatches restPause type', () {
      final json = {
        'name': 'RP',
        'type': 'restPause',
        'category': 'arms',
        'weight': 20.0,
        'targetReps': 8,
        'restPauseSets': [
          {'reps': 8, 'restSeconds': 15, 'isCompleted': false},
        ],
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise, isA<RestPauseExercise>());
    });
  });

  group('SupersetExerciseData', () {
    test('constructor', () {
      const data = SupersetExerciseData(
        exerciseId: 'ex-1',
        exerciseName: 'Bench',
        targetWeight: 80.0,
        targetReps: 10,
      );
      expect(data.exerciseId, 'ex-1');
      expect(data.exerciseName, 'Bench');
      expect(data.targetWeight, 80.0);
      expect(data.isCompleted, false);
    });

    test('fromJson', () {
      final json = {
        'exerciseId': 'ex-1',
        'exerciseName': 'Bench',
        'targetWeight': 80.0,
        'targetReps': 10,
        'targetMinReps': 8,
        'targetMaxReps': 12,
        'actualWeight': 80.0,
        'actualReps': 9,
        'rpe': 8,
        'isCompleted': true,
        'notes': 'test',
      };
      final data = SupersetExerciseData.fromJson(json);
      expect(data.exerciseId, 'ex-1');
      expect(data.targetWeight, 80.0);
      expect(data.targetMinReps, 8);
      expect(data.targetMaxReps, 12);
      expect(data.actualWeight, 80.0);
      expect(data.actualReps, 9);
      expect(data.rpe, 8);
      expect(data.isCompleted, true);
      expect(data.notes, 'test');
    });

    test('fromJson with missing exerciseId defaults to empty string', () {
      final json = {'exerciseName': 'Test'};
      final data = SupersetExerciseData.fromJson(json);
      expect(data.exerciseId, '');
      expect(data.exerciseName, 'Test');
    });

    test('hasRepRange', () {
      const withRange = SupersetExerciseData(
        exerciseId: 'x', exerciseName: 'x',
        targetMinReps: 8, targetMaxReps: 12,
      );
      expect(withRange.hasRepRange, true);

      const sameRange = SupersetExerciseData(
        exerciseId: 'x', exerciseName: 'x',
        targetMinReps: 10, targetMaxReps: 10,
      );
      expect(sameRange.hasRepRange, false);

      const noRange = SupersetExerciseData(exerciseId: 'x', exerciseName: 'x');
      expect(noRange.hasRepRange, false);
    });

    test('repsDisplay', () {
      const range = SupersetExerciseData(
        exerciseId: 'x', exerciseName: 'x',
        targetMinReps: 8, targetMaxReps: 12,
      );
      expect(range.repsDisplay, '8-12');

      const single = SupersetExerciseData(
        exerciseId: 'x', exerciseName: 'x',
        targetReps: 10,
      );
      expect(single.repsDisplay, '10');

      const empty = SupersetExerciseData(exerciseId: 'x', exerciseName: 'x');
      expect(empty.repsDisplay, '-');

      // targetMinReps only (no range)
      const minOnly = SupersetExerciseData(
        exerciseId: 'x', exerciseName: 'x',
        targetMinReps: 8,
      );
      expect(minOnly.repsDisplay, '8');
    });

    test('copyWith', () {
      const data = SupersetExerciseData(
        exerciseId: 'ex-1',
        exerciseName: 'Bench',
        targetWeight: 80.0,
      );
      final copy = data.copyWith(actualWeight: 80.0, isCompleted: true);
      expect(copy.exerciseId, 'ex-1');
      expect(copy.actualWeight, 80.0);
      expect(copy.isCompleted, true);
    });

    test('copyWith all fields', () {
      const data = SupersetExerciseData(
        exerciseId: 'ex-1',
        exerciseName: 'Bench',
      );
      final copy = data.copyWith(
        exerciseId: 'ex-2',
        exerciseName: 'Squat',
        targetWeight: 100.0,
        targetReps: 5,
        targetMinReps: 4,
        targetMaxReps: 6,
        actualWeight: 100.0,
        actualReps: 5,
        rpe: 9,
        isCompleted: true,
        notes: 'PR!',
      );
      expect(copy.exerciseId, 'ex-2');
      expect(copy.exerciseName, 'Squat');
      expect(copy.targetWeight, 100.0);
      expect(copy.targetReps, 5);
      expect(copy.targetMinReps, 4);
      expect(copy.targetMaxReps, 6);
      expect(copy.actualWeight, 100.0);
      expect(copy.actualReps, 5);
      expect(copy.rpe, 9);
      expect(copy.isCompleted, true);
      expect(copy.notes, 'PR!');
    });

    test('toJson round-trip', () {
      const data = SupersetExerciseData(
        exerciseId: 'ex-1',
        exerciseName: 'Bench',
        targetWeight: 80.0,
        targetReps: 10,
        targetMinReps: 8,
        targetMaxReps: 12,
      );
      final json = data.toJson();
      expect(json['exerciseId'], 'ex-1');
      expect(json['targetWeight'], 80.0);
      expect(json['targetMinReps'], 8);
      expect(json['targetMaxReps'], 12);

      final restored = SupersetExerciseData.fromJson(json);
      expect(restored.exerciseId, data.exerciseId);
      expect(restored.targetWeight, data.targetWeight);
    });

    test('toJson omits null targetMinReps/targetMaxReps', () {
      const data = SupersetExerciseData(exerciseId: 'x', exerciseName: 'x');
      final json = data.toJson();
      expect(json.containsKey('targetMinReps'), false);
      expect(json.containsKey('targetMaxReps'), false);
    });
  });

  group('SupersetSet', () {
    test('constructor with defaults', () {
      final set = SupersetSet(
        setNumber: 1,
        exerciseData: {},
      );
      expect(set.setNumber, 1);
      expect(set.isCompleted, false);
      expect(set.isWarmup, false);
      expect(set.exerciseData, isEmpty);
      expect(set.id, isNotEmpty);
    });

    test('constructor with custom id', () {
      final set = SupersetSet(
        id: 'custom-id',
        setNumber: 1,
        exerciseData: {},
      );
      expect(set.id, 'custom-id');
    });

    test('constructor with all fields', () {
      final now = DateTime(2024, 1, 1);
      final set = SupersetSet(
        id: 'ss-1',
        setNumber: 2,
        exerciseData: {
          'ex-1': const SupersetExerciseData(exerciseId: 'ex-1', exerciseName: 'Bench', isCompleted: true),
        },
        isCompleted: true,
        completedAt: now,
        setDurationMillis: 60000.0,
        setStartedAt: now,
        isWarmup: true,
        notes: 'Good round',
      );
      expect(set.isCompleted, true);
      expect(set.completedAt, now);
      expect(set.setDurationMillis, 60000.0);
      expect(set.isWarmup, true);
      expect(set.notes, 'Good round');
    });

    test('fromJson basic', () {
      final json = <String, dynamic>{
        'id': 'ss-1',
        'setNumber': 1,
        'exerciseData': <String, dynamic>{
          'ex-1': <String, dynamic>{
            'exerciseId': 'ex-1',
            'exerciseName': 'Bench',
            'targetWeight': 80.0,
            'targetReps': 10,
            'isCompleted': false,
          },
        },
        'isCompleted': false,
        'isWarmup': false,
      };
      final set = SupersetSet.fromJson(json);
      expect(set.id, 'ss-1');
      expect(set.setNumber, 1);
      expect(set.exerciseData['ex-1']?.exerciseName, 'Bench');
      expect(set.isCompleted, false);
    });

    test('fromJson with completedAt and setStartedAt', () {
      final json = <String, dynamic>{
        'setNumber': 1,
        'exerciseData': <String, dynamic>{},
        'completedAt': '2024-01-01T10:00:00.000',
        'setStartedAt': '2024-01-01T09:55:00.000',
        'setDurationMillis': 300000.0,
        'isWarmup': true,
        'notes': 'Warm-up round',
      };
      final set = SupersetSet.fromJson(json);
      expect(set.completedAt, DateTime(2024, 1, 1, 10, 0));
      expect(set.setStartedAt, DateTime(2024, 1, 1, 9, 55));
      expect(set.setDurationMillis, 300000.0);
      expect(set.isWarmup, true);
      expect(set.notes, 'Warm-up round');
    });

    test('fromJson with empty exerciseData', () {
      final json = {
        'setNumber': 1,
      };
      final set = SupersetSet.fromJson(json);
      expect(set.exerciseData, isEmpty);
    });

    test('toJson round-trip', () {
      final set = SupersetSet(
        id: 'ss-1',
        setNumber: 1,
        exerciseData: {
          'ex-1': const SupersetExerciseData(
            exerciseId: 'ex-1',
            exerciseName: 'Bench',
            targetWeight: 80.0,
            targetReps: 10,
          ),
        },
        isCompleted: false,
      );
      final json = set.toJson();
      expect(json['id'], 'ss-1');
      expect(json['setNumber'], 1);
      expect(json['isCompleted'], false);
      final exerciseDataJson = json['exerciseData'] as Map<String, dynamic>;
      expect(exerciseDataJson.containsKey('ex-1'), true);
    });

    test('isFullyCompleted when all exercises completed', () {
      final set = SupersetSet(
        setNumber: 1,
        exerciseData: {
          'ex-1': const SupersetExerciseData(exerciseId: 'ex-1', exerciseName: 'A', isCompleted: true),
          'ex-2': const SupersetExerciseData(exerciseId: 'ex-2', exerciseName: 'B', isCompleted: true),
        },
      );
      expect(set.isFullyCompleted, true);
    });

    test('isFullyCompleted false when any exercise not completed', () {
      final set = SupersetSet(
        setNumber: 1,
        exerciseData: {
          'ex-1': const SupersetExerciseData(exerciseId: 'ex-1', exerciseName: 'A', isCompleted: true),
          'ex-2': const SupersetExerciseData(exerciseId: 'ex-2', exerciseName: 'B', isCompleted: false),
        },
      );
      expect(set.isFullyCompleted, false);
    });

    test('isFullyCompleted true when empty', () {
      final set = SupersetSet(setNumber: 1, exerciseData: {});
      expect(set.isFullyCompleted, true);
    });

    test('completedExercisesCount', () {
      final set = SupersetSet(
        setNumber: 1,
        exerciseData: {
          'ex-1': const SupersetExerciseData(exerciseId: 'ex-1', exerciseName: 'A', isCompleted: true),
          'ex-2': const SupersetExerciseData(exerciseId: 'ex-2', exerciseName: 'B', isCompleted: false),
          'ex-3': const SupersetExerciseData(exerciseId: 'ex-3', exerciseName: 'C', isCompleted: true),
        },
      );
      expect(set.completedExercisesCount, 2);
    });

    test('copyWith', () {
      final set = SupersetSet(setNumber: 1, exerciseData: {});
      final copy = set.copyWith(setNumber: 2, isCompleted: true);
      expect(copy.setNumber, 2);
      expect(copy.isCompleted, true);
      expect(copy.id, set.id);
    });

    test('copyWith with exerciseData', () {
      final original = SupersetSet(setNumber: 1, exerciseData: {});
      final newData = {
        'ex-1': const SupersetExerciseData(exerciseId: 'ex-1', exerciseName: 'Bench'),
      };
      final copy = original.copyWith(exerciseData: newData);
      expect(copy.exerciseData.containsKey('ex-1'), true);
    });

    test('copyWith preserves exerciseData as copy', () {
      final originalData = {
        'ex-1': const SupersetExerciseData(exerciseId: 'ex-1', exerciseName: 'Bench'),
      };
      final original = SupersetSet(setNumber: 1, exerciseData: originalData);
      final copy = original.copyWith();
      // Should be a copy, not same reference
      expect(copy.exerciseData, isNot(same(originalData)));
    });
  });

  group('SupersetExercise', () {
    SupersetExercise _buildSuperset({
      String id = 'ss-ex',
      List<Exercise>? exercises,
      List<SupersetSet>? supersetSets,
    }) {
      exercises ??= [
        Exercise(
          id: 'child-1',
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
        ),
        Exercise(
          id: 'child-2',
          name: 'Row',
          type: ExerciseType.single,
          category: ExerciseCategory.back,
        ),
      ];
      return SupersetExercise(
        id: id,
        name: 'Bench + Row',
        exercises: exercises,
        supersetSets: supersetSets ?? [],
      );
    }

    test('constructor inherits first exercise category', () {
      final ss = _buildSuperset();
      expect(ss.category, ExerciseCategory.chest);
      expect(ss.type, ExerciseType.superset);
    });

    test('constructor with empty exercises defaults to other', () {
      final ss = SupersetExercise(
        name: 'Empty Superset',
        exercises: [],
      );
      expect(ss.category, ExerciseCategory.other);
    });

    test('isCompleted with empty supersetSets is false', () {
      final ss = _buildSuperset();
      expect(ss.isCompleted, false);
    });

    test('isCompleted true when all supersetSets completed', () {
      final ss = _buildSuperset(
        supersetSets: [
          SupersetSet(setNumber: 1, exerciseData: {}, isCompleted: true),
          SupersetSet(setNumber: 2, exerciseData: {}, isCompleted: true),
        ],
      );
      expect(ss.isCompleted, true);
    });

    test('isCompleted false when any supersetSet not completed', () {
      final ss = _buildSuperset(
        supersetSets: [
          SupersetSet(setNumber: 1, exerciseData: {}, isCompleted: true),
          SupersetSet(setNumber: 2, exerciseData: {}, isCompleted: false),
        ],
      );
      expect(ss.isCompleted, false);
    });

    test('completedAt returns latest from supersetSets', () {
      final earlier = DateTime(2024, 1, 1, 10, 0);
      final later = DateTime(2024, 1, 1, 11, 0);
      final ss = _buildSuperset(
        supersetSets: [
          SupersetSet(setNumber: 1, exerciseData: {}, isCompleted: true, completedAt: earlier),
          SupersetSet(setNumber: 2, exerciseData: {}, isCompleted: true, completedAt: later),
        ],
      );
      expect(ss.completedAt, later);
    });

    test('completedAt null when no completed supersetSets', () {
      final ss = _buildSuperset(
        supersetSets: [
          SupersetSet(setNumber: 1, exerciseData: {}),
        ],
      );
      expect(ss.completedAt, isNull);
    });

    test('totalVolume sums all exercise data', () {
      final supersetSets = [
        SupersetSet(
          setNumber: 1,
          exerciseData: {
            'ex-1': const SupersetExerciseData(
              exerciseId: 'ex-1', exerciseName: 'Bench',
              targetWeight: 80.0, targetReps: 10,
            ),
            'ex-2': const SupersetExerciseData(
              exerciseId: 'ex-2', exerciseName: 'Row',
              targetWeight: 60.0, targetReps: 12,
            ),
          },
        ),
      ];
      final ss = _buildSuperset(supersetSets: supersetSets);
      // 80*10 + 60*12 = 800 + 720 = 1520
      expect(ss.totalVolume, 1520.0);
    });

    test('totalVolume uses actualWeight/actualReps when available', () {
      final supersetSets = [
        SupersetSet(
          setNumber: 1,
          exerciseData: {
            'ex-1': const SupersetExerciseData(
              exerciseId: 'ex-1', exerciseName: 'Bench',
              targetWeight: 80.0, targetReps: 10,
              actualWeight: 85.0, actualReps: 9,
            ),
          },
        ),
      ];
      final ss = _buildSuperset(supersetSets: supersetSets);
      // 85*9 = 765
      expect(ss.totalVolume, 765.0);
    });

    test('totalVolume empty is zero', () {
      final ss = _buildSuperset();
      expect(ss.totalVolume, 0.0);
    });

    test('completedRoundsCount', () {
      final ss = _buildSuperset(
        supersetSets: [
          SupersetSet(
            setNumber: 1,
            exerciseData: {
              'child-1': const SupersetExerciseData(exerciseId: 'child-1', exerciseName: 'A', isCompleted: true),
              'child-2': const SupersetExerciseData(exerciseId: 'child-2', exerciseName: 'B', isCompleted: true),
            },
            isCompleted: true,
          ),
          SupersetSet(
            setNumber: 2,
            exerciseData: {
              'child-1': const SupersetExerciseData(exerciseId: 'child-1', exerciseName: 'A', isCompleted: false),
              'child-2': const SupersetExerciseData(exerciseId: 'child-2', exerciseName: 'B', isCompleted: false),
            },
          ),
        ],
      );
      // isFullyCompleted checks exerciseData completions, but completedRoundsCount checks isFullyCompleted
      // The first set has both exercises completed so isFullyCompleted = true
      expect(ss.completedRoundsCount, 1);
    });

    test('completionPercentage', () {
      final ss = _buildSuperset(
        supersetSets: [
          SupersetSet(
            setNumber: 1,
            exerciseData: {
              'child-1': const SupersetExerciseData(exerciseId: 'child-1', exerciseName: 'A', isCompleted: true),
              'child-2': const SupersetExerciseData(exerciseId: 'child-2', exerciseName: 'B', isCompleted: true),
            },
          ),
          SupersetSet(
            setNumber: 2,
            exerciseData: {
              'child-1': const SupersetExerciseData(exerciseId: 'child-1', exerciseName: 'A', isCompleted: false),
              'child-2': const SupersetExerciseData(exerciseId: 'child-2', exerciseName: 'B', isCompleted: false),
            },
          ),
        ],
      );
      expect(ss.completionPercentage, 50.0);
    });

    test('completionPercentage zero when empty', () {
      final ss = _buildSuperset();
      expect(ss.completionPercentage, 0.0);
    });

    test('isDataConsistent when all sets have data for all exercises', () {
      final exercises = [
        Exercise(id: 'child-1', name: 'Bench', type: ExerciseType.single, category: ExerciseCategory.chest),
        Exercise(id: 'child-2', name: 'Row', type: ExerciseType.single, category: ExerciseCategory.back),
      ];
      final ss = SupersetExercise(
        name: 'Bench + Row',
        exercises: exercises,
        supersetSets: [
          SupersetSet(
            setNumber: 1,
            exerciseData: {
              'child-1': const SupersetExerciseData(exerciseId: 'child-1', exerciseName: 'Bench'),
              'child-2': const SupersetExerciseData(exerciseId: 'child-2', exerciseName: 'Row'),
            },
          ),
        ],
      );
      expect(ss.isDataConsistent, true);
    });

    test('isDataConsistent false when set missing exercise data', () {
      final exercises = [
        Exercise(id: 'child-1', name: 'Bench', type: ExerciseType.single, category: ExerciseCategory.chest),
        Exercise(id: 'child-2', name: 'Row', type: ExerciseType.single, category: ExerciseCategory.back),
      ];
      final ss = SupersetExercise(
        name: 'Bench + Row',
        exercises: exercises,
        supersetSets: [
          SupersetSet(
            setNumber: 1,
            exerciseData: {
              'child-1': const SupersetExerciseData(exerciseId: 'child-1', exerciseName: 'Bench'),
              // Missing child-2
            },
          ),
        ],
      );
      expect(ss.isDataConsistent, false);
    });

    test('ensureConsistency returns self when already consistent', () {
      final exercises = [
        Exercise(id: 'child-1', name: 'Bench', type: ExerciseType.single, category: ExerciseCategory.chest),
      ];
      final ss = SupersetExercise(
        name: 'Test',
        exercises: exercises,
        supersetSets: [
          SupersetSet(
            setNumber: 1,
            exerciseData: {
              'child-1': const SupersetExerciseData(exerciseId: 'child-1', exerciseName: 'Bench'),
            },
          ),
        ],
      );
      final result = ss.ensureConsistency();
      expect(result, same(ss));
    });

    test('ensureConsistency adds missing exercise data', () {
      final exercises = [
        Exercise(id: 'child-1', name: 'Bench', type: ExerciseType.single, category: ExerciseCategory.chest),
        Exercise(id: 'child-2', name: 'Row', type: ExerciseType.single, category: ExerciseCategory.back),
      ];
      final ss = SupersetExercise(
        name: 'Test',
        exercises: exercises,
        supersetSets: [
          SupersetSet(
            setNumber: 1,
            exerciseData: {
              'child-1': const SupersetExerciseData(exerciseId: 'child-1', exerciseName: 'Bench'),
              // child-2 missing
            },
          ),
        ],
      );
      final result = ss.ensureConsistency();
      expect(result.supersetSets.first.exerciseData.containsKey('child-2'), true);
      expect(result.supersetSets.first.exerciseData['child-2']?.exerciseName, 'Row');
    });

    test('ensureConsistency preserves existing exercise data', () {
      const existingData = SupersetExerciseData(
        exerciseId: 'child-1',
        exerciseName: 'Bench',
        targetWeight: 100.0,
        targetReps: 5,
      );
      final exercises = [
        Exercise(id: 'child-1', name: 'Bench', type: ExerciseType.single, category: ExerciseCategory.chest),
        Exercise(id: 'child-2', name: 'Row', type: ExerciseType.single, category: ExerciseCategory.back),
      ];
      final ss = SupersetExercise(
        name: 'Test',
        exercises: exercises,
        supersetSets: [
          SupersetSet(
            setNumber: 1,
            exerciseData: {'child-1': existingData},
          ),
        ],
      );
      final result = ss.ensureConsistency();
      final restoredData = result.supersetSets.first.exerciseData['child-1']!;
      expect(restoredData.targetWeight, 100.0);
      expect(restoredData.targetReps, 5);
    });

    test('fromJson round-trip', () {
      final json = <String, dynamic>{
        'id': 'ss-id',
        'name': 'Bench + Row',
        'type': 'superset',
        'category': 'chest',
        'exercises': <dynamic>[
          <String, dynamic>{'id': 'ex-1', 'name': 'Bench', 'type': 'single', 'category': 'chest', 'sets': <dynamic>[]},
          <String, dynamic>{'id': 'ex-2', 'name': 'Row', 'type': 'single', 'category': 'back', 'sets': <dynamic>[]},
        ],
        'supersetSets': <dynamic>[
          <String, dynamic>{
            'setNumber': 1,
            'exerciseData': <String, dynamic>{
              'ex-1': <String, dynamic>{'exerciseId': 'ex-1', 'exerciseName': 'Bench', 'targetWeight': 80.0, 'targetReps': 10, 'isCompleted': false},
              'ex-2': <String, dynamic>{'exerciseId': 'ex-2', 'exerciseName': 'Row', 'targetWeight': 60.0, 'targetReps': 12, 'isCompleted': false},
            },
            'isCompleted': false,
          },
        ],
        'restTime': 120,
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise, isA<SupersetExercise>());
      final ss = exercise as SupersetExercise;
      expect(ss.id, 'ss-id');
      expect(ss.name, 'Bench + Row');
      expect(ss.exercises.length, 2);
      expect(ss.supersetSets.length, 1);
      expect(ss.restTime, 120);
    });

    test('fromJson with advanced fields', () {
      final json = {
        'name': 'Super',
        'type': 'superset',
        'category': 'chest',
        'exercises': [],
        'supersetSets': [],
        'restAfterExercise': 90,
        'autoAdjustmentType': 'rpe',
        'calculated1RM': 150.0,
        'targetRPEMin': 7.0,
        'targetRPEMax': 9.0,
        'targetRIR': 1,
        'countingMode': 'weighted',
        'movementType': 'compoundMedium',
        'lastCalculationDate': '2024-01-01T00:00:00.000',
        'calculationMetadata': 'test',
      };
      final exercise = Exercise.fromJson(json);
      final ss = exercise as SupersetExercise;
      expect(ss.restAfterExercise, 90);
      expect(ss.autoAdjustmentType, AutoAdjustmentType.rpe);
      expect(ss.calculated1RM, 150.0);
      expect(ss.targetRPEMin, 7.0);
      expect(ss.targetRPEMax, 9.0);
      expect(ss.targetRIR, 1);
      expect(ss.movementType, MovementType.compoundMedium);
    });

    test('toJson includes exercises and supersetSets', () {
      final ss = _buildSuperset(
        supersetSets: [
          SupersetSet(
            setNumber: 1,
            exerciseData: {
              'child-1': const SupersetExerciseData(exerciseId: 'child-1', exerciseName: 'Bench'),
            },
          ),
        ],
      );
      final json = ss.toJson();
      expect(json['type'], 'superset');
      expect((json['exercises'] as List).length, 2);
      expect((json['supersetSets'] as List).length, 1);
    });

    test('copyWith preserves exercises and supersetSets', () {
      final ss = _buildSuperset();
      final copy = ss.copyWith(name: 'New Name');
      expect(copy.name, 'New Name');
      expect(copy.exercises.length, 2);
    });

    test('copyWith with clearRestTime', () {
      final ss = SupersetExercise(
        name: 'Test',
        exercises: [],
        restTime: 90,
      );
      final copy = ss.copyWith(clearRestTime: true);
      expect(copy.restTime, isNull);
    });

    test('copyWith with clearRestAfterExercise', () {
      final ss = SupersetExercise(
        name: 'Test',
        exercises: [],
        restAfterExercise: 60,
      );
      final copy = ss.copyWith(clearRestAfterExercise: true);
      expect(copy.restAfterExercise, isNull);
    });

    test('copyWith with new exercises and supersetSets', () {
      final ss = _buildSuperset();
      final newExercises = [
        Exercise(id: 'new-1', name: 'Squat', type: ExerciseType.single, category: ExerciseCategory.legs),
      ];
      final newSets = [
        SupersetSet(setNumber: 1, exerciseData: {}, isCompleted: true),
      ];
      final copy = ss.copyWith(exercises: newExercises, supersetSets: newSets);
      expect(copy.exercises.length, 1);
      expect(copy.exercises.first.name, 'Squat');
      expect(copy.supersetSets.length, 1);
    });
  });

  group('DropSetStage', () {
    test('constructor', () {
      final stage = DropSetStage(
        weight: 80.0,
        reps: 10,
      );
      expect(stage.weight, 80.0);
      expect(stage.reps, 10);
      expect(stage.isCompleted, false);
      expect(stage.actualReps, isNull);
    });

    test('constructor with all fields', () {
      final now = DateTime(2024, 1, 1);
      final stage = DropSetStage(
        weight: 80.0,
        reps: 10,
        minReps: 8,
        maxReps: 12,
        actualReps: 9,
        rpe: 8,
        isCompleted: true,
        completedAt: now,
      );
      expect(stage.minReps, 8);
      expect(stage.maxReps, 12);
      expect(stage.actualReps, 9);
      expect(stage.rpe, 8);
      expect(stage.isCompleted, true);
      expect(stage.completedAt, now);
    });

    test('fromJson', () {
      final json = {
        'weight': 80.0,
        'reps': 10,
        'minReps': 8,
        'maxReps': 12,
        'actualReps': 9,
        'rpe': 8,
        'isCompleted': true,
        'completedAt': '2024-01-01T10:00:00.000',
      };
      final stage = DropSetStage.fromJson(json);
      expect(stage.weight, 80.0);
      expect(stage.reps, 10);
      expect(stage.minReps, 8);
      expect(stage.maxReps, 12);
      expect(stage.actualReps, 9);
      expect(stage.rpe, 8);
      expect(stage.isCompleted, true);
      expect(stage.completedAt, DateTime(2024, 1, 1, 10, 0));
    });

    test('fromJson with null weight defaults to 0', () {
      final json = {'reps': 10};
      final stage = DropSetStage.fromJson(json);
      expect(stage.weight, 0.0);
      expect(stage.reps, 10);
    });

    test('fromJson with null reps defaults to 0', () {
      final json = {'weight': 80.0};
      final stage = DropSetStage.fromJson(json);
      expect(stage.reps, 0);
    });

    test('fromJson with null completedAt', () {
      final json = {'weight': 80.0, 'reps': 10, 'completedAt': null};
      final stage = DropSetStage.fromJson(json);
      expect(stage.completedAt, isNull);
    });

    test('effectiveReps uses actualReps when available', () {
      final stage = DropSetStage(weight: 80.0, reps: 10, actualReps: 8);
      expect(stage.effectiveReps, 8);
    });

    test('effectiveReps falls back to reps', () {
      final stage = DropSetStage(weight: 80.0, reps: 10);
      expect(stage.effectiveReps, 10);
    });

    test('hasRepRange true', () {
      final stage = DropSetStage(weight: 80.0, reps: 10, minReps: 8, maxReps: 12);
      expect(stage.hasRepRange, true);
    });

    test('hasRepRange false when same', () {
      final stage = DropSetStage(weight: 80.0, reps: 10, minReps: 10, maxReps: 10);
      expect(stage.hasRepRange, false);
    });

    test('hasRepRange false when null', () {
      final stage = DropSetStage(weight: 80.0, reps: 10);
      expect(stage.hasRepRange, false);
    });

    test('copyWith', () {
      final original = DropSetStage(weight: 80.0, reps: 10);
      final copy = original.copyWith(weight: 60.0, actualReps: 12, isCompleted: true);
      expect(copy.weight, 60.0);
      expect(copy.reps, 10); // preserved
      expect(copy.actualReps, 12);
      expect(copy.isCompleted, true);
    });

    test('copyWith all fields', () {
      final original = DropSetStage(weight: 80.0, reps: 10);
      final now = DateTime(2024, 6, 1);
      final copy = original.copyWith(
        weight: 70.0,
        reps: 8,
        minReps: 6,
        maxReps: 10,
        actualReps: 7,
        rpe: 9,
        isCompleted: true,
        completedAt: now,
      );
      expect(copy.weight, 70.0);
      expect(copy.reps, 8);
      expect(copy.minReps, 6);
      expect(copy.maxReps, 10);
      expect(copy.actualReps, 7);
      expect(copy.rpe, 9);
      expect(copy.isCompleted, true);
      expect(copy.completedAt, now);
    });

    test('toJson', () {
      final now = DateTime(2024, 1, 1);
      final stage = DropSetStage(
        weight: 80.0,
        reps: 10,
        minReps: 8,
        maxReps: 12,
        actualReps: 9,
        rpe: 8,
        isCompleted: true,
        completedAt: now,
      );
      final json = stage.toJson();
      expect(json['weight'], 80.0);
      expect(json['reps'], 10);
      expect(json['minReps'], 8);
      expect(json['maxReps'], 12);
      expect(json['actualReps'], 9);
      expect(json['rpe'], 8);
      expect(json['isCompleted'], true);
      expect(json['completedAt'], isNotNull);
    });

    test('toJson omits null minReps/maxReps', () {
      final stage = DropSetStage(weight: 80.0, reps: 10);
      final json = stage.toJson();
      expect(json.containsKey('minReps'), false);
      expect(json.containsKey('maxReps'), false);
    });
  });

  group('DropSetExercise', () {
    DropSetExercise _buildDropSet({
      String id = 'ds-1',
      List<DropSetStage>? stages,
    }) {
      stages ??= [
        DropSetStage(weight: 80.0, reps: 10),
        DropSetStage(weight: 60.0, reps: 12),
        DropSetStage(weight: 40.0, reps: 15),
      ];
      return DropSetExercise(
        id: id,
        name: 'Drop Set Bench',
        category: ExerciseCategory.chest,
        stages: stages,
      );
    }

    test('constructor', () {
      final ds = _buildDropSet();
      expect(ds.id, 'ds-1');
      expect(ds.name, 'Drop Set Bench');
      expect(ds.type, ExerciseType.dropset);
      expect(ds.stages.length, 3);
    });

    test('isCompleted false when empty stages', () {
      final ds = DropSetExercise(
        name: 'Test', category: ExerciseCategory.chest, stages: [],
      );
      expect(ds.isCompleted, false);
    });

    test('isCompleted true when all stages completed', () {
      final ds = _buildDropSet(
        stages: [
          DropSetStage(weight: 80.0, reps: 10, isCompleted: true),
          DropSetStage(weight: 60.0, reps: 12, isCompleted: true),
        ],
      );
      expect(ds.isCompleted, true);
    });

    test('isCompleted false when any stage not completed', () {
      final ds = _buildDropSet(
        stages: [
          DropSetStage(weight: 80.0, reps: 10, isCompleted: true),
          DropSetStage(weight: 60.0, reps: 12, isCompleted: false),
        ],
      );
      expect(ds.isCompleted, false);
    });

    test('totalVolume uses effectiveReps', () {
      final ds = _buildDropSet(
        stages: [
          DropSetStage(weight: 80.0, reps: 10),
          DropSetStage(weight: 60.0, reps: 12, actualReps: 10),
        ],
      );
      // 80*10 + 60*10 = 800 + 600 = 1400
      expect(ds.totalVolume, 1400.0);
    });

    test('totalVolume empty is zero', () {
      final ds = DropSetExercise(
        name: 'Test', category: ExerciseCategory.chest, stages: [],
      );
      expect(ds.totalVolume, 0.0);
    });

    test('completedAt returns latest from stages', () {
      final earlier = DateTime(2024, 1, 1, 10, 0);
      final later = DateTime(2024, 1, 1, 11, 0);
      final ds = _buildDropSet(
        stages: [
          DropSetStage(weight: 80.0, reps: 10, isCompleted: true, completedAt: earlier),
          DropSetStage(weight: 60.0, reps: 12, isCompleted: true, completedAt: later),
        ],
      );
      expect(ds.completedAt, later);
    });

    test('completedAt null when no completed stages', () {
      final ds = _buildDropSet();
      expect(ds.completedAt, isNull);
    });

    test('fromJson', () {
      final json = {
        'id': 'ds-id',
        'name': 'Drop Bench',
        'type': 'dropset',
        'category': 'chest',
        'stages': [
          {'weight': 80.0, 'reps': 10, 'isCompleted': false},
          {'weight': 60.0, 'reps': 12, 'isCompleted': false},
        ],
        'restTime': 90,
        'notes': 'Go to failure',
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise, isA<DropSetExercise>());
      final ds = exercise as DropSetExercise;
      expect(ds.id, 'ds-id');
      expect(ds.name, 'Drop Bench');
      expect(ds.stages.length, 2);
      expect(ds.restTime, 90);
      expect(ds.notes, 'Go to failure');
    });

    test('fromJson with advanced fields', () {
      final json = {
        'name': 'Drop',
        'type': 'dropset',
        'category': 'chest',
        'stages': [],
        'restAfterExercise': 60,
        'autoAdjustmentType': 'rpe',
        'calculated1RM': 100.0,
        'targetRPEMin': 8.0,
        'targetRPEMax': 10.0,
        'targetRIR': 0,
        'countingMode': 'weighted',
        'movementType': 'compoundMedium',
        'lastCalculationDate': '2024-01-01T00:00:00.000',
        'calculationMetadata': 'meta',
      };
      final ds = Exercise.fromJson(json) as DropSetExercise;
      expect(ds.restAfterExercise, 60);
      expect(ds.autoAdjustmentType, AutoAdjustmentType.rpe);
      expect(ds.calculated1RM, 100.0);
      expect(ds.targetRPEMin, 8.0);
      expect(ds.targetRPEMax, 10.0);
      expect(ds.targetRIR, 0);
      expect(ds.movementType, MovementType.compoundMedium);
    });

    test('fromJson restTime as double', () {
      final json = {
        'name': 'Drop',
        'type': 'dropset',
        'category': 'chest',
        'stages': [],
        'restTime': 90.0,
        'restAfterExercise': 60.0,
      };
      final ds = Exercise.fromJson(json) as DropSetExercise;
      expect(ds.restTime, 90);
      expect(ds.restAfterExercise, 60);
    });

    test('fromJson with exerciseId key', () {
      final json = {
        'exerciseId': 'tmpl-ds',
        'exerciseName': 'Drop Set',
        'type': 'dropset',
        'category': 'arms',
        'stages': [],
      };
      final ds = Exercise.fromJson(json) as DropSetExercise;
      expect(ds.id, 'tmpl-ds');
      expect(ds.name, 'Drop Set');
    });

    test('fromJson with unknown category defaults to other', () {
      final json = {
        'name': 'Drop',
        'type': 'dropset',
        'category': 'unknown',
        'stages': [],
      };
      final ds = Exercise.fromJson(json) as DropSetExercise;
      expect(ds.category, ExerciseCategory.other);
    });

    test('toJson includes stages', () {
      final ds = _buildDropSet();
      final json = ds.toJson();
      expect(json['type'], 'dropset');
      expect((json['stages'] as List).length, 3);
    });

    test('copyWith', () {
      final ds = _buildDropSet();
      final newStages = [DropSetStage(weight: 100.0, reps: 5)];
      final copy = ds.copyWith(name: 'New Name', stages: newStages);
      expect(copy.name, 'New Name');
      expect(copy.stages.length, 1);
      expect(copy.category, ds.category); // preserved
    });

    test('copyWith with clearRestTime', () {
      final ds = DropSetExercise(
        name: 'Test', category: ExerciseCategory.chest, stages: [], restTime: 90,
      );
      final copy = ds.copyWith(clearRestTime: true);
      expect(copy.restTime, isNull);
    });

    test('copyWith with clearRestAfterExercise', () {
      final ds = DropSetExercise(
        name: 'Test', category: ExerciseCategory.chest, stages: [], restAfterExercise: 60,
      );
      final copy = ds.copyWith(clearRestAfterExercise: true);
      expect(copy.restAfterExercise, isNull);
    });

    test('copyWith with advanced fields', () {
      final ds = _buildDropSet();
      final copy = ds.copyWith(
        category: ExerciseCategory.back,
        countingMode: ExerciseCountingMode.reps,
        movementType: MovementType.isolationLight,
        autoAdjustmentType: AutoAdjustmentType.rpe,
        calculated1RM: 150.0,
        targetRPEMin: 7.0,
        targetRPEMax: 9.0,
        targetRIR: 1,
        tut: '2-1-2-0',
        restAfterExercise: 90,
      );
      expect(copy.category, ExerciseCategory.back);
      expect(copy.countingMode, ExerciseCountingMode.reps);
      expect(copy.movementType, MovementType.isolationLight);
      expect(copy.autoAdjustmentType, AutoAdjustmentType.rpe);
      expect(copy.calculated1RM, 150.0);
      expect(copy.targetRPEMin, 7.0);
      expect(copy.targetRPEMax, 9.0);
      expect(copy.targetRIR, 1);
      expect(copy.tut, '2-1-2-0');
      expect(copy.restAfterExercise, 90);
    });
  });

  group('RestPauseSet', () {
    test('constructor', () {
      final set = RestPauseSet(reps: 10, restSeconds: 15);
      expect(set.reps, 10);
      expect(set.restSeconds, 15);
      expect(set.isCompleted, false);
      expect(set.actualReps, isNull);
    });

    test('constructor with all fields', () {
      final now = DateTime(2024, 1, 1);
      final set = RestPauseSet(
        reps: 10,
        restSeconds: 15,
        minReps: 8,
        maxReps: 12,
        actualReps: 9,
        rpe: 9,
        isCompleted: true,
        completedAt: now,
      );
      expect(set.minReps, 8);
      expect(set.maxReps, 12);
      expect(set.actualReps, 9);
      expect(set.rpe, 9);
      expect(set.isCompleted, true);
      expect(set.completedAt, now);
    });

    test('fromJson', () {
      final json = {
        'reps': 10,
        'restSeconds': 15,
        'minReps': 8,
        'maxReps': 12,
        'actualReps': 9,
        'rpe': 9,
        'isCompleted': true,
        'completedAt': '2024-01-01T10:00:00.000',
      };
      final set = RestPauseSet.fromJson(json);
      expect(set.reps, 10);
      expect(set.restSeconds, 15);
      expect(set.minReps, 8);
      expect(set.maxReps, 12);
      expect(set.actualReps, 9);
      expect(set.rpe, 9);
      expect(set.isCompleted, true);
    });

    test('fromJson defaults for null values', () {
      final json = <String, dynamic>{};
      final set = RestPauseSet.fromJson(json);
      expect(set.reps, 0);
      expect(set.restSeconds, 0);
      expect(set.isCompleted, false);
    });

    test('effectiveReps uses actualReps when available', () {
      final set = RestPauseSet(reps: 10, restSeconds: 15, actualReps: 8);
      expect(set.effectiveReps, 8);
    });

    test('effectiveReps falls back to reps', () {
      final set = RestPauseSet(reps: 10, restSeconds: 15);
      expect(set.effectiveReps, 10);
    });

    test('hasRepRange true', () {
      final set = RestPauseSet(reps: 10, restSeconds: 15, minReps: 8, maxReps: 12);
      expect(set.hasRepRange, true);
    });

    test('hasRepRange false when same', () {
      final set = RestPauseSet(reps: 10, restSeconds: 15, minReps: 10, maxReps: 10);
      expect(set.hasRepRange, false);
    });

    test('hasRepRange false when null', () {
      final set = RestPauseSet(reps: 10, restSeconds: 15);
      expect(set.hasRepRange, false);
    });

    test('copyWith', () {
      final original = RestPauseSet(reps: 10, restSeconds: 15);
      final copy = original.copyWith(actualReps: 9, isCompleted: true);
      expect(copy.reps, 10);
      expect(copy.restSeconds, 15);
      expect(copy.actualReps, 9);
      expect(copy.isCompleted, true);
    });

    test('copyWith all fields', () {
      final original = RestPauseSet(reps: 10, restSeconds: 15);
      final now = DateTime(2024, 1, 1);
      final copy = original.copyWith(
        reps: 8,
        restSeconds: 20,
        minReps: 6,
        maxReps: 10,
        actualReps: 7,
        rpe: 10,
        isCompleted: true,
        completedAt: now,
      );
      expect(copy.reps, 8);
      expect(copy.restSeconds, 20);
      expect(copy.minReps, 6);
      expect(copy.maxReps, 10);
      expect(copy.actualReps, 7);
      expect(copy.rpe, 10);
      expect(copy.isCompleted, true);
      expect(copy.completedAt, now);
    });

    test('toJson', () {
      final now = DateTime(2024, 1, 1);
      final set = RestPauseSet(
        reps: 10,
        restSeconds: 15,
        minReps: 8,
        maxReps: 12,
        actualReps: 9,
        rpe: 9,
        isCompleted: true,
        completedAt: now,
      );
      final json = set.toJson();
      expect(json['reps'], 10);
      expect(json['restSeconds'], 15);
      expect(json['minReps'], 8);
      expect(json['maxReps'], 12);
      expect(json['actualReps'], 9);
      expect(json['rpe'], 9);
      expect(json['isCompleted'], true);
      expect(json['completedAt'], isNotNull);
    });

    test('toJson omits null minReps/maxReps', () {
      final set = RestPauseSet(reps: 10, restSeconds: 15);
      final json = set.toJson();
      expect(json.containsKey('minReps'), false);
      expect(json.containsKey('maxReps'), false);
    });
  });

  group('RestPauseExercise', () {
    RestPauseExercise _buildRestPause({
      String id = 'rp-1',
      List<RestPauseSet>? restPauseSets,
    }) {
      restPauseSets ??= [
        RestPauseSet(reps: 8, restSeconds: 0),
        RestPauseSet(reps: 4, restSeconds: 15),
        RestPauseSet(reps: 2, restSeconds: 15),
      ];
      return RestPauseExercise(
        id: id,
        name: 'Rest-Pause Curl',
        category: ExerciseCategory.arms,
        weight: 20.0,
        targetReps: 8,
        restPauseSets: restPauseSets,
      );
    }

    test('constructor', () {
      final rp = _buildRestPause();
      expect(rp.id, 'rp-1');
      expect(rp.name, 'Rest-Pause Curl');
      expect(rp.type, ExerciseType.restPause);
      expect(rp.weight, 20.0);
      expect(rp.targetReps, 8);
      expect(rp.restPauseSets.length, 3);
    });

    test('constructor with rep range', () {
      final rp = RestPauseExercise(
        name: 'RP',
        category: ExerciseCategory.arms,
        weight: 20.0,
        targetReps: 8,
        targetMinReps: 6,
        targetMaxReps: 10,
        restPauseSets: [],
      );
      expect(rp.targetMinReps, 6);
      expect(rp.targetMaxReps, 10);
    });

    test('hasRepRange true', () {
      final rp = RestPauseExercise(
        name: 'RP',
        category: ExerciseCategory.arms,
        weight: 20.0,
        targetReps: 8,
        targetMinReps: 6,
        targetMaxReps: 10,
        restPauseSets: [],
      );
      expect(rp.hasRepRange, true);
    });

    test('hasRepRange false when null', () {
      final rp = _buildRestPause();
      expect(rp.hasRepRange, false);
    });

    test('hasRepRange false when same', () {
      final rp = RestPauseExercise(
        name: 'RP',
        category: ExerciseCategory.arms,
        weight: 20.0,
        targetReps: 8,
        targetMinReps: 8,
        targetMaxReps: 8,
        restPauseSets: [],
      );
      expect(rp.hasRepRange, false);
    });

    test('isCompleted false when empty restPauseSets', () {
      final rp = RestPauseExercise(
        name: 'Test', category: ExerciseCategory.arms,
        weight: 20.0, targetReps: 8, restPauseSets: [],
      );
      expect(rp.isCompleted, false);
    });

    test('isCompleted true when all sets completed', () {
      final rp = _buildRestPause(
        restPauseSets: [
          RestPauseSet(reps: 8, restSeconds: 0, isCompleted: true),
          RestPauseSet(reps: 4, restSeconds: 15, isCompleted: true),
        ],
      );
      expect(rp.isCompleted, true);
    });

    test('isCompleted false when any set not completed', () {
      final rp = _buildRestPause(
        restPauseSets: [
          RestPauseSet(reps: 8, restSeconds: 0, isCompleted: true),
          RestPauseSet(reps: 4, restSeconds: 15, isCompleted: false),
        ],
      );
      expect(rp.isCompleted, false);
    });

    test('totalVolume', () {
      final rp = _buildRestPause(
        restPauseSets: [
          RestPauseSet(reps: 8, restSeconds: 0),      // 20*8=160
          RestPauseSet(reps: 4, restSeconds: 15),     // 20*4=80
          RestPauseSet(reps: 2, restSeconds: 15),     // 20*2=40
        ],
      );
      expect(rp.totalVolume, 280.0);
    });

    test('totalVolume uses effectiveReps', () {
      final rp = _buildRestPause(
        restPauseSets: [
          RestPauseSet(reps: 8, restSeconds: 0, actualReps: 6),  // 20*6=120
          RestPauseSet(reps: 4, restSeconds: 15),                 // 20*4=80
        ],
      );
      expect(rp.totalVolume, 200.0);
    });

    test('completedAt returns latest', () {
      final earlier = DateTime(2024, 1, 1, 10, 0);
      final later = DateTime(2024, 1, 1, 11, 0);
      final rp = _buildRestPause(
        restPauseSets: [
          RestPauseSet(reps: 8, restSeconds: 0, isCompleted: true, completedAt: earlier),
          RestPauseSet(reps: 4, restSeconds: 15, isCompleted: true, completedAt: later),
        ],
      );
      expect(rp.completedAt, later);
    });

    test('completedAt null when no completed sets', () {
      final rp = _buildRestPause();
      expect(rp.completedAt, isNull);
    });

    test('fromJson', () {
      final json = {
        'id': 'rp-id',
        'name': 'Rest-Pause Curl',
        'type': 'restPause',
        'category': 'arms',
        'weight': 20.0,
        'targetReps': 8,
        'restPauseSets': [
          {'reps': 8, 'restSeconds': 0, 'isCompleted': false},
          {'reps': 4, 'restSeconds': 15, 'isCompleted': false},
        ],
        'restTime': 120,
        'notes': 'Go to failure',
      };
      final exercise = Exercise.fromJson(json);
      expect(exercise, isA<RestPauseExercise>());
      final rp = exercise as RestPauseExercise;
      expect(rp.id, 'rp-id');
      expect(rp.weight, 20.0);
      expect(rp.targetReps, 8);
      expect(rp.restPauseSets.length, 2);
      expect(rp.restTime, 120);
    });

    test('fromJson with rep range', () {
      final json = {
        'name': 'RP',
        'type': 'restPause',
        'category': 'arms',
        'weight': 20.0,
        'targetReps': 8,
        'targetMinReps': 6,
        'targetMaxReps': 10,
        'restPauseSets': [],
      };
      final rp = Exercise.fromJson(json) as RestPauseExercise;
      expect(rp.targetMinReps, 6);
      expect(rp.targetMaxReps, 10);
    });

    test('fromJson with advanced fields', () {
      final json = {
        'name': 'RP',
        'type': 'restPause',
        'category': 'arms',
        'weight': 20.0,
        'targetReps': 8,
        'restPauseSets': [],
        'restAfterExercise': 60,
        'autoAdjustmentType': 'rpe',
        'calculated1RM': 30.0,
        'targetRPEMin': 8.0,
        'targetRPEMax': 10.0,
        'targetRIR': 0,
        'countingMode': 'weighted',
        'movementType': 'isolationLight',
        'lastCalculationDate': '2024-01-01T00:00:00.000',
        'calculationMetadata': 'meta',
        'tut': '2-0-2-0',
      };
      final rp = Exercise.fromJson(json) as RestPauseExercise;
      expect(rp.restAfterExercise, 60);
      expect(rp.autoAdjustmentType, AutoAdjustmentType.rpe);
      expect(rp.calculated1RM, 30.0);
      expect(rp.movementType, MovementType.isolationLight);
      expect(rp.tut, '2-0-2-0');
    });

    test('fromJson restTime as double', () {
      final json = {
        'name': 'RP',
        'type': 'restPause',
        'category': 'arms',
        'weight': 20.0,
        'targetReps': 8,
        'restPauseSets': [],
        'restTime': 90.0,
        'restAfterExercise': 60.0,
      };
      final rp = Exercise.fromJson(json) as RestPauseExercise;
      expect(rp.restTime, 90);
      expect(rp.restAfterExercise, 60);
    });

    test('fromJson with exerciseId key', () {
      final json = {
        'exerciseId': 'tmpl-rp',
        'exerciseName': 'Rest-Pause',
        'type': 'restPause',
        'category': 'arms',
        'weight': 0.0,
        'targetReps': 0,
        'restPauseSets': [],
      };
      final rp = Exercise.fromJson(json) as RestPauseExercise;
      expect(rp.id, 'tmpl-rp');
      expect(rp.name, 'Rest-Pause');
    });

    test('fromJson with unknown category defaults to other', () {
      final json = {
        'name': 'RP',
        'type': 'restPause',
        'category': 'unknown',
        'weight': 20.0,
        'targetReps': 8,
        'restPauseSets': [],
      };
      final rp = Exercise.fromJson(json) as RestPauseExercise;
      expect(rp.category, ExerciseCategory.other);
    });

    test('toJson includes restPause specific fields', () {
      final rp = _buildRestPause();
      final json = rp.toJson();
      expect(json['type'], 'restPause');
      expect(json['weight'], 20.0);
      expect(json['targetReps'], 8);
      expect((json['restPauseSets'] as List).length, 3);
    });

    test('toJson includes targetMinReps/targetMaxReps when set', () {
      final rp = RestPauseExercise(
        name: 'RP',
        category: ExerciseCategory.arms,
        weight: 20.0,
        targetReps: 8,
        targetMinReps: 6,
        targetMaxReps: 10,
        restPauseSets: [],
      );
      final json = rp.toJson();
      expect(json['targetMinReps'], 6);
      expect(json['targetMaxReps'], 10);
    });

    test('toJson omits null targetMinReps/targetMaxReps', () {
      final rp = _buildRestPause();
      final json = rp.toJson();
      expect(json.containsKey('targetMinReps'), false);
      expect(json.containsKey('targetMaxReps'), false);
    });

    test('copyWith', () {
      final rp = _buildRestPause();
      final copy = rp.copyWith(name: 'New Name', weight: 25.0);
      expect(copy.name, 'New Name');
      expect(copy.weight, 25.0);
      expect(copy.targetReps, rp.targetReps); // preserved
      expect(copy.category, rp.category);
    });

    test('copyWith with clearRestTime', () {
      final rp = RestPauseExercise(
        name: 'Test', category: ExerciseCategory.arms,
        weight: 20.0, targetReps: 8, restPauseSets: [], restTime: 90,
      );
      final copy = rp.copyWith(clearRestTime: true);
      expect(copy.restTime, isNull);
    });

    test('copyWith with clearRestAfterExercise', () {
      final rp = RestPauseExercise(
        name: 'Test', category: ExerciseCategory.arms,
        weight: 20.0, targetReps: 8, restPauseSets: [], restAfterExercise: 60,
      );
      final copy = rp.copyWith(clearRestAfterExercise: true);
      expect(copy.restAfterExercise, isNull);
    });

    test('copyWith with all advanced fields', () {
      final rp = _buildRestPause();
      final copy = rp.copyWith(
        targetReps: 6,
        targetMinReps: 4,
        targetMaxReps: 8,
        restPauseSets: [RestPauseSet(reps: 6, restSeconds: 0)],
        category: ExerciseCategory.back,
        countingMode: ExerciseCountingMode.reps,
        movementType: MovementType.isolationLight,
        autoAdjustmentType: AutoAdjustmentType.rpe,
        calculated1RM: 50.0,
        targetRPEMin: 8.0,
        targetRPEMax: 10.0,
        targetRIR: 0,
        tut: '2-0-2-0',
        restAfterExercise: 30,
      );
      expect(copy.targetReps, 6);
      expect(copy.targetMinReps, 4);
      expect(copy.targetMaxReps, 8);
      expect(copy.restPauseSets.length, 1);
      expect(copy.category, ExerciseCategory.back);
      expect(copy.countingMode, ExerciseCountingMode.reps);
      expect(copy.movementType, MovementType.isolationLight);
      expect(copy.autoAdjustmentType, AutoAdjustmentType.rpe);
      expect(copy.calculated1RM, 50.0);
      expect(copy.targetRPEMin, 8.0);
      expect(copy.targetRPEMax, 10.0);
      expect(copy.targetRIR, 0);
      expect(copy.tut, '2-0-2-0');
      expect(copy.restAfterExercise, 30);
    });
  });
}

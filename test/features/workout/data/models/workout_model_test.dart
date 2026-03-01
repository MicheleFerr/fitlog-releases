import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/data/models/workout_model.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';

void main() {
  group('ExerciseSetModel', () {
    group('fromJson', () {
      test('parses minimal JSON with defaults', () {
        final json = <String, dynamic>{};
        final model = ExerciseSetModel.fromJson(json);

        expect(model.id, startsWith('set-'));
        expect(model.setNumber, 0);
        expect(model.weight, isNull);
        expect(model.reps, isNull);
        expect(model.restTime, isNull);
        expect(model.rpe, isNull);
        expect(model.notes, isNull);
        expect(model.isWarmup, false);
        expect(model.isCompletedLegacy, true); // defaults to true for Firebase
        expect(model.isCompleted, true);
        expect(model.restTimerSkipped, false);
      });

      test('parses full JSON correctly', () {
        final now = DateTime(2024, 1, 15, 10, 30);
        final json = <String, dynamic>{
          'id': 'set-1',
          'setNumber': 1,
          'weight': 100.0,
          'reps': 10,
          'minReps': 8,
          'maxReps': 12,
          'restSeconds': 90,
          'rpe': 8,
          'notes': 'Felt strong',
          'isCompleted': true,
          'completedAt': now.toIso8601String(),
          'setDurationMillis': 45000.0,
          'setStartedAt': now.toIso8601String(),
          'actualReps': 10,
          'isWarmup': false,
          'seconds': 60,
          'distance': 5.0,
          'restTimerSkipped': true,
          'restTimerSecondsRemaining': 30,
          'restTimerSecondsAdded': 15,
          'actualRestSeconds': 75,
        };
        final model = ExerciseSetModel.fromJson(json);

        expect(model.id, 'set-1');
        expect(model.setNumber, 1);
        expect(model.weight, 100.0);
        expect(model.reps, 10);
        expect(model.minReps, 8);
        expect(model.maxReps, 12);
        expect(model.restTime, 90);
        expect(model.rpe, 8);
        expect(model.notes, 'Felt strong');
        expect(model.completedAt, now);
        expect(model.isCompletedLegacy, false);
        expect(model.isCompleted, true);
        expect(model.setDurationMillis, 45000.0);
        expect(model.actualReps, 10);
        expect(model.isWarmup, false);
        expect(model.seconds, 60);
        expect(model.distance, 5.0);
        expect(model.restTimerSkipped, true);
        expect(model.restTimerSecondsRemaining, 30);
        expect(model.restTimerSecondsAdded, 15);
        expect(model.actualRestSeconds, 75);
      });

      test('uses restSeconds field (Firebase format)', () {
        final json = <String, dynamic>{
          'restSeconds': 60,
        };
        final model = ExerciseSetModel.fromJson(json);
        expect(model.restTime, 60);
      });

      test('uses restTimeSeconds field (legacy format)', () {
        final json = <String, dynamic>{
          'restTimeSeconds': 90,
        };
        final model = ExerciseSetModel.fromJson(json);
        expect(model.restTime, 90);
      });

      test('prefers restSeconds over restTimeSeconds', () {
        final json = <String, dynamic>{
          'restSeconds': 60,
          'restTimeSeconds': 90,
        };
        final model = ExerciseSetModel.fromJson(json);
        expect(model.restTime, 60);
      });

      test('handles legacy completed without timestamp', () {
        final json = <String, dynamic>{
          'isCompleted': true,
        };
        final model = ExerciseSetModel.fromJson(json);
        expect(model.completedAt, isNull);
        expect(model.isCompletedLegacy, true);
        expect(model.isCompleted, true);
      });

      test('handles not completed', () {
        final json = <String, dynamic>{
          'isCompleted': false,
        };
        final model = ExerciseSetModel.fromJson(json);
        expect(model.completedAt, isNull);
        expect(model.isCompletedLegacy, false);
        expect(model.isCompleted, false);
      });

      test('completed via timestamp clears legacy flag', () {
        final now = DateTime(2024, 1, 15);
        final json = <String, dynamic>{
          'isCompleted': true,
          'completedAt': now.toIso8601String(),
        };
        final model = ExerciseSetModel.fromJson(json);
        expect(model.completedAt, now);
        expect(model.isCompletedLegacy, false);
        expect(model.isCompleted, true);
      });

      test('handles Map<dynamic, dynamic> input from Hive', () {
        final json = <dynamic, dynamic>{
          'id': 'set-hive',
          'setNumber': 2,
          'weight': 50.0,
        };
        final model = ExerciseSetModel.fromJson(json);
        expect(model.id, 'set-hive');
        expect(model.setNumber, 2);
        expect(model.weight, 50.0);
      });

      test('parses completedAt from ISO string', () {
        final date = DateTime(2024, 6, 15, 14, 30, 0);
        final json = <String, dynamic>{
          'completedAt': date.toIso8601String(),
        };
        final model = ExerciseSetModel.fromJson(json);
        expect(model.completedAt, date);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final now = DateTime(2024, 1, 15, 10, 30);
        final model = ExerciseSetModel(
          id: 'set-1',
          setNumber: 1,
          weight: 80.0,
          reps: 10,
          minReps: 8,
          maxReps: 12,
          restTime: 90,
          rpe: 7,
          notes: 'Good form',
          completedAt: now,
          setDurationMillis: 30000.0,
          setStartedAt: now,
          actualReps: 10,
          isWarmup: true,
          seconds: 45,
          distance: 2.5,
          restTimerSkipped: true,
          restTimerSecondsRemaining: 20,
          restTimerSecondsAdded: 10,
          actualRestSeconds: 80,
        );
        final json = model.toJson();

        expect(json['id'], 'set-1');
        expect(json['setNumber'], 1);
        expect(json['weight'], 80.0);
        expect(json['reps'], 10);
        expect(json['minReps'], 8);
        expect(json['maxReps'], 12);
        expect(json['restTimeSeconds'], 90);
        expect(json['rpe'], 7);
        expect(json['notes'], 'Good form');
        expect(json['isCompleted'], true);
        expect(json['completedAt'], now.toIso8601String());
        expect(json['setDurationMillis'], 30000.0);
        expect(json['setStartedAt'], now.toIso8601String());
        expect(json['actualReps'], 10);
        expect(json['isWarmup'], true);
        expect(json['seconds'], 45);
        expect(json['distance'], 2.5);
        expect(json['restTimerSkipped'], true);
        expect(json['restTimerSecondsRemaining'], 20);
        expect(json['restTimerSecondsAdded'], 10);
        expect(json['actualRestSeconds'], 80);
      });

      test('omits optional fields when null', () {
        final model = ExerciseSetModel(
          id: 'set-1',
          setNumber: 1,
        );
        final json = model.toJson();

        expect(json.containsKey('minReps'), false);
        expect(json.containsKey('maxReps'), false);
        expect(json.containsKey('restTimerSecondsRemaining'), false);
        expect(json.containsKey('restTimerSecondsAdded'), false);
        expect(json.containsKey('actualRestSeconds'), false);
      });
    });

    group('volume', () {
      test('calculates weight * reps', () {
        final model = ExerciseSetModel(
          id: 'set-1',
          setNumber: 1,
          weight: 100.0,
          reps: 10,
        );
        expect(model.volume, 1000.0);
      });

      test('returns 0 when weight is null', () {
        final model = ExerciseSetModel(
          id: 'set-1',
          setNumber: 1,
          reps: 10,
        );
        expect(model.volume, 0.0);
      });

      test('returns 0 when reps is null', () {
        final model = ExerciseSetModel(
          id: 'set-1',
          setNumber: 1,
          weight: 100.0,
        );
        expect(model.volume, 0.0);
      });

      test('returns 0 when both are null', () {
        final model = ExerciseSetModel(
          id: 'set-1',
          setNumber: 1,
        );
        expect(model.volume, 0.0);
      });
    });

    group('isCompleted', () {
      test('true when completedAt is set', () {
        final model = ExerciseSetModel(
          id: 'set-1',
          setNumber: 1,
          completedAt: DateTime.now(),
        );
        expect(model.isCompleted, true);
      });

      test('true when isCompletedLegacy is true', () {
        final model = ExerciseSetModel(
          id: 'set-1',
          setNumber: 1,
          isCompletedLegacy: true,
        );
        expect(model.isCompleted, true);
      });

      test('false when neither completedAt nor legacy', () {
        final model = ExerciseSetModel(
          id: 'set-1',
          setNumber: 1,
        );
        expect(model.isCompleted, false);
      });
    });

    group('copyWith', () {
      test('creates new instance with modified fields', () {
        final original = ExerciseSetModel(
          id: 'set-1',
          setNumber: 1,
          weight: 80.0,
          reps: 10,
        );
        final modified = original.copyWith(weight: 90.0, reps: 8);

        expect(modified.id, 'set-1');
        expect(modified.weight, 90.0);
        expect(modified.reps, 8);
        expect(original.weight, 80.0); // original unchanged
      });

      test('clears legacy flag when completedAt is provided', () {
        final original = ExerciseSetModel(
          id: 'set-1',
          setNumber: 1,
          isCompletedLegacy: true,
        );
        final modified = original.copyWith(completedAt: DateTime.now());

        expect(modified.isCompletedLegacy, false);
        expect(modified.isCompleted, true);
      });

      test('preserves all fields when no arguments', () {
        final now = DateTime(2024, 1, 15);
        final original = ExerciseSetModel(
          id: 'set-1',
          setNumber: 1,
          weight: 80.0,
          reps: 10,
          restTime: 90,
          rpe: 7,
          notes: 'test',
          completedAt: now,
          distance: 5.0,
          seconds: 30,
          isWarmup: true,
          restTimerSkipped: true,
          restTimerSecondsRemaining: 20,
        );
        final modified = original.copyWith();

        expect(modified.id, original.id);
        expect(modified.weight, original.weight);
        expect(modified.reps, original.reps);
        expect(modified.restTime, original.restTime);
        expect(modified.rpe, original.rpe);
        expect(modified.notes, original.notes);
        expect(modified.completedAt, original.completedAt);
        expect(modified.distance, original.distance);
        expect(modified.seconds, original.seconds);
        expect(modified.isWarmup, original.isWarmup);
        expect(modified.restTimerSkipped, original.restTimerSkipped);
        expect(modified.restTimerSecondsRemaining, original.restTimerSecondsRemaining);
      });
    });

    group('toDomain', () {
      test('converts to ExerciseSet correctly', () {
        final now = DateTime(2024, 1, 15, 10, 30);
        final model = ExerciseSetModel(
          id: 'set-1',
          setNumber: 1,
          weight: 80.0,
          reps: 10,
          minReps: 8,
          maxReps: 12,
          restTime: 90,
          rpe: 7,
          notes: 'Good form',
          completedAt: now,
          isCompletedLegacy: false,
          setDurationMillis: 30000.0,
          setStartedAt: now,
          actualReps: 10,
          isWarmup: true,
          seconds: 45,
          distance: 2.5,
          restTimerSkipped: true,
          restTimerSecondsRemaining: 20,
          restTimerSecondsAdded: 10,
          actualRestSeconds: 80,
        );
        final domain = model.toDomain();

        expect(domain.id, 'set-1');
        expect(domain.setNumber, 1);
        expect(domain.weight, 80.0);
        expect(domain.reps, 10);
        expect(domain.minReps, 8);
        expect(domain.maxReps, 12);
        expect(domain.restTime, 90);
        expect(domain.rpe, 7);
        expect(domain.notes, 'Good form');
        expect(domain.isCompleted, true);
        expect(domain.completedAt, now);
        expect(domain.setDurationMillis, 30000.0);
        expect(domain.setStartedAt, now);
        expect(domain.actualReps, 10);
        expect(domain.isWarmup, true);
        expect(domain.seconds, 45);
        expect(domain.distance, 2.5);
        expect(domain.restTimerSkipped, true);
        expect(domain.restTimerSecondsRemaining, 20);
        expect(domain.restTimerSecondsAdded, 10);
        expect(domain.actualRestSeconds, 80);
      });

      test('maps legacy completed flag to isCompleted', () {
        final model = ExerciseSetModel(
          id: 'set-1',
          setNumber: 1,
          isCompletedLegacy: true,
        );
        final domain = model.toDomain();
        expect(domain.isCompleted, true);
      });
    });

    group('fromDomain', () {
      test('converts from ExerciseSet correctly', () {
        final now = DateTime(2024, 1, 15, 10, 30);
        final domain = ExerciseSet(
          id: 'set-1',
          setNumber: 1,
          weight: 80.0,
          reps: 10,
          minReps: 8,
          maxReps: 12,
          restTime: 90,
          rpe: 7,
          notes: 'Good form',
          isCompleted: true,
          completedAt: now,
          setDurationMillis: 30000.0,
          setStartedAt: now,
          actualReps: 10,
          isWarmup: true,
          seconds: 45,
          distance: 2.5,
          restTimerSkipped: true,
          restTimerSecondsRemaining: 20,
          restTimerSecondsAdded: 10,
          actualRestSeconds: 80,
        );
        final model = ExerciseSetModel.fromDomain(domain);

        expect(model.id, 'set-1');
        expect(model.setNumber, 1);
        expect(model.weight, 80.0);
        expect(model.reps, 10);
        expect(model.restTime, 90);
        expect(model.rpe, 7);
        expect(model.completedAt, now);
        expect(model.isCompletedLegacy, false);
        expect(model.distance, 2.5);
        expect(model.restTimerSkipped, true);
      });

      test('sets isCompletedLegacy when completed without timestamp', () {
        final domain = ExerciseSet(
          setNumber: 1,
          isCompleted: true,
        );
        final model = ExerciseSetModel.fromDomain(domain);
        expect(model.isCompletedLegacy, true);
        expect(model.completedAt, isNull);
      });
    });

    group('JSON roundtrip', () {
      test('fromJson -> toJson preserves data', () {
        final now = DateTime(2024, 1, 15, 10, 30);
        final json = <String, dynamic>{
          'id': 'set-roundtrip',
          'setNumber': 3,
          'weight': 100.0,
          'reps': 8,
          'minReps': 6,
          'maxReps': 10,
          'rpe': 9,
          'notes': 'Heavy set',
          'isCompleted': true,
          'completedAt': now.toIso8601String(),
          'actualReps': 8,
          'isWarmup': false,
          'seconds': 30,
          'distance': 1.5,
          'restTimerSkipped': false,
        };
        final model = ExerciseSetModel.fromJson(json);
        final output = model.toJson();

        expect(output['id'], 'set-roundtrip');
        expect(output['setNumber'], 3);
        expect(output['weight'], 100.0);
        expect(output['reps'], 8);
        expect(output['rpe'], 9);
        expect(output['notes'], 'Heavy set');
        expect(output['isCompleted'], true);
        expect(output['completedAt'], now.toIso8601String());
        expect(output['actualReps'], 8);
        expect(output['isWarmup'], false);
        expect(output['seconds'], 30);
        expect(output['distance'], 1.5);
      });
    });
  });

  group('ExerciseModel', () {
    final fixedDate = DateTime(2024, 1, 15, 10, 30);

    ExerciseSetModel _makeSet({
      String id = 'set-1',
      int setNumber = 1,
      double? weight = 80.0,
      int? reps = 10,
      DateTime? completedAt,
    }) {
      return ExerciseSetModel(
        id: id,
        setNumber: setNumber,
        weight: weight,
        reps: reps,
        completedAt: completedAt,
      );
    }

    group('fromJson', () {
      test('parses minimal JSON with defaults', () {
        final json = <String, dynamic>{};
        final model = ExerciseModel.fromJson(json);

        expect(model.id, startsWith('unknown-'));
        expect(model.name, 'Unknown Exercise');
        expect(model.type, 'single');
        expect(model.category, 'other');
        expect(model.sets, isEmpty);
        expect(model.restTime, isNull);
      });

      test('parses full single exercise JSON', () {
        final json = <String, dynamic>{
          'id': 'ex-1',
          'name': 'Bench Press',
          'type': 'single',
          'category': 'chest',
          'sets': [
            {'id': 'set-1', 'setNumber': 1, 'weight': 80.0, 'reps': 10},
            {'id': 'set-2', 'setNumber': 2, 'weight': 85.0, 'reps': 8},
          ],
          'restTime': 90,
          'restAfterExercise': 120,
          'tut': '3-1-2-0',
          'notes': 'Focus on form',
          'createdAt': fixedDate.toIso8601String(),
          'updatedAt': fixedDate.toIso8601String(),
          'calculated1RM': 100.0,
          'calculated3RM': 90.0,
          'targetRPEMin': 7.0,
          'targetRPEMax': 9.0,
          'targetRIR': 2,
          'autoAdjustmentType': 'rpe',
          'movementType': 'compoundMedium',
          'countingMode': 'weighted',
        };
        final model = ExerciseModel.fromJson(json);

        expect(model.id, 'ex-1');
        expect(model.name, 'Bench Press');
        expect(model.type, 'single');
        expect(model.category, 'chest');
        expect(model.sets.length, 2);
        expect(model.restTime, 90);
        expect(model.restAfterExercise, 120);
        expect(model.tut, '3-1-2-0');
        expect(model.notes, 'Focus on form');
        expect(model.calculated1RM, 100.0);
        expect(model.calculated3RM, 90.0);
        expect(model.targetRPEMin, 7.0);
        expect(model.targetRPEMax, 9.0);
        expect(model.targetRIR, 2);
        expect(model.autoAdjustmentType, 'rpe');
        expect(model.movementType, 'compoundMedium');
        expect(model.countingMode, 'weighted');
      });

      test('uses restTimeSeconds as legacy fallback', () {
        final json = <String, dynamic>{
          'restTimeSeconds': 60,
        };
        final model = ExerciseModel.fromJson(json);
        expect(model.restTime, 60);
      });

      test('prefers restTime over restTimeSeconds', () {
        final json = <String, dynamic>{
          'restTime': 90,
          'restTimeSeconds': 60,
        };
        final model = ExerciseModel.fromJson(json);
        expect(model.restTime, 90);
      });

      test('handles nested exerciseData structure', () {
        final json = <String, dynamic>{
          'id': 'outer-id',
          'name': 'Outer Name',
          'exerciseData': {
            'id': 'inner-id',
            'name': 'Inner Name',
            'notes': 'Inner notes',
          },
        };
        final model = ExerciseModel.fromJson(json);

        expect(model.id, 'inner-id');
        expect(model.name, 'Inner Name');
        expect(model.notes, 'Inner notes');
      });

      test('falls back to outer fields when exerciseData has nulls', () {
        final json = <String, dynamic>{
          'id': 'outer-id',
          'name': 'Outer Name',
          'exerciseData': <String, dynamic>{},
        };
        final model = ExerciseModel.fromJson(json);

        expect(model.id, 'outer-id');
        expect(model.name, 'Outer Name');
      });

      test('skips malformed sets instead of failing', () {
        final json = <String, dynamic>{
          'id': 'ex-1',
          'name': 'Test',
          'sets': [
            {'id': 'set-1', 'setNumber': 1, 'weight': 80.0},
            'invalid-set', // This is not a Map, should be skipped
            {'id': 'set-3', 'setNumber': 3, 'weight': 90.0},
          ],
        };
        // This should not throw - malformed entries skipped
        // The string 'invalid-set' will cause a cast error on `as Map`
        // which gets caught in the try/catch
        final model = ExerciseModel.fromJson(json);
        expect(model.sets.length, 2);
      });

      test('parses superset type with exercises', () {
        final json = <String, dynamic>{
          'id': 'ss-1',
          'name': 'Chest-Back Superset',
          'type': 'superset',
          'category': 'chest',
          'sets': [],
          'exercises': [
            {
              'id': 'ex-a',
              'name': 'Bench Press',
              'type': 'single',
              'category': 'chest',
              'sets': [],
            },
            {
              'id': 'ex-b',
              'name': 'Barbell Row',
              'type': 'single',
              'category': 'back',
              'sets': [],
            },
          ],
          'supersetSets': [
            {'setNumber': 1},
          ],
        };
        final model = ExerciseModel.fromJson(json);

        expect(model.type, 'superset');
        expect(model.supersetExercises, isNotNull);
        expect(model.supersetExercises!.length, 2);
        expect(model.supersetExercises![0].name, 'Bench Press');
        expect(model.supersetSetsData, isNotNull);
        expect(model.supersetSetsData!.length, 1);
      });

      test('parses dropset type with stages', () {
        final json = <String, dynamic>{
          'id': 'ds-1',
          'name': 'Bicep Curl Dropset',
          'type': 'dropset',
          'category': 'arms',
          'sets': [],
          'stages': [
            {'weight': 20.0, 'reps': 10},
            {'weight': 15.0, 'reps': 12},
          ],
        };
        final model = ExerciseModel.fromJson(json);

        expect(model.type, 'dropset');
        expect(model.dropSetStages, isNotNull);
        expect(model.dropSetStages!.length, 2);
      });

      test('parses restPause type', () {
        final json = <String, dynamic>{
          'id': 'rp-1',
          'name': 'Rest Pause Bench',
          'type': 'restPause',
          'category': 'chest',
          'sets': [],
          'weight': 80.0,
          'targetReps': 15,
          'restPauseSets': [
            {'reps': 8, 'pauseSeconds': 15},
          ],
        };
        final model = ExerciseModel.fromJson(json);

        expect(model.type, 'restPause');
        expect(model.restPauseWeight, 80.0);
        expect(model.restPauseTargetReps, 15);
        expect(model.restPauseSetsData, isNotNull);
        expect(model.restPauseSetsData!.length, 1);
      });

      test('handles Map<dynamic, dynamic> from Hive', () {
        final json = <dynamic, dynamic>{
          'id': 'ex-hive',
          'name': 'Hive Exercise',
          'type': 'single',
          'category': 'chest',
        };
        final model = ExerciseModel.fromJson(json);
        expect(model.id, 'ex-hive');
        expect(model.name, 'Hive Exercise');
      });

      test('parses RM calculation fields from num', () {
        final json = <String, dynamic>{
          'calculated1RM': 100,
          'calculated3RM': 90,
          'calculated6RM': 80,
          'calculated10RM': 70,
        };
        final model = ExerciseModel.fromJson(json);

        expect(model.calculated1RM, 100.0);
        expect(model.calculated3RM, 90.0);
        expect(model.calculated6RM, 80.0);
        expect(model.calculated10RM, 70.0);
      });
    });

    group('toJson', () {
      test('serializes single exercise correctly', () {
        final model = ExerciseModel(
          id: 'ex-1',
          name: 'Bench Press',
          type: 'single',
          category: 'chest',
          sets: [_makeSet()],
          restTime: 90,
          restAfterExercise: 120,
          tut: '3-1-2-0',
          notes: 'Focus',
          createdAt: fixedDate,
          updatedAt: fixedDate,
          calculated1RM: 100.0,
          targetRPEMin: 7.0,
          targetRPEMax: 9.0,
          targetRIR: 2,
          autoAdjustmentType: 'rpe',
          movementType: 'compoundMedium',
          countingMode: 'weighted',
        );
        final json = model.toJson();

        expect(json['id'], 'ex-1');
        expect(json['name'], 'Bench Press');
        expect(json['type'], 'single');
        expect(json['category'], 'chest');
        expect(json['sets'], isA<List>());
        expect((json['sets'] as List).length, 1);
        expect(json['restTimeSeconds'], 90);
        expect(json['restAfterExercise'], 120);
        expect(json['tut'], '3-1-2-0');
        expect(json['notes'], 'Focus');
        expect(json['calculated1RM'], 100.0);
        expect(json['targetRPEMin'], 7.0);
        expect(json['targetRPEMax'], 9.0);
        expect(json['targetRIR'], 2);
        expect(json['autoAdjustmentType'], 'rpe');
        expect(json['movementType'], 'compoundMedium');
        expect(json['countingMode'], 'weighted');
      });

      test('includes polymorphic superset fields', () {
        final model = ExerciseModel(
          id: 'ss-1',
          name: 'Superset',
          type: 'superset',
          category: 'chest',
          sets: [],
          createdAt: fixedDate,
          supersetExercises: [
            ExerciseModel(
              id: 'ex-a',
              name: 'Press',
              type: 'single',
              category: 'chest',
              sets: [],
              createdAt: fixedDate,
            ),
          ],
          supersetSetsData: [{'setNumber': 1}],
        );
        final json = model.toJson();

        expect(json['exercises'], isNotNull);
        expect(json['supersetSets'], isNotNull);
        expect(json.containsKey('stages'), false);
        expect(json.containsKey('weight'), false);
      });

      test('includes polymorphic dropset fields', () {
        final model = ExerciseModel(
          id: 'ds-1',
          name: 'Dropset',
          type: 'dropset',
          category: 'arms',
          sets: [],
          createdAt: fixedDate,
          dropSetStages: [{'weight': 20.0, 'reps': 10}],
        );
        final json = model.toJson();

        expect(json['stages'], isNotNull);
        expect(json.containsKey('exercises'), false);
      });

      test('includes polymorphic restPause fields', () {
        final model = ExerciseModel(
          id: 'rp-1',
          name: 'Rest Pause',
          type: 'restPause',
          category: 'chest',
          sets: [],
          createdAt: fixedDate,
          restPauseWeight: 80.0,
          restPauseTargetReps: 15,
          restPauseSetsData: [{'reps': 8}],
        );
        final json = model.toJson();

        expect(json['weight'], 80.0);
        expect(json['targetReps'], 15);
        expect(json['restPauseSets'], isNotNull);
        expect(json.containsKey('stages'), false);
      });
    });

    group('isCompleted', () {
      test('true when all sets are completed', () {
        final model = ExerciseModel(
          id: 'ex-1',
          name: 'Test',
          type: 'single',
          category: 'chest',
          sets: [
            _makeSet(id: 'set-1', completedAt: fixedDate),
            _makeSet(id: 'set-2', completedAt: fixedDate),
          ],
          createdAt: fixedDate,
        );
        expect(model.isCompleted, true);
      });

      test('false when some sets are not completed', () {
        final model = ExerciseModel(
          id: 'ex-1',
          name: 'Test',
          type: 'single',
          category: 'chest',
          sets: [
            _makeSet(id: 'set-1', completedAt: fixedDate),
            _makeSet(id: 'set-2'),
          ],
          createdAt: fixedDate,
        );
        expect(model.isCompleted, false);
      });

      test('false when no sets', () {
        final model = ExerciseModel(
          id: 'ex-1',
          name: 'Test',
          type: 'single',
          category: 'chest',
          sets: [],
          createdAt: fixedDate,
        );
        expect(model.isCompleted, false);
      });
    });

    group('totalVolume', () {
      test('sums volume of completed sets only', () {
        final model = ExerciseModel(
          id: 'ex-1',
          name: 'Test',
          type: 'single',
          category: 'chest',
          sets: [
            _makeSet(
              id: 'set-1',
              weight: 100.0,
              reps: 10,
              completedAt: fixedDate,
            ),
            _makeSet(
              id: 'set-2',
              weight: 90.0,
              reps: 8,
              completedAt: fixedDate,
            ),
            _makeSet(id: 'set-3', weight: 80.0, reps: 6), // not completed
          ],
          createdAt: fixedDate,
        );
        // 100*10 + 90*8 = 1000 + 720 = 1720
        expect(model.totalVolume, 1720.0);
      });

      test('returns 0 when no completed sets', () {
        final model = ExerciseModel(
          id: 'ex-1',
          name: 'Test',
          type: 'single',
          category: 'chest',
          sets: [
            _makeSet(id: 'set-1', weight: 100.0, reps: 10),
          ],
          createdAt: fixedDate,
        );
        expect(model.totalVolume, 0.0);
      });
    });

    group('toDomain', () {
      test('converts single exercise to domain', () {
        final model = ExerciseModel(
          id: 'ex-1',
          name: 'Bench Press',
          type: 'single',
          category: 'chest',
          sets: [_makeSet()],
          restTime: 90,
          notes: 'Good',
          createdAt: fixedDate,
          updatedAt: fixedDate,
          autoAdjustmentType: 'rpe',
          movementType: 'compoundMedium',
          countingMode: 'weighted',
        );
        final domain = model.toDomain();

        expect(domain, isA<Exercise>());
        expect(domain, isNot(isA<SupersetExercise>()));
        expect(domain.id, 'ex-1');
        expect(domain.name, 'Bench Press');
        expect(domain.type, ExerciseType.single);
        expect(domain.category, ExerciseCategory.chest);
        expect(domain.sets.length, 1);
        expect(domain.restTime, 90);
        expect(domain.notes, 'Good');
        expect(domain.autoAdjustmentType, AutoAdjustmentType.rpe);
        expect(domain.movementType, MovementType.compoundMedium);
        expect(domain.countingMode, ExerciseCountingMode.weighted);
      });

      test('converts to default enums for invalid strings', () {
        final model = ExerciseModel(
          id: 'ex-1',
          name: 'Test',
          type: 'nonexistent_type',
          category: 'nonexistent_category',
          sets: [],
          createdAt: fixedDate,
          autoAdjustmentType: 'nonexistent',
          movementType: 'nonexistent',
          countingMode: 'nonexistent',
        );
        final domain = model.toDomain();

        expect(domain.type, ExerciseType.single);
        expect(domain.category, ExerciseCategory.other);
        expect(domain.autoAdjustmentType, AutoAdjustmentType.rpe);
        expect(domain.movementType, MovementType.isolationLight);
        expect(domain.countingMode, ExerciseCountingMode.weighted);
      });

      test('converts null nullable enums correctly', () {
        final model = ExerciseModel(
          id: 'ex-1',
          name: 'Test',
          type: 'single',
          category: 'chest',
          sets: [],
          createdAt: fixedDate,
        );
        final domain = model.toDomain();

        expect(domain.autoAdjustmentType, isNull);
        expect(domain.movementType, isNull);
        expect(domain.countingMode, ExerciseCountingMode.weighted);
      });
    });

    group('copyWith', () {
      test('creates new instance preserving unmodified fields', () {
        final original = ExerciseModel(
          id: 'ex-1',
          name: 'Bench Press',
          type: 'single',
          category: 'chest',
          sets: [],
          restTime: 90,
          createdAt: fixedDate,
          calculated1RM: 100.0,
        );
        final modified = original.copyWith(name: 'Squat', category: 'legs');

        expect(modified.id, 'ex-1');
        expect(modified.name, 'Squat');
        expect(modified.category, 'legs');
        expect(modified.type, 'single');
        expect(modified.restTime, 90);
        expect(modified.calculated1RM, 100.0);
        expect(original.name, 'Bench Press'); // original unchanged
      });
    });

    group('fromDomain', () {
      test('converts base Exercise from domain', () {
        final exercise = Exercise(
          id: 'ex-1',
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [ExerciseSet(setNumber: 1, weight: 80.0, reps: 10)],
          restTime: 90,
          notes: 'Test',
          createdAt: fixedDate,
          updatedAt: fixedDate,
          countingMode: ExerciseCountingMode.weighted,
          movementType: MovementType.compoundMedium,
        );
        final model = ExerciseModel.fromDomain(exercise);

        expect(model.id, 'ex-1');
        expect(model.name, 'Bench Press');
        expect(model.type, 'single');
        expect(model.category, 'chest');
        expect(model.sets.length, 1);
        expect(model.restTime, 90);
        expect(model.countingMode, 'weighted');
        expect(model.movementType, 'compoundMedium');
        expect(model.supersetExercises, isNull);
        expect(model.dropSetStages, isNull);
        expect(model.restPauseSetsData, isNull);
      });
    });
  });

  group('WorkoutModel', () {
    final fixedDate = DateTime(2024, 1, 15, 10, 30);

    group('fromJson', () {
      test('parses minimal JSON with defaults', () {
        final json = <String, dynamic>{};
        final model = WorkoutModel.fromJson(json);

        expect(model.id, startsWith('workout-'));
        expect(model.name, 'Unnamed Workout');
        expect(model.status, 'completed');
        expect(model.exercises, isEmpty);
        expect(model.startTime, isNull);
        expect(model.endTime, isNull);
        expect(model.notes, isNull);
      });

      test('parses full JSON correctly', () {
        final json = <String, dynamic>{
          'id': 'w-1',
          'name': 'Push Day',
          'status': 'inProgress',
          'exercises': [
            {
              'id': 'ex-1',
              'name': 'Bench Press',
              'type': 'single',
              'category': 'chest',
              'sets': [],
            },
          ],
          'startTime': fixedDate.toIso8601String(),
          'endTime': fixedDate.toIso8601String(),
          'notes': 'Great workout',
          'createdAt': fixedDate.toIso8601String(),
          'updatedAt': fixedDate.toIso8601String(),
        };
        final model = WorkoutModel.fromJson(json);

        expect(model.id, 'w-1');
        expect(model.name, 'Push Day');
        expect(model.status, 'inProgress');
        expect(model.exercises.length, 1);
        expect(model.exercises[0].name, 'Bench Press');
        expect(model.startTime, fixedDate);
        expect(model.endTime, fixedDate);
        expect(model.notes, 'Great workout');
        expect(model.createdAt, fixedDate);
        expect(model.updatedAt, fixedDate);
      });

      test('handles null status as completed', () {
        final json = <String, dynamic>{
          'id': 'w-1',
          'status': null,
        };
        final model = WorkoutModel.fromJson(json);
        expect(model.status, 'completed');
      });

      test('handles null exercises list', () {
        final json = <String, dynamic>{
          'id': 'w-1',
          'exercises': null,
        };
        final model = WorkoutModel.fromJson(json);
        expect(model.exercises, isEmpty);
      });

      test('skips malformed exercises instead of failing', () {
        final json = <String, dynamic>{
          'id': 'w-1',
          'exercises': [
            {'id': 'ex-1', 'name': 'Valid'},
            'invalid-exercise-entry',
            {'id': 'ex-3', 'name': 'Also Valid'},
          ],
        };
        final model = WorkoutModel.fromJson(json);
        expect(model.exercises.length, 2);
      });

      test('handles Map<dynamic, dynamic> from Hive', () {
        final json = <dynamic, dynamic>{
          'id': 'w-hive',
          'name': 'Hive Workout',
        };
        final model = WorkoutModel.fromJson(json);
        expect(model.id, 'w-hive');
        expect(model.name, 'Hive Workout');
      });

      test('parses DateTime from ISO string', () {
        final date = DateTime(2024, 6, 15, 14, 30, 0);
        final json = <String, dynamic>{
          'startTime': date.toIso8601String(),
          'endTime': date.toIso8601String(),
          'createdAt': date.toIso8601String(),
          'updatedAt': date.toIso8601String(),
        };
        final model = WorkoutModel.fromJson(json);

        expect(model.startTime, date);
        expect(model.endTime, date);
        expect(model.createdAt, date);
        expect(model.updatedAt, date);
      });

      test('parses DateTime from DateTime object', () {
        final date = DateTime(2024, 6, 15, 14, 30, 0);
        final json = <String, dynamic>{
          'startTime': date,
          'createdAt': date,
          'updatedAt': date,
        };
        final model = WorkoutModel.fromJson(json);

        expect(model.startTime, date);
        expect(model.createdAt, date);
      });

      test('handles invalid DateTime string gracefully', () {
        final json = <String, dynamic>{
          'startTime': 'not-a-date',
        };
        final model = WorkoutModel.fromJson(json);
        expect(model.startTime, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final model = WorkoutModel(
          id: 'w-1',
          name: 'Push Day',
          exercises: [],
          status: 'completed',
          startTime: fixedDate,
          endTime: fixedDate,
          notes: 'Great workout',
          createdAt: fixedDate,
          updatedAt: fixedDate,
        );
        final json = model.toJson();

        expect(json['id'], 'w-1');
        expect(json['name'], 'Push Day');
        expect(json['exercises'], isA<List>());
        expect(json['status'], 'completed');
        expect(json['startTime'], fixedDate);
        expect(json['endTime'], fixedDate);
        expect(json['notes'], 'Great workout');
        expect(json['createdAt'], fixedDate);
        expect(json['updatedAt'], fixedDate);
      });
    });

    group('toDomain', () {
      test('converts to Workout domain entity', () {
        final model = WorkoutModel(
          id: 'w-1',
          name: 'Push Day',
          exercises: [
            ExerciseModel(
              id: 'ex-1',
              name: 'Bench Press',
              type: 'single',
              category: 'chest',
              sets: [],
              createdAt: fixedDate,
            ),
          ],
          status: 'completed',
          startTime: fixedDate,
          endTime: fixedDate,
          notes: 'Great workout',
          createdAt: fixedDate,
          updatedAt: fixedDate,
        );
        final domain = model.toDomain();

        expect(domain.id, 'w-1');
        expect(domain.name, 'Push Day');
        expect(domain.exercises.length, 1);
        expect(domain.status, WorkoutStatus.completed);
        expect(domain.startTime, fixedDate);
        expect(domain.endTime, fixedDate);
        expect(domain.notes, 'Great workout');
      });

      test('maps unknown status to planned', () {
        final model = WorkoutModel(
          id: 'w-1',
          name: 'Test',
          exercises: [],
          status: 'nonexistent_status',
          createdAt: fixedDate,
          updatedAt: fixedDate,
        );
        final domain = model.toDomain();
        expect(domain.status, WorkoutStatus.planned);
      });

      test('maps all WorkoutStatus values correctly', () {
        for (final status in WorkoutStatus.values) {
          final model = WorkoutModel(
            id: 'w-1',
            name: 'Test',
            exercises: [],
            status: status.name,
            createdAt: fixedDate,
            updatedAt: fixedDate,
          );
          final domain = model.toDomain();
          expect(domain.status, status);
        }
      });
    });

    group('fromDomain', () {
      test('converts from Workout domain entity', () {
        final workout = Workout(
          id: 'w-1',
          name: 'Push Day',
          exercises: [
            Exercise(
              id: 'ex-1',
              name: 'Bench Press',
              type: ExerciseType.single,
              category: ExerciseCategory.chest,
              sets: [],
              createdAt: fixedDate,
              updatedAt: fixedDate,
            ),
          ],
          status: WorkoutStatus.completed,
          startTime: fixedDate,
          endTime: fixedDate,
          notes: 'Great workout',
          createdAt: fixedDate,
          updatedAt: fixedDate,
        );
        final model = WorkoutModel.fromDomain(workout);

        expect(model.id, 'w-1');
        expect(model.name, 'Push Day');
        expect(model.exercises.length, 1);
        expect(model.status, 'completed');
        expect(model.startTime, fixedDate);
        expect(model.endTime, fixedDate);
        expect(model.notes, 'Great workout');
      });
    });

    group('copyWith', () {
      test('creates new instance with modified fields', () {
        final original = WorkoutModel(
          id: 'w-1',
          name: 'Push Day',
          exercises: [],
          status: 'planned',
          createdAt: fixedDate,
          updatedAt: fixedDate,
        );
        final modified = original.copyWith(
          name: 'Pull Day',
          status: 'completed',
        );

        expect(modified.id, 'w-1');
        expect(modified.name, 'Pull Day');
        expect(modified.status, 'completed');
        expect(original.name, 'Push Day'); // original unchanged
      });
    });

    group('JSON roundtrip', () {
      test('fromJson -> toJson -> fromJson preserves data', () {
        final json = <String, dynamic>{
          'id': 'w-roundtrip',
          'name': 'Roundtrip Workout',
          'status': 'completed',
          'exercises': [
            {
              'id': 'ex-1',
              'name': 'Squat',
              'type': 'single',
              'category': 'legs',
              'sets': [
                {
                  'id': 'set-1',
                  'setNumber': 1,
                  'weight': 100.0,
                  'reps': 5,
                  'isCompleted': true,
                },
              ],
              'createdAt': fixedDate.toIso8601String(),
            },
          ],
          'notes': 'Strong session',
          'createdAt': fixedDate.toIso8601String(),
          'updatedAt': fixedDate.toIso8601String(),
        };

        final model1 = WorkoutModel.fromJson(json);
        final outputJson = model1.toJson();
        final model2 = WorkoutModel.fromJson(outputJson);

        expect(model2.id, model1.id);
        expect(model2.name, model1.name);
        expect(model2.status, model1.status);
        expect(model2.exercises.length, model1.exercises.length);
        expect(model2.exercises[0].name, model1.exercises[0].name);
        expect(model2.notes, model1.notes);
      });
    });
  });
}

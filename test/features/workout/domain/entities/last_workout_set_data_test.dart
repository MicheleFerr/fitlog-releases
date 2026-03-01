import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/last_workout_set_data.dart';

void main() {
  group('LastWorkoutSetData', () {
    final testDate = DateTime(2026, 1, 15, 10, 30);

    LastWorkoutSetData createSubject({
      double weight = 80.0,
      int reps = 10,
      int? rpe,
      DateTime? date,
      String? workoutName,
      int setNumber = 1,
      String exerciseName = 'Bench Press',
    }) {
      return LastWorkoutSetData(
        weight: weight,
        reps: reps,
        rpe: rpe,
        date: date ?? testDate,
        workoutName: workoutName,
        setNumber: setNumber,
        exerciseName: exerciseName,
      );
    }

    group('factory creation', () {
      test('creates with all required fields', () {
        final data = createSubject();

        expect(data.weight, 80.0);
        expect(data.reps, 10);
        expect(data.date, testDate);
        expect(data.setNumber, 1);
        expect(data.exerciseName, 'Bench Press');
      });

      test('creates with all optional fields', () {
        final data = createSubject(
          rpe: 8,
          workoutName: 'Push Day',
        );

        expect(data.rpe, 8);
        expect(data.workoutName, 'Push Day');
      });

      test('nullable fields default to null', () {
        final data = createSubject();

        expect(data.rpe, isNull);
        expect(data.workoutName, isNull);
      });

      test('supports zero weight', () {
        final data = createSubject(weight: 0.0);
        expect(data.weight, 0.0);
      });

      test('supports decimal weight', () {
        final data = createSubject(weight: 82.5);
        expect(data.weight, 82.5);
      });
    });

    group('equality', () {
      test('two instances with same values are equal', () {
        final a = createSubject(rpe: 7, workoutName: 'Push');
        final b = createSubject(rpe: 7, workoutName: 'Push');

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different weight means not equal', () {
        final a = createSubject(weight: 80.0);
        final b = createSubject(weight: 85.0);

        expect(a, isNot(equals(b)));
      });

      test('different reps means not equal', () {
        final a = createSubject(reps: 10);
        final b = createSubject(reps: 12);

        expect(a, isNot(equals(b)));
      });

      test('different rpe means not equal', () {
        final a = createSubject(rpe: 7);
        final b = createSubject(rpe: 9);

        expect(a, isNot(equals(b)));
      });

      test('null vs non-null rpe means not equal', () {
        final a = createSubject(rpe: null);
        final b = createSubject(rpe: 8);

        expect(a, isNot(equals(b)));
      });

      test('different exerciseName means not equal', () {
        final a = createSubject(exerciseName: 'Bench Press');
        final b = createSubject(exerciseName: 'Squat');

        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('copies with new weight', () {
        final original = createSubject();
        final copy = original.copyWith(weight: 90.0);

        expect(copy.weight, 90.0);
        expect(copy.reps, original.reps);
        expect(copy.exerciseName, original.exerciseName);
      });

      test('copies with new rpe', () {
        final original = createSubject(rpe: 7);
        final copy = original.copyWith(rpe: 9);

        expect(copy.rpe, 9);
        expect(copy.weight, original.weight);
      });

      test('copies with new workoutName', () {
        final original = createSubject();
        final copy = original.copyWith(workoutName: 'Leg Day');

        expect(copy.workoutName, 'Leg Day');
      });

      test('returns equal object when no changes', () {
        final original = createSubject(rpe: 8, workoutName: 'Push');
        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('JSON serialization', () {
      test('toJson contains all required fields', () {
        final data = createSubject();
        final json = data.toJson();

        expect(json['weight'], 80.0);
        expect(json['reps'], 10);
        expect(json['setNumber'], 1);
        expect(json['exerciseName'], 'Bench Press');
        expect(json.containsKey('date'), isTrue);
      });

      test('toJson contains optional fields when set', () {
        final data = createSubject(rpe: 8, workoutName: 'Push Day');
        final json = data.toJson();

        expect(json['rpe'], 8);
        expect(json['workoutName'], 'Push Day');
      });

      test('toJson omits null optional fields or sets them null', () {
        final data = createSubject();
        final json = data.toJson();

        // Freezed may include null keys or omit them
        if (json.containsKey('rpe')) {
          expect(json['rpe'], isNull);
        }
      });

      test('fromJson round-trip preserves data', () {
        final original = createSubject(rpe: 8, workoutName: 'Push Day');
        final json = original.toJson();
        final restored = LastWorkoutSetData.fromJson(json);

        expect(restored, equals(original));
      });

      test('fromJson round-trip with null optionals', () {
        final original = createSubject();
        final json = original.toJson();
        final restored = LastWorkoutSetData.fromJson(json);

        expect(restored, equals(original));
      });

      test('fromJson with minimal JSON', () {
        final json = {
          'weight': 100.0,
          'reps': 5,
          'date': testDate.toIso8601String(),
          'setNumber': 3,
          'exerciseName': 'Squat',
        };

        final data = LastWorkoutSetData.fromJson(json);

        expect(data.weight, 100.0);
        expect(data.reps, 5);
        expect(data.setNumber, 3);
        expect(data.exerciseName, 'Squat');
        expect(data.rpe, isNull);
        expect(data.workoutName, isNull);
      });
    });
  });

  group('LastWorkoutSetParams', () {
    LastWorkoutSetParams createParams({
      String exerciseName = 'Bench Press',
      int setNumber = 1,
    }) {
      return LastWorkoutSetParams(
        exerciseName: exerciseName,
        setNumber: setNumber,
      );
    }

    group('factory creation', () {
      test('creates with required fields', () {
        final params = createParams();

        expect(params.exerciseName, 'Bench Press');
        expect(params.setNumber, 1);
      });

      test('creates with custom values', () {
        final params = createParams(exerciseName: 'Squat', setNumber: 3);

        expect(params.exerciseName, 'Squat');
        expect(params.setNumber, 3);
      });
    });

    group('equality', () {
      test('same values are equal', () {
        final a = createParams();
        final b = createParams();

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different exerciseName means not equal', () {
        final a = createParams(exerciseName: 'Bench Press');
        final b = createParams(exerciseName: 'Squat');

        expect(a, isNot(equals(b)));
      });

      test('different setNumber means not equal', () {
        final a = createParams(setNumber: 1);
        final b = createParams(setNumber: 2);

        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('copies with new exerciseName', () {
        final original = createParams();
        final copy = original.copyWith(exerciseName: 'Deadlift');

        expect(copy.exerciseName, 'Deadlift');
        expect(copy.setNumber, original.setNumber);
      });

      test('copies with new setNumber', () {
        final original = createParams();
        final copy = original.copyWith(setNumber: 5);

        expect(copy.setNumber, 5);
        expect(copy.exerciseName, original.exerciseName);
      });
    });

    group('JSON serialization', () {
      test('toJson produces correct map', () {
        final params = createParams();
        final json = params.toJson();

        expect(json['exerciseName'], 'Bench Press');
        expect(json['setNumber'], 1);
      });

      test('fromJson round-trip preserves data', () {
        final original = createParams(exerciseName: 'OHP', setNumber: 2);
        final json = original.toJson();
        final restored = LastWorkoutSetParams.fromJson(json);

        expect(restored, equals(original));
      });
    });
  });
}

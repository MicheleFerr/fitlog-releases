import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

void main() {
  group('💪 Exercise 100% Coverage Tests', () {
    group('Exercise Edge Cases', () {
      test('copyWith with null values preserves originals', () {
        final original = Exercise(
          id: 'ex-123',
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [
            ExerciseSet(setNumber: 1, weight: 60, reps: 10),
          ],
          notes: 'Original notes',
          restTime: 120,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
        );

        // copyWith senza parametri mantiene tutti i valori
        final copy = original.copyWith();
        
        expect(copy.id, original.id);
        expect(copy.name, original.name);
        expect(copy.type, original.type);
        expect(copy.category, original.category);
        expect(copy.sets.length, original.sets.length);
        expect(copy.notes, original.notes);
        expect(copy.restTime, original.restTime);
      });

      test('fromJson with missing optional fields', () {
        final json = {
          'id': 'ex-456',
          'name': 'Squats',
          'type': 'superset',
          'category': 'legs',
          'sets': [],
          'notes': null,
          'restTime': null,
          'createdAt': DateTime(2024, 1, 1).toIso8601String(),
          'updatedAt': DateTime(2024, 1, 2).toIso8601String(),
        };

        final exercise = Exercise.fromJson(json);
        
        expect(exercise.id, 'ex-456');
        expect(exercise.name, 'Squats');
        expect(exercise.type, ExerciseType.superset);
        expect(exercise.category, ExerciseCategory.legs);
        expect(exercise.sets, isEmpty);
        expect(exercise.notes, isNull);
        expect(exercise.restTime, isNull);
      });

      test('toJson with all fields populated', () {
        final exercise = Exercise(
          id: 'ex-789',
          name: 'Deadlift',
          type: ExerciseType.dropset,
          category: ExerciseCategory.back,
          sets: [
            ExerciseSet(
              setNumber: 1,
              weight: 100,
              reps: 5,
              isCompleted: true,
            ),
          ],
          notes: 'Heavy day',
          restTime: 180,
        );

        final json = exercise.toJson();
        
        expect(json['id'], 'ex-789');
        expect(json['name'], 'Deadlift');
        expect(json['type'], 'dropset');
        expect(json['category'], 'back');
        expect(json['sets'], isA<List>());
        expect(json['notes'], 'Heavy day');
        expect(json['restTimeSeconds'], 180);
        expect(json['createdAt'], isNotNull);
        expect(json['updatedAt'], isNotNull);
      });
    });

    group('ExerciseSet Complete Coverage', () {
      test('constructor with all parameters', () {
        final set = ExerciseSet(
          id: 'set-123',
          setNumber: 1,
          weight: 50.5,
          reps: 12,
          actualReps: 10,
          isCompleted: true,
          notes: 'Easy set',
          isWarmup: true,
          rpe: 8,
          setDurationMillis: 45000,
          completedAt: DateTime(2024, 1, 1, 10, 30),
          setStartedAt: DateTime(2024, 1, 1, 10, 29),
        );

        expect(set.id, 'set-123');
        expect(set.setNumber, 1);
        expect(set.weight, 50.5);
        expect(set.reps, 12);
        expect(set.actualReps, 10);
        expect(set.isCompleted, true);
        expect(set.notes, 'Easy set');
        expect(set.isWarmup, true);
        expect(set.rpe, 8);
        expect(set.setDurationMillis, 45000);
        expect(set.completedAt, DateTime(2024, 1, 1, 10, 30));
        expect(set.setStartedAt, DateTime(2024, 1, 1, 10, 29));
      });

      test('auto-generates UUID when id is null', () {
        final set1 = ExerciseSet(setNumber: 1, weight: 50, reps: 10);
        final set2 = ExerciseSet(setNumber: 1, weight: 50, reps: 10);
        
        expect(set1.id, isNotEmpty);
        expect(set2.id, isNotEmpty);
        expect(set1.id, isNot(equals(set2.id)));
      });

      test('properties calculation', () {
        final set1 = ExerciseSet(setNumber: 1, weight: 100, reps: 10);
        expect(set1.setNumber, 1);
        expect(set1.weight, 100);
        expect(set1.reps, 10);

        final set2 = ExerciseSet(setNumber: 2, weight: 50.5, reps: 8);
        expect(set2.weight, 50.5);
        expect(set2.reps, 8);

        final set3 = ExerciseSet(setNumber: 3, weight: 0, reps: 20);
        expect(set3.weight, 0);
        expect(set3.reps, 20);
      });

      test('copyWith preserves values', () {
        final original = ExerciseSet(
          id: 'set-456',
          setNumber: 2,
          weight: 60,
          reps: 8,
          actualReps: 7,
          isCompleted: false,
          notes: 'Original note',
          isWarmup: false,
          rpe: 8,
          setDurationMillis: 30000,
        );

        final copy = original.copyWith(
          weight: 65,
          reps: 7,
          isCompleted: true,
        );

        expect(copy.id, original.id);
        expect(copy.setNumber, original.setNumber);
        expect(copy.weight, 65);
        expect(copy.reps, 7);
        expect(copy.isCompleted, true);
        expect(copy.notes, original.notes);
        expect(copy.isWarmup, original.isWarmup);
        expect(copy.rpe, original.rpe);
        expect(copy.setDurationMillis, original.setDurationMillis);
        expect(copy.actualReps, original.actualReps);
      });

      test('copyWith with no parameters', () {
        final original = ExerciseSet(
          setNumber: 1,
          weight: 50,
          reps: 10,
        );

        final copy = original.copyWith();
        
        expect(copy.id, original.id);
        expect(copy.setNumber, original.setNumber);
        expect(copy.weight, original.weight);
        expect(copy.reps, original.reps);
      });

      test('toJson complete', () {
        final set = ExerciseSet(
          id: 'set-json',
          setNumber: 3,
          weight: 75.5,
          reps: 6,
          actualReps: 5,
          isCompleted: true,
          notes: 'Last set',
          isWarmup: false,
          rpe: 9,
          setDurationMillis: 60000,
          completedAt: DateTime(2024, 1, 1, 11, 0),
          setStartedAt: DateTime(2024, 1, 1, 10, 59),
        );

        final json = set.toJson();
        
        expect(json['id'], 'set-json');
        expect(json['setNumber'], 3);
        expect(json['weight'], 75.5);
        expect(json['reps'], 6);
        expect(json['actualReps'], 5);
        expect(json['isCompleted'], true);
        expect(json['notes'], 'Last set');
        expect(json['isWarmup'], false);
        expect(json['rpe'], 9);
        expect(json['setDurationMillis'], 60000);
        expect(json['completedAt'], isNotNull);
        expect(json['setStartedAt'], isNotNull);
      });

      test('fromJson complete', () {
        final json = {
          'id': 'set-from-json',
          'setNumber': 4,
          'weight': 80.0,
          'reps': 5,
          'actualReps': 5,
          'isCompleted': false,
          'notes': 'Heavy set',
          'isWarmup': false,
          'rpe': 10,
          'setDurationMillis': 45000.0,
          'completedAt': DateTime(2024, 1, 1).toIso8601String(),
          'setStartedAt': DateTime(2024, 1, 1).toIso8601String(),
        };

        final set = ExerciseSet.fromJson(json);
        
        expect(set.id, 'set-from-json');
        expect(set.setNumber, 4);
        expect(set.weight, 80.0);
        expect(set.reps, 5);
        expect(set.actualReps, 5);
        expect(set.isCompleted, false);
        expect(set.notes, 'Heavy set');
        expect(set.isWarmup, false);
        expect(set.rpe, 10);
        expect(set.setDurationMillis, 45000.0);
        expect(set.completedAt, isNotNull);
        expect(set.setStartedAt, isNotNull);
      });

      test('fromJson with null optional fields', () {
        final json = {
          'setNumber': 1,
          'weight': 50.0,
          'reps': 10,
        };

        final set = ExerciseSet.fromJson(json);
        
        expect(set.id, isNotEmpty); // Auto-generated
        expect(set.setNumber, 1);
        expect(set.weight, 50.0);
        expect(set.reps, 10);
        expect(set.isCompleted, false); // Default
        expect(set.notes, isNull);
        expect(set.isWarmup, false); // Default
        expect(set.rpe, isNull);
        expect(set.actualReps, isNull);
        expect(set.setDurationMillis, isNull);
        expect(set.completedAt, isNull);
        expect(set.setStartedAt, isNull);
      });

      test('toString', () {
        final set = ExerciseSet(
          setNumber: 5,
          weight: 100,
          reps: 3,
          isCompleted: true,
        );

        final str = set.toString();
        
        expect(str, contains('5')); // setNumber
        expect(str, contains('100')); // weight
        expect(str, contains('3')); // reps
        expect(str, contains('true')); // isCompleted
      });

      test('equality operator', () {
        final set1 = ExerciseSet(
          id: 'same-id',
          setNumber: 1,
          weight: 50,
          reps: 10,
        );

        final set2 = ExerciseSet(
          id: 'same-id',
          setNumber: 2,
          weight: 60,
          reps: 8,
        );

        final set3 = ExerciseSet(
          id: 'different-id',
          setNumber: 1,
          weight: 50,
          reps: 10,
        );

        expect(set1 == set2, true); // Same ID
        expect(set1 == set3, false); // Different ID
        expect(set1 == set1, true); // Same object
      });

      test('hashCode', () {
        final set1 = ExerciseSet(
          id: 'same-id',
          setNumber: 1,
          weight: 50,
          reps: 10,
        );

        final set2 = ExerciseSet(
          id: 'same-id',
          setNumber: 2,
          weight: 60,
          reps: 8,
        );

        final set3 = ExerciseSet(
          id: 'different-id',
          setNumber: 1,
          weight: 50,
          reps: 10,
        );

        expect(set1.hashCode, set2.hashCode);
        expect(set1.hashCode, isNot(set3.hashCode));
      });
    });

    group('ExerciseType enum coverage', () {
      test('all enum values are unique', () {
        final types = ExerciseType.values;
        final uniqueTypes = types.toSet();
        expect(uniqueTypes.length, types.length);
      });

      test('enum contains expected values', () {
        expect(ExerciseType.values, contains(ExerciseType.single));
        expect(ExerciseType.values, contains(ExerciseType.superset));
        expect(ExerciseType.values, contains(ExerciseType.dropset));
        expect(ExerciseType.values, contains(ExerciseType.restPause));
      });
    });

    group('ExerciseCategory enum coverage', () {
      test('all enum values are unique', () {
        final categories = ExerciseCategory.values;
        final uniqueCategories = categories.toSet();
        expect(uniqueCategories.length, categories.length);
      });

      test('enum contains all expected categories', () {
        expect(ExerciseCategory.values, contains(ExerciseCategory.chest));
        expect(ExerciseCategory.values, contains(ExerciseCategory.back));
        expect(ExerciseCategory.values, contains(ExerciseCategory.shoulders));
        expect(ExerciseCategory.values, contains(ExerciseCategory.arms));
        expect(ExerciseCategory.values, contains(ExerciseCategory.legs));
        expect(ExerciseCategory.values, contains(ExerciseCategory.abs));
        expect(ExerciseCategory.values, contains(ExerciseCategory.cardio));
        expect(ExerciseCategory.values, contains(ExerciseCategory.other));
      });
    });
  });
}
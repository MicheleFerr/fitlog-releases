import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

void main() {
  group('🏋️ Exercise Entity Complete Coverage Tests', () {
    group('Constructor & Basic Properties', () {
      test('✅ Create Exercise with all properties', () {
        final now = DateTime.now();
        final sets = [
          ExerciseSet(setNumber: 1, reps: 10, weight: 60.0),
          ExerciseSet(setNumber: 2, reps: 10, weight: 60.0),
        ];
        
        final exercise = Exercise(
          id: 'exercise-123',
          name: 'Bench Press',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: sets,
          notes: 'Good form',
          restTime: 90,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        
        expect(exercise.id, 'exercise-123');
        expect(exercise.name, 'Bench Press');
        expect(exercise.type, ExerciseType.single);
        expect(exercise.category, ExerciseCategory.chest);
        expect(exercise.sets.length, 2);
        expect(exercise.notes, 'Good form');
        expect(exercise.restTime, 90);
        expect(exercise.createdAt, now);
        expect(exercise.updatedAt, now);
      });

      test('✅ Create Exercise with minimal properties', () {
        final exercise = Exercise(
          name: 'Squat',
          type: ExerciseType.single,
          category: ExerciseCategory.legs,
        );
        
        expect(exercise.name, 'Squat');
        expect(exercise.type, ExerciseType.single);
        expect(exercise.category, ExerciseCategory.legs);
        expect(exercise.sets, isEmpty);
        expect(exercise.notes, isNull);
        expect(exercise.restTime, isNull);
        expect(exercise.id, isNotEmpty); // Auto-generated
      });

      test('✅ Create Exercise with auto-generated ID', () {
        final exercise = Exercise(
          name: 'Deadlift',
          type: ExerciseType.single,
          category: ExerciseCategory.back,
        );
        
        expect(exercise.id, isNotEmpty);
        expect(exercise.id.length, 36); // UUID v4 length
      });
    });

    group('ExerciseType Enum', () {
      test('✅ All ExerciseType values', () {
        expect(ExerciseType.values.length, 4);
        expect(ExerciseType.values.contains(ExerciseType.single), true);
        expect(ExerciseType.values.contains(ExerciseType.superset), true);
        expect(ExerciseType.values.contains(ExerciseType.dropset), true);
        expect(ExerciseType.values.contains(ExerciseType.restPause), true);
      });

      test('✅ ExerciseType string conversion', () {
        expect(ExerciseType.single.name, 'single');
        expect(ExerciseType.superset.name, 'superset');
        expect(ExerciseType.dropset.name, 'dropset');
        expect(ExerciseType.restPause.name, 'restPause');
      });
    });

    group('ExerciseCategory Enum', () {
      test('✅ All ExerciseCategory values', () {
        expect(ExerciseCategory.values.length, 8);
        expect(ExerciseCategory.values.contains(ExerciseCategory.chest), true);
        expect(ExerciseCategory.values.contains(ExerciseCategory.back), true);
        expect(ExerciseCategory.values.contains(ExerciseCategory.shoulders), true);
        expect(ExerciseCategory.values.contains(ExerciseCategory.arms), true);
        expect(ExerciseCategory.values.contains(ExerciseCategory.legs), true);
        expect(ExerciseCategory.values.contains(ExerciseCategory.abs), true);
        expect(ExerciseCategory.values.contains(ExerciseCategory.cardio), true);
        expect(ExerciseCategory.values.contains(ExerciseCategory.other), true);
      });

      test('✅ ExerciseCategory string conversion', () {
        expect(ExerciseCategory.chest.name, 'chest');
        expect(ExerciseCategory.back.name, 'back');
        expect(ExerciseCategory.shoulders.name, 'shoulders');
        expect(ExerciseCategory.arms.name, 'arms');
        expect(ExerciseCategory.legs.name, 'legs');
        expect(ExerciseCategory.abs.name, 'abs');
        expect(ExerciseCategory.cardio.name, 'cardio');
        expect(ExerciseCategory.other.name, 'other');
      });
    });

    group('copyWith Method', () {
      test('✅ copyWith all properties', () {
        final original = Exercise(
          id: 'original',
          name: 'Original Exercise',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          sets: [],
          notes: 'Original notes',
          restTime: 60,
        );
        
        final newSets = [
          ExerciseSet(setNumber: 1, reps: 12),
        ];
        
        final copied = original.copyWith(
          name: 'Copied Exercise',
          type: ExerciseType.superset,
          category: ExerciseCategory.legs,
          sets: newSets,
          notes: 'New notes',
          restTime: 90,
        );
        
        expect(copied.id, 'original'); // ID unchanged
        expect(copied.name, 'Copied Exercise');
        expect(copied.type, ExerciseType.superset);
        expect(copied.category, ExerciseCategory.legs);
        expect(copied.sets.length, 1);
        expect(copied.notes, 'New notes');
        expect(copied.restTime, 90);
      });

      test('✅ copyWith partial properties', () {
        final original = Exercise(
          name: 'Original',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
        );
        
        final copied = original.copyWith(
          name: 'Modified',
        );
        
        expect(copied.name, 'Modified');
        expect(copied.type, ExerciseType.single); // Unchanged
        expect(copied.category, ExerciseCategory.chest); // Unchanged
      });

      test('✅ copyWith updates updatedAt', () {
        final original = Exercise(
          name: 'Test',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        
        final beforeCopy = DateTime.now();
        final copied = original.copyWith(name: 'Updated');
        final afterCopy = DateTime.now();
        
        expect(copied.createdAt, original.createdAt); // Not changed
        expect(copied.updatedAt.isAfter(beforeCopy) || 
               copied.updatedAt.isAtSameMomentAs(beforeCopy), true);
        expect(copied.updatedAt.isBefore(afterCopy) || 
               copied.updatedAt.isAtSameMomentAs(afterCopy), true);
      });
    });

    group('JSON Serialization', () {
      test('✅ toJson with all properties', () {
        final now = DateTime.now();
        final exercise = Exercise(
          id: 'json-test',
          name: 'JSON Exercise',
          type: ExerciseType.dropset,
          category: ExerciseCategory.arms,
          sets: [
            ExerciseSet(setNumber: 1, reps: 10, weight: 50.0),
          ],
          notes: 'Test notes',
          restTime: 120,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );
        
        final json = exercise.toJson();
        
        expect(json['id'], 'json-test');
        expect(json['name'], 'JSON Exercise');
        expect(json['type'], 'dropset');
        expect(json['category'], 'arms');
        expect(json['sets'], isA<List>());
        expect(json['sets'].length, 1);
        expect(json['notes'], 'Test notes');
        expect(json['restTime'], 120);
        expect(json['createdAt'], now.toIso8601String());
        expect(json['updatedAt'], now.toIso8601String());
      });

      test('✅ fromJson with all properties', () {
        final now = DateTime.now();
        final json = {
          'id': 'from-json',
          'name': 'From JSON',
          'type': 'restPause',
          'category': 'shoulders',
          'sets': [
            {
              'id': 'set1',
              'setNumber': 1,
              'weight': 30.0,
              'reps': 15,
              'isCompleted': false,
              'isWarmup': false,
            }
          ],
          'notes': 'From JSON notes',
          'restTime': 45,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };
        
        final exercise = Exercise.fromJson(json);
        
        expect(exercise.id, 'from-json');
        expect(exercise.name, 'From JSON');
        expect(exercise.type, ExerciseType.restPause);
        expect(exercise.category, ExerciseCategory.shoulders);
        expect(exercise.sets.length, 1);
        expect(exercise.notes, 'From JSON notes');
        expect(exercise.restTime, 45);
      });

      test('✅ fromJson with null sets', () {
        final json = {
          'id': 'no-sets',
          'name': 'No Sets',
          'type': 'single',
          'category': 'abs',
          'sets': null,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        
        final exercise = Exercise.fromJson(json);
        
        expect(exercise.sets, isEmpty);
      });

      test('✅ JSON roundtrip', () {
        final original = Exercise(
          id: 'roundtrip',
          name: 'Roundtrip Test',
          type: ExerciseType.superset,
          category: ExerciseCategory.back,
          sets: [
            ExerciseSet(setNumber: 1, reps: 8, weight: 70.0),
            ExerciseSet(setNumber: 2, reps: 8, weight: 70.0),
          ],
          notes: 'Test roundtrip',
          restTime: 75,
        );
        
        final json = original.toJson();
        final restored = Exercise.fromJson(json);
        
        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.type, original.type);
        expect(restored.category, original.category);
        expect(restored.sets.length, original.sets.length);
        expect(restored.notes, original.notes);
        expect(restored.restTime, original.restTime);
      });
    });

    group('Exercise Properties', () {
      test('✅ Exercise with different types', () {
        // Single exercise
        var exercise = Exercise(
          name: 'Single',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
        );
        expect(exercise.type, ExerciseType.single);
        
        // Superset
        exercise = Exercise(
          name: 'Superset',
          type: ExerciseType.superset,
          category: ExerciseCategory.chest,
        );
        expect(exercise.type, ExerciseType.superset);
        
        // Dropset
        exercise = Exercise(
          name: 'Dropset',
          type: ExerciseType.dropset,
          category: ExerciseCategory.chest,
        );
        expect(exercise.type, ExerciseType.dropset);
        
        // Rest-pause
        exercise = Exercise(
          name: 'Rest-Pause',
          type: ExerciseType.restPause,
          category: ExerciseCategory.chest,
        );
        expect(exercise.type, ExerciseType.restPause);
      });

      test('✅ Exercise with different categories', () {
        for (final category in ExerciseCategory.values) {
          final exercise = Exercise(
            name: 'Test ${category.name}',
            type: ExerciseType.single,
            category: category,
          );
          expect(exercise.category, category);
        }
      });
    });

    group('Edge Cases', () {
      test('✅ Exercise with empty name', () {
        final exercise = Exercise(
          name: '',
          type: ExerciseType.single,
          category: ExerciseCategory.other,
        );
        
        expect(exercise.name, '');
      });

      test('✅ Exercise with very long name', () {
        final longName = 'A' * 1000;
        final exercise = Exercise(
          name: longName,
          type: ExerciseType.single,
          category: ExerciseCategory.other,
        );
        
        expect(exercise.name, longName);
      });

      test('✅ Exercise with negative rest time (shouldn\'t happen but test safety)', () {
        final exercise = Exercise(
          name: 'Negative Rest',
          type: ExerciseType.single,
          category: ExerciseCategory.other,
          restTime: -30,
        );
        
        expect(exercise.restTime, -30); // Should store as-is
      });

      test('✅ Exercise with very large rest time', () {
        final exercise = Exercise(
          name: 'Long Rest',
          type: ExerciseType.single,
          category: ExerciseCategory.other,
          restTime: 999999,
        );
        
        expect(exercise.restTime, 999999);
      });
    });
  });

  group('🏋️ ExerciseSet Complete Coverage Tests', () {
    group('Constructor & Basic Properties', () {
      test('✅ Create ExerciseSet with all properties', () {
        final now = DateTime.now();
        final set = ExerciseSet(
          id: 'set-123',
          setNumber: 1,
          weight: 60.0,
          reps: 10,
          actualReps: 9,
          rpe: 8,
          seconds: 30,
          distance: 5.0,
          isCompleted: true,
          notes: 'Good set',
          completedAt: now,
          setDurationMillis: 45000,
          setStartedAt: now.subtract(const Duration(seconds: 45)),
          isWarmup: false,
        );
        
        expect(set.id, 'set-123');
        expect(set.setNumber, 1);
        expect(set.weight, 60.0);
        expect(set.reps, 10);
        expect(set.actualReps, 9);
        expect(set.rpe, 8);
        expect(set.seconds, 30);
        expect(set.distance, 5.0);
        expect(set.isCompleted, true);
        expect(set.notes, 'Good set');
        expect(set.completedAt, now);
        expect(set.setDurationMillis, 45000);
        expect(set.setStartedAt, now.subtract(const Duration(seconds: 45)));
        expect(set.isWarmup, false);
      });

      test('✅ Create ExerciseSet with minimal properties', () {
        final set = ExerciseSet(
          setNumber: 1,
        );
        
        expect(set.setNumber, 1);
        expect(set.weight, isNull);
        expect(set.reps, isNull);
        expect(set.actualReps, isNull);
        expect(set.rpe, isNull);
        expect(set.seconds, isNull);
        expect(set.distance, isNull);
        expect(set.isCompleted, false);
        expect(set.notes, isNull);
        expect(set.completedAt, isNull);
        expect(set.setDurationMillis, isNull);
        expect(set.setStartedAt, isNull);
        expect(set.isWarmup, false);
        expect(set.id, isNotEmpty); // Auto-generated
      });

      test('✅ Create warmup set', () {
        final set = ExerciseSet(
          setNumber: 1,
          weight: 20.0,
          reps: 15,
          isWarmup: true,
        );
        
        expect(set.isWarmup, true);
        expect(set.weight, 20.0);
        expect(set.reps, 15);
      });

      test('✅ Create time-based set (for planks, etc)', () {
        final set = ExerciseSet(
          setNumber: 1,
          seconds: 60,
          isCompleted: true,
        );
        
        expect(set.seconds, 60);
        expect(set.weight, isNull);
        expect(set.reps, isNull);
      });

      test('✅ Create distance-based set (for cardio)', () {
        final set = ExerciseSet(
          setNumber: 1,
          distance: 5.0,
          seconds: 1800, // 30 minutes
          isCompleted: true,
        );
        
        expect(set.distance, 5.0);
        expect(set.seconds, 1800);
      });
    });

    group('copyWith Method', () {
      test('✅ copyWith all properties', () {
        final now = DateTime.now();
        final original = ExerciseSet(
          id: 'original',
          setNumber: 1,
          weight: 50.0,
          reps: 10,
          isCompleted: false,
        );
        
        final copied = original.copyWith(
          setNumber: 2,
          weight: 60.0,
          reps: 8,
          actualReps: 7,
          rpe: 9,
          seconds: 45,
          distance: 3.0,
          isCompleted: true,
          notes: 'Tough set',
          completedAt: now,
          setDurationMillis: 60000,
          setStartedAt: now.subtract(const Duration(minutes: 1)),
          isWarmup: true,
        );
        
        expect(copied.id, 'original'); // ID unchanged
        expect(copied.setNumber, 2);
        expect(copied.weight, 60.0);
        expect(copied.reps, 8);
        expect(copied.actualReps, 7);
        expect(copied.rpe, 9);
        expect(copied.seconds, 45);
        expect(copied.distance, 3.0);
        expect(copied.isCompleted, true);
        expect(copied.notes, 'Tough set');
        expect(copied.completedAt, now);
        expect(copied.setDurationMillis, 60000);
        expect(copied.isWarmup, true);
      });

      test('✅ copyWith partial properties', () {
        final original = ExerciseSet(
          setNumber: 1,
          weight: 50.0,
          reps: 10,
        );
        
        final copied = original.copyWith(
          weight: 55.0,
          isCompleted: true,
        );
        
        expect(copied.weight, 55.0);
        expect(copied.reps, 10); // Unchanged
        expect(copied.isCompleted, true);
      });
    });

    group('JSON Serialization', () {
      test('✅ toJson with all properties', () {
        final now = DateTime.now();
        final set = ExerciseSet(
          id: 'json-set',
          setNumber: 3,
          weight: 80.0,
          reps: 6,
          actualReps: 5,
          rpe: 10,
          seconds: 30,
          distance: 2.5,
          isCompleted: true,
          notes: 'Max effort',
          completedAt: now,
          setDurationMillis: 35000,
          setStartedAt: now.subtract(const Duration(seconds: 35)),
          isWarmup: false,
        );
        
        final json = set.toJson();
        
        expect(json['id'], 'json-set');
        expect(json['setNumber'], 3);
        expect(json['weight'], 80.0);
        expect(json['reps'], 6);
        expect(json['actualReps'], 5);
        expect(json['rpe'], 10);
        expect(json['seconds'], 30);
        expect(json['distance'], 2.5);
        expect(json['isCompleted'], true);
        expect(json['notes'], 'Max effort');
        expect(json['completedAt'], now.toIso8601String());
        expect(json['setDurationMillis'], 35000);
        expect(json['isWarmup'], false);
      });

      test('✅ fromJson with all properties', () {
        final now = DateTime.now();
        final json = {
          'id': 'from-json-set',
          'setNumber': 2,
          'weight': 70.0,
          'reps': 8,
          'actualReps': 8,
          'rpe': 7,
          'seconds': 0,
          'distance': 0.0,
          'isCompleted': true,
          'notes': 'From JSON',
          'completedAt': now.toIso8601String(),
          'setDurationMillis': 40000.0,
          'setStartedAt': now.subtract(const Duration(seconds: 40)).toIso8601String(),
          'isWarmup': true,
        };
        
        final set = ExerciseSet.fromJson(json);
        
        expect(set.id, 'from-json-set');
        expect(set.setNumber, 2);
        expect(set.weight, 70.0);
        expect(set.reps, 8);
        expect(set.actualReps, 8);
        expect(set.rpe, 7);
        expect(set.isCompleted, true);
        expect(set.notes, 'From JSON');
        expect(set.isWarmup, true);
      });

      test('✅ JSON roundtrip', () {
        final original = ExerciseSet(
          id: 'roundtrip-set',
          setNumber: 1,
          weight: 100.0,
          reps: 5,
          actualReps: 5,
          rpe: 9,
          isCompleted: true,
          notes: 'Heavy',
          isWarmup: false,
        );
        
        final json = original.toJson();
        final restored = ExerciseSet.fromJson(json);
        
        expect(restored.id, original.id);
        expect(restored.setNumber, original.setNumber);
        expect(restored.weight, original.weight);
        expect(restored.reps, original.reps);
        expect(restored.actualReps, original.actualReps);
        expect(restored.rpe, original.rpe);
        expect(restored.isCompleted, original.isCompleted);
        expect(restored.notes, original.notes);
        expect(restored.isWarmup, original.isWarmup);
      });
    });

    group('Set Variations', () {
      test('✅ RPE validation range', () {
        // Valid RPE values (typically 5-10 scale)
        for (int rpe = 5; rpe <= 10; rpe++) {
          final set = ExerciseSet(
            setNumber: 1,
            rpe: rpe,
          );
          expect(set.rpe, rpe);
        }
        
        // Edge cases
        final lowRpe = ExerciseSet(setNumber: 1, rpe: 1);
        expect(lowRpe.rpe, 1);
        
        final highRpe = ExerciseSet(setNumber: 1, rpe: 15);
        expect(highRpe.rpe, 15);
      });

      test('✅ Actual reps vs target reps', () {
        final set = ExerciseSet(
          setNumber: 1,
          reps: 10, // Target
          actualReps: 8, // Actual achieved
          isCompleted: true,
        );
        
        expect(set.reps, 10);
        expect(set.actualReps, 8);
        expect(set.actualReps! < set.reps!, true); // Didn't hit target
      });

      test('✅ Set duration tracking', () {
        final startTime = DateTime.now();
        final endTime = startTime.add(const Duration(seconds: 45));
        
        final set = ExerciseSet(
          setNumber: 1,
          setStartedAt: startTime,
          completedAt: endTime,
          setDurationMillis: 45000,
          isCompleted: true,
        );
        
        expect(set.setDurationMillis, 45000);
        expect(
          set.completedAt!.difference(set.setStartedAt!).inMilliseconds,
          closeTo(45000, 1000),
        );
      });
    });

    group('Edge Cases', () {
      test('✅ Set with zero weight', () {
        final set = ExerciseSet(
          setNumber: 1,
          weight: 0.0,
          reps: 10,
        );
        
        expect(set.weight, 0.0); // Bodyweight exercise
      });

      test('✅ Set with negative values (shouldn\'t happen but test safety)', () {
        final set = ExerciseSet(
          setNumber: -1,
          weight: -50.0,
          reps: -10,
          seconds: -30,
          distance: -5.0,
        );
        
        expect(set.setNumber, -1);
        expect(set.weight, -50.0);
        expect(set.reps, -10);
        expect(set.seconds, -30);
        expect(set.distance, -5.0);
      });

      test('✅ Set with very large values', () {
        final set = ExerciseSet(
          setNumber: 999,
          weight: 999999.99,
          reps: 999999,
          seconds: 999999,
          distance: 999999.99,
        );
        
        expect(set.setNumber, 999);
        expect(set.weight, 999999.99);
        expect(set.reps, 999999);
        expect(set.seconds, 999999);
        expect(set.distance, 999999.99);
      });

      test('✅ Set with all null optional values', () {
        final set = ExerciseSet(
          setNumber: 1,
          weight: null,
          reps: null,
          actualReps: null,
          rpe: null,
          seconds: null,
          distance: null,
          notes: null,
          completedAt: null,
          setDurationMillis: null,
          setStartedAt: null,
        );
        
        expect(set.weight, isNull);
        expect(set.reps, isNull);
        expect(set.actualReps, isNull);
        expect(set.rpe, isNull);
        expect(set.seconds, isNull);
        expect(set.distance, isNull);
        expect(set.notes, isNull);
        expect(set.completedAt, isNull);
        expect(set.setDurationMillis, isNull);
        expect(set.setStartedAt, isNull);
      });

      test('✅ Set with empty notes', () {
        final set = ExerciseSet(
          setNumber: 1,
          notes: '',
        );
        
        expect(set.notes, '');
      });

      test('✅ Set with very long notes', () {
        final longNotes = 'A' * 10000;
        final set = ExerciseSet(
          setNumber: 1,
          notes: longNotes,
        );
        
        expect(set.notes, longNotes);
      });
    });
  });
}
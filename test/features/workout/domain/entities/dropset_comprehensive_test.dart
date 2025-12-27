import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

void main() {
  group('DropSetExercise Comprehensive Tests', () {
    group('Creation', () {
      test('creates dropset with all fields', () {
        final dropset = DropSetExercise(
          id: 'drop-1',
          name: 'Bicep Curls Dropset',
          category: ExerciseCategory.arms,
          stages: [
            DropSetStage(weight: 20, reps: 8),
            DropSetStage(weight: 15, reps: 10),
            DropSetStage(weight: 10, reps: 12),
          ],
          notes: 'Go to failure',
          restTime: 60,
        );

        expect(dropset.id, 'drop-1');
        expect(dropset.name, 'Bicep Curls Dropset');
        expect(dropset.type, ExerciseType.dropset);
        expect(dropset.category, ExerciseCategory.arms);
        expect(dropset.stages.length, 3);
        expect(dropset.notes, 'Go to failure');
        expect(dropset.restTime, 60);
      });

      test('creates dropset with minimum fields', () {
        final dropset = DropSetExercise(
          name: 'Simple Dropset',
          category: ExerciseCategory.chest,
          stages: [],
        );

        expect(dropset.name, 'Simple Dropset');
        expect(dropset.type, ExerciseType.dropset);
        expect(dropset.category, ExerciseCategory.chest);
        expect(dropset.stages, isEmpty);
        expect(dropset.notes, isNull);
        expect(dropset.restTime, isNull);
      });

      test('auto-generates id when not provided', () {
        final dropset = DropSetExercise(
          name: 'Test',
          category: ExerciseCategory.chest,
          stages: [],
        );

        expect(dropset.id, isNotEmpty);
      });
    });

    group('Serialization - toJson', () {
      test('serializes all fields correctly', () {
        final dropset = DropSetExercise(
          id: 'drop-json-1',
          name: 'Test Dropset',
          category: ExerciseCategory.back,
          stages: [
            DropSetStage(weight: 100, reps: 10, isCompleted: true),
            DropSetStage(weight: 80, reps: 12, isCompleted: false),
          ],
          notes: 'Test notes',
          restTime: 90,
        );

        final json = dropset.toJson();

        expect(json['id'], 'drop-json-1');
        expect(json['name'], 'Test Dropset');
        expect(json['type'], 'dropset');
        expect(json['category'], 'back');
        expect(json['notes'], 'Test notes');
        expect(json['restTime'], 90);
        expect(json['stages'], isA<List>());
        expect((json['stages'] as List).length, 2);

        final stage1 = (json['stages'] as List)[0] as Map<String, dynamic>;
        expect(stage1['weight'], 100);
        expect(stage1['reps'], 10);
        expect(stage1['isCompleted'], true);
      });

      test('serializes empty stages', () {
        final dropset = DropSetExercise(
          id: 'drop-empty',
          name: 'Empty Dropset',
          category: ExerciseCategory.chest,
          stages: [],
        );

        final json = dropset.toJson();

        expect(json['stages'], isA<List>());
        expect((json['stages'] as List), isEmpty);
      });

      test('includes createdAt and updatedAt', () {
        final dropset = DropSetExercise(
          name: 'Test',
          category: ExerciseCategory.chest,
          stages: [],
        );

        final json = dropset.toJson();

        expect(json['createdAt'], isNotNull);
        expect(json['updatedAt'], isNotNull);
      });
    });

    group('Deserialization - fromJson', () {
      test('deserializes complete JSON', () {
        final json = {
          'id': 'drop-from-json',
          'name': 'Loaded Dropset',
          'type': 'dropset',
          'category': 'legs',
          'notes': 'Loaded notes',
          'restTime': 120,
          'stages': [
            {'weight': 150.0, 'reps': 8, 'isCompleted': true},
            {'weight': 120.0, 'reps': 10, 'isCompleted': true},
            {'weight': 90.0, 'reps': 12, 'isCompleted': false},
          ],
        };

        final dropset = DropSetExercise.fromJson(json);

        expect(dropset.id, 'drop-from-json');
        expect(dropset.name, 'Loaded Dropset');
        expect(dropset.type, ExerciseType.dropset);
        expect(dropset.category, ExerciseCategory.legs);
        expect(dropset.notes, 'Loaded notes');
        expect(dropset.restTime, 120);
        expect(dropset.stages.length, 3);
        expect(dropset.stages[0].weight, 150.0);
        expect(dropset.stages[0].isCompleted, true);
        expect(dropset.stages[2].isCompleted, false);
      });

      test('deserializes with missing optional fields', () {
        final json = {
          'id': 'drop-minimal',
          'name': 'Minimal Dropset',
          'category': 'chest',
          'stages': [],
        };

        final dropset = DropSetExercise.fromJson(json);

        expect(dropset.id, 'drop-minimal');
        expect(dropset.name, 'Minimal Dropset');
        expect(dropset.category, ExerciseCategory.chest);
        expect(dropset.notes, isNull);
        expect(dropset.restTime, isNull);
        expect(dropset.stages, isEmpty);
      });

      test('handles missing stages array', () {
        final json = {
          'id': 'drop-no-stages',
          'name': 'No Stages',
          'category': 'arms',
        };

        final dropset = DropSetExercise.fromJson(json);

        expect(dropset.stages, isEmpty);
      });

      test('uses exerciseId as fallback for id', () {
        final json = {
          'exerciseId': 'ex-123',
          'name': 'Test',
          'category': 'chest',
          'stages': [],
        };

        final dropset = DropSetExercise.fromJson(json);

        expect(dropset.id, 'ex-123');
      });

      test('uses exerciseName as fallback for name', () {
        final json = {
          'id': 'drop-1',
          'exerciseName': 'Fallback Name',
          'category': 'chest',
          'stages': [],
        };

        final dropset = DropSetExercise.fromJson(json);

        expect(dropset.name, 'Fallback Name');
      });

      test('uses default name when no name provided', () {
        final json = {
          'id': 'drop-1',
          'category': 'chest',
          'stages': [],
        };

        final dropset = DropSetExercise.fromJson(json);

        expect(dropset.name, 'Drop Set');
      });

      test('uses other category for unknown category', () {
        final json = {
          'id': 'drop-1',
          'name': 'Test',
          'category': 'unknown_category',
          'stages': [],
        };

        final dropset = DropSetExercise.fromJson(json);

        expect(dropset.category, ExerciseCategory.other);
      });

      test('handles restTime as integer', () {
        final json = {
          'id': 'drop-1',
          'name': 'Test',
          'category': 'chest',
          'stages': [],
          'restTime': 90,
        };

        final dropset = DropSetExercise.fromJson(json);

        expect(dropset.restTime, 90);
      });

      test('handles restTime as double', () {
        final json = {
          'id': 'drop-1',
          'name': 'Test',
          'category': 'chest',
          'stages': [],
          'restTime': 90.0,
        };

        final dropset = DropSetExercise.fromJson(json);

        expect(dropset.restTime, 90);
      });

      test('handles non-numeric restTime', () {
        final json = {
          'id': 'drop-1',
          'name': 'Test',
          'category': 'chest',
          'stages': [],
          'restTime': 'invalid',
        };

        final dropset = DropSetExercise.fromJson(json);

        expect(dropset.restTime, isNull);
      });
    });

    group('Round-trip serialization', () {
      test('toJson then fromJson preserves data', () {
        final original = DropSetExercise(
          id: 'roundtrip-1',
          name: 'Roundtrip Test',
          category: ExerciseCategory.shoulders,
          stages: [
            DropSetStage(weight: 50, reps: 10, isCompleted: true),
            DropSetStage(weight: 40, reps: 12, isCompleted: false),
          ],
          notes: 'Roundtrip notes',
          restTime: 45,
        );

        final json = original.toJson();
        final restored = DropSetExercise.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.type, original.type);
        expect(restored.category, original.category);
        expect(restored.notes, original.notes);
        expect(restored.restTime, original.restTime);
        expect(restored.stages.length, original.stages.length);

        for (var i = 0; i < original.stages.length; i++) {
          expect(restored.stages[i].weight, original.stages[i].weight);
          expect(restored.stages[i].reps, original.stages[i].reps);
          expect(restored.stages[i].isCompleted, original.stages[i].isCompleted);
        }
      });
    });
  });

  group('DropSetStage Comprehensive Tests', () {
    group('Creation', () {
      test('creates stage with all fields', () {
        final stage = DropSetStage(
          weight: 100.0,
          reps: 10,
          isCompleted: true,
        );

        expect(stage.weight, 100.0);
        expect(stage.reps, 10);
        expect(stage.isCompleted, true);
      });

      test('creates stage with default isCompleted', () {
        final stage = DropSetStage(
          weight: 50.0,
          reps: 8,
        );

        expect(stage.weight, 50.0);
        expect(stage.reps, 8);
        expect(stage.isCompleted, false);
      });
    });

    group('copyWith', () {
      test('copies all fields when specified', () {
        final original = DropSetStage(
          weight: 100,
          reps: 10,
          isCompleted: false,
        );

        final copy = original.copyWith(
          weight: 80,
          reps: 12,
          isCompleted: true,
        );

        expect(copy.weight, 80);
        expect(copy.reps, 12);
        expect(copy.isCompleted, true);

        // Original unchanged
        expect(original.weight, 100);
        expect(original.reps, 10);
        expect(original.isCompleted, false);
      });

      test('preserves unspecified fields', () {
        final original = DropSetStage(
          weight: 100,
          reps: 10,
          isCompleted: false,
        );

        final copy = original.copyWith(isCompleted: true);

        expect(copy.weight, 100);
        expect(copy.reps, 10);
        expect(copy.isCompleted, true);
      });
    });

    group('Serialization - toJson', () {
      test('serializes all fields', () {
        final stage = DropSetStage(
          weight: 75.5,
          reps: 12,
          isCompleted: true,
        );

        final json = stage.toJson();

        expect(json['weight'], 75.5);
        expect(json['reps'], 12);
        expect(json['isCompleted'], true);
      });
    });

    group('Deserialization - fromJson', () {
      test('deserializes complete JSON', () {
        final json = {
          'weight': 60.0,
          'reps': 15,
          'isCompleted': true,
        };

        final stage = DropSetStage.fromJson(json);

        expect(stage.weight, 60.0);
        expect(stage.reps, 15);
        expect(stage.isCompleted, true);
      });

      test('handles missing weight (defaults to 0)', () {
        final json = {
          'reps': 10,
          'isCompleted': false,
        };

        final stage = DropSetStage.fromJson(json);

        expect(stage.weight, 0.0);
        expect(stage.reps, 10);
      });

      test('handles missing reps (defaults to 0)', () {
        final json = {
          'weight': 50.0,
          'isCompleted': false,
        };

        final stage = DropSetStage.fromJson(json);

        expect(stage.weight, 50.0);
        expect(stage.reps, 0);
      });

      test('handles missing isCompleted (defaults to false)', () {
        final json = {
          'weight': 50.0,
          'reps': 10,
        };

        final stage = DropSetStage.fromJson(json);

        expect(stage.isCompleted, false);
      });

      test('handles weight as int', () {
        final json = {
          'weight': 100,
          'reps': 10,
          'isCompleted': false,
        };

        final stage = DropSetStage.fromJson(json);

        expect(stage.weight, 100.0);
      });

      test('handles null values', () {
        final json = <String, dynamic>{
          'weight': null,
          'reps': null,
          'isCompleted': null,
        };

        final stage = DropSetStage.fromJson(json);

        expect(stage.weight, 0.0);
        expect(stage.reps, 0);
        expect(stage.isCompleted, false);
      });
    });
  });

  group('Edge Cases', () {
    test('dropset with zero weight stage', () {
      final dropset = DropSetExercise(
        name: 'Zero Weight Test',
        category: ExerciseCategory.arms,
        stages: [
          DropSetStage(weight: 0, reps: 10),
        ],
      );

      expect(dropset.stages[0].weight, 0);
      expect(dropset.stages[0].reps, 10);
    });

    test('dropset with zero reps stage', () {
      final dropset = DropSetExercise(
        name: 'Zero Reps Test',
        category: ExerciseCategory.arms,
        stages: [
          DropSetStage(weight: 50, reps: 0),
        ],
      );

      expect(dropset.stages[0].weight, 50);
      expect(dropset.stages[0].reps, 0);
    });

    test('dropset with very high weight', () {
      final dropset = DropSetExercise(
        name: 'Heavy Test',
        category: ExerciseCategory.legs,
        stages: [
          DropSetStage(weight: 500, reps: 3),
          DropSetStage(weight: 400, reps: 5),
          DropSetStage(weight: 300, reps: 8),
        ],
      );

      expect(dropset.stages[0].weight, 500);
      expect(dropset.stages.length, 3);

      final json = dropset.toJson();
      final restored = DropSetExercise.fromJson(json);

      expect(restored.stages[0].weight, 500);
    });

    test('dropset with decimal weights', () {
      final dropset = DropSetExercise(
        name: 'Decimal Test',
        category: ExerciseCategory.chest,
        stages: [
          DropSetStage(weight: 22.5, reps: 10),
          DropSetStage(weight: 17.5, reps: 12),
          DropSetStage(weight: 12.5, reps: 15),
        ],
      );

      final json = dropset.toJson();
      final restored = DropSetExercise.fromJson(json);

      expect(restored.stages[0].weight, 22.5);
      expect(restored.stages[1].weight, 17.5);
      expect(restored.stages[2].weight, 12.5);
    });

    test('dropset with many stages', () {
      final stages = List.generate(
        10,
        (i) => DropSetStage(
          weight: 100 - (i * 10).toDouble(),
          reps: 8 + i,
        ),
      );

      final dropset = DropSetExercise(
        name: 'Many Stages',
        category: ExerciseCategory.arms,
        stages: stages,
      );

      expect(dropset.stages.length, 10);
      expect(dropset.stages.first.weight, 100);
      expect(dropset.stages.last.weight, 10);

      final json = dropset.toJson();
      final restored = DropSetExercise.fromJson(json);

      expect(restored.stages.length, 10);
    });

    test('dropset with special characters in notes', () {
      final dropset = DropSetExercise(
        name: 'Special Notes',
        category: ExerciseCategory.chest,
        stages: [],
        notes: 'Notes with "quotes" and \'apostrophes\' and emoji',
      );

      final json = dropset.toJson();
      final restored = DropSetExercise.fromJson(json);

      expect(restored.notes, dropset.notes);
    });

    test('dropset with unicode name', () {
      final dropset = DropSetExercise(
        name: 'Curl con Manubri',
        category: ExerciseCategory.arms,
        stages: [
          DropSetStage(weight: 12, reps: 10),
        ],
      );

      final json = dropset.toJson();
      final restored = DropSetExercise.fromJson(json);

      expect(restored.name, 'Curl con Manubri');
    });

    test('dropset with all categories', () {
      for (final category in ExerciseCategory.values) {
        final dropset = DropSetExercise(
          name: 'Category Test',
          category: category,
          stages: [],
        );

        final json = dropset.toJson();
        final restored = DropSetExercise.fromJson(json);

        expect(restored.category, category);
      }
    });
  });

  group('Factory Pattern - Exercise.fromJson', () {
    test('Exercise.fromJson creates DropSetExercise for type=dropset', () {
      final json = {
        'id': 'factory-test',
        'name': 'Factory Test',
        'type': 'dropset',
        'category': 'chest',
        'stages': [
          {'weight': 100.0, 'reps': 10, 'isCompleted': false},
        ],
      };

      final exercise = Exercise.fromJson(json);

      expect(exercise, isA<DropSetExercise>());
      expect(exercise.type, ExerciseType.dropset);

      final dropset = exercise as DropSetExercise;
      expect(dropset.stages.length, 1);
      expect(dropset.stages[0].weight, 100.0);
    });
  });
}

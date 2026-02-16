import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

void main() {
  group('DropSetStage', () {
    test('effectiveReps returns actualReps when set', () {
      final stage = DropSetStage(
        weight: 100.0,
        reps: 10,
        actualReps: 8,
        isCompleted: true,
      );

      expect(stage.effectiveReps, 8);
    });

    test('effectiveReps returns reps when actualReps is null', () {
      final stage = DropSetStage(
        weight: 100.0,
        reps: 10,
        isCompleted: true,
      );

      expect(stage.effectiveReps, 10);
    });

    test('copyWith preserves rpe', () {
      final stage = DropSetStage(
        weight: 100.0,
        reps: 10,
        isCompleted: true,
      );

      final updated = stage.copyWith(rpe: 8);

      expect(updated.rpe, 8);
      expect(updated.weight, 100.0);
      expect(updated.reps, 10);
      expect(updated.isCompleted, true);
    });

    test('copyWith preserves all existing fields', () {
      final stage = DropSetStage(
        weight: 100.0,
        reps: 10,
        actualReps: 8,
        rpe: 9,
        isCompleted: true,
        completedAt: DateTime(2024, 1, 15, 10, 30),
      );

      final updated = stage.copyWith(weight: 90.0);

      expect(updated.weight, 90.0);
      expect(updated.reps, 10);
      expect(updated.actualReps, 8);
      expect(updated.rpe, 9);
      expect(updated.isCompleted, true);
      expect(updated.completedAt, DateTime(2024, 1, 15, 10, 30));
    });

    test('toJson includes rpe and actualReps', () {
      final stage = DropSetStage(
        weight: 100.0,
        reps: 10,
        actualReps: 8,
        rpe: 9,
        isCompleted: true,
        completedAt: DateTime(2024, 1, 15, 10, 30),
      );

      final json = stage.toJson();

      expect(json['weight'], 100.0);
      expect(json['reps'], 10);
      expect(json['actualReps'], 8);
      expect(json['rpe'], 9);
      expect(json['isCompleted'], true);
      expect(json['completedAt'], '2024-01-15T10:30:00.000');
    });

    test('toJson excludes null optional fields', () {
      final stage = DropSetStage(
        weight: 100.0,
        reps: 10,
        isCompleted: false,
      );

      final json = stage.toJson();

      expect(json['weight'], 100.0);
      expect(json['reps'], 10);
      expect(json['actualReps'], isNull);
      expect(json['rpe'], isNull);
      expect(json['isCompleted'], false);
      expect(json['completedAt'], isNull);
    });

    test('fromJson parses rpe and actualReps', () {
      final json = {
        'weight': 100.0,
        'reps': 10,
        'actualReps': 8,
        'rpe': 9,
        'isCompleted': true,
        'completedAt': '2024-01-15T10:30:00.000',
      };

      final stage = DropSetStage.fromJson(json);

      expect(stage.weight, 100.0);
      expect(stage.reps, 10);
      expect(stage.actualReps, 8);
      expect(stage.rpe, 9);
      expect(stage.isCompleted, true);
      expect(stage.completedAt, DateTime(2024, 1, 15, 10, 30));
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'weight': 100.0,
        'reps': 10,
        'isCompleted': true,
      };

      final stage = DropSetStage.fromJson(json);

      expect(stage.weight, 100.0);
      expect(stage.reps, 10);
      expect(stage.actualReps, isNull);
      expect(stage.rpe, isNull);
      expect(stage.isCompleted, true);
      expect(stage.completedAt, isNull);
    });

    test('fromJson handles null values', () {
      final json = <String, dynamic>{
        'weight': null,
        'reps': null,
        'actualReps': null,
        'rpe': null,
        'isCompleted': null,
        'completedAt': null,
      };

      final stage = DropSetStage.fromJson(json);

      expect(stage.weight, 0.0);
      expect(stage.reps, 0);
      expect(stage.actualReps, isNull);
      expect(stage.rpe, isNull);
      expect(stage.isCompleted, false);
      expect(stage.completedAt, isNull);
    });

    test('volume calculation with effectiveReps', () {
      final stages = [
        DropSetStage(weight: 100.0, reps: 10, isCompleted: true),
        DropSetStage(weight: 80.0, reps: 10, actualReps: 8, isCompleted: true),
        DropSetStage(weight: 60.0, reps: 10, isCompleted: true),
      ];

      // Total volume: (100*10) + (80*8) + (60*10) = 1000 + 640 + 600 = 2240
      final totalVolume = stages.fold<double>(0.0, (sum, stage) {
        return sum + (stage.weight * stage.effectiveReps);
      });

      expect(totalVolume, 2240.0);
    });

    test('total reps calculation', () {
      final stages = [
        DropSetStage(weight: 100.0, reps: 10, isCompleted: true),
        DropSetStage(weight: 80.0, reps: 10, actualReps: 8, isCompleted: true),
        DropSetStage(weight: 60.0, reps: 10, isCompleted: true),
      ];

      // Total reps: 10 + 8 + 10 = 28 (uses effectiveReps)
      final totalReps =
          stages.fold<int>(0, (sum, stage) => sum + stage.effectiveReps);

      expect(totalReps, 28);
    });
  });

  group('DropSetExercise', () {
    test('creates with stages', () {
      final stages = [
        DropSetStage(weight: 100.0, reps: 10),
        DropSetStage(weight: 80.0, reps: 10),
      ];

      final exercise = DropSetExercise(
        name: 'Bench Press',
        category: ExerciseCategory.chest,
        stages: stages,
      );

      expect(exercise.name, 'Bench Press');
      expect(exercise.type, ExerciseType.dropset);
      expect(exercise.stages.length, 2);
      expect(exercise.stages[0].weight, 100.0);
      expect(exercise.stages[1].weight, 80.0);
    });

    test('serializes stages with RPE in toJson', () {
      final stages = [
        DropSetStage(weight: 100.0, reps: 10, rpe: 8, isCompleted: true),
        DropSetStage(weight: 80.0, reps: 10, rpe: 8, isCompleted: true),
      ];

      final exercise = DropSetExercise(
        name: 'Bench Press',
        category: ExerciseCategory.chest,
        stages: stages,
      );

      final json = exercise.toJson();
      final stagesJson = json['stages'] as List;

      expect(stagesJson.length, 2);
      expect(stagesJson[0]['rpe'], 8);
      expect(stagesJson[1]['rpe'], 8);
    });

    test('fromJson parses stages with RPE', () {
      final json = {
        'name': 'Bench Press',
        'type': 'dropset',
        'category': 'chest',
        'stages': [
          {'weight': 100.0, 'reps': 10, 'rpe': 9, 'isCompleted': true},
          {'weight': 80.0, 'reps': 10, 'rpe': 9, 'isCompleted': true},
        ],
      };

      final exercise = DropSetExercise.fromJson(json);

      expect(exercise.stages.length, 2);
      expect(exercise.stages[0].rpe, 9);
      expect(exercise.stages[1].rpe, 9);
    });

    test('can add new stage to existing exercise', () {
      final existingStages = [
        DropSetStage(weight: 100.0, reps: 10, isCompleted: true),
        DropSetStage(weight: 80.0, reps: 10, isCompleted: true),
      ];

      final exercise = DropSetExercise(
        name: 'Bench Press',
        category: ExerciseCategory.chest,
        stages: existingStages,
      );

      // Simulate adding a new stage
      final newStage = DropSetStage(weight: 60.0, reps: 10, isCompleted: false);
      final updatedStages = [...exercise.stages, newStage];

      final updatedExercise = DropSetExercise(
        id: exercise.id,
        name: exercise.name,
        category: exercise.category,
        stages: updatedStages,
      );

      expect(updatedExercise.stages.length, 3);
      expect(updatedExercise.stages[2].weight, 60.0);
      expect(updatedExercise.stages[2].isCompleted, false);
    });

    test('new stage weight calculation based on previous stage', () {
      const lastStageWeight = 80.0;

      // Simulate -5kg drop suggestion
      const suggestedWeight = lastStageWeight - 5.0;
      expect(suggestedWeight, 75.0);

      // Simulate -10kg drop
      const biggerDrop = lastStageWeight - 10.0;
      expect(biggerDrop, 70.0);

      // Ensure weight doesn't go below 0
      const smallWeight = 2.5;
      final clampedWeight = (smallWeight - 5.0).clamp(0.0, double.infinity);
      expect(clampedWeight, 0.0);
    });
  });
}

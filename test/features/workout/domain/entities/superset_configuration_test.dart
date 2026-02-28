import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart'
    as ExerciseDB;
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_configuration.dart';

/// Helper to create a minimal ExerciseDefinition for testing.
ExerciseDB.ExerciseDefinition _makeExercise({
  required String id,
  String nome = 'Test Exercise',
}) {
  return ExerciseDB.ExerciseDefinition(
    id: id,
    nome: nome,
    focus: const ['CHEST'],
    muscoliSecondari: const ['TRIC'],
    difficolta: 'Intermedio',
    tipoEsercizio: 'Compound',
    attrezzatura: 'Bilanciere',
    patternMovimento: 'Push',
    rangeRipetizioni: '8-12',
  );
}

void main() {
  group('SupersetExerciseConfig', () {
    test('constructor stores all fields', () {
      const config = SupersetExerciseConfig(
        exerciseId: 'ex-1',
        targetReps: 10,
        targetWeight: 60.0,
      );
      expect(config.exerciseId, 'ex-1');
      expect(config.targetReps, 10);
      expect(config.targetWeight, 60.0);
    });

    test('targetWeight defaults to null', () {
      const config = SupersetExerciseConfig(
        exerciseId: 'ex-1',
        targetReps: 12,
      );
      expect(config.targetWeight, isNull);
    });

    test('copyWith updates exerciseId', () {
      const config = SupersetExerciseConfig(
        exerciseId: 'ex-1',
        targetReps: 10,
        targetWeight: 50.0,
      );
      final copy = config.copyWith(exerciseId: 'ex-2');
      expect(copy.exerciseId, 'ex-2');
      expect(copy.targetReps, 10);
      expect(copy.targetWeight, 50.0);
    });

    test('copyWith updates targetReps', () {
      const config = SupersetExerciseConfig(
        exerciseId: 'ex-1',
        targetReps: 10,
      );
      final copy = config.copyWith(targetReps: 15);
      expect(copy.targetReps, 15);
      expect(copy.exerciseId, 'ex-1');
    });

    test('copyWith updates targetWeight', () {
      const config = SupersetExerciseConfig(
        exerciseId: 'ex-1',
        targetReps: 10,
      );
      final copy = config.copyWith(targetWeight: 80.0);
      expect(copy.targetWeight, 80.0);
    });

    test('copyWith preserves all fields when no args given', () {
      const config = SupersetExerciseConfig(
        exerciseId: 'ex-1',
        targetReps: 10,
        targetWeight: 50.0,
      );
      final copy = config.copyWith();
      expect(copy.exerciseId, 'ex-1');
      expect(copy.targetReps, 10);
      expect(copy.targetWeight, 50.0);
    });
  });

  group('SupersetRound', () {
    group('constructor', () {
      test('stores all fields', () {
        const configs = {
          'ex-1': SupersetExerciseConfig(exerciseId: 'ex-1', targetReps: 10),
          'ex-2': SupersetExerciseConfig(exerciseId: 'ex-2', targetReps: 12),
        };
        const round = SupersetRound(
          roundNumber: 1,
          exerciseConfigs: configs,
          notes: 'Focus on form',
        );
        expect(round.roundNumber, 1);
        expect(round.exerciseConfigs, hasLength(2));
        expect(round.notes, 'Focus on form');
      });

      test('notes defaults to null', () {
        const round = SupersetRound(
          roundNumber: 1,
          exerciseConfigs: {
            'ex-1': SupersetExerciseConfig(exerciseId: 'ex-1', targetReps: 10),
          },
        );
        expect(round.notes, isNull);
      });
    });

    group('uniform factory', () {
      test('creates same config for all exercise ids', () {
        final round = SupersetRound.uniform(
          roundNumber: 1,
          targetReps: 10,
          targetWeight: 50.0,
          exerciseIds: ['ex-1', 'ex-2', 'ex-3'],
        );
        expect(round.exerciseConfigs, hasLength(3));
        for (final entry in round.exerciseConfigs.entries) {
          expect(entry.value.targetReps, 10);
          expect(entry.value.targetWeight, 50.0);
          expect(entry.value.exerciseId, entry.key);
        }
      });

      test('handles single exercise id', () {
        final round = SupersetRound.uniform(
          roundNumber: 2,
          targetReps: 8,
          exerciseIds: ['ex-1'],
        );
        expect(round.exerciseConfigs, hasLength(1));
        expect(round.roundNumber, 2);
      });

      test('notes parameter works', () {
        final round = SupersetRound.uniform(
          roundNumber: 1,
          targetReps: 10,
          exerciseIds: ['ex-1'],
          notes: 'Go heavy',
        );
        expect(round.notes, 'Go heavy');
      });

      test('targetWeight defaults to null in uniform', () {
        final round = SupersetRound.uniform(
          roundNumber: 1,
          targetReps: 10,
          exerciseIds: ['ex-1'],
        );
        expect(round.exerciseConfigs['ex-1']!.targetWeight, isNull);
      });
    });

    group('legacy getters', () {
      test('targetReps returns first config targetReps', () {
        final round = SupersetRound.uniform(
          roundNumber: 1,
          targetReps: 12,
          exerciseIds: ['ex-1', 'ex-2'],
        );
        expect(round.targetReps, 12);
      });

      test('targetWeight returns first config targetWeight', () {
        final round = SupersetRound.uniform(
          roundNumber: 1,
          targetReps: 10,
          targetWeight: 75.0,
          exerciseIds: ['ex-1', 'ex-2'],
        );
        expect(round.targetWeight, 75.0);
      });

      test('targetWeight returns null when first config has no weight', () {
        final round = SupersetRound.uniform(
          roundNumber: 1,
          targetReps: 10,
          exerciseIds: ['ex-1'],
        );
        expect(round.targetWeight, isNull);
      });
    });

    group('copyWith', () {
      test('updates roundNumber', () {
        final round = SupersetRound.uniform(
          roundNumber: 1,
          targetReps: 10,
          exerciseIds: ['ex-1'],
        );
        final copy = round.copyWith(roundNumber: 3);
        expect(copy.roundNumber, 3);
        expect(copy.exerciseConfigs, hasLength(1));
      });

      test('updates exerciseConfigs', () {
        final round = SupersetRound.uniform(
          roundNumber: 1,
          targetReps: 10,
          exerciseIds: ['ex-1'],
        );
        final newConfigs = {
          'ex-2': const SupersetExerciseConfig(
            exerciseId: 'ex-2',
            targetReps: 15,
          ),
        };
        final copy = round.copyWith(exerciseConfigs: newConfigs);
        expect(copy.exerciseConfigs, hasLength(1));
        expect(copy.exerciseConfigs.containsKey('ex-2'), true);
      });

      test('updates notes', () {
        final round = SupersetRound.uniform(
          roundNumber: 1,
          targetReps: 10,
          exerciseIds: ['ex-1'],
        );
        final copy = round.copyWith(notes: 'New notes');
        expect(copy.notes, 'New notes');
      });

      test('preserves all fields when no args given', () {
        final round = SupersetRound.uniform(
          roundNumber: 2,
          targetReps: 8,
          targetWeight: 40.0,
          exerciseIds: ['ex-1', 'ex-2'],
          notes: 'Warm up first',
        );
        final copy = round.copyWith();
        expect(copy.roundNumber, 2);
        expect(copy.exerciseConfigs, hasLength(2));
        expect(copy.notes, 'Warm up first');
      });
    });
  });

  group('SupersetConfiguration', () {
    final exercise1 = _makeExercise(id: 'ex-1', nome: 'Bench Press');
    final exercise2 = _makeExercise(id: 'ex-2', nome: 'Bent Over Row');
    final exercise3 = _makeExercise(id: 'ex-3', nome: 'Overhead Press');

    group('constructor', () {
      test('stores required fields', () {
        final round = SupersetRound.uniform(
          roundNumber: 1,
          targetReps: 10,
          exerciseIds: ['ex-1', 'ex-2'],
        );
        final config = SupersetConfiguration(
          exercises: [exercise1, exercise2],
          rounds: [round],
        );
        expect(config.exercises, hasLength(2));
        expect(config.rounds, hasLength(1));
      });

      test('defaults restBetweenExercises to 0', () {
        final config = SupersetConfiguration(
          exercises: [exercise1, exercise2],
          rounds: [],
        );
        expect(config.restBetweenExercises, 0);
      });

      test('defaults restAfterRound to 90', () {
        final config = SupersetConfiguration(
          exercises: [exercise1, exercise2],
          rounds: [],
        );
        expect(config.restAfterRound, 90);
      });

      test('defaults name to Superset', () {
        final config = SupersetConfiguration(
          exercises: [exercise1, exercise2],
          rounds: [],
        );
        expect(config.name, 'Superset');
      });

      test('accepts custom rest and name values', () {
        final config = SupersetConfiguration(
          exercises: [exercise1, exercise2],
          rounds: [],
          restBetweenExercises: 30,
          restAfterRound: 120,
          name: 'Chest & Back',
        );
        expect(config.restBetweenExercises, 30);
        expect(config.restAfterRound, 120);
        expect(config.name, 'Chest & Back');
      });
    });

    group('isValid', () {
      test('returns true with 2+ exercises and non-empty rounds', () {
        final round = SupersetRound.uniform(
          roundNumber: 1,
          targetReps: 10,
          exerciseIds: ['ex-1', 'ex-2'],
        );
        final config = SupersetConfiguration(
          exercises: [exercise1, exercise2],
          rounds: [round],
        );
        expect(config.isValid, true);
      });

      test('returns false with 0 exercises', () {
        final round = SupersetRound.uniform(
          roundNumber: 1,
          targetReps: 10,
          exerciseIds: [],
        );
        final config = SupersetConfiguration(
          exercises: [],
          rounds: [round],
        );
        expect(config.isValid, false);
      });

      test('returns false with 1 exercise', () {
        final round = SupersetRound.uniform(
          roundNumber: 1,
          targetReps: 10,
          exerciseIds: ['ex-1'],
        );
        final config = SupersetConfiguration(
          exercises: [exercise1],
          rounds: [round],
        );
        expect(config.isValid, false);
      });

      test('returns false with empty rounds', () {
        final config = SupersetConfiguration(
          exercises: [exercise1, exercise2],
          rounds: [],
        );
        expect(config.isValid, false);
      });

      test('returns false with 1 exercise and empty rounds', () {
        final config = SupersetConfiguration(
          exercises: [exercise1],
          rounds: [],
        );
        expect(config.isValid, false);
      });

      test('returns true with 3 exercises and multiple rounds', () {
        final rounds = [
          SupersetRound.uniform(
            roundNumber: 1,
            targetReps: 10,
            exerciseIds: ['ex-1', 'ex-2', 'ex-3'],
          ),
          SupersetRound.uniform(
            roundNumber: 2,
            targetReps: 10,
            exerciseIds: ['ex-1', 'ex-2', 'ex-3'],
          ),
        ];
        final config = SupersetConfiguration(
          exercises: [exercise1, exercise2, exercise3],
          rounds: rounds,
        );
        expect(config.isValid, true);
      });
    });

    group('totalSets', () {
      test('returns number of rounds', () {
        final rounds = [
          SupersetRound.uniform(
            roundNumber: 1,
            targetReps: 10,
            exerciseIds: ['ex-1', 'ex-2'],
          ),
          SupersetRound.uniform(
            roundNumber: 2,
            targetReps: 10,
            exerciseIds: ['ex-1', 'ex-2'],
          ),
          SupersetRound.uniform(
            roundNumber: 3,
            targetReps: 10,
            exerciseIds: ['ex-1', 'ex-2'],
          ),
        ];
        final config = SupersetConfiguration(
          exercises: [exercise1, exercise2],
          rounds: rounds,
        );
        expect(config.totalSets, 3);
      });

      test('returns 0 when no rounds', () {
        final config = SupersetConfiguration(
          exercises: [exercise1, exercise2],
          rounds: [],
        );
        expect(config.totalSets, 0);
      });

      test('returns 1 with single round', () {
        final config = SupersetConfiguration(
          exercises: [exercise1, exercise2],
          rounds: [
            SupersetRound.uniform(
              roundNumber: 1,
              targetReps: 10,
              exerciseIds: ['ex-1', 'ex-2'],
            ),
          ],
        );
        expect(config.totalSets, 1);
      });
    });

    group('copyWith', () {
      test('updates exercises', () {
        final config = SupersetConfiguration(
          exercises: [exercise1, exercise2],
          rounds: [],
        );
        final copy = config.copyWith(exercises: [exercise1]);
        expect(copy.exercises, hasLength(1));
      });

      test('updates rounds', () {
        final config = SupersetConfiguration(
          exercises: [exercise1, exercise2],
          rounds: [],
        );
        final newRounds = [
          SupersetRound.uniform(
            roundNumber: 1,
            targetReps: 10,
            exerciseIds: ['ex-1', 'ex-2'],
          ),
        ];
        final copy = config.copyWith(rounds: newRounds);
        expect(copy.rounds, hasLength(1));
      });

      test('updates restBetweenExercises', () {
        final config = SupersetConfiguration(
          exercises: [exercise1, exercise2],
          rounds: [],
        );
        final copy = config.copyWith(restBetweenExercises: 30);
        expect(copy.restBetweenExercises, 30);
      });

      test('updates restAfterRound', () {
        final config = SupersetConfiguration(
          exercises: [exercise1, exercise2],
          rounds: [],
        );
        final copy = config.copyWith(restAfterRound: 180);
        expect(copy.restAfterRound, 180);
      });

      test('updates name', () {
        final config = SupersetConfiguration(
          exercises: [exercise1, exercise2],
          rounds: [],
        );
        final copy = config.copyWith(name: 'Push/Pull');
        expect(copy.name, 'Push/Pull');
      });

      test('preserves all fields when no args given', () {
        final round = SupersetRound.uniform(
          roundNumber: 1,
          targetReps: 10,
          exerciseIds: ['ex-1', 'ex-2'],
        );
        final config = SupersetConfiguration(
          exercises: [exercise1, exercise2],
          rounds: [round],
          restBetweenExercises: 15,
          restAfterRound: 120,
          name: 'My Superset',
        );
        final copy = config.copyWith();
        expect(copy.exercises, hasLength(2));
        expect(copy.rounds, hasLength(1));
        expect(copy.restBetweenExercises, 15);
        expect(copy.restAfterRound, 120);
        expect(copy.name, 'My Superset');
      });
    });
  });
}

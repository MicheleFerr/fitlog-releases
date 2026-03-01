/// StressIndexState unit tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_recovery_status.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_state.dart';

void main() {
  MuscleRecoveryStatus _makeRecovery({
    String muscleId = 'PETT',
    RecoveryState state = RecoveryState.fullyRecovered,
    double recoveryPercentage = 100,
    double lastStressScore = 50,
  }) {
    return MuscleRecoveryStatus(
      muscleId: muscleId,
      displayName: muscleId,
      state: state,
      recoveryPercentage: recoveryPercentage,
      lastWorked: DateTime.now().subtract(const Duration(hours: 48)),
      lastStressScore: lastStressScore,
    );
  }

  StressIndexResult _makeResult({double primaryScore = 50}) {
    return StressIndexResult(
      primaryScore: primaryScore,
      fallbackScore: 40,
      confidence: 0.8,
      totalSets: 10,
      setsWithRpe: 8,
      workoutId: 'w-1',
      muscleBreakdown: {},
      calculatedAt: DateTime(2024, 6, 15),
      rawScore: 5000,
    );
  }

  group('StressIndexState.empty', () {
    test('creates empty state', () {
      final state = StressIndexState.empty();
      expect(state.latestResult, isNull);
      expect(state.muscleRecovery, isEmpty);
      expect(state.history, isEmpty);
    });
  });

  group('StressIndexState - hasData', () {
    test('empty state has no data', () {
      expect(StressIndexState.empty().hasData, false);
    });

    test('state with latest result has data', () {
      final state = StressIndexState(
        latestResult: _makeResult(),
        muscleRecovery: {},
        history: [],
      );
      expect(state.hasData, true);
    });

    test('state with history has data', () {
      final state = StressIndexState(
        latestResult: null,
        muscleRecovery: {},
        history: [_makeResult()],
      );
      expect(state.hasData, true);
    });
  });

  group('StressIndexState - fullyRecoveredMuscles', () {
    test('returns empty for empty state', () {
      expect(StressIndexState.empty().fullyRecoveredMuscles, isEmpty);
    });

    test('returns only fully recovered muscles', () {
      final state = StressIndexState(
        latestResult: null,
        muscleRecovery: {
          'PETT': _makeRecovery(state: RecoveryState.fullyRecovered),
          'LAT': _makeRecovery(
              muscleId: 'LAT', state: RecoveryState.recovering),
          'QUAD': _makeRecovery(
              muscleId: 'QUAD', state: RecoveryState.fullyRecovered),
        },
        history: [],
      );
      expect(state.fullyRecoveredMuscles.length, 2);
    });
  });

  group('StressIndexState - fatiguedMuscles', () {
    test('returns fatigued and exhausted muscles', () {
      final state = StressIndexState(
        latestResult: null,
        muscleRecovery: {
          'PETT': _makeRecovery(state: RecoveryState.fatigued),
          'LAT': _makeRecovery(
              muscleId: 'LAT', state: RecoveryState.exhausted),
          'QUAD': _makeRecovery(
              muscleId: 'QUAD', state: RecoveryState.recovering),
        },
        history: [],
      );
      expect(state.fatiguedMuscles.length, 2);
    });
  });

  group('StressIndexState - almostReadyMuscles', () {
    test('returns almostReady muscles only', () {
      final state = StressIndexState(
        latestResult: null,
        muscleRecovery: {
          'PETT': _makeRecovery(state: RecoveryState.almostReady),
          'LAT': _makeRecovery(
              muscleId: 'LAT', state: RecoveryState.fullyRecovered),
        },
        history: [],
      );
      expect(state.almostReadyMuscles.length, 1);
    });
  });

  group('StressIndexState - averageRecoveryPercentage', () {
    test('returns 100 for empty state', () {
      expect(StressIndexState.empty().averageRecoveryPercentage, 100.0);
    });

    test('returns average of recovery percentages', () {
      final state = StressIndexState(
        latestResult: null,
        muscleRecovery: {
          'PETT': _makeRecovery(recoveryPercentage: 80),
          'LAT': _makeRecovery(muscleId: 'LAT', recoveryPercentage: 60),
        },
        history: [],
      );
      expect(state.averageRecoveryPercentage, 70.0);
    });

    test('single muscle returns its percentage', () {
      final state = StressIndexState(
        latestResult: null,
        muscleRecovery: {
          'PETT': _makeRecovery(recoveryPercentage: 55),
        },
        history: [],
      );
      expect(state.averageRecoveryPercentage, 55.0);
    });
  });
}

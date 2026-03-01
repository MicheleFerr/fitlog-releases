/// MuscleReadinessData unit tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_readiness_data.dart';

void main() {
  MuscleReadinessData _make({double recoveryPercent = 95}) {
    return MuscleReadinessData(
      muscleId: 'PETT',
      displayName: 'Chest',
      recoveryPercent: recoveryPercent,
      hoursSinceWorkout: 48,
    );
  }

  group('MuscleReadinessData - state', () {
    test('100% => fullyReady', () {
      expect(_make(recoveryPercent: 100).state,
          MuscleReadinessState.fullyReady);
    });

    test('150% => fullyReady (supercompensation)', () {
      expect(_make(recoveryPercent: 150).state,
          MuscleReadinessState.fullyReady);
    });

    test('95% => ready', () {
      expect(_make(recoveryPercent: 95).state, MuscleReadinessState.ready);
    });

    test('90% => ready', () {
      expect(_make(recoveryPercent: 90).state, MuscleReadinessState.ready);
    });

    test('80% => acceptable', () {
      expect(
          _make(recoveryPercent: 80).state, MuscleReadinessState.acceptable);
    });

    test('70% => acceptable', () {
      expect(
          _make(recoveryPercent: 70).state, MuscleReadinessState.acceptable);
    });

    test('60% => underRecovered', () {
      expect(_make(recoveryPercent: 60).state,
          MuscleReadinessState.underRecovered);
    });

    test('50% => underRecovered', () {
      expect(_make(recoveryPercent: 50).state,
          MuscleReadinessState.underRecovered);
    });

    test('40% => fatigued', () {
      expect(_make(recoveryPercent: 40).state, MuscleReadinessState.fatigued);
    });

    test('0% => fatigued', () {
      expect(_make(recoveryPercent: 0).state, MuscleReadinessState.fatigued);
    });
  });

  group('MuscleReadinessData - isReady', () {
    test('fullyReady is ready', () {
      expect(_make(recoveryPercent: 100).isReady, true);
    });

    test('ready is ready', () {
      expect(_make(recoveryPercent: 92).isReady, true);
    });

    test('acceptable is not ready', () {
      expect(_make(recoveryPercent: 80).isReady, false);
    });
  });

  group('MuscleReadinessData - isSuboptimal', () {
    test('acceptable is suboptimal', () {
      expect(_make(recoveryPercent: 75).isSuboptimal, true);
    });

    test('underRecovered is suboptimal', () {
      expect(_make(recoveryPercent: 55).isSuboptimal, true);
    });

    test('fatigued is not suboptimal', () {
      expect(_make(recoveryPercent: 30).isSuboptimal, false);
    });

    test('ready is not suboptimal', () {
      expect(_make(recoveryPercent: 95).isSuboptimal, false);
    });
  });

  group('MuscleReadinessData - shouldAvoid', () {
    test('fatigued should be avoided', () {
      expect(_make(recoveryPercent: 30).shouldAvoid, true);
    });

    test('underRecovered should not be avoided', () {
      expect(_make(recoveryPercent: 55).shouldAvoid, false);
    });
  });

  group('MuscleReadinessData - totalModifier', () {
    test('sums all modifiers', () {
      final data = MuscleReadinessData(
        muscleId: 'PETT',
        displayName: 'Chest',
        recoveryPercent: 80,
        hoursSinceWorkout: 48,
        sleepModifier: -10,
        hrvModifier: 5,
        ageModifier: -3,
      );
      expect(data.totalModifier, -8);
    });

    test('default modifiers sum to 0', () {
      expect(_make().totalModifier, 0);
    });
  });

  group('MuscleReadinessData - hasSignificantModifiers', () {
    test('abs > 10 is significant', () {
      final data = MuscleReadinessData(
        muscleId: 'PETT',
        displayName: 'Chest',
        recoveryPercent: 80,
        hoursSinceWorkout: 48,
        sleepModifier: -15,
      );
      expect(data.hasSignificantModifiers, true);
    });

    test('abs <= 10 is not significant', () {
      final data = MuscleReadinessData(
        muscleId: 'PETT',
        displayName: 'Chest',
        recoveryPercent: 80,
        hoursSinceWorkout: 48,
        sleepModifier: -5,
        hrvModifier: 3,
      );
      expect(data.hasSignificantModifiers, false);
    });
  });

  group('MuscleReadinessState', () {
    test('has 5 values', () {
      expect(MuscleReadinessState.values.length, 5);
    });
  });
}

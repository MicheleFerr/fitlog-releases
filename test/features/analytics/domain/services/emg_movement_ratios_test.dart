/// EmgMovementRatios tests - ratio configs, distribution, pattern inference.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/emg_movement_ratios.dart';

void main() {
  group('MovementPattern', () {
    test('has 9 values', () {
      expect(MovementPattern.values.length, 9);
    });
  });

  group('EmgRatioConfig', () {
    test('total sums all ratios', () {
      const config = EmgRatioConfig(
        primaryRatio: 0.60,
        highSynergistRatio: 0.25,
        moderateSynergistRatio: 0.15,
        lowSynergistRatio: 0.0,
      );
      expect(config.total, closeTo(1.0, 0.001));
      expect(config.isValid, isTrue);
    });

    test('isValid false when total != 1.0', () {
      const config = EmgRatioConfig(
        primaryRatio: 0.50,
        highSynergistRatio: 0.20,
        moderateSynergistRatio: 0.10,
        lowSynergistRatio: 0.0,
      );
      expect(config.isValid, isFalse);
    });
  });

  group('EmgMovementRatios.getRatios', () {
    test('all patterns have valid ratios summing to 1.0', () {
      for (final pattern in MovementPattern.values) {
        final config = EmgMovementRatios.getRatios(pattern);
        expect(
          config.isValid,
          isTrue,
          reason: '$pattern ratios should sum to 1.0, got ${config.total}',
        );
      }
    });

    test('pushHorizontal: chest dominant', () {
      final config = EmgMovementRatios.getRatios(MovementPattern.pushHorizontal);
      expect(config.primaryRatio, 0.60);
      expect(config.highSynergistRatio, 0.25);
      expect(config.moderateSynergistRatio, 0.15);
    });

    test('isolation: target muscle dominant (85%)', () {
      final config = EmgMovementRatios.getRatios(MovementPattern.isolation);
      expect(config.primaryRatio, 0.85);
      expect(config.highSynergistRatio, 0.15);
    });

    test('other: 100% primary', () {
      final config = EmgMovementRatios.getRatios(MovementPattern.other);
      expect(config.primaryRatio, 1.0);
      expect(config.highSynergistRatio, 0.0);
    });
  });

  group('EmgMovementRatios.getSimpleRatios', () {
    test('pushHorizontal returns 60/40 split', () {
      final (primary, secondary) =
          EmgMovementRatios.getSimpleRatios(MovementPattern.pushHorizontal);
      expect(primary, 0.60);
      expect(secondary, closeTo(0.40, 0.001));
    });

    test('other returns 100/0 split', () {
      final (primary, secondary) =
          EmgMovementRatios.getSimpleRatios(MovementPattern.other);
      expect(primary, 1.0);
      expect(secondary, 0.0);
    });
  });

  group('EmgMovementRatios.getTieredRatios', () {
    test('returns three values summing to 1.0', () {
      for (final pattern in MovementPattern.values) {
        final (p, h, m) = EmgMovementRatios.getTieredRatios(pattern);
        expect(
          p + h + m,
          closeTo(1.0, 0.001),
          reason: '$pattern tiered ratios should sum to 1.0',
        );
      }
    });
  });

  group('EmgMovementRatios.distributeWithTiers', () {
    test('distributes volume correctly for pushHorizontal', () {
      final result = EmgMovementRatios.distributeWithTiers(
        primary: ['PETT'],
        secondary: ['DELT_ANT', 'TRIC'],
        totalVolume: 1000,
        pattern: MovementPattern.pushHorizontal,
      );
      expect(result['pett'], 600.0); // 60%
      expect(result['delt_ant'], 250.0); // 25% high synergist
      expect(result['tric'], 150.0); // 15% moderate synergist
    });

    test('splits primary evenly among multiple muscles', () {
      final result = EmgMovementRatios.distributeWithTiers(
        primary: ['GLUT', 'FEMOR'],
        secondary: ['LOMBAR'],
        totalVolume: 1000,
        pattern: MovementPattern.hinge,
      );
      // Primary: 55% / 2 muscles = 275 each
      expect(result['glut'], closeTo(275.0, 0.1));
      expect(result['femor'], closeTo(275.0, 0.1));
    });

    test('handles empty primary list', () {
      final result = EmgMovementRatios.distributeWithTiers(
        primary: [],
        secondary: ['BICI'],
        totalVolume: 1000,
        pattern: MovementPattern.pullVertical,
      );
      expect(result.containsKey('bici'), isTrue);
    });

    test('handles single secondary', () {
      final result = EmgMovementRatios.distributeWithTiers(
        primary: ['QUAD'],
        secondary: ['GLUT'],
        totalVolume: 1000,
        pattern: MovementPattern.squat,
      );
      expect(result['quad'], 500.0); // 50%
      expect(result['glut'], 350.0); // 35% high synergist
    });
  });

  group('EmgMovementRatios.inferPattern', () {
    test('core exercises detected', () {
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: 'core',
          exerciseName: 'Crunch',
        ),
        MovementPattern.core,
      );
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: 'other',
          exerciseName: 'Plank',
        ),
        MovementPattern.core,
      );
    });

    test('lower body hinge patterns', () {
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: 'lower',
          exerciseName: 'Romanian Deadlift',
        ),
        MovementPattern.hinge,
      );
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: 'lower',
          exerciseName: 'Leg Curl',
        ),
        MovementPattern.hinge,
      );
    });

    test('lower body squat patterns', () {
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: 'lower',
          exerciseName: 'Back Squat',
        ),
        MovementPattern.squat,
      );
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: 'lower',
          exerciseName: 'Leg Press',
        ),
        MovementPattern.squat,
      );
    });

    test('lower body defaults to squat', () {
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: 'lower',
          exerciseName: 'Unknown Lower Exercise',
        ),
        MovementPattern.squat,
      );
    });

    test('upper push vertical', () {
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: 'upper_push',
          exerciseName: 'Overhead Press',
        ),
        MovementPattern.pushVertical,
      );
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: 'push',
          exerciseName: 'Military Press',
        ),
        MovementPattern.pushVertical,
      );
    });

    test('upper push isolation', () {
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: 'upper_push',
          exerciseName: 'Tricep Pushdown',
        ),
        MovementPattern.isolation,
      );
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: 'push',
          exerciseName: 'Lateral Raise',
        ),
        MovementPattern.isolation,
      );
    });

    test('upper push defaults to horizontal', () {
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: 'upper_push',
          exerciseName: 'Bench Press',
        ),
        MovementPattern.pushHorizontal,
      );
    });

    test('upper pull vertical', () {
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: 'upper_pull',
          exerciseName: 'Lat Pulldown',
        ),
        MovementPattern.pullVertical,
      );
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: 'pull',
          exerciseName: 'Pull-up',
        ),
        MovementPattern.pullVertical,
      );
    });

    test('upper pull isolation', () {
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: 'pull',
          exerciseName: 'Bicep Curl',
        ),
        MovementPattern.isolation,
      );
    });

    test('upper pull defaults to horizontal', () {
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: 'upper_pull',
          exerciseName: 'Barbell Row',
        ),
        MovementPattern.pullHorizontal,
      );
    });

    test('fallback to focusMuscle inference', () {
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: '',
          exerciseName: 'Unknown',
          focusMuscle: 'chest',
        ),
        MovementPattern.pushHorizontal,
      );
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: '',
          exerciseName: 'Unknown',
          focusMuscle: 'quad',
        ),
        MovementPattern.squat,
      );
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: '',
          exerciseName: 'Unknown',
          focusMuscle: 'glut',
        ),
        MovementPattern.hinge,
      );
    });

    test('ultimate fallback is other', () {
      expect(
        EmgMovementRatios.inferPattern(
          fileCategory: '',
          exerciseName: 'Unknown Exercise',
        ),
        MovementPattern.other,
      );
    });
  });

  group('EmgMovementRatios.fromPatternMovimento', () {
    test('push pattern horizontal', () {
      expect(
        EmgMovementRatios.fromPatternMovimento('Push Pattern',
            exerciseName: 'Bench Press'),
        MovementPattern.pushHorizontal,
      );
    });

    test('push pattern vertical', () {
      expect(
        EmgMovementRatios.fromPatternMovimento('Push Pattern',
            exerciseName: 'Overhead Press'),
        MovementPattern.pushVertical,
      );
    });

    test('pull pattern horizontal', () {
      expect(
        EmgMovementRatios.fromPatternMovimento('Pull Pattern',
            exerciseName: 'Barbell Row'),
        MovementPattern.pullHorizontal,
      );
    });

    test('pull pattern vertical', () {
      expect(
        EmgMovementRatios.fromPatternMovimento('Pull Pattern',
            exerciseName: 'Lat Pulldown'),
        MovementPattern.pullVertical,
      );
    });

    test('squat pattern', () {
      expect(
        EmgMovementRatios.fromPatternMovimento('Squat Pattern'),
        MovementPattern.squat,
      );
    });

    test('lunge pattern maps to squat', () {
      expect(
        EmgMovementRatios.fromPatternMovimento('Lunge Pattern'),
        MovementPattern.squat,
      );
    });

    test('hinge pattern', () {
      expect(
        EmgMovementRatios.fromPatternMovimento('Hinge Pattern'),
        MovementPattern.hinge,
      );
    });

    test('isolation', () {
      expect(
        EmgMovementRatios.fromPatternMovimento('Isolation'),
        MovementPattern.isolation,
      );
    });

    test('core/stability', () {
      expect(
        EmgMovementRatios.fromPatternMovimento('Anti-Rotation / Core Stability'),
        MovementPattern.core,
      );
    });

    test('functional uses name inference', () {
      expect(
        EmgMovementRatios.fromPatternMovimento('Functional Movement',
            exerciseName: 'Deadlift'),
        MovementPattern.other, // Falls through to inferPattern with empty fileCategory
      );
    });

    test('flexibility/plyometric maps to other', () {
      expect(
        EmgMovementRatios.fromPatternMovimento('Flexibility'),
        MovementPattern.other,
      );
      expect(
        EmgMovementRatios.fromPatternMovimento('Plyometric'),
        MovementPattern.other,
      );
    });

    test('empty string maps to other', () {
      expect(
        EmgMovementRatios.fromPatternMovimento(''),
        MovementPattern.other,
      );
    });

    test('unknown pattern maps to other', () {
      expect(
        EmgMovementRatios.fromPatternMovimento('SomethingRandom'),
        MovementPattern.other,
      );
    });
  });
}

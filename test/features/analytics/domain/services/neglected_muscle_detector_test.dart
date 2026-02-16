import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/muscle_balance_calculator.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';

void main() {
  late NeglectedMuscleDetector detector;

  setUp(() {
    detector = NeglectedMuscleDetector();
  });

  /// Helper: create MuscleBalanceMetrics with custom volume percentages
  MuscleBalanceMetrics createMetrics(Map<String, double> volumes) {
    return MuscleBalanceMetrics(
      pushPullRatio: 1.0,
      upperLowerRatio: 1.0,
      pushPullWarning: false,
      upperLowerWarning: false,
      neglectedMuscles: const [],
      topMuscles: const [],
      balanceScore: 5.0,
      muscleVolumePercentages: volumes,
    );
  }

  group('Threshold-based detection', () {
    test('back at 7% should be neglected (threshold 8%)', () {
      final balance = createMetrics({'back': 7.0});
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 1);
      expect(result.first.muscleName, 'back');
    });

    test('back at 9% should NOT be neglected (threshold 8%)', () {
      final balance = createMetrics({'back': 9.0});
      final result = detector.detectNeglectedMuscles(balance);

      expect(result, isEmpty);
    });

    test('biceps at 4% should NOT be neglected (threshold 3%)', () {
      final balance = createMetrics({'biceps': 4.0});
      final result = detector.detectNeglectedMuscles(balance);

      expect(result, isEmpty);
    });

    test('biceps at 2% should be neglected (threshold 3%)', () {
      final balance = createMetrics({'biceps': 2.0});
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 1);
      expect(result.first.muscleName, 'biceps');
    });

    test('chest at 5% should be neglected (threshold 6%)', () {
      final balance = createMetrics({'chest': 5.0});
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 1);
      expect(result.first.muscleName, 'chest');
    });

    test('calves at 2% should be neglected (threshold 2.5%)', () {
      final balance = createMetrics({'calves': 2.0});
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 1);
    });

    test('calves at 3% should NOT be neglected (threshold 2.5%)', () {
      final balance = createMetrics({'calves': 3.0});
      final result = detector.detectNeglectedMuscles(balance);

      expect(result, isEmpty);
    });

    test('unknown muscle uses default threshold (5%)', () {
      final balance = createMetrics({'traps': 4.0});
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 1);
      expect(result.first.muscleName, 'traps');
    });

    test('unknown muscle at 6% should NOT be neglected', () {
      final balance = createMetrics({'traps': 6.0});
      final result = detector.detectNeglectedMuscles(balance);

      expect(result, isEmpty);
    });

    test('detects multiple neglected muscles simultaneously', () {
      final balance = createMetrics({
        'back': 3.0, // threshold 8%
        'chest': 2.0, // threshold 6%
        'biceps': 1.0, // threshold 3%
        'quads': 10.0, // threshold 8% - OK
      });
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 3);
      final names = result.map((m) => m.muscleName).toSet();
      expect(names, containsAll(['back', 'chest', 'biceps']));
      expect(names, isNot(contains('quads')));
    });
  });

  group('Severity calculation (relative thresholds)', () {
    test('ratio < 0.4 = critical', () {
      // back threshold 8%, at 2% => ratio = 0.25 < 0.4
      final balance = createMetrics({'back': 2.0});
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.first.severity, NeglectSeverity.critical);
    });

    test('ratio 0.4-0.7 = high', () {
      // back threshold 8%, at 4% => ratio = 0.5
      final balance = createMetrics({'back': 4.0});
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.first.severity, NeglectSeverity.high);
    });

    test('ratio 0.7-1.0 = medium', () {
      // back threshold 8%, at 6% => ratio = 0.75
      final balance = createMetrics({'back': 6.0});
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.first.severity, NeglectSeverity.medium);
    });

    test('small muscle severity uses its own threshold', () {
      // forearms threshold 2%, at 0.5% => ratio = 0.25 < 0.4 = critical
      final balance = createMetrics({'forearms': 0.5});
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.first.severity, NeglectSeverity.critical);
    });

    test('medium muscle severity example', () {
      // hamstrings threshold 5%, at 3.8% => ratio = 0.76 = medium
      final balance = createMetrics({'hamstrings': 3.8});
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.first.severity, NeglectSeverity.medium);
    });
  });

  group('Antagonist pairs', () {
    test('classic pairs: chest/back, quads/hamstrings, biceps/triceps', () {
      // Verify antagonist boost to priority
      // back at 3% (neglected), chest at 15% (high antagonist)
      final balance = createMetrics({
        'back': 3.0,
        'chest': 15.0,
      });
      final result = detector.detectNeglectedMuscles(balance);

      // back should get antagonist imbalance bonus (chest/back = 5.0 > 3.0)
      expect(result.length, 1);
      expect(result.first.muscleName, 'back');
      // Priority should be higher than base severity alone
      expect(result.first.priority, greaterThan(4.0));
    });

    test('new pair: rear_delts/shoulders', () {
      // rear_delts at 1% (threshold 2%), shoulders at 10%
      final balance = createMetrics({
        'rear_delts': 1.0,
        'shoulders': 10.0,
      });
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 1);
      expect(result.first.muscleName, 'rear_delts');
      // shoulders/rear_delts = 10.0 > 3.0 → antagonist score + posture risk
      expect(result.first.priority, greaterThan(5.0));
    });

    test('abs/lower_back antagonist pair', () {
      final balance = createMetrics({
        'lower_back': 0.5,
        'abs': 5.0,
      });
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 1);
      expect(result.first.muscleName, 'lower_back');
      // abs/lower_back = 10.0 > 3.0 → antagonist score
      expect(result.first.priority, greaterThan(4.0));
    });

    test('no antagonist boost when antagonist is also low', () {
      final balance = createMetrics({
        'chest': 2.0,
        'back': 2.0, // both low, ratio ~1
      });
      final result = detector.detectNeglectedMuscles(balance);

      // Both are neglected, but antagonist ratio is ~1 (no boost)
      for (final muscle in result) {
        // Priority should be lower (no imbalance bonus)
        expect(muscle.priority, lessThanOrEqualTo(7.0));
      }
    });
  });

  group('Posture risk', () {
    test('back neglected + high chest/back ratio = rounded shoulders risk', () {
      final balance = createMetrics({
        'back': 3.0,
        'chest': 12.0, // chest/back = 4.0 > 2.0
      });
      final result = detector.detectNeglectedMuscles(balance);
      final back = result.first;

      // Should have posture risk score (3.0 for ratio > 2.0)
      expect(back.priority, greaterThanOrEqualTo(7.0));
    });

    test('hamstrings neglected + high quads/ham ratio = knee risk', () {
      final balance = createMetrics({
        'hamstrings': 2.0,
        'quads': 15.0, // quads/ham = 7.5 > 2.5
      });
      final result = detector.detectNeglectedMuscles(balance);
      final ham = result.firstWhere((m) => m.muscleName == 'hamstrings');

      expect(ham.priority, greaterThanOrEqualTo(7.0));
    });

    test('rear delts neglected + high shoulders/rear_delts = impingement risk', () {
      final balance = createMetrics({
        'rear_delts': 0.5,
        'shoulders': 8.0, // shoulders/rear_delts = 16 > 3.0
      });
      final result = detector.detectNeglectedMuscles(balance);
      final rearDelts = result.firstWhere((m) => m.muscleName == 'rear_delts');

      // Should get posture risk of 2.5
      expect(rearDelts.priority, greaterThan(6.0));
    });

    test('lower back neglected + high abs/lower_back ratio', () {
      final balance = createMetrics({
        'lower_back': 1.0,
        'abs': 5.0, // abs/lb = 5.0 > 2.5
      });
      final result = detector.detectNeglectedMuscles(balance);
      final lb = result.firstWhere((m) => m.muscleName == 'lower_back');

      expect(lb.priority, greaterThan(5.0));
    });

    test('no posture risk when ratios are balanced', () {
      final balance = createMetrics({
        'back': 7.0, // just below 8% threshold
        'chest': 7.0, // chest/back = 1.0
      });
      final result = detector.detectNeglectedMuscles(balance);

      // back is neglected but no posture risk (ratio = 1.0 < 1.5)
      expect(result.length, 1);
      expect(result.first.muscleName, 'back');
      // Priority = severity(medium=2) + antagonist(0 or 1) + posture(0)
      expect(result.first.priority, lessThanOrEqualTo(4.0));
    });
  });

  group('Priority sorting', () {
    test('results sorted by priority (highest first)', () {
      final balance = createMetrics({
        'back': 1.0, // critical, high chest/back imbalance + posture risk
        'chest': 15.0,
        'calves': 2.0, // just below threshold, medium severity
        'forearms': 1.5, // medium severity (ratio 0.75)
      });
      final result = detector.detectNeglectedMuscles(balance);

      // Verify sorted descending
      for (var i = 0; i < result.length - 1; i++) {
        expect(
          result[i].priority,
          greaterThanOrEqualTo(result[i + 1].priority),
          reason: '${result[i].muscleName} should have >= priority than ${result[i + 1].muscleName}',
        );
      }

      // Back should be first (highest priority: critical + imbalance + posture)
      expect(result.first.muscleName, 'back');
    });
  });

  group('Priority score clamping', () {
    test('priority should never exceed 10.0', () {
      // Extreme scenario: all bonus factors maxed
      final balance = createMetrics({
        'back': 0.1, // critical (4pts) + antagonist >3 (3pts) + posture >2 (3pts)
        'chest': 20.0,
      });
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.first.priority, lessThanOrEqualTo(10.0));
    });

    test('priority should never be negative', () {
      final balance = createMetrics({'biceps': 2.5});
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.first.priority, greaterThanOrEqualTo(0.0));
    });
  });

  group('Static threshold map', () {
    test('all expected muscles are in the threshold map', () {
      const expectedMuscles = [
        'back', 'quads', 'chest', 'hamstrings', 'glutes', 'shoulders',
        'biceps', 'triceps', 'calves', 'forearms', 'abs', 'lower_back',
        'rear_delts',
      ];

      for (final muscle in expectedMuscles) {
        expect(
          NeglectedMuscleDetector.neglectThresholds.containsKey(muscle),
          isTrue,
          reason: '$muscle should have a defined threshold',
        );
      }
    });

    test('large muscles have higher thresholds than small muscles', () {
      final backThreshold = NeglectedMuscleDetector.neglectThresholds['back']!;
      final bicepsThreshold = NeglectedMuscleDetector.neglectThresholds['biceps']!;
      final forearmThreshold = NeglectedMuscleDetector.neglectThresholds['forearms']!;

      expect(backThreshold, greaterThan(bicepsThreshold));
      expect(bicepsThreshold, greaterThan(forearmThreshold));
    });
  });

  group('Key normalization (abbreviated to detector keys)', () {
    test('glut → glutes normalization', () {
      final balance = createMetrics({'glut': 3.0}); // threshold 5%
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 1);
      expect(result.first.muscleName, 'glutes'); // normalized key
      expect(result.first.volumePercentage, 3.0);
    });

    test('femo → hamstrings normalization', () {
      final balance = createMetrics({'femo': 3.0}); // threshold 5%
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 1);
      expect(result.first.muscleName, 'hamstrings');
      expect(result.first.volumePercentage, 3.0);
    });

    test('quad → quads normalization', () {
      final balance = createMetrics({'quad': 5.0}); // threshold 8%
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 1);
      expect(result.first.muscleName, 'quads');
      expect(result.first.volumePercentage, 5.0);
    });

    test('delt_post → rear_delts normalization', () {
      final balance = createMetrics({'delt_post': 1.0}); // threshold 2%
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 1);
      expect(result.first.muscleName, 'rear_delts');
      expect(result.first.volumePercentage, 1.0);
    });

    test('pett → chest normalization', () {
      final balance = createMetrics({'pett': 4.0}); // threshold 6%
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 1);
      expect(result.first.muscleName, 'chest');
      expect(result.first.volumePercentage, 4.0);
    });

    test('aggregates lat + trap → back', () {
      final balance = createMetrics({
        'lat': 3.0,
        'trap': 2.0, // total = 5.0, threshold 8%
      });
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 1);
      expect(result.first.muscleName, 'back');
      expect(result.first.volumePercentage, 5.0); // aggregated
    });

    test('aggregates delt + delt_ant + delt_lat → shoulders', () {
      final balance = createMetrics({
        'delt': 1.0,
        'delt_ant': 1.5,
        'delt_lat': 1.0, // total = 3.5, threshold 5%
      });
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 1);
      expect(result.first.muscleName, 'shoulders');
      expect(result.first.volumePercentage, 3.5);
    });

    test('aggregates core + obl → abs', () {
      final balance = createMetrics({
        'core': 1.0,
        'obl': 1.0, // total = 2.0, threshold 3%
      });
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 1);
      expect(result.first.muscleName, 'abs');
      expect(result.first.volumePercentage, 2.0);
    });

    test('aggregates add + abdu → glutes', () {
      final balance = createMetrics({
        'add': 1.5,
        'abdu': 1.5, // total = 3.0, threshold 5%
      });
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 1);
      expect(result.first.muscleName, 'glutes');
      expect(result.first.volumePercentage, 3.0);
    });

    test('mixed abbreviated and normalized keys', () {
      final balance = createMetrics({
        'glut': 2.0, // → glutes (threshold 5%) - neglected
        'femo': 2.0, // → hamstrings (threshold 5%) - neglected
        'chest': 10.0, // already normalized - OK
        'lat': 9.0, // → back (threshold 8%) - OK
      });
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 2);
      final names = result.map((m) => m.muscleName).toSet();
      expect(names, containsAll(['glutes', 'hamstrings']));
      expect(names, isNot(contains('back'))); // lat at 9% > 8% threshold
    });

    test('posture risk works with normalized keys', () {
      final balance = createMetrics({
        'femo': 2.0, // → hamstrings (neglected)
        'quad': 15.0, // → quads (high)
      });
      final result = detector.detectNeglectedMuscles(balance);

      final ham = result.firstWhere((m) => m.muscleName == 'hamstrings');
      // Should detect posture risk (quads/hamstrings = 7.5 > 2.5)
      expect(ham.priority, greaterThanOrEqualTo(7.0));
    });

    test('antagonist pairs work with normalized keys', () {
      final balance = createMetrics({
        'pett': 15.0, // → chest
        'lat': 3.0, // → back (neglected)
      });
      final result = detector.detectNeglectedMuscles(balance);

      final back = result.firstWhere((m) => m.muscleName == 'back');
      // Should detect antagonist imbalance (chest/back = 5.0 > 3.0)
      expect(back.priority, greaterThan(4.0));
    });
  });

  group('Edge cases', () {
    test('empty volume percentages returns empty list', () {
      final balance = createMetrics({});
      final result = detector.detectNeglectedMuscles(balance);

      expect(result, isEmpty);
    });

    test('all muscles above threshold returns empty list', () {
      final balance = createMetrics({
        'back': 15.0,
        'chest': 12.0,
        'quads': 10.0,
        'biceps': 5.0,
      });
      final result = detector.detectNeglectedMuscles(balance);

      expect(result, isEmpty);
    });

    test('muscle at exactly threshold is NOT neglected', () {
      final balance = createMetrics({'back': 8.0}); // exactly at threshold
      final result = detector.detectNeglectedMuscles(balance);

      expect(result, isEmpty);
    });

    test('muscle at 0% volume is critical', () {
      final balance = createMetrics({'chest': 0.0});
      final result = detector.detectNeglectedMuscles(balance);

      expect(result.length, 1);
      expect(result.first.severity, NeglectSeverity.critical);
    });
  });
}

/// RepZoneSuggestionEngine tests - distribution analysis, variety, zone detection.
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/rep_zone_suggestion.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/rep_zone_suggestion_engine.dart';

void main() {
  late RepZoneSuggestionEngine engine;

  setUp(() {
    engine = RepZoneSuggestionEngine();
  });

  // Helper to create an ExerciseHistory with sessions containing sets of given reps
  ExerciseHistory _makeHistory({
    String id = 'ex1',
    String name = 'Bench Press',
    String muscle = 'chest',
    required List<List<int>> sessionReps,
  }) {
    final sessions = <ExerciseSession>[];
    for (int i = 0; i < sessionReps.length; i++) {
      final sets = sessionReps[i]
          .map(
            (reps) => AnalyticsSet(
              weight: 80,
              reps: reps,
              date: DateTime(2025, 1, 1 + i),
            ),
          )
          .toList();
      sessions.add(
        ExerciseSession(
          exerciseName: name,
          muscleGroup: muscle,
          sets: sets,
          date: DateTime(2025, 1, 1 + i),
        ),
      );
    }
    return ExerciseHistory(
      exerciseId: id,
      exerciseName: name,
      muscleGroup: muscle,
      sessions: sessions,
    );
  }

  group('RepZoneSuggestionEngine constants', () {
    test('dominantThreshold is 80', () {
      expect(RepZoneSuggestionEngine.dominantThreshold, 80.0);
    });

    test('veryDominantThreshold is 90', () {
      expect(RepZoneSuggestionEngine.veryDominantThreshold, 90.0);
    });

    test('minimumSetsForAnalysis is 10', () {
      expect(RepZoneSuggestionEngine.minimumSetsForAnalysis, 10);
    });

    test('maxSuggestions is 10', () {
      expect(RepZoneSuggestionEngine.maxSuggestions, 10);
    });

    test('maxAlternatives is 4', () {
      expect(RepZoneSuggestionEngine.maxAlternatives, 4);
    });
  });

  group('analyzeDistribution', () {
    test('empty histories returns zero analysis', () {
      final analysis = engine.analyzeDistribution([]);
      expect(analysis.totalSets, 0);
      expect(analysis.strengthPercentage, 0.0);
      expect(analysis.hypertrophyPercentage, 0.0);
      expect(analysis.endurancePercentage, 0.0);
    });

    test('all strength sets (1-5 reps)', () {
      final history = _makeHistory(sessionReps: [
        [3, 3, 3, 5, 5],
        [4, 4, 4, 5, 5],
      ]);
      final analysis = engine.analyzeDistribution([history]);
      expect(analysis.totalSets, 10);
      expect(analysis.strengthSets, 10);
      expect(analysis.hypertrophySets, 0);
      expect(analysis.enduranceSets, 0);
      expect(analysis.strengthPercentage, 100.0);
    });

    test('all hypertrophy sets (6-15 reps)', () {
      final history = _makeHistory(sessionReps: [
        [8, 10, 12],
        [6, 8, 10, 15],
      ]);
      final analysis = engine.analyzeDistribution([history]);
      expect(analysis.totalSets, 7);
      expect(analysis.hypertrophySets, 7);
      expect(analysis.strengthSets, 0);
      expect(analysis.enduranceSets, 0);
      expect(analysis.hypertrophyPercentage, 100.0);
    });

    test('all endurance sets (16+ reps)', () {
      final history = _makeHistory(sessionReps: [
        [20, 25, 30],
      ]);
      final analysis = engine.analyzeDistribution([history]);
      expect(analysis.totalSets, 3);
      expect(analysis.enduranceSets, 3);
      expect(analysis.endurancePercentage, 100.0);
    });

    test('mixed distribution', () {
      final history = _makeHistory(sessionReps: [
        [3, 3, 3, 10, 10, 10, 10, 20, 20, 20],
      ]);
      final analysis = engine.analyzeDistribution([history]);
      expect(analysis.totalSets, 10);
      expect(analysis.strengthSets, 3);
      expect(analysis.hypertrophySets, 4);
      expect(analysis.enduranceSets, 3);
      expect(analysis.strengthPercentage, 30.0);
      expect(analysis.hypertrophyPercentage, 40.0);
      expect(analysis.endurancePercentage, 30.0);
    });

    test('variety level excellent when no zone > 70%', () {
      final history = _makeHistory(sessionReps: [
        [3, 3, 3, 10, 10, 10, 10, 20, 20, 20],
      ]);
      final analysis = engine.analyzeDistribution([history]);
      expect(analysis.varietyLevel, VarietyLevel.excellent);
    });

    test('variety level good when max zone 70-80%', () {
      // 8 hypertrophy, 1 strength, 1 endurance = 80% hyp
      // Need exactly 70-80%: 7/10 = 70%, 8/10 = 80%
      // 75% = 75 out of 100: let's do 15/20
      final histories = [
        _makeHistory(sessionReps: [
          [10, 10, 10, 10, 10, 10, 10, 10, 10, 10], // 10 hyp
          [10, 10, 10, 10, 10, 3, 3, 20, 20, 20], // 5 hyp + 2 str + 3 end
        ]),
      ];
      final analysis = engine.analyzeDistribution(histories);
      // 15 hyp / 20 total = 75%
      expect(analysis.hypertrophyPercentage, 75.0);
      expect(analysis.varietyLevel, VarietyLevel.good);
    });

    test('variety level low when max zone 80-90%', () {
      // 85% in one zone: 17/20
      final histories = [
        _makeHistory(sessionReps: [
          [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
          [10, 10, 10, 10, 10, 10, 10, 3, 3, 3],
        ]),
      ];
      final analysis = engine.analyzeDistribution(histories);
      // 17 hyp / 20 = 85%
      expect(analysis.hypertrophyPercentage, 85.0);
      expect(analysis.varietyLevel, VarietyLevel.low);
    });

    test('variety level veryLow when max zone > 90%', () {
      // 19/20 = 95%
      final histories = [
        _makeHistory(sessionReps: [
          [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
          [10, 10, 10, 10, 10, 10, 10, 10, 10, 3],
        ]),
      ];
      final analysis = engine.analyzeDistribution(histories);
      // 19 hyp / 20 = 95%
      expect(analysis.hypertrophyPercentage, 95.0);
      expect(analysis.varietyLevel, VarietyLevel.veryLow);
    });

    test('dominant zone detected for strength', () {
      // > 80% strength
      final history = _makeHistory(sessionReps: [
        [3, 3, 3, 3, 3, 3, 3, 3, 3, 10], // 9/10 = 90% strength
      ]);
      final analysis = engine.analyzeDistribution([history]);
      expect(analysis.dominantZone, RepZone.strength);
    });

    test('dominant zone null when balanced', () {
      final history = _makeHistory(sessionReps: [
        [3, 3, 3, 10, 10, 10, 10, 20, 20, 20],
      ]);
      final analysis = engine.analyzeDistribution([history]);
      expect(analysis.dominantZone, isNull);
    });

    test('neglected zones detected for <10%', () {
      // 0% strength, 0% endurance
      final history = _makeHistory(sessionReps: [
        [10, 10, 10, 10, 10],
      ]);
      final analysis = engine.analyzeDistribution([history]);
      expect(analysis.neglectedZones, contains(RepZone.strength));
      expect(analysis.neglectedZones, contains(RepZone.endurance));
      expect(analysis.neglectedZones, isNot(contains(RepZone.hypertrophy)));
    });

    test('needsSuggestions true for low variety', () {
      final history = _makeHistory(sessionReps: [
        [10, 10, 10, 10, 10, 10, 10, 10, 10, 3], // 90% hyp
      ]);
      final analysis = engine.analyzeDistribution([history]);
      expect(analysis.needsSuggestions, isTrue);
    });

    test('needsSuggestions false for good variety', () {
      final history = _makeHistory(sessionReps: [
        [3, 3, 3, 10, 10, 10, 10, 20, 20, 20],
      ]);
      final analysis = engine.analyzeDistribution([history]);
      expect(analysis.needsSuggestions, isFalse);
    });

    test('multiple exercise histories combined', () {
      final h1 = _makeHistory(
        id: 'ex1',
        name: 'Bench Press',
        sessionReps: [
          [3, 3, 3, 3, 3],
        ],
      );
      final h2 = _makeHistory(
        id: 'ex2',
        name: 'Leg Curl',
        sessionReps: [
          [10, 10, 10, 10, 10],
        ],
      );
      final analysis = engine.analyzeDistribution([h1, h2]);
      expect(analysis.totalSets, 10);
      expect(analysis.strengthSets, 5);
      expect(analysis.hypertrophySets, 5);
      expect(analysis.strengthPercentage, 50.0);
      expect(analysis.hypertrophyPercentage, 50.0);
    });

    test('boundary: 5 reps is strength, 6 is hypertrophy', () {
      final history = _makeHistory(sessionReps: [
        [5, 6],
      ]);
      final analysis = engine.analyzeDistribution([history]);
      expect(analysis.strengthSets, 1);
      expect(analysis.hypertrophySets, 1);
    });

    test('boundary: 15 reps is hypertrophy, 16 is endurance', () {
      final history = _makeHistory(sessionReps: [
        [15, 16],
      ]);
      final analysis = engine.analyzeDistribution([history]);
      expect(analysis.hypertrophySets, 1);
      expect(analysis.enduranceSets, 1);
    });
  });

  group('RepZone properties', () {
    test('labels', () {
      expect(RepZone.strength.label, 'Forza');
      expect(RepZone.hypertrophy.label, 'Ipertrofia');
      expect(RepZone.endurance.label, 'Resistenza');
    });

    test('repRange', () {
      expect(RepZone.strength.repRange, '1-5 rep');
      expect(RepZone.hypertrophy.repRange, '6-15 rep');
      expect(RepZone.endurance.repRange, '15+ rep');
    });

    test('recommendedSets', () {
      expect(RepZone.strength.recommendedSets, 3);
      expect(RepZone.hypertrophy.recommendedSets, 4);
      expect(RepZone.endurance.recommendedSets, 3);
    });

    test('recommendedReps', () {
      expect(RepZone.strength.recommendedReps, 5);
      expect(RepZone.hypertrophy.recommendedReps, 10);
      expect(RepZone.endurance.recommendedReps, 15);
    });

    test('recommendedRestSeconds', () {
      expect(RepZone.strength.recommendedRestSeconds, 180);
      expect(RepZone.hypertrophy.recommendedRestSeconds, 90);
      expect(RepZone.endurance.recommendedRestSeconds, 60);
    });
  });

  group('VarietyLevel', () {
    test('needsSuggestions', () {
      expect(VarietyLevel.excellent.needsSuggestions, isFalse);
      expect(VarietyLevel.good.needsSuggestions, isFalse);
      expect(VarietyLevel.low.needsSuggestions, isTrue);
      expect(VarietyLevel.veryLow.needsSuggestions, isTrue);
    });
  });
}

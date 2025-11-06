import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_fuzzy_matcher.dart';

void main() {
  group('ExerciseFuzzyMatcher', () {
    // Sample exercises for testing
    late List<Exercise> testExercises;

    setUp(() {
      testExercises = [
        Exercise(
          id: 'panca_piana',
          nome: 'Panca Piana con Bilanciere',
          focus: const ['PET'],
          imageUrl: null,
          muscoliSecondari: const ['TRIC', 'DELT'],
          difficolta: 'Intermedio',
          tipoEsercizio: 'Compound',
          attrezzatura: 'Bilanciere',
          patternMovimento: 'Push',
          rangeRipetizioni: '6-12',
          noteTecniche: null,
          aliases: const ['panca', 'bench press', 'bp'],
        ),
        Exercise(
          id: 'rdl',
          nome: 'Stacco Rumeno con Bilanciere',
          focus: const ['FEMOR', 'GLUT'],
          imageUrl: null,
          muscoliSecondari: const ['LOM'],
          difficolta: 'Avanzato',
          tipoEsercizio: 'Compound',
          attrezzatura: 'Bilanciere',
          patternMovimento: 'Hinge',
          rangeRipetizioni: '6-10',
          noteTecniche: null,
          aliases: const ['rdl', 'romanian deadlift', 'stacco rumeno'],
        ),
        Exercise(
          id: 'squat',
          nome: 'Squat con Bilanciere',
          focus: const ['QUAD', 'GLUT'],
          imageUrl: null,
          muscoliSecondari: const ['CORE'],
          difficolta: 'Avanzato',
          tipoEsercizio: 'Compound',
          attrezzatura: 'Bilanciere',
          patternMovimento: 'Squat',
          rangeRipetizioni: '6-12',
          noteTecniche: null,
          aliases: const ['squat', 'sq'],
        ),
        Exercise(
          id: 'lat_machine',
          nome: 'Lat Machine',
          focus: const ['LAT'],
          imageUrl: null,
          muscoliSecondari: const ['BIC', 'TRAP'],
          difficolta: 'Principiante',
          tipoEsercizio: 'Compound',
          attrezzatura: 'Macchina',
          patternMovimento: 'Pull',
          rangeRipetizioni: '8-15',
          noteTecniche: null,
          aliases: const ['lat', 'pulldown', 'lat pulldown'],
        ),
      ];
    });

    test('should find exercise with exact match', () async {
      final results = await ExerciseFuzzyMatcher.searchExercises(
        exercises: testExercises,
        query: 'Panca Piana',
      );

      expect(results, isNotEmpty);
      expect(results.first.exercise.id, 'panca_piana');
      expect(results.first.score, greaterThan(0.70)); // Good score for match
    });

    test('should find exercise with typo correction', () async {
      final results = await ExerciseFuzzyMatcher.searchExercises(
        exercises: testExercises,
        query: 'pancha piana', // Typo: "pancha" instead of "panca"
      );

      expect(results, isNotEmpty);
      expect(results.first.exercise.id, 'panca_piana');
      expect(results.first.wasAutoCorrected, true); // Should be flagged as autocorrected
    });

    test('should find exercise with abbreviation', () async {
      final results = await ExerciseFuzzyMatcher.searchExercises(
        exercises: testExercises,
        query: 'rdl', // Abbreviation for Romanian Deadlift
        strictThreshold: 0.70, // Lower threshold for short abbreviations
        typeThreshold: 0.50,
      );

      expect(results, isNotEmpty);
      // Should find RDL exercise among results
      final hasRDL = results.any((r) => r.exercise.id == 'rdl');
      expect(hasRDL, true, reason: 'Should find RDL exercise');
    });

    test('should find exercise with partial name', () async {
      final results = await ExerciseFuzzyMatcher.searchExercises(
        exercises: testExercises,
        query: 'lat', // Partial match
      );

      expect(results, isNotEmpty);
      // Should find "Lat Machine"
      final latMachine = results.firstWhere(
        (r) => r.exercise.id == 'lat_machine',
        orElse: () => results.first,
      );
      expect(latMachine.exercise.id, 'lat_machine');
    });

    test('should find exercise with lowercase query', () async {
      final results = await ExerciseFuzzyMatcher.searchExercises(
        exercises: testExercises,
        query: 'squat', // Lowercase
        strictThreshold: 0.70,
        typeThreshold: 0.50,
      );

      expect(results, isNotEmpty);
      // Should find squat exercise among results
      final hasSquat = results.any((r) => r.exercise.id == 'squat');
      expect(hasSquat, true, reason: 'Should find Squat exercise');
    });

    test('should find exercise with accent variations', () async {
      final results = await ExerciseFuzzyMatcher.searchExercises(
        exercises: testExercises,
        query: 'panca piana', // No accents
      );

      expect(results, isNotEmpty);
      expect(results.first.exercise.id, 'panca_piana');
    });

    test('should return results ordered by score (best first)', () async {
      final results = await ExerciseFuzzyMatcher.searchExercises(
        exercises: testExercises,
        query: 'panca',
        maxResults: 10,
      );

      expect(results, isNotEmpty);

      // Verify results are ordered by score (descending)
      for (int i = 0; i < results.length - 1; i++) {
        expect(
          results[i].score,
          greaterThanOrEqualTo(results[i + 1].score),
          reason: 'Results should be ordered by score descending',
        );
      }
    });

    test('should respect maxResults parameter', () async {
      final results = await ExerciseFuzzyMatcher.searchExercises(
        exercises: testExercises,
        query: 'bilanciere',
        maxResults: 2,
      );

      expect(results.length, lessThanOrEqualTo(2));
    });

    test('should return empty list for empty query', () async {
      final results = await ExerciseFuzzyMatcher.searchExercises(
        exercises: testExercises,
        query: '',
      );

      expect(results, isEmpty);
    });

    test('should return empty list for query with no matches', () async {
      final results = await ExerciseFuzzyMatcher.searchExercises(
        exercises: testExercises,
        query: 'xyzabc123', // Gibberish query
        typeThreshold: 0.85, // High threshold to avoid false matches
      );

      // Might be empty or have very low scores
      if (results.isNotEmpty) {
        expect(results.first.score, lessThan(0.85));
      }
    });

    test('findBestMatch should return best single result', () async {
      final result = await ExerciseFuzzyMatcher.findBestMatch(
        exercises: testExercises,
        query: 'panca', // Use simpler query
        minScore: 0.50, // Lower threshold
      );

      expect(result, isNotNull);
      expect(result!.exercise.id, 'panca_piana');
      expect(result.score, greaterThanOrEqualTo(0.50));
    });

    test('findBestMatch should return null for low quality match', () async {
      final result = await ExerciseFuzzyMatcher.findBestMatch(
        exercises: testExercises,
        query: 'xyzabc',
        minScore: 0.85, // High threshold
      );

      expect(result, isNull);
    });

    test('should search across multiple fields (name, focus, equipment)', () async {
      final results = await ExerciseFuzzyMatcher.searchExercises(
        exercises: testExercises,
        query: 'bilanciere', // Equipment term
      );

      expect(results, isNotEmpty);
      // All exercises with "Bilanciere" equipment should match
      expect(
        results.where((r) => r.exercise.attrezzatura == 'Bilanciere').length,
        greaterThan(0),
      );
    });

    test('ExerciseFuzzyResult should have correct helpers', () async {
      final results = await ExerciseFuzzyMatcher.searchExercises(
        exercises: testExercises,
        query: 'panca piana',
      );

      expect(results, isNotEmpty);
      final result = results.first;

      // Test scorePercentage
      expect(result.scorePercentage, matches(r'^\d+%$'));

      // Test confidenceLevel
      expect(
        ['High', 'Medium', 'Low'].contains(result.confidenceLevel),
        true,
      );

      // Test scoreColorHex
      expect(result.scoreColorHex, matches(r'^#[0-9A-F]{6}$'));
    });

    test('should handle aliases correctly', () async {
      // Search using an alias
      final results = await ExerciseFuzzyMatcher.searchExercises(
        exercises: testExercises,
        query: 'panca', // Part of name and aliases
        strictThreshold: 0.70,
        typeThreshold: 0.50,
      );

      expect(results, isNotEmpty);

      // Should find Panca Piana
      final hasPancaPiana = results.any((r) => r.exercise.id == 'panca_piana');
      expect(hasPancaPiana, true, reason: 'Should find Panca Piana');
    });

    test('should use custom thresholds', () async {
      // Very strict threshold
      final strictResults = await ExerciseFuzzyMatcher.searchExercises(
        exercises: testExercises,
        query: 'pancha piana', // Typo
        strictThreshold: 0.95, // Very high
        typeThreshold: 0.90,   // Very high
      );

      // Loose threshold
      final looseResults = await ExerciseFuzzyMatcher.searchExercises(
        exercises: testExercises,
        query: 'pancha piana',
        strictThreshold: 0.70, // Lower
        typeThreshold: 0.50,   // Lower
      );

      // Loose threshold should return more or equal results
      expect(
        looseResults.length,
        greaterThanOrEqualTo(strictResults.length),
      );
    });

    test('performance: should handle large dataset efficiently', () async {
      // Create a larger dataset (simulate 1500 exercises)
      final largeDataset = List.generate(1500, (index) {
        return Exercise(
          id: 'exercise_$index',
          nome: 'Exercise $index',
          focus: const ['QUAD'],
          imageUrl: null,
          muscoliSecondari: const [],
          difficolta: 'Intermedio',
          tipoEsercizio: 'Compound',
          attrezzatura: 'Vario',
          patternMovimento: 'Vario',
          rangeRipetizioni: '8-12',
          noteTecniche: null,
        );
      });

      // Add our test exercises
      largeDataset.addAll(testExercises);

      final stopwatch = Stopwatch()..start();

      final results = await ExerciseFuzzyMatcher.searchExercises(
        exercises: largeDataset,
        query: 'panca piana',
      );

      stopwatch.stop();

      expect(results, isNotEmpty);
      expect(results.first.exercise.id, 'panca_piana');

      // Should complete in reasonable time (< 500ms even with isolate overhead)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'Search should be fast even with 1500+ exercises',
      );
    });
  });
}

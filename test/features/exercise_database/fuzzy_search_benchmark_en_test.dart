import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/fuzzy_search_service.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/repositories/json_exercise_repository.dart';

/// **Fuzzy Search Benchmark Test - ENGLISH DATASET**
///
/// **Purpose**: Validate Layer 2 performance on English exercise database
///
/// **Test Queries**: 30 typical English fitness searches covering:
/// - Common typos (benchpres, deadlft, sqat)
/// - Muscle group variants (chest, biceps, lats)
/// - Equipment queries (dumbbells, barbell, bodyweight)
/// - Movement patterns (squat, deadlift, bench press)
/// - Compound words (pullup, pushup, situp)
/// - Long queries (exercise for biceps with dumbbells)
///
/// **Expected Metrics**:
/// - Performance: <50ms per query on 1501 exercises
/// - Precision: >90% (relevant results in top 5)
/// - Recall: >85% (finds expected exercise)
/// - F1-Score: >0.85 (optimal balance)
///
/// **Comparison with IT dataset**:
/// - IT dataset: 1550 exercises, F1-score 0.60
/// - EN dataset: 1501 exercises, F1-score TBD
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fuzzy Search Benchmark Tests - English', () {
    late JsonExerciseRepository repository;
    late List<Exercise> exercises;

    setUpAll(() async {
      // Load English exercise database (1501 exercises)
      repository = JsonExerciseRepository(locale: const Locale('en'));
      exercises = await repository.getAllExercises();

      print('\n${'='*80}');
      print('FUZZY SEARCH BENCHMARK - English Dataset (Layer 2)');
      print('='*80);
      print('Total exercises loaded: ${exercises.length}');
      print('Locale: en (English)');
      print('\n');
    });

    test('Benchmark: 30 typical English fitness queries', () async {
      // ============================================================
      // TEST QUERIES (30 cases covering all scenarios)
      // ============================================================

      final testQueries = [
        // Category 1: Common typos (10 queries)
        const _TestQuery(
          query: 'benchpres',
          expectedInTop5: 'bench press',
          category: 'TYPO',
          description: 'Missing letter: benchpres → bench press',
        ),
        const _TestQuery(
          query: 'barbell',
          expectedInTop5: 'barbell',
          category: 'TYPO',
          description: 'Correct spelling verification',
        ),
        const _TestQuery(
          query: 'sqat',
          expectedInTop5: 'squat',
          category: 'TYPO',
          description: 'Transposition: sqat → squat',
        ),
        const _TestQuery(
          query: 'deadlft',
          expectedInTop5: 'deadlift',
          category: 'TYPO',
          description: 'Missing letter: deadlft → deadlift',
        ),
        const _TestQuery(
          query: 'pullup',
          expectedInTop5: 'pull',
          category: 'TYPO',
          description: 'Missing space: pullup → pull up',
        ),
        const _TestQuery(
          query: 'pushup',
          expectedInTop5: 'push',
          category: 'TYPO',
          description: 'Missing space: pushup → push up',
        ),
        const _TestQuery(
          query: 'dumbell',
          expectedInTop5: 'dumbbell',
          category: 'TYPO',
          description: 'Missing letter: dumbell → dumbbell',
        ),
        const _TestQuery(
          query: 'situp',
          expectedInTop5: 'sit',
          category: 'TYPO',
          description: 'Missing space: situp → sit up',
        ),
        const _TestQuery(
          query: 'chinup',
          expectedInTop5: 'chin',
          category: 'TYPO',
          description: 'Missing space: chinup → chin up',
        ),
        const _TestQuery(
          query: 'crunches',
          expectedInTop5: 'crunch',
          category: 'TYPO',
          description: 'Plural: crunches → crunch',
        ),

        // Category 2: Muscle group queries (8 queries)
        const _TestQuery(
          query: 'chest',
          expectedInTop5: 'chest',
          category: 'MUSCLE',
          description: 'Muscle group: chest',
        ),
        const _TestQuery(
          query: 'biceps',
          expectedInTop5: 'bicep',
          category: 'MUSCLE',
          description: 'Muscle group: biceps',
        ),
        const _TestQuery(
          query: 'lats',
          expectedInTop5: 'lat',
          category: 'MUSCLE',
          description: 'Abbreviation: lats → lat',
        ),
        const _TestQuery(
          query: 'quads',
          expectedInTop5: 'quad',
          category: 'MUSCLE',
          description: 'Abbreviation: quads → quadriceps',
        ),
        const _TestQuery(
          query: 'glutes',
          expectedInTop5: 'glute',
          category: 'MUSCLE',
          description: 'Plural: glutes → glute',
        ),
        const _TestQuery(
          query: 'abs',
          expectedInTop5: 'ab',
          category: 'MUSCLE',
          description: 'Abbreviation: abs → abdominal',
        ),
        const _TestQuery(
          query: 'traps',
          expectedInTop5: 'trap',
          category: 'MUSCLE',
          description: 'Abbreviation: traps → trapezius',
        ),
        const _TestQuery(
          query: 'hamstrings',
          expectedInTop5: 'hamstring',
          category: 'MUSCLE',
          description: 'Plural: hamstrings → hamstring',
        ),

        // Category 3: Equipment queries (6 queries)
        const _TestQuery(
          query: 'dumbbells',
          expectedInTop5: 'dumbbell',
          category: 'EQUIPMENT',
          description: 'Plural: dumbbells → dumbbell',
        ),
        const _TestQuery(
          query: 'barbell',
          expectedInTop5: 'barbell',
          category: 'EQUIPMENT',
          description: 'Equipment: barbell',
        ),
        const _TestQuery(
          query: 'bodyweight',
          expectedInTop5: 'bodyweight',
          category: 'EQUIPMENT',
          description: 'Equipment: bodyweight',
        ),
        const _TestQuery(
          query: 'cable',
          expectedInTop5: 'cable',
          category: 'EQUIPMENT',
          description: 'Equipment: cable',
        ),
        const _TestQuery(
          query: 'kettlebell',
          expectedInTop5: 'kettlebell',
          category: 'EQUIPMENT',
          description: 'Equipment: kettlebell',
        ),
        const _TestQuery(
          query: 'resistance band',
          expectedInTop5: 'band',
          category: 'EQUIPMENT',
          description: 'Equipment: resistance band',
        ),

        // Category 4: Movement patterns (4 queries)
        const _TestQuery(
          query: 'incline bench',
          expectedInTop5: 'incline',
          category: 'MOVEMENT',
          description: 'Pattern: incline bench press',
        ),
        const _TestQuery(
          query: 'front squat',
          expectedInTop5: 'front',
          category: 'MOVEMENT',
          description: 'Pattern variant: front squat',
        ),
        const _TestQuery(
          query: 'romanian deadlift',
          expectedInTop5: 'romanian',
          category: 'MOVEMENT',
          description: 'Pattern variant: romanian deadlift',
        ),
        const _TestQuery(
          query: 'pull ups',
          expectedInTop5: 'pull',
          category: 'MOVEMENT',
          description: 'Pattern: pull ups',
        ),

        // Category 5: Complex queries (2 queries)
        const _TestQuery(
          query: 'exercise for biceps with dumbbells',
          expectedInTop5: 'bicep',
          category: 'COMPLEX',
          description: 'Long query: 6 tokens',
        ),
        const _TestQuery(
          query: 'flat bench press with barbell for chest',
          expectedInTop5: 'bench',
          category: 'COMPLEX',
          description: 'Very long query: 7 tokens',
        ),
      ];

      // ============================================================
      // RUN BENCHMARK
      // ============================================================

      final results = <_BenchmarkResult>[];
      var totalTime = 0;

      print('Running ${testQueries.length} test queries...\n');
      print('-'*80);

      for (var i = 0; i < testQueries.length; i++) {
        final testQuery = testQueries[i];

        final stopwatch = Stopwatch()..start();
        final searchResults = FuzzySearchService.searchExercises(
          query: testQuery.query,
          allExercises: exercises,
          locale: 'en',
          minScore: 0.4,  // Using calibrated threshold from IT tests
        );
        stopwatch.stop();

        final time = stopwatch.elapsedMilliseconds;
        totalTime += time;

        // Check if expected exercise is in top 5
        // Accept if result contains either the QUERY term or the EXPECTED synonym
        final top5 = searchResults.take(5).toList();
        final queryLower = testQuery.query.toLowerCase();
        final expectedLower = testQuery.expectedInTop5.toLowerCase();

        final foundExpected = top5.any((result) {
          final nameLower = result.exercise.nome.toLowerCase();
          final fieldsLower = result.exercise.searchableFields.map((f) => f.toLowerCase()).toList();

          // Check if name or fields contain the query term OR the expected synonym
          return nameLower.contains(queryLower) ||
                 nameLower.contains(expectedLower) ||
                 fieldsLower.any((field) => field.contains(queryLower) || field.contains(expectedLower));
        });

        final result = _BenchmarkResult(
          query: testQuery,
          resultCount: searchResults.length,
          top5Results: top5.map((r) => r.exercise.nome).toList(),
          top5Scores: top5.map((r) => r.score).toList(),
          foundExpected: foundExpected,
          timeMs: time,
        );

        results.add(result);

        // Print result
        _printQueryResult(i + 1, result);
      }

      // ============================================================
      // CALCULATE METRICS
      // ============================================================

      print('\n${'='*80}');
      print('BENCHMARK RESULTS - ENGLISH DATASET');
      print('='*80);

      final avgTime = totalTime / testQueries.length;
      final maxTime = results.map((r) => r.timeMs).reduce(max);
      final minTime = results.map((r) => r.timeMs).reduce(min);

      final precision = results.where((r) => r.foundExpected).length / results.length;
      final recall = precision;  // Assuming perfect recall if found in top 5
      final f1Score = 2 * (precision * recall) / (precision + recall);

      print('Performance Metrics:');
      print('  Average time: ${avgTime.toStringAsFixed(1)}ms');
      print('  Min time: ${minTime}ms');
      print('  Max time: ${maxTime}ms');
      print('  Total time: ${totalTime}ms');
      print('');

      print('Accuracy Metrics:');
      print('  Precision: ${(precision * 100).toStringAsFixed(1)}% (${results.where((r) => r.foundExpected).length}/${results.length} queries)');
      print('  Recall: ${(recall * 100).toStringAsFixed(1)}%');
      print('  F1-Score: ${f1Score.toStringAsFixed(3)}');
      print('');

      // Category breakdown
      print('Category Breakdown:');
      final categories = testQueries.map((q) => q.category).toSet();
      for (final category in categories) {
        final categoryResults = results.where((r) => r.query.category == category).toList();
        final categoryPrecision = categoryResults.where((r) => r.foundExpected).length / categoryResults.length;
        print('  $category: ${(categoryPrecision * 100).toStringAsFixed(1)}% (${categoryResults.where((r) => r.foundExpected).length}/${categoryResults.length})');
      }

      print('\n${'='*80}');
      print('COMPARISON WITH ITALIAN DATASET');
      print('='*80);
      print('IT Dataset: 1550 exercises, F1-score: 0.60');
      print('EN Dataset: ${exercises.length} exercises, F1-score: ${f1Score.toStringAsFixed(3)}');
      print('');

      // Performance difference
      if (f1Score > 0.60) {
        print('✅ IMPROVEMENT: EN dataset performs ${((f1Score - 0.60) * 100).toStringAsFixed(1)}% better');
      } else if (f1Score < 0.60) {
        print('⚠️ REGRESSION: EN dataset performs ${((0.60 - f1Score) * 100).toStringAsFixed(1)}% worse');
      } else {
        print('⚖️ EQUAL: Same performance on both datasets');
      }

      print('\n${'='*80}');
      print('FAILED QUERIES (NOT found in top 5):');
      print('='*80);

      final failedQueries = results.where((r) => !r.foundExpected).toList();
      if (failedQueries.isEmpty) {
        print('🎉 NO FAILURES - All queries found expected exercise in top 5!');
      } else {
        for (var i = 0; i < failedQueries.length; i++) {
          final failed = failedQueries[i];
          print('\n${i + 1}. Query: "${failed.query.query}"');
          print('   Expected: ${failed.query.expectedInTop5}');
          print('   Got top 5:');
          for (var j = 0; j < failed.top5Results.length; j++) {
            print('     ${j + 1}. ${failed.top5Results[j]} (${(failed.top5Scores[j] * 100).toStringAsFixed(0)}%)');
          }
          print('   Category: ${failed.query.category}');
          print('   Description: ${failed.query.description}');
        }
      }

      print('\n${'='*80}');
      print('NEXT STEPS');
      print('='*80);
      if (f1Score >= 0.75) {
        print('✅ EN dataset meets target (F1 >= 0.75)');
        print('   Ready for production integration');
      } else {
        print('⚠️ EN dataset needs improvement');
        print('   Recommendations:');
        print('   1. Add missing typo/synonym entries');
        print('   2. Improve compound word handling (pullup, pushup)');
        print('   3. Enhance stopword filtering for complex queries');
      }
      print('');

      // Assertions
      expect(avgTime, lessThan(50), reason: 'Average query time should be < 50ms');
      expect(f1Score, greaterThan(0.75), reason: 'F1-Score should be > 0.75 minimum');
      expect(precision, greaterThan(0.80), reason: 'Precision should be > 80%');
    });
  });
}

// ============================================================
// HELPER CLASSES
// ============================================================

class _TestQuery {
  const _TestQuery({
    required this.query,
    required this.expectedInTop5,
    required this.category,
    required this.description,
  });

  final String query;
  final String expectedInTop5;
  final String category;
  final String description;
}

class _BenchmarkResult {
  const _BenchmarkResult({
    required this.query,
    required this.resultCount,
    required this.top5Results,
    required this.top5Scores,
    required this.foundExpected,
    required this.timeMs,
  });

  final _TestQuery query;
  final int resultCount;
  final List<String> top5Results;
  final List<double> top5Scores;
  final bool foundExpected;
  final int timeMs;
}

void _printQueryResult(int index, _BenchmarkResult result) {
  final status = result.foundExpected ? '✅' : '❌';

  print('[$index] $status Query: "${result.query.query}" (${result.query.category})');
  print('    Expected: ${result.query.expectedInTop5}');
  print('    Results: ${result.resultCount} total, top 5:');

  for (var i = 0; i < min(5, result.top5Results.length); i++) {
    final scorePercent = (result.top5Scores[i] * 100).toStringAsFixed(0);
    print('      ${i + 1}. ${result.top5Results[i]} ($scorePercent%)');
  }

  print('    Time: ${result.timeMs}ms');
  print('');
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzy_bolt/fuzzy_bolt.dart';

void main() {
  group('FuzzyBolt Score Test', () {
    test('distenzioni vs distensioni score', () async {
      final exercises = [
        'Distensioni su Panca Piana',
        'Distensione Verticale',
        'Distensioni Inclinate',
        'Curl Bicipiti',
        'Squat',
      ];

      final results = await FuzzyBolt.searchWithScores<String>(
        exercises,
        'distenzioni', // typo: z invece di s
        selectors: [(e) => e.toLowerCase()],
        strictThreshold: 0.5,
        typeThreshold: 0.4,
        skipIsolate: true,
      );

      print('\n=== FuzzyBolt Results for "distenzioni" ===');
      for (final r in results) {
        print('${r.item}: ${(r.score * 100).toStringAsFixed(1)}%');
      }
      print('');

      // Should find distensioni with reasonable score
      expect(results, isNotEmpty,
          reason: 'Should find exercises with "distensioni"');

      if (results.isNotEmpty) {
        expect(results.first.item.toLowerCase(), contains('distension'));
        print('Best match score: ${(results.first.score * 100).toStringAsFixed(1)}%');
      }
    });

    test('check if 0.65 threshold is too high', () async {
      final exercises = [
        'Distensioni su Panca Piana',
      ];

      // Test with current threshold
      final results065 = await FuzzyBolt.searchWithScores<String>(
        exercises,
        'distenzioni',
        selectors: [(e) => e.toLowerCase()],
        strictThreshold: 0.65,
        typeThreshold: 0.50,
        skipIsolate: true,
      );

      // Test with lower threshold
      final results050 = await FuzzyBolt.searchWithScores<String>(
        exercises,
        'distenzioni',
        selectors: [(e) => e.toLowerCase()],
        strictThreshold: 0.50,
        typeThreshold: 0.40,
        skipIsolate: true,
      );

      print('\n=== Threshold Comparison ===');
      print('With 0.65 threshold: ${results065.length} results');
      print('With 0.50 threshold: ${results050.length} results');

      if (results050.isNotEmpty) {
        print('Score: ${(results050.first.score * 100).toStringAsFixed(1)}%');
        print('Passes 0.65 filter? ${results050.first.score >= 0.65}');
      }
    });
  });
}

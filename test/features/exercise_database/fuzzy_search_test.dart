import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

void main() {
  group('Fuzzy Search - Typo Tolerance', () {
    test('should match common typos with threshold >= 70', () {
      // Test cases: [query, target, expectedToMatch]
      final tests = [
        ['distenzioni', 'distensioni', true], // z invece di s
        ['distenzione', 'distensione', true], // singolare ok
        ['distensioni', 'distensioni', true], // esatto
        ['bicepit', 'bicipiti', true], // typo comune
        ['tricipti', 'tricipiti', true], // lettere scambiate
        ['squot', 'squat', true], // typo vocale
        ['panca', 'panca', true], // esatto
        ['curl', 'curl', true], // esatto
        ['xyz', 'distensioni', false], // completamente diverso
      ];

      for (final test in tests) {
        final query = test[0] as String;
        final target = test[1] as String;
        final shouldMatch = test[2] as bool;

        final score = ratio(query, target);
        final matches = score >= 70;

        expect(
          matches,
          equals(shouldMatch),
          reason:
              '"$query" vs "$target" = $score% (expected ${shouldMatch ? ">=" : "<"} 70)',
        );
      }
    });

    test('should rank exact matches higher than fuzzy matches', () {
      final exactScore = ratio('distensioni', 'distensioni');
      final fuzzyScore = ratio('distenzioni', 'distensioni');

      expect(exactScore, greaterThan(fuzzyScore));
      expect(exactScore, equals(100));
    });
  });
}

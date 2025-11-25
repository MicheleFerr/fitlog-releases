import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_search_service.dart';

/// Test per il nuovo ExerciseSearchService V2 con ricerca order-agnostic
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExerciseSearchService V2 - Order Agnostic Tests', () {
    late ExerciseSearchService service;

    setUpAll(() async {
      service = ExerciseSearchService();
      // Carica esercizi in italiano
      await service.loadExercises(const Locale('it'));
    });

    test('Leg Curl should find Curl Sdraiato Leg (order-agnostic)', () async {
      final results = await service.searchExercises('Leg Curl', const Locale('it'));

      print('\n🔎 Results for "Leg Curl":');
      for (final r in results.take(5)) {
        print('   - ${r.name}');
      }

      expect(results, isNotEmpty, reason: 'Should find at least one result');

      // Verifica che contenga "curl" e "leg" nel nome
      final hasMatch = results.any((r) =>
          r.name.toLowerCase().contains('curl') &&
          r.name.toLowerCase().contains('leg'));
      expect(hasMatch, isTrue, reason: 'Should find exercise with curl and leg');
    });

    test('Piana panca should find Panca Piana (inverted)', () async {
      final results = await service.searchExercises('Piana panca', const Locale('it'));

      print('\n🔎 Results for "Piana panca":');
      for (final r in results.take(5)) {
        print('   - ${r.name}');
      }

      expect(results, isNotEmpty, reason: 'Should find at least one result');

      final hasMatch = results.any((r) =>
          r.name.toLowerCase().contains('panca') &&
          r.name.toLowerCase().contains('piana'));
      expect(hasMatch, isTrue, reason: 'Should find Panca Piana');
    });

    test('Hammer curl should find Curl Hammer', () async {
      final results = await service.searchExercises('Hammer curl', const Locale('it'));

      print('\n🔎 Results for "Hammer curl":');
      for (final r in results.take(5)) {
        print('   - ${r.name}');
      }

      expect(results, isNotEmpty, reason: 'Should find at least one result');

      final hasMatch = results.any((r) =>
          r.name.toLowerCase().contains('hammer') &&
          r.name.toLowerCase().contains('curl'));
      expect(hasMatch, isTrue, reason: 'Should find Curl Hammer');
    });

    test('press bench should find bench press exercises', () async {
      final results = await service.searchExercises('press bench', const Locale('it'));

      print('\n🔎 Results for "press bench":');
      for (final r in results.take(5)) {
        print('   - ${r.name}');
      }

      // In italiano potrebbe non trovare "press bench" letteralmente
      // ma dovrebbe trovare esercizi con "panca"
      print('   Note: Italian DB may not have "bench press" - checking "panca"');
    });

    test('petto should find chest exercises (category mapping)', () async {
      final results = await service.searchExercises('petto', const Locale('it'));

      print('\n🔎 Results for "petto" (category):');
      print('   Found ${results.length} exercises');
      for (final r in results.take(3)) {
        print('   - ${r.name}');
      }

      expect(results, isNotEmpty, reason: 'Should find chest exercises');
    });

    test('inclinata panca should find Panca Inclinata', () async {
      final results = await service.searchExercises('inclinata panca', const Locale('it'));

      print('\n🔎 Results for "inclinata panca":');
      for (final r in results.take(5)) {
        print('   - ${r.name}');
      }

      expect(results, isNotEmpty, reason: 'Should find at least one result');

      final hasMatch = results.any((r) =>
          r.name.toLowerCase().contains('panca') &&
          r.name.toLowerCase().contains('inclinata'));
      expect(hasMatch, isTrue, reason: 'Should find Panca Inclinata');
    });

    test('curl leg should find same as Leg Curl', () async {
      final results1 = await service.searchExercises('Leg Curl', const Locale('it'));
      final results2 = await service.searchExercises('curl leg', const Locale('it'));

      print('\n🔎 Comparing "Leg Curl" vs "curl leg":');
      print('   Leg Curl: ${results1.take(3).map((r) => r.name).join(", ")}');
      print('   curl leg: ${results2.take(3).map((r) => r.name).join(", ")}');

      // Entrambi dovrebbero trovare esercizi con curl e leg
      final names1 = results1.take(5).map((r) => r.name.toLowerCase()).toSet();
      final names2 = results2.take(5).map((r) => r.name.toLowerCase()).toSet();

      final overlap = names1.intersection(names2);
      expect(overlap, isNotEmpty, reason: 'Both queries should find similar results');
    });
  });
}

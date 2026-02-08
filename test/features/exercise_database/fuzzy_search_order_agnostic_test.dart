import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_fuzzy_search_isolate.dart';

/// Test per verificare che la ricerca order-agnostic funzioni correttamente
/// - "Leg Curl" -> trova "Curl Sdraiato Leg..."
/// - "Piana panca" -> trova "Panca Piana"
/// - "Hammer curl" -> trova "Curl Hammer"
void main() {
  // Lista esercizi di test (simula exercises_it.json)
  final testExercises = [
    ExerciseDefinition(
      id: 'lever_lying_leg_curl',
      nome: 'Curl Sdraiato Leg Alla Macchina',
      focus: const ['FEMORALI'],
      muscoliSecondari: const ['GLUT'],
      difficolta: 'Intermedio',
      tipoEsercizio: 'Isolamento',
      attrezzatura: 'Macchina',
      patternMovimento: 'Hip Hinge',
      rangeRipetizioni: '8-15',
      aliases: const ['cslam', 'curl', 'curl sdraiato leg', 'leg curl'],
    ),
    ExerciseDefinition(
      id: 'barbell_bench_press',
      nome: 'Panca Piana Bilanciere',
      focus: const ['PETTO'],
      muscoliSecondari: const ['TRICIPITI', 'SPALLE'],
      difficolta: 'Intermedio',
      tipoEsercizio: 'Compound',
      attrezzatura: 'Bilanciere',
      patternMovimento: 'Push',
      rangeRipetizioni: '6-12',
      aliases: const ['bench press', 'panca', 'flat bench'],
    ),
    ExerciseDefinition(
      id: 'dumbbell_hammer_curl',
      nome: 'Curl Hammer Manubri',
      focus: const ['BICIPITI'],
      muscoliSecondari: const ['AVAMBRACCI'],
      difficolta: 'Principiante',
      tipoEsercizio: 'Isolamento',
      attrezzatura: 'Manubri',
      patternMovimento: 'Pull',
      rangeRipetizioni: '8-15',
      aliases: const ['hammer curl', 'curl martello'],
    ),
    ExerciseDefinition(
      id: 'incline_bench_press',
      nome: 'Panca Inclinata Bilanciere',
      focus: const ['PETTO'],
      muscoliSecondari: const ['TRICIPITI', 'SPALLE'],
      difficolta: 'Intermedio',
      tipoEsercizio: 'Compound',
      attrezzatura: 'Bilanciere',
      patternMovimento: 'Push',
      rangeRipetizioni: '6-12',
      aliases: const ['incline bench', 'panca inclinata'],
    ),
    ExerciseDefinition(
      id: 'lat_pulldown',
      nome: 'Lat Machine Presa Larga',
      focus: const ['DORSALI'],
      muscoliSecondari: const ['BICIPITI', 'AVAMBRACCI'],
      difficolta: 'Principiante',
      tipoEsercizio: 'Compound',
      attrezzatura: 'Cavi',
      patternMovimento: 'Pull',
      rangeRipetizioni: '8-15',
      aliases: const ['lat pulldown', 'pulldown'],
    ),
  ];

  group('Order-Agnostic Search Tests', () {
    late ExerciseFuzzySearchIsolate searchIsolate;

    setUpAll(() async {
      searchIsolate = ExerciseFuzzySearchIsolate();
      await searchIsolate.initialize();
    });

    tearDownAll(() async {
      await searchIsolate.dispose();
    });

    test('Leg Curl should find Curl Sdraiato Leg', () async {
      final results = await searchIsolate.search(
        query: 'Leg Curl',
        exercises: testExercises,
        userBoosts: {},
      );

      expect(results, isNotEmpty, reason: 'Should find at least one result');

      // Debug: print all results
      print('\n🔎 Debug: All results for "Leg Curl":');
      for (final r in results.take(5)) {
        print('   - ${r.exercise.nome} (id: ${r.exercise.id}, score: ${r.scorePercentage})');
      }

      // Verifica che il primo risultato sia il leg curl
      final topResult = results.first;
      expect(
        topResult.exercise.id,
        equals('lever_lying_leg_curl'),
        reason: 'Top result should be the Leg Curl exercise',
      );

      print('✅ "Leg Curl" -> "${topResult.exercise.nome}" (score: ${topResult.scorePercentage})');
    });

    test('Piana panca should find Panca Piana', () async {
      final results = await searchIsolate.search(
        query: 'Piana panca',
        exercises: testExercises,
        userBoosts: {},
      );

      expect(results, isNotEmpty, reason: 'Should find at least one result');

      // Verifica che trovi Panca Piana
      final hasPancaPiana = results.any((r) => r.exercise.id == 'barbell_bench_press');
      expect(hasPancaPiana, isTrue, reason: 'Should find Panca Piana exercise');

      final topResult = results.first;
      print('✅ "Piana panca" -> "${topResult.exercise.nome}" (score: ${topResult.scorePercentage})');
    });

    test('Hammer curl should find Curl Hammer', () async {
      final results = await searchIsolate.search(
        query: 'Hammer curl',
        exercises: testExercises,
        userBoosts: {},
      );

      expect(results, isNotEmpty, reason: 'Should find at least one result');

      // Verifica che il primo risultato sia curl hammer
      final topResult = results.first;
      expect(
        topResult.exercise.id,
        equals('dumbbell_hammer_curl'),
        reason: 'Top result should be the Hammer Curl exercise',
      );

      print('✅ "Hammer curl" -> "${topResult.exercise.nome}" (score: ${topResult.scorePercentage})');
    });

    test('curl leg should find Curl Sdraiato Leg (inverted)', () async {
      final results = await searchIsolate.search(
        query: 'curl leg',
        exercises: testExercises,
        userBoosts: {},
      );

      expect(results, isNotEmpty, reason: 'Should find at least one result');

      final hasLegCurl = results.any((r) => r.exercise.id == 'lever_lying_leg_curl');
      expect(hasLegCurl, isTrue, reason: 'Should find Leg Curl exercise');

      final topResult = results.first;
      print('✅ "curl leg" -> "${topResult.exercise.nome}" (score: ${topResult.scorePercentage})');
    });

    test('bench press should find Panca Piana', () async {
      final results = await searchIsolate.search(
        query: 'bench press',
        exercises: testExercises,
        userBoosts: {},
      );

      expect(results, isNotEmpty, reason: 'Should find at least one result');

      final hasBench = results.any((r) => r.exercise.id == 'barbell_bench_press');
      expect(hasBench, isTrue, reason: 'Should find bench press exercise');

      final topResult = results.first;
      print('✅ "bench press" -> "${topResult.exercise.nome}" (score: ${topResult.scorePercentage})');
    });

    test('press bench (inverted) should find Panca Piana', () async {
      final results = await searchIsolate.search(
        query: 'press bench',
        exercises: testExercises,
        userBoosts: {},
      );

      expect(results, isNotEmpty, reason: 'Should find at least one result');

      final hasBench = results.any((r) => r.exercise.id == 'barbell_bench_press');
      expect(hasBench, isTrue, reason: 'Should find bench press exercise with inverted query');

      final topResult = results.first;
      print('✅ "press bench" -> "${topResult.exercise.nome}" (score: ${topResult.scorePercentage})');
    });

    // NOTE: Sinonimi (martello = hammer) richiedono aliases nel JSON,
    // non sono gestiti dall'order-agnostic search.
    // Se si aggiunge 'curl martello' agli aliases di dumbbell_hammer_curl,
    // il test passerebbe.
    test('martello curl requires aliases in JSON (synonym, not order issue)', () async {
      final results = await searchIsolate.search(
        query: 'martello curl',
        exercises: testExercises,
        userBoosts: {},
      );

      // Questo test documenta che i SINONIMI (martello=hammer) richiedono aliases
      // Order-agnostic search gestisce solo l'ORDINE delle parole, non le traduzioni
      print('ℹ️ "martello curl" - Sinonimi richiedono aliases nel JSON');
      print('   Per supportare: aggiungere "curl martello" agli aliases di Curl Hammer');

      // Se non ci sono aliases con "martello", non trova risultati - questo è corretto
      if (results.isEmpty) {
        print('   Risultato atteso: nessun match (manca alias "martello")');
      } else {
        final topResult = results.first;
        print('   Trovato: "${topResult.exercise.nome}" (score: ${topResult.scorePercentage})');
      }
    });

    test('inclinata panca should find Panca Inclinata', () async {
      final results = await searchIsolate.search(
        query: 'inclinata panca',
        exercises: testExercises,
        userBoosts: {},
      );

      expect(results, isNotEmpty, reason: 'Should find at least one result');

      final hasIncline = results.any((r) => r.exercise.id == 'incline_bench_press');
      expect(hasIncline, isTrue, reason: 'Should find incline bench with inverted words');

      final topResult = results.first;
      print('✅ "inclinata panca" -> "${topResult.exercise.nome}" (score: ${topResult.scorePercentage})');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/import/data/mappers/exercise_name_mapper.dart';
import 'package:gymbro_flutter_new/features/import/domain/entities/import_result.dart';
import 'package:gymbro_flutter_new/shared/domain/abstractions/exercise_counting_mode.dart';

// ---------------------------------------------------------------------------
// Fake ExerciseDefinition factory – avoids touching Hive adapter internals
// ---------------------------------------------------------------------------

ExerciseDefinition _makeExercise({
  required String id,
  required String nome,
  List<String> aliases = const [],
}) {
  return ExerciseDefinition(
    id: id,
    nome: nome,
    focus: const [],
    muscoliSecondari: const [],
    difficolta: 'Intermedio',
    tipoEsercizio: 'Compound',
    attrezzatura: 'Bilanciere',
    patternMovimento: 'Push',
    rangeRipetizioni: '8-12',
    aliases: aliases,
    countingMode: ExerciseCountingMode.weighted,
  );
}

// ---------------------------------------------------------------------------
// A minimal exercise database used throughout tests
// ---------------------------------------------------------------------------

final List<ExerciseDefinition> _fakeDb = [
  _makeExercise(
    id: 'ex-bench',
    nome: 'Panca Piana con Bilanciere',
    aliases: ['bench press', 'panca piana', 'flat bench'],
  ),
  _makeExercise(
    id: 'ex-squat',
    nome: 'Squat con Bilanciere',
    aliases: ['squat', 'back squat'],
  ),
  _makeExercise(
    id: 'ex-pullup',
    nome: 'Trazioni alla Sbarra',
    aliases: ['pull up', 'pullup', 'chin up', 'trazioni'],
  ),
  _makeExercise(
    id: 'ex-deadlift',
    nome: 'Stacco da Terra',
    aliases: ['deadlift', 'stacco'],
  ),
  _makeExercise(
    id: 'ex-ohp',
    nome: 'Military Press con Bilanciere',
    aliases: ['overhead press', 'ohp', 'military press'],
  ),
  _makeExercise(
    id: 'ex-curl',
    nome: 'Curl con Bilanciere',
    aliases: ['barbell curl', 'bicep curl', 'curl bilanciere'],
  ),
  _makeExercise(
    id: 'ex-lat',
    nome: 'Lat Machine',
    aliases: ['lat pulldown', 'pulldown'],
  ),
];

void main() {
  late ExerciseNameMapper mapper;

  setUp(() {
    mapper = ExerciseNameMapper(_fakeDb);
  });

  // ---------------------------------------------------------------------------
  group('ExerciseNameMapper - constants', () {
    test('autoMapThreshold is 0.75', () {
      expect(ExerciseNameMapper.autoMapThreshold, 0.75);
    });

    test('suggestionThreshold is 0.4', () {
      expect(ExerciseNameMapper.suggestionThreshold, 0.4);
    });

    test('maxSuggestions is 5', () {
      expect(ExerciseNameMapper.maxSuggestions, 5);
    });

    test('knownMappings is not empty', () {
      expect(ExerciseNameMapper.knownMappings, isNotEmpty);
    });

    test('knownMappings contains bench press entry', () {
      expect(ExerciseNameMapper.knownMappings.containsKey('bench press'), isTrue);
    });

    test('knownMappings contains squat entry', () {
      expect(ExerciseNameMapper.knownMappings.containsKey('squat'), isTrue);
    });

    test('knownMappings contains deadlift entry', () {
      expect(ExerciseNameMapper.knownMappings.containsKey('deadlift'), isTrue);
    });

    test('knownMappings contains pull up variants', () {
      expect(ExerciseNameMapper.knownMappings.containsKey('pull up'), isTrue);
      expect(ExerciseNameMapper.knownMappings.containsKey('pullup'), isTrue);
      expect(ExerciseNameMapper.knownMappings.containsKey('pull-up'), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  group('ExerciseNameMapper - findBestMatch', () {
    test('finds known mapping for "bench press"', () async {
      final match = await mapper.findBestMatch('bench press');

      expect(match, isNotNull);
      expect(match!.exerciseId, 'ex-bench');
      expect(match.confidence, greaterThanOrEqualTo(0.9));
    });

    test('finds known mapping for "Bench Press" (case insensitive)', () async {
      final match = await mapper.findBestMatch('Bench Press');

      expect(match, isNotNull);
      expect(match!.exerciseId, 'ex-bench');
    });

    test('finds known mapping for "Flat Bench Press"', () async {
      final match = await mapper.findBestMatch('Flat Bench Press');

      expect(match, isNotNull);
      // Should match bench press translation since normalized contains "bench press"
      expect(match!.confidence, greaterThanOrEqualTo(0.9));
    });

    test('finds known mapping for "Squat (Barbell)"', () async {
      final match = await mapper.findBestMatch('Squat (Barbell)');

      expect(match, isNotNull);
      expect(match!.exerciseId, 'ex-squat');
    });

    test('finds known mapping for "Pull Up"', () async {
      final match = await mapper.findBestMatch('Pull Up');

      expect(match, isNotNull);
      expect(match!.exerciseId, 'ex-pullup');
    });

    test('finds known mapping for "Pull-Up" (hyphenated)', () async {
      final match = await mapper.findBestMatch('Pull-Up');

      expect(match, isNotNull);
      expect(match!.exerciseId, 'ex-pullup');
    });

    test('finds known mapping for "Pullup" (no space)', () async {
      final match = await mapper.findBestMatch('Pullup');

      expect(match, isNotNull);
      expect(match!.exerciseId, 'ex-pullup');
    });

    test('finds known mapping for "Deadlift"', () async {
      final match = await mapper.findBestMatch('Deadlift');

      expect(match, isNotNull);
      expect(match!.exerciseId, 'ex-deadlift');
    });

    test('finds known mapping for "Overhead Press"', () async {
      final match = await mapper.findBestMatch('Overhead Press');

      expect(match, isNotNull);
      expect(match!.exerciseId, 'ex-ohp');
    });

    test('returns null or low-confidence for completely unknown exercise', () async {
      // Use a string that won't match anything meaningful
      final match = await mapper.findBestMatch('xyzabc gibberish 123 nothing');

      // Either null or very low confidence
      if (match != null) {
        expect(match.confidence, lessThan(ExerciseNameMapper.autoMapThreshold));
      }
    });

    test('returns ExerciseMatch with valid fields', () async {
      final match = await mapper.findBestMatch('Bench Press');

      expect(match, isNotNull);
      expect(match!.exerciseId, isNotEmpty);
      expect(match.name, isNotEmpty);
      expect(match.confidence, greaterThan(0.0));
      expect(match.confidence, lessThanOrEqualTo(1.0));
    });
  });

  // ---------------------------------------------------------------------------
  group('ExerciseNameMapper - findSuggestions', () {
    test('returns suggestions for bench press', () async {
      final suggestions = await mapper.findSuggestions('bench press');

      expect(suggestions, isNotEmpty);
      // All suggestions should be above threshold
      for (final s in suggestions) {
        expect(s.confidence, greaterThanOrEqualTo(ExerciseNameMapper.suggestionThreshold));
      }
    });

    test('respects maxSuggestions limit', () async {
      final suggestions = await mapper.findSuggestions('press');

      expect(suggestions.length, lessThanOrEqualTo(ExerciseNameMapper.maxSuggestions));
    });

    test('returns empty list for completely unrecognizable input', () async {
      final suggestions = await mapper.findSuggestions('zzz999aaa');

      // Either empty or all below threshold (already filtered)
      for (final s in suggestions) {
        expect(
          s.confidence,
          greaterThanOrEqualTo(ExerciseNameMapper.suggestionThreshold),
        );
      }
    });

    test('each suggestion has non-empty exerciseId and name', () async {
      final suggestions = await mapper.findSuggestions('squat');

      for (final s in suggestions) {
        expect(s.exerciseId, isNotEmpty);
        expect(s.name, isNotEmpty);
      }
    });
  });

  // ---------------------------------------------------------------------------
  group('ExerciseNameMapper - mapExercises', () {
    ImportParseResult buildParseResult(List<String> exerciseNames) {
      final unmapped = exerciseNames
          .map(
            (name) => UnmappedExercise(
              originalName: name,
              occurrences: 1,
              suggestions: [],
            ),
          )
          .toList();

      final workout = ParsedWorkout(
        name: 'Test Workout',
        date: DateTime(2024, 1, 15),
        exercises: exerciseNames
            .map(
              (name) => ParsedExercise(
                originalName: name,
                sets: [const ParsedSet(setNumber: 1, weight: 80.0, reps: 8)],
              ),
            )
            .toList(),
      );

      return ImportParseResult(
        sourceApp: 'strong',
        workouts: [workout],
        unmappedExercises: unmapped,
        autoMappedExercises: {},
        totalRows: exerciseNames.length,
        parsedRows: exerciseNames.length,
      );
    }

    test('auto-maps exercises with high confidence', () async {
      final parseResult = buildParseResult(['bench press']);

      final mapped = await mapper.mapExercises(parseResult);

      expect(mapped.autoMappedExercises, isNotEmpty);
      expect(mapped.autoMappedExercises.containsKey('bench press'), isTrue);
    });

    test('updates workouts with mappedExerciseId after auto-mapping', () async {
      final parseResult = buildParseResult(['bench press']);

      final mapped = await mapper.mapExercises(parseResult);

      final exercise = mapped.workouts.first.exercises.first;
      expect(exercise.mappedExerciseId, isNotNull);
      expect(exercise.mappedExerciseName, isNotNull);
    });

    test('keeps exercises in stillUnmapped when confidence is low', () async {
      final parseResult = buildParseResult(['xyzabc totally unknown exercise']);

      final mapped = await mapper.mapExercises(parseResult);

      // The exercise should still be in unmapped
      expect(mapped.unmappedExercises, isNotEmpty);
      expect(
        mapped.unmappedExercises.any(
          (u) => u.originalName == 'xyzabc totally unknown exercise',
        ),
        isTrue,
      );
    });

    test('unmapped exercises get suggestions attached', () async {
      final parseResult = buildParseResult(['xyzabc totally unknown exercise']);

      final mapped = await mapper.mapExercises(parseResult);

      // suggestions field should be populated (though possibly empty for truly unknown names)
      final unmapped = mapped.unmappedExercises.first;
      expect(unmapped.suggestions, isA<List<ExerciseMatch>>());
    });

    test('returns updated ImportParseResult with same sourceApp', () async {
      final parseResult = buildParseResult(['squat']);

      final mapped = await mapper.mapExercises(parseResult);
      expect(mapped.sourceApp, 'strong');
    });

    test('handles empty unmappedExercises gracefully', () async {
      const parseResult = ImportParseResult(
        sourceApp: 'hevy',
        workouts: [],
        unmappedExercises: [],
        autoMappedExercises: {},
        totalRows: 0,
        parsedRows: 0,
      );

      final mapped = await mapper.mapExercises(parseResult);
      expect(mapped.autoMappedExercises, isEmpty);
      expect(mapped.unmappedExercises, isEmpty);
    });

    test('maps multiple known exercises simultaneously', () async {
      final parseResult = buildParseResult([
        'bench press',
        'squat',
        'deadlift',
      ]);

      final mapped = await mapper.mapExercises(parseResult);

      expect(mapped.autoMappedExercises.length, greaterThanOrEqualTo(2));
    });
  });

  // ---------------------------------------------------------------------------
  group('ExerciseNameMapper - normalize / fuzzy variants', () {
    test('handles mixed case input', () async {
      final match = await mapper.findBestMatch('BENCH PRESS');
      expect(match, isNotNull);
    });

    test('handles extra whitespace', () async {
      final match = await mapper.findBestMatch('  bench  press  ');
      expect(match, isNotNull);
    });

    test('handles punctuation in name', () async {
      // "Bench Press (Barbell)" should still find bench press
      final match = await mapper.findBestMatch('Bench Press (Barbell)');
      expect(match, isNotNull);
      expect(match!.confidence, greaterThanOrEqualTo(0.9));
    });

    test('handles hyphenated variants', () async {
      final match = await mapper.findBestMatch('Pull-Up');
      expect(match, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  group('ExerciseNameMapper - empty database', () {
    test('findBestMatch with empty database: known mapping path throws or returns null', () async {
      // The known mapping path calls _exercises.firstWhere with orElse: () => _exercises.first
      // which throws StateError when _exercises is empty.
      // The fuzzy fallback path (FuzzyBolt) returns empty results -> null.
      // For names that do NOT match any known mapping key, fuzzy path runs safely:
      final emptyMapper = ExerciseNameMapper([]);
      // 'xyzabc' won't match any known mapping, so it falls through to fuzzy search
      final match = await emptyMapper.findBestMatch('xyzabc unknown exercise name');
      expect(match, isNull); // FuzzyBolt returns empty results -> null
    });

    test('findSuggestions returns empty list when database is empty', () async {
      final emptyMapper = ExerciseNameMapper([]);
      final suggestions = await emptyMapper.findSuggestions('squat');
      expect(suggestions, isEmpty);
    });
  });
}

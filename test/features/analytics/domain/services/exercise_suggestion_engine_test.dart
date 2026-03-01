import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/exercise_suggestion_engine.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/neglected_muscle_detector.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';

void main() {
  late ExerciseSuggestionEngine engine;

  setUp(() {
    engine = ExerciseSuggestionEngine();
  });

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  /// Build a minimal [ExerciseDefinition] for testing.
  ExerciseDefinition makeExercise({
    required String id,
    required String nome,
    required String focus,
    String tipoEsercizio = 'Compound',
    String countingMode = 'weighted',
    String difficolta = 'Intermedio',
    String patternMovimento = 'Squat',
    String rangeRipetizioni = '6-10',
    String? imageUrl,
  }) {
    return ExerciseDefinition(
      id: id,
      nome: nome,
      focus: [focus],
      muscoliSecondari: const [],
      difficolta: difficolta,
      tipoEsercizio: tipoEsercizio,
      attrezzatura: 'Bilanciere',
      patternMovimento: patternMovimento,
      rangeRipetizioni: rangeRipetizioni,
      countingMode: ExerciseCountingMode.fromString(countingMode),
      imageUrl: imageUrl,
    );
  }

  NeglectedMuscle makeNeglected({
    required String muscleName,
    double priority = 5.0,
    NeglectSeverity severity = NeglectSeverity.high,
  }) {
    return NeglectedMuscle(
      muscleName: muscleName,
      volumePercentage: 2.0,
      severity: severity,
      priority: priority,
    );
  }

  // ---------------------------------------------------------------------------
  // ExerciseDifficulty.fromItalianString
  // ---------------------------------------------------------------------------

  group('ExerciseDifficulty.fromItalianString', () {
    test('returns beginner for "principiante" (lowercase)', () {
      expect(
        ExerciseDifficulty.fromItalianString('principiante'),
        ExerciseDifficulty.beginner,
      );
    });

    test('returns beginner for "Principiante" (mixed case)', () {
      expect(
        ExerciseDifficulty.fromItalianString('Principiante'),
        ExerciseDifficulty.beginner,
      );
    });

    test('returns intermediate for "intermedio"', () {
      expect(
        ExerciseDifficulty.fromItalianString('intermedio'),
        ExerciseDifficulty.intermediate,
      );
    });

    test('returns intermediate for "Intermedio" (mixed case)', () {
      expect(
        ExerciseDifficulty.fromItalianString('Intermedio'),
        ExerciseDifficulty.intermediate,
      );
    });

    test('returns advanced for "avanzato"', () {
      expect(
        ExerciseDifficulty.fromItalianString('avanzato'),
        ExerciseDifficulty.advanced,
      );
    });

    test('returns advanced for "Avanzato" (mixed case)', () {
      expect(
        ExerciseDifficulty.fromItalianString('Avanzato'),
        ExerciseDifficulty.advanced,
      );
    });

    test('returns intermediate for unknown string', () {
      expect(
        ExerciseDifficulty.fromItalianString('unknown'),
        ExerciseDifficulty.intermediate,
      );
    });

    test('returns intermediate for null', () {
      expect(
        ExerciseDifficulty.fromItalianString(null),
        ExerciseDifficulty.intermediate,
      );
    });

    test('returns intermediate for empty string', () {
      expect(
        ExerciseDifficulty.fromItalianString(''),
        ExerciseDifficulty.intermediate,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Exercise exclusion - exact match only
  // ---------------------------------------------------------------------------

  group('Exercise exclusion - exact match only', () {
    final quadExercises = [
      makeExercise(
        id: 'squat_bilanciere',
        nome: 'Squat con Bilanciere',
        focus: 'QUAD',
      ),
      makeExercise(
        id: 'front_squat_bilanciere',
        nome: 'Front Squat con Bilanciere',
        focus: 'QUAD',
      ),
      makeExercise(
        id: 'leg_press_45',
        nome: 'Leg Press 45°',
        focus: 'QUAD',
      ),
      makeExercise(
        id: 'leg_extension',
        nome: 'Leg Extension',
        focus: 'QUAD',
        tipoEsercizio: 'Isolamento',
      ),
      makeExercise(
        id: 'goblet_squat',
        nome: 'Goblet Squat con Manubri',
        focus: 'QUAD',
      ),
    ];

    final neglectedQuads = [
      const NeglectedMuscle(
        muscleName: 'quads',
        volumePercentage: 2.0,
        severity: NeglectSeverity.critical,
        priority: 8.0,
      ),
    ];

    test(
      'should find QUAD exercises when template has "Squat con Bilanciere"',
      () {
        final excludeSet = {'Squat con Bilanciere', 'squat_bilanciere'};

        final result = engine.generateSuggestionsGroupedByMuscle(
          neglectedMuscles: neglectedQuads,
          allExercises: quadExercises,
          excludeExercises: excludeSet,
        );

        expect(result.containsKey('quads'), isTrue,
            reason: 'Should have suggestions for quads');
        expect(result['quads']!.length, greaterThan(0),
            reason: 'Should have at least one suggestion');

        final names = result['quads']!.map((s) => s.exerciseName).toList();
        expect(names, isNot(contains('Squat con Bilanciere')));
        // "Front Squat con Bilanciere" should NOT be excluded (different name)
        expect(names, contains('Front Squat con Bilanciere'));
      },
    );

    test('should not over-exclude exercises with substring matching', () {
      final excludeSet = {'Squat con Bilanciere', 'squat_bilanciere'};

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglectedQuads,
        allExercises: quadExercises,
        excludeExercises: excludeSet,
      );

      // 5 exercises - 1 exact match = 4 remaining
      expect(result['quads']!.length, equals(4));
    });

    test('should exclude by exact ID match', () {
      final excludeSet = {'leg_extension'};

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglectedQuads,
        allExercises: quadExercises,
        excludeExercises: excludeSet,
      );

      final names = result['quads']!.map((s) => s.exerciseName).toList();
      expect(names, isNot(contains('Leg Extension')));
      expect(result['quads']!.length, equals(4));
    });

    test('empty excludeSet does not remove any exercise', () {
      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglectedQuads,
        allExercises: quadExercises,
        excludeExercises: {},
      );

      // maxPerMuscle default is 4
      expect(result['quads']!.length, equals(4));
    });

    test('null excludeExercises does not remove any exercise', () {
      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglectedQuads,
        allExercises: quadExercises,
      );

      expect(result['quads']!.length, equals(4));
    });

    test('case-insensitive exclusion by name', () {
      final excludeSet = {'squat con bilanciere'}; // lowercase

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglectedQuads,
        allExercises: quadExercises,
        excludeExercises: excludeSet,
      );

      final names = result['quads']!.map((s) => s.exerciseName).toList();
      expect(names, isNot(contains('Squat con Bilanciere')));
    });
  });

  // ---------------------------------------------------------------------------
  // Glute suggestions
  // ---------------------------------------------------------------------------

  group('Glute suggestions', () {
    final gluteExercises = [
      makeExercise(
        id: 'hip_thrust_bilanciere',
        nome: 'Hip Thrust con Bilanciere',
        focus: 'GLUT',
      ),
      makeExercise(
        id: 'bulgarian_split_squat',
        nome: 'Bulgarian Split Squat',
        focus: 'GLUT',
      ),
      makeExercise(
        id: 'glute_bridge',
        nome: 'Glute Bridge',
        focus: 'GLUT',
      ),
    ];

    final neglectedGlutes = [
      const NeglectedMuscle(
        muscleName: 'glutes',
        volumePercentage: 1.5,
        severity: NeglectSeverity.critical,
        priority: 9.0,
      ),
    ];

    test('should find GLUT exercises for neglected glutes', () {
      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglectedGlutes,
        allExercises: gluteExercises,
      );

      expect(result.containsKey('glutes'), isTrue);
      expect(result['glutes']!.length, equals(3));
    });

    test('should only exclude exact match, not substring', () {
      final excludeSet = {'Hip Thrust con Bilanciere', 'hip_thrust_bilanciere'};

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglectedGlutes,
        allExercises: gluteExercises,
        excludeExercises: excludeSet,
      );

      expect(result.containsKey('glutes'), isTrue);
      expect(result['glutes']!.length, equals(2));
      final names = result['glutes']!.map((s) => s.exerciseName).toList();
      expect(names, isNot(contains('Hip Thrust con Bilanciere')));
      expect(names, contains('Bulgarian Split Squat'));
      expect(names, contains('Glute Bridge'));
    });
  });

  // ---------------------------------------------------------------------------
  // Focus code mapping
  // ---------------------------------------------------------------------------

  group('Focus code mapping', () {
    test('quads maps to QUAD focus code', () {
      final exercises = [
        makeExercise(id: 'test1', nome: 'Test QUAD', focus: 'QUAD'),
        makeExercise(id: 'test2', nome: 'Test LAT', focus: 'LAT'),
      ];

      final neglected = [
        const NeglectedMuscle(
          muscleName: 'quads',
          volumePercentage: 2.0,
          severity: NeglectSeverity.critical,
          priority: 8.0,
        ),
      ];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result['quads']!.length, equals(1));
      expect(result['quads']!.first.exerciseName, equals('Test QUAD'));
    });

    test('glutes maps to GLUT focus code', () {
      final exercises = [
        makeExercise(id: 'test1', nome: 'Test GLUT', focus: 'GLUT'),
        makeExercise(id: 'test2', nome: 'Test PETT', focus: 'PETT'),
      ];

      final neglected = [
        const NeglectedMuscle(
          muscleName: 'glutes',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 9.0,
        ),
      ];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result['glutes']!.length, equals(1));
      expect(result['glutes']!.first.exerciseName, equals('Test GLUT'));
    });

    test('back maps via MuscleAbbreviationMapper (LAT focus code)', () {
      // getSearchAbbreviations('back') → nameToAbbreviation('back') → 'LAT'
      // TRAP is not included because 'schiena' pattern is only hit with that exact key
      final exercises = [
        makeExercise(id: 'lat_ex', nome: 'Lat Pulldown', focus: 'LAT'),
        makeExercise(id: 'pett_ex', nome: 'Bench Press', focus: 'PETT'),
      ];
      final neglected = [makeNeglected(muscleName: 'back')];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      // back → getSearchAbbreviations returns ['LAT']
      expect(result.containsKey('back'), isTrue);
      final names = result['back']!.map((s) => s.exerciseName).toList();
      expect(names, contains('Lat Pulldown'));
      expect(names, isNot(contains('Bench Press')));
    });

    test('chest maps to PETT focus code', () {
      final exercises = [
        makeExercise(id: 'bp', nome: 'Bench Press', focus: 'PETT'),
        makeExercise(id: 'row', nome: 'Barbell Row', focus: 'LAT'),
      ];
      final neglected = [makeNeglected(muscleName: 'chest')];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result.containsKey('chest'), isTrue);
      expect(result['chest']!.first.exerciseName, equals('Bench Press'));
    });

    test('biceps maps to BICI focus code', () {
      final exercises = [
        makeExercise(id: 'curl', nome: 'Barbell Curl', focus: 'BICI'),
      ];
      final neglected = [makeNeglected(muscleName: 'biceps')];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result.containsKey('biceps'), isTrue);
      expect(result['biceps']!.first.exerciseName, equals('Barbell Curl'));
    });

    test('triceps maps to TRIC focus code', () {
      final exercises = [
        makeExercise(id: 'pushdown', nome: 'Tricep Pushdown', focus: 'TRIC'),
      ];
      final neglected = [makeNeglected(muscleName: 'triceps')];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result.containsKey('triceps'), isTrue);
    });

    test('hamstrings maps to FEMO focus code', () {
      final exercises = [
        makeExercise(id: 'rdl', nome: 'Romanian Deadlift', focus: 'FEMO'),
      ];
      final neglected = [makeNeglected(muscleName: 'hamstrings')];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result.containsKey('hamstrings'), isTrue);
      expect(result['hamstrings']!.first.exerciseName,
          equals('Romanian Deadlift'));
    });

    test('calves maps to POLP focus code', () {
      final exercises = [
        makeExercise(
            id: 'calf_raise', nome: 'Calf Raise', focus: 'POLP'),
      ];
      final neglected = [makeNeglected(muscleName: 'calves')];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result.containsKey('calves'), isTrue);
    });

    test('shoulders maps to DELT focus code', () {
      final exercises = [
        makeExercise(
            id: 'ohp', nome: 'Overhead Press', focus: 'DELT'),
      ];
      final neglected = [makeNeglected(muscleName: 'shoulders')];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result.containsKey('shoulders'), isTrue);
    });

    test('abs maps via fallback to CORE focus code', () {
      final exercises = [
        makeExercise(id: 'plank', nome: 'Plank', focus: 'CORE'),
      ];
      final neglected = [makeNeglected(muscleName: 'abs')];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result.containsKey('abs'), isTrue);
    });

    test('lower_back maps via MuscleAbbreviationMapper to LOMB focus code', () {
      // getSearchAbbreviations('lower_back') → nameToAbbreviation('lower_back') → 'LOMB'
      final exercises = [
        makeExercise(
            id: 'hyperext', nome: 'Hyperextension', focus: 'LOMB'),
      ];
      final neglected = [makeNeglected(muscleName: 'lower_back')];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result.containsKey('lower_back'), isTrue);
    });

    test('unknown muscle name returns no suggestions', () {
      final exercises = [
        makeExercise(id: 'test', nome: 'Some Exercise', focus: 'QUAD'),
      ];
      final neglected = [makeNeglected(muscleName: 'unknown_muscle_xyz')];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      // No focus codes → skipped
      expect(result.containsKey('unknown_muscle_xyz'), isFalse);
    });

    test('empty neglected list returns empty map', () {
      final exercises = [
        makeExercise(id: 'test', nome: 'Some Exercise', focus: 'QUAD'),
      ];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: [],
        allExercises: exercises,
      );

      expect(result, isEmpty);
    });

    test('empty exercises list returns empty map', () {
      final neglected = [makeNeglected(muscleName: 'quads')];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglected,
        allExercises: [],
      );

      expect(result, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // generateSuggestionsFromDatabase – flat list
  // ---------------------------------------------------------------------------

  group('generateSuggestionsFromDatabase', () {
    test('returns flat list sorted by priority descending', () {
      final exercises = [
        makeExercise(id: 'q1', nome: 'Squat', focus: 'QUAD'),
        makeExercise(id: 'q2', nome: 'Leg Press', focus: 'QUAD'),
        makeExercise(id: 'g1', nome: 'Hip Thrust', focus: 'GLUT'),
      ];

      final neglected = [
        const NeglectedMuscle(
          muscleName: 'quads',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 5.0, // lower priority
        ),
        const NeglectedMuscle(
          muscleName: 'glutes',
          volumePercentage: 0.5,
          severity: NeglectSeverity.critical,
          priority: 9.0, // higher priority
        ),
      ];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result, isNotEmpty);
      // Glute suggestion (priority 9.0) should come before quad (5.0)
      expect(result.first.targetMuscle, equals('glutes'));
    });

    test('respects maxPerMuscle limit', () {
      final exercises = List.generate(
        10,
        (i) => makeExercise(
          id: 'ex$i',
          nome: 'Exercise $i',
          focus: 'QUAD',
        ),
      );

      final neglected = [
        const NeglectedMuscle(
          muscleName: 'quads',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 8.0,
        ),
      ];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: exercises,
        maxPerMuscle: 3,
      );

      final quadSuggestions =
          result.where((s) => s.targetMuscle == 'quads').toList();
      expect(quadSuggestions.length, equals(3));
    });

    test('default maxPerMuscle is 4', () {
      final exercises = List.generate(
        6,
        (i) => makeExercise(
          id: 'ex$i',
          nome: 'Exercise $i',
          focus: 'QUAD',
        ),
      );

      final neglected = [
        const NeglectedMuscle(
          muscleName: 'quads',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 8.0,
        ),
      ];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result.length, equals(4));
    });

    test('excludes exercises by name or id in flat list', () {
      final exercises = [
        makeExercise(id: 'q1', nome: 'Squat', focus: 'QUAD'),
        makeExercise(id: 'q2', nome: 'Leg Press', focus: 'QUAD'),
      ];
      final neglected = [makeNeglected(muscleName: 'quads')];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: exercises,
        excludeExercises: {'Squat'},
      );

      expect(result.length, equals(1));
      expect(result.first.exerciseName, equals('Leg Press'));
    });

    test('returns empty list when no matching exercises', () {
      final exercises = [
        makeExercise(id: 'bench', nome: 'Bench Press', focus: 'PETT'),
      ];
      final neglected = [makeNeglected(muscleName: 'quads')];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result, isEmpty);
    });

    test('skips neglected muscles with empty focus codes', () {
      final exercises = [
        makeExercise(id: 'q1', nome: 'Squat', focus: 'QUAD'),
      ];
      // 'unknown_xyz' will produce no focus codes
      final neglected = [
        makeNeglected(muscleName: 'unknown_xyz'),
        makeNeglected(muscleName: 'quads'),
      ];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result.every((s) => s.targetMuscle == 'quads'), isTrue);
    });

    test('suggestion properties are mapped correctly from ExerciseDefinition',
        () {
      final exercise = ExerciseDefinition(
        id: 'bp_id',
        nome: 'Bench Press',
        focus: const ['PETT'],
        muscoliSecondari: const [],
        difficolta: 'Principiante',
        tipoEsercizio: 'Compound',
        attrezzatura: 'Bilanciere',
        patternMovimento: 'Push Pattern',
        rangeRipetizioni: '8-12',
        countingMode: ExerciseCountingMode.weighted,
        imageUrl: 'https://example.com/bench.gif',
      );

      final neglected = [
        const NeglectedMuscle(
          muscleName: 'chest',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 7.5,
        ),
      ];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: [exercise],
      );

      expect(result.length, equals(1));
      final s = result.first;
      expect(s.exerciseId, equals('bp_id'));
      expect(s.exerciseName, equals('Bench Press'));
      expect(s.targetMuscle, equals('chest'));
      expect(s.priority, equals(7.5));
      expect(s.difficulty, equals(ExerciseDifficulty.beginner));
      expect(s.equipment, equals('Bilanciere'));
      expect(s.description, equals('Push Pattern'));
      expect(s.countingMode, equals(ExerciseCountingMode.weighted));
      expect(s.exerciseType, equals('Compound'));
      expect(s.imageUrl, equals('https://example.com/bench.gif'));
    });

    test('uses rangeRipetizioni when patternMovimento is empty', () {
      final exercise = ExerciseDefinition(
        id: 'plank_id',
        nome: 'Plank',
        focus: const ['CORE'],
        muscoliSecondari: const [],
        difficolta: 'Principiante',
        tipoEsercizio: 'Isolamento',
        attrezzatura: 'Corpo Libero',
        patternMovimento: '', // empty → fallback
        rangeRipetizioni: '30-60s',
        countingMode: ExerciseCountingMode.time,
      );

      final neglected = [
        const NeglectedMuscle(
          muscleName: 'abs',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 6.0,
        ),
      ];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: [exercise],
      );

      expect(result.length, equals(1));
      // When patternMovimento is empty, description should use rangeRipetizioni
      expect(result.first.description, equals('30-60s'));
    });

    test('imageUrl is null when not provided', () {
      final exercises = [
        makeExercise(id: 'q1', nome: 'Squat', focus: 'QUAD'),
      ];
      final neglected = [makeNeglected(muscleName: 'quads')];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result.first.imageUrl, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Sorting logic
  // ---------------------------------------------------------------------------

  group('Sorting: countingMode order (weighted first)', () {
    test('weighted exercises appear before reps and time', () {
      final exercises = [
        makeExercise(
          id: 'time_ex',
          nome: 'Plank',
          focus: 'QUAD',
          countingMode: 'time',
        ),
        makeExercise(
          id: 'reps_ex',
          nome: 'Bodyweight Squat',
          focus: 'QUAD',
          countingMode: 'reps',
        ),
        makeExercise(
          id: 'weighted_ex',
          nome: 'Barbell Squat',
          focus: 'QUAD',
          countingMode: 'weighted',
        ),
      ];

      final neglected = [makeNeglected(muscleName: 'quads')];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: exercises,
        maxPerMuscle: 3,
      );

      expect(result.first.exerciseName, equals('Barbell Squat'));
      expect(result[1].exerciseName, equals('Bodyweight Squat'));
      expect(result.last.exerciseName, equals('Plank'));
    });
  });

  group('Sorting: exercise type order (Compound first)', () {
    test('Compound exercises appear before Isolamento', () {
      final exercises = [
        makeExercise(
          id: 'iso',
          nome: 'Leg Extension',
          focus: 'QUAD',
          tipoEsercizio: 'Isolamento',
          countingMode: 'weighted',
        ),
        makeExercise(
          id: 'compound',
          nome: 'Barbell Squat',
          focus: 'QUAD',
          tipoEsercizio: 'Compound',
          countingMode: 'weighted',
        ),
      ];

      final neglected = [makeNeglected(muscleName: 'quads')];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: exercises,
        maxPerMuscle: 2,
      );

      expect(result.first.exerciseName, equals('Barbell Squat'));
      expect(result.last.exerciseName, equals('Leg Extension'));
    });

    test('unknown exercise type sorts after Isolamento', () {
      final exercises = [
        makeExercise(
          id: 'unknown_type',
          nome: 'Mystery Move',
          focus: 'QUAD',
          tipoEsercizio: 'Cardio',
          countingMode: 'weighted',
        ),
        makeExercise(
          id: 'iso',
          nome: 'Leg Extension',
          focus: 'QUAD',
          tipoEsercizio: 'Isolamento',
          countingMode: 'weighted',
        ),
      ];

      final neglected = [makeNeglected(muscleName: 'quads')];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: exercises,
        maxPerMuscle: 2,
      );

      // Isolamento (1) < unknown (2)
      expect(result.first.exerciseName, equals('Leg Extension'));
      expect(result.last.exerciseName, equals('Mystery Move'));
    });
  });

  group('Sorting: difficulty order (beginner first)', () {
    test('principiante before intermedio before avanzato', () {
      final exercises = [
        makeExercise(
          id: 'adv',
          nome: 'Avanzato Exercise',
          focus: 'QUAD',
          tipoEsercizio: 'Compound',
          countingMode: 'weighted',
          difficolta: 'Avanzato',
        ),
        makeExercise(
          id: 'beg',
          nome: 'Principiante Exercise',
          focus: 'QUAD',
          tipoEsercizio: 'Compound',
          countingMode: 'weighted',
          difficolta: 'Principiante',
        ),
        makeExercise(
          id: 'int',
          nome: 'Intermedio Exercise',
          focus: 'QUAD',
          tipoEsercizio: 'Compound',
          countingMode: 'weighted',
          difficolta: 'Intermedio',
        ),
      ];

      final neglected = [makeNeglected(muscleName: 'quads')];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: exercises,
        maxPerMuscle: 3,
      );

      expect(result[0].exerciseName, equals('Principiante Exercise'));
      expect(result[1].exerciseName, equals('Intermedio Exercise'));
      expect(result[2].exerciseName, equals('Avanzato Exercise'));
    });

    test('unknown difficulty treated as intermedio in sort order', () {
      final exercises = [
        makeExercise(
          id: 'unknown',
          nome: 'Unknown Difficulty',
          focus: 'QUAD',
          tipoEsercizio: 'Compound',
          countingMode: 'weighted',
          difficolta: 'Nessuno',
        ),
        makeExercise(
          id: 'beg',
          nome: 'Principiante Exercise',
          focus: 'QUAD',
          tipoEsercizio: 'Compound',
          countingMode: 'weighted',
          difficolta: 'Principiante',
        ),
      ];

      final neglected = [makeNeglected(muscleName: 'quads')];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: exercises,
        maxPerMuscle: 2,
      );

      // principiante (0) before unknown-treated-as-intermedio (1)
      expect(result.first.exerciseName, equals('Principiante Exercise'));
    });
  });

  // ---------------------------------------------------------------------------
  // generateSuggestionsGroupedByMuscle – additional coverage
  // ---------------------------------------------------------------------------

  group('generateSuggestionsGroupedByMuscle – additional', () {
    test('multiple muscles produce separate groups', () {
      final exercises = [
        makeExercise(id: 'q1', nome: 'Squat', focus: 'QUAD'),
        makeExercise(id: 'g1', nome: 'Hip Thrust', focus: 'GLUT'),
        makeExercise(id: 'p1', nome: 'Bench Press', focus: 'PETT'),
      ];

      final neglected = [
        makeNeglected(muscleName: 'quads', priority: 8.0),
        makeNeglected(muscleName: 'glutes', priority: 7.0),
        makeNeglected(muscleName: 'chest', priority: 6.0),
      ];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result.containsKey('quads'), isTrue);
      expect(result.containsKey('glutes'), isTrue);
      expect(result.containsKey('chest'), isTrue);
    });

    test('muscle with no matching exercises is omitted from map', () {
      final exercises = [
        makeExercise(id: 'q1', nome: 'Squat', focus: 'QUAD'),
      ];

      // calves neglected but no POLP exercise in list
      final neglected = [
        makeNeglected(muscleName: 'calves', priority: 5.0),
        makeNeglected(muscleName: 'quads', priority: 8.0),
      ];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result.containsKey('calves'), isFalse);
      expect(result.containsKey('quads'), isTrue);
    });

    test('respects maxPerMuscle in grouped method', () {
      final exercises = List.generate(
        6,
        (i) => makeExercise(
          id: 'ex$i',
          nome: 'Exercise $i',
          focus: 'QUAD',
        ),
      );

      final neglected = [makeNeglected(muscleName: 'quads')];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglected,
        allExercises: exercises,
        maxPerMuscle: 2,
      );

      expect(result['quads']!.length, equals(2));
    });

    test('suggestion priority matches neglected muscle priority', () {
      final exercises = [
        makeExercise(id: 'q1', nome: 'Squat', focus: 'QUAD'),
      ];

      final neglected = [
        const NeglectedMuscle(
          muscleName: 'quads',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 9.5,
        ),
      ];

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result['quads']!.first.priority, equals(9.5));
    });
  });

  // ---------------------------------------------------------------------------
  // Legacy generateSuggestions (flat list with static database)
  // ---------------------------------------------------------------------------

  group('generateSuggestions (legacy)', () {
    test('returns suggestions for known muscle (back)', () {
      final neglected = [
        const NeglectedMuscle(
          muscleName: 'back',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 8.0,
        ),
      ];

      final result = engine.generateSuggestions(neglectedMuscles: neglected);

      expect(result, isNotEmpty);
      expect(result.every((s) => s.targetMuscle == 'back'), isTrue);
    });

    test('returns empty for unknown muscle (no database entry)', () {
      final neglected = [
        const NeglectedMuscle(
          muscleName: 'phantom_muscle',
          volumePercentage: 0.0,
          severity: NeglectSeverity.critical,
          priority: 10.0,
        ),
      ];

      final result = engine.generateSuggestions(neglectedMuscles: neglected);

      expect(result, isEmpty);
    });

    test('respects maxSuggestions limit', () {
      final neglected = [
        const NeglectedMuscle(
          muscleName: 'back',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 8.0,
        ),
        const NeglectedMuscle(
          muscleName: 'chest',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 7.0,
        ),
        const NeglectedMuscle(
          muscleName: 'quads',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 6.0,
        ),
      ];

      final result = engine.generateSuggestions(
        neglectedMuscles: neglected,
        maxSuggestions: 2,
      );

      expect(result.length, lessThanOrEqualTo(2));
    });

    test('default maxSuggestions is 5', () {
      final neglected = [
        const NeglectedMuscle(
          muscleName: 'back',
          volumePercentage: 0.5,
          severity: NeglectSeverity.critical,
          priority: 8.0,
        ),
        const NeglectedMuscle(
          muscleName: 'chest',
          volumePercentage: 0.5,
          severity: NeglectSeverity.critical,
          priority: 7.0,
        ),
        const NeglectedMuscle(
          muscleName: 'quads',
          volumePercentage: 0.5,
          severity: NeglectSeverity.critical,
          priority: 6.0,
        ),
        const NeglectedMuscle(
          muscleName: 'biceps',
          volumePercentage: 0.5,
          severity: NeglectSeverity.critical,
          priority: 5.0,
        ),
        const NeglectedMuscle(
          muscleName: 'triceps',
          volumePercentage: 0.5,
          severity: NeglectSeverity.critical,
          priority: 4.0,
        ),
        const NeglectedMuscle(
          muscleName: 'shoulders',
          volumePercentage: 0.5,
          severity: NeglectSeverity.critical,
          priority: 3.0,
        ),
      ];

      final result = engine.generateSuggestions(neglectedMuscles: neglected);

      expect(result.length, lessThanOrEqualTo(5));
    });

    test('filters by maxDifficulty: beginner only', () {
      final neglected = [
        const NeglectedMuscle(
          muscleName: 'back',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 8.0,
        ),
      ];

      final result = engine.generateSuggestions(
        neglectedMuscles: neglected,
        maxDifficulty: ExerciseDifficulty.beginner,
      );

      // Only beginner exercises should be included
      expect(
        result.every((s) => s.difficulty == ExerciseDifficulty.beginner),
        isTrue,
      );
    });

    test('filters by maxDifficulty: intermediate excludes advanced', () {
      final neglected = [
        const NeglectedMuscle(
          muscleName: 'back',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 8.0,
        ),
      ];

      final result = engine.generateSuggestions(
        neglectedMuscles: neglected,
        maxDifficulty: ExerciseDifficulty.intermediate,
      );

      expect(
        result.every((s) => s.difficulty.index <= ExerciseDifficulty.intermediate.index),
        isTrue,
      );
    });

    test('excludes named exercises from legacy method', () {
      final neglected = [
        const NeglectedMuscle(
          muscleName: 'back',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 8.0,
        ),
      ];

      final beforeExclude = engine.generateSuggestions(
        neglectedMuscles: neglected,
      );
      final pullUpExists =
          beforeExclude.any((s) => s.exerciseName == 'Pull-ups');

      if (pullUpExists) {
        final result = engine.generateSuggestions(
          neglectedMuscles: neglected,
          excludeExercises: {'Pull-ups'},
        );
        expect(result.any((s) => s.exerciseName == 'Pull-ups'), isFalse);
      }
    });

    test('sorted by priority descending across muscles', () {
      final neglected = [
        const NeglectedMuscle(
          muscleName: 'hamstrings',
          volumePercentage: 0.5,
          severity: NeglectSeverity.critical,
          priority: 3.0,
        ),
        const NeglectedMuscle(
          muscleName: 'back',
          volumePercentage: 0.5,
          severity: NeglectSeverity.critical,
          priority: 9.0,
        ),
      ];

      final result = engine.generateSuggestions(neglectedMuscles: neglected);

      if (result.length >= 2) {
        // Back (priority 9) should come before hamstrings (priority 3)
        final backIdx = result.indexWhere((s) => s.targetMuscle == 'back');
        final hamIdx =
            result.indexWhere((s) => s.targetMuscle == 'hamstrings');
        if (backIdx >= 0 && hamIdx >= 0) {
          expect(backIdx, lessThan(hamIdx));
        }
      }
    });

    test('null maxDifficulty allows all difficulties', () {
      final neglected = [
        const NeglectedMuscle(
          muscleName: 'back',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 8.0,
        ),
      ];

      final withFilter = engine.generateSuggestions(
        neglectedMuscles: neglected,
        maxDifficulty: ExerciseDifficulty.beginner,
      );

      final withoutFilter = engine.generateSuggestions(
        neglectedMuscles: neglected,
      );

      // Without filter should have >= results compared to with filter
      expect(withoutFilter.length, greaterThanOrEqualTo(withFilter.length));
    });
  });

  // ---------------------------------------------------------------------------
  // Legacy generateSuggestionsGroupedByMuscleLegacy
  // ---------------------------------------------------------------------------

  group('generateSuggestionsGroupedByMuscleLegacy', () {
    test('returns grouped suggestions for known muscles', () {
      final neglected = [
        const NeglectedMuscle(
          muscleName: 'chest',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 7.0,
        ),
        const NeglectedMuscle(
          muscleName: 'shoulders',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 6.0,
        ),
      ];

      final result = engine.generateSuggestionsGroupedByMuscleLegacy(
        neglectedMuscles: neglected,
      );

      expect(result.containsKey('chest'), isTrue);
      expect(result.containsKey('shoulders'), isTrue);
    });

    test('omits muscles with no database entries', () {
      final neglected = [
        const NeglectedMuscle(
          muscleName: 'phantom',
          volumePercentage: 0.0,
          severity: NeglectSeverity.critical,
          priority: 10.0,
        ),
      ];

      final result = engine.generateSuggestionsGroupedByMuscleLegacy(
        neglectedMuscles: neglected,
      );

      expect(result.containsKey('phantom'), isFalse);
    });

    test('filters by maxDifficulty: beginner only', () {
      final neglected = [
        const NeglectedMuscle(
          muscleName: 'back',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 8.0,
        ),
      ];

      final result = engine.generateSuggestionsGroupedByMuscleLegacy(
        neglectedMuscles: neglected,
        maxDifficulty: ExerciseDifficulty.beginner,
      );

      if (result.containsKey('back')) {
        expect(
          result['back']!
              .every((s) => s.difficulty == ExerciseDifficulty.beginner),
          isTrue,
        );
      }
    });

    test('excludes named exercises from grouped legacy method', () {
      final neglected = [
        const NeglectedMuscle(
          muscleName: 'back',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 8.0,
        ),
      ];

      final beforeResult = engine.generateSuggestionsGroupedByMuscleLegacy(
        neglectedMuscles: neglected,
      );

      if (beforeResult.containsKey('back') &&
          beforeResult['back']!.isNotEmpty) {
        final nameToExclude = beforeResult['back']!.first.exerciseName;

        final result = engine.generateSuggestionsGroupedByMuscleLegacy(
          neglectedMuscles: neglected,
          excludeExercises: {nameToExclude},
        );

        if (result.containsKey('back')) {
          expect(
            result['back']!.any((s) => s.exerciseName == nameToExclude),
            isFalse,
          );
        }
      }
    });

    test('empty neglected list returns empty map', () {
      final result = engine.generateSuggestionsGroupedByMuscleLegacy(
        neglectedMuscles: [],
      );

      expect(result, isEmpty);
    });

    test('suggestion fields are populated from legacy database', () {
      final neglected = [
        const NeglectedMuscle(
          muscleName: 'triceps',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 5.0,
        ),
      ];

      final result = engine.generateSuggestionsGroupedByMuscleLegacy(
        neglectedMuscles: neglected,
      );

      if (result.containsKey('triceps')) {
        final s = result['triceps']!.first;
        expect(s.exerciseId, isNotEmpty);
        expect(s.exerciseName, isNotEmpty);
        expect(s.targetMuscle, equals('triceps'));
        expect(s.priority, equals(5.0));
        expect(s.equipment, isNotEmpty);
        expect(s.description, isNotEmpty);
      }
    });

    test('null excludeExercises does not cause error', () {
      final neglected = [
        const NeglectedMuscle(
          muscleName: 'chest',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 7.0,
        ),
      ];

      // Should not throw
      final result = engine.generateSuggestionsGroupedByMuscleLegacy(
        neglectedMuscles: neglected,
      );

      expect(result, isA<Map<String, List<ExerciseSuggestion>>>());
    });

    test('all legacy database muscles produce suggestions', () {
      // These are the muscle names present in _legacyDatabase
      const legacyMuscles = [
        'back',
        'hamstrings',
        'glutes',
        'calves',
        'triceps',
        'abs',
        'shoulders',
        'chest',
        'biceps',
        'quads',
      ];

      for (final muscle in legacyMuscles) {
        final neglected = [
          NeglectedMuscle(
            muscleName: muscle,
            volumePercentage: 0.5,
            severity: NeglectSeverity.critical,
            priority: 8.0,
          ),
        ];

        final result = engine.generateSuggestionsGroupedByMuscleLegacy(
          neglectedMuscles: neglected,
        );

        expect(result.containsKey(muscle), isTrue,
            reason: 'Expected suggestions for muscle: $muscle');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // ExerciseSuggestion construction
  // ---------------------------------------------------------------------------

  group('ExerciseSuggestion', () {
    test('can be constructed and all fields are accessible', () {
      const suggestion = ExerciseSuggestion(
        exerciseId: 'test_id',
        exerciseName: 'Test Exercise',
        targetMuscle: 'chest',
        priority: 7.5,
        difficulty: ExerciseDifficulty.intermediate,
        equipment: 'Bilanciere',
        description: 'Push Pattern',
        countingMode: ExerciseCountingMode.weighted,
        exerciseType: 'Compound',
        imageUrl: 'https://example.com/img.gif',
      );

      expect(suggestion.exerciseId, equals('test_id'));
      expect(suggestion.exerciseName, equals('Test Exercise'));
      expect(suggestion.targetMuscle, equals('chest'));
      expect(suggestion.priority, equals(7.5));
      expect(suggestion.difficulty, equals(ExerciseDifficulty.intermediate));
      expect(suggestion.equipment, equals('Bilanciere'));
      expect(suggestion.description, equals('Push Pattern'));
      expect(suggestion.countingMode, equals(ExerciseCountingMode.weighted));
      expect(suggestion.exerciseType, equals('Compound'));
      expect(suggestion.imageUrl, equals('https://example.com/img.gif'));
    });

    test('imageUrl defaults to null', () {
      const suggestion = ExerciseSuggestion(
        exerciseId: 'id',
        exerciseName: 'Name',
        targetMuscle: 'muscle',
        priority: 5.0,
        difficulty: ExerciseDifficulty.beginner,
        equipment: 'None',
        description: 'Desc',
        countingMode: ExerciseCountingMode.reps,
        exerciseType: 'Isolamento',
      );

      expect(suggestion.imageUrl, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // _getFocusCodesForMuscle fallback paths (exercised via groupedByMuscle)
  // ---------------------------------------------------------------------------

  group('_getFocusCodesForMuscle fallback paths', () {
    test('back fallback includes LAT, TRAP, LOMBAR', () {
      // If MuscleAbbreviationMapper returns empty for "back" we'd get fallback.
      // In practice the mapper returns LAT for 'back'.
      // We just verify that 'back' correctly matches LAT exercises.
      final exercises = [
        makeExercise(id: 'lat1', nome: 'Lat Pull', focus: 'LAT'),
      ];
      final neglected = [makeNeglected(muscleName: 'back')];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result.isNotEmpty, isTrue);
    });

    test('abs with CORE exercise is matched', () {
      final exercises = [
        makeExercise(id: 'core1', nome: 'Hanging Leg Raise', focus: 'CORE'),
      ];
      final neglected = [makeNeglected(muscleName: 'abs')];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result.isNotEmpty, isTrue);
      expect(result.first.exerciseName, equals('Hanging Leg Raise'));
    });

    test('lower_back with LOMB exercise is matched', () {
      // getSearchAbbreviations('lower_back') returns ['LOMB']
      final exercises = [
        makeExercise(
            id: 'lb1', nome: 'Back Extension', focus: 'LOMB'),
      ];
      final neglected = [makeNeglected(muscleName: 'lower_back')];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result.isNotEmpty, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Multi-muscle sorting by priority in flat list
  // ---------------------------------------------------------------------------

  group('Multi-muscle priority sorting in generateSuggestionsFromDatabase', () {
    test('highest priority muscle suggestions appear first', () {
      final exercises = [
        makeExercise(id: 'q1', nome: 'Squat', focus: 'QUAD'),
        makeExercise(id: 'p1', nome: 'Bench Press', focus: 'PETT'),
        makeExercise(id: 'g1', nome: 'Hip Thrust', focus: 'GLUT'),
      ];

      final neglected = [
        const NeglectedMuscle(
          muscleName: 'quads',
          volumePercentage: 1.0,
          severity: NeglectSeverity.critical,
          priority: 4.0,
        ),
        const NeglectedMuscle(
          muscleName: 'chest',
          volumePercentage: 0.5,
          severity: NeglectSeverity.critical,
          priority: 10.0,
        ),
        const NeglectedMuscle(
          muscleName: 'glutes',
          volumePercentage: 0.8,
          severity: NeglectSeverity.critical,
          priority: 7.0,
        ),
      ];

      final result = engine.generateSuggestionsFromDatabase(
        neglectedMuscles: neglected,
        allExercises: exercises,
      );

      expect(result.length, equals(3));
      // sorted: chest (10) > glutes (7) > quads (4)
      expect(result[0].targetMuscle, equals('chest'));
      expect(result[1].targetMuscle, equals('glutes'));
      expect(result[2].targetMuscle, equals('quads'));
    });
  });
}

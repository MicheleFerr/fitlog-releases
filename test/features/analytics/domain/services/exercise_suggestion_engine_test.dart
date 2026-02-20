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

  /// Helper: create a minimal ExerciseDefinition
  ExerciseDefinition makeExercise({
    required String id,
    required String nome,
    required String focus,
    String tipoEsercizio = 'Compound',
    String countingMode = 'weighted',
  }) {
    return ExerciseDefinition(
      id: id,
      nome: nome,
      focus: [focus],
      muscoliSecondari: const [],
      difficolta: 'Intermedio',
      tipoEsercizio: tipoEsercizio,
      attrezzatura: 'Bilanciere',
      patternMovimento: 'Squat',
      rangeRipetizioni: '6-10',
      countingMode: ExerciseCountingMode.fromString(countingMode),
    );
  }

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
        // User has "Squat con Bilanciere" in template
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

        // "Squat con Bilanciere" should be excluded (exact match)
        final names = result['quads']!.map((s) => s.exerciseName).toList();
        expect(names, isNot(contains('Squat con Bilanciere')));
        // "Front Squat con Bilanciere" should NOT be excluded
        expect(names, contains('Front Squat con Bilanciere'));
      },
    );

    test('should not over-exclude exercises with substring matching', () {
      // User has only "Squat con Bilanciere" in template
      final excludeSet = {'Squat con Bilanciere', 'squat_bilanciere'};

      final result = engine.generateSuggestionsGroupedByMuscle(
        neglectedMuscles: neglectedQuads,
        allExercises: quadExercises,
        excludeExercises: excludeSet,
      );

      // Should have 4 suggestions (all except the excluded one)
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
  });

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
      // User has "Hip Thrust con Bilanciere" in template
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
  });
}

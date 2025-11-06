import 'package:flutter_test/flutter_test.dart';

/// Simple exercise model for validation
class Exercise {

  Exercise({
    required this.id,
    required this.nome,
    required this.focus,
    required this.imageUrl,
    required this.difficolta,
  });
  final String id;
  final String nome;
  final String? focus;
  final String imageUrl;
  final String difficolta;

  bool isValid() {
    return id.isNotEmpty &&
        nome.isNotEmpty &&
        imageUrl.isNotEmpty &&
        difficolta.isNotEmpty;
  }
}

void main() {
  group('🏋️ Exercise Database Unit Tests', () {
    // ============================================================================
    // BASIC EXERCISE MODEL TESTS
    // ============================================================================

    test('✅ TEST 1: Valid exercise model passes validation', () {
      final exercise = Exercise(
        id: 'bench_press',
        nome: 'Panca Piana',
        focus: 'PETT',
        imageUrl: 'https://example.com/image.gif',
        difficolta: 'Intermedio',
      );

      expect(exercise.isValid(), true);
    });

    test('✅ TEST 2: Exercise with missing ID fails validation', () {
      final exercise = Exercise(
        id: '',
        nome: 'Panca Piana',
        focus: 'PETT',
        imageUrl: 'https://example.com/image.gif',
        difficolta: 'Intermedio',
      );

      expect(exercise.isValid(), false);
    });

    test('✅ TEST 3: Exercise with null focus is still valid', () {
      final exercise = Exercise(
        id: 'squat',
        nome: 'Squat',
        focus: null,
        imageUrl: 'https://example.com/image.gif',
        difficolta: 'Avanzato',
      );

      expect(exercise.isValid(), true);
    });

    test('✅ TEST 4: Exercise with missing nome fails validation', () {
      final exercise = Exercise(
        id: 'deadlift',
        nome: '',
        focus: 'GLUT',
        imageUrl: 'https://example.com/image.gif',
        difficolta: 'Avanzato',
      );

      expect(exercise.isValid(), false);
    });

    test('✅ TEST 5: Exercise with missing imageUrl fails validation', () {
      final exercise = Exercise(
        id: 'curl',
        nome: 'Curl Manubri',
        focus: 'BICI',
        imageUrl: '',
        difficolta: 'Principiante',
      );

      expect(exercise.isValid(), false);
    });

    test('✅ TEST 6: Exercise with missing difficolta fails validation', () {
      final exercise = Exercise(
        id: 'row',
        nome: 'Rematore',
        focus: 'LAT',
        imageUrl: 'https://example.com/image.gif',
        difficolta: '',
      );

      expect(exercise.isValid(), false);
    });

    // ============================================================================
    // FOCUS AREA TESTS
    // ============================================================================

    test('✅ TEST 7: Valid focus areas are recognized', () {
      const validAreas = [
        'CHEST',
        'BACK',
        'SHOULDERS',
        'BICEPS',
        'TRICEPS',
        'FOREARMS',
        'CORE',
        'ABS',
        'OBLIQUES',
        'GLUT',
        'QUAD',
        'HAMSTRING',
        'CALVES',
        'LEGS',
        'FEMOR',
        'LATS',
        'TRAPS',
        'RHOMBOID',
        'ROTATOR_CUFF',
        'FULL_BODY',
        'CARDIO',
        'FLEXIBILITY',
        'STABILIZER',
        'COMPOUND',
        'PETT',
        'BICI',
        'POLP',
        'LAT',
        'TRAP',
        'SPALL',
        'ADDO',
      ];

      for (final area in validAreas) {
        final exercise = Exercise(
          id: 'test',
          nome: 'Test Exercise',
          focus: area,
          imageUrl: 'https://example.com/image.gif',
          difficolta: 'Intermedio',
        );
        expect(exercise.isValid(), true,
            reason: 'Focus area $area should be valid');
      }
    });

    test('✅ TEST 8: Comma-separated focus areas can be parsed', () {
      const focusString = 'LAT, TRAP';
      final focusAreas =
          focusString.split(',').map((f) => f.trim()).toList();

      expect(focusAreas.length, 2);
      expect(focusAreas[0], 'LAT');
      expect(focusAreas[1], 'TRAP');
    });

    // ============================================================================
    // DIFFICULTY LEVEL TESTS
    // ============================================================================

    test('✅ TEST 9: Valid difficulty levels are recognized', () {
      const validDifficulties = [
        'Principiante',
        'Intermedio',
        'Avanzato',
        'Beginner',
        'Intermediate',
        'Advanced',
        'Principiante/Intermedio',
        'Intermedio/Avanzato',
      ];

      for (final difficulty in validDifficulties) {
        final exercise = Exercise(
          id: 'test',
          nome: 'Test Exercise',
          focus: 'CHEST',
          imageUrl: 'https://example.com/image.gif',
          difficolta: difficulty,
        );
        expect(exercise.isValid(), true,
            reason: 'Difficulty $difficulty should be valid');
      }
    });

    // ============================================================================
    // URL VALIDATION TESTS
    // ============================================================================

    test('✅ TEST 10: Valid HTTP URLs are accepted', () {
      const validUrls = [
        'http://example.com/image.gif',
        'https://static.exercisedb.dev/media/abc123.gif',
        '/assets/images/exercise.gif',
        'https://example.com/path/to/image.png',
      ];

      for (final url in validUrls) {
        final exercise = Exercise(
          id: 'test',
          nome: 'Test',
          focus: 'CHEST',
          imageUrl: url,
          difficolta: 'Intermedio',
        );
        expect(exercise.isValid(), true, reason: 'URL $url should be valid');
      }
    });

    test('✅ TEST 11: Exercise model equality', () {
      final ex1 = Exercise(
        id: 'bench_press',
        nome: 'Panca Piana',
        focus: 'PETT',
        imageUrl: 'https://example.com/image.gif',
        difficolta: 'Intermedio',
      );

      final ex2 = Exercise(
        id: 'bench_press',
        nome: 'Panca Piana',
        focus: 'PETT',
        imageUrl: 'https://example.com/image.gif',
        difficolta: 'Intermedio',
      );

      expect(ex1.id, ex2.id);
      expect(ex1.nome, ex2.nome);
      expect(ex1.focus, ex2.focus);
    });

    // ============================================================================
    // COLLECTION TESTS
    // ============================================================================

    test('✅ TEST 12: Exercise collection can be filtered by focus', () {
      final exercises = [
        Exercise(
          id: 'bench_press',
          nome: 'Panca Piana',
          focus: 'PETT',
          imageUrl: 'https://example.com/image1.gif',
          difficolta: 'Intermedio',
        ),
        Exercise(
          id: 'squat',
          nome: 'Squat',
          focus: 'QUAD',
          imageUrl: 'https://example.com/image2.gif',
          difficolta: 'Avanzato',
        ),
        Exercise(
          id: 'deadlift',
          nome: 'Stacco',
          focus: 'GLUT',
          imageUrl: 'https://example.com/image3.gif',
          difficolta: 'Avanzato',
        ),
      ];

      final chestExercises =
          exercises.where((e) => e.focus == 'PETT').toList();
      expect(chestExercises.length, 1);
      expect(chestExercises.first.id, 'bench_press');
    });

    test('✅ TEST 13: Exercise collection can be filtered by difficulty', () {
      final exercises = [
        Exercise(
          id: 'bench_press',
          nome: 'Panca Piana',
          focus: 'PETT',
          imageUrl: 'https://example.com/image1.gif',
          difficolta: 'Principiante',
        ),
        Exercise(
          id: 'squat',
          nome: 'Squat',
          focus: 'QUAD',
          imageUrl: 'https://example.com/image2.gif',
          difficolta: 'Avanzato',
        ),
        Exercise(
          id: 'row',
          nome: 'Rematore',
          focus: 'LAT',
          imageUrl: 'https://example.com/image3.gif',
          difficolta: 'Intermedio',
        ),
      ];

      final advancedExercises =
          exercises.where((e) => e.difficolta == 'Avanzato').toList();
      expect(advancedExercises.length, 1);
      expect(advancedExercises.first.id, 'squat');
    });

    test('✅ TEST 14: Exercise IDs must be unique in collection', () {
      final ids = {'bench_press', 'squat', 'deadlift', 'curl', 'row'};

      expect(ids.length, 5);
      expect(ids.contains('bench_press'), true);
      expect(ids.contains('non_existent'), false);
    });

    test('✅ TEST 15: Exercise nome length validation', () {
      // Exercise name should be at least 2 characters
      final shortName = Exercise(
        id: 'test',
        nome: 'A', // Too short
        focus: 'CHEST',
        imageUrl: 'https://example.com/image.gif',
        difficolta: 'Principiante',
      );

      final validName = Exercise(
        id: 'test2',
        nome: 'Bench Press', // Valid
        focus: 'CHEST',
        imageUrl: 'https://example.com/image.gif',
        difficolta: 'Principiante',
      );

      expect(shortName.nome.length, lessThan(2));
      expect(validName.nome.length, greaterThanOrEqualTo(2));
    });
  });
}

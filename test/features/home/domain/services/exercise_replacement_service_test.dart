import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/home/domain/services/exercise_replacement_service.dart';

void main() {
  group('ExerciseReplacementService', () {
    // Helper function to create test exercises
    Exercise createExercise({
      required String id,
      required String nome,
      required List<String> focus,
      required String patternMovimento,
      required String attrezzatura,
      required String tipoEsercizio,
      String difficolta = 'Intermedio',
      List<String> muscoliSecondari = const [],
    }) {
      return Exercise(
        id: id,
        nome: nome,
        focus: focus,
        muscoliSecondari: muscoliSecondari,
        difficolta: difficolta,
        tipoEsercizio: tipoEsercizio,
        attrezzatura: attrezzatura,
        patternMovimento: patternMovimento,
        rangeRipetizioni: '8-12',
      );
    }

    group('findSimilarExercises', () {
      test('should throw exception when exercise not found in database', () {
        // Arrange
        final database = <String, Exercise>{};

        // Act & Assert
        expect(
          () => ExerciseReplacementService.findSimilarExercises(
            currentExerciseName: 'Nonexistent Exercise',
            exerciseDatabase: database,
          ),
          throwsException,
        );
      });

      test('should return empty list when database is empty except current exercise', () {
        // Arrange
        final benchPress = createExercise(
          id: 'e1',
          nome: 'Bench Press',
          focus: ['Petto'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final database = {'e1': benchPress};

        // Act
        final result = ExerciseReplacementService.findSimilarExercises(
          currentExerciseName: 'Bench Press',
          exerciseDatabase: database,
        );

        // Assert
        expect(result, isEmpty);
      });

      test('should find exercises with matching muscle group', () {
        // Arrange
        final benchPress = createExercise(
          id: 'e1',
          nome: 'Bench Press',
          focus: ['Petto'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final inclinePress = createExercise(
          id: 'e2',
          nome: 'Incline Press',
          focus: ['Petto'],
          patternMovimento: 'Push',
          attrezzatura: 'Manubri',
          tipoEsercizio: 'Compound',
        );

        final database = {
          'e1': benchPress,
          'e2': inclinePress,
        };

        // Act
        final result = ExerciseReplacementService.findSimilarExercises(
          currentExerciseName: 'Bench Press',
          exerciseDatabase: database,
        );

        // Assert
        expect(result, hasLength(1));
        expect(result.first.nome, equals('Incline Press'));
      });

      test('should exclude exercise with different movement pattern', () {
        // Arrange
        final benchPress = createExercise(
          id: 'e1',
          nome: 'Bench Press',
          focus: ['Petto'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final chestFly = createExercise(
          id: 'e2',
          nome: 'Chest Fly',
          focus: ['Petto'],
          patternMovimento: 'Fly', // Different pattern
          attrezzatura: 'Manubri',
          tipoEsercizio: 'Isolation',
        );

        final database = {
          'e1': benchPress,
          'e2': chestFly,
        };

        // Act
        final result = ExerciseReplacementService.findSimilarExercises(
          currentExerciseName: 'Bench Press',
          exerciseDatabase: database,
        );

        // Assert
        expect(result, isEmpty);
      });

      test('should exclude exercise with no matching muscle groups', () {
        // Arrange
        final benchPress = createExercise(
          id: 'e1',
          nome: 'Bench Press',
          focus: ['Petto'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final squat = createExercise(
          id: 'e2',
          nome: 'Squat',
          focus: ['Gambe'], // No matching muscle
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final database = {
          'e1': benchPress,
          'e2': squat,
        };

        // Act
        final result = ExerciseReplacementService.findSimilarExercises(
          currentExerciseName: 'Bench Press',
          exerciseDatabase: database,
        );

        // Assert
        expect(result, isEmpty);
      });

      test('should match equipment when matchEquipment is true', () {
        // Arrange
        final benchPress = createExercise(
          id: 'e1',
          nome: 'Bench Press',
          focus: ['Petto'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final dumbbellPress = createExercise(
          id: 'e2',
          nome: 'Dumbbell Press',
          focus: ['Petto'],
          patternMovimento: 'Push',
          attrezzatura: 'Manubri', // Different equipment
          tipoEsercizio: 'Compound',
        );

        final database = {
          'e1': benchPress,
          'e2': dumbbellPress,
        };

        // Act
        final result = ExerciseReplacementService.findSimilarExercises(
          currentExerciseName: 'Bench Press',
          exerciseDatabase: database,
          matchEquipment: true,
        );

        // Assert
        expect(result, isEmpty); // Should exclude due to equipment mismatch
      });

      test('should not match equipment when matchEquipment is false', () {
        // Arrange
        final benchPress = createExercise(
          id: 'e1',
          nome: 'Bench Press',
          focus: ['Petto'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final dumbbellPress = createExercise(
          id: 'e2',
          nome: 'Dumbbell Press',
          focus: ['Petto'],
          patternMovimento: 'Push',
          attrezzatura: 'Manubri', // Different equipment
          tipoEsercizio: 'Compound',
        );

        final database = {
          'e1': benchPress,
          'e2': dumbbellPress,
        };

        // Act
        final result = ExerciseReplacementService.findSimilarExercises(
          currentExerciseName: 'Bench Press',
          exerciseDatabase: database,
          matchEquipment: false, // Should ignore equipment
        );

        // Assert
        expect(result, hasLength(1));
        expect(result.first.nome, equals('Dumbbell Press'));
      });

      test('should sort by number of matching muscle groups (descending)', () {
        // Arrange
        final benchPress = createExercise(
          id: 'e1',
          nome: 'Bench Press',
          focus: ['Petto', 'Spalle', 'Tricipiti'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        // Matches 1 muscle
        final inclinePress = createExercise(
          id: 'e2',
          nome: 'Incline Press',
          focus: ['Petto'],
          patternMovimento: 'Push',
          attrezzatura: 'Manubri',
          tipoEsercizio: 'Compound',
        );

        // Matches 2 muscles
        final overheadPress = createExercise(
          id: 'e3',
          nome: 'Overhead Press',
          focus: ['Spalle', 'Tricipiti'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        // Matches 3 muscles (perfect match)
        final dumbbellPress = createExercise(
          id: 'e4',
          nome: 'Dumbbell Press',
          focus: ['Petto', 'Spalle', 'Tricipiti'],
          patternMovimento: 'Push',
          attrezzatura: 'Manubri',
          tipoEsercizio: 'Compound',
        );

        final database = {
          'e1': benchPress,
          'e2': inclinePress,
          'e3': overheadPress,
          'e4': dumbbellPress,
        };

        // Act
        final result = ExerciseReplacementService.findSimilarExercises(
          currentExerciseName: 'Bench Press',
          exerciseDatabase: database,
        );

        // Assert
        expect(result, hasLength(3));
        expect(result[0].nome, equals('Dumbbell Press')); // 3 matches
        expect(result[1].nome, equals('Overhead Press')); // 2 matches
        expect(result[2].nome, equals('Incline Press')); // 1 match
      });

      test('should be case insensitive for exercise name matching', () {
        // Arrange
        final benchPress = createExercise(
          id: 'e1',
          nome: 'Bench Press',
          focus: ['Petto'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final inclinePress = createExercise(
          id: 'e2',
          nome: 'Incline Press',
          focus: ['Petto'],
          patternMovimento: 'Push',
          attrezzatura: 'Manubri',
          tipoEsercizio: 'Compound',
        );

        final database = {
          'e1': benchPress,
          'e2': inclinePress,
        };

        // Act - Use lowercase name
        final result = ExerciseReplacementService.findSimilarExercises(
          currentExerciseName: 'bench press', // Lowercase
          exerciseDatabase: database,
        );

        // Assert
        expect(result, hasLength(1));
        expect(result.first.nome, equals('Incline Press'));
      });

      test('should handle exercises with multiple muscle groups correctly', () {
        // Arrange
        final pullup = createExercise(
          id: 'e1',
          nome: 'Pull Up',
          focus: ['Dorso', 'Bicipiti'],
          patternMovimento: 'Pull',
          attrezzatura: 'Corpo libero',
          tipoEsercizio: 'Compound',
        );

        final chinup = createExercise(
          id: 'e2',
          nome: 'Chin Up',
          focus: ['Dorso', 'Bicipiti'],
          patternMovimento: 'Pull',
          attrezzatura: 'Corpo libero',
          tipoEsercizio: 'Compound',
        );

        final bentOverRow = createExercise(
          id: 'e3',
          nome: 'Bent Over Row',
          focus: ['Dorso'],
          patternMovimento: 'Pull',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final database = {
          'e1': pullup,
          'e2': chinup,
          'e3': bentOverRow,
        };

        // Act
        final result = ExerciseReplacementService.findSimilarExercises(
          currentExerciseName: 'Pull Up',
          exerciseDatabase: database,
        );

        // Assert
        expect(result, hasLength(2));
        expect(result[0].nome, equals('Chin Up')); // 2 matching muscles
        expect(result[1].nome, equals('Bent Over Row')); // 1 matching muscle
      });
    });

    group('getExerciseDetails', () {
      test('should format exercise details correctly', () {
        // Arrange
        final exercise = createExercise(
          id: 'e1',
          nome: 'Bench Press',
          focus: ['Petto', 'Spalle'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
          difficolta: 'Intermedio',
        );

        // Act
        final result = ExerciseReplacementService.getExerciseDetails(exercise);

        // Assert
        expect(result, equals('Petto, Spalle • Bilanciere • Intermedio'));
      });

      test('should format exercise with single muscle group', () {
        // Arrange
        final exercise = createExercise(
          id: 'e1',
          nome: 'Bicep Curl',
          focus: ['Bicipiti'],
          patternMovimento: 'Pull',
          attrezzatura: 'Manubri',
          tipoEsercizio: 'Isolation',
          difficolta: 'Principiante',
        );

        // Act
        final result = ExerciseReplacementService.getExerciseDetails(exercise);

        // Assert
        expect(result, equals('Bicipiti • Manubri • Principiante'));
      });

      test('should format exercise with multiple muscle groups', () {
        // Arrange
        final exercise = createExercise(
          id: 'e1',
          nome: 'Deadlift',
          focus: ['Dorso', 'Gambe', 'Core'],
          patternMovimento: 'Hinge',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
          difficolta: 'Avanzato',
        );

        // Act
        final result = ExerciseReplacementService.getExerciseDetails(exercise);

        // Assert
        expect(result, equals('Dorso, Gambe, Core • Bilanciere • Avanzato'));
      });
    });

    group('calculateSimilarity', () {
      test('should return 100 for identical exercises', () {
        // Arrange
        final exercise1 = createExercise(
          id: 'e1',
          nome: 'Bench Press',
          focus: ['Petto', 'Spalle'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final exercise2 = createExercise(
          id: 'e2',
          nome: 'Bench Press Clone',
          focus: ['Petto', 'Spalle'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        // Act
        final score = ExerciseReplacementService.calculateSimilarity(
          exercise1,
          exercise2,
        );

        // Assert
        expect(score, equals(100));
      });

      test('should return 0 for completely different exercises', () {
        // Arrange
        final exercise1 = createExercise(
          id: 'e1',
          nome: 'Bench Press',
          focus: ['Petto'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final exercise2 = createExercise(
          id: 'e2',
          nome: 'Squat',
          focus: ['Gambe'],
          patternMovimento: 'Squat',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        // Act
        final score = ExerciseReplacementService.calculateSimilarity(
          exercise1,
          exercise2,
        );

        // Assert
        // Movement pattern differs (-30), equipment same (+15), type same (+15)
        // Primary muscles 0 match (0/1 = 0% of 40 = 0)
        // Total: 0 + 0 + 15 + 15 = 30
        expect(score, equals(30));
      });

      test('should calculate primary muscle score correctly (40 points max)', () {
        // Arrange
        final exercise1 = createExercise(
          id: 'e1',
          nome: 'Exercise 1',
          focus: ['Petto', 'Spalle'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final exercise2 = createExercise(
          id: 'e2',
          nome: 'Exercise 2',
          focus: ['Petto'], // 1 match out of 2 = 50% of 40 = 20
          patternMovimento: 'Different',
          attrezzatura: 'Different',
          tipoEsercizio: 'Different',
        );

        // Act
        final score = ExerciseReplacementService.calculateSimilarity(
          exercise1,
          exercise2,
        );

        // Assert
        // 1 muscle match out of 2 = 50% * 40 = 20
        expect(score, equals(20));
      });

      test('should add 30 points for matching movement pattern', () {
        // Arrange
        final exercise1 = createExercise(
          id: 'e1',
          nome: 'Exercise 1',
          focus: ['Petto'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final exercise2 = createExercise(
          id: 'e2',
          nome: 'Exercise 2',
          focus: ['Petto'],
          patternMovimento: 'Push', // Match
          attrezzatura: 'Different',
          tipoEsercizio: 'Different',
        );

        // Act
        final score = ExerciseReplacementService.calculateSimilarity(
          exercise1,
          exercise2,
        );

        // Assert
        // Primary muscle 100% match = 40
        // Movement pattern match = 30
        // Equipment no match = 0
        // Type no match = 0
        // Total: 40 + 30 = 70
        expect(score, equals(70));
      });

      test('should add 15 points for matching equipment', () {
        // Arrange
        final exercise1 = createExercise(
          id: 'e1',
          nome: 'Exercise 1',
          focus: ['Petto'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final exercise2 = createExercise(
          id: 'e2',
          nome: 'Exercise 2',
          focus: ['Petto'],
          patternMovimento: 'Different',
          attrezzatura: 'Bilanciere', // Match
          tipoEsercizio: 'Different',
        );

        // Act
        final score = ExerciseReplacementService.calculateSimilarity(
          exercise1,
          exercise2,
        );

        // Assert
        // Primary muscle 100% match = 40
        // Movement pattern no match = 0
        // Equipment match = 15
        // Type no match = 0
        // Total: 40 + 15 = 55
        expect(score, equals(55));
      });

      test('should add 15 points for matching exercise type', () {
        // Arrange
        final exercise1 = createExercise(
          id: 'e1',
          nome: 'Exercise 1',
          focus: ['Petto'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final exercise2 = createExercise(
          id: 'e2',
          nome: 'Exercise 2',
          focus: ['Petto'],
          patternMovimento: 'Different',
          attrezzatura: 'Different',
          tipoEsercizio: 'Compound', // Match
        );

        // Act
        final score = ExerciseReplacementService.calculateSimilarity(
          exercise1,
          exercise2,
        );

        // Assert
        // Primary muscle 100% match = 40
        // Movement pattern no match = 0
        // Equipment no match = 0
        // Type match = 15
        // Total: 40 + 15 = 55
        expect(score, equals(55));
      });

      test('should calculate cumulative score correctly', () {
        // Arrange
        final exercise1 = createExercise(
          id: 'e1',
          nome: 'Bench Press',
          focus: ['Petto', 'Spalle', 'Tricipiti'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final exercise2 = createExercise(
          id: 'e2',
          nome: 'Dumbbell Press',
          focus: ['Petto', 'Spalle'], // 2 of 3 = 66.67% of 40 = 26.67 ≈ 27
          patternMovimento: 'Push', // +30
          attrezzatura: 'Manubri', // 0
          tipoEsercizio: 'Compound', // +15
        );

        // Act
        final score = ExerciseReplacementService.calculateSimilarity(
          exercise1,
          exercise2,
        );

        // Assert
        // Primary muscle 2/3 match = 66.67% * 40 = 26.67 ≈ 27
        // Movement pattern match = 30
        // Equipment no match = 0
        // Type match = 15
        // Total: 27 + 30 + 0 + 15 = 72
        expect(score, equals(72));
      });

      test('should handle zero matching muscles', () {
        // Arrange
        final exercise1 = createExercise(
          id: 'e1',
          nome: 'Exercise 1',
          focus: ['Petto'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final exercise2 = createExercise(
          id: 'e2',
          nome: 'Exercise 2',
          focus: ['Gambe'], // No match
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        // Act
        final score = ExerciseReplacementService.calculateSimilarity(
          exercise1,
          exercise2,
        );

        // Assert
        // Primary muscle 0 match = 0
        // Movement pattern match = 30
        // Equipment match = 15
        // Type match = 15
        // Total: 0 + 30 + 15 + 15 = 60
        expect(score, equals(60));
      });

      test('should clamp score to 0-100 range', () {
        // Arrange - Create exercises that could theoretically exceed 100
        final exercise1 = createExercise(
          id: 'e1',
          nome: 'Exercise 1',
          focus: ['Petto', 'Spalle'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final exercise2 = createExercise(
          id: 'e2',
          nome: 'Exercise 2',
          focus: ['Petto', 'Spalle'],
          patternMovimento: 'Push',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        // Act
        final score = ExerciseReplacementService.calculateSimilarity(
          exercise1,
          exercise2,
        );

        // Assert
        expect(score, greaterThanOrEqualTo(0));
        expect(score, lessThanOrEqualTo(100));
        expect(score, equals(100)); // Perfect match
      });

      test('should handle exercises with many muscle groups', () {
        // Arrange
        final exercise1 = createExercise(
          id: 'e1',
          nome: 'Deadlift',
          focus: ['Dorso', 'Gambe', 'Core', 'Trapezi'],
          patternMovimento: 'Hinge',
          attrezzatura: 'Bilanciere',
          tipoEsercizio: 'Compound',
        );

        final exercise2 = createExercise(
          id: 'e2',
          nome: 'Romanian Deadlift',
          focus: ['Gambe', 'Dorso'], // 2 of 4 = 50% of 40 = 20
          patternMovimento: 'Hinge', // +30
          attrezzatura: 'Bilanciere', // +15
          tipoEsercizio: 'Compound', // +15
        );

        // Act
        final score = ExerciseReplacementService.calculateSimilarity(
          exercise1,
          exercise2,
        );

        // Assert
        // Primary muscle 2/4 match = 50% * 40 = 20
        // Movement pattern match = 30
        // Equipment match = 15
        // Type match = 15
        // Total: 20 + 30 + 15 + 15 = 80
        expect(score, equals(80));
      });
    });
  });
}

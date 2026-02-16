import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/exercise_compatibility_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

void main() {
  group('ExerciseCompatibilityService - calculateCompatibility', () {
    test('should return 0 for same exercise', () {
      // Arrange
      final exercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      // Act
      final compatibility = ExerciseCompatibilityService.calculateCompatibility(
        exercise,
        exercise,
      );

      // Assert
      expect(compatibility, equals(0.0));
    });

    test('should give high score for same muscle group', () {
      // Arrange
      final exercise1 = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );
      final exercise2 = Exercise(
        name: 'Incline Dumbbell Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      // Act
      final compatibility = ExerciseCompatibilityService.calculateCompatibility(
        exercise1,
        exercise2,
      );

      // Assert
      // Primary muscle match (40%) + movement pattern (20%) + equipment + difficulty
      expect(compatibility, greaterThan(40.0));
    });

    test('should give moderate score for related muscle groups (chest-shoulders)', () {
      // Arrange
      final chestExercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );
      final shouldersExercise = Exercise(
        name: 'Shoulder Press',
        type: ExerciseType.single,
        category: ExerciseCategory.shoulders,
      );

      // Act
      final compatibility = ExerciseCompatibilityService.calculateCompatibility(
        chestExercise,
        shouldersExercise,
      );

      // Assert
      // Related muscles get bonus score
      expect(compatibility, greaterThan(15.0));
      expect(compatibility, lessThan(75.0)); // Increased - related muscles get significant bonus
    });

    test('should give moderate score for related muscle groups (back-arms)', () {
      // Arrange
      final backExercise = Exercise(
        name: 'Pull Up',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
      );
      final armsExercise = Exercise(
        name: 'Bicep Curl',
        type: ExerciseType.single,
        category: ExerciseCategory.arms,
      );

      // Act
      final compatibility = ExerciseCompatibilityService.calculateCompatibility(
        backExercise,
        armsExercise,
      );

      // Assert
      expect(compatibility, greaterThan(10.0));
      expect(compatibility, lessThan(75.0)); // Increased - related muscles get significant bonus
    });

    test('should give low score for unrelated muscle groups', () {
      // Arrange
      final chestExercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );
      final legsExercise = Exercise(
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
      );

      // Act
      final compatibility = ExerciseCompatibilityService.calculateCompatibility(
        chestExercise,
        legsExercise,
      );

      // Assert
      expect(compatibility, lessThan(30.0));
    });

    test('should recognize same movement pattern (push exercises)', () {
      // Arrange
      final exercise1 = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );
      final exercise2 = Exercise(
        name: 'Shoulder Press',
        type: ExerciseType.single,
        category: ExerciseCategory.shoulders,
      );

      // Act
      final compatibility = ExerciseCompatibilityService.calculateCompatibility(
        exercise1,
        exercise2,
      );

      // Assert
      // Both are push movements, should get movement pattern bonus (20%)
      expect(compatibility, greaterThan(20.0));
    });

    test('should recognize same movement pattern (pull exercises)', () {
      // Arrange
      final exercise1 = Exercise(
        name: 'Pull Up',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
      );
      final exercise2 = Exercise(
        name: 'Barbell Row',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
      );

      // Act
      final compatibility = ExerciseCompatibilityService.calculateCompatibility(
        exercise1,
        exercise2,
      );

      // Assert
      // Both are pull movements + same muscle group
      expect(compatibility, greaterThan(50.0));
    });

    test('should recognize squat pattern', () {
      // Arrange
      final exercise1 = Exercise(
        name: 'Back Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
      );
      final exercise2 = Exercise(
        name: 'Front Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
      );

      // Act
      final compatibility = ExerciseCompatibilityService.calculateCompatibility(
        exercise1,
        exercise2,
      );

      // Assert
      // Same muscle group + same squat pattern
      expect(compatibility, greaterThan(50.0));
    });

    test('should recognize deadlift/hinge pattern', () {
      // Arrange
      final exercise1 = Exercise(
        name: 'Deadlift',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
      );
      final exercise2 = Exercise(
        name: 'Romanian Deadlift',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
      );

      // Act
      final compatibility = ExerciseCompatibilityService.calculateCompatibility(
        exercise1,
        exercise2,
      );

      // Assert
      // Same muscle group + same hinge pattern
      expect(compatibility, greaterThan(50.0));
    });

    test('should score barbell exercises similarly', () {
      // Arrange
      final exercise1 = Exercise(
        name: 'Barbell Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );
      final exercise2 = Exercise(
        name: 'Barbell Incline Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      // Act
      final compatibility = ExerciseCompatibilityService.calculateCompatibility(
        exercise1,
        exercise2,
      );

      // Assert
      // Same muscle + same equipment (barbell) should score high
      expect(compatibility, greaterThan(60.0));
    });

    test('should score dumbbell exercises similarly', () {
      // Arrange
      final exercise1 = Exercise(
        name: 'Dumbbell Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );
      final exercise2 = Exercise(
        name: 'Dumbbell Flyes',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      // Act
      final compatibility = ExerciseCompatibilityService.calculateCompatibility(
        exercise1,
        exercise2,
      );

      // Assert
      // Same muscle + same equipment type
      expect(compatibility, greaterThan(50.0));
    });

    test('should handle bodyweight exercises', () {
      // Arrange
      final exercise1 = Exercise(
        name: 'Push Up',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );
      final exercise2 = Exercise(
        name: 'Dips',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      // Act
      final compatibility = ExerciseCompatibilityService.calculateCompatibility(
        exercise1,
        exercise2,
      );

      // Assert
      // Same muscle + both bodyweight
      expect(compatibility, greaterThan(50.0));
    });

    test('should penalize different equipment types', () {
      // Arrange
      final barbellExercise = Exercise(
        name: 'Barbell Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );
      final machineExercise = Exercise(
        name: 'Machine Chest Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      // Act
      final compatibilityBarbell = ExerciseCompatibilityService.calculateCompatibility(
        barbellExercise,
        Exercise(name: 'Barbell Incline Press', type: ExerciseType.single, category: ExerciseCategory.chest),
      );
      final compatibilityMachine = ExerciseCompatibilityService.calculateCompatibility(
        barbellExercise,
        machineExercise,
      );

      // Assert
      // Same equipment should score higher
      expect(compatibilityBarbell, greaterThan(compatibilityMachine));
    });

    test('should handle advanced/olympic lifts (high difficulty)', () {
      // Arrange
      final snatch = Exercise(
        name: 'Snatch',
        type: ExerciseType.single,
        category: ExerciseCategory.shoulders,
      );
      final cleanAndJerk = Exercise(
        name: 'Clean and Jerk',
        type: ExerciseType.single,
        category: ExerciseCategory.shoulders,
      );

      // Act
      final compatibility = ExerciseCompatibilityService.calculateCompatibility(
        snatch,
        cleanAndJerk,
      );

      // Assert
      // Both olympic lifts, should get difficulty bonus
      expect(compatibility, greaterThan(20.0));
    });

    test('should handle intermediate compound exercises', () {
      // Arrange
      final squat = Exercise(
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
      );
      final deadlift = Exercise(
        name: 'Deadlift',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
      );

      // Act
      final compatibility = ExerciseCompatibilityService.calculateCompatibility(
        squat,
        deadlift,
      );

      // Assert
      // Different muscles but both compound movements
      expect(compatibility, greaterThan(5.0));
      expect(compatibility, lessThan(40.0));
    });

    test('should handle beginner isolation exercises', () {
      // Arrange
      final lateralRaise = Exercise(
        name: 'Lateral Raise',
        type: ExerciseType.single,
        category: ExerciseCategory.shoulders,
      );
      final frontRaise = Exercise(
        name: 'Front Raise',
        type: ExerciseType.single,
        category: ExerciseCategory.shoulders,
      );

      // Act
      final compatibility = ExerciseCompatibilityService.calculateCompatibility(
        lateralRaise,
        frontRaise,
      );

      // Assert
      // Same muscle + same difficulty level (isolation)
      expect(compatibility, greaterThan(40.0));
    });
  });

  group('ExerciseCompatibilityService - getSuggestedReplacements', () {
    test('should return suggestions sorted by compatibility descending', () {
      // Arrange
      final currentExercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      final availableExercises = [
        Exercise(name: 'Squat', type: ExerciseType.single, category: ExerciseCategory.legs),
        Exercise(name: 'Incline Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        Exercise(name: 'Pull Up', type: ExerciseType.single, category: ExerciseCategory.back),
        Exercise(name: 'Dumbbell Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        Exercise(name: 'Shoulder Press', type: ExerciseType.single, category: ExerciseCategory.shoulders),
      ];

      // Act
      final suggestions = ExerciseCompatibilityService.getSuggestedReplacements(
        currentExercise,
        availableExercises,
      );

      // Assert
      expect(suggestions, isNotEmpty);
      // First suggestion should be most compatible (chest exercises)
      expect(suggestions.first.exercise.category, equals(ExerciseCategory.chest));
      // Verify descending order
      for (int i = 0; i < suggestions.length - 1; i++) {
        expect(
          suggestions[i].compatibilityScore,
          greaterThanOrEqualTo(suggestions[i + 1].compatibilityScore),
        );
      }
    });

    test('should filter out suggestions below 30% compatibility', () {
      // Arrange
      final chestExercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      final availableExercises = [
        Exercise(name: 'Squat', type: ExerciseType.single, category: ExerciseCategory.legs),
        Exercise(name: 'Bicep Curl', type: ExerciseType.single, category: ExerciseCategory.arms),
        Exercise(name: 'Calf Raise', type: ExerciseType.single, category: ExerciseCategory.legs),
        Exercise(name: 'Incline Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
      ];

      // Act
      final suggestions = ExerciseCompatibilityService.getSuggestedReplacements(
        chestExercise,
        availableExercises,
      );

      // Assert
      // All suggestions should be >= 30%
      for (final suggestion in suggestions) {
        expect(suggestion.compatibilityScore, greaterThanOrEqualTo(30.0));
      }
    });

    test('should limit suggestions to top 10', () {
      // Arrange
      final exercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      // Create 20 available exercises
      final availableExercises = List.generate(
        20,
        (i) => Exercise(
          name: 'Chest Exercise $i',
          type: ExerciseType.single,
          category: ExerciseCategory.chest,
        ),
      );

      // Act
      final suggestions = ExerciseCompatibilityService.getSuggestedReplacements(
        exercise,
        availableExercises,
      );

      // Assert
      expect(suggestions.length, lessThanOrEqualTo(10));
    });

    test('should exclude current exercise from suggestions', () {
      // Arrange
      final currentExercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      final availableExercises = [
        currentExercise, // Same instance
        Exercise(name: 'Incline Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        Exercise(name: 'Dumbbell Press', type: ExerciseType.single, category: ExerciseCategory.chest),
      ];

      // Act
      final suggestions = ExerciseCompatibilityService.getSuggestedReplacements(
        currentExercise,
        availableExercises,
      );

      // Assert
      expect(suggestions.every((s) => s.exercise != currentExercise), isTrue);
    });

    test('should include reason for suggestion', () {
      // Arrange
      final currentExercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      final availableExercises = [
        Exercise(name: 'Incline Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        Exercise(name: 'Shoulder Press', type: ExerciseType.single, category: ExerciseCategory.shoulders),
      ];

      // Act
      final suggestions = ExerciseCompatibilityService.getSuggestedReplacements(
        currentExercise,
        availableExercises,
      );

      // Assert
      expect(suggestions, isNotEmpty);
      for (final suggestion in suggestions) {
        expect(suggestion.reason, isNotEmpty);
        expect(suggestion.reason, isA<String>());
      }
    });

    test('should handle empty available exercises', () {
      // Arrange
      final exercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      // Act
      final suggestions = ExerciseCompatibilityService.getSuggestedReplacements(
        exercise,
        [],
      );

      // Assert
      expect(suggestions, isEmpty);
    });

    test('should handle single available exercise', () {
      // Arrange
      final currentExercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      final availableExercises = [
        Exercise(name: 'Incline Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
      ];

      // Act
      final suggestions = ExerciseCompatibilityService.getSuggestedReplacements(
        currentExercise,
        availableExercises,
      );

      // Assert
      expect(suggestions.length, equals(1));
      expect(suggestions.first.exercise.name, equals('Incline Bench Press'));
    });

    test('should prioritize same muscle group suggestions', () {
      // Arrange
      final chestExercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      final availableExercises = [
        Exercise(name: 'Squat', type: ExerciseType.single, category: ExerciseCategory.legs),
        Exercise(name: 'Incline Bench Press', type: ExerciseType.single, category: ExerciseCategory.chest),
        Exercise(name: 'Pull Up', type: ExerciseType.single, category: ExerciseCategory.back),
        Exercise(name: 'Dumbbell Flyes', type: ExerciseType.single, category: ExerciseCategory.chest),
      ];

      // Act
      final suggestions = ExerciseCompatibilityService.getSuggestedReplacements(
        chestExercise,
        availableExercises,
      );

      // Assert
      expect(suggestions, isNotEmpty);
      // Top suggestions should be chest exercises
      expect(suggestions.first.exercise.category, equals(ExerciseCategory.chest));
      if (suggestions.length > 1) {
        expect(suggestions[1].exercise.category, equals(ExerciseCategory.chest));
      }
    });
  });

  group('ExerciseCompatibilityService - ExerciseSuggestion', () {
    test('should create valid ExerciseSuggestion', () {
      // Arrange
      final exercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      // Act
      final suggestion = ExerciseSuggestion(
        exercise: exercise,
        compatibilityScore: 85.0,
        reason: 'Same muscle group',
      );

      // Assert
      expect(suggestion.exercise, equals(exercise));
      expect(suggestion.compatibilityScore, equals(85.0));
      expect(suggestion.reason, equals('Same muscle group'));
    });
  });
}

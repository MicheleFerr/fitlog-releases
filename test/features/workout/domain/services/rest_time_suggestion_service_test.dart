import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/rest_time_suggestion_service.dart';

void main() {
  group('RestTimeSuggestionService', () {
    late Exercise apreExercise;

    setUp(() {
      apreExercise = Exercise(
        id: 'test1',
        name: 'Bench Press',
        autoAdjustmentType: AutoAdjustmentType.apre,
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        sets: [],
      );
    });

    group('checkRestTimeSuggestion', () {
      test('should return null when auto adjust is disabled', () {
        // Act
        final result = RestTimeSuggestionService.checkRestTimeSuggestion(
          exercise: apreExercise,
          newWeight: 90,
          lastWeight: 100,
          currentRestTime: 120,
          autoAdjustEnabled: false,
        );

        // Assert
        expect(result, isNull);
      });

      test('should return null when exercise is not APRE', () {
        // Arrange
        final nonApreExercise = Exercise(
          id: 'test2',
          name: 'Squats',
          autoAdjustmentType: null, // Not APRE
          type: ExerciseType.single,
          category: ExerciseCategory.legs,
          sets: [],
        );

        // Act
        final result = RestTimeSuggestionService.checkRestTimeSuggestion(
          exercise: nonApreExercise,
          newWeight: 90,
          lastWeight: 100,
          currentRestTime: 120,
          autoAdjustEnabled: true,
        );

        // Assert
        expect(result, isNull);
      });

      test('should suggest +60s rest increase for >10% weight drop', () {
        // Act
        final result = RestTimeSuggestionService.checkRestTimeSuggestion(
          exercise: apreExercise,
          newWeight: 85, // 15% drop from 100
          lastWeight: 100,
          currentRestTime: 120,
          autoAdjustEnabled: true,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.type, equals(RestTimeSuggestionType.increase));
        expect(result.currentRestTime, equals(120));
        expect(result.suggestedRestTime, equals(180)); // 120 + 60
        expect(result.reason, contains('Peso ridotto')); // Service uses Italian hardcoded text
      });

      test('should suggest +30s rest increase for 5-10% weight drop', () {
        // Act
        final result = RestTimeSuggestionService.checkRestTimeSuggestion(
          exercise: apreExercise,
          newWeight: 93, // 7% drop from 100
          lastWeight: 100,
          currentRestTime: 120,
          autoAdjustEnabled: true,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.type, equals(RestTimeSuggestionType.increase));
        expect(result.currentRestTime, equals(120));
        expect(result.suggestedRestTime, equals(150)); // 120 + 30
      });

      test('should suggest +15s rest increase for <5% weight drop', () {
        // Act
        final result = RestTimeSuggestionService.checkRestTimeSuggestion(
          exercise: apreExercise,
          newWeight: 97, // 3% drop from 100
          lastWeight: 100,
          currentRestTime: 120,
          autoAdjustEnabled: true,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.type, equals(RestTimeSuggestionType.increase));
        expect(result.currentRestTime, equals(120));
        expect(result.suggestedRestTime, equals(135)); // 120 + 15
      });

      test('should suggest rest decrease when weight increases significantly', () {
        // Act
        final result = RestTimeSuggestionService.checkRestTimeSuggestion(
          exercise: apreExercise,
          newWeight: 115, // 15% increase from 100
          lastWeight: 100,
          currentRestTime: 120,
          autoAdjustEnabled: true,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.type, equals(RestTimeSuggestionType.decrease));
        expect(result.currentRestTime, equals(120));
        expect(result.suggestedRestTime, lessThan(120));
      });

      test('should return null when weight remains stable', () {
        // Act
        final result = RestTimeSuggestionService.checkRestTimeSuggestion(
          exercise: apreExercise,
          newWeight: 100,
          lastWeight: 100,
          currentRestTime: 120,
          autoAdjustEnabled: true,
        );

        // Assert
        expect(result, isNull);
      });

      test('should handle zero current rest time', () {
        // Act
        final result = RestTimeSuggestionService.checkRestTimeSuggestion(
          exercise: apreExercise,
          newWeight: 90,
          lastWeight: 100,
          currentRestTime: 0,
          autoAdjustEnabled: true,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.suggestedRestTime, greaterThan(0));
      });

      test('should calculate percentage drop correctly', () {
        // Act - 25% drop
        final result = RestTimeSuggestionService.checkRestTimeSuggestion(
          exercise: apreExercise,
          newWeight: 75,
          lastWeight: 100,
          currentRestTime: 120,
          autoAdjustEnabled: true,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.type, equals(RestTimeSuggestionType.increase));
        // Should suggest max increase for >10% drop
        expect(result.suggestedRestTime, equals(180));
      });

      test('should handle very small weight changes', () {
        // Act - 0.5% drop
        final result = RestTimeSuggestionService.checkRestTimeSuggestion(
          exercise: apreExercise,
          newWeight: 99.5,
          lastWeight: 100,
          currentRestTime: 120,
          autoAdjustEnabled: true,
        );

        // Assert
        expect(result, isNotNull);
        // Should still suggest minimum increase
        expect(result!.suggestedRestTime, equals(135)); // 120 + 15
      });

      test('should work with different base rest times', () {
        // Act
        final result1 = RestTimeSuggestionService.checkRestTimeSuggestion(
          exercise: apreExercise,
          newWeight: 90,
          lastWeight: 100,
          currentRestTime: 60,
          autoAdjustEnabled: true,
        );

        final result2 = RestTimeSuggestionService.checkRestTimeSuggestion(
          exercise: apreExercise,
          newWeight: 90,
          lastWeight: 100,
          currentRestTime: 180,
          autoAdjustEnabled: true,
        );

        // Assert
        expect(result1, isNotNull);
        expect(result2, isNotNull);
        expect(result1!.suggestedRestTime, equals(90)); // 60 + 30
        expect(result2!.suggestedRestTime, equals(210)); // 180 + 30
      });
    });

    group('RestTimeSuggestion model', () {
      test('should create increase suggestion correctly', () {
        // Arrange & Act
        final suggestion = RestTimeSuggestion(
          type: RestTimeSuggestionType.increase,
          currentRestTime: 120,
          suggestedRestTime: 150,
          reason: 'Performance dropped',
          weightDrop: 10.0,
        );

        // Assert
        expect(suggestion.type, equals(RestTimeSuggestionType.increase));
        expect(suggestion.currentRestTime, equals(120));
        expect(suggestion.suggestedRestTime, equals(150));
        expect(suggestion.reason, equals('Performance dropped'));
      });

      test('should create decrease suggestion correctly', () {
        // Arrange & Act
        final suggestion = RestTimeSuggestion(
          type: RestTimeSuggestionType.decrease,
          currentRestTime: 120,
          suggestedRestTime: 90,
          reason: 'Performance improved',
          weightDrop: 0.0,
        );

        // Assert
        expect(suggestion.type, equals(RestTimeSuggestionType.decrease));
        expect(suggestion.currentRestTime, equals(120));
        expect(suggestion.suggestedRestTime, equals(90));
        expect(suggestion.reason, equals('Performance improved'));
      });
    });
  });
}

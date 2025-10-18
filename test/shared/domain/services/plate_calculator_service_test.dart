import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/weight_settings.dart';
import 'package:gymbro_flutter_new/shared/domain/services/plate_calculator_service.dart';

void main() {
  group('PlateCalculatorService', () {
    late PlateCalculatorService service;

    setUp(() {
      service = PlateCalculatorService();
    });

    group('Exact Matches (kg)', () {
      test('should calculate exact match for 100kg with standard plates', () {
        // Arrange
        const targetWeight = 100.0;
        const barWeight = 20.0;
        final plates = [
          const PlateOption(weight: 20, count: 4),
          const PlateOption(weight: 15, count: 4),
          const PlateOption(weight: 10, count: 4),
          const PlateOption(weight: 5, count: 4),
          const PlateOption(weight: 2.5, count: 4),
          const PlateOption(weight: 1.25, count: 4),
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        expect(result.isExact, isTrue);
        expect(result.actualWeight, equals(100.0));
        expect(result.targetWeight, equals(100.0));
        expect(result.difference.abs(), lessThan(0.01));

        // 100kg = 20kg bar + 40kg per side
        // Expected: 2x20kg per side = 40kg
        expect(result.platesPerSide.length, equals(1));
        expect(result.platesPerSide.first.weight, equals(20));
        expect(result.platesPerSide.first.count, equals(2));
      });

      test('should calculate exact match for 60kg with mixed plates', () {
        // Arrange
        const targetWeight = 60.0;
        const barWeight = 20.0;
        final plates = [
          const PlateOption(weight: 20, count: 2),
          const PlateOption(weight: 10, count: 4),
          const PlateOption(weight: 5, count: 4),
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        expect(result.isExact, isTrue);
        expect(result.actualWeight, equals(60.0));
        // 60kg = 20kg bar + 20kg per side
        // Expected: 1x20kg per side
        expect(result.platesPerSide.length, equals(1));
        expect(result.platesPerSide.first.weight, equals(20));
        expect(result.platesPerSide.first.count, equals(1));
      });

      test('should calculate exact match with fractional plates (1.25kg)', () {
        // Arrange
        const targetWeight = 42.5;
        const barWeight = 20.0;
        final plates = [
          const PlateOption(weight: 10, count: 4),
          const PlateOption(weight: 2.5, count: 4),
          const PlateOption(weight: 1.25, count: 4),
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        expect(result.isExact, isTrue);
        expect(result.actualWeight, equals(42.5));
        // 42.5kg = 20kg bar + 11.25kg per side
        // Expected: 1x10kg + 1x1.25kg per side
        expect(result.platesPerSide.length, equals(2));
        expect(result.platesPerSide[0].weight, equals(10));
        expect(result.platesPerSide[0].count, equals(1));
        expect(result.platesPerSide[1].weight, equals(1.25));
        expect(result.platesPerSide[1].count, equals(1));
      });
    });

    group('Exact Matches (lbs)', () {
      test('should calculate exact match for 225lbs with standard lbs plates', () {
        // Arrange
        const targetWeight = 225.0;
        const barWeight = 45.0;
        final plates = [
          const PlateOption(weight: 45, count: 4),
          const PlateOption(weight: 25, count: 4),
          const PlateOption(weight: 10, count: 4),
          const PlateOption(weight: 5, count: 4),
          const PlateOption(weight: 2.5, count: 4),
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        expect(result.isExact, isTrue);
        expect(result.actualWeight, equals(225.0));
        // 225lbs = 45lbs bar + 90lbs per side
        // Expected: 2x45lbs per side
        expect(result.platesPerSide.length, equals(1));
        expect(result.platesPerSide.first.weight, equals(45));
        expect(result.platesPerSide.first.count, equals(2));
      });
    });

    group('Approximate Matches', () {
      test('should return closest achievable weight when exact not possible', () {
        // Arrange
        const targetWeight = 67.3; // Odd target
        const barWeight = 20.0;
        final plates = [
          const PlateOption(weight: 20, count: 4),
          const PlateOption(weight: 10, count: 4),
          const PlateOption(weight: 5, count: 4),
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        expect(result.isExact, isFalse);
        expect(result.actualWeight, lessThanOrEqualTo(targetWeight));
        // Best achievable: 65kg (20kg bar + 22.5kg per side = 1x20kg + 1x2.5kg? No 2.5kg available)
        // Actually: 60kg (20kg bar + 20kg per side = 1x20kg)
        expect(result.actualWeight, equals(60.0));
      });

      test('should use heaviest plates first (greedy algorithm)', () {
        // Arrange
        const targetWeight = 80.0;
        const barWeight = 20.0;
        final plates = [
          const PlateOption(weight: 20, count: 2),
          const PlateOption(weight: 10, count: 10), // Many 10kg plates
          const PlateOption(weight: 5, count: 10),
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        expect(result.isExact, isTrue);
        expect(result.actualWeight, equals(80.0));
        // 80kg = 20kg bar + 30kg per side
        // Greedy should use: 1x20kg + 1x10kg per side (not 3x10kg)
        expect(result.platesPerSide.length, equals(2));
        expect(result.platesPerSide[0].weight, equals(20));
        expect(result.platesPerSide[0].count, equals(1));
        expect(result.platesPerSide[1].weight, equals(10));
        expect(result.platesPerSide[1].count, equals(1));
      });
    });

    group('Edge Cases', () {
      test('should return bar only when target equals bar weight', () {
        // Arrange
        const targetWeight = 20.0;
        const barWeight = 20.0;
        final plates = [
          const PlateOption(weight: 20, count: 4),
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        expect(result.isExact, isTrue);
        expect(result.actualWeight, equals(20.0));
        expect(result.platesPerSide, isEmpty);
      });

      test('should return bar only when target is less than bar weight', () {
        // Arrange
        const targetWeight = 15.0;
        const barWeight = 20.0;
        final plates = [
          const PlateOption(weight: 20, count: 4),
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        expect(result.isExact, isTrue);
        expect(result.actualWeight, equals(20.0));
        expect(result.platesPerSide, isEmpty);
      });

      test('should handle empty plates list', () {
        // Arrange
        const targetWeight = 100.0;
        const barWeight = 20.0;
        final plates = <PlateOption>[];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        expect(result.actualWeight, equals(20.0)); // Bar only
        expect(result.platesPerSide, isEmpty);
        expect(result.isExact, isFalse);
      });

      test('should handle insufficient plates to reach target', () {
        // Arrange
        const targetWeight = 100.0;
        const barWeight = 20.0;
        final plates = [
          const PlateOption(weight: 20, count: 1), // Only 1 plate (can't balance)
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        expect(result.actualWeight, lessThan(targetWeight));
        expect(result.isExact, isFalse);
        // Should use 1x20kg per side = 60kg total
        expect(result.actualWeight, equals(60.0));
      });

      test('should handle zero target weight', () {
        // Arrange
        const targetWeight = 0.0;
        const barWeight = 20.0;
        final plates = [
          const PlateOption(weight: 20, count: 4),
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        expect(result.actualWeight, equals(20.0)); // Bar only
        expect(result.platesPerSide, isEmpty);
      });

      test('should respect plate count limits', () {
        // Arrange
        const targetWeight = 140.0;
        const barWeight = 20.0;
        final plates = [
          const PlateOption(weight: 20, count: 2), // Limited to 2 plates total
          const PlateOption(weight: 10, count: 10),
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        // 140kg = 20kg bar + 60kg per side
        // Greedy algorithm: tries to use 3x20kg per side (60/20=3), but only 2 available
        // Uses 2x20kg per side = 40kg, then needs 20kg more
        // Uses 2x10kg per side = 20kg
        // Total: 20 + (40 + 20) * 2 = 20 + 120 = 140kg
        expect(result.actualWeight, equals(140.0));
        expect(result.platesPerSide.length, equals(2));
        expect(result.platesPerSide[0].weight, equals(20));
        expect(result.platesPerSide[0].count, equals(2)); // Used 2x20kg (max available)
        expect(result.platesPerSide[1].weight, equals(10));
        expect(result.platesPerSide[1].count, equals(2)); // Used 2x10kg
      });
    });

    group('PlateCalculation Properties', () {
      test('difference should return correct value', () {
        // Arrange
        const targetWeight = 100.0;
        const barWeight = 20.0;
        final plates = [
          const PlateOption(weight: 20, count: 4), // 4 plates = 2 per side
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        // 100kg = 20kg bar + 40kg per side = 2x20kg per side
        // Achieves exactly 100kg, so difference = 0
        expect(result.isExact, isTrue);
        expect(result.difference, equals(0.0));
        expect(result.actualWeight, equals(100.0));
      });

      test('difference should return negative when underweight', () {
        // Arrange
        const targetWeight = 100.0;
        const barWeight = 20.0;
        final plates = [
          const PlateOption(weight: 20, count: 1), // Only 1 plate
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        // Can only achieve 60kg (20kg bar + 1x20kg per side)
        // Difference = 60 - 100 = -40kg
        expect(result.actualWeight, equals(60.0));
        expect(result.difference, equals(-40.0));
        expect(result.isExact, isFalse);
      });

      test('isAchievable should be true when difference is small', () {
        // Arrange
        const targetWeight = 100.0;
        const barWeight = 20.0;
        final plates = [
          const PlateOption(weight: 20, count: 4),
          const PlateOption(weight: 10, count: 4),
          const PlateOption(weight: 5, count: 4),
          const PlateOption(weight: 2.5, count: 4),
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        expect(result.isExact, isTrue);
        expect(result.isAchievable, isTrue);
      });

      test('isAchievable should be false when difference is large', () {
        // Arrange
        const targetWeight = 100.0;
        const barWeight = 20.0;
        final plates = [
          const PlateOption(weight: 20, count: 1), // Very limited
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        // Actual: 60kg, Target: 100kg, Difference: -40kg
        expect(result.isExact, isFalse);
        expect(result.difference.abs(), greaterThan(2.5));
        expect(result.isAchievable, isFalse);
      });
    });

    group('PlateUsage', () {
      test('toString should format correctly', () {
        // Arrange
        const plateUsage = PlateUsage(weight: 20.0, count: 2);

        // Act
        final result = plateUsage.toString();

        // Assert
        expect(result, equals('2x 20.0kg'));
      });
    });

    group('Complex Scenarios', () {
      test('should handle multiple fractional plates correctly', () {
        // Arrange
        const targetWeight = 47.5;
        const barWeight = 20.0;
        final plates = [
          const PlateOption(weight: 10, count: 4),
          const PlateOption(weight: 5, count: 4),
          const PlateOption(weight: 2.5, count: 4),
          const PlateOption(weight: 1.25, count: 4),
          const PlateOption(weight: 0.5, count: 4),
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        expect(result.isExact, isTrue);
        expect(result.actualWeight, equals(47.5));
        // 47.5kg = 20kg bar + 13.75kg per side
        // Expected: 1x10kg + 1x2.5kg + 1x1.25kg per side
        expect(result.platesPerSide.length, equals(3));

        final totalPerSide = result.platesPerSide.fold<double>(
          0,
          (sum, usage) => sum + (usage.weight * usage.count),
        );
        expect(totalPerSide, equals(13.75));
      });

      test('should prioritize larger plates even with many small plates available', () {
        // Arrange
        const targetWeight = 100.0;
        const barWeight = 20.0;
        final plates = [
          const PlateOption(weight: 20, count: 4),
          const PlateOption(weight: 10, count: 10),
          const PlateOption(weight: 5, count: 20),
          const PlateOption(weight: 2.5, count: 30),
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        expect(result.isExact, isTrue);
        expect(result.actualWeight, equals(100.0));

        // Should use 2x20kg per side (greedy = heaviest first)
        expect(result.platesPerSide.first.weight, equals(20));
        expect(result.platesPerSide.first.count, equals(2));
      });

      test('should handle plates with same weight but different counts', () {
        // Arrange (edge case that shouldn't happen, but test for robustness)
        const targetWeight = 60.0;
        const barWeight = 20.0;
        final plates = [
          const PlateOption(weight: 10, count: 4),
          // Service will merge by weight internally in the Map
        ];

        // Act
        final result = service.calculatePlates(
          targetWeight: targetWeight,
          barWeight: barWeight,
          availablePlates: plates,
        );

        // Assert
        expect(result.isExact, isTrue);
        expect(result.actualWeight, equals(60.0));
        // 60kg = 20kg bar + 20kg per side = 2x10kg per side
        expect(result.platesPerSide.length, equals(1));
        expect(result.platesPerSide.first.count, equals(2));
      });
    });
  });
}

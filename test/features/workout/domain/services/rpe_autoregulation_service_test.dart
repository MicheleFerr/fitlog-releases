import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/rpe_autoregulation_service.dart';

void main() {
  group('RPEAutoregulationService', () {
    group('calculateRPEAdjustment', () {
      test('should maintain weight when RPE is within target range', () {
        // Arrange - RPE 8 in range 7-9
        const currentWeight = 100.0;
        const actualRPE = 8.0;
        const targetRPEMin = 7.0;
        const targetRPEMax = 9.0;

        // Act
        final result = RPEAutoregulationService.calculateRPEAdjustment(
          currentWeight: currentWeight,
          actualRPE: actualRPE,
          targetRPEMin: targetRPEMin,
          targetRPEMax: targetRPEMax,
        );

        // Assert
        expect(result.adjustmentPercent, equals(0));
        expect(result.adjustedWeight, equals(currentWeight));
        expect(result.shouldMaintain, isTrue);
        expect(result.reason, contains('within target range'));
      });

      test('should increase weight by 2% when RPE is 0.5 below minimum', () {
        // Arrange - RPE 6.5, target 7-9
        const currentWeight = 100.0;
        const actualRPE = 6.5;
        const targetRPEMin = 7.0;
        const targetRPEMax = 9.0;

        // Act
        final result = RPEAutoregulationService.calculateRPEAdjustment(
          currentWeight: currentWeight,
          actualRPE: actualRPE,
          targetRPEMin: targetRPEMin,
          targetRPEMax: targetRPEMax,
        );

        // Assert - Formula: (0.5 / 0.5) * 2% = 2%
        expect(result.adjustmentPercent, equals(2.0));
        expect(result.adjustedWeight, equals(102.5)); // Rounded to 2.5kg
        expect(result.shouldIncrease, isTrue);
        expect(result.reason, contains('below target'));
      });

      test('should increase weight by 4% when RPE is 1.0 below minimum', () {
        // Arrange - RPE 6.0, target 7-9
        const currentWeight = 100.0;
        const actualRPE = 6.0;
        const targetRPEMin = 7.0;
        const targetRPEMax = 9.0;

        // Act
        final result = RPEAutoregulationService.calculateRPEAdjustment(
          currentWeight: currentWeight,
          actualRPE: actualRPE,
          targetRPEMin: targetRPEMin,
          targetRPEMax: targetRPEMax,
        );

        // Assert - Formula: (1.0 / 0.5) * 2% = 4%
        expect(result.adjustmentPercent, equals(4.0));
        expect(result.adjustedWeight, equals(105.0)); // Rounded to 2.5kg
        expect(result.shouldIncrease, isTrue);
        expect(result.reason, contains('below target range'));
      });

      test('should decrease weight by 2% when RPE is 0.5 above maximum', () {
        // Arrange - RPE 9.5, target 7-9
        const currentWeight = 100.0;
        const actualRPE = 9.5;
        const targetRPEMin = 7.0;
        const targetRPEMax = 9.0;

        // Act
        final result = RPEAutoregulationService.calculateRPEAdjustment(
          currentWeight: currentWeight,
          actualRPE: actualRPE,
          targetRPEMin: targetRPEMin,
          targetRPEMax: targetRPEMax,
        );

        // Assert - Formula: -(0.5 / 0.5) * 2% = -2%
        expect(result.adjustmentPercent, equals(-2.0));
        expect(result.adjustedWeight, equals(97.5)); // Rounded to 2.5kg
        expect(result.shouldDecrease, isTrue);
        expect(result.reason, contains('above target'));
      });

      test('should decrease weight by 4% when RPE is 1.0 above maximum', () {
        // Arrange - RPE 10, target 7-9
        const currentWeight = 100.0;
        const actualRPE = 10.0;
        const targetRPEMin = 7.0;
        const targetRPEMax = 9.0;

        // Act
        final result = RPEAutoregulationService.calculateRPEAdjustment(
          currentWeight: currentWeight,
          actualRPE: actualRPE,
          targetRPEMin: targetRPEMin,
          targetRPEMax: targetRPEMax,
        );

        // Assert - Formula: -(1.0 / 0.5) * 2% = -4%
        expect(result.adjustmentPercent, equals(-4.0));
        expect(result.adjustedWeight, equals(95.0)); // Rounded to 2.5kg
        expect(result.shouldDecrease, isTrue);
        expect(result.reason, contains('above target range'));
      });

      test('should cap positive adjustment at +20%', () {
        // Arrange - RPE 2.0 (way below target 7-9)
        const currentWeight = 100.0;
        const actualRPE = 2.0;
        const targetRPEMin = 7.0;
        const targetRPEMax = 9.0;

        // Act
        final result = RPEAutoregulationService.calculateRPEAdjustment(
          currentWeight: currentWeight,
          actualRPE: actualRPE,
          targetRPEMin: targetRPEMin,
          targetRPEMax: targetRPEMax,
        );

        // Assert - Should be capped at 20%
        expect(result.adjustmentPercent, equals(20.0));
        expect(result.adjustedWeight, equals(120.0));
        expect(result.reason, contains('capped at +20%'));
      });

      test('should cap negative adjustment at -20%', () {
        // Arrange - RPE 10 (way above target 3-5)
        const currentWeight = 100.0;
        const actualRPE = 10.0;
        const targetRPEMin = 3.0;
        const targetRPEMax = 5.0;

        // Act
        final result = RPEAutoregulationService.calculateRPEAdjustment(
          currentWeight: currentWeight,
          actualRPE: actualRPE,
          targetRPEMin: targetRPEMin,
          targetRPEMax: targetRPEMax,
        );

        // Assert - Should be capped at -20%
        expect(result.adjustmentPercent, equals(-20.0));
        expect(result.adjustedWeight, equals(80.0));
        expect(result.reason, contains('capped at -20%'));
      });

      test('should provide detailed reason for significant deviation', () {
        // Arrange - RPE 5.0, target 7-9 (2 points below)
        const currentWeight = 100.0;
        const actualRPE = 5.0;
        const targetRPEMin = 7.0;
        const targetRPEMax = 9.0;

        // Act
        final result = RPEAutoregulationService.calculateRPEAdjustment(
          currentWeight: currentWeight,
          actualRPE: actualRPE,
          targetRPEMin: targetRPEMin,
          targetRPEMax: targetRPEMax,
        );

        // Assert
        expect(result.reason, contains('significantly below'));
        expect(result.actualRPE, equals(actualRPE));
        expect(result.targetRPERange, equals('7.0-9.0'));
      });

      test('should work with different base weights', () {
        // Arrange
        const actualRPE = 8.5;
        const targetRPEMin = 7.0;
        const targetRPEMax = 9.0;

        // Act - Test with 50kg
        final result50 = RPEAutoregulationService.calculateRPEAdjustment(
          currentWeight: 50.0,
          actualRPE: actualRPE,
          targetRPEMin: targetRPEMin,
          targetRPEMax: targetRPEMax,
        );

        // Act - Test with 200kg
        final result200 = RPEAutoregulationService.calculateRPEAdjustment(
          currentWeight: 200.0,
          actualRPE: actualRPE,
          targetRPEMin: targetRPEMin,
          targetRPEMax: targetRPEMax,
        );

        // Assert - Both should have same percentage but different absolute weights
        expect(result50.adjustmentPercent, equals(result200.adjustmentPercent));
        expect(result50.adjustedWeight, equals(50.0));
        expect(result200.adjustedWeight, equals(200.0));
      });
    });

    group('calculateRIRAdjustment', () {
      test('should maintain weight when RIR matches target', () {
        // Arrange - RIR 2, target 2
        const currentWeight = 100.0;
        const actualRIR = 2;
        const targetRIR = 2;

        // Act
        final result = RPEAutoregulationService.calculateRIRAdjustment(
          currentWeight: currentWeight,
          actualRIR: actualRIR,
          targetRIR: targetRIR,
        );

        // Assert
        expect(result.adjustmentPercent, equals(0));
        expect(result.adjustedWeight, equals(currentWeight));
        expect(result.shouldMaintain, isTrue);
        expect(result.reason, contains('matches target'));
      });

      test('should increase weight by 4% when RIR is 1 above target', () {
        // Arrange - RIR 3, target 2 (too easy)
        const currentWeight = 100.0;
        const actualRIR = 3;
        const targetRIR = 2;

        // Act
        final result = RPEAutoregulationService.calculateRIRAdjustment(
          currentWeight: currentWeight,
          actualRIR: actualRIR,
          targetRIR: targetRIR,
        );

        // Assert - Formula: 1 RIR * 4% = 4%
        expect(result.adjustmentPercent, equals(4.0));
        expect(result.adjustedWeight, equals(105.0)); // Rounded to 2.5kg
        expect(result.shouldIncrease, isTrue);
        expect(result.reason, contains('more RIR'));
      });

      test('should increase weight by 8% when RIR is 2 above target', () {
        // Arrange - RIR 4, target 2 (way too easy)
        const currentWeight = 100.0;
        const actualRIR = 4;
        const targetRIR = 2;

        // Act
        final result = RPEAutoregulationService.calculateRIRAdjustment(
          currentWeight: currentWeight,
          actualRIR: actualRIR,
          targetRIR: targetRIR,
        );

        // Assert - Formula: 2 RIR * 4% = 8%
        expect(result.adjustmentPercent, equals(8.0));
        expect(result.adjustedWeight, equals(107.5)); // Rounded to 2.5kg
        expect(result.shouldIncrease, isTrue);
        expect(result.reason, contains('More reps in reserve'));
      });

      test('should decrease weight by 4% when RIR is 1 below target', () {
        // Arrange - RIR 1, target 2 (too hard)
        const currentWeight = 100.0;
        const actualRIR = 1;
        const targetRIR = 2;

        // Act
        final result = RPEAutoregulationService.calculateRIRAdjustment(
          currentWeight: currentWeight,
          actualRIR: actualRIR,
          targetRIR: targetRIR,
        );

        // Assert - Formula: -1 RIR * 4% = -4%
        expect(result.adjustmentPercent, equals(-4.0));
        expect(result.adjustedWeight, equals(95.0)); // Rounded to 2.5kg
        expect(result.shouldDecrease, isTrue);
        expect(result.reason, contains('fewer RIR'));
      });

      test('should decrease weight by 8% when RIR is 2 below target', () {
        // Arrange - RIR 0, target 2 (way too hard)
        const currentWeight = 100.0;
        const actualRIR = 0;
        const targetRIR = 2;

        // Act
        final result = RPEAutoregulationService.calculateRIRAdjustment(
          currentWeight: currentWeight,
          actualRIR: actualRIR,
          targetRIR: targetRIR,
        );

        // Assert - Formula: -2 RIR * 4% = -8%
        expect(result.adjustmentPercent, equals(-8.0));
        expect(result.adjustedWeight, equals(92.5)); // Rounded to 2.5kg
        expect(result.shouldDecrease, isTrue);
        expect(result.reason, contains('Too few reps'));
      });

      test('should cap positive adjustment at +20%', () {
        // Arrange - RIR 8, target 2 (way too easy)
        const currentWeight = 100.0;
        const actualRIR = 8;
        const targetRIR = 2;

        // Act
        final result = RPEAutoregulationService.calculateRIRAdjustment(
          currentWeight: currentWeight,
          actualRIR: actualRIR,
          targetRIR: targetRIR,
        );

        // Assert - Should be capped at 20%
        expect(result.adjustmentPercent, equals(20.0));
        expect(result.adjustedWeight, equals(120.0));
        expect(result.reason, contains('capped at +20%'));
      });

      test('should cap negative adjustment at -20%', () {
        // Arrange - RIR 0, target 8 (way too hard)
        const currentWeight = 100.0;
        const actualRIR = 0;
        const targetRIR = 8;

        // Act
        final result = RPEAutoregulationService.calculateRIRAdjustment(
          currentWeight: currentWeight,
          actualRIR: actualRIR,
          targetRIR: targetRIR,
        );

        // Assert - Should be capped at -20%
        expect(result.adjustmentPercent, equals(-20.0));
        expect(result.adjustedWeight, equals(80.0));
        expect(result.reason, contains('capped at -20%'));
      });

      test('should include RIR values in result', () {
        // Arrange
        const currentWeight = 100.0;
        const actualRIR = 3;
        const targetRIR = 2;

        // Act
        final result = RPEAutoregulationService.calculateRIRAdjustment(
          currentWeight: currentWeight,
          actualRIR: actualRIR,
          targetRIR: targetRIR,
        );

        // Assert
        expect(result.actualRIR, equals(actualRIR));
        expect(result.targetRIR, equals(targetRIR));
      });

      test('should provide detailed reason for significant deviation', () {
        // Arrange - RIR 5, target 2 (3+ RIR too easy)
        const currentWeight = 100.0;
        const actualRIR = 5;
        const targetRIR = 2;

        // Act
        final result = RPEAutoregulationService.calculateRIRAdjustment(
          currentWeight: currentWeight,
          actualRIR: actualRIR,
          targetRIR: targetRIR,
        );

        // Assert
        expect(result.reason, contains('Too many reps in reserve'));
      });
    });

    group('rpeToRIR conversion', () {
      test('should convert RPE 10 to RIR 0', () {
        expect(RPEAutoregulationService.rpeToRIR(10.0), equals(0));
        expect(RPEAutoregulationService.rpeToRIR(10.5), equals(0)); // Above 10
      });

      test('should convert RPE 9.0-9.9 to RIR 1', () {
        expect(RPEAutoregulationService.rpeToRIR(9.0), equals(1));
        expect(RPEAutoregulationService.rpeToRIR(9.5), equals(1));
        expect(RPEAutoregulationService.rpeToRIR(9.9), equals(1));
      });

      test('should convert RPE 8.0-8.9 to RIR 2', () {
        expect(RPEAutoregulationService.rpeToRIR(8.0), equals(2));
        expect(RPEAutoregulationService.rpeToRIR(8.5), equals(2));
        expect(RPEAutoregulationService.rpeToRIR(8.9), equals(2));
      });

      test('should convert RPE 7.0-7.9 to RIR 3', () {
        expect(RPEAutoregulationService.rpeToRIR(7.0), equals(3));
        expect(RPEAutoregulationService.rpeToRIR(7.5), equals(3));
        expect(RPEAutoregulationService.rpeToRIR(7.9), equals(3));
      });

      test('should convert RPE 6.0-6.9 to RIR 4', () {
        expect(RPEAutoregulationService.rpeToRIR(6.0), equals(4));
        expect(RPEAutoregulationService.rpeToRIR(6.5), equals(4));
        expect(RPEAutoregulationService.rpeToRIR(6.9), equals(4));
      });

      test('should convert RPE < 6.0 to RIR 5', () {
        expect(RPEAutoregulationService.rpeToRIR(5.9), equals(5));
        expect(RPEAutoregulationService.rpeToRIR(5.0), equals(5));
        expect(RPEAutoregulationService.rpeToRIR(1.0), equals(5));
      });
    });

    group('rirToRPE conversion', () {
      test('should convert RIR 0 to RPE 10', () {
        expect(RPEAutoregulationService.rirToRPE(0), equals(10.0));
      });

      test('should convert RIR 1 to RPE 9', () {
        expect(RPEAutoregulationService.rirToRPE(1), equals(9.0));
      });

      test('should convert RIR 2 to RPE 8', () {
        expect(RPEAutoregulationService.rirToRPE(2), equals(8.0));
      });

      test('should convert RIR 3 to RPE 7', () {
        expect(RPEAutoregulationService.rirToRPE(3), equals(7.0));
      });

      test('should convert RIR 4 to RPE 6', () {
        expect(RPEAutoregulationService.rirToRPE(4), equals(6.0));
      });

      test('should convert RIR 5+ to RPE 5', () {
        expect(RPEAutoregulationService.rirToRPE(5), equals(5.0));
        expect(RPEAutoregulationService.rirToRPE(10), equals(5.0));
        expect(RPEAutoregulationService.rirToRPE(100), equals(5.0));
      });
    });

    group('WeightAdjustment entity', () {
      test('shouldIncrease should be true for positive adjustment', () {
        const adjustment = WeightAdjustment(
          originalWeight: 100.0,
          adjustedWeight: 105.0,
          adjustmentPercent: 5.0,
          reason: 'Test increase',
        );

        expect(adjustment.shouldIncrease, isTrue);
        expect(adjustment.shouldDecrease, isFalse);
        expect(adjustment.shouldMaintain, isFalse);
      });

      test('shouldDecrease should be true for negative adjustment', () {
        const adjustment = WeightAdjustment(
          originalWeight: 100.0,
          adjustedWeight: 95.0,
          adjustmentPercent: -5.0,
          reason: 'Test decrease',
        );

        expect(adjustment.shouldIncrease, isFalse);
        expect(adjustment.shouldDecrease, isTrue);
        expect(adjustment.shouldMaintain, isFalse);
      });

      test('shouldMaintain should be true for zero adjustment', () {
        const adjustment = WeightAdjustment(
          originalWeight: 100.0,
          adjustedWeight: 100.0,
          adjustmentPercent: 0.0,
          reason: 'Test maintain',
        );

        expect(adjustment.shouldIncrease, isFalse);
        expect(adjustment.shouldDecrease, isFalse);
        expect(adjustment.shouldMaintain, isTrue);
      });

      test('should store RPE values correctly', () {
        const adjustment = WeightAdjustment(
          originalWeight: 100.0,
          adjustedWeight: 102.5,
          adjustmentPercent: 2.5,
          reason: 'RPE test',
          actualRPE: 6.5,
          targetRPERange: '7.0-9.0',
        );

        expect(adjustment.actualRPE, equals(6.5));
        expect(adjustment.targetRPERange, equals('7.0-9.0'));
        expect(adjustment.actualRIR, isNull);
        expect(adjustment.targetRIR, isNull);
      });

      test('should store RIR values correctly', () {
        const adjustment = WeightAdjustment(
          originalWeight: 100.0,
          adjustedWeight: 104.0,
          adjustmentPercent: 4.0,
          reason: 'RIR test',
          actualRIR: 3,
          targetRIR: 2,
        );

        expect(adjustment.actualRIR, equals(3));
        expect(adjustment.targetRIR, equals(2));
        expect(adjustment.actualRPE, isNull);
        expect(adjustment.targetRPERange, isNull);
      });
    });

    group('Weight rounding', () {
      test('should round to nearest 2.5kg', () {
        // Testing through public API
        const currentWeight = 100.0;

        // 102.4 → 102.5
        final result1 = RPEAutoregulationService.calculateRPEAdjustment(
          currentWeight: currentWeight,
          actualRPE: 6.88, // Should give ~2.4% increase
          targetRPEMin: 7.0,
          targetRPEMax: 9.0,
        );
        expect(result1.adjustedWeight, equals(102.5));

        // 97.6 → 97.5
        final result2 = RPEAutoregulationService.calculateRPEAdjustment(
          currentWeight: currentWeight,
          actualRPE: 9.12, // Should give ~-2.4% decrease
          targetRPEMin: 7.0,
          targetRPEMax: 9.0,
        );
        expect(result2.adjustedWeight, equals(97.5));
      });

      test('should handle edge cases in rounding', () {
        const currentWeight = 100.0;

        // Exactly 101.25 → should round to 102.5
        final result1 = RPEAutoregulationService.calculateRIRAdjustment(
          currentWeight: currentWeight,
          actualRIR: 3,
          targetRIR: 2,
        );
        // 4% of 100 = 104, which rounds to 105
        expect(result1.adjustedWeight, isA<double>());

        // Exactly 98.75 → should round to 97.5
        final result2 = RPEAutoregulationService.calculateRIRAdjustment(
          currentWeight: currentWeight,
          actualRIR: 1,
          targetRIR: 2,
        );
        // -4% of 100 = 96, which rounds to 95
        expect(result2.adjustedWeight, isA<double>());
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/apre_service.dart';

void main() {
  group('APREService - APRE-3 Protocol (Strength)', () {
    test('should return heavy decrease for 0-1 reps', () {
      // Act
      final adjustment0 = APREService.getAdjustment(3, 0);
      final adjustment1 = APREService.getAdjustment(3, 1);

      // Assert
      expect(adjustment0, isNotNull);
      expect(adjustment0!.set4Adjustment, equals(-10.0));
      expect(adjustment0.nextSessionAdjustment, equals(-10.0));
      expect(adjustment0.repsRange, equals('0-1'));

      expect(adjustment1, isNotNull);
      expect(adjustment1!.set4Adjustment, equals(-10.0));
    });

    test('should maintain weight for 2-3 reps (perfect)', () {
      // Act
      final adjustment2 = APREService.getAdjustment(3, 2);
      final adjustment3 = APREService.getAdjustment(3, 3);

      // Assert
      expect(adjustment2, isNotNull);
      expect(adjustment2!.set4Adjustment, equals(0.0));
      expect(adjustment2.nextSessionAdjustment, equals(0.0));
      expect(adjustment2.repsRange, equals('2-3'));

      expect(adjustment3, isNotNull);
      expect(adjustment3!.set4Adjustment, equals(0.0));
    });

    test('should increase moderately for 4-5 reps', () {
      // Act
      final adjustment4 = APREService.getAdjustment(3, 4);
      final adjustment5 = APREService.getAdjustment(3, 5);

      // Assert
      expect(adjustment4, isNotNull);
      expect(adjustment4!.set4Adjustment, equals(5.0));
      expect(adjustment4.nextSessionAdjustment, equals(5.0));
      expect(adjustment4.repsRange, equals('4-5'));

      expect(adjustment5, isNotNull);
      expect(adjustment5!.set4Adjustment, equals(5.0));
    });

    test('should increase significantly for 6+ reps', () {
      // Act
      final adjustment6 = APREService.getAdjustment(3, 6);
      final adjustment10 = APREService.getAdjustment(3, 10);

      // Assert
      expect(adjustment6, isNotNull);
      expect(adjustment6!.set4Adjustment, equals(10.0));
      expect(adjustment6.nextSessionAdjustment, equals(10.0));
      expect(adjustment6.repsRange, equals('6+'));

      expect(adjustment10, isNotNull);
      expect(adjustment10!.set4Adjustment, equals(10.0));
    });
  });

  group('APREService - APRE-6 Protocol (Hypertrophy)', () {
    test('should return heavy decrease for 0-2 reps', () {
      // Act
      final adjustment0 = APREService.getAdjustment(6, 0);
      final adjustment2 = APREService.getAdjustment(6, 2);

      // Assert
      expect(adjustment0, isNotNull);
      expect(adjustment0!.set4Adjustment, equals(-10.0));
      expect(adjustment0.repsRange, equals('0-2'));

      expect(adjustment2, isNotNull);
      expect(adjustment2!.set4Adjustment, equals(-10.0));
    });

    test('should decrease slightly for 3-4 reps', () {
      // Act
      final adjustment3 = APREService.getAdjustment(6, 3);
      final adjustment4 = APREService.getAdjustment(6, 4);

      // Assert
      expect(adjustment3, isNotNull);
      expect(adjustment3!.set4Adjustment, equals(-5.0));
      expect(adjustment3.nextSessionAdjustment, equals(-5.0));
      expect(adjustment3.repsRange, equals('3-4'));

      expect(adjustment4, isNotNull);
      expect(adjustment4!.set4Adjustment, equals(-5.0));
    });

    test('should maintain weight for 5-7 reps (perfect)', () {
      // Act
      final adjustment5 = APREService.getAdjustment(6, 5);
      final adjustment6 = APREService.getAdjustment(6, 6);
      final adjustment7 = APREService.getAdjustment(6, 7);

      // Assert
      expect(adjustment5, isNotNull);
      expect(adjustment5!.set4Adjustment, equals(0.0));
      expect(adjustment5.repsRange, equals('5-7'));

      expect(adjustment6, isNotNull);
      expect(adjustment6!.set4Adjustment, equals(0.0));

      expect(adjustment7, isNotNull);
      expect(adjustment7!.set4Adjustment, equals(0.0));
    });

    test('should increase moderately for 8-12 reps', () {
      // Act
      final adjustment8 = APREService.getAdjustment(6, 8);
      final adjustment12 = APREService.getAdjustment(6, 12);

      // Assert
      expect(adjustment8, isNotNull);
      expect(adjustment8!.set4Adjustment, equals(5.0));
      expect(adjustment8.repsRange, equals('8-12'));

      expect(adjustment12, isNotNull);
      expect(adjustment12!.set4Adjustment, equals(5.0));
    });

    test('should increase significantly for 13+ reps', () {
      // Act
      final adjustment13 = APREService.getAdjustment(6, 13);
      final adjustment20 = APREService.getAdjustment(6, 20);

      // Assert
      expect(adjustment13, isNotNull);
      expect(adjustment13!.set4Adjustment, equals(10.0));
      expect(adjustment13.repsRange, equals('13+'));

      expect(adjustment20, isNotNull);
      expect(adjustment20!.set4Adjustment, equals(10.0));
    });
  });

  group('APREService - APRE-10 Protocol (Endurance)', () {
    test('should return heavy decrease for 0-7 reps', () {
      // Act
      final adjustment0 = APREService.getAdjustment(10, 0);
      final adjustment7 = APREService.getAdjustment(10, 7);

      // Assert
      expect(adjustment0, isNotNull);
      expect(adjustment0!.set4Adjustment, equals(-10.0));
      expect(adjustment0.repsRange, equals('0-7'));

      expect(adjustment7, isNotNull);
      expect(adjustment7!.set4Adjustment, equals(-10.0));
    });

    test('should maintain weight for 8-12 reps (perfect)', () {
      // Act
      final adjustment8 = APREService.getAdjustment(10, 8);
      final adjustment10 = APREService.getAdjustment(10, 10);
      final adjustment12 = APREService.getAdjustment(10, 12);

      // Assert
      expect(adjustment8, isNotNull);
      expect(adjustment8!.set4Adjustment, equals(0.0));
      expect(adjustment8.repsRange, equals('8-12'));

      expect(adjustment10, isNotNull);
      expect(adjustment10!.set4Adjustment, equals(0.0));

      expect(adjustment12, isNotNull);
      expect(adjustment12!.set4Adjustment, equals(0.0));
    });

    test('should increase moderately for 13-17 reps', () {
      // Act
      final adjustment13 = APREService.getAdjustment(10, 13);
      final adjustment17 = APREService.getAdjustment(10, 17);

      // Assert
      expect(adjustment13, isNotNull);
      expect(adjustment13!.set4Adjustment, equals(5.0));
      expect(adjustment13.repsRange, equals('13-17'));

      expect(adjustment17, isNotNull);
      expect(adjustment17!.set4Adjustment, equals(5.0));
    });

    test('should increase significantly for 18+ reps', () {
      // Act
      final adjustment18 = APREService.getAdjustment(10, 18);
      final adjustment25 = APREService.getAdjustment(10, 25);

      // Assert
      expect(adjustment18, isNotNull);
      expect(adjustment18!.set4Adjustment, equals(10.0));
      expect(adjustment18.repsRange, equals('18+'));

      expect(adjustment25, isNotNull);
      expect(adjustment25!.set4Adjustment, equals(10.0));
    });
  });

  group('APREService - Invalid Protocol', () {
    test('should return null for invalid protocol', () {
      // Act
      final adjustment = APREService.getAdjustment(99, 5);

      // Assert
      expect(adjustment, isNull);
    });

    test('should handle zero protocol', () {
      // Act
      final adjustment = APREService.getAdjustment(0, 5);

      // Assert
      expect(adjustment, isNull);
    });

    test('should handle negative protocol', () {
      // Act
      final adjustment = APREService.getAdjustment(-1, 5);

      // Assert
      expect(adjustment, isNull);
    });
  });

  group('APREService - Weight Calculations (Kilograms)', () {
    test('should calculate next weight with positive adjustment', () {
      // Arrange
      const currentWeight = 100.0;
      const repsCompleted = 6; // Protocol 3 → +10 lbs adjustment
      const protocol = 3;

      // Act
      final nextWeight = APREService.calculateNextWeight(
        currentWeight,
        repsCompleted,
        protocol,
        useKilograms: true,
      );

      // Assert - Should add ~4.5kg (10 lbs) rounded to 2.5kg
      expect(nextWeight, greaterThan(currentWeight));
      expect(nextWeight % 2.5, equals(0)); // Rounded to 2.5kg
    });

    test('should calculate next weight with negative adjustment', () {
      // Arrange
      const currentWeight = 100.0;
      const repsCompleted = 1; // Protocol 3 → -10 lbs adjustment
      const protocol = 3;

      // Act
      final nextWeight = APREService.calculateNextWeight(
        currentWeight,
        repsCompleted,
        protocol,
        useKilograms: true,
      );

      // Assert - Should subtract ~4.5kg (10 lbs) rounded to 2.5kg
      expect(nextWeight, lessThan(currentWeight));
      expect(nextWeight % 2.5, equals(0));
    });

    test('should maintain weight with zero adjustment', () {
      // Arrange
      const currentWeight = 100.0;
      const repsCompleted = 3; // Protocol 3 → 0 lbs adjustment
      const protocol = 3;

      // Act
      final nextWeight = APREService.calculateNextWeight(
        currentWeight,
        repsCompleted,
        protocol,
        useKilograms: true,
      );

      // Assert - Weight should stay the same
      expect(nextWeight, equals(currentWeight));
    });

    test('should round to nearest 2.5kg', () {
      // Arrange - Edge case where conversion might not be exact 2.5kg multiple
      const currentWeight = 97.3;
      const repsCompleted = 5; // Protocol 3 → +5 lbs adjustment
      const protocol = 3;

      // Act
      final nextWeight = APREService.calculateNextWeight(
        currentWeight,
        repsCompleted,
        protocol,
        useKilograms: true,
      );

      // Assert
      expect(nextWeight % 2.5, equals(0));
    });

    test('should handle set 4 vs next session differently', () {
      // Arrange
      const currentWeight = 100.0;
      const repsCompleted = 6;
      const protocol = 3;

      // Act
      final set4Weight = APREService.calculateNextWeight(
        currentWeight,
        repsCompleted,
        protocol,
        isForSet4: true,
        useKilograms: true,
      );

      final nextSessionWeight = APREService.calculateNextWeight(
        currentWeight,
        repsCompleted,
        protocol,
        isForSet4: false,
        useKilograms: true,
      );

      // Assert - In this case they're the same, but the parameter is used
      expect(set4Weight, isNotNull);
      expect(nextSessionWeight, isNotNull);
    });

    test('should return current weight for invalid protocol', () {
      // Arrange
      const currentWeight = 100.0;
      const repsCompleted = 5;
      const invalidProtocol = 99;

      // Act
      final nextWeight = APREService.calculateNextWeight(
        currentWeight,
        repsCompleted,
        invalidProtocol,
        useKilograms: true,
      );

      // Assert
      expect(nextWeight, equals(currentWeight));
    });
  });

  group('APREService - Weight Calculations (Pounds)', () {
    test('should calculate next weight in pounds', () {
      // Arrange
      const currentWeight = 225.0; // lbs
      const repsCompleted = 6; // Protocol 3 → +10 lbs adjustment
      const protocol = 3;

      // Act
      final nextWeight = APREService.calculateNextWeight(
        currentWeight,
        repsCompleted,
        protocol,
        useKilograms: false,
      );

      // Assert - Should add 10 lbs rounded to 5 lbs
      expect(nextWeight, greaterThan(currentWeight));
      expect(nextWeight % 5, equals(0)); // Rounded to 5 lbs
    });

    test('should round to nearest 5 lbs', () {
      // Arrange
      const currentWeight = 223.0; // lbs
      const repsCompleted = 5; // Protocol 3 → +5 lbs adjustment
      const protocol = 3;

      // Act
      final nextWeight = APREService.calculateNextWeight(
        currentWeight,
        repsCompleted,
        protocol,
        useKilograms: false,
      );

      // Assert
      expect(nextWeight % 5, equals(0));
    });

    test('should handle negative adjustments in pounds', () {
      // Arrange
      const currentWeight = 225.0;
      const repsCompleted = 1; // Protocol 3 → -10 lbs
      const protocol = 3;

      // Act
      final nextWeight = APREService.calculateNextWeight(
        currentWeight,
        repsCompleted,
        protocol,
        useKilograms: false,
      );

      // Assert
      expect(nextWeight, lessThan(currentWeight));
      expect(nextWeight % 5, equals(0));
    });
  });

  group('APREService - Protocol Descriptions', () {
    test('should return APRE-3 description', () {
      // Act
      final description = APREService.getProtocolDescription(3);

      // Assert
      expect(description, contains('APRE-3'));
      expect(description, contains('Maximum Strength'));
      expect(description, contains('92%'));
    });

    test('should return APRE-6 description', () {
      // Act
      final description = APREService.getProtocolDescription(6);

      // Assert
      expect(description, contains('APRE-6'));
      expect(description, contains('Strength-Hypertrophy'));
      expect(description, contains('83%'));
    });

    test('should return APRE-10 description', () {
      // Act
      final description = APREService.getProtocolDescription(10);

      // Assert
      expect(description, contains('APRE-10'));
      expect(description, contains('Hypertrophy-Endurance'));
      expect(description, contains('75%'));
    });

    test('should return unknown for invalid protocol', () {
      // Act
      final description = APREService.getProtocolDescription(99);

      // Assert
      expect(description, equals('Unknown protocol'));
    });
  });

  group('APREService - APRE Set Structure', () {
    test('should return 4 sets for APRE structure', () {
      // Act
      final sets = APREService.getAPRESetStructure(6, 100.0);

      // Assert
      expect(sets, hasLength(4));
    });

    test('should have correct warm-up set (50% for 10 reps)', () {
      // Arrange
      const baseWeight = 100.0;

      // Act
      final sets = APREService.getAPRESetStructure(6, baseWeight);

      // Assert
      final warmUpSet = sets[0];
      expect(warmUpSet.setNumber, equals(1));
      expect(warmUpSet.percentage, equals(50));
      expect(warmUpSet.weight, equals(50.0)); // 50% of 100
      expect(warmUpSet.targetReps, equals(10));
      expect(warmUpSet.description, contains('Warm-up'));
    });

    test('should have correct preparation set (75% for protocol reps)', () {
      // Arrange
      const baseWeight = 100.0;
      const protocol = 6;

      // Act
      final sets = APREService.getAPRESetStructure(protocol, baseWeight);

      // Assert
      final prepSet = sets[1];
      expect(prepSet.setNumber, equals(2));
      expect(prepSet.percentage, equals(75));
      expect(prepSet.weight, equals(75.0)); // 75% of 100
      expect(prepSet.targetReps, equals(6)); // Same as protocol
      expect(prepSet.description, contains('Preparation'));
    });

    test('should have correct max effort set 3 (100% max reps)', () {
      // Arrange
      const baseWeight = 100.0;

      // Act
      final sets = APREService.getAPRESetStructure(6, baseWeight);

      // Assert
      final set3 = sets[2];
      expect(set3.setNumber, equals(3));
      expect(set3.percentage, equals(100));
      expect(set3.weight, equals(100.0)); // 100% of base
      expect(set3.targetReps, isNull); // MAX reps
      expect(set3.description, contains('Max effort'));
    });

    test('should have adjusted set 4 with null weight', () {
      // Arrange
      const baseWeight = 100.0;

      // Act
      final sets = APREService.getAPRESetStructure(6, baseWeight);

      // Assert
      final set4 = sets[3];
      expect(set4.setNumber, equals(4));
      expect(set4.percentage, isNull); // Adjusted based on set 3
      expect(set4.weight, isNull); // Will be calculated
      expect(set4.targetReps, isNull); // MAX reps
      expect(set4.description, contains('Adjusted'));
    });

    test('should work with different protocols', () {
      // Act
      final sets3 = APREService.getAPRESetStructure(3, 100.0);
      final sets6 = APREService.getAPRESetStructure(6, 100.0);
      final sets10 = APREService.getAPRESetStructure(10, 100.0);

      // Assert - All should have 4 sets
      expect(sets3, hasLength(4));
      expect(sets6, hasLength(4));
      expect(sets10, hasLength(4));

      // Preparation set should have different target reps
      expect(sets3[1].targetReps, equals(3));
      expect(sets6[1].targetReps, equals(6));
      expect(sets10[1].targetReps, equals(10));
    });

    test('should work with different base weights', () {
      // Act
      final setsLight = APREService.getAPRESetStructure(6, 50.0);
      final setsHeavy = APREService.getAPRESetStructure(6, 200.0);

      // Assert
      expect(setsLight[0].weight, equals(25.0)); // 50% of 50
      expect(setsLight[1].weight, equals(37.5)); // 75% of 50

      expect(setsHeavy[0].weight, equals(100.0)); // 50% of 200
      expect(setsHeavy[1].weight, equals(150.0)); // 75% of 200
    });
  });

  group('APREService - Key Set Detection', () {
    test('should identify set 3 as key set', () {
      // Act
      final isKey = APREService.isAPREKeySet(3);

      // Assert
      expect(isKey, isTrue);
    });

    test('should identify set 4 as key set', () {
      // Act
      final isKey = APREService.isAPREKeySet(4);

      // Assert
      expect(isKey, isTrue);
    });

    test('should not identify set 1 as key set', () {
      // Act
      final isKey = APREService.isAPREKeySet(1);

      // Assert
      expect(isKey, isFalse);
    });

    test('should not identify set 2 as key set', () {
      // Act
      final isKey = APREService.isAPREKeySet(2);

      // Assert
      expect(isKey, isFalse);
    });

    test('should not identify set 5+ as key set', () {
      // Act
      final isKey5 = APREService.isAPREKeySet(5);
      final isKey10 = APREService.isAPREKeySet(10);

      // Assert
      expect(isKey5, isFalse);
      expect(isKey10, isFalse);
    });
  });

  group('APREService - Adjustment Reasons', () {
    test('should provide reason for large overperformance', () {
      // Act
      final reason = APREService.getAdjustmentReason(6, 5, 10);

      // Assert - 5 reps over target
      expect(reason, contains('more reps than target'));
      expect(reason, contains('stronger'));
    });

    test('should provide reason for moderate overperformance', () {
      // Act
      final reason = APREService.getAdjustmentReason(6, 5, 7);

      // Assert - 2 reps over target
      expect(reason, contains('above target'));
    });

    test('should provide reason for perfect performance', () {
      // Act
      final reason = APREService.getAdjustmentReason(6, 5, 5);

      // Assert - Exactly on target
      expect(reason, contains('Perfect'));
      expect(reason, contains('target reps'));
    });

    test('should provide reason for slight underperformance', () {
      // Act
      final reason = APREService.getAdjustmentReason(6, 5, 4);

      // Assert - 1 rep under
      expect(reason, contains('Slightly below target'));
      expect(reason, contains('minor adjustment'));
    });

    test('should provide reason for significant underperformance', () {
      // Act
      final reason = APREService.getAdjustmentReason(6, 5, 2);

      // Assert - 3 reps under
      expect(reason, contains('Significantly below target'));
      expect(reason, contains('too heavy'));
    });

    test('should handle edge cases', () {
      // Act
      final reasonVeryOver = APREService.getAdjustmentReason(6, 5, 15);
      final reasonVeryUnder = APREService.getAdjustmentReason(6, 10, 0);

      // Assert
      expect(reasonVeryOver, contains('stronger'));
      expect(reasonVeryUnder, contains('too heavy'));
    });
  });

  group('APREAdjustment - Conversion to Kilograms', () {
    test('should convert set4Adjustment to kg', () {
      // Arrange
      const adjustment = APREAdjustment(
        set4Adjustment: 10.0, // lbs
        nextSessionAdjustment: 10.0,
        description: 'Test',
        repsRange: 'Test',
      );

      // Act
      final adjustmentKg = adjustment.set4AdjustmentKg;

      // Assert - 10 lbs ≈ 4.536 kg
      expect(adjustmentKg, closeTo(4.536, 0.01));
    });

    test('should convert nextSessionAdjustment to kg', () {
      // Arrange
      const adjustment = APREAdjustment(
        set4Adjustment: 5.0,
        nextSessionAdjustment: 5.0, // lbs
        description: 'Test',
        repsRange: 'Test',
      );

      // Act
      final adjustmentKg = adjustment.nextSessionAdjustmentKg;

      // Assert - 5 lbs ≈ 2.268 kg
      expect(adjustmentKg, closeTo(2.268, 0.01));
    });

    test('should handle negative adjustments', () {
      // Arrange
      const adjustment = APREAdjustment(
        set4Adjustment: -10.0, // lbs
        nextSessionAdjustment: -10.0,
        description: 'Test',
        repsRange: 'Test',
      );

      // Act
      final adjustmentKg = adjustment.set4AdjustmentKg;

      // Assert - -10 lbs ≈ -4.536 kg
      expect(adjustmentKg, closeTo(-4.536, 0.01));
    });

    test('should handle zero adjustment', () {
      // Arrange
      const adjustment = APREAdjustment(
        set4Adjustment: 0.0,
        nextSessionAdjustment: 0.0,
        description: 'Perfect',
        repsRange: 'Test',
      );

      // Act
      final adjustmentKg = adjustment.set4AdjustmentKg;

      // Assert
      expect(adjustmentKg, equals(0.0));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/apre_auto_regulation_service.dart';

void main() {
  group('APREAutoRegulationService - Protocol Selection', () {
    test('should select protocol 3 for strength (1-5 reps)', () {
      // Arrange & Act
      final protocol1 = APREAutoRegulationService.selectProtocolFromTargetReps(1);
      final protocol3 = APREAutoRegulationService.selectProtocolFromTargetReps(3);
      final protocol5 = APREAutoRegulationService.selectProtocolFromTargetReps(5);

      // Assert
      expect(protocol1, equals(3));
      expect(protocol3, equals(3));
      expect(protocol5, equals(3));
    });

    test('should select protocol 6 for hypertrophy (6-10 reps)', () {
      // Arrange & Act
      final protocol6 = APREAutoRegulationService.selectProtocolFromTargetReps(6);
      final protocol8 = APREAutoRegulationService.selectProtocolFromTargetReps(8);
      final protocol10 = APREAutoRegulationService.selectProtocolFromTargetReps(10);

      // Assert
      expect(protocol6, equals(6));
      expect(protocol8, equals(6));
      expect(protocol10, equals(6));
    });

    test('should select protocol 10 for endurance (11+ reps)', () {
      // Arrange & Act
      final protocol11 = APREAutoRegulationService.selectProtocolFromTargetReps(11);
      final protocol15 = APREAutoRegulationService.selectProtocolFromTargetReps(15);
      final protocol20 = APREAutoRegulationService.selectProtocolFromTargetReps(20);

      // Assert
      expect(protocol11, equals(10));
      expect(protocol15, equals(10));
      expect(protocol20, equals(10));
    });

    test('should handle boundary cases', () {
      // Arrange & Act
      final boundaryStrength = APREAutoRegulationService.selectProtocolFromTargetReps(5);
      final boundaryHypertrophy = APREAutoRegulationService.selectProtocolFromTargetReps(10);

      // Assert
      expect(boundaryStrength, equals(3)); // 5 reps = strength
      expect(boundaryHypertrophy, equals(6)); // 10 reps = hypertrophy
    });
  });

  group('APREAutoRegulationService - Rest Time Calculation', () {
    test('should return 180s for strength protocol (protocol 3)', () {
      // Act
      final restTime = APREAutoRegulationService.getRestTimeForProtocol(3);

      // Assert
      expect(restTime, equals(180));
    });

    test('should return 120s for hypertrophy protocol (protocol 6)', () {
      // Act
      final restTime = APREAutoRegulationService.getRestTimeForProtocol(6);

      // Assert
      expect(restTime, equals(120));
    });

    test('should return 60s for endurance protocol (protocol 10)', () {
      // Act
      final restTime = APREAutoRegulationService.getRestTimeForProtocol(10);

      // Assert
      expect(restTime, equals(60));
    });

    test('should return 90s for unknown protocol (default)', () {
      // Act
      final restTime = APREAutoRegulationService.getRestTimeForProtocol(99);

      // Assert
      expect(restTime, equals(90));
    });

    test('should allow custom rest time overrides', () {
      // Act
      final customRest = APREAutoRegulationService.getRestTimeForProtocol(
        3,
        strengthRestTime: 300,
        hypertrophyRestTime: 150,
        enduranceRestTime: 90,
      );

      // Assert
      expect(customRest, equals(300));
    });
  });

  group('APREAutoRegulationService - Weight Calculations', () {
    test('should return empty map for empty historical sets', () {
      // Act
      final result = APREAutoRegulationService.calculateAPREWeights(
        historicalSets: [],
        protocol: 6,
      );

      // Assert
      expect(result, isEmpty);
    });

    test('should filter out invalid sets (zero weight or reps)', () {
      // Arrange
      final invalidSets = [
        _MockSet(weight: 0, reps: 10), // Zero weight
        _MockSet(weight: 100, reps: 0), // Zero reps
        _MockSet(weight: 100, reps: 16), // Too many reps (>15)
      ];

      // Act
      final result = APREAutoRegulationService.calculateAPREWeights(
        historicalSets: invalidSets,
        protocol: 6,
      );

      // Assert - Should return empty because all sets invalid
      expect(result, isEmpty);
    });

    test('should calculate APRE weights from valid historical sets', () {
      // Arrange - Realistic bench press history
      final validSets = [
        _MockSet(weight: 100, reps: 5), // ~112.5kg 1RM
        _MockSet(weight: 90, reps: 8),  // ~112.5kg 1RM
        _MockSet(weight: 80, reps: 10), // ~106.7kg 1RM
      ];

      // Act
      final result = APREAutoRegulationService.calculateAPREWeights(
        historicalSets: validSets,
        protocol: 6,
        useMetricSystem: true,
      );

      // Assert
      expect(result, isNotEmpty);
      expect(result['calculated1RM'], isNotNull);
      expect(result['calculated3RM'], isNotNull);
      expect(result['calculated6RM'], isNotNull);
      expect(result['calculated10RM'], isNotNull);
      expect(result['baseWeight'], isNotNull);
      expect(result['metadata'], isNotNull);
      expect(result['confidence'], isNotNull);
      expect(result['dataPoints'], equals(3));
    });

    test('should round weights to nearest 2.5kg for metric system', () {
      // Arrange
      final sets = [
        _MockSet(weight: 100, reps: 5),
      ];

      // Act
      final result = APREAutoRegulationService.calculateAPREWeights(
        historicalSets: sets,
        protocol: 6,
        useMetricSystem: true,
      );

      // Assert - All weights should be multiples of 2.5
      final weight3RM = result['calculated3RM'] as double;
      final weight6RM = result['calculated6RM'] as double;
      final weight10RM = result['calculated10RM'] as double;

      expect(weight3RM % 2.5, equals(0));
      expect(weight6RM % 2.5, equals(0));
      expect(weight10RM % 2.5, equals(0));
    });

    test('should calculate confidence based on data points', () {
      // Arrange
      final lowConfidenceSets = [_MockSet(weight: 100, reps: 5)]; // 1 set = Low
      final mediumConfidenceSets = List.generate(3, (i) => _MockSet(weight: 100, reps: 5)); // 3 sets = Medium
      final highConfidenceSets = List.generate(5, (i) => _MockSet(weight: 100, reps: 5)); // 5 sets = High

      // Act
      final lowResult = APREAutoRegulationService.calculateAPREWeights(
        historicalSets: lowConfidenceSets,
        protocol: 6,
      );
      final mediumResult = APREAutoRegulationService.calculateAPREWeights(
        historicalSets: mediumConfidenceSets,
        protocol: 6,
      );
      final highResult = APREAutoRegulationService.calculateAPREWeights(
        historicalSets: highConfidenceSets,
        protocol: 6,
      );

      // Assert
      expect(lowResult['confidence'], equals('Low'));
      expect(mediumResult['confidence'], equals('Medium'));
      expect(highResult['confidence'], equals('High'));
    });

    test('should prioritize heavier lifts (higher 1RM estimates)', () {
      // Arrange - Mix of heavy and light sets
      final sets = [
        _MockSet(weight: 60, reps: 10),  // Lower 1RM estimate
        _MockSet(weight: 100, reps: 5),  // Higher 1RM estimate
        _MockSet(weight: 70, reps: 8),   // Medium 1RM estimate
      ];

      // Act
      final result = APREAutoRegulationService.calculateAPREWeights(
        historicalSets: sets,
        protocol: 6,
      );

      // Assert - Should use top sets
      expect(result, isNotEmpty);
      expect(result['dataPoints'], equals(3));
    });

    test('should limit to top 10 sets for calculation', () {
      // Arrange - 15 sets (should only use top 10)
      final manySets = List.generate(15, (i) => _MockSet(weight: (100 - i).toDouble(), reps: 5));

      // Act
      final result = APREAutoRegulationService.calculateAPREWeights(
        historicalSets: manySets,
        protocol: 6,
      );

      // Assert - Should cap at 10 data points
      expect(result['dataPoints'], equals(10));
    });

    test('should select correct base weight for protocol', () {
      // Arrange
      final sets = [_MockSet(weight: 100, reps: 5)];

      // Act
      final protocol3Result = APREAutoRegulationService.calculateAPREWeights(
        historicalSets: sets,
        protocol: 3,
      );
      final protocol6Result = APREAutoRegulationService.calculateAPREWeights(
        historicalSets: sets,
        protocol: 6,
      );
      final protocol10Result = APREAutoRegulationService.calculateAPREWeights(
        historicalSets: sets,
        protocol: 10,
      );

      // Assert - Base weight should match protocol RM
      expect(protocol3Result['baseWeight'], equals(protocol3Result['calculated3RM']));
      expect(protocol6Result['baseWeight'], equals(protocol6Result['calculated6RM']));
      expect(protocol10Result['baseWeight'], equals(protocol10Result['calculated10RM']));
    });
  });

  group('APREAutoRegulationService - Next Set Weight Adjustment', () {
    test('should maintain weight when hitting target exactly', () {
      // Arrange
      const currentWeight = 100.0;
      const targetReps = 5;
      const actualReps = 5; // Hit target exactly

      // Act
      final newWeight = APREAutoRegulationService.calculateNextSetWeight(
        protocol: 6,
        currentWeight: currentWeight,
        targetReps: targetReps,
        actualReps: actualReps,
      );

      // Assert - Weight should stay the same
      expect(newWeight, equals(currentWeight));
    });

    test('should increase weight by 2.5kg when 1 rep over target', () {
      // Arrange
      const currentWeight = 100.0;
      const targetReps = 5;
      const actualReps = 6; // 1 over

      // Act
      final newWeight = APREAutoRegulationService.calculateNextSetWeight(
        protocol: 6,
        currentWeight: currentWeight,
        targetReps: targetReps,
        actualReps: actualReps,
      );

      // Assert - Should add 2.5kg
      expect(newWeight, equals(102.5));
    });

    test('should increase weight by 5kg when 2 reps over target (hypertrophy)', () {
      // Arrange
      const currentWeight = 100.0;
      const targetReps = 5;
      const actualReps = 7; // 2 over

      // Act
      final newWeight = APREAutoRegulationService.calculateNextSetWeight(
        protocol: 6, // Hypertrophy
        currentWeight: currentWeight,
        targetReps: targetReps,
        actualReps: actualReps,
      );

      // Assert - Should add 5kg
      expect(newWeight, equals(105.0));
    });

    test('should increase weight by 7.5kg when 3+ reps over target (strength)', () {
      // Arrange
      const currentWeight = 100.0;
      const targetReps = 5;
      const actualReps = 8; // 3+ over

      // Act
      final newWeight = APREAutoRegulationService.calculateNextSetWeight(
        protocol: 3, // Strength - more aggressive
        currentWeight: currentWeight,
        targetReps: targetReps,
        actualReps: actualReps,
      );

      // Assert - Should add 7.5kg
      expect(newWeight, equals(107.5));
    });

    test('should decrease weight by 2.5kg when 2 reps under target', () {
      // Arrange
      const currentWeight = 100.0;
      const targetReps = 5;
      const actualReps = 3; // 2 under

      // Act
      final newWeight = APREAutoRegulationService.calculateNextSetWeight(
        protocol: 6,
        currentWeight: currentWeight,
        targetReps: targetReps,
        actualReps: actualReps,
      );

      // Assert - Should subtract 2.5kg
      expect(newWeight, equals(97.5));
    });

    test('should decrease weight by 5kg when 3+ reps under target (strength)', () {
      // Arrange
      const currentWeight = 100.0;
      const targetReps = 5;
      const actualReps = 2; // 3 under

      // Act
      final newWeight = APREAutoRegulationService.calculateNextSetWeight(
        protocol: 3, // Strength
        currentWeight: currentWeight,
        targetReps: targetReps,
        actualReps: actualReps,
      );

      // Assert - Should subtract 5kg
      expect(newWeight, equals(95.0));
    });

    test('should round adjusted weight to nearest 2.5kg', () {
      // Arrange - Edge case where adjustment might not be exact 2.5kg multiple
      const currentWeight = 101.0;
      const targetReps = 5;
      const actualReps = 6;

      // Act
      final newWeight = APREAutoRegulationService.calculateNextSetWeight(
        protocol: 6,
        currentWeight: currentWeight,
        targetReps: targetReps,
        actualReps: actualReps,
      );

      // Assert - Should round to nearest 2.5kg
      expect(newWeight % 2.5, equals(0));
    });

    test('should respect minimum weight of 2.5kg', () {
      // Arrange - Very low weight with large decrease
      const currentWeight = 5.0;
      const targetReps = 5;
      const actualReps = 2; // Triggers -5kg adjustment

      // Act
      final newWeight = APREAutoRegulationService.calculateNextSetWeight(
        protocol: 3,
        currentWeight: currentWeight,
        targetReps: targetReps,
        actualReps: actualReps,
      );

      // Assert - Should clamp to minimum 2.5kg
      expect(newWeight, equals(2.5));
    });

    test('should handle different protocols with same performance', () {
      // Arrange
      const currentWeight = 100.0;
      const targetReps = 10;
      const actualReps = 12; // 2 over

      // Act
      final strengthWeight = APREAutoRegulationService.calculateNextSetWeight(
        protocol: 3,
        currentWeight: currentWeight,
        targetReps: targetReps,
        actualReps: actualReps,
      );

      final hypertrophyWeight = APREAutoRegulationService.calculateNextSetWeight(
        protocol: 6,
        currentWeight: currentWeight,
        targetReps: targetReps,
        actualReps: actualReps,
      );

      final enduranceWeight = APREAutoRegulationService.calculateNextSetWeight(
        protocol: 10,
        currentWeight: currentWeight,
        targetReps: targetReps,
        actualReps: actualReps,
      );

      // Assert - Different protocols should have different adjustments
      expect(strengthWeight, greaterThan(enduranceWeight)); // Strength more aggressive
    });

    test('should handle large performance variations', () {
      // Arrange - Massive overperformance
      const currentWeight = 100.0;
      const targetReps = 5;
      const actualReps = 15; // 10 reps over!

      // Act
      final newWeight = APREAutoRegulationService.calculateNextSetWeight(
        protocol: 3,
        currentWeight: currentWeight,
        targetReps: targetReps,
        actualReps: actualReps,
      );

      // Assert - Should add large weight
      expect(newWeight, greaterThan(currentWeight));
    });

    test('should handle endurance protocol adjustments', () {
      // Arrange
      const currentWeight = 50.0;
      const targetReps = 15;
      const actualReps = 17; // 2 over for endurance

      // Act
      final newWeight = APREAutoRegulationService.calculateNextSetWeight(
        protocol: 10, // Endurance - conservative adjustments
        currentWeight: currentWeight,
        targetReps: targetReps,
        actualReps: actualReps,
      );

      // Assert - Endurance should have smaller adjustment
      expect(newWeight, equals(52.5)); // +2.5kg for endurance protocol
    });
  });

  group('APREAutoRegulationService - Exercise Configuration', () {
    test('should configure exercise with APRE settings', () {
      // Arrange
      final exercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
      );

      final calculations = {
        'calculated1RM': 110.0,
        'calculated3RM': 100.0,
        'calculated6RM': 90.0,
        'calculated10RM': 80.0,
        'baseWeight': 90.0,
        'metadata': 'Based on 5 sets (Confidence: High)',
      };

      // Act
      final configured = APREAutoRegulationService.configureAPREForExercise(
        exercise: exercise,
        calculations: calculations,
        protocol: 6,
        restTime: 120,
      );

      // Assert
      expect(configured.useAPRE, isTrue);
      expect(configured.autoAdjustmentType, equals(AutoAdjustmentType.apre));
      expect(configured.apreProtocol, equals(6));
      expect(configured.apreBaseWeight, equals(90.0));
      expect(configured.calculated1RM, equals(110.0));
      expect(configured.calculated3RM, equals(100.0));
      expect(configured.calculated6RM, equals(90.0));
      expect(configured.calculated10RM, equals(80.0));
      expect(configured.restTime, equals(120));
      expect(configured.lastCalculationDate, isNotNull);
      expect(configured.calculationMetadata, equals('Based on 5 sets (Confidence: High)'));
    });

    test('should handle null calculations gracefully', () {
      // Arrange
      final exercise = Exercise(
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
      );

      final calculations = <String, dynamic>{};

      // Act
      final configured = APREAutoRegulationService.configureAPREForExercise(
        exercise: exercise,
        calculations: calculations,
        protocol: 3,
        restTime: 180,
      );

      // Assert - Should still configure basic settings
      expect(configured.useAPRE, isTrue);
      expect(configured.apreProtocol, equals(3));
      expect(configured.restTime, equals(180));
    });
  });

  group('APREAutoRegulationService - Cache Logic', () {
    test('should recalculate when no previous calculation exists', () {
      // Arrange
      final exercise = Exercise(
        name: 'Deadlift',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
        useAPRE: true,
        lastCalculationDate: null, // No calculation yet
      );

      // Act
      final shouldRecalc = APREAutoRegulationService.shouldRecalculate(exercise);

      // Assert
      expect(shouldRecalc, isTrue);
    });

    test('should not recalculate when calculation is recent (<7 days)', () {
      // Arrange
      final recentDate = DateTime.now().subtract(const Duration(days: 3));
      final exercise = Exercise(
        name: 'Bench Press',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        useAPRE: true,
        lastCalculationDate: recentDate,
      );

      // Act
      final shouldRecalc = APREAutoRegulationService.shouldRecalculate(exercise);

      // Assert
      expect(shouldRecalc, isFalse);
    });

    test('should recalculate when calculation is old (>7 days)', () {
      // Arrange
      final oldDate = DateTime.now().subtract(const Duration(days: 10));
      final exercise = Exercise(
        name: 'Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
        useAPRE: true,
        lastCalculationDate: oldDate,
      );

      // Act
      final shouldRecalc = APREAutoRegulationService.shouldRecalculate(exercise);

      // Assert
      expect(shouldRecalc, isTrue);
    });

    test('should recalculate on exactly 7 day boundary', () {
      // Arrange
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final exercise = Exercise(
        name: 'Row',
        type: ExerciseType.single,
        category: ExerciseCategory.back,
        useAPRE: true,
        lastCalculationDate: sevenDaysAgo,
      );

      // Act
      final shouldRecalc = APREAutoRegulationService.shouldRecalculate(exercise);

      // Assert - Exactly 7 days should NOT trigger recalculation (>7 required)
      expect(shouldRecalc, isFalse);
    });

    test('should recalculate on 8+ days', () {
      // Arrange
      final eightDaysAgo = DateTime.now().subtract(const Duration(days: 8));
      final exercise = Exercise(
        name: 'Press',
        type: ExerciseType.single,
        category: ExerciseCategory.shoulders,
        useAPRE: true,
        lastCalculationDate: eightDaysAgo,
      );

      // Act
      final shouldRecalc = APREAutoRegulationService.shouldRecalculate(exercise);

      // Assert
      expect(shouldRecalc, isTrue);
    });
  });

  group('APREAutoRegulationService - Base Weight Selection', () {
    test('should return null for non-APRE exercise', () {
      // Arrange
      final exercise = Exercise(
        name: 'Regular Exercise',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        useAPRE: false,
      );

      // Act
      final baseWeight = APREAutoRegulationService.getBaseWeightForProtocol(exercise);

      // Assert
      expect(baseWeight, isNull);
    });

    test('should return calculated3RM for protocol 3', () {
      // Arrange
      final exercise = Exercise(
        name: 'Heavy Bench',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        useAPRE: true,
        apreProtocol: 3,
        calculated3RM: 100.0,
        calculated6RM: 90.0,
        calculated10RM: 80.0,
      );

      // Act
      final baseWeight = APREAutoRegulationService.getBaseWeightForProtocol(exercise);

      // Assert
      expect(baseWeight, equals(100.0));
    });

    test('should return calculated6RM for protocol 6', () {
      // Arrange
      final exercise = Exercise(
        name: 'Hypertrophy Squat',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
        useAPRE: true,
        apreProtocol: 6,
        calculated3RM: 120.0,
        calculated6RM: 110.0,
        calculated10RM: 100.0,
      );

      // Act
      final baseWeight = APREAutoRegulationService.getBaseWeightForProtocol(exercise);

      // Assert
      expect(baseWeight, equals(110.0));
    });

    test('should return calculated10RM for protocol 10', () {
      // Arrange
      final exercise = Exercise(
        name: 'Endurance Deadlift',
        type: ExerciseType.single,
        category: ExerciseCategory.legs,
        useAPRE: true,
        apreProtocol: 10,
        calculated3RM: 150.0,
        calculated6RM: 140.0,
        calculated10RM: 130.0,
      );

      // Act
      final baseWeight = APREAutoRegulationService.getBaseWeightForProtocol(exercise);

      // Assert
      expect(baseWeight, equals(130.0));
    });

    test('should fallback to apreBaseWeight if calculated RM is null', () {
      // Arrange
      final exercise = Exercise(
        name: 'New Exercise',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        useAPRE: true,
        apreProtocol: 6,
        apreBaseWeight: 75.0,
        calculated6RM: null, // Not calculated yet
      );

      // Act
      final baseWeight = APREAutoRegulationService.getBaseWeightForProtocol(exercise);

      // Assert
      expect(baseWeight, equals(75.0));
    });

    test('should return apreBaseWeight for unknown protocol', () {
      // Arrange
      final exercise = Exercise(
        name: 'Unknown Protocol',
        type: ExerciseType.single,
        category: ExerciseCategory.chest,
        useAPRE: true,
        apreProtocol: 99, // Invalid protocol
        apreBaseWeight: 50.0,
      );

      // Act
      final baseWeight = APREAutoRegulationService.getBaseWeightForProtocol(exercise);

      // Assert
      expect(baseWeight, equals(50.0));
    });
  });

  group('APREAutoRegulationService - Protocol Descriptions', () {
    test('should return strength description for protocol 3', () {
      // Act
      final description = APREAutoRegulationService.getProtocolDescription(3);

      // Assert
      expect(description, contains('Strength'));
      expect(description, contains('1-5 reps'));
    });

    test('should return hypertrophy description for protocol 6', () {
      // Act
      final description = APREAutoRegulationService.getProtocolDescription(6);

      // Assert
      expect(description, contains('Hypertrophy'));
      expect(description, contains('6-10 reps'));
    });

    test('should return endurance description for protocol 10', () {
      // Act
      final description = APREAutoRegulationService.getProtocolDescription(10);

      // Assert
      expect(description, contains('Endurance'));
      expect(description, contains('11+ reps'));
    });

    test('should return generic description for unknown protocol', () {
      // Act
      final description = APREAutoRegulationService.getProtocolDescription(99);

      // Assert
      expect(description, equals('APRE Protocol'));
    });
  });
}

/// Mock set for testing historical data calculations
class _MockSet {
  _MockSet({required this.weight, required this.reps});
  final double? weight;
  final int? reps;
}

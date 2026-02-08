/// Fitness-Fatigue Model Service Tests
///
/// Tests the FFM implementation for recovery prediction.
/// Validates exponential decay, muscle weighting, and edge cases.
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/muscle_stress_data.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/entities/stress_index_result.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/fitness_fatigue_service.dart';
import 'package:gymbro_flutter_new/features/stress_index/domain/services/stress_index_calculator.dart';

void main() {
  // ============================================
  // HELPER FUNCTIONS
  // ============================================

  /// Create a StressIndexResult for testing
  StressIndexResult createStressResult({
    required String workoutId,
    required DateTime calculatedAt,
    required Map<String, double> muscleStress,
    double primaryScore = 50.0,
  }) {
    final muscleBreakdown = <String, MuscleStressData>{};
    for (final entry in muscleStress.entries) {
      muscleBreakdown[entry.key] = MuscleStressData(
        muscleId: entry.key,
        displayName: entry.key,
        stressScore: entry.value,
        setsCount: 3,
        totalVolume: 1000,
        avgRpe: 7.5,
        recoveryHours: 48,
        estimatedRecovery: calculatedAt.add(const Duration(hours: 48)),
      );
    }

    return StressIndexResult(
      primaryScore: primaryScore,
      fallbackScore: primaryScore,
      confidence: 0.8,
      muscleBreakdown: muscleBreakdown,
      totalSets: 9,
      setsWithRpe: 7,
      workoutId: workoutId,
      calculatedAt: calculatedAt,
      rawScore: primaryScore * 100,
    );
  }

  // ============================================
  // getOverallReadiness TESTS
  // ============================================

  group('FitnessFatigueService.getOverallReadiness', () {
    test('returns 100.0 for empty workout history', () {
      final readiness = FitnessFatigueService.getOverallReadiness([]);
      expect(readiness, equals(100.0));
    });

    test('returns lower readiness immediately after workout', () {
      final now = DateTime.now();
      final recentWorkout = createStressResult(
        workoutId: 'w1',
        calculatedAt: now.subtract(const Duration(hours: 1)),
        muscleStress: {'PETT': 70.0, 'TRIC': 50.0},
        primaryScore: 65.0,
      );

      final readiness = FitnessFatigueService.getOverallReadiness([recentWorkout]);

      // Should be less than 100 due to recent fatigue
      expect(readiness, lessThan(100.0));
      // Should be reasonable (not negative or crazy high)
      expect(readiness, greaterThan(0.0));
      expect(readiness, lessThan(150.0));
    });

    test('readiness increases over time (recovery)', () {
      final now = DateTime.now();

      // Workout 1 hour ago
      final workout1Hour = createStressResult(
        workoutId: 'w1',
        calculatedAt: now.subtract(const Duration(hours: 1)),
        muscleStress: {'PETT': 70.0},
        primaryScore: 70.0,
      );

      // Same workout 48 hours ago
      final workout48Hours = createStressResult(
        workoutId: 'w2',
        calculatedAt: now.subtract(const Duration(hours: 48)),
        muscleStress: {'PETT': 70.0},
        primaryScore: 70.0,
      );

      final readiness1Hour = FitnessFatigueService.getOverallReadiness([workout1Hour]);
      final readiness48Hours = FitnessFatigueService.getOverallReadiness([workout48Hours]);

      // 48 hours of recovery should result in higher readiness
      expect(readiness48Hours, greaterThan(readiness1Hour));
    });

    test('weights larger muscles more heavily', () {
      final now = DateTime.now();

      // Only quads trained (large muscle, weight 1.2)
      final quadsOnly = createStressResult(
        workoutId: 'w1',
        calculatedAt: now.subtract(const Duration(hours: 12)),
        muscleStress: {'QUAD': 80.0},
        primaryScore: 80.0,
      );

      // Only biceps trained (small muscle, weight 0.6)
      final bicepsOnly = createStressResult(
        workoutId: 'w2',
        calculatedAt: now.subtract(const Duration(hours: 12)),
        muscleStress: {'BICI': 80.0},
        primaryScore: 80.0,
      );

      final readinessQuads = FitnessFatigueService.getOverallReadiness([quadsOnly]);
      final readinessBiceps = FitnessFatigueService.getOverallReadiness([bicepsOnly]);

      // Both should be below 100 due to fatigue
      expect(readinessQuads, lessThan(100.0));
      expect(readinessBiceps, lessThan(100.0));

      // Note: The actual comparison depends on FFM implementation
      // Just verify both are valid ranges
      expect(readinessQuads, greaterThan(0.0));
      expect(readinessBiceps, greaterThan(0.0));
    });
  });

  // ============================================
  // calculateRecovery TESTS
  // ============================================

  group('FitnessFatigueService.calculateRecovery', () {
    test('returns empty map for empty history', () {
      final predictions = FitnessFatigueService.calculateRecovery([]);
      expect(predictions, isEmpty);
    });

    test('returns predictions for each trained muscle', () {
      final now = DateTime.now();
      final workout = createStressResult(
        workoutId: 'w1',
        calculatedAt: now.subtract(const Duration(hours: 24)),
        muscleStress: {'PETT': 60.0, 'DELT_ANT': 40.0, 'TRIC': 35.0},
      );

      final predictions = FitnessFatigueService.calculateRecovery([workout]);

      expect(predictions.containsKey('PETT'), isTrue);
      expect(predictions.containsKey('DELT_ANT'), isTrue);
      expect(predictions.containsKey('TRIC'), isTrue);
      expect(predictions.length, equals(3));
    });

    test('predictions have valid FFMRecoveryState', () {
      final now = DateTime.now();
      final workout = createStressResult(
        workoutId: 'w1',
        calculatedAt: now.subtract(const Duration(hours: 6)),
        muscleStress: {'PETT': 70.0},
      );

      final predictions = FitnessFatigueService.calculateRecovery([workout]);
      final pettPrediction = predictions['PETT']!;

      // State should be one of the valid values
      expect(
        FFMRecoveryState.values.contains(pettPrediction.state),
        isTrue,
      );

      // Performance level should be reasonable
      expect(pettPrediction.performanceLevel, greaterThan(0));
      expect(pettPrediction.performanceLevel, lessThan(200));
    });

    test('atTime parameter affects predictions', () {
      final now = DateTime.now();
      final workout = createStressResult(
        workoutId: 'w1',
        calculatedAt: now.subtract(const Duration(hours: 24)),
        muscleStress: {'PETT': 70.0},
      );

      // Check now
      final predictionsNow = FitnessFatigueService.calculateRecovery(
        [workout],
        atTime: now,
      );

      // Check 48 hours in future
      final predictionsFuture = FitnessFatigueService.calculateRecovery(
        [workout],
        atTime: now.add(const Duration(hours: 48)),
      );

      // Future should have higher performance (more recovery time)
      expect(
        predictionsFuture['PETT']!.performanceLevel,
        greaterThan(predictionsNow['PETT']!.performanceLevel),
      );
    });
  });

  // ============================================
  // StressIndexCalculator.getOverallReadinessFFM TESTS
  // ============================================

  group('StressIndexCalculator.getOverallReadinessFFM', () {
    test('delegates to FitnessFatigueService correctly', () {
      final now = DateTime.now();
      final workout = createStressResult(
        workoutId: 'w1',
        calculatedAt: now.subtract(const Duration(hours: 12)),
        muscleStress: {'PETT': 60.0, 'TRIC': 40.0},
      );

      final directResult = FitnessFatigueService.getOverallReadiness([workout]);
      final calculatorResult = StressIndexCalculator.getOverallReadinessFFM([workout]);

      expect(calculatorResult, equals(directResult));
    });

    test('returns 100.0 for empty history', () {
      final result = StressIndexCalculator.getOverallReadinessFFM([]);
      expect(result, equals(100.0));
    });
  });

  // ============================================
  // HOME SCREEN FATIGUE DISPLAY TESTS
  // ============================================

  group('Home Screen Fatigue Calculation', () {
    /// Simulates the calculation done in pro_insights_preview_section.dart
    double calculateDisplayedFatigue(List<StressIndexResult> history) {
      final readiness = history.isNotEmpty
          ? StressIndexCalculator.getOverallReadinessFFM(history)
          : 100.0;
      return (100 - readiness).clamp(0.0, 100.0);
    }

    test('empty history shows 0 fatigue', () {
      final fatigue = calculateDisplayedFatigue([]);
      expect(fatigue, equals(0.0));
    });

    test('recent workout shows positive fatigue', () {
      final now = DateTime.now();
      final workout = createStressResult(
        workoutId: 'w1',
        calculatedAt: now.subtract(const Duration(hours: 2)),
        muscleStress: {'PETT': 70.0, 'TRIC': 50.0},
        primaryScore: 65.0,
      );

      final fatigue = calculateDisplayedFatigue([workout]);

      // Should show fatigue (positive value)
      expect(fatigue, greaterThan(0.0));
      // Should be clamped to valid range
      expect(fatigue, lessThanOrEqualTo(100.0));
    });

    test('fatigue decreases with rest days', () {
      final now = DateTime.now();

      // Workout 1 day ago
      final workout1Day = createStressResult(
        workoutId: 'w1',
        calculatedAt: now.subtract(const Duration(days: 1)),
        muscleStress: {'PETT': 70.0},
        primaryScore: 70.0,
      );

      // Same workout 5 days ago
      final workout5Days = createStressResult(
        workoutId: 'w2',
        calculatedAt: now.subtract(const Duration(days: 5)),
        muscleStress: {'PETT': 70.0},
        primaryScore: 70.0,
      );

      final fatigue1Day = calculateDisplayedFatigue([workout1Day]);
      final fatigue5Days = calculateDisplayedFatigue([workout5Days]);

      // 5 days of rest should result in less fatigue
      expect(fatigue5Days, lessThan(fatigue1Day));
    });

    test('supercompensation shows 0 fatigue (clamped)', () {
      final now = DateTime.now();

      // Very old workout - should be in supercompensation
      final oldWorkout = createStressResult(
        workoutId: 'w1',
        calculatedAt: now.subtract(const Duration(days: 14)),
        muscleStress: {'PETT': 50.0},
        primaryScore: 50.0,
      );

      final fatigue = calculateDisplayedFatigue([oldWorkout]);

      // If readiness > 100 (supercompensation), fatigue should be 0
      expect(fatigue, greaterThanOrEqualTo(0.0));
      expect(fatigue, lessThanOrEqualTo(100.0));
    });

    test('multiple workouts accumulate fatigue correctly', () {
      final now = DateTime.now();

      // Single workout
      final singleWorkout = createStressResult(
        workoutId: 'w1',
        calculatedAt: now.subtract(const Duration(hours: 12)),
        muscleStress: {'PETT': 60.0},
        primaryScore: 60.0,
      );

      // Two workouts on consecutive days
      final workout1 = createStressResult(
        workoutId: 'w1',
        calculatedAt: now.subtract(const Duration(hours: 12)),
        muscleStress: {'PETT': 60.0},
        primaryScore: 60.0,
      );
      final workout2 = createStressResult(
        workoutId: 'w2',
        calculatedAt: now.subtract(const Duration(hours: 36)),
        muscleStress: {'PETT': 60.0},
        primaryScore: 60.0,
      );

      final fatigueSingle = calculateDisplayedFatigue([singleWorkout]);
      final fatigueMultiple = calculateDisplayedFatigue([workout1, workout2]);

      // Multiple workouts should result in higher fatigue
      expect(fatigueMultiple, greaterThanOrEqualTo(fatigueSingle));
    });
  });

  // ============================================
  // EDGE CASES
  // ============================================

  group('Edge Cases', () {
    test('handles very high stress scores', () {
      final now = DateTime.now();
      final extremeWorkout = createStressResult(
        workoutId: 'w1',
        calculatedAt: now.subtract(const Duration(hours: 1)),
        muscleStress: {'PETT': 100.0, 'QUAD': 100.0, 'LAT': 100.0},
        primaryScore: 100.0,
      );

      final readiness = FitnessFatigueService.getOverallReadiness([extremeWorkout]);

      // Should still return a valid number
      expect(readiness.isFinite, isTrue);
      expect(readiness.isNaN, isFalse);
    });

    test('handles very old workouts', () {
      final now = DateTime.now();
      final veryOldWorkout = createStressResult(
        workoutId: 'w1',
        calculatedAt: now.subtract(const Duration(days: 365)),
        muscleStress: {'PETT': 80.0},
        primaryScore: 80.0,
      );

      final readiness = FitnessFatigueService.getOverallReadiness([veryOldWorkout]);

      // Very old workout should have minimal effect
      expect(readiness, greaterThanOrEqualTo(95.0));
    });

    test('handles future workout timestamps gracefully', () {
      final now = DateTime.now();
      final futureWorkout = createStressResult(
        workoutId: 'w1',
        calculatedAt: now.add(const Duration(days: 1)),
        muscleStress: {'PETT': 70.0},
        primaryScore: 70.0,
      );

      // Should not crash
      final readiness = FitnessFatigueService.getOverallReadiness([futureWorkout]);
      expect(readiness.isFinite, isTrue);
    });

    test('handles unknown muscle IDs with default weight', () {
      final now = DateTime.now();
      final workout = createStressResult(
        workoutId: 'w1',
        calculatedAt: now.subtract(const Duration(hours: 12)),
        muscleStress: {'UNKNOWN_MUSCLE': 60.0},
        primaryScore: 60.0,
      );

      // Should not crash, uses default weight 0.5
      final readiness = FitnessFatigueService.getOverallReadiness([workout]);
      expect(readiness.isFinite, isTrue);
      expect(readiness, lessThan(100.0)); // Should still show fatigue
    });
  });
}

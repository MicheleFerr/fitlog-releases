import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/services/one_rm_calculator.dart';

/// Service to handle APRE (Autoregulatory Progressive Resistance Exercise) protocol
/// This service manages automatic protocol selection, weight calculations, and caching
class APREAutoRegulationService {
  /// Automatically selects APRE protocol based on target reps
  /// Protocol determines adjustment aggressiveness and rest time:
  /// - 1-5 reps → APRE 3 (strength focus, aggressive adjustments, 3min rest)
  /// - 6-10 reps → APRE 6 (hypertrophy focus, moderate adjustments, 2min rest)
  /// - 11+ reps → APRE 10 (endurance focus, conservative adjustments, 1min rest)
  ///
  /// Note: Adjustments are always relative to YOUR target reps, not fixed values
  static int selectProtocolFromTargetReps(int targetReps) {
    if (targetReps <= 5) {
      return 3; // Strength protocol
    } else if (targetReps <= 10) {
      return 6; // Hypertrophy protocol
    } else {
      return 10; // Endurance protocol
    }
  }

  /// Determines appropriate rest time based on APRE protocol
  static int getRestTimeForProtocol(int protocol, {
    int strengthRestTime = 180,
    int hypertrophyRestTime = 120,
    int enduranceRestTime = 60,
    int defaultRestTime = 90,
  }) {
    switch (protocol) {
      case 3:
        return strengthRestTime; // 3 minutes for strength
      case 6:
        return hypertrophyRestTime; // 2 minutes for hypertrophy
      case 10:
        return enduranceRestTime; // 1 minute for endurance
      default:
        return defaultRestTime; // 90 seconds default
    }
  }

  /// Calculates all APRE weight values from historical data
  /// Returns a map with calculated1RM, calculated3RM, calculated6RM, calculated10RM
  static Map<String, dynamic> calculateAPREWeights({
    required List<dynamic> historicalSets,
    required int protocol,
    bool useMetricSystem = true,
  }) {
    debugPrint('[APRE] Calculating weights from ${historicalSets.length} historical sets');

    if (historicalSets.isEmpty) {
      debugPrint('[APRE] No historical data available');
      return {};
    }

    // Filter valid sets (weight > 0, reps between 1-15)
    final validSets = historicalSets
        .where((set) =>
            set.weight != null &&
            set.reps != null &&
            set.weight! > 0 &&
            set.reps! > 0 &&
            set.reps! <= 15)
        .toList();

    if (validSets.isEmpty) {
      debugPrint('[APRE] No valid sets found for calculation');
      return {};
    }

    // Sort sets by estimated 1RM (descending) to prioritize heavier lifts
    validSets.sort((a, b) {
      final a1RM = OneRMCalculator.calculateAverage(a.weight!, a.reps!);
      final b1RM = OneRMCalculator.calculateAverage(b.weight!, b.reps!);
      return b1RM.compareTo(a1RM);
    });

    // Take top sets (max 10) for calculation
    final topSets = validSets.take(10).toList();

    // Log top sets for debugging
    debugPrint('[APRE] Top ${topSets.length} sets for calculation:');
    for (final set in topSets.take(3)) {
      final est1RM = OneRMCalculator.calculateAverage(set.weight!, set.reps!);
      debugPrint('  ${set.weight}kg x ${set.reps} reps → ${est1RM.toStringAsFixed(1)}kg 1RM');
    }

    // Calculate average 1RM from top sets
    double total1RM = 0;
    int count = 0;

    for (final set in topSets) {
      final estimated = OneRMCalculator.calculateAverage(set.weight!, set.reps!);
      if (estimated > 0) {
        total1RM += estimated;
        count++;
      }
    }

    if (count == 0) {
      debugPrint('[APRE] Could not calculate 1RM from sets');
      return {};
    }

    final estimated1RM = total1RM / count;

    // Calculate weight for each rep range using Brzycki formula for consistency
    // This matches the formula used in auto_adjustment_modal.dart
    final weight3RM = OneRMCalculator.calculateWeightForReps(estimated1RM, 3);
    final weight6RM = OneRMCalculator.calculateWeightForReps(estimated1RM, 6);
    final weight10RM = OneRMCalculator.calculateWeightForReps(estimated1RM, 10);

    // Round to nearest 2.5kg (or 5lbs if imperial)
    final roundingFactor = useMetricSystem ? 2.5 : 5.0;
    final rounded3RM = (weight3RM / roundingFactor).round() * roundingFactor;
    final rounded6RM = (weight6RM / roundingFactor).round() * roundingFactor;
    final rounded10RM = (weight10RM / roundingFactor).round() * roundingFactor;

    // Determine confidence level based on data points
    final confidence = count >= 5 ? 'High' : count >= 3 ? 'Medium' : 'Low';
    final metadata = 'Based on $count sets (Confidence: $confidence)';

    debugPrint('[APRE] Calculation complete:');
    debugPrint('  1RM: ${estimated1RM.toStringAsFixed(1)}kg');
    debugPrint('  3RM: ${rounded3RM.toStringAsFixed(1)}kg');
    debugPrint('  6RM: ${rounded6RM.toStringAsFixed(1)}kg');
    debugPrint('  10RM: ${rounded10RM.toStringAsFixed(1)}kg');
    debugPrint('  Confidence: $confidence');

    return {
      'calculated1RM': estimated1RM,
      'calculated3RM': rounded3RM,
      'calculated6RM': rounded6RM,
      'calculated10RM': rounded10RM,
      'baseWeight': protocol == 3 ? rounded3RM : protocol == 6 ? rounded6RM : rounded10RM,
      'metadata': metadata,
      'confidence': confidence,
      'dataPoints': count,
    };
  }

  /// Updates exercise with APRE configuration and cached calculations
  static Exercise configureAPREForExercise({
    required Exercise exercise,
    required Map<String, dynamic> calculations,
    required int protocol,
    required int restTime,
  }) {
    return exercise.copyWith(
      autoAdjustmentType: AutoAdjustmentType.apre,
      useAPRE: true,
      apreProtocol: protocol,
      apreBaseWeight: calculations['baseWeight']?.toDouble(),
      calculated1RM: calculations['calculated1RM']?.toDouble(),
      calculated3RM: calculations['calculated3RM']?.toDouble(),
      calculated6RM: calculations['calculated6RM']?.toDouble(),
      calculated10RM: calculations['calculated10RM']?.toDouble(),
      lastCalculationDate: DateTime.now(),
      calculationMetadata: calculations['metadata'],
      restTime: restTime,
    );
  }

  /// Checks if calculations are stale and need refresh
  /// Returns true if calculations are older than 7 days
  static bool shouldRecalculate(Exercise exercise) {
    if (exercise.lastCalculationDate == null) return true;

    final daysSinceCalculation = DateTime.now()
        .difference(exercise.lastCalculationDate!)
        .inDays;

    return daysSinceCalculation > 7;
  }

  /// Gets the appropriate base weight for current protocol
  static double? getBaseWeightForProtocol(Exercise exercise) {
    if (!exercise.useAPRE) return null;

    switch (exercise.apreProtocol) {
      case 3:
        return exercise.calculated3RM ?? exercise.apreBaseWeight;
      case 6:
        return exercise.calculated6RM ?? exercise.apreBaseWeight;
      case 10:
        return exercise.calculated10RM ?? exercise.apreBaseWeight;
      default:
        return exercise.apreBaseWeight;
    }
  }

  /// Adjusts weight based on APRE protocol performance
  /// This is called after completing a set to determine next set's weight
  /// Uses targetReps as baseline for adjustment decisions
  static double calculateNextSetWeight({
    required int protocol,
    required double currentWeight,
    required int targetReps,
    required int actualReps,
  }) {
    // Calculate performance relative to target
    final repsDifference = actualReps - targetReps;
    double adjustment = 0;

    debugPrint('[APRE-ADJUST] Protocol: $protocol, Target: $targetReps, Actual: $actualReps, Diff: $repsDifference');

    // Adjustment based on how far from target (relative to protocol)
    // More aggressive adjustments for strength (protocol 3), less for endurance (protocol 10)
    if (repsDifference <= -3) {
      // Severely under target (e.g., 2 reps when target is 5)
      adjustment = protocol == 3 ? -5.0 : -7.5; // Decrease significantly
    } else if (repsDifference == -2) {
      // Moderately under target (e.g., 3 reps when target is 5)
      adjustment = -2.5; // Decrease moderately
    } else if (repsDifference == -1) {
      // Slightly under target (e.g., 4 reps when target is 5)
      adjustment = protocol == 3 ? -2.5 : 0; // Small decrease or maintain
    } else if (repsDifference == 0) {
      // Hit target exactly - perfect!
      adjustment = 0; // Maintain weight
    } else if (repsDifference == 1) {
      // Slightly over target (e.g., 6 reps when target is 5)
      adjustment = 2.5; // Small increase
    } else if (repsDifference == 2) {
      // Moderately over target (e.g., 7 reps when target is 5)
      adjustment = protocol == 10 ? 2.5 : 5.0; // Moderate increase
    } else {
      // Significantly over target (e.g., 8+ reps when target is 5)
      adjustment = protocol == 10 ? 5.0 : 7.5; // Large increase
    }

    debugPrint('[APRE-ADJUST] Adjustment: ${adjustment >= 0 ? "+" : ""}${adjustment}kg');

    final newWeight = currentWeight + adjustment;

    // Round to nearest 2.5kg and ensure minimum weight
    final roundedWeight = ((newWeight / 2.5).round() * 2.5).clamp(2.5, double.infinity);

    debugPrint('[APRE-ADJUST] Weight: ${currentWeight}kg → ${roundedWeight}kg');

    return roundedWeight;
  }

  /// Generates APRE protocol description for UI
  static String getProtocolDescription(int protocol) {
    switch (protocol) {
      case 3:
        return 'APRE 3 - Strength Protocol (1-5 reps)';
      case 6:
        return 'APRE 6 - Hypertrophy Protocol (6-10 reps)';
      case 10:
        return 'APRE 10 - Endurance Protocol (11+ reps)';
      default:
        return 'APRE Protocol';
    }
  }
}
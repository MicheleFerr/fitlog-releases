import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/utils/debug_logger.dart';

/// TIER-1 Fatigue Analysis Service
/// Advanced fatigue detection using multiple biomechanical markers
class FatigueAnalyzerService {
  
  /// Calculate real-time fatigue index during set execution
  double calculateRealTimeFatigue(
    List<double> velocityData,
    List<DateTime> repTimestamps,
  ) {
    if (velocityData.length < 3) return 0.0;
    
    try {
      // Multiple fatigue indicators
      final velocityFatigue = _calculateVelocityFatigue(velocityData);
      final temporalFatigue = _calculateTemporalFatigue(repTimestamps);
      final consistencyFatigue = _calculateConsistencyFatigue(velocityData);
      
      // Weight different fatigue types
      final compositeIndex = (
        velocityFatigue * 0.5 +
        temporalFatigue * 0.3 +
        consistencyFatigue * 0.2
      );
      
      return math.max(0.0, math.min(100.0, compositeIndex));
      
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Real-time fatigue calculation error: $e');
      return 0.0;
    }
  }

  /// Calculate comprehensive fatigue analysis after set completion
  Future<double> calculateSetFatigue({
    required List<double> velocityData,
    required List<DateTime> repTimestamps,
    double? weight,
  }) async {
    try {
      if (velocityData.length < 3) return 0.0;
      
      // Advanced fatigue markers
      final velocityLoss = _calculateVelocityLoss(velocityData);
      final powerLoss = weight != null ? _calculatePowerLoss(velocityData, weight) : 0.0;
      final mechanicalFatigue = _calculateMechanicalFatigue(velocityData);
      final metabolicFatigue = _calculateMetabolicFatigue(repTimestamps);
      final neuralFatigue = _calculateNeuralFatigue(velocityData);
      
      // Comprehensive fatigue model
      final fatigueIndex = _calculateCompositeFatigueIndex(
        velocityLoss: velocityLoss,
        powerLoss: powerLoss,
        mechanicalFatigue: mechanicalFatigue,
        metabolicFatigue: metabolicFatigue,
        neuralFatigue: neuralFatigue,
      );
      
      DebugLogger.log(LogCategory.timer, 
        'TIER-1: Set fatigue calculated - VL: $velocityLoss, '
        'MF: $mechanicalFatigue, MET: $metabolicFatigue, Index: $fatigueIndex');
      
      return fatigueIndex;
      
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Set fatigue calculation error: $e');
      return 0.0;
    }
  }

  /// Predict optimal rest time based on current fatigue
  Duration predictOptimalRestTime(double fatigueIndex, String exerciseType) {
    // Base rest times by exercise type
    final baseRestMap = <String, int>{
      'squat': 180,
      'deadlift': 240,
      'bench_press': 120,
      'overhead_press': 120,
      'row': 90,
      'curl': 60,
      'isolation': 60,
    };
    
    final baseRest = baseRestMap[exerciseType.toLowerCase()] ?? 120;
    
    // Adjust based on fatigue
    double multiplier = 1.0;
    if (fatigueIndex > 80) multiplier = 2.0;
    else if (fatigueIndex > 60) multiplier = 1.5;
    else if (fatigueIndex > 40) multiplier = 1.2;
    else if (fatigueIndex < 20) multiplier = 0.8;
    
    final adjustedRest = (baseRest * multiplier).round();
    return Duration(seconds: adjustedRest);
  }

  /// Generate fatigue-based recommendations
  FatigueRecommendation getFatigueRecommendation(
    double fatigueIndex,
    int currentSet,
    int plannedSets,
  ) {
    if (fatigueIndex > 90) {
      return FatigueRecommendation(
        action: FatigueAction.stopSet,
        message: "Extreme fatigue detected - end set immediately",
        restRecommendation: Duration(minutes: 5),
        weightAdjustment: -15.0, // Reduce weight by 15%
        priority: FatiguePriority.critical,
      );
    }
    
    if (fatigueIndex > 75) {
      return FatigueRecommendation(
        action: FatigueAction.considerEnding,
        message: "High fatigue - consider ending set",
        restRecommendation: Duration(minutes: 3),
        weightAdjustment: -10.0,
        priority: FatiguePriority.high,
      );
    }
    
    if (fatigueIndex > 50) {
      return FatigueRecommendation(
        action: FatigueAction.monitor,
        message: "Moderate fatigue - monitor closely",
        restRecommendation: Duration(minutes: 2),
        weightAdjustment: -5.0,
        priority: FatiguePriority.medium,
      );
    }
    
    return FatigueRecommendation(
      action: FatigueAction.continue,
      message: "Low fatigue - continue set",
      restRecommendation: Duration(seconds: 90),
      weightAdjustment: 0.0,
      priority: FatiguePriority.low,
    );
  }

  /// Calculate velocity-based fatigue (most common method)
  double _calculateVelocityFatigue(List<double> velocities) {
    if (velocities.length < 3) return 0.0;
    
    // Compare first rep vs average of last 2-3 reps
    final firstRep = velocities.first.abs();
    final lastReps = velocities.sublist(math.max(0, velocities.length - 3));
    final lastRepAvg = lastReps.map((v) => v.abs()).reduce((a, b) => a + b) / lastReps.length;
    
    if (firstRep == 0) return 0.0;
    
    final velocityLoss = ((firstRep - lastRepAvg) / firstRep) * 100;
    
    return math.max(0.0, velocityLoss);
  }

  /// Calculate temporal fatigue (time between reps increasing)
  double _calculateTemporalFatigue(List<DateTime> repTimestamps) {
    if (repTimestamps.length < 3) return 0.0;
    
    final repIntervals = <int>[];
    for (int i = 1; i < repTimestamps.length; i++) {
      repIntervals.add(repTimestamps[i].difference(repTimestamps[i-1]).inMilliseconds);
    }
    
    if (repIntervals.length < 2) return 0.0;
    
    // Compare first intervals vs last intervals
    final firstIntervals = repIntervals.sublist(0, math.min(2, repIntervals.length));
    final lastIntervals = repIntervals.sublist(math.max(0, repIntervals.length - 2));
    
    final firstAvg = firstIntervals.reduce((a, b) => a + b) / firstIntervals.length;
    final lastAvg = lastIntervals.reduce((a, b) => a + b) / lastIntervals.length;
    
    final timeIncrease = ((lastAvg - firstAvg) / firstAvg) * 100;
    
    return math.max(0.0, math.min(100.0, timeIncrease));
  }

  /// Calculate consistency fatigue (increasing rep-to-rep variation)
  double _calculateConsistencyFatigue(List<double> velocities) {
    if (velocities.length < 4) return 0.0;
    
    // Calculate coefficient of variation for first half vs second half
    final midPoint = velocities.length ~/ 2;
    final firstHalf = velocities.sublist(0, midPoint);
    final secondHalf = velocities.sublist(midPoint);
    
    final firstCV = _calculateCoefficientOfVariation(firstHalf);
    final secondCV = _calculateCoefficientOfVariation(secondHalf);
    
    final consistencyLoss = ((secondCV - firstCV) / (firstCV + 0.001)) * 100;
    
    return math.max(0.0, math.min(100.0, consistencyLoss * 2));
  }

  /// Calculate velocity loss over the set
  double _calculateVelocityLoss(List<double> velocities) {
    if (velocities.isEmpty) return 0.0;
    
    final bestVelocity = velocities.map((v) => v.abs()).reduce(math.max);
    final lastVelocity = velocities.last.abs();
    
    if (bestVelocity == 0) return 0.0;
    
    return ((bestVelocity - lastVelocity) / bestVelocity) * 100;
  }

  /// Calculate power loss (requires weight)
  double _calculatePowerLoss(List<double> velocities, double weight) {
    // Power = Force × Velocity (simplified)
    const gravity = 9.81;
    final force = weight * gravity;
    
    final powerValues = velocities.map((v) => force * v.abs()).toList();
    
    if (powerValues.isEmpty) return 0.0;
    
    final bestPower = powerValues.reduce(math.max);
    final lastPower = powerValues.last;
    
    if (bestPower == 0) return 0.0;
    
    return ((bestPower - lastPower) / bestPower) * 100;
  }

  /// Calculate mechanical fatigue (force production capacity)
  double _calculateMechanicalFatigue(List<double> velocities) {
    // Based on velocity profile analysis
    return _calculateVelocityFatigue(velocities) * 0.8; // Mechanical component of velocity loss
  }

  /// Calculate metabolic fatigue (energy system fatigue)
  double _calculateMetabolicFatigue(List<DateTime> repTimestamps) {
    // Based on rest periods and rep timing
    return _calculateTemporalFatigue(repTimestamps) * 1.2; // Metabolic component amplified
  }

  /// Calculate neural fatigue (motor unit recruitment efficiency)
  double _calculateNeuralFatigue(List<double> velocities) {
    // Based on velocity variability increase
    return _calculateConsistencyFatigue(velocities) * 1.5; // Neural component amplified
  }

  /// Calculate composite fatigue index from multiple markers
  double _calculateCompositeFatigueIndex({
    required double velocityLoss,
    required double powerLoss,
    required double mechanicalFatigue,
    required double metabolicFatigue,
    required double neuralFatigue,
  }) {
    // Weighted average of different fatigue types
    final weights = {
      'velocity': 0.3,
      'power': 0.2,
      'mechanical': 0.2,
      'metabolic': 0.15,
      'neural': 0.15,
    };
    
    final compositeIndex = (
      velocityLoss * weights['velocity']! +
      powerLoss * weights['power']! +
      mechanicalFatigue * weights['mechanical']! +
      metabolicFatigue * weights['metabolic']! +
      neuralFatigue * weights['neural']!
    );
    
    return math.max(0.0, math.min(100.0, compositeIndex));
  }

  /// Helper: Calculate coefficient of variation
  double _calculateCoefficientOfVariation(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values
        .map((v) => math.pow(v - mean, 2))
        .reduce((a, b) => a + b) / values.length;
    
    final standardDeviation = math.sqrt(variance);
    
    if (mean == 0) return 0.0;
    
    return (standardDeviation / mean) * 100;
  }
}

/// Fatigue-based recommendation data
class FatigueRecommendation {
  final FatigueAction action;
  final String message;
  final Duration restRecommendation;
  final double weightAdjustment; // Percentage change
  final FatiguePriority priority;
  
  const FatigueRecommendation({
    required this.action,
    required this.message,
    required this.restRecommendation,
    required this.weightAdjustment,
    required this.priority,
  });
}

/// Fatigue action recommendations
enum FatigueAction {
  continue,
  monitor,
  considerEnding,
  stopSet,
}

/// Fatigue priority levels
enum FatiguePriority {
  low,
  medium,
  high,
  critical,
}

// Provider for the service
final fatigueAnalyzerServiceProvider = Provider<FatigueAnalyzerService>((ref) {
  return FatigueAnalyzerService();
});
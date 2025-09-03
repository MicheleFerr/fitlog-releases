import '../entities/smart_training_metrics.dart';
import '../entities/progressive_overload_analysis.dart';
import '../../workout/domain/entities/workout.dart';
import '../../workout/domain/entities/exercise.dart';

/// Core engine for progressive overload calculations and analysis
class ProgressiveOverloadEngine {
  
  /// Calculate 1RM using Epley formula with RPE adjustment
  static double calculateOneRM(double weight, int reps, {int? rpe}) {
    if (reps == 1) return weight;
    
    // Base Epley formula: 1RM = weight * (1 + reps/30)
    double baseOneRM = weight * (1 + reps / 30);
    
    // RPE adjustment factor (more accurate for higher RPE values)
    if (rpe != null && rpe >= 6 && rpe <= 10) {
      double rpeAdjustment = _getRPEAdjustmentFactor(reps, rpe);
      baseOneRM = weight / rpeAdjustment;
    }
    
    return baseOneRM;
  }
  
  /// Get RPE adjustment factor based on reps and RPE
  static double _getRPEAdjustmentFactor(int reps, int rpe) {
    // RPE to percentage of 1RM conversion table
    const Map<int, Map<int, double>> rpeChart = {
      1: {10: 1.00, 9: 0.98, 8: 0.95, 7: 0.92, 6: 0.88},
      2: {10: 0.95, 9: 0.92, 8: 0.90, 7: 0.87, 6: 0.84},
      3: {10: 0.92, 9: 0.90, 8: 0.87, 7: 0.84, 6: 0.81},
      4: {10: 0.90, 9: 0.87, 8: 0.84, 7: 0.81, 6: 0.78},
      5: {10: 0.87, 9: 0.84, 8: 0.81, 7: 0.78, 6: 0.75},
      6: {10: 0.84, 9: 0.81, 8: 0.78, 7: 0.75, 6: 0.72},
      8: {10: 0.80, 9: 0.77, 8: 0.74, 7: 0.71, 6: 0.68},
      10: {10: 0.75, 9: 0.72, 8: 0.69, 7: 0.66, 6: 0.63},
      12: {10: 0.70, 9: 0.67, 8: 0.64, 7: 0.61, 6: 0.58},
    };
    
    // Find closest rep range
    int closestReps = rpeChart.keys.reduce((a, b) => 
      (reps - a).abs() < (reps - b).abs() ? a : b);
    
    return rpeChart[closestReps]?[rpe] ?? 0.75;
  }
  
  /// Calculate training volume for an exercise
  static double calculateVolume(List<ExerciseSet> sets, {bool includeWarmup = false}) {
    return sets
        .where((set) => includeWarmup || !set.isWarmup)
        .where((set) => set.isCompleted)
        .fold(0.0, (total, set) => total + (set.weight * (set.actualReps ?? set.reps)));
  }
  
  /// Calculate average intensity (%1RM) for an exercise
  static double calculateAverageIntensity(List<ExerciseSet> sets, double oneRM) {
    if (oneRM <= 0 || sets.isEmpty) return 0.0;
    
    final workingSets = sets.where((set) => !set.isWarmup && set.isCompleted).toList();
    if (workingSets.isEmpty) return 0.0;
    
    double totalIntensity = 0.0;
    for (final set in workingSets) {
      totalIntensity += (set.weight / oneRM) * 100;
    }
    
    return totalIntensity / workingSets.length;
  }
  
  /// Calculate training load (Volume × Intensity)
  static double calculateTrainingLoad(double volume, double averageIntensity) {
    return volume * (averageIntensity / 100);
  }
  
  /// Generate overload recommendations based on analysis
  static List<OverloadRecommendation> generateOverloadRecommendations(
    String exerciseName,
    List<SmartTrainingMetrics> recentMetrics,
    ProgressiveOverloadAnalysis? previousAnalysis,
  ) {
    final recommendations = <OverloadRecommendation>[];
    
    if (recentMetrics.length < 2) {
      // Not enough data for analysis
      return [
        OverloadRecommendation(
          method: OverloadMethod.volume,
          description: 'Continue current training and collect more data',
          parameters: {'weeks_needed': 2},
          confidence: 0.5,
          priority: 1,
          reasoning: 'Insufficient data for accurate analysis',
          preconditions: ['Complete at least 2 more sessions'],
        ),
      ];
    }
    
    final latest = recentMetrics.first;
    final previous = recentMetrics[1];
    
    // Analyze volume progression
    final volumeChange = (latest.volume - previous.volume) / previous.volume;
    final intensityChange = (latest.averageIntensity - previous.averageIntensity) / previous.averageIntensity;
    
    // Volume-based progression
    if (volumeChange < 0.02 && latest.averageIntensity < 85) {
      recommendations.add(OverloadRecommendation(
        method: OverloadMethod.volume,
        description: 'Increase volume by adding 1-2 sets',
        parameters: {
          'additional_sets': _calculateOptimalSetIncrease(latest.totalSets),
          'target_volume_increase': 0.10,
        },
        confidence: 0.85,
        priority: 1,
        reasoning: 'Volume has stagnated while intensity allows for progression',
        preconditions: ['RPE < 9 on most sets', 'Good recovery between sessions'],
      ));
    }
    
    // Intensity-based progression
    if (latest.averageIntensity < 80 && volumeChange > -0.05) {
      recommendations.add(OverloadRecommendation(
        method: OverloadMethod.intensity,
        description: 'Increase weight by 2.5-5kg',
        parameters: {
          'weight_increase_kg': _calculateOptimalWeightIncrease(exerciseName, latest.volume),
          'maintain_reps': true,
        },
        confidence: 0.90,
        priority: 1,
        reasoning: 'Current intensity allows for weight progression',
        preconditions: ['Consistent form', 'RPE 7-8 on working sets'],
      ));
    }
    
    // Frequency-based progression
    if (recentMetrics.length >= 4) {
      final sessionFreq = _calculateWeeklyFrequency(recentMetrics);
      if (sessionFreq < 2 && latest.readinessScore > 7) {
        recommendations.add(OverloadRecommendation(
          method: OverloadMethod.frequency,
          description: 'Increase training frequency',
          parameters: {
            'additional_sessions_per_week': 1,
            'reduce_volume_per_session': 0.8,
          },
          confidence: 0.75,
          priority: 2,
          reasoning: 'Low frequency with good recovery capacity',
          preconditions: ['Adequate sleep', 'Low stress levels'],
        ));
      }
    }
    
    // Advanced methods for experienced trainees
    if (previousAnalysis?.stallWeeks ?? 0 >= 3) {
      recommendations.addAll(_getAdvancedOverloadMethods(latest, exerciseName));
    }
    
    return recommendations..sort((a, b) => a.priority.compareTo(b.priority));
  }
  
  /// Calculate optimal set increase
  static int _calculateOptimalSetIncrease(int currentSets) {
    if (currentSets <= 3) return 1;
    if (currentSets <= 6) return 1;
    return 2; // Higher volume exercises can handle more sets
  }
  
  /// Calculate optimal weight increase based on exercise type
  static double _calculateOptimalWeightIncrease(String exerciseName, double currentVolume) {
    // Exercise-specific progression rates
    const Map<String, double> progressionRates = {
      'squat': 5.0,
      'deadlift': 7.5,
      'bench press': 2.5,
      'overhead press': 1.25,
      'row': 2.5,
    };
    
    final exerciseKey = exerciseName.toLowerCase();
    for (final key in progressionRates.keys) {
      if (exerciseKey.contains(key)) {
        return progressionRates[key]!;
      }
    }
    
    // Default progression based on volume
    if (currentVolume > 5000) return 5.0; // Heavy compound
    if (currentVolume > 2000) return 2.5; // Medium compound
    return 1.25; // Isolation exercises
  }
  
  /// Calculate weekly training frequency
  static double _calculateWeeklyFrequency(List<SmartTrainingMetrics> metrics) {
    if (metrics.length < 7) return metrics.length / 7;
    
    final weekMetrics = metrics.take(7).toList();
    return weekMetrics.length / 7;
  }
  
  /// Advanced overload methods for breaking plateaus
  static List<OverloadRecommendation> _getAdvancedOverloadMethods(
    SmartTrainingMetrics latest,
    String exerciseName,
  ) {
    return [
      OverloadRecommendation(
        method: OverloadMethod.density,
        description: 'Reduce rest time between sets',
        parameters: {
          'rest_reduction_seconds': 15,
          'maintain_performance': true,
        },
        confidence: 0.70,
        priority: 3,
        reasoning: 'Plateau detected - density training can stimulate adaptation',
        preconditions: ['Good cardiovascular fitness', 'Stable technique'],
      ),
      OverloadRecommendation(
        method: OverloadMethod.range,
        description: 'Implement tempo manipulation',
        parameters: {
          'eccentric_tempo_seconds': 3,
          'concentric_tempo': 'explosive',
          'duration_weeks': 3,
        },
        confidence: 0.65,
        priority: 4,
        reasoning: 'Time under tension variation can break strength plateaus',
        preconditions: ['Experience with tempo training', 'Focus on technique'],
      ),
    ];
  }
  
  /// Detect if deload is needed based on fatigue accumulation
  static bool needsDeload(List<SmartTrainingMetrics> recentMetrics) {
    if (recentMetrics.length < 3) return false;
    
    final avgFatigue = recentMetrics.take(3)
        .map((m) => m.fatigueScore)
        .reduce((a, b) => a + b) / 3;
    
    final avgReadiness = recentMetrics.take(3)
        .map((m) => m.readinessScore)
        .reduce((a, b) => a + b) / 3;
    
    // Deload indicators
    final highFatigue = avgFatigue >= 7.5;
    final lowReadiness = avgReadiness <= 6.0;
    final volumeDecline = _hasVolumeDecline(recentMetrics);
    
    return highFatigue || (lowReadiness && volumeDecline);
  }
  
  /// Check if volume has declined over recent sessions
  static bool _hasVolumeDecline(List<SmartTrainingMetrics> metrics) {
    if (metrics.length < 4) return false;
    
    final recent = metrics.take(2).map((m) => m.volume).reduce((a, b) => a + b) / 2;
    final previous = metrics.skip(2).take(2).map((m) => m.volume).reduce((a, b) => a + b) / 2;
    
    return (recent - previous) / previous < -0.10; // 10% volume decline
  }
  
  /// Calculate progress rate (weekly improvement)
  static double calculateProgressRate(List<SmartTrainingMetrics> metrics) {
    if (metrics.length < 4) return 0.0;
    
    final firstWeek = metrics.skip(3).first;
    final lastWeek = metrics.first;
    
    final weeks = lastWeek.date.difference(firstWeek.date).inDays / 7;
    if (weeks <= 0) return 0.0;
    
    final volumeImprovement = (lastWeek.volume - firstWeek.volume) / firstWeek.volume;
    
    return volumeImprovement / weeks;
  }
}
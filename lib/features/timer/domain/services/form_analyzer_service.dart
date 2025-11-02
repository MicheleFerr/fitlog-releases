import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/utils/debug_logger.dart';

/// TIER-1 Form Analysis Service
/// Analyzes movement quality and provides form scoring
class FormAnalyzerService {
  // Movement analysis state
  double _currentFormScore = 0.0;
  final List<double> _formScoreHistory = [];
  
  // Analysis parameters
  static const int _analysisWindow = 50; // samples for analysis
  static const double _formThreshold = 0.1; // Threshold for form deviation
  
  /// Get current form score (0-100)
  Future<double> getCurrentFormScore() async {
    return _currentFormScore;
  }

  /// Analyze form based on velocity consistency and movement patterns
  Future<double> analyzeMovementForm({
    required List<double> velocityData,
    required List<double> accelerationData,
    String? exerciseType,
  }) async {
    try {
      if (velocityData.length < 10) return 0.0;
      
      // Calculate multiple form metrics
      final consistencyScore = _calculateVelocityConsistency(velocityData);
      final smoothnessScore = _calculateMovementSmoothness(accelerationData);
      final rhythmScore = _calculateMovementRhythm(velocityData);
      final rangeScore = _calculateRangeOfMotionScore(velocityData);
      
      // Weight different aspects based on exercise type
      final weights = _getExerciseWeights(exerciseType);
      
      final formScore = (
        consistencyScore * weights.consistency +
        smoothnessScore * weights.smoothness +
        rhythmScore * weights.rhythm +
        rangeScore * weights.range
      ) / (weights.consistency + weights.smoothness + weights.rhythm + weights.range);
      
      _currentFormScore = formScore;
      _formScoreHistory.add(formScore);
      
      // Keep history manageable
      if (_formScoreHistory.length > 1000) {
        _formScoreHistory.removeAt(0);
      }
      
      return formScore;
      
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Form analysis error: $e');
      return 0.0;
    }
  }

  /// Calculate overall set form score
  Future<double> calculateSetFormScore({
    required List<double> formScores,
    required double consistencyScore,
    required List<double> velocityData,
  }) async {
    if (formScores.isEmpty) return 0.0;
    
    try {
      // Base score from individual form scores
      final averageFormScore = formScores.reduce((a, b) => a + b) / formScores.length;
      
      // Penalty for declining form over the set
      final formDeclinePenalty = _calculateFormDeclinePenalty(formScores);
      
      // Bonus for consistent velocity (good control)
      final consistencyBonus = consistencyScore > 80 ? 5.0 : 0.0;
      
      // Final form score
      final finalScore = math.max(0.0, math.min(100.0, 
        averageFormScore - formDeclinePenalty + consistencyBonus));
      
      DebugLogger.log(LogCategory.timer, 
        'TIER-1: Set form score calculated - Base: $averageFormScore, '
        'Decline penalty: $formDeclinePenalty, Final: $finalScore');
      
      return finalScore;
      
    } catch (e) {
      DebugLogger.log(LogCategory.timer, 'Set form score calculation error: $e');
      return 0.0;
    }
  }

  /// Provide real-time form feedback
  FormFeedback getFormFeedback() {
    if (_formScoreHistory.length < 5) {
      return const FormFeedback(
        message: 'Establishing baseline...',
        severity: FeedbackSeverity.info,
        recommendation: 'Continue with current form',
      );
    }
    
    final recentScores = _formScoreHistory.sublist(
      math.max(0, _formScoreHistory.length - 10));
    
    final averageRecent = recentScores.reduce((a, b) => a + b) / recentScores.length;
    final trend = _calculateFormTrend(recentScores);
    
    // Provide contextual feedback
    if (averageRecent < 60) {
      return const FormFeedback(
        message: 'Form quality declining',
        severity: FeedbackSeverity.warning,
        recommendation: 'Focus on controlled movement',
      );
    }
    
    if (trend < -5) {
      return const FormFeedback(
        message: 'Form deteriorating',
        severity: FeedbackSeverity.caution,
        recommendation: 'Consider reducing weight or resting',
      );
    }
    
    if (averageRecent > 85) {
      return const FormFeedback(
        message: 'Excellent form!',
        severity: FeedbackSeverity.positive,
        recommendation: 'Maintain current technique',
      );
    }
    
    return const FormFeedback(
      message: 'Good form',
      severity: FeedbackSeverity.info,
      recommendation: 'Keep up the consistency',
    );
  }

  /// Calculate velocity consistency score
  double _calculateVelocityConsistency(List<double> velocities) {
    if (velocities.length < 3) return 100.0;
    
    final average = velocities.reduce((a, b) => a + b) / velocities.length;
    final variance = velocities
        .map((v) => math.pow(v - average, 2))
        .reduce((a, b) => a + b) / velocities.length;
    
    final standardDeviation = math.sqrt(variance);
    final coefficientOfVariation = (standardDeviation / average) * 100;
    
    // Convert to 0-100 scale (lower variation = higher score)
    return math.max(0, 100 - (coefficientOfVariation * 3));
  }

  /// Calculate movement smoothness
  double _calculateMovementSmoothness(List<double> accelerationData) {
    if (accelerationData.length < 10) return 100.0;
    
    // Calculate jerk (derivative of acceleration)
    final jerkValues = <double>[];
    for (int i = 1; i < accelerationData.length; i++) {
      jerkValues.add((accelerationData[i] - accelerationData[i-1]).abs());
    }
    
    final averageJerk = jerkValues.reduce((a, b) => a + b) / jerkValues.length;
    
    // Lower jerk = smoother movement = higher score
    final smoothnessScore = math.max(0, 100 - (averageJerk * 20));

    return smoothnessScore.toDouble();
  }

  /// Calculate movement rhythm score
  double _calculateMovementRhythm(List<double> velocities) {
    if (velocities.length < 20) return 100.0;
    
    // Detect peaks and valleys in velocity to analyze rhythm
    final peaks = <int>[];
    final valleys = <int>[];
    
    for (int i = 1; i < velocities.length - 1; i++) {
      if (velocities[i] > velocities[i-1] && velocities[i] > velocities[i+1]) {
        peaks.add(i);
      }
      if (velocities[i] < velocities[i-1] && velocities[i] < velocities[i+1]) {
        valleys.add(i);
      }
    }
    
    // Calculate rhythm consistency
    if (peaks.length < 2) return 50.0;
    
    final peakIntervals = <int>[];
    for (int i = 1; i < peaks.length; i++) {
      peakIntervals.add(peaks[i] - peaks[i-1]);
    }
    
    if (peakIntervals.isEmpty) return 50.0;
    
    final averageInterval = peakIntervals.reduce((a, b) => a + b) / peakIntervals.length;
    final intervalVariance = peakIntervals
        .map((interval) => math.pow(interval - averageInterval, 2))
        .reduce((a, b) => a + b) / peakIntervals.length;
    
    final rhythmConsistency = math.max(0, 100 - (math.sqrt(intervalVariance) * 2));

    return rhythmConsistency.toDouble();
  }

  /// Calculate range of motion score (based on velocity variation)
  double _calculateRangeOfMotionScore(List<double> velocities) {
    if (velocities.isEmpty) return 0.0;
    
    final maxVel = velocities.reduce(math.max);
    final minVel = velocities.reduce(math.min);
    final range = maxVel - minVel;
    
    // Good range of motion should show significant velocity variation
    // Score based on normalized range
    final normalizedRange = range / (maxVel.abs() + 0.001); // Avoid division by zero
    
    return math.min(100.0, normalizedRange * 200);
  }

  /// Get exercise-specific weights for form analysis
  FormWeights _getExerciseWeights(String? exerciseType) {
    switch (exerciseType?.toLowerCase()) {
      case 'squat':
      case 'deadlift':
        return const FormWeights(
          consistency: 0.3,
          smoothness: 0.4,
          rhythm: 0.2,
          range: 0.1,
        );
      case 'bench_press':
      case 'press':
        return const FormWeights(
          consistency: 0.4,
          smoothness: 0.3,
          rhythm: 0.2,
          range: 0.1,
        );
      case 'curl':
      case 'isolation':
        return const FormWeights(
          consistency: 0.2,
          smoothness: 0.5,
          rhythm: 0.2,
          range: 0.1,
        );
      default:
        return const FormWeights(
          consistency: 0.35,
          smoothness: 0.35,
          rhythm: 0.2,
          range: 0.1,
        );
    }
  }

  /// Calculate form decline penalty
  double _calculateFormDeclinePenalty(List<double> formScores) {
    if (formScores.length < 3) return 0.0;
    
    final firstThird = formScores.sublist(0, formScores.length ~/ 3);
    final lastThird = formScores.sublist(formScores.length - (formScores.length ~/ 3));
    
    final firstAvg = firstThird.reduce((a, b) => a + b) / firstThird.length;
    final lastAvg = lastThird.reduce((a, b) => a + b) / lastThird.length;
    
    final decline = firstAvg - lastAvg;
    
    return math.max(0.0, decline * 0.5); // 50% of decline as penalty
  }

  /// Calculate form trend
  double _calculateFormTrend(List<double> scores) {
    if (scores.length < 2) return 0.0;
    
    final firstHalf = scores.sublist(0, scores.length ~/ 2);
    final secondHalf = scores.sublist(scores.length ~/ 2);
    
    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
    
    return secondAvg - firstAvg;
  }

  /// Reset form analysis state
  void reset() {
    _currentFormScore = 0.0;
    _formScoreHistory.clear();
    
    DebugLogger.log(LogCategory.timer, 'TIER-1: Form analyzer reset');
  }

  /// Get form score statistics
  FormStatistics getFormStatistics() {
    if (_formScoreHistory.isEmpty) {
      return const FormStatistics(
        averageScore: 0.0,
        bestScore: 0.0,
        worstScore: 0.0,
        trend: 0.0,
        sampleCount: 0,
      );
    }
    
    final average = _formScoreHistory.reduce((a, b) => a + b) / _formScoreHistory.length;
    final best = _formScoreHistory.reduce(math.max);
    final worst = _formScoreHistory.reduce(math.min);
    final trend = _calculateFormTrend(_formScoreHistory);
    
    return FormStatistics(
      averageScore: average,
      bestScore: best,
      worstScore: worst,
      trend: trend,
      sampleCount: _formScoreHistory.length,
    );
  }
}

/// Form analysis weights for different exercises
class FormWeights {
  
  const FormWeights({
    required this.consistency,
    required this.smoothness,
    required this.rhythm,
    required this.range,
  });
  final double consistency;
  final double smoothness;
  final double rhythm;
  final double range;
}

/// Form feedback data
class FormFeedback {
  
  const FormFeedback({
    required this.message,
    required this.severity,
    required this.recommendation,
  });
  final String message;
  final FeedbackSeverity severity;
  final String recommendation;
}

/// Feedback severity levels
enum FeedbackSeverity {
  positive,
  info,
  caution,
  warning,
}

/// Form analysis statistics
class FormStatistics {
  
  const FormStatistics({
    required this.averageScore,
    required this.bestScore,
    required this.worstScore,
    required this.trend,
    required this.sampleCount,
  });
  final double averageScore;
  final double bestScore;
  final double worstScore;
  final double trend;
  final int sampleCount;
}

// Provider for the service
final formAnalyzerServiceProvider = Provider<FormAnalyzerService>((ref) {
  return FormAnalyzerService();
});
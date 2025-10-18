/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/entities
/// 🎯 Feature: strength_standards
/// 🔧 Type: entity
/// 🌍 Localization: N/A - Entity class
/// 🎨 Theme: N/A - Entity class
/// 📱 Platform: Universal
///
/// Tracks accuracy of weight suggestions compared to actual weights used
/// by users. Used for adaptive learning and improving suggestions over time.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'suggestion_accuracy.freezed.dart';
part 'suggestion_accuracy.g.dart';

/// Single suggestion accuracy record
@freezed
class SuggestionAccuracy with _$SuggestionAccuracy {
  const factory SuggestionAccuracy({
    /// Unique ID for this record
    required String id,

    /// User ID
    required String userId,

    /// Exercise ID from GymBro database
    required String exerciseId,

    /// Weight suggested by system (kg)
    required double suggestedWeight,

    /// Weight actually used by user (kg)
    required double actualWeight,

    /// Reps suggested by system
    required int suggestedReps,

    /// Reps actually completed by user
    required int actualReps,

    /// Absolute error percentage: |actual - suggested| / suggested * 100
    required double weightErrorPercent,

    /// Reps error: actualReps - suggestedReps (can be negative)
    required int repsError,

    /// Timestamp when set was performed
    required DateTime timestamp,

    /// Experience level at time of suggestion
    required String experienceLevel,

    /// Training goal at time of suggestion
    required String trainingGoal,

    /// Whether user found suggestion helpful (optional feedback)
    bool? wasHelpful,

    /// User's perceived exertion (1-10 RPE scale)
    int? perceivedExertion,
  }) = _SuggestionAccuracy;

  factory SuggestionAccuracy.fromJson(Map<String, dynamic> json) =>
      _$SuggestionAccuracyFromJson(json);
}

/// Extension for accuracy calculations
extension SuggestionAccuracyExtension on SuggestionAccuracy {
  /// Whether suggestion was within acceptable range (±15%)
  bool get isAcceptable => weightErrorPercent <= 15.0;

  /// Whether suggestion was very accurate (±5%)
  bool get isVeryAccurate => weightErrorPercent <= 5.0;

  /// Suggestion quality tier
  AccuracyTier get accuracyTier {
    if (weightErrorPercent <= 5.0) return AccuracyTier.excellent;
    if (weightErrorPercent <= 10.0) return AccuracyTier.good;
    if (weightErrorPercent <= 15.0) return AccuracyTier.acceptable;
    if (weightErrorPercent <= 25.0) return AccuracyTier.poor;
    return AccuracyTier.veryPoor;
  }

  /// Direction of error (too heavy, too light, or just right)
  ErrorDirection get errorDirection {
    if (weightErrorPercent <= 5.0) return ErrorDirection.justRight;
    if (actualWeight > suggestedWeight) {
      return ErrorDirection.tooLight; // User used more weight
    } else {
      return ErrorDirection.tooHeavy; // User used less weight
    }
  }
}

/// Accuracy tier classification
enum AccuracyTier {
  excellent, // ≤5% error
  good, // ≤10% error
  acceptable, // ≤15% error
  poor, // ≤25% error
  veryPoor, // >25% error
}

/// Error direction
enum ErrorDirection {
  tooHeavy, // Suggested weight was too much
  tooLight, // Suggested weight was too little
  justRight, // Within ±5%
}

/// Aggregated accuracy metrics for an exercise
class AccuracyMetrics {
  const AccuracyMetrics({
    required this.exerciseId,
    required this.sampleSize,
    required this.averageErrorPercent,
    required this.standardDeviation,
    required this.trend,
    required this.lastUpdated,
  });

  final String exerciseId;
  final int sampleSize;
  final double averageErrorPercent;
  final double standardDeviation;
  final AccuracyTrend trend;
  final DateTime lastUpdated;

  /// Whether we have enough data for reliable metrics
  bool get isReliable => sampleSize >= 3;

  /// Confidence in current suggestions (0.0 to 1.0)
  double get confidence {
    if (!isReliable) return 0.5; // Medium confidence with low data

    // Higher confidence with lower error and more samples
    final errorFactor = 1.0 - (averageErrorPercent / 100.0).clamp(0.0, 1.0);
    final sampleFactor = (sampleSize / 10.0).clamp(0.0, 1.0); // Max at 10 samples

    return (errorFactor * 0.7 + sampleFactor * 0.3).clamp(0.0, 1.0);
  }
}

/// Trend in accuracy over time
enum AccuracyTrend {
  improving, // Error decreasing over time
  stable, // Error consistent
  worsening, // Error increasing over time
  insufficient, // Not enough data to determine trend
}

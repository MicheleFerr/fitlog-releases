/// Predictive Balance - Pattern Prediction Entity
///
/// Represents a prediction of which workout is missing this week
/// based on the detected pattern.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/predictive_balance/domain/entities/workout_fingerprint.dart';

part 'pattern_prediction.freezed.dart';
part 'pattern_prediction.g.dart';

/// Prediction of missing workout for current week
///
/// Generated when user has a valid pattern and hasn't completed
/// all workouts in their typical cycle this week.
@freezed
abstract class PatternPrediction with _$PatternPrediction {
  const factory PatternPrediction({
    /// The workout fingerprint that is missing
    required WorkoutFingerprint missing,

    /// Muscles that would be covered by completing this workout
    required List<String> musclesCovered,

    /// Template ID if there's a matching template to suggest
    String? suggestedTemplateId,

    /// Template name for display
    String? suggestedTemplateName,

    /// How many workouts are missing (could be multiple)
    @Default(1) int missingCount,

    /// Pattern confidence this prediction is based on
    required double patternConfidence,
  }) = _PatternPrediction;

  const PatternPrediction._();

  factory PatternPrediction.fromJson(Map<String, dynamic> json) =>
      _$PatternPredictionFromJson(json);

  /// Display name for the missing workout
  String get displayName =>
      suggestedTemplateName ?? missing.displayName;

  /// Whether there's a specific template to navigate to
  bool get hasTemplate => suggestedTemplateId != null;

  /// Check if a specific muscle would be resolved by this workout
  bool resolvesMuscle(String muscleName) {
    final normalized = muscleName.toLowerCase();
    return musclesCovered.any((m) => m.toLowerCase() == normalized);
  }
}

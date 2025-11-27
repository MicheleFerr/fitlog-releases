/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/entities
/// 🎯 Feature: analytics
/// 🔧 Type: entity
///
/// AnalyticsSet Entity - Represents a single set in an analytics session
///
/// **Note**: Renamed from ExerciseSet to avoid conflict with workout.ExerciseSet
///
/// **Properties**:
/// - weight: Weight lifted in kg
/// - reps: Number of repetitions performed
/// - date: When the set was performed
///
/// **Computed Properties**:
/// - volume: Total volume (weight × reps)
/// - estimatedOneRM: Estimated One Rep Maximum using Epley formula
///
/// **Epley Formula**:
/// 1RM = (weight × reps / 37.5) + weight
///
/// **Usage**:
/// ```dart
/// final set = AnalyticsSet(
///   weight: 100.0,
///   reps: 8,
///   date: DateTime.now(),
/// );
///
/// print(set.volume);           // 800.0
/// print(set.estimatedOneRM);   // ~121.3 kg
/// ```
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_set.freezed.dart';
part 'analytics_set.g.dart';

@freezed
abstract class AnalyticsSet with _$AnalyticsSet {

  const factory AnalyticsSet({
    /// Weight lifted in kg (must be > 0)
    required double weight,

    /// Number of repetitions performed (must be > 0)
    required int reps,

    /// When the set was performed
    required DateTime date,
  }) = _AnalyticsSet;
  const AnalyticsSet._();

  /// Create from JSON (Firestore deserialization)
  factory AnalyticsSet.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsSetFromJson(json);

  /// Total volume for this set (weight × reps)
  ///
  /// Example:
  /// - weight: 100 kg, reps: 8 → volume: 800 kg
  double get volume => weight * reps;

  /// Estimated One Rep Maximum using Epley formula
  ///
  /// **Formula**: 1RM = (weight × reps / 37.5) + weight
  ///
  /// **Why Epley?**
  /// - Most accurate for 5-10 rep range
  /// - Widely used in strength training research
  /// - Better than Brzycki for intermediate lifters
  ///
  /// **Examples**:
  /// - 100 kg × 8 reps → ~121.3 kg 1RM
  /// - 80 kg × 10 reps → ~101.3 kg 1RM
  /// - 60 kg × 5 reps → ~68.0 kg 1RM
  ///
  /// **Edge Cases**:
  /// - 1 rep → returns weight (1RM = actual weight)
  /// - >15 reps → formula becomes less accurate (use with caution)
  double get estimatedOneRM {
    if (reps == 1) {
      return weight; // 1 rep = actual 1RM
    }
    return (weight * reps / 37.5) + weight;
  }

  /// Validate set data
  ///
  /// **Constraints**:
  /// - weight must be > 0
  /// - reps must be > 0
  ///
  /// Throws [ArgumentError] if validation fails
  void validate() {
    if (weight <= 0) {
      throw ArgumentError('Weight must be greater than 0, got: $weight');
    }
    if (reps <= 0) {
      throw ArgumentError('Reps must be greater than 0, got: $reps');
    }
  }
}

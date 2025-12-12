/// Muscle Stress Data Entity
///
/// Represents stress data for a specific muscle group within a workout.
/// Used for muscle-level breakdown in stress index calculation.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'muscle_stress_data.freezed.dart';
part 'muscle_stress_data.g.dart';

@freezed
abstract class MuscleStressData with _$MuscleStressData {
  const factory MuscleStressData({
    /// Muscle identifier (e.g., "PETT", "LAT", "QUAD")
    required String muscleId,

    /// Display name for UI (e.g., "Chest", "Lats", "Quadriceps")
    required String displayName,

    /// Stress score for this muscle (0-100, logarithmic)
    required double stressScore,

    /// Number of sets targeting this muscle
    required int setsCount,

    /// Total volume for this muscle (kg × reps)
    required double totalVolume,

    /// Average RPE for sets targeting this muscle
    /// 0 if no RPE data available
    required double avgRpe,

    /// Estimated recovery time in hours
    required int recoveryHours,

    /// Estimated full recovery timestamp
    required DateTime? estimatedRecovery,
  }) = _MuscleStressData;

  const MuscleStressData._();

  factory MuscleStressData.fromJson(Map<String, dynamic> json) =>
      _$MuscleStressDataFromJson(json);

  /// Check if this muscle has RPE data
  bool get hasRpeData => avgRpe > 0;

  /// Get stress level category for this muscle
  MuscleStressLevel get stressLevel {
    if (stressScore < 20) return MuscleStressLevel.low;
    if (stressScore < 40) return MuscleStressLevel.moderate;
    if (stressScore < 60) return MuscleStressLevel.high;
    return MuscleStressLevel.veryHigh;
  }
}

/// Muscle-level stress categories
enum MuscleStressLevel {
  low,
  moderate,
  high,
  veryHigh,
}

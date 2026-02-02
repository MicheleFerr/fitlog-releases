/// Predictive Balance - Workout Fingerprint Entity
///
/// Represents the muscle profile of a workout for pattern matching.
/// Used to identify similar workouts across different sessions.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_fingerprint.freezed.dart';
part 'workout_fingerprint.g.dart';

/// Category of workout based on dominant muscle groups
enum WorkoutCategory {
  /// Chest, shoulders, triceps focused
  push,

  /// Back, biceps focused
  pull,

  /// Quadriceps, hamstrings, glutes focused
  legs,

  /// Upper body mix (push + pull)
  upper,

  /// Lower body focus
  lower,

  /// Full body workout
  fullBody,

  /// Unclassified
  other,
}

/// Fingerprint of a workout based on muscle volume distribution
///
/// Used to identify and match similar workouts for pattern detection.
/// Two workouts with similar fingerprints are considered the same "type".
@freezed
abstract class WorkoutFingerprint with _$WorkoutFingerprint {
  const factory WorkoutFingerprint({
    /// Unique ID (hash of dominant muscles + category)
    required String id,

    /// Template name if workout was from a template
    String? templateName,

    /// Template ID for navigation
    String? templateId,

    /// Top 3 muscles by volume contribution
    required List<String> dominantMuscles,

    /// Inferred category based on muscle composition
    required WorkoutCategory category,

    /// Total volume (sets × reps × weight) for ranking
    required double totalVolume,

    /// Original workout date (for debugging)
    DateTime? workoutDate,
  }) = _WorkoutFingerprint;

  const WorkoutFingerprint._();

  factory WorkoutFingerprint.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFingerprintFromJson(json);

  /// Check if this fingerprint matches another (same workout type)
  bool matches(WorkoutFingerprint other) {
    // Same template = definite match
    if (templateName != null &&
        templateName!.isNotEmpty &&
        templateName == other.templateName) {
      return true;
    }

    // Same category (except "other") = match
    if (category == other.category && category != WorkoutCategory.other) {
      return true;
    }

    // 2/3 dominant muscles overlap = match
    final overlap = dominantMuscles
        .where((m) => other.dominantMuscles.contains(m))
        .length;
    return overlap >= 2;
  }

  /// Generate display name for this fingerprint
  String get displayName {
    if (templateName != null && templateName!.isNotEmpty) {
      return templateName!;
    }
    return category.name;
  }
}

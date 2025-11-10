/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain
/// 🎯 Feature: workout
/// 🔧 Type: entity (data class)
/// 🌍 Localization: N/A (domain model)
library;

import 'package:gymbro_flutter_new/features/workout/domain/entities/experience_level.dart';

/// Workout context gathered from user during quick start flow
///
/// Contains:
/// - Time available (5, 15, 30, 45 minutes)
/// - Experience level (beginner, intermediate, advanced) - optional for <30min
/// - Gender (optional, for Phase 4 personalization)
/// - Timestamp (for analytics)
///
/// Used to personalize:
/// - Exercise count (2-5 based on time + experience)
/// - Weight suggestions (conservative vs aggressive)
/// - Rep ranges (beginner-friendly vs advanced)
/// - Workout naming (gender-specific tone)
class WorkoutContext {
  /// Time available in minutes (5, 15, 30, or 45)
  final int timeAvailable;

  /// Experience level (null if user skipped or <30min fast path)
  final ExperienceLevel? experienceLevel;

  /// User gender (null if skipped, for Phase 4 personalization)
  /// Values: 'male', 'female', 'other', null
  final String? gender;

  /// Timestamp when context was gathered (for analytics)
  final DateTime timestamp;

  /// Total time taken to complete context gathering (milliseconds)
  /// Used for analytics: P50/P75/P90 metrics
  final int? completionTimeMs;

  const WorkoutContext({
    required this.timeAvailable,
    this.experienceLevel,
    this.gender,
    required this.timestamp,
    this.completionTimeMs,
  });

  /// Whether user needs experience level selection
  /// True if timeAvailable >= 30 minutes
  bool get needsExperienceLevel => timeAvailable >= 30;

  /// Suggested exercise count based on time + experience
  ///
  /// Logic:
  /// - <30min: 2 exercises (quick workout)
  /// - ≥30min + beginner: 3 exercises
  /// - ≥30min + intermediate: 4 exercises
  /// - ≥30min + advanced: 5 exercises
  int get suggestedExerciseCount {
    if (timeAvailable < 30) {
      return 2; // Quick workout
    }

    if (experienceLevel == null) {
      return 3; // Default if experience not selected
    }

    return experienceLevel!.suggestedExerciseCount;
  }

  /// Whether full context was gathered (including demographics)
  bool get hasFullContext => experienceLevel != null && gender != null;

  /// Whether minimal context was gathered (time + experience only)
  bool get hasMinimalContext => experienceLevel != null;

  /// Completion speed category for analytics
  ///
  /// - turbo: <6 seconds (very fast)
  /// - normal: 6-15 seconds (expected)
  /// - slow: >15 seconds (may need help)
  String get completionSpeedCategory {
    if (completionTimeMs == null) return 'unknown';

    if (completionTimeMs! < 6000) {
      return 'turbo';
    } else if (completionTimeMs! <= 15000) {
      return 'normal';
    } else {
      return 'slow';
    }
  }

  /// Copy with method for updating context
  WorkoutContext copyWith({
    int? timeAvailable,
    ExperienceLevel? experienceLevel,
    String? gender,
    DateTime? timestamp,
    int? completionTimeMs,
  }) {
    return WorkoutContext(
      timeAvailable: timeAvailable ?? this.timeAvailable,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      gender: gender ?? this.gender,
      timestamp: timestamp ?? this.timestamp,
      completionTimeMs: completionTimeMs ?? this.completionTimeMs,
    );
  }

  /// Convert to Map for analytics/storage
  Map<String, dynamic> toMap() {
    return {
      'time_available': timeAvailable,
      'experience_level': experienceLevel?.name,
      'gender': gender,
      'timestamp': timestamp.toIso8601String(),
      'completion_time_ms': completionTimeMs,
      'suggested_exercise_count': suggestedExerciseCount,
      'has_full_context': hasFullContext,
      'completion_speed_category': completionSpeedCategory,
    };
  }

  /// Create from Map (for restoration from SharedPreferences)
  factory WorkoutContext.fromMap(Map<String, dynamic> map) {
    return WorkoutContext(
      timeAvailable: map['time_available'] as int,
      experienceLevel: map['experience_level'] != null
          ? ExperienceLevel.fromString(map['experience_level'] as String)
          : null,
      gender: map['gender'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      completionTimeMs: map['completion_time_ms'] as int?,
    );
  }

  @override
  String toString() {
    return 'WorkoutContext('
        'time: ${timeAvailable}min, '
        'level: ${experienceLevel?.name ?? 'none'}, '
        'gender: ${gender ?? 'none'}, '
        'exercises: $suggestedExerciseCount, '
        'speed: $completionSpeedCategory'
        ')';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutContext &&
          runtimeType == other.runtimeType &&
          timeAvailable == other.timeAvailable &&
          experienceLevel == other.experienceLevel &&
          gender == other.gender;

  @override
  int get hashCode =>
      timeAvailable.hashCode ^ experienceLevel.hashCode ^ gender.hashCode;
}

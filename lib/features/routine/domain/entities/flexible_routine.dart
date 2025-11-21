/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain/entities
/// 🎯 Feature: flexible_routine
/// 🔧 Type: entity
/// 🌍 Localization: N/A (domain logic only)
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// FLEXIBLE ROUTINE ENTITY - v2.0 SIMPLIFIED
///
/// This is the v2.0 simplified routine entity with:
/// - 12 fields (down from 20+ in v1.0)
/// - No nested entities (RoutinePattern, SkipTracker removed)
/// - Direct Set of int for training days (no complex pattern)
/// - Map of int to String for workout schedule (day to templateId)
/// - Set of String for completed days tracking
///
/// Replaces v1.0 complex schema with flat, Firestore-friendly structure.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_preset.dart';

part 'flexible_routine.freezed.dart';
part 'flexible_routine.g.dart';

/// FlexibleRoutine entity - v2.0 simplified schema
///
/// Core routine entity with 12 fields for workout scheduling.
/// Supports preset-based routines (PPL, Upper/Lower, etc.) and custom schedules.
@freezed
class FlexibleRoutine with _$FlexibleRoutine {
  const factory FlexibleRoutine({
    /// Unique routine identifier (Firestore document ID)
    required String id,

    /// User who owns this routine (for multi-user support)
    required String userId,

    /// Routine name (user-defined, e.g., "My PPL Routine")
    required String name,

    /// Optional description/notes
    @Default('') String description,

    /// Preset type (ppl6Day, upperLower4Day, etc.)
    /// Determines default training days and template suggestions
    required RoutinePreset presetType,

    /// Training days as Set of weekday integers
    /// Monday = 1, Sunday = 7
    /// Example: {1, 2, 3, 4, 5, 6} for 6-day routine
    required Set<int> trainingDays,

    /// Workout schedule mapping day → template ID
    /// Key: weekday (1-7), Value: template ID (Firestore ref)
    /// Example: {1: "template_123", 2: "template_456", ...}
    required Map<int, String> workoutSchedule,

    /// Whether this routine is currently active
    /// Only one routine can be active per user at a time
    @Default(true) bool isActive,

    /// Completed workout days (ISO 8601 date strings)
    /// Example: {"2025-01-20", "2025-01-22", ...}
    /// Used for streak tracking and analytics
    @Default({}) Set<String> completedDays,

    /// Total number of workouts completed in this routine
    /// Incremented each time a workout is marked complete
    @Default(0) int totalWorkouts,

    /// Routine creation timestamp
    required DateTime createdAt,

    /// Last update timestamp (modified whenever routine changes)
    required DateTime updatedAt,
  }) = _FlexibleRoutine;

  /// JSON deserialization
  factory FlexibleRoutine.fromJson(Map<String, dynamic> json) =>
      _$FlexibleRoutineFromJson(json);
}

/// Extension methods for FlexibleRoutine business logic
extension FlexibleRoutineExtension on FlexibleRoutine {
  /// Get today's assigned workout template ID (if today is a training day)
  /// Returns null if today is a rest day or no template assigned
  String? getTodayWorkout() {
    final today = DateTime.now().weekday;
    if (!trainingDays.contains(today)) return null;
    return workoutSchedule[today];
  }

  /// Get workout template ID for a specific day of week
  /// Returns null if day is not a training day
  String? getWorkoutForDay(int dayOfWeek) {
    if (!trainingDays.contains(dayOfWeek)) return null;
    return workoutSchedule[dayOfWeek];
  }

  /// Check if a specific date has been completed
  /// @param date ISO 8601 date string (e.g., "2025-01-20")
  bool isDateCompleted(String date) {
    return completedDays.contains(date);
  }

  /// Check if today's workout has been completed
  bool isTodayCompleted() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return completedDays.contains(today);
  }

  /// Get number of workouts completed this week
  int get weeklyCompletionCount {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekDates = List.generate(
      7,
      (i) => weekStart.add(Duration(days: i)).toIso8601String().substring(0, 10),
    );

    return completedDays.where((date) => weekDates.contains(date)).length;
  }

  /// Get completion rate (0.0 - 1.0)
  /// Based on total workouts completed vs total days elapsed
  double get completionRate {
    final now = DateTime.now();
    final daysSinceCreation = now.difference(createdAt).inDays;
    if (daysSinceCreation == 0) return 0.0;

    final expectedWorkouts = (daysSinceCreation / 7 * trainingDays.length).floor();
    if (expectedWorkouts == 0) return 0.0;

    return (totalWorkouts / expectedWorkouts).clamp(0.0, 1.0);
  }

  /// Get current week's adherence rate (0.0 - 1.0)
  /// Completed workouts this week / scheduled workouts this week
  double get weeklyAdherenceRate {
    final now = DateTime.now();
    final weekDay = now.weekday; // 1 = Monday, 7 = Sunday

    final scheduledThisWeek = trainingDays.where((day) => day <= weekDay).length;
    if (scheduledThisWeek == 0) return 0.0;

    return (weeklyCompletionCount / scheduledThisWeek).clamp(0.0, 1.0);
  }

  /// Get days assigned (how many days have templates)
  /// Used for Step 2 progress indicator
  int get daysAssigned {
    return workoutSchedule.length;
  }

  /// Check if all training days have templates assigned
  /// Used for "Save" button enablement
  bool get isFullyAssigned {
    return workoutSchedule.length == trainingDays.length;
  }

  /// Get next training day (1-7) from today
  /// Returns null if no upcoming training days this week
  int? get nextTrainingDay {
    final today = DateTime.now().weekday;
    final sortedDays = trainingDays.toList()..sort();

    // Find next day after today
    for (final day in sortedDays) {
      if (day > today) return day;
    }

    // If no day after today, return first day of next week
    return sortedDays.isNotEmpty ? sortedDays.first : null;
  }

  /// Get the name of the next workout
  /// Returns template name if available, null otherwise
  String? getNextWorkoutName() {
    final nextDay = nextTrainingDay;
    if (nextDay == null) return null;
    return workoutSchedule[nextDay];
  }
}

/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain
/// 🎯 Feature: routine_pause
/// 🔧 Type: entity
/// 🌍 Localization: N/A (domain logic only)
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// ROUTINE PAUSE ENTITY - Injury/Recovery Mode
///
/// This entity provides:
/// - Date range pause with reason tracking
/// - Auto-resume on endDate
/// - Conflict detection with scheduled workouts
/// - Analytics (pause duration, reasons, patterns)
///
/// Dependencies:
/// - Freezed: Code generation
/// - JSON serialization
/// - cloud_firestore: Timestamp serialization
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'routine_pause.freezed.dart';
part 'routine_pause.g.dart';

/// Pause reasons enum
enum PauseReason {
  /// Injury (shoulder, knee, back, etc.)
  injury,

  /// Sick/Illness (flu, cold, etc.)
  sick,

  /// Vacation/Travel
  vacation,

  /// Work/Life busy period
  busy,

  /// Mental health/Burnout
  burnout,

  /// Other reason
  other,
}

/// Extension for PauseReason display
extension PauseReasonExtensions on PauseReason {
  /// Get localization key for this reason
  String get localizationKey {
    switch (this) {
      case PauseReason.injury:
        return 'pauseReasonInjury';
      case PauseReason.sick:
        return 'pauseReasonSick';
      case PauseReason.vacation:
        return 'pauseReasonVacation';
      case PauseReason.busy:
        return 'pauseReasonBusy';
      case PauseReason.burnout:
        return 'pauseReasonBurnout';
      case PauseReason.other:
        return 'pauseReasonOther';
    }
  }

  /// Get default display name (fallback)
  String get displayName {
    switch (this) {
      case PauseReason.injury:
        return 'Injury';
      case PauseReason.sick:
        return 'Sick/Illness';
      case PauseReason.vacation:
        return 'Vacation';
      case PauseReason.busy:
        return 'Busy';
      case PauseReason.burnout:
        return 'Burnout';
      case PauseReason.other:
        return 'Other';
    }
  }
}

/// Custom serializer for Firestore Timestamp ↔ DateTime
class TimestampSerializer implements JsonConverter<DateTime, dynamic> {
  const TimestampSerializer();

  @override
  DateTime fromJson(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    throw ArgumentError('Cannot convert $timestamp to DateTime');
  }

  @override
  dynamic toJson(DateTime date) {
    return Timestamp.fromDate(date);
  }
}

/// 🎯 ROUTINE PAUSE ENTITY
///
/// Represents a pause period for a routine (e.g., injury, vacation).
/// Automatically resumes on endDate.
///
/// Example:
/// ```dart
/// RoutinePause(
///   id: 'pause_123',
///   routineId: 'routine_abc',
///   userId: 'user_xyz',
///   reason: PauseReason.injury,
///   startDate: DateTime(2025, 1, 10),
///   endDate: DateTime(2025, 1, 17),
///   notes: 'Shoulder injury - no upper body',
///   isActive: true,
///   createdAt: DateTime.now(),
/// )
/// ```
@freezed
class RoutinePause with _$RoutinePause {
  const factory RoutinePause({
    /// Unique pause ID
    required String id,

    /// Routine being paused
    required String routineId,

    /// User who created the pause
    required String userId,

    /// Reason for pause
    required PauseReason reason,

    /// Start date (normalized to midnight local)
    @TimestampSerializer() required DateTime startDate,

    /// End date (normalized to midnight local)
    @TimestampSerializer() required DateTime endDate,

    /// Optional notes (e.g., "Shoulder injury - avoid overhead pressing")
    String? notes,

    /// Whether pause is currently active
    @Default(true) bool isActive,

    /// When pause was created
    @TimestampSerializer() required DateTime createdAt,

    // === ANALYTICS FIELDS ===

    /// When pause was resumed (null if auto-resumed)
    @TimestampSerializer() DateTime? resumedAt,

    /// Whether user manually resumed (vs auto-resume on endDate)
    @Default(false) bool userInitiatedResume,

    /// Number of workouts skipped during this pause
    @Default(0) int workoutsSkipped,

    /// IDs of workouts skipped (for audit trail)
    @Default([]) List<String> skippedWorkoutIds,
  }) = _RoutinePause;

  const RoutinePause._();

  factory RoutinePause.fromJson(Map<String, dynamic> json) =>
      _$RoutinePauseFromJson(json);

  /// Factory for creating a new pause
  factory RoutinePause.create({
    required String routineId,
    required String userId,
    required PauseReason reason,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
  }) {
    return RoutinePause(
      id: '', // Will be set by repository
      routineId: routineId,
      userId: userId,
      reason: reason,
      startDate: _normalizeToMidnight(startDate),
      endDate: _normalizeToMidnight(endDate),
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  /// Normalize date to midnight (00:00:00)
  static DateTime _normalizeToMidnight(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

/// Extension methods for RoutinePause
extension RoutinePauseExtensions on RoutinePause {
  /// Get list of all paused days (inclusive)
  List<DateTime> get pausedDays {
    final days = <DateTime>[];
    var current = startDate;

    while (current.isBefore(endDate) ||
        current.isAtSameMomentAs(endDate)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  /// Get pause duration in days
  int get durationDays {
    return endDate.difference(startDate).inDays + 1; // +1 for inclusive
  }

  /// Check if a specific date is paused
  bool isPaused(DateTime date) {
    final normalized = RoutinePause._normalizeToMidnight(date);
    return (normalized.isAtSameMomentAs(startDate) ||
            normalized.isAfter(startDate)) &&
        (normalized.isAtSameMomentAs(endDate) ||
            normalized.isBefore(endDate));
  }

  /// Check if pause is expired (endDate has passed)
  bool get isExpired {
    final now = RoutinePause._normalizeToMidnight(DateTime.now());
    return now.isAfter(endDate);
  }

  /// Check if pause is currently active and not expired
  bool get isActiveAndValid {
    return isActive && !isExpired;
  }

  /// Days remaining until auto-resume (0 if expired)
  int get daysRemaining {
    if (isExpired) return 0;
    final now = RoutinePause._normalizeToMidnight(DateTime.now());
    return endDate.difference(now).inDays + 1;
  }

  /// Progress percentage (0-100)
  double get progressPercentage {
    if (durationDays == 0) return 100.0;
    final daysPassed = DateTime.now().difference(startDate).inDays;
    return (daysPassed / durationDays * 100).clamp(0.0, 100.0);
  }

  /// Resume this pause (sets isActive = false, resumedAt = now)
  RoutinePause resume({bool userInitiated = false}) {
    return copyWith(
      isActive: false,
      resumedAt: DateTime.now(),
      userInitiatedResume: userInitiated,
    );
  }

  /// Add skipped workout to tracking
  RoutinePause addSkippedWorkout(String workoutId) {
    return copyWith(
      workoutsSkipped: workoutsSkipped + 1,
      skippedWorkoutIds: [...skippedWorkoutIds, workoutId],
    );
  }

  /// Get summary string
  String get summary {
    final duration = durationDays;
    final skipped = workoutsSkipped;
    final reasonName = reason.displayName;

    if (isActive) {
      final remaining = daysRemaining;
      return '$reasonName • $duration days • $remaining days left • $skipped workouts skipped';
    } else {
      return '$reasonName • $duration days • $skipped workouts skipped';
    }
  }
}

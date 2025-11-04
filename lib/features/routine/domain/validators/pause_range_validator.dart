/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain
/// 🎯 Feature: routine_pause
/// 🔧 Type: validator
/// 🌍 Localization: N/A (domain logic only)
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// PAUSE RANGE VALIDATOR - Validate pause date ranges
///
/// This validator ensures:
/// - startDate is not in the past
/// - endDate is after startDate
/// - Pause duration is within limits (1-365 days)
/// - No overlapping pauses exist
///
/// Dependencies:
/// - RoutinePause entity
/// - RoutinePauseRepository (for overlap check)
library;

import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_pause.dart';

/// Validation result
class ValidationResult {
  const ValidationResult.success() : error = null;
  const ValidationResult.failure(this.error);

  final String? error;
  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

/// Pause range validator
class PauseRangeValidator {
  /// Maximum pause duration in days (1 year)
  static const int maxPauseDays = 365;

  /// Minimum pause duration in days
  static const int minPauseDays = 1;

  /// Validate pause date range
  ///
  /// Checks:
  /// 1. startDate cannot be in the past
  /// 2. endDate must be AFTER startDate (not equal)
  /// 3. Duration must be between 1-365 days
  /// 4. Optional: Check for overlapping pauses (if existingPauses provided)
  ///
  /// Returns:
  /// - `ValidationResult.success()` if valid
  /// - `ValidationResult.failure(message)` if invalid
  ValidationResult validateRange({
    required DateTime startDate,
    required DateTime endDate,
    List<RoutinePause>? existingPauses,
  }) {
    // Normalize dates to midnight for comparison
    final normalizedStart = _normalizeToMidnight(startDate);
    final normalizedEnd = _normalizeToMidnight(endDate);
    final today = _normalizeToMidnight(DateTime.now());

    // ✅ Check 1: startDate cannot be in the past
    if (normalizedStart.isBefore(today)) {
      return const ValidationResult.failure(
        'Start date cannot be in the past',
      );
    }

    // ✅ Check 2: endDate must be AFTER startDate (not equal)
    if (!normalizedEnd.isAfter(normalizedStart)) {
      return const ValidationResult.failure(
        'End date must be after start date',
      );
    }

    // ✅ Check 3: Check duration limits
    final durationDays = normalizedEnd.difference(normalizedStart).inDays + 1;

    if (durationDays < minPauseDays) {
      return const ValidationResult.failure(
        'Pause duration must be at least $minPauseDays day',
      );
    }

    if (durationDays > maxPauseDays) {
      return const ValidationResult.failure(
        'Pause duration cannot exceed $maxPauseDays days',
      );
    }

    // ✅ Check 4: Check for overlapping pauses (if provided)
    if (existingPauses != null && existingPauses.isNotEmpty) {
      final overlappingPause = _findOverlappingPause(
        normalizedStart,
        normalizedEnd,
        existingPauses,
      );

      if (overlappingPause != null) {
        final overlapEnd = overlappingPause.endDate;
        return ValidationResult.failure(
          'Routine already paused until ${_formatDate(overlapEnd)}',
        );
      }
    }

    return const ValidationResult.success();
  }

  /// Find overlapping pause in existing pauses
  RoutinePause? _findOverlappingPause(
    DateTime startDate,
    DateTime endDate,
    List<RoutinePause> existingPauses,
  ) {
    for (final pause in existingPauses) {
      // Skip inactive pauses
      if (!pause.isActive) continue;

      // Check if date ranges overlap
      // Overlap occurs if:
      // - new start is during existing pause, OR
      // - new end is during existing pause, OR
      // - new pause completely contains existing pause
      final hasOverlap = _dateRangesOverlap(
        startDate,
        endDate,
        pause.startDate,
        pause.endDate,
      );

      if (hasOverlap) return pause;
    }

    return null;
  }

  /// Check if two date ranges overlap
  bool _dateRangesOverlap(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    // Range 1: [start1, end1]
    // Range 2: [start2, end2]
    //
    // Overlap if:
    // - start1 is between start2 and end2, OR
    // - end1 is between start2 and end2, OR
    // - start2 is between start1 and end1, OR
    // - end2 is between start1 and end1
    return (start1.isBefore(end2) || start1.isAtSameMomentAs(end2)) &&
        (end1.isAfter(start2) || end1.isAtSameMomentAs(start2));
  }

  /// Normalize date to midnight (00:00:00)
  DateTime _normalizeToMidnight(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Format date to readable string
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain/entities
/// 🎯 Feature: Flexible Routine Extensions (TEMPORARY)
/// 🔧 Type: Extension Methods
///
/// Temporary extensions to resolve compilation errors in smart_notification_service.dart
library;

import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/skip_tracker.dart';

/// Extension methods for FlexibleRoutine to support notification service
extension FlexibleRoutineExtensions on FlexibleRoutine {
  /// Get workout name for a specific date
  /// Returns null if no workout is scheduled for that date
  String? getWorkoutForDate(DateTime date) {
    // Format date as string key for schedule lookup
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    // Check if date is in schedule
    final scheduledDay = schedule[dateKey];

    // Return template ID as workout name if scheduled, null if rest day
    // TODO: Fetch actual workout name from template repository
    return scheduledDay?.templateId;
  }
}

/// Extension methods for SkipTracker to support notification service
extension SkipTrackerExtensions on SkipTracker {
  /// Get list of skipped workout dates
  /// Returns empty list if no skips tracked
  List<DateTime> getSkippedDays() {
    // TODO: Implement proper skip tracking
    // For now, return empty list to prevent compilation error
    return [];
  }
}

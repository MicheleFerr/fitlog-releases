/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain
/// 🎯 Feature: flexible_routine
/// 🔧 Type: repository_interface
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// FLEXIBLE ROUTINE REPOSITORY INTERFACE - Contract for flexible routine data operations
///
/// This interface defines:
/// - CRUD operations for flexible routines
/// - Active routine management
/// - Multi-routine support
/// - Skip & recovery operations
/// - Sync operations
///
/// Implementations:
/// - FirebaseFlexibleRoutineRepository (Firebase + offline cache)
library;

import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';

/// Abstract repository interface for flexible routine operations
abstract class FlexibleRoutineRepository {
  // === CRUD OPERATIONS ===

  /// Get a specific routine by ID
  Future<FlexibleRoutine?> getRoutineById(String routineId);

  /// Get all routines for a user (active, paused, archived)
  Future<List<FlexibleRoutine>> getUserRoutines(String userId);

  /// Get only active routines
  Future<List<FlexibleRoutine>> getActiveRoutines(String userId);

  /// Get archived routines
  Future<List<FlexibleRoutine>> getArchivedRoutines(String userId);

  /// Create a new routine
  Future<void> createRoutine(FlexibleRoutine routine);

  /// Update an existing routine
  Future<void> updateRoutine(FlexibleRoutine routine);

  /// Delete a routine
  Future<void> deleteRoutine(String routineId);

  // === ACTIVE ROUTINE MANAGEMENT ===

  /// Get the user's currently active routine
  /// Returns null if no active routine exists
  Future<FlexibleRoutine?> getActiveRoutine(String userId);

  /// Set a routine as active (deactivates all others)
  Future<void> activateRoutine(String routineId, String userId);

  /// Deactivate the current active routine
  Future<void> deactivateCurrentRoutine(String userId);

  /// Stream the user's active routine (real-time updates)
  Stream<FlexibleRoutine?> watchActiveRoutine(String userId);

  /// Stream all user routines (real-time updates)
  Stream<List<FlexibleRoutine>> watchUserRoutines(String userId);

  /// Stream a specific routine by ID (real-time updates)
  Stream<FlexibleRoutine?> watchRoutineById(String routineId);

  // === ROUTINE STATE OPERATIONS ===

  /// Archive a routine (keeps it but marks as inactive)
  Future<void> archiveRoutine(String routineId);

  /// Unarchive a routine
  Future<void> unarchiveRoutine(String routineId);

  /// Mark routine as completed (period ended)
  Future<void> completeRoutine(String routineId);

  // === DAY OPERATIONS ===

  /// Mark a specific day as completed
  Future<void> completeDayWorkout({
    required String routineId,
    required DateTime date,
    required String workoutId,
  });

  /// Mark a specific day as skipped
  Future<void> skipDay({
    required String routineId,
    required DateTime date,
    String? reason,
    String? notes,
  });

  /// Recover a skipped day on another date
  Future<void> recoverDay({
    required String routineId,
    required DateTime originalDate,
    required DateTime recoveryDate,
    String? notes,
  });

  /// ✅ NEW: Perform missed workout recovery with atomic batch write
  ///
  /// Completes today's workout as recovery and marks yesterday as skipped
  /// in a single atomic operation. Uses UTC-normalized dates for timezone safety.
  ///
  /// Parameters:
  /// - routineId: ID of the active routine
  /// - workoutId: ID of the workout to complete as recovery
  /// - userId: ID of the user
  ///
  /// Returns: true if recovery succeeded, false otherwise
  Future<bool> performMissedWorkoutRecovery({
    required String routineId,
    required String workoutId,
    required String userId,
  });

  // === QUERY OPERATIONS ===

  /// Get routines within a date range
  Future<List<FlexibleRoutine>> getRoutinesInDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get routines by type
  Future<List<FlexibleRoutine>> getRoutinesByType({
    required String userId,
    required RoutineType type,
  });

  /// Check if user has any active routines
  Future<bool> hasActiveRoutines(String userId);

  /// Get routine statistics
  Future<RoutineStatistics> getRoutineStatistics(String routineId);

  // === SYNC OPERATIONS ===

  /// Sync pending changes to the server
  Future<void> syncPendingChanges(String userId);

  /// Batch update multiple routines
  Future<void> batchUpdateRoutines(List<FlexibleRoutine> routines);
}

/// Statistics for a routine
class RoutineStatistics {

  const RoutineStatistics({
    required this.totalDays,
    required this.completedDays,
    required this.skippedDays,
    required this.recoveredDays,
    required this.restDays,
    required this.completionRate,
    required this.adherenceRate,
    required this.skipRate,
    required this.currentStreak,
    required this.longestStreak,
    this.lastWorkoutDate,
    this.mostSkippedDay,
    this.mostCompletedDay,
  });

  /// Calculate statistics from a routine
  factory RoutineStatistics.fromRoutine(FlexibleRoutine routine) {
    final schedule = routine.schedule.values;

    final totalDays = routine.durationInDays;
    final completedDays = routine.completedDays;
    final skippedDays = routine.skipTracker.totalSkips;
    final recoveredDays = routine.skipTracker.totalRecoveries;
    final restDays =
        schedule.where((day) => day.status == DayStatus.rest).length;

    final completionRate = routine.progressPercentage * 100;
    final adherenceRate = routine.adherenceRate;
    final skipRate = routine.skipRate;

    final currentStreak = routine.currentStreak;
    final longestStreak = routine.skipTracker.longestSkipStreak;

    return RoutineStatistics(
      totalDays: totalDays,
      completedDays: completedDays,
      skippedDays: skippedDays,
      recoveredDays: recoveredDays,
      restDays: restDays,
      completionRate: completionRate,
      adherenceRate: adherenceRate,
      skipRate: skipRate,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastWorkoutDate: routine.lastWorkoutDate,
    );
  }
  final int totalDays;
  final int completedDays;
  final int skippedDays;
  final int recoveredDays;
  final int restDays;
  final double completionRate;
  final double adherenceRate;
  final double skipRate;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastWorkoutDate;
  final String? mostSkippedDay;
  final String? mostCompletedDay;

  /// Get summary string
  String get summary {
    return 'Completed: $completedDays/$totalDays • Adherence: ${adherenceRate.toInt()}% • Skip Rate: ${skipRate.toInt()}%';
  }
}

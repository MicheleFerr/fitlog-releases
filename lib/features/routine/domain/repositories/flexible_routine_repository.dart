/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain
/// 🎯 Feature: flexible_routine
/// 🔧 Type: repository_interface
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// FLEXIBLE ROUTINE REPOSITORY INTERFACE - v2.0 Simplified Schema
///
/// This interface defines:
/// - CRUD operations for flexible routines
/// - Active routine management
/// - Real-time streams
///
/// ⚠️ **v2.0 CHANGES**: Removed v1.0 complex features:
/// - Day-level operations (completeDay, skipDay, recoverDay) - not in v2.0 schema
/// - Archive/Complete states (isArchived, isCompleted) - not in v2.0 schema
/// - RoutineType filtering - not in v2.0 schema
/// - RoutineStatistics - simplified to use v2.0 properties only
///
/// Implementations:
/// - FirebaseFlexibleRoutineRepository (Firebase + offline cache)
library;

import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';

/// Abstract repository interface for flexible routine operations
abstract class FlexibleRoutineRepository {
  // === CRUD OPERATIONS ===

  /// Create a new routine
  Future<void> createRoutine(FlexibleRoutine routine);

  /// Update an existing routine
  Future<void> updateRoutine(FlexibleRoutine routine);

  /// Delete a routine
  Future<void> deleteRoutine(String routineId);

  /// Get a specific routine by ID
  Future<FlexibleRoutine?> getRoutineById(String routineId);

  // === QUERY OPERATIONS ===

  /// Get all routines for a user
  Future<List<FlexibleRoutine>> getUserRoutines(String userId);

  // === ACTIVATION MANAGEMENT ===

  /// Activate a routine (deactivates all others automatically)
  Future<void> activateRoutine(String userId, String routineId);

  /// Deactivate a routine
  Future<void> deactivateRoutine(String routineId);

  /// Deactivate all routines for a user
  Future<void> deactivateAllRoutines(String userId);

  // === HELPER METHODS ===

  /// Get active routine (one-time fetch, not stream)
  Future<FlexibleRoutine?> getActiveRoutine(String userId);

  /// Check if user has any active routines
  Future<bool> hasActiveRoutines(String userId);

  /// Get statistics for a routine
  Future<RoutineStatistics?> getRoutineStatistics(String routineId);

  // === STREAM OPERATIONS (Real-time) ===

  /// Stream the user's active routine (real-time updates)
  Stream<FlexibleRoutine?> watchActiveRoutine(String userId);

  /// Stream all user routines (real-time updates)
  Stream<List<FlexibleRoutine>> watchUserRoutines(String userId);

  /// Stream a specific routine by ID (real-time updates)
  Stream<FlexibleRoutine?> watchRoutineById(String routineId);
}

/// Statistics for a routine (v2.0 simplified)
///
/// **v2.0 CHANGES**: Only uses properties available in v2.0 schema
class RoutineStatistics {
  const RoutineStatistics({
    required this.totalTrainingDays,
    required this.totalWorkouts,
    required this.completedWorkouts,
    required this.completionRate,
    required this.createdAt,
    required this.lastModified,
  });

  /// Calculate statistics from a routine (v2.0 compatible)
  factory RoutineStatistics.fromRoutine(FlexibleRoutine routine) {
    final totalTrainingDays = routine.trainingDays.length;
    final totalWorkouts = routine.totalWorkouts;
    final completedWorkouts = routine.completedDays.length;

    final completionRate = totalWorkouts > 0
        ? (completedWorkouts / totalWorkouts) * 100
        : 0.0;

    return RoutineStatistics(
      totalTrainingDays: totalTrainingDays,
      totalWorkouts: totalWorkouts,
      completedWorkouts: completedWorkouts,
      completionRate: completionRate,
      createdAt: routine.createdAt,
      lastModified: routine.updatedAt,
    );
  }

  final int totalTrainingDays;
  final int totalWorkouts;
  final int completedWorkouts;
  final double completionRate;
  final DateTime createdAt;
  final DateTime lastModified;

  /// Get summary string
  @override
  String toString() {
    return 'Completed: $completedWorkouts/$totalWorkouts • Completion Rate: ${completionRate.toStringAsFixed(0)}%';
  }
}

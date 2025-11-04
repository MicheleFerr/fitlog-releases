/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain
/// 🎯 Feature: routine_pause
/// 🔧 Type: repository_interface
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// ROUTINE PAUSE REPOSITORY INTERFACE
///
/// This repository interface defines:
/// - CRUD operations for routine pauses
/// - Query methods (active, expired, by user)
/// - Batch operations
/// - Stream for real-time updates
///
/// Implementations:
/// - FirebaseRoutinePauseRepository (Firestore)
library;

import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_pause.dart';

/// Repository interface for routine pauses
abstract class RoutinePauseRepository {
  // === CRUD OPERATIONS ===

  /// Get pause by ID
  Future<RoutinePause?> getPauseById(String pauseId);

  /// Get all active pauses for a routine
  Future<List<RoutinePause>> getActivePausesForRoutine(String routineId);

  /// Get all active pauses for a user (across all routines)
  Future<List<RoutinePause>> getActivePausesForUser(String userId);

  /// Get all pauses for a routine (active + inactive)
  Future<List<RoutinePause>> getAllPausesForRoutine(String routineId);

  /// Get all expired but still active pauses (need auto-resume)
  Future<List<RoutinePause>> getExpiredPauses(String userId);

  /// Create a new pause
  Future<RoutinePause> createPause(RoutinePause pause);

  /// Update existing pause
  Future<void> updatePause(RoutinePause pause);

  /// Delete pause
  Future<void> deletePause(String pauseId);

  // === BATCH OPERATIONS ===

  /// Resume multiple pauses (batch operation)
  Future<void> resumePauses(List<RoutinePause> pauses);

  // === QUERY HELPERS ===

  /// Check if routine is currently paused
  Future<bool> isRoutinePaused(String routineId);

  /// Get active pause for routine (null if not paused)
  Future<RoutinePause?> getActivePause(String routineId);

  // === STREAMS ===

  /// Stream of active pauses for a user
  Stream<List<RoutinePause>> watchActivePauses(String userId);

  /// Stream of active pause for specific routine
  Stream<RoutinePause?> watchRoutinePause(String routineId);
}

/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/domain/repositories
/// 🎯 Feature: flexible_routine
/// 🔧 Type: repository interface
/// 🌍 Localization: N/A
/// 📱 Platform: Universal
///
/// ROUTINE REPOSITORY - v2.0
///
/// Abstract interface for routine persistence operations.
/// Implementations handle Firestore sync, local caching, etc.
library;

import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';

/// Repository contract for FlexibleRoutine CRUD and streaming operations
///
/// Implementations:
/// - FirebaseRoutineRepository: Firestore real-time sync
/// - LocalRoutineRepository: Local SQLite caching (future)
abstract class RoutineRepository {
  /// Create a new routine in storage
  ///
  /// Automatically deactivates all other routines for this user
  /// (only one active routine allowed per user)
  ///
  /// Throws:
  /// - FirebaseException if Firestore write fails
  /// - ValidationException if routine data invalid
  Future<void> createRoutine(FlexibleRoutine routine);

  /// Update an existing routine
  ///
  /// Updates `updatedAt` timestamp automatically
  ///
  /// Throws:
  /// - FirebaseException if Firestore write fails
  /// - NotFoundException if routine doesn't exist
  Future<void> updateRoutine(FlexibleRoutine routine);

  /// Delete a routine permanently
  ///
  /// If deleting the active routine, automatically activates
  /// the most recently created inactive routine (if any exists)
  ///
  /// Throws:
  /// - FirebaseException if Firestore delete fails
  /// - NotFoundException if routine doesn't exist
  Future<void> deleteRoutine(String routineId);

  /// Get the currently active routine for a user (one-time read)
  ///
  /// Returns null if no active routine exists
  ///
  /// Use [watchActiveRoutine] for real-time updates
  Future<FlexibleRoutine?> getActiveRoutine(String userId);

  /// Watch the currently active routine for a user (real-time stream)
  ///
  /// Emits whenever the active routine changes (updates, activation change, etc.)
  /// Emits null if no active routine exists
  ///
  /// Automatically cancels subscription when provider disposed
  ///
  /// Returns:
  /// - Stream of FlexibleRoutine with real-time updates
  Stream<FlexibleRoutine?> watchActiveRoutine(String userId);

  /// Watch all routines for a user (real-time stream)
  ///
  /// Includes both active and inactive routines
  /// Sorted by createdAt descending (newest first)
  ///
  /// Returns:
  /// - Stream of List of FlexibleRoutine with real-time updates
  Stream<List<FlexibleRoutine>> watchUserRoutines(String userId);

  /// Deactivate all routines for a user
  ///
  /// Used when creating a new routine (to ensure only one active)
  /// or when user wants to pause all routines
  ///
  /// Throws:
  /// - FirebaseException if batch write fails
  Future<void> deactivateAllRoutines(String userId);

  /// Activate a specific routine (and deactivate all others)
  ///
  /// Ensures only one routine is active per user
  ///
  /// Throws:
  /// - FirebaseException if batch write fails
  /// - NotFoundException if routine doesn't exist
  Future<void> activateRoutine(String routineId);
}

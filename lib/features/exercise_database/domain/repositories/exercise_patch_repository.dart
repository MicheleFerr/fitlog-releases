/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/domain/repositories
/// 🎯 Feature: exercise_database
/// 🔧 Type: repository interface
///
/// Repository interface for managing exercise patches (user corrections)
///
/// **Responsibilities**:
/// - Submit new patches to Firestore
/// - Retrieve patches for review (user or admin)
/// - Approve/reject patches (admin only)
/// - Stream real-time patch updates
library;

import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_patch.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

abstract class ExercisePatchRepository {
  /// Submit a new patch to Firestore
  ///
  /// **Validation checks** (in implementation):
  /// 1. Check for duplicate pending patches (same exerciseId + fieldName + userId)
  /// 2. Validate reason length (min 10 chars)
  /// 3. Set expiration date (createdAt + 30 days)
  ///
  /// Returns [Right(patchId)] on success, [Left(Failure)] on error
  Future<Either<Failure, String>> submitPatch({
    required String exerciseId,
    required String fieldName,
    required dynamic oldValue,
    required dynamic newValue,
    required dynamic originalValue,
    required String reason,
    required String language,
    required int version,
  });

  /// Get all patches submitted by a specific user
  ///
  /// **Filters**: Only patches where userId matches
  /// **Ordering**: Most recent first (createdAt DESC)
  ///
  /// Returns [Right(List<ExercisePatch>)] on success
  Future<Either<Failure, List<ExercisePatch>>> getUserPatches(String userId);

  /// Get all pending patches (for admin review)
  ///
  /// **Filters**: status == PENDING, not expired
  /// **Ordering**: Oldest first (createdAt ASC) - FIFO review
  ///
  /// Returns [Right(List<ExercisePatch>)] on success
  Future<Either<Failure, List<ExercisePatch>>> getPendingPatches();

  /// Get patches for a specific exercise (for admin detail view)
  ///
  /// **Filters**: exerciseId matches
  /// **Ordering**: Most recent first
  ///
  /// Returns [Right(List<ExercisePatch>)] on success
  Future<Either<Failure, List<ExercisePatch>>> getExercisePatches(
    String exerciseId,
  );

  /// Approve a patch (admin only)
  ///
  /// **Updates**:
  /// - status: PENDING → APPROVED
  /// - approvedAt: current timestamp
  /// - approvedBy: admin userId
  ///
  /// **Side effects**: Cloud Function will detect status change and apply to Firestore
  ///
  /// Returns [Right(void)] on success
  Future<Either<Failure, void>> approvePatch({
    required String patchId,
    required String adminUserId,
    String? adminNote,
  });

  /// Reject a patch (admin only)
  ///
  /// **Updates**:
  /// - status: PENDING → REJECTED
  /// - rejectedAt: current timestamp
  /// - rejectReason: reason for rejection
  /// - adminNote: optional additional notes
  ///
  /// Returns [Right(void)] on success
  Future<Either<Failure, void>> rejectPatch({
    required String patchId,
    required String adminUserId,
    required String reason,
    String? adminNote,
  });

  /// Stream of patches for a user (real-time updates)
  ///
  /// **Use case**: User's "My Patches" screen
  ///
  /// Returns stream of patches for userId
  Stream<Either<Failure, List<ExercisePatch>>> watchUserPatches(String userId);

  /// Stream of pending patches count (for admin badge)
  ///
  /// **Use case**: Admin dashboard badge counter
  ///
  /// Returns stream of pending patch count
  Stream<Either<Failure, int>> watchPendingPatchCount();

  /// Get a single patch by ID
  ///
  /// **Use case**: Admin detail view, deep linking
  ///
  /// Returns [Right(ExercisePatch)] on success, [Left(Failure)] if not found
  Future<Either<Failure, ExercisePatch>> getPatchById(String patchId);

  /// Delete a patch (soft delete - audit trail preservation)
  ///
  /// **Implementation note**: Should only update status to EXPIRED,
  /// never actually delete the document (audit trail)
  ///
  /// Returns [Right(void)] on success
  Future<Either<Failure, void>> deletePatch(String patchId);
}

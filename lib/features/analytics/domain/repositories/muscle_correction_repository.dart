/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/repositories
/// 🎯 Feature: analytics
/// 🔧 Type: repository interface
///
/// MuscleCorrectionRepository - Contract for muscle group correction operations
///
/// **Purpose**: Define operations for saving/retrieving corrections locally and remotely
///
/// **Responsibilities**:
/// - Local storage (Hive): Immediate UI effect
/// - Remote storage (Firestore): Admin review + feedback
/// - Watch feedback status: Real-time listener for admin approval/rejection
///
/// **Workflow**:
/// 1. `saveLocalCorrection()` → Hive (immediate)
/// 2. `submitFeedbackToAdmin()` → Firestore (async)
/// 3. `watchFeedbackStatus()` → Stream for real-time updates
/// 4. `getLocalCorrections()` → All corrections from Hive
library;

import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/muscle_correction.dart';

/// Feedback status for admin review
///
/// **Lifecycle**:
/// 1. `pending`: Submitted, awaiting admin review
/// 2. `approved`: Admin approved → global database updated
/// 3. `rejected`: Admin rejected → user correction remains local-only
enum FeedbackStatus {
  /// Submitted to admin, awaiting review
  pending,

  /// Admin approved the correction
  approved,

  /// Admin rejected the correction
  rejected,
}

/// Repository interface for muscle group corrections
abstract class MuscleCorrectionRepository {
  /// Save correction to local storage (Hive)
  ///
  /// **Effect**: Immediate UI update (exercise shows new muscle group)
  ///
  /// **Storage**: Hive box `corrections` with key = `exerciseName`
  ///
  /// **Returns**: `Right(unit)` on success, `Left(Failure)` on error
  Future<Either<Failure, Unit>> saveLocalCorrection(
    MuscleCorrection correction,
  );

  /// Get all local corrections from Hive
  ///
  /// **Use Case**: Display user's correction history, sync to UI
  ///
  /// **Returns**: List of corrections (empty if none)
  Future<Either<Failure, List<MuscleCorrection>>> getLocalCorrections();

  /// Submit feedback to admin for global database update
  ///
  /// **Effect**: Creates Firestore document in `muscle_group_feedback` collection
  ///
  /// **Document Structure**:
  /// ```dart
  /// {
  ///   'exerciseName': 'Bench Press',
  ///   'oldGroup': 'Back',
  ///   'newGroup': 'Chest',
  ///   'userId': 'user123',
  ///   'timestamp': FieldValue.serverTimestamp(),
  ///   'status': 'pending',
  ///   'notificationShown': false,
  ///   'pushSent': false,
  /// }
  /// ```
  ///
  /// **Returns**: `Right(unit)` on success, `Left(Failure)` on error
  Future<Either<Failure, Unit>> submitFeedbackToAdmin(
    MuscleCorrection correction,
  );

  /// Watch feedback status for a specific correction
  ///
  /// **Use Case**: Real-time listener for admin approval/rejection
  ///
  /// **Returns**: Stream of `FeedbackStatus` (updates when admin changes status)
  ///
  /// **Note**: Use with Firestore `snapshots()` stream
  Stream<Either<Failure, FeedbackStatus>> watchFeedbackStatus(
    String correctionId,
  );

  /// Delete a local correction from Hive
  ///
  /// **Use Case**: User wants to revert a correction
  ///
  /// **Returns**: `Right(unit)` on success, `Left(Failure)` on error
  Future<Either<Failure, Unit>> deleteLocalCorrection(String exerciseName);
}

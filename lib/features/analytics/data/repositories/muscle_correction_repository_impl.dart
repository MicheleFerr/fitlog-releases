/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/data/repositories
/// 🎯 Feature: analytics
/// 🔧 Type: repository implementation
///
/// MuscleCorrectionRepositoryImpl - Implementation of muscle correction operations
///
/// **Purpose**: Concrete implementation for local (Hive) and remote (Firestore) corrections
///
/// **Responsibilities**:
/// - Store corrections in Hive for immediate UI effect
/// - Submit feedback to Firestore for admin review
/// - Watch real-time feedback status changes
/// - Retrieve and delete local corrections
///
/// **Storage Strategy**:
/// - **Local**: Hive box `corrections` with key = exerciseName (one per exercise)
/// - **Remote**: Firestore collection `muscle_group_feedback`
///
/// **Error Handling**:
/// - Hive errors → LocalStorageFailure
/// - Firestore errors → FirestoreFailure
/// - All methods return Either<Failure, T>
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/features/analytics/data/local/hive_muscle_correction_adapter.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/muscle_correction.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/repositories/muscle_correction_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

/// Implementation of muscle correction repository
///
/// **Dependencies**:
/// - HiveBoxManagerEnhanced: Local storage access (initialized version)
/// - FirebaseFirestore: Remote storage access
/// - FirebaseAuth: User authentication (via instance)
class MuscleCorrectionRepositoryImpl implements MuscleCorrectionRepository {
  MuscleCorrectionRepositoryImpl({
    required this.hiveBoxManager,
    required this.firestore,
  });

  final HiveBoxManagerEnhanced hiveBoxManager;
  final FirebaseFirestore firestore;

  /// Hive box name for corrections storage
  static const String _correctionsBoxName = 'corrections';

  /// Firestore collection name for admin feedback
  static const String _feedbackCollectionName = 'muscle_group_feedback';

  @override
  Future<Either<Failure, Unit>> saveLocalCorrection(
    MuscleCorrection correction,
  ) async {
    try {
      // Get or create Hive box
      final box = await hiveBoxManager.openBox<Map<String, dynamic>>(
        _correctionsBoxName,
      );

      // Store correction with exerciseName as key
      // This ensures one correction per exercise (latest wins)
      await box.put(correction.exerciseName, correction.toHiveJson());

      return right(unit);
    } catch (e) {
      return left(
        CacheFailure('Failed to save correction locally: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<MuscleCorrection>>> getLocalCorrections() async {
    try {
      // Get Hive box
      final box = await hiveBoxManager.openBox<Map<String, dynamic>>(
        _correctionsBoxName,
      );

      // Retrieve all corrections from box
      final corrections = <MuscleCorrection>[];

      for (final dynamic value in box.values) {
        if (value is Map<String, dynamic>) {
          try {
            final correction = MuscleCorrectionHiveExtension.fromHiveJson(
              value,
            );
            corrections.add(correction);
          } catch (e) {
            // Skip malformed entries
            continue;
          }
        }
      }

      // Sort by timestamp (newest first)
      corrections.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return right(corrections);
    } catch (e) {
      return left(
        CacheFailure('Failed to get local corrections: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> submitFeedbackToAdmin(
    MuscleCorrection correction,
  ) async {
    try {
      // Get current user ID
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        return left(
          const ServerFailure(
            'User not authenticated. Cannot submit feedback.',
          ),
        );
      }

      // Create Firestore document
      final docRef = firestore.collection(_feedbackCollectionName).doc();

      await docRef.set({
        'exerciseName': correction.exerciseName,
        'oldGroup': correction.oldMuscleGroup,
        'newGroup': correction.newMuscleGroup,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': FeedbackStatus.pending.name,
        'notificationShown': false,
        'pushSent': false,
      });

      return right(unit);
    } on FirebaseException catch (e) {
      return left(
        ServerFailure(
          'Failed to submit feedback: ${e.message ?? e.toString()}',
        ),
      );
    } catch (e) {
      return left(ServerFailure('Failed to submit feedback: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, FeedbackStatus>> watchFeedbackStatus(
    String correctionId,
  ) {
    try {
      // Watch Firestore document for status changes
      return firestore
          .collection(_feedbackCollectionName)
          .doc(correctionId)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) {
              return left(const ServerFailure('Correction document not found'));
            }

            final data = snapshot.data();
            if (data == null) {
              return left(
                const ServerFailure('Correction document has no data'),
              );
            }

            // Parse status string to enum
            final statusString = data['status'] as String?;
            if (statusString == null) {
              return left(
                const ServerFailure('Status field missing in document'),
              );
            }

            try {
              final status = FeedbackStatus.values.firstWhere(
                (e) => e.name == statusString,
                orElse: () => FeedbackStatus.pending,
              );
              return right(status);
            } catch (e) {
              return left(
                ServerFailure('Failed to parse status: ${e.toString()}'),
              );
            }
          });
    } catch (e) {
      // If stream creation fails, return error stream
      return Stream.value(
        left(ServerFailure('Failed to watch feedback status: ${e.toString()}')),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteLocalCorrection(
    String exerciseName,
  ) async {
    try {
      // Get Hive box
      final box = await hiveBoxManager.openBox<Map<String, dynamic>>(
        _correctionsBoxName,
      );

      // Delete correction by exerciseName key
      await box.delete(exerciseName);

      return right(unit);
    } catch (e) {
      return left(CacheFailure('Failed to delete correction: ${e.toString()}'));
    }
  }
}

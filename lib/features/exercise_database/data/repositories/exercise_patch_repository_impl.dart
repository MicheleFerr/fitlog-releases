/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/data/repositories
/// 🎯 Feature: exercise_database
/// 🔧 Type: repository implementation
///
/// Firebase Firestore implementation of ExercisePatchRepository
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_patch.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/enums/patch_status.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/repositories/exercise_patch_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/shared/domain/services/input_validator.dart'; // 🔐 SECURITY: XSS/injection prevention

class ExercisePatchRepositoryImpl implements ExercisePatchRepository {
  ExercisePatchRepositoryImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// 🔐 SECURITY: Input validator for XSS/injection prevention
  final InputValidator _validator = InputValidator();

  /// Firestore collection reference
  CollectionReference<Map<String, dynamic>> get _patchesCollection =>
      _firestore.collection('exercise_patches');

  @override
  Future<Either<Failure, String>> submitPatch({
    required String exerciseId,
    required String fieldName,
    required dynamic oldValue,
    required dynamic newValue,
    required dynamic originalValue,
    required String reason,
    required String language,
    required int version,
  }) async {
    try {
      // Get current user ID from auth (implementation will use Firebase Auth)
      final userId = _firestore.app.options.projectId; // Placeholder - replace with actual auth

      // 🔐 SECURITY: Sanitize user input to prevent XSS/injection attacks
      final sanitizedReason = _validator.sanitize(reason);

      // 1. Validate reason length (after sanitization)
      if (sanitizedReason.trim().length < 10) {
        return const Left(
          ValidationFailure(
            'Reason too short (minimum 10 characters)',
            code: 'REASON_TOO_SHORT',
          ),
        );
      }

      // 🔐 SECURITY: Check for dangerous patterns in reason
      if (_validator.containsDangerousPatterns(reason)) {
        return const Left(
          ValidationFailure(
            'Invalid characters detected in reason',
            code: 'DANGEROUS_PATTERNS_DETECTED',
          ),
        );
      }

      // 🔐 SECURITY: Sanitize newValue if it's a string
      dynamic sanitizedNewValue = newValue;
      if (newValue is String) {
        sanitizedNewValue = _validator.sanitize(newValue);

        // Check for dangerous patterns in newValue
        if (_validator.containsDangerousPatterns(newValue)) {
          return const Left(
            ValidationFailure(
              'Invalid characters detected in new value',
              code: 'DANGEROUS_PATTERNS_DETECTED',
            ),
          );
        }
      }

      // 2. Check for duplicate pending patches
      final duplicateCheck = await _patchesCollection
          .where('exerciseId', isEqualTo: exerciseId)
          .where('fieldName', isEqualTo: fieldName)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: PatchStatus.pending.value)
          .limit(1)
          .get();

      if (duplicateCheck.docs.isNotEmpty) {
        return const Left(
          ValidationFailure(
            'Duplicate patch exists',
            code: 'DUPLICATE_PATCH',
          ),
        );
      }

      // 3. Create patch document
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(days: 30));

      final patchDoc = _patchesCollection.doc();
      final patch = ExercisePatch(
        id: patchDoc.id,
        exerciseId: exerciseId,
        userId: userId,
        fieldName: fieldName,
        oldValue: oldValue,
        newValue: sanitizedNewValue, // 🔐 SECURITY: Using sanitized value
        originalValue: originalValue,
        reason: sanitizedReason.trim(), // 🔐 SECURITY: Using sanitized reason
        status: PatchStatus.pending,
        language: language,
        createdAt: now,
        expiresAt: expiresAt,
        version: version,
      );

      // 4. Submit to Firestore
      await patchDoc.set(patch.toJson());

      return Right(patchDoc.id);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(
          'Firebase error: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Unexpected error: $e',
          code: 'UNKNOWN_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ExercisePatch>>> getUserPatches(
    String userId,
  ) async {
    try {
      final snapshot = await _patchesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final patches = snapshot.docs
          .map((doc) => ExercisePatch.fromJson(doc.data()))
          .toList();

      return Right(patches);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(
          'Firebase error: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Unexpected error: $e',
          code: 'UNKNOWN_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ExercisePatch>>> getPendingPatches() async {
    try {
      final now = DateTime.now();

      final snapshot = await _patchesCollection
          .where('status', isEqualTo: PatchStatus.pending.value)
          .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('expiresAt')
          .orderBy('createdAt')
          .get();

      final patches = snapshot.docs
          .map((doc) => ExercisePatch.fromJson(doc.data()))
          .toList();

      return Right(patches);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(
          'Firebase error: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Unexpected error: $e',
          code: 'UNKNOWN_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ExercisePatch>>> getExercisePatches(
    String exerciseId,
  ) async {
    try {
      final snapshot = await _patchesCollection
          .where('exerciseId', isEqualTo: exerciseId)
          .orderBy('createdAt', descending: true)
          .get();

      final patches = snapshot.docs
          .map((doc) => ExercisePatch.fromJson(doc.data()))
          .toList();

      return Right(patches);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(
          'Firebase error: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Unexpected error: $e',
          code: 'UNKNOWN_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> approvePatch({
    required String patchId,
    required String adminUserId,
    String? adminNote,
  }) async {
    try {
      final now = DateTime.now();

      final updateData = {
        'status': PatchStatus.approved.value,
        'approvedAt': Timestamp.fromDate(now),
        'approvedBy': adminUserId,
      };

      if (adminNote != null) {
        updateData['adminNote'] = adminNote;
      }

      await _patchesCollection.doc(patchId).update(updateData);

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(
          'Firebase error: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Unexpected error: $e',
          code: 'UNKNOWN_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> rejectPatch({
    required String patchId,
    required String adminUserId,
    required String reason,
    String? adminNote,
  }) async {
    try {
      final now = DateTime.now();

      final updateData = {
        'status': PatchStatus.rejected.value,
        'rejectedAt': Timestamp.fromDate(now),
        'rejectReason': reason,
      };

      if (adminNote != null) {
        updateData['adminNote'] = adminNote;
      }

      await _patchesCollection.doc(patchId).update(updateData);

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(
          'Firebase error: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Unexpected error: $e',
          code: 'UNKNOWN_ERROR',
        ),
      );
    }
  }

  @override
  Stream<Either<Failure, List<ExercisePatch>>> watchUserPatches(
    String userId,
  ) {
    try {
      return _patchesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final patches = snapshot.docs
            .map((doc) => ExercisePatch.fromJson(doc.data()))
            .toList();
        return Right<Failure, List<ExercisePatch>>(patches);
      }).handleError((error) {
        if (error is FirebaseException) {
          return Left<Failure, List<ExercisePatch>>(
            ServerFailure(
              'Firebase error: ${error.message}',
              code: error.code,
            ),
          );
        }
        return Left<Failure, List<ExercisePatch>>(
          UnexpectedFailure(
            'Unexpected error: $error',
            code: 'UNKNOWN_ERROR',
          ),
        );
      });
    } catch (e) {
      return Stream.value(
        Left(
          UnexpectedFailure(
            'Unexpected error: $e',
            code: 'UNKNOWN_ERROR',
          ),
        ),
      );
    }
  }

  @override
  Stream<Either<Failure, int>> watchPendingPatchCount() {
    try {
      final now = DateTime.now();

      return _patchesCollection
          .where('status', isEqualTo: PatchStatus.pending.value)
          .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
          .snapshots()
          .map((snapshot) {
        return Right<Failure, int>(snapshot.docs.length);
      }).handleError((error) {
        if (error is FirebaseException) {
          return Left<Failure, int>(
            ServerFailure(
              'Firebase error: ${error.message}',
              code: error.code,
            ),
          );
        }
        return Left<Failure, int>(
          UnexpectedFailure(
            'Unexpected error: $error',
            code: 'UNKNOWN_ERROR',
          ),
        );
      });
    } catch (e) {
      return Stream.value(
        Left(
          UnexpectedFailure(
            'Unexpected error: $e',
            code: 'UNKNOWN_ERROR',
          ),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, ExercisePatch>> getPatchById(String patchId) async {
    try {
      final doc = await _patchesCollection.doc(patchId).get();

      if (!doc.exists || doc.data() == null) {
        return const Left(
          ValidationFailure(
            'Patch not found',
            code: 'PATCH_NOT_FOUND',
          ),
        );
      }

      final patch = ExercisePatch.fromJson(doc.data()!);
      return Right(patch);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(
          'Firebase error: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Unexpected error: $e',
          code: 'UNKNOWN_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deletePatch(String patchId) async {
    try {
      // Soft delete - set status to EXPIRED (preserve audit trail)
      await _patchesCollection.doc(patchId).update({
        'status': PatchStatus.expired.value,
      });

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(
          'Firebase error: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Unexpected error: $e',
          code: 'UNKNOWN_ERROR',
        ),
      );
    }
  }
}

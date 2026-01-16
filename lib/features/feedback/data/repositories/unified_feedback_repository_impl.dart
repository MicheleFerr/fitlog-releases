/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/feedback/data/repositories
/// 🎯 Feature: unified_feedback
/// 🔧 Type: repository_implementation
///
/// Firestore implementation of IUnifiedFeedbackRepository
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/core/data/mixins/firebase_error_mapper_mixin.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/entities/unified_feedback.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/enums/unified_feedback_type.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/repositories/i_unified_feedback_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';
import 'package:gymbro_flutter_new/shared/domain/services/input_validator.dart'; // 🔐 SECURITY: XSS/injection prevention

class UnifiedFeedbackRepositoryImpl with FirebaseErrorMapperMixin implements IUnifiedFeedbackRepository {
  UnifiedFeedbackRepositoryImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// 🔐 SECURITY: Input validator for XSS/injection prevention
  final InputValidator _validator = InputValidator();

  /// Firestore collection reference
  CollectionReference<Map<String, dynamic>> get _feedbackCollection =>
      _firestore.collection('feedback');

  // ========================================
  // USER OPERATIONS
  // ========================================

  @override
  Future<Either<Failure, String>> submitFeedback(
    UnifiedFeedback feedback,
  ) async {
    // 1. Validate feedback
    if (feedback.message.trim().isEmpty) {
      return const Left(
        ValidationFailure(
          'Message cannot be empty',
          code: 'EMPTY_MESSAGE',
        ),
      );
    }

    if (feedback.userId.trim().isEmpty) {
      return const Left(
        ValidationFailure(
          'User ID cannot be empty',
          code: 'EMPTY_USER_ID',
        ),
      );
    }

    // 🔐 SECURITY: Check for dangerous patterns in message
    if (_validator.containsDangerousPatterns(feedback.message)) {
      return const Left(
        ValidationFailure(
          'Invalid characters detected in feedback message',
          code: 'DANGEROUS_PATTERNS_DETECTED',
        ),
      );
    }

    // 🔐 SECURITY: Sanitize message before storing
    final sanitizedMessage = _validator.sanitize(feedback.message);

    // Validate sanitized message length
    if (sanitizedMessage.trim().length < 10) {
      return const Left(
        ValidationFailure(
          'Feedback message too short (minimum 10 characters after sanitization)',
          code: 'MESSAGE_TOO_SHORT',
        ),
      );
    }

    // 2. Create sanitized feedback data for Firestore
    // Note: We modify the JSON representation rather than the entity itself
    final feedbackJson = feedback.toJson();
    feedbackJson['message'] = sanitizedMessage; // 🔐 SECURITY: Replace with sanitized message

    // 3. Create Firestore document with error handling via mixin
    return handleFirebaseOperation(
      () async {
        final docRef = _feedbackCollection.doc(feedback.id);
        await docRef.set(feedbackJson);
        return feedback.id;
      },
      operationName: 'submitFeedback',
    );
  }

  @override
  Future<Either<Failure, List<UnifiedFeedback>>> getUserFeedback(
    String userId,
  ) async {
    return handleFirebaseOperation(
      () async {
        final snapshot = await _feedbackCollection
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();

        final feedbackList = snapshot.docs
            .map((doc) => UnifiedFeedback.fromJson(doc.data()))
            .toList();

        return feedbackList;
      },
      operationName: 'getUserFeedback',
    );
  }

  @override
  Future<Either<Failure, List<UnifiedFeedback>>> getUserFeedbackByType(
    String userId,
    UnifiedFeedbackType type,
  ) async {
    return handleFirebaseOperation(
      () async {
        final snapshot = await _feedbackCollection
            .where('userId', isEqualTo: userId)
            .where('type', isEqualTo: type.value)
            .orderBy('createdAt', descending: true)
            .get();

        final feedbackList = snapshot.docs
            .map((doc) => UnifiedFeedback.fromJson(doc.data()))
            .toList();

        return feedbackList;
      },
      operationName: 'getUserFeedbackByType',
    );
  }

  // ========================================
  // ADMIN OPERATIONS - QUERIES
  // ========================================

  @override
  Future<Either<Failure, List<UnifiedFeedback>>> getAllFeedback({
    int? limit,
    UnifiedFeedbackType? type,
    UnifiedFeedbackStatus? status,
    FeedbackSeverity? severity,
  }) async {
    return handleFirebaseOperation(
      () async {
        Query<Map<String, dynamic>> query = _feedbackCollection;

        // Apply filters
        if (type != null) {
          query = query.where('type', isEqualTo: type.value);
        }
        if (status != null) {
          query = query.where('status', isEqualTo: status.value);
        }
        if (severity != null) {
          query = query.where('severity', isEqualTo: severity.value);
        }

        // Order by createdAt (most recent first)
        query = query.orderBy('createdAt', descending: true);

        // Apply limit if specified
        if (limit != null) {
          query = query.limit(limit);
        }

        final snapshot = await query.get();

        final feedbackList = snapshot.docs
            .map((doc) => UnifiedFeedback.fromJson(doc.data()))
            .toList();

        return feedbackList;
      },
      operationName: 'getAllFeedback',
    );
  }

  @override
  Future<Either<Failure, UnifiedFeedback>> getFeedbackById(
    String feedbackId,
  ) async {
    return handleFirebaseOperation(
      () async {
        final doc = await _feedbackCollection.doc(feedbackId).get();

        if (!doc.exists || doc.data() == null) {
          throw const ValidationFailure(
            'Feedback not found',
            code: 'FEEDBACK_NOT_FOUND',
          );
        }

        final feedback = UnifiedFeedback.fromJson(doc.data()!);
        return feedback;
      },
      operationName: 'getFeedbackById',
    );
  }

  @override
  Future<Either<Failure, List<UnifiedFeedback>>> getPendingFeedback() async {
    return handleFirebaseOperation(
      () async {
        // Get feedback with open or reviewing status
        final snapshot = await _feedbackCollection
            .where('status',
                whereIn: [UnifiedFeedbackStatus.open.value, UnifiedFeedbackStatus.reviewing.value])
            .orderBy('severity', descending: true) // Critical first
            .orderBy('createdAt') // Oldest first within same severity
            .get();

        final feedbackList = snapshot.docs
            .map((doc) => UnifiedFeedback.fromJson(doc.data()))
            .toList();

        // Sort by severity level (Firestore string sorting might not work as expected)
        feedbackList.sort((a, b) {
          final severityCompare = b.severity.level.compareTo(a.severity.level);
          if (severityCompare != 0) return severityCompare;
          return a.createdAt.compareTo(b.createdAt); // Older first
        });

        return feedbackList;
      },
      operationName: 'getPendingFeedback',
    );
  }

  @override
  Future<Either<Failure, List<UnifiedFeedback>>> getFeedbackByType(
    UnifiedFeedbackType type, {
    int? limit,
  }) async {
    return handleFirebaseOperation(
      () async {
        Query<Map<String, dynamic>> query = _feedbackCollection
            .where('type', isEqualTo: type.value)
            .orderBy('createdAt', descending: true);

        if (limit != null) {
          query = query.limit(limit);
        }

        final snapshot = await query.get();

        final feedbackList = snapshot.docs
            .map((doc) => UnifiedFeedback.fromJson(doc.data()))
            .toList();

        return feedbackList;
      },
      operationName: 'getFeedbackByType',
    );
  }

  @override
  Future<Either<Failure, List<UnifiedFeedback>>> getFeedbackByStatus(
    UnifiedFeedbackStatus status, {
    int? limit,
  }) async {
    return handleFirebaseOperation(
      () async {
        Query<Map<String, dynamic>> query = _feedbackCollection
            .where('status', isEqualTo: status.value)
            .orderBy('createdAt', descending: true);

        if (limit != null) {
          query = query.limit(limit);
        }

        final snapshot = await query.get();

        final feedbackList = snapshot.docs
            .map((doc) => UnifiedFeedback.fromJson(doc.data()))
            .toList();

        return feedbackList;
      },
      operationName: 'getFeedbackByStatus',
    );
  }

  // ========================================
  // ADMIN OPERATIONS - ACTIONS
  // ========================================

  @override
  Future<Either<Failure, void>> updateFeedbackStatus({
    required String feedbackId,
    required UnifiedFeedbackStatus newStatus,
    required String adminUserId,
    String? adminNote,
  }) async {
    return handleFirebaseVoidOperation(
      () async {
        final now = DateTime.now();

        final updateData = <String, dynamic>{
          'status': newStatus.value,
          'reviewedBy': adminUserId,
          'updatedAt': Timestamp.fromDate(now),
        };

        // Set resolvedAt if status is resolved/dismissed/closed
        if (newStatus.isCompleted) {
          updateData['resolvedAt'] = Timestamp.fromDate(now);
        }

        // Add admin note if provided
        if (adminNote != null && adminNote.trim().isNotEmpty) {
          updateData['adminNotes'] = adminNote;
        }

        await _feedbackCollection.doc(feedbackId).update(updateData);
      },
      operationName: 'updateFeedbackStatus',
    );
  }

  @override
  Future<Either<Failure, void>> updateFeedbackSeverity({
    required String feedbackId,
    required FeedbackSeverity newSeverity,
  }) async {
    return handleFirebaseVoidOperation(
      () async {
        await _feedbackCollection.doc(feedbackId).update({
          'severity': newSeverity.value,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      },
      operationName: 'updateFeedbackSeverity',
    );
  }

  @override
  Future<Either<Failure, void>> addAdminNote({
    required String feedbackId,
    required String note,
    required String adminUserId,
  }) async {
    // 1. Validate note
    if (note.trim().isEmpty) {
      return const Left(
        ValidationFailure(
          'Note cannot be empty',
          code: 'EMPTY_NOTE',
        ),
      );
    }

    // 🔐 SECURITY: Check for dangerous patterns in admin note
    if (_validator.containsDangerousPatterns(note)) {
      return const Left(
        ValidationFailure(
          'Invalid characters detected in admin note',
          code: 'DANGEROUS_PATTERNS_DETECTED',
        ),
      );
    }

    // 🔐 SECURITY: Sanitize admin note before storing
    final sanitizedNote = _validator.sanitize(note);

    // Validate sanitized note length
    if (sanitizedNote.trim().isEmpty) {
      return const Left(
        ValidationFailure(
          'Note cannot be empty after sanitization',
          code: 'EMPTY_NOTE_AFTER_SANITIZATION',
        ),
      );
    }

    // 2. Get current feedback to append note
    final feedbackResult = await getFeedbackById(feedbackId);

    return feedbackResult.fold(
      (failure) => Left(failure),
      (feedback) async {
        // Use sanitized note instead of original
        final updatedFeedback = feedback.addAdminNote(sanitizedNote); // 🔐 SECURITY: Using sanitized note

        return handleFirebaseVoidOperation(
          () async {
            await _feedbackCollection.doc(feedbackId).update({
              'adminNotes': updatedFeedback.adminNotes,
              'reviewedBy': adminUserId,
              'updatedAt': Timestamp.fromDate(DateTime.now()),
            });
          },
          operationName: 'addAdminNote',
        );
      },
    );
  }

  @override
  Future<Either<Failure, void>> deleteFeedback(String feedbackId) async {
    return handleFirebaseVoidOperation(
      () async {
        // Soft delete - set status to closed
        await _feedbackCollection.doc(feedbackId).update({
          'status': UnifiedFeedbackStatus.closed.value,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      },
      operationName: 'deleteFeedback',
    );
  }

  // ========================================
  // REAL-TIME STREAMS
  // ========================================

  @override
  Stream<Either<Failure, int>> watchPendingFeedbackCount() {
    try {
      return _feedbackCollection
          .where('status', whereIn: [
            UnifiedFeedbackStatus.open.value,
            UnifiedFeedbackStatus.reviewing.value,
          ])
          .snapshots()
          .map((snapshot) => Right<Failure, int>(snapshot.docs.length))
          .handleError((error) {
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
  Stream<Either<Failure, List<UnifiedFeedback>>> watchUserFeedback(
    String userId,
  ) {
    try {
      return _feedbackCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final feedbackList = snapshot.docs
            .map((doc) => UnifiedFeedback.fromJson(doc.data()))
            .toList();
        return Right<Failure, List<UnifiedFeedback>>(feedbackList);
      }).handleError((error) {
        if (error is FirebaseException) {
          return Left<Failure, List<UnifiedFeedback>>(
            ServerFailure(
              'Firebase error: ${error.message}',
              code: error.code,
            ),
          );
        }
        return Left<Failure, List<UnifiedFeedback>>(
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
  Stream<Either<Failure, List<UnifiedFeedback>>> watchFeedbackByType(
    UnifiedFeedbackType type,
  ) {
    try {
      return _feedbackCollection
          .where('type', isEqualTo: type.value)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final feedbackList = snapshot.docs
            .map((doc) => UnifiedFeedback.fromJson(doc.data()))
            .toList();
        return Right<Failure, List<UnifiedFeedback>>(feedbackList);
      }).handleError((error) {
        if (error is FirebaseException) {
          return Left<Failure, List<UnifiedFeedback>>(
            ServerFailure(
              'Firebase error: ${error.message}',
              code: error.code,
            ),
          );
        }
        return Left<Failure, List<UnifiedFeedback>>(
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

  // ========================================
  // STATISTICS & ANALYTICS
  // ========================================

  @override
  Future<Either<Failure, FeedbackStatistics>> getFeedbackStatistics() async {
    return handleFirebaseOperation(
      () async {
        // Fetch all feedback (consider pagination for large datasets in production)
        final snapshot = await _feedbackCollection.get();

        if (snapshot.docs.isEmpty) {
          return const FeedbackStatistics(
            totalCount: 0,
            countsByType: {},
            countsByStatus: {},
            countsBySeverity: {},
            avgResolutionTimeHours: 0.0,
            mostActiveReporters: [],
          );
        }

        // Initialize counters
        final countsByType = <UnifiedFeedbackType, int>{};
        final countsByStatus = <UnifiedFeedbackStatus, int>{};
        final countsBySeverity = <FeedbackSeverity, int>{};
        final userFeedbackCounts = <String, int>{};
        final resolutionTimes = <double>[];

        // Process each feedback
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final feedback = UnifiedFeedback.fromJson(data);

          // Count by type
          countsByType[feedback.type] = (countsByType[feedback.type] ?? 0) + 1;

          // Count by status
          countsByStatus[feedback.status] =
              (countsByStatus[feedback.status] ?? 0) + 1;

          // Count by severity
          countsBySeverity[feedback.severity] =
              (countsBySeverity[feedback.severity] ?? 0) + 1;

          // Count by user
          userFeedbackCounts[feedback.userId] =
              (userFeedbackCounts[feedback.userId] ?? 0) + 1;

          // Calculate resolution time if resolved
          if (feedback.resolvedAt != null) {
            final resolutionTime =
                feedback.resolvedAt!.difference(feedback.createdAt).inHours;
            resolutionTimes.add(resolutionTime.toDouble());
          }
        }

        // Calculate average resolution time
        final avgResolutionTimeHours = resolutionTimes.isEmpty
            ? 0.0
            : resolutionTimes.reduce((a, b) => a + b) / resolutionTimes.length;

        // Get top 10 most active reporters
        final sortedReporters = userFeedbackCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final mostActiveReporters = sortedReporters
            .take(10)
            .map((entry) => (entry.key, entry.value))
            .toList();

        return FeedbackStatistics(
          totalCount: snapshot.docs.length,
          countsByType: countsByType,
          countsByStatus: countsByStatus,
          countsBySeverity: countsBySeverity,
          avgResolutionTimeHours: avgResolutionTimeHours,
          mostActiveReporters: mostActiveReporters,
        );
      },
      operationName: 'getFeedbackStatistics',
    );
  }
}

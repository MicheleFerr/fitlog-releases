/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/feedback/domain/repositories
/// 🎯 Feature: unified_feedback
/// 🔧 Type: repository_interface
///
/// Unified Feedback Repository Interface
library;

import 'package:fpdart/fpdart.dart' hide State;
import 'package:gymbro_flutter_new/features/feedback/domain/entities/unified_feedback.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/enums/unified_feedback_type.dart';
import 'package:gymbro_flutter_new/shared/domain/failures/failure.dart';

/// Repository interface for unified feedback system
///
/// Implements Clean Architecture pattern with Either<Failure, T> return types
/// for robust error handling without exceptions.
///
/// **Responsibilities**:
/// - CRUD operations for unified feedback
/// - User feedback queries (by type, status, etc.)
/// - Admin feedback review operations
/// - Real-time streams for feedback monitoring
/// - Statistics aggregation for admin dashboard
abstract class IUnifiedFeedbackRepository {
  // ========================================
  // USER OPERATIONS
  // ========================================

  /// Submit new feedback
  ///
  /// Returns feedback ID on success
  ///
  /// **Errors**:
  /// - ValidationFailure: Invalid feedback data (empty message, invalid userId, etc.)
  /// - ServerFailure: Firestore write error
  /// - UnexpectedFailure: Unknown error
  Future<Either<Failure, String>> submitFeedback(
    UnifiedFeedback feedback,
  );

  /// Get all feedback submitted by specific user
  ///
  /// Ordered by createdAt (most recent first)
  ///
  /// **Errors**:
  /// - ServerFailure: Firestore read error
  /// - UnexpectedFailure: Unknown error
  Future<Either<Failure, List<UnifiedFeedback>>> getUserFeedback(
    String userId,
  );

  /// Get user feedback filtered by type
  ///
  /// Ordered by createdAt (most recent first)
  ///
  /// **Errors**:
  /// - ServerFailure: Firestore read error
  /// - UnexpectedFailure: Unknown error
  Future<Either<Failure, List<UnifiedFeedback>>> getUserFeedbackByType(
    String userId,
    UnifiedFeedbackType type,
  );

  // ========================================
  // ADMIN OPERATIONS - QUERIES
  // ========================================

  /// Get all feedback (admin only)
  ///
  /// Optional filters:
  /// - [limit]: Max results (default: no limit)
  /// - [type]: Filter by feedback type
  /// - [status]: Filter by status
  /// - [severity]: Filter by severity
  ///
  /// Ordered by createdAt (most recent first)
  ///
  /// **Errors**:
  /// - ServerFailure: Firestore read error
  /// - UnexpectedFailure: Unknown error
  Future<Either<Failure, List<UnifiedFeedback>>> getAllFeedback({
    int? limit,
    UnifiedFeedbackType? type,
    UnifiedFeedbackStatus? status,
    FeedbackSeverity? severity,
  });

  /// Get feedback by specific ID
  ///
  /// **Errors**:
  /// - ValidationFailure: Feedback not found
  /// - ServerFailure: Firestore read error
  /// - UnexpectedFailure: Unknown error
  Future<Either<Failure, UnifiedFeedback>> getFeedbackById(
    String feedbackId,
  );

  /// Get all pending feedback (open + reviewing status)
  ///
  /// Ordered by severity (critical first), then by createdAt (oldest first)
  ///
  /// **Errors**:
  /// - ServerFailure: Firestore read error
  /// - UnexpectedFailure: Unknown error
  Future<Either<Failure, List<UnifiedFeedback>>> getPendingFeedback();

  /// Get feedback by type (admin only)
  ///
  /// Ordered by createdAt (most recent first)
  ///
  /// **Errors**:
  /// - ServerFailure: Firestore read error
  /// - UnexpectedFailure: Unknown error
  Future<Either<Failure, List<UnifiedFeedback>>> getFeedbackByType(
    UnifiedFeedbackType type, {
    int? limit,
  });

  /// Get feedback by status (admin only)
  ///
  /// Ordered by createdAt (most recent first)
  ///
  /// **Errors**:
  /// - ServerFailure: Firestore read error
  /// - UnexpectedFailure: Unknown error
  Future<Either<Failure, List<UnifiedFeedback>>> getFeedbackByStatus(
    UnifiedFeedbackStatus status, {
    int? limit,
  });

  // ========================================
  // ADMIN OPERATIONS - ACTIONS
  // ========================================

  /// Update feedback status (admin only)
  ///
  /// Automatically sets:
  /// - updatedAt timestamp
  /// - resolvedAt timestamp (if status is resolved/dismissed/closed)
  ///
  /// **Errors**:
  /// - ValidationFailure: Feedback not found, invalid transition
  /// - ServerFailure: Firestore write error
  /// - UnexpectedFailure: Unknown error
  Future<Either<Failure, void>> updateFeedbackStatus({
    required String feedbackId,
    required UnifiedFeedbackStatus newStatus,
    required String adminUserId,
    String? adminNote,
  });

  /// Update feedback severity (admin only)
  ///
  /// **Errors**:
  /// - ValidationFailure: Feedback not found
  /// - ServerFailure: Firestore write error
  /// - UnexpectedFailure: Unknown error
  Future<Either<Failure, void>> updateFeedbackSeverity({
    required String feedbackId,
    required FeedbackSeverity newSeverity,
  });

  /// Add admin note to feedback (admin only)
  ///
  /// Appends note with timestamp to existing adminNotes
  ///
  /// **Errors**:
  /// - ValidationFailure: Feedback not found, empty note
  /// - ServerFailure: Firestore write error
  /// - UnexpectedFailure: Unknown error
  Future<Either<Failure, void>> addAdminNote({
    required String feedbackId,
    required String note,
    required String adminUserId,
  });

  /// Delete feedback (soft delete - sets status to closed)
  ///
  /// **Errors**:
  /// - ValidationFailure: Feedback not found
  /// - ServerFailure: Firestore write error
  /// - UnexpectedFailure: Unknown error
  Future<Either<Failure, void>> deleteFeedback(
    String feedbackId,
  );

  // ========================================
  // REAL-TIME STREAMS
  // ========================================

  /// Watch pending feedback count (admin dashboard)
  ///
  /// Emits count whenever pending feedback changes
  ///
  /// **Errors**: Wrapped in Left(Failure) in stream
  Stream<Either<Failure, int>> watchPendingFeedbackCount();

  /// Watch user feedback in real-time
  ///
  /// Emits list whenever user's feedback changes
  ///
  /// **Errors**: Wrapped in Left(Failure) in stream
  Stream<Either<Failure, List<UnifiedFeedback>>> watchUserFeedback(
    String userId,
  );

  /// Watch feedback by type in real-time (admin only)
  ///
  /// Emits list whenever feedback of this type changes
  ///
  /// **Errors**: Wrapped in Left(Failure) in stream
  Stream<Either<Failure, List<UnifiedFeedback>>> watchFeedbackByType(
    UnifiedFeedbackType type,
  );

  // ========================================
  // STATISTICS & ANALYTICS
  // ========================================

  /// Get aggregated feedback statistics (admin dashboard)
  ///
  /// Returns:
  /// - Total feedback count
  /// - Counts by type (exercise: 50, ai_insight: 30, etc.)
  /// - Counts by status (open: 10, reviewing: 5, resolved: 80, etc.)
  /// - Counts by severity (critical: 2, high: 8, medium: 40, low: 50)
  /// - Average resolution time (in hours)
  /// - Most active reporters (top 10 users by feedback count)
  ///
  /// **Errors**:
  /// - ServerFailure: Firestore read error
  /// - UnexpectedFailure: Unknown error
  Future<Either<Failure, FeedbackStatistics>> getFeedbackStatistics();
}

/// Feedback Statistics Model
///
/// Aggregated metrics for admin dashboard
class FeedbackStatistics {
  const FeedbackStatistics({
    required this.totalCount,
    required this.countsByType,
    required this.countsByStatus,
    required this.countsBySeverity,
    required this.avgResolutionTimeHours,
    required this.mostActiveReporters,
  });

  /// Total feedback count
  final int totalCount;

  /// Counts by feedback type
  ///
  /// Example: {'exercise': 50, 'ai_insight': 30, 'analytics': 20, ...}
  final Map<UnifiedFeedbackType, int> countsByType;

  /// Counts by status
  ///
  /// Example: {'open': 10, 'reviewing': 5, 'resolved': 80, ...}
  final Map<UnifiedFeedbackStatus, int> countsByStatus;

  /// Counts by severity
  ///
  /// Example: {'critical': 2, 'high': 8, 'medium': 40, 'low': 50}
  final Map<FeedbackSeverity, int> countsBySeverity;

  /// Average time to resolve feedback (in hours)
  ///
  /// Calculated from (resolvedAt - createdAt) for resolved/dismissed feedback
  final double avgResolutionTimeHours;

  /// Most active reporters (top 10)
  ///
  /// List of (userId, feedbackCount) tuples, sorted by count descending
  final List<(String userId, int count)> mostActiveReporters;

  /// Calculate percentage for type
  double getTypePercentage(UnifiedFeedbackType type) {
    if (totalCount == 0) return 0.0;
    final count = countsByType[type] ?? 0;
    return (count / totalCount) * 100;
  }

  /// Calculate percentage for status
  double getStatusPercentage(UnifiedFeedbackStatus status) {
    if (totalCount == 0) return 0.0;
    final count = countsByStatus[status] ?? 0;
    return (count / totalCount) * 100;
  }

  /// Calculate percentage for severity
  double getSeverityPercentage(FeedbackSeverity severity) {
    if (totalCount == 0) return 0.0;
    final count = countsBySeverity[severity] ?? 0;
    return (count / totalCount) * 100;
  }

  /// Get pending feedback count (open + reviewing)
  int get pendingCount {
    return (countsByStatus[UnifiedFeedbackStatus.open] ?? 0) +
        (countsByStatus[UnifiedFeedbackStatus.reviewing] ?? 0);
  }

  /// Get completed feedback count (resolved + dismissed + closed)
  int get completedCount {
    return (countsByStatus[UnifiedFeedbackStatus.resolved] ?? 0) +
        (countsByStatus[UnifiedFeedbackStatus.dismissed] ?? 0) +
        (countsByStatus[UnifiedFeedbackStatus.closed] ?? 0);
  }

  /// Get critical/high priority feedback count
  int get highPriorityCount {
    return (countsBySeverity[FeedbackSeverity.critical] ?? 0) +
        (countsBySeverity[FeedbackSeverity.high] ?? 0);
  }
}

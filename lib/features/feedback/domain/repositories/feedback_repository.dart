/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/feedback/domain/repositories
/// 🎯 Feature: user_feedback
/// 🔧 Type: repository_interface
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// FEEDBACK REPOSITORY INTERFACE - Contract for feedback operations
library;

import 'package:gymbro_flutter_new/features/feedback/domain/entities/user_feedback.dart';

/// Abstract repository interface for user feedback operations
abstract class FeedbackRepository {
  // === USER OPERATIONS ===

  /// Submit new feedback
  Future<void> submitFeedback(UserFeedback feedback);

  /// Get user's own feedback
  Future<List<UserFeedback>> getUserFeedback(String userId);

  // === ADMIN OPERATIONS ===

  /// Get all feedback (admin only)
  Future<List<UserFeedback>> getAllFeedback();

  /// Get feedback by status (admin only)
  Future<List<UserFeedback>> getFeedbackByStatus(FeedbackStatus status);

  /// Get feedback by category (admin only)
  Future<List<UserFeedback>> getFeedbackByCategory(FeedbackCategory category);

  /// Update feedback status (admin only)
  Future<void> updateFeedbackStatus({
    required String feedbackId,
    required FeedbackStatus status,
    required String adminUserId,
    String? notes,
  });

  /// Delete feedback (admin only)
  Future<void> deleteFeedback(String feedbackId);

  // === REAL-TIME STREAMS ===

  /// Stream all feedback (admin only)
  Stream<List<UserFeedback>> watchAllFeedback();

  /// Stream new/unreviewed feedback count (admin only)
  Stream<int> watchNewFeedbackCount();

  // === STATISTICS ===

  /// Get feedback statistics (admin only)
  Future<FeedbackStatistics> getFeedbackStatistics();
}

/// Feedback statistics for admin dashboard
class FeedbackStatistics {

  const FeedbackStatistics({
    required this.totalFeedback,
    required this.newFeedback,
    required this.reviewedFeedback,
    required this.resolvedFeedback,
    required this.dismissedFeedback,
    required this.averageRating,
    required this.categoryBreakdown,
    required this.statusBreakdown,
  });

  factory FeedbackStatistics.empty() {
    return const FeedbackStatistics(
      totalFeedback: 0,
      newFeedback: 0,
      reviewedFeedback: 0,
      resolvedFeedback: 0,
      dismissedFeedback: 0,
      averageRating: 0.0,
      categoryBreakdown: {},
      statusBreakdown: {},
    );
  }

  /// Calculate from list of feedback
  factory FeedbackStatistics.fromFeedbackList(List<UserFeedback> feedbackList) {
    final total = feedbackList.length;
    final newCount =
        feedbackList.where((f) => f.status == FeedbackStatus.newFeedback).length;
    final reviewedCount =
        feedbackList.where((f) => f.status == FeedbackStatus.reviewed).length;
    final resolvedCount =
        feedbackList.where((f) => f.status == FeedbackStatus.resolved).length;
    final dismissedCount =
        feedbackList.where((f) => f.status == FeedbackStatus.dismissed).length;

    // Calculate average rating (only from rated feedback)
    final ratedFeedback = feedbackList.where((f) => f.rating != null);
    final averageRating = ratedFeedback.isEmpty
        ? 0.0
        : ratedFeedback.map((f) => f.rating!).reduce((a, b) => a + b) /
            ratedFeedback.length;

    // Category breakdown
    final categoryBreakdown = <FeedbackCategory, int>{};
    for (final category in FeedbackCategory.values) {
      categoryBreakdown[category] =
          feedbackList.where((f) => f.category == category).length;
    }

    // Status breakdown
    final statusBreakdown = <FeedbackStatus, int>{};
    for (final status in FeedbackStatus.values) {
      statusBreakdown[status] =
          feedbackList.where((f) => f.status == status).length;
    }

    return FeedbackStatistics(
      totalFeedback: total,
      newFeedback: newCount,
      reviewedFeedback: reviewedCount,
      resolvedFeedback: resolvedCount,
      dismissedFeedback: dismissedCount,
      averageRating: averageRating,
      categoryBreakdown: categoryBreakdown,
      statusBreakdown: statusBreakdown,
    );
  }
  final int totalFeedback;
  final int newFeedback;
  final int reviewedFeedback;
  final int resolvedFeedback;
  final int dismissedFeedback;
  final double averageRating;
  final Map<FeedbackCategory, int> categoryBreakdown;
  final Map<FeedbackStatus, int> statusBreakdown;

  String get summary {
    return 'Total: $totalFeedback • New: $newFeedback • Avg Rating: ${averageRating.toStringAsFixed(1)}⭐';
  }
}

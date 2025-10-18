/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/feedback/domain/entities
/// 🎯 Feature: user_feedback
/// 🔧 Type: entity
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// USER FEEDBACK ENTITY - Feedback from users
///
/// Fields:
/// - id: Unique identifier
/// - userId: User who submitted feedback
/// - message: Feedback text
/// - rating: 1-5 stars (optional)
/// - category: Type of feedback
/// - status: New/Reviewed/Resolved
/// - createdAt: Submission timestamp
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_feedback.freezed.dart';
part 'user_feedback.g.dart';

/// Feedback category types
enum FeedbackCategory {
  bug,
  feature,
  improvement,
  praise,
  other,
}

/// Feedback status
enum FeedbackStatus {
  newFeedback, // Just submitted
  reviewed,    // Admin reviewed
  resolved,    // Issue resolved
  dismissed,   // Not actionable
}

/// User feedback entity
@freezed
class UserFeedback with _$UserFeedback {
  const factory UserFeedback({
    required String id,
    required String userId,
    required String message,
    required FeedbackCategory category,
    required FeedbackStatus status,
    required DateTime createdAt,
    int? rating, // 1-5 stars (optional)
    String? userEmail,
    String? userDisplayName,
    String? deviceInfo,
    String? appVersion,
    String? screenshotUrl, // Firebase Storage URL (future)
    DateTime? reviewedAt,
    String? reviewedBy, // Admin user ID
    String? adminNotes,
  }) = _UserFeedback;

  factory UserFeedback.fromJson(Map<String, dynamic> json) =>
      _$UserFeedbackFromJson(json);
}

/// Extension for creating new feedback
extension UserFeedbackFactory on UserFeedback {
  /// Create a new feedback entry
  static UserFeedback create({
    required String userId,
    required String message,
    required FeedbackCategory category,
    int? rating,
    String? userEmail,
    String? userDisplayName,
    String? deviceInfo,
    String? appVersion,
  }) {
    return UserFeedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      message: message,
      category: category,
      status: FeedbackStatus.newFeedback,
      createdAt: DateTime.now(),
      rating: rating,
      userEmail: userEmail,
      userDisplayName: userDisplayName,
      deviceInfo: deviceInfo,
      appVersion: appVersion,
    );
  }
}

/// Extension for status operations
extension UserFeedbackExtensions on UserFeedback {
  /// Mark as reviewed by admin
  UserFeedback markAsReviewed(String adminUserId) {
    return copyWith(
      status: FeedbackStatus.reviewed,
      reviewedAt: DateTime.now(),
      reviewedBy: adminUserId,
    );
  }

  /// Mark as resolved
  UserFeedback markAsResolved(String adminUserId, String notes) {
    return copyWith(
      status: FeedbackStatus.resolved,
      reviewedAt: DateTime.now(),
      reviewedBy: adminUserId,
      adminNotes: notes,
    );
  }

  /// Mark as dismissed
  UserFeedback dismiss(String adminUserId, String reason) {
    return copyWith(
      status: FeedbackStatus.dismissed,
      reviewedAt: DateTime.now(),
      reviewedBy: adminUserId,
      adminNotes: reason,
    );
  }

  /// Get category icon
  String get categoryIcon {
    switch (category) {
      case FeedbackCategory.bug:
        return '🐛';
      case FeedbackCategory.feature:
        return '✨';
      case FeedbackCategory.improvement:
        return '💡';
      case FeedbackCategory.praise:
        return '❤️';
      case FeedbackCategory.other:
        return '💬';
    }
  }

  /// Get category label
  String get categoryLabel {
    switch (category) {
      case FeedbackCategory.bug:
        return 'Bug Report';
      case FeedbackCategory.feature:
        return 'Feature Request';
      case FeedbackCategory.improvement:
        return 'Improvement';
      case FeedbackCategory.praise:
        return 'Praise';
      case FeedbackCategory.other:
        return 'Other';
    }
  }

  /// Get status icon
  String get statusIcon {
    switch (status) {
      case FeedbackStatus.newFeedback:
        return '🆕';
      case FeedbackStatus.reviewed:
        return '👁️';
      case FeedbackStatus.resolved:
        return '✅';
      case FeedbackStatus.dismissed:
        return '❌';
    }
  }

  /// Get status label
  String get statusLabel {
    switch (status) {
      case FeedbackStatus.newFeedback:
        return 'New';
      case FeedbackStatus.reviewed:
        return 'Reviewed';
      case FeedbackStatus.resolved:
        return 'Resolved';
      case FeedbackStatus.dismissed:
        return 'Dismissed';
    }
  }

  /// Check if feedback is actionable
  bool get isActionable {
    return status == FeedbackStatus.newFeedback ||
        status == FeedbackStatus.reviewed;
  }

  /// Get rating stars display
  String get ratingStars {
    if (rating == null) return 'No rating';
    return '⭐' * rating!;
  }
}

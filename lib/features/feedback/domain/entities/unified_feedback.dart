/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/feedback/domain/entities
/// 🎯 Feature: unified_feedback
/// 🔧 Type: entity
///
/// Unified Feedback Entity - Single entity for all feedback types
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/feedback/domain/enums/unified_feedback_type.dart';

part 'unified_feedback.freezed.dart';
part 'unified_feedback.g.dart';

/// Unified Feedback Entity
///
/// This entity consolidates all feedback types into a single schema:
/// - Exercise feedback (former `exercise_feedback` collection)
/// - AI insight feedback (former `ai_coach_feedback` collection)
/// - Analytics page feedback (former `analytics_page_feedback` collection)
/// - Buddy reports (former `buddy_reports` collection)
/// - General feedback (former `userFeedback` collection)
///
/// **Type Discriminator**: [type] field determines feedback type
/// **Type-Specific Data**: [metadata] Map contains type-specific fields
///
/// **Firestore Collection**: `feedback` (replaces 5 separate collections)
@freezed
abstract class UnifiedFeedback with _$UnifiedFeedback {
  const factory UnifiedFeedback({
    /// Unique feedback ID (Firestore document ID)
    required String id,

    /// User who submitted feedback (Firebase Auth UID)
    required String userId,

    /// Type of feedback (discriminator)
    required UnifiedFeedbackType type,

    /// Current status in review workflow
    required UnifiedFeedbackStatus status,

    /// Severity level (for prioritization)
    required FeedbackSeverity severity,

    /// Main feedback message/description
    required String message,

    /// When feedback was submitted
    required DateTime createdAt,

    /// Last update timestamp (status change, admin note, etc.)
    DateTime? updatedAt,

    /// When feedback was marked resolved/dismissed (if applicable)
    DateTime? resolvedAt,

    // ========================================
    // ADMIN REVIEW FIELDS
    // ========================================

    /// Admin user ID who reviewed this feedback
    String? reviewedBy,

    /// Admin notes/comments (visible to user if status is resolved)
    String? adminNotes,

    // ========================================
    // TYPE-SPECIFIC METADATA
    // ========================================

    /// Type-specific data stored as Map
    ///
    /// **Exercise Feedback**:
    /// - exerciseId: String
    /// - exerciseName: String
    /// - feedbackType: String (BUG/SUGGESTION/TYPO/OTHER)
    /// - fieldName: String? (optional - specific field like "nome", "noteTecniche")
    ///
    /// **AI Insight Feedback**:
    /// - insightId: String
    /// - insightType: String (e.g., "overtraining", "progression")
    /// - insightCategory: String (e.g., "recovery", "performance")
    /// - feedbackType: String (helpful/notHelpful/dismissed/actedUpon)
    /// - dismissReason: String? (alreadyKnow/notRelevant/incorrect/etc.)
    /// - viewDurationSeconds: int (time insight was visible before feedback)
    ///
    /// **Analytics Feedback**:
    /// - isHelpful: bool (true = 👍, false = 👎)
    /// - lastViewedSection: String? (overview/progress/insights/routine)
    /// - totalWorkoutsViewed: int? (user engagement metric)
    ///
    /// **Buddy Report**:
    /// - targetUserId: String (reported user ID)
    /// - targetUserName: String (reported user display name)
    /// - reportReason: String (HARASSMENT/SPAM/FAKE_PROFILE/INAPPROPRIATE_PHOTOS/etc.)
    ///
    /// **General Feedback**:
    /// - category: String (bug/feature/improvement/praise/other)
    /// - rating: int? (1-5 stars, optional)
    /// - deviceInfo: String? (e.g., "iPhone 15 Pro - iOS 17.2")
    /// - appVersion: String? (e.g., "1.2.3")
    /// - screenshotUrl: String? (Firebase Storage URL, future)
    @Default({}) Map<String, dynamic> metadata,

    // ========================================
    // USER INFO (OPTIONAL - FOR ADMIN)
    // ========================================

    /// User email (for admin contact)
    String? userEmail,

    /// User display name (for admin reference)
    String? userDisplayName,
  }) = _UnifiedFeedback;

  factory UnifiedFeedback.fromJson(Map<String, dynamic> json) =>
      _$UnifiedFeedbackFromJson(json);
}

/// Extension methods for UnifiedFeedback
extension UnifiedFeedbackX on UnifiedFeedback {
  /// Whether this feedback is actionable (open or reviewing)
  bool get isActionable => status.isActionable;

  /// Whether this feedback is completed (resolved/dismissed/closed)
  bool get isCompleted => status.isCompleted;

  /// Get type-specific display title
  String get typeDisplayTitle {
    switch (type) {
      case UnifiedFeedbackType.exercise:
        return metadata['exerciseName'] as String? ?? 'Exercise Feedback';
      case UnifiedFeedbackType.aiInsight:
        return 'AI Insight: ${metadata['insightType'] ?? 'Unknown'}';
      case UnifiedFeedbackType.analytics:
        final isHelpful = metadata['isHelpful'] as bool? ?? false;
        return isHelpful
            ? 'Analytics: Positive Feedback'
            : 'Analytics: Needs Improvement';
      case UnifiedFeedbackType.buddyReport:
        return 'Report: ${metadata['targetUserName'] ?? 'User'}';
      case UnifiedFeedbackType.general:
        final category = metadata['category'] as String? ?? 'other';
        return 'General: ${category.toUpperCase()}';
      case UnifiedFeedbackType.exercisePatch:
        return 'Exercise Patch: ${metadata['fieldName'] ?? 'Unknown'}';
    }
  }

  /// Get short summary for list views
  String get shortSummary {
    if (message.length <= 100) return message;
    return '${message.substring(0, 97)}...';
  }

  /// Whether feedback has admin review
  bool get hasAdminReview => reviewedBy != null;

  /// Days since submission
  int get daysSinceCreated {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Days since last update
  int? get daysSinceUpdated {
    if (updatedAt == null) return null;
    return DateTime.now().difference(updatedAt!).inDays;
  }

  /// Mark as reviewed by admin
  UnifiedFeedback markAsReviewed(String adminUserId) {
    return copyWith(
      status: UnifiedFeedbackStatus.reviewing,
      reviewedBy: adminUserId,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark as resolved by admin
  UnifiedFeedback markAsResolved(String adminUserId, {String? notes}) {
    return copyWith(
      status: UnifiedFeedbackStatus.resolved,
      reviewedBy: adminUserId,
      adminNotes: notes,
      resolvedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Mark as dismissed by admin
  UnifiedFeedback markAsDismissed(
    String adminUserId, {
    required String reason,
  }) {
    return copyWith(
      status: UnifiedFeedbackStatus.dismissed,
      reviewedBy: adminUserId,
      adminNotes: reason,
      resolvedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Update severity level
  UnifiedFeedback updateSeverity(FeedbackSeverity newSeverity) {
    return copyWith(severity: newSeverity, updatedAt: DateTime.now());
  }

  /// Add admin note (append to existing if present)
  UnifiedFeedback addAdminNote(String note) {
    final existingNotes = adminNotes ?? '';
    final newNotes = existingNotes.isEmpty
        ? note
        : '$existingNotes\n\n--- ${DateTime.now().toIso8601String()} ---\n$note';

    return copyWith(adminNotes: newNotes, updatedAt: DateTime.now());
  }
}

/// Factory methods for creating type-specific feedback
extension UnifiedFeedbackFactory on UnifiedFeedback {
  /// Create exercise feedback
  static UnifiedFeedback createExerciseFeedback({
    required String userId,
    required String exerciseId,
    required String exerciseName,
    required String feedbackType, // BUG/SUGGESTION/TYPO/OTHER
    required String message,
    required FeedbackSeverity severity,
    String? fieldName,
    String? userEmail,
    String? userDisplayName,
  }) {
    return UnifiedFeedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: UnifiedFeedbackType.exercise,
      status: UnifiedFeedbackStatus.open,
      severity: severity,
      message: message,
      createdAt: DateTime.now(),
      metadata: {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'feedbackType': feedbackType,
        if (fieldName != null) 'fieldName': fieldName,
      },
      userEmail: userEmail,
      userDisplayName: userDisplayName,
    );
  }

  /// Create AI insight feedback
  static UnifiedFeedback createAIInsightFeedback({
    required String userId,
    required String insightId,
    required String insightType,
    required String insightCategory,
    required String feedbackType, // helpful/notHelpful/dismissed/actedUpon
    String? dismissReason,
    String? comment,
    int viewDurationSeconds = 0,
  }) {
    return UnifiedFeedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: UnifiedFeedbackType.aiInsight,
      status: UnifiedFeedbackStatus.open,
      severity: FeedbackSeverity.low, // AI feedback typically low priority
      message: comment ?? 'User feedback on AI insight',
      createdAt: DateTime.now(),
      metadata: {
        'insightId': insightId,
        'insightType': insightType,
        'insightCategory': insightCategory,
        'feedbackType': feedbackType,
        if (dismissReason != null) 'dismissReason': dismissReason,
        'viewDurationSeconds': viewDurationSeconds,
      },
    );
  }

  /// Create analytics feedback
  static UnifiedFeedback createAnalyticsFeedback({
    required String userId,
    required bool isHelpful,
    String? comment,
    String? lastViewedSection,
    int? totalWorkoutsViewed,
  }) {
    return UnifiedFeedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: UnifiedFeedbackType.analytics,
      status: UnifiedFeedbackStatus.open,
      severity: FeedbackSeverity.medium,
      message:
          comment ?? (isHelpful ? 'Positive feedback' : 'Needs improvement'),
      createdAt: DateTime.now(),
      metadata: {
        'isHelpful': isHelpful,
        if (lastViewedSection != null) 'lastViewedSection': lastViewedSection,
        if (totalWorkoutsViewed != null)
          'totalWorkoutsViewed': totalWorkoutsViewed,
      },
    );
  }

  /// Create buddy report
  static UnifiedFeedback createBuddyReport({
    required String reporterId,
    required String targetUserId,
    required String targetUserName,
    required String reportReason, // HARASSMENT/SPAM/FAKE_PROFILE/etc.
    required String description,
  }) {
    return UnifiedFeedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: reporterId,
      type: UnifiedFeedbackType.buddyReport,
      status: UnifiedFeedbackStatus.open,
      severity: FeedbackSeverity.high, // User reports are high priority
      message: description,
      createdAt: DateTime.now(),
      metadata: {
        'targetUserId': targetUserId,
        'targetUserName': targetUserName,
        'reportReason': reportReason,
      },
    );
  }

  /// Create general feedback
  static UnifiedFeedback createGeneralFeedback({
    required String userId,
    required String message,
    required String category, // bug/feature/improvement/praise/other
    FeedbackSeverity? severity,
    int? rating,
    String? userEmail,
    String? userDisplayName,
    String? deviceInfo,
    String? appVersion,
  }) {
    return UnifiedFeedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: UnifiedFeedbackType.general,
      status: UnifiedFeedbackStatus.open,
      severity: severity ?? _severityFromCategory(category),
      message: message,
      createdAt: DateTime.now(),
      metadata: {
        'category': category,
        if (rating != null) 'rating': rating,
        if (deviceInfo != null) 'deviceInfo': deviceInfo,
        if (appVersion != null) 'appVersion': appVersion,
      },
      userEmail: userEmail,
      userDisplayName: userDisplayName,
    );
  }

  /// Helper: Map category to default severity
  static FeedbackSeverity _severityFromCategory(String category) {
    switch (category.toLowerCase()) {
      case 'bug':
        return FeedbackSeverity.high;
      case 'feature':
        return FeedbackSeverity.medium;
      case 'improvement':
        return FeedbackSeverity.medium;
      case 'praise':
        return FeedbackSeverity.low;
      default:
        return FeedbackSeverity.medium;
    }
  }
}

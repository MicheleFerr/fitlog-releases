/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/entities
/// 🎯 Feature: ai_coach
/// 🔧 Type: entity
///
/// Feedback Data Entity - Tracks user feedback on AI insights
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_data.freezed.dart';
part 'feedback_data.g.dart';

/// Feedback type for AI insights
///
/// User can provide feedback on insight quality to improve recommendations
enum FeedbackType {
  /// User found insight helpful
  helpful,

  /// User dismissed insight as not helpful
  notHelpful,

  /// User dismissed insight (neutral)
  dismissed,

  /// User acted on insight (implicit positive feedback)
  actedUpon,
}

/// Reason for dismissing insight
///
/// Helps understand why user didn't find insight useful
enum DismissReason {
  /// Already addressed this issue
  alreadyKnow,

  /// Not relevant to current goals
  notRelevant,

  /// Insight is incorrect or inaccurate
  incorrect,

  /// Too advanced for current level
  tooAdvanced,

  /// Too basic for current level
  tooBasic,

  /// Don't want to see this type of insight
  notInterested,

  /// Other reason (not specified)
  other,
}

/// Feedback Data
///
/// Tracks user feedback on specific AI insight to improve recommendations
///
/// Used by feedback repository to:
/// - Calculate insight effectiveness by type/category
/// - Identify low-performing insights to suppress
/// - Personalize insights based on user preferences
/// - Track engagement metrics
@freezed
class FeedbackData with _$FeedbackData {
  const factory FeedbackData({
    /// Unique feedback ID
    required String id,

    /// User ID who provided feedback
    required String userId,

    /// Insight ID that received feedback
    required String insightId,

    /// Type of insight that received feedback
    required String insightType,

    /// Category of insight that received feedback
    required String insightCategory,

    /// Type of feedback provided
    required FeedbackType feedbackType,

    /// Reason for dismissing (if feedbackType is notHelpful/dismissed)
    DismissReason? dismissReason,

    /// Optional text comment from user
    String? comment,

    /// When feedback was provided
    required DateTime timestamp,

    /// How long insight was shown before feedback (in seconds)
    @Default(0) int viewDurationSeconds,
  }) = _FeedbackData;

  factory FeedbackData.fromJson(Map<String, dynamic> json) =>
      _$FeedbackDataFromJson(json);
}

/// Extension methods for FeedbackData
extension FeedbackDataX on FeedbackData {
  /// Whether feedback is positive
  bool get isPositive =>
      feedbackType == FeedbackType.helpful ||
      feedbackType == FeedbackType.actedUpon;

  /// Whether feedback is negative
  bool get isNegative => feedbackType == FeedbackType.notHelpful;

  /// Whether insight was engaged with
  bool get wasEngaged =>
      feedbackType == FeedbackType.helpful ||
      feedbackType == FeedbackType.notHelpful ||
      feedbackType == FeedbackType.actedUpon;

  /// Whether user provided detailed feedback
  bool get hasDetailedFeedback => dismissReason != null || comment != null;
}

/// Feedback Statistics
///
/// Aggregated feedback metrics for specific insight type or category
@freezed
class FeedbackStats with _$FeedbackStats {
  const factory FeedbackStats({
    /// Insight type or category
    required String identifier,

    /// Total feedback received
    @Default(0) int totalFeedback,

    /// Helpful feedback count
    @Default(0) int helpfulCount,

    /// Not helpful feedback count
    @Default(0) int notHelpfulCount,

    /// Dismissed feedback count
    @Default(0) int dismissedCount,

    /// Acted upon feedback count
    @Default(0) int actedUponCount,

    /// Average view duration in seconds
    @Default(0.0) double avgViewDuration,

    /// When stats were last updated
    DateTime? lastUpdated,
  }) = _FeedbackStats;

  factory FeedbackStats.fromJson(Map<String, dynamic> json) =>
      _$FeedbackStatsFromJson(json);
}

/// Extension methods for FeedbackStats
extension FeedbackStatsX on FeedbackStats {
  /// Calculate effectiveness rate (0.0 - 1.0)
  ///
  /// Considers helpful + acted upon as positive
  /// Formula: (helpful + actedUpon) / (helpful + notHelpful + actedUpon)
  double get effectivenessRate {
    final positiveCount = helpfulCount + actedUponCount;
    final negativeCount = notHelpfulCount;
    final totalEngaged = positiveCount + negativeCount;

    if (totalEngaged == 0) return 0.0;
    return positiveCount / totalEngaged;
  }

  /// Calculate engagement rate (0.0 - 1.0)
  ///
  /// Percentage of insights that received active feedback (not just dismissed)
  /// Formula: (helpful + notHelpful + actedUpon) / totalFeedback
  double get engagementRate {
    if (totalFeedback == 0) return 0.0;

    final engagedCount = helpfulCount + notHelpfulCount + actedUponCount;
    return engagedCount / totalFeedback;
  }

  /// Whether insight type is performing well
  ///
  /// Threshold: >60% effectiveness rate with >5 feedback samples
  bool get isPerformingWell =>
      totalFeedback >= 5 && effectivenessRate > 0.6;

  /// Whether insight type is performing poorly
  ///
  /// Threshold: <30% effectiveness rate with >10 feedback samples
  bool get isPerformingPoorly =>
      totalFeedback >= 10 && effectivenessRate < 0.3;

  /// Whether there's enough data to make decisions
  bool get hasEnoughData => totalFeedback >= 5;
}

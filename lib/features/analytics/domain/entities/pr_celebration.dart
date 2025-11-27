import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/pr_type.dart';

part 'pr_celebration.freezed.dart';
part 'pr_celebration.g.dart';

/// Celebration engagement tracking for PR notifications
enum CelebrationEngagement {
  /// User viewed the celebration modal/notification
  viewed,

  /// User shared the PR celebration
  shared,

  /// User dismissed the celebration
  dismissed,
}

/// PR Celebration entity representing a personal record celebration event
///
/// Tracks when a user achieves a personal record and how they engage
/// with the celebration (view, share, dismiss) for analytics and retention.
@freezed
abstract class PRCelebration with _$PRCelebration {
  const factory PRCelebration({
    /// Unique celebration identifier
    required String id,

    /// User who achieved the PR
    required String userId,

    /// Personal record identifier
    required String prId,

    /// Type of personal record achieved
    required PRType prType,

    /// When the celebration was triggered
    required DateTime celebratedAt,

    /// How the user engaged with the celebration
    required CelebrationEngagement engagement,

    /// Previous personal record value
    required double previousValue,

    /// New personal record value
    required double newValue,

    /// Exercise name (optional for context)
    String? exerciseName,

    /// Whether a push notification was sent
    @Default(false) bool notificationSent,

    /// When the notification was sent (if applicable)
    DateTime? notificationSentAt,
  }) = _PRCelebration;

  factory PRCelebration.fromJson(Map<String, dynamic> json) =>
      _$PRCelebrationFromJson(json);
}

/// Extension to calculate PR improvement percentage
extension PRCelebrationExtensions on PRCelebration {
  /// Calculate percentage improvement from previous PR
  double get improvementPercentage {
    if (previousValue == 0) return 0;
    return ((newValue - previousValue) / previousValue) * 100;
  }

  /// Check if this is a significant PR (>10% improvement)
  bool get isSignificantPR => improvementPercentage >= 10;
}

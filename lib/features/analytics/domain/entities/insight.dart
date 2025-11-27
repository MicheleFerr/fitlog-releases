import 'package:freezed_annotation/freezed_annotation.dart';

part 'insight.freezed.dart';
part 'insight.g.dart';

/// Insight engagement tracking for analytics
enum InsightEngagement {
  /// User viewed the insight
  viewed,

  /// User dismissed the insight without taking action
  dismissed,

  /// User took the recommended action
  actionTaken,
}

/// Priority levels for insights
enum InsightPriority {
  high,    // Must address immediately
  medium,  // Should address soon
  low,     // Nice to know
}

/// Types of insights
enum InsightType {
  achievement,  // Positive milestone reached
  warning,      // Potential issue detected
  suggestion,   // Improvement opportunity
  improvement,  // Performance improvement detected
  info,         // General information
  motivation,   // Motivational message
}

/// Insight entity with engagement tracking
///
/// Represents an actionable insight shown to the user with tracking
/// for visibility and engagement metrics to measure effectiveness.
@freezed
abstract class Insight with _$Insight {
  const factory Insight({
    /// Unique insight identifier
    required String id,

    /// User this insight belongs to
    required String userId,

    /// Type of insight
    required InsightType type,

    /// Priority level
    required InsightPriority priority,

    /// Insight title (localized)
    required String title,

    /// Insight message/description (localized)
    required String message,

    /// Recommended action (localized)
    required String recommendation,

    /// When the insight was generated
    required DateTime generatedAt,

    /// Additional metadata (exercise names, metrics, etc.)
    @Default({}) Map<String, dynamic> metadata,

    /// User's engagement with this insight (if any)
    InsightEngagement? engagement,

    /// Specific action the user took (e.g., "started_workout", "adjusted_volume")
    String? actionTaken,

    /// When the user dismissed the insight
    DateTime? dismissedAt,

    /// When the user first viewed the insight
    DateTime? viewedAt,

    /// When action was taken (if applicable)
    DateTime? actionTakenAt,
  }) = _Insight;

  factory Insight.fromJson(Map<String, dynamic> json) =>
      _$InsightFromJson(json);
}

/// Extension methods for Insight
extension InsightExtensions on Insight {
  /// Check if the insight has been viewed
  bool get isViewed => viewedAt != null;

  /// Check if the insight has been dismissed
  bool get isDismissed => dismissedAt != null;

  /// Check if action was taken
  bool get hasActionTaken => actionTakenAt != null;

  /// Check if insight is still pending (not viewed, dismissed, or acted upon)
  bool get isPending => !isViewed && !isDismissed && !hasActionTaken;

  /// Calculate time since generation (for freshness)
  Duration get age => DateTime.now().difference(generatedAt);

  /// Check if insight is stale (>7 days old)
  bool get isStale => age.inDays > 7;
}

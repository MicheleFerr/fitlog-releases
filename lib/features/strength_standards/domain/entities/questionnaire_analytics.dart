/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain/entities
/// 🎯 Feature: strength_standards
/// 🔧 Type: entity
/// 🌍 Localization: N/A - Entity class
/// 🎨 Theme: N/A - Entity class
/// 📱 Platform: Universal
///
/// Tracks user behavior during fitness questionnaire completion
/// for analytics and UX optimization.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'questionnaire_analytics.freezed.dart';
part 'questionnaire_analytics.g.dart';

/// Analytics data for questionnaire completion tracking
@freezed
class QuestionnaireAnalytics with _$QuestionnaireAnalytics {
  const factory QuestionnaireAnalytics({
    /// User ID for aggregation
    required String userId,

    /// Timestamp when questionnaire was started
    required DateTime startedAt,

    /// Timestamp when completed (null if abandoned)
    DateTime? completedAt,

    /// Last step user reached before abandoning/completing
    @Default(0) int lastStepReached,

    /// Total steps in questionnaire (usually 7: 0-6)
    @Default(7) int totalSteps,

    /// Time spent on each step (step index → seconds)
    @Default({}) Map<int, int> stepDurations,

    /// Whether user abandoned (true) or completed (false)
    bool? wasAbandoned,

    /// Feedback ratings for each step (1-5 scale, null if not rated)
    @Default({}) Map<int, int?> stepFeedback,

    /// Total time from start to completion/abandon (seconds)
    int? totalDurationSeconds,

    /// Device/platform info for analytics
    String? platform,

    /// App version
    String? appVersion,
  }) = _QuestionnaireAnalytics;

  factory QuestionnaireAnalytics.fromJson(Map<String, dynamic> json) =>
      _$QuestionnaireAnalyticsFromJson(json);
}

/// Extension for calculated metrics
extension QuestionnaireAnalyticsExtension on QuestionnaireAnalytics {
  /// Completion rate (0.0 to 1.0)
  double get completionRate {
    if (completedAt != null) return 1.0;
    return lastStepReached / totalSteps;
  }

  /// Average time per step (seconds)
  double get averageStepDuration {
    if (stepDurations.isEmpty) return 0.0;
    final total = stepDurations.values.reduce((a, b) => a + b);
    return total / stepDurations.length;
  }

  /// Step where user dropped off (null if completed)
  int? get dropOffStep {
    if (completedAt != null) return null;
    return lastStepReached;
  }

  /// Whether questionnaire was completed
  bool get isCompleted => completedAt != null;

  /// Total duration in minutes
  double get totalDurationMinutes {
    if (totalDurationSeconds == null) return 0.0;
    return totalDurationSeconds! / 60.0;
  }

  /// Average feedback rating (1-5, null if no feedback)
  double? get averageFeedbackRating {
    final ratings = stepFeedback.values.whereType<int>().toList();
    if (ratings.isEmpty) return null;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  /// Whether user provided any feedback
  bool get hasFeedback => stepFeedback.values.any((rating) => rating != null);
}

/// Aggregated analytics for all users (admin view)
class QuestionnaireAnalyticsAggregated {
  const QuestionnaireAnalyticsAggregated({
    required this.totalAttempts,
    required this.totalCompletions,
    required this.averageCompletionTime,
    required this.dropOffByStep,
    required this.averageFeedbackByStep,
  });

  final int totalAttempts;
  final int totalCompletions;
  final Duration averageCompletionTime;
  final Map<int, int> dropOffByStep; // step → abandon count
  final Map<int, double> averageFeedbackByStep; // step → avg rating

  double get completionRate => totalCompletions / totalAttempts;

  int get mostProblematicStep {
    if (dropOffByStep.isEmpty) return 0;
    return dropOffByStep.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

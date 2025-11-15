/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/domain/services
/// 🎯 Feature: ai_coach
/// 🔧 Type: service
///
/// Insight Rule Engine - applies dynamic rules and prioritization
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_insight.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/insight_rule.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';

/// Rule engine for applying dynamic rules to insights
///
/// Responsibilities:
/// - Apply personalized thresholds based on experience level
/// - Re-prioritize insights based on user context
/// - Filter insights by severity and relevance
/// - Enforce business rules (e.g., max insights per type)
class InsightRuleEngine {
  InsightRuleEngine(this._rules);

  final List<InsightRule> _rules;

  /// Apply rules and return filtered, prioritized insights
  ///
  /// Process:
  /// 1. Filter by severity (remove low-priority if critical exists)
  /// 2. Apply personalized thresholds from rules
  /// 3. Re-prioritize based on user context
  /// 4. Limit to top N insights (default: 5)
  ///
  /// [rawInsights] - Unfiltered insights from analyzers
  /// [context] - User context for personalization
  /// [maxInsights] - Maximum insights to return (default: 5)
  List<AIInsight> applyRules(
    List<AIInsight> rawInsights,
    UserContext context, {
    int maxInsights = 5,
  }) {
    if (rawInsights.isEmpty) return [];

    // Step 1: Filter by severity (prioritize critical)
    final filteredInsights = _filterBySeverity(rawInsights);

    // Step 2: Re-prioritize based on user context
    final reprioritizedInsights = _reprioritizeByContext(
      filteredInsights,
      context,
    );

    // Step 3: Sort by final priority (lower number = higher priority)
    reprioritizedInsights.sort((a, b) => a.priority.compareTo(b.priority));

    // Step 4: Limit to top N insights
    return reprioritizedInsights.take(maxInsights).toList();
  }

  /// Filter insights by severity
  ///
  /// Logic:
  /// - If any CRITICAL insights exist, remove all LOW severity insights
  /// - If no CRITICAL but HIGH exists, keep HIGH + MEDIUM
  List<AIInsight> _filterBySeverity(List<AIInsight> insights) {
    final hasCritical = insights.any((i) => i.severity == InsightSeverity.critical);

    if (hasCritical) {
      // Remove LOW severity when CRITICAL exists
      return insights
          .where((i) => i.severity != InsightSeverity.low)
          .toList();
    }

    final hasHigh = insights.any((i) => i.severity == InsightSeverity.high);

    if (hasHigh) {
      // Remove LOW severity when HIGH exists
      return insights
          .where((i) => i.severity != InsightSeverity.low)
          .toList();
    }

    // Keep all insights if only MEDIUM/LOW severity
    return insights;
  }

  /// Re-prioritize insights based on user context
  ///
  /// Adjustments:
  /// - Beginners: Boost recovery and mobility warnings
  /// - Advanced: Boost CNS fatigue and periodization suggestions
  /// - User goal alignment: Boost insights matching primary goal
  List<AIInsight> _reprioritizeByContext(
    List<AIInsight> insights,
    UserContext context,
  ) {
    return insights.map((insight) {
      var adjustedPriority = insight.priority;

      // Experience-based adjustments
      switch (context.experienceLevel) {
        case ExperienceLevel.beginner:
          // Beginners: Prioritize recovery and form warnings
          if (insight.type == InsightType.recoveryPattern ||
              insight.type == InsightType.formWarning ||
              insight.type == InsightType.mobility) {
            adjustedPriority = (adjustedPriority - 1).clamp(1, 10);
          }
          break;

        case ExperienceLevel.intermediate:
          // Intermediate: Balanced prioritization
          if (insight.type == InsightType.progressOverload ||
              insight.type == InsightType.volumeOptimization) {
            adjustedPriority = (adjustedPriority - 1).clamp(1, 10);
          }
          break;

        case ExperienceLevel.advanced:
          // Advanced: Prioritize CNS fatigue and periodization
          if (insight.type == InsightType.cnsFatigue ||
              insight.type == InsightType.periodization) {
            adjustedPriority = (adjustedPriority - 1).clamp(1, 10);
          }
          break;
      }

      // Goal-based adjustments
      switch (context.primaryGoal) {
        case TrainingGoal.hypertrophy:
          // Hypertrophy goal: Prioritize volume and recovery
          if (insight.type == InsightType.volumeOptimization ||
              insight.type == InsightType.recoveryPattern ||
              insight.type == InsightType.muscleGroupBalance) {
            adjustedPriority = (adjustedPriority - 1).clamp(1, 10);
          }
          break;

        case TrainingGoal.strength:
          // Strength goal: Prioritize progressive overload and CNS
          if (insight.type == InsightType.progressOverload ||
              insight.type == InsightType.cnsFatigue ||
              insight.type == InsightType.periodization) {
            adjustedPriority = (adjustedPriority - 1).clamp(1, 10);
          }
          break;

        case TrainingGoal.endurance:
          // Endurance goal: Prioritize recovery and frequency
          if (insight.type == InsightType.recoveryPattern ||
              insight.type == InsightType.frequencyRecommendation ||
              insight.type == InsightType.mobility) {
            adjustedPriority = (adjustedPriority - 1).clamp(1, 10);
          }
          break;
      }

      // Return new insight with adjusted priority
      return AIInsight(
        id: insight.id,
        type: insight.type,
        severity: insight.severity,
        title: insight.title,
        description: insight.description,
        recommendation: insight.recommendation,
        priority: adjustedPriority,
        affectedExercise: insight.affectedExercise,
        affectedTemplates: insight.affectedTemplates,
        scientificStrategies: insight.scientificStrategies,
        dataPoints: insight.dataPoints,
        timestamp: insight.timestamp,
      );
    }).toList();
  }

  /// Get personalized threshold for an insight type
  ///
  /// Returns null if no rule exists for this insight type
  PersonalizedThreshold? getThreshold(
    InsightType type,
    ExperienceLevel level,
  ) {
    final rule = _rules.firstWhere(
      (r) => r.insightType == type,
      orElse: () => throw StateError('No rule found for type: $type'),
    );

    return rule.personalizedThresholds[level];
  }

  /// Check if user has minimum weeks of data for an insight type
  bool hasMinimumData(InsightType type, int weeksSinceStart) {
    final rule = _rules.firstWhere(
      (r) => r.insightType == type,
      orElse: () => throw StateError('No rule found for type: $type'),
    );

    return weeksSinceStart >= rule.minWeeks;
  }

  /// Get all rules
  List<InsightRule> get rules => List.unmodifiable(_rules);

  /// Add a new rule (for testing/dynamic configuration)
  void addRule(InsightRule rule) {
    _rules.add(rule);
  }

  /// Remove a rule by insight type
  void removeRule(InsightType type) {
    _rules.removeWhere((r) => r.insightType == type);
  }

  /// Clear all rules
  void clearRules() {
    _rules.clear();
  }
}

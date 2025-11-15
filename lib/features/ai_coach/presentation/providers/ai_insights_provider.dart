/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/providers
/// 🎯 Feature: ai_coach
/// 🔧 Type: provider
///
/// AI Insights Riverpod Provider - state management for insights
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_insight.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/analyzer_registry.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/services/insight_rule_engine.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/analyzers/volume_balance_analyzer.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/analyzers/progressive_overload_analyzer.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/analyzers/recovery_pattern_analyzer.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/analyzers/cns_fatigue_analyzer.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/analyzers/periodization_analyzer.dart';
import 'package:gymbro_flutter_new/features/ai_coach/data/analyzers/mobility_analyzer.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';

/// Analyzer Registry provider (singleton)
final analyzerRegistryProvider = Provider<AnalyzerRegistry>((ref) {
  final registry = AnalyzerRegistry();

  // Register all analyzers
  // Note: Exercise database would come from a provider in real implementation
  final exerciseDatabase = <String, Exercise>{};

  registry.registerAnalyzer(VolumeBalanceAnalyzer(exerciseDatabase));
  registry.registerAnalyzer(ProgressiveOverloadAnalyzer());
  registry.registerAnalyzer(RecoveryPatternAnalyzer());
  registry.registerAnalyzer(CNSFatigueAnalyzer());
  registry.registerAnalyzer(PeriodizationAnalyzer());
  registry.registerAnalyzer(MobilityAnalyzer());

  return registry;
});

/// Insight Rule Engine provider
final insightRuleEngineProvider = Provider<InsightRuleEngine>((ref) {
  // In real implementation, rules would be loaded from Firestore/JSON
  return InsightRuleEngine([]);
});

/// AI Insights provider - generates insights from workouts
///
/// Usage:
/// ```dart
/// final insights = ref.watch(aiInsightsProvider);
/// insights.when(
///   data: (insights) => InsightsList(insights: insights),
///   loading: () => LoadingIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
final aiInsightsProvider = FutureProvider.autoDispose<List<AIInsight>>((ref) async {
  // Dependencies
  final registry = ref.watch(analyzerRegistryProvider);
  final ruleEngine = ref.watch(insightRuleEngineProvider);

  // User context (would come from user profile provider in real implementation)
  const userContext = UserContext(
    userId: 'test-user',
    experienceLevel: ExperienceLevel.intermediate,
    primaryGoal: TrainingGoal.hypertrophy,
    weeklyAvailability: 4,
  );

  // Workouts (would come from workout provider in real implementation)
  const workouts = <Workout>[];

  // Generate insights from all enabled analyzers
  final rawInsights = <AIInsight>[];

  final enabledAnalyzers = registry.getAllEnabledAnalyzers(userContext);

  for (final analyzer in enabledAnalyzers) {
    final insight = await analyzer.analyze(workouts, userContext);
    if (insight != null) {
      rawInsights.add(insight);
    }
  }

  // Apply rules and prioritization
  final filteredInsights = ruleEngine.applyRules(
    rawInsights,
    userContext,
    maxInsights: 5,
  );

  return filteredInsights;
});

/// Insights by type provider
///
/// Returns insights grouped by type for categorized display
final insightsByTypeProvider = Provider.autoDispose<Map<InsightType, List<AIInsight>>>((ref) {
  final insights = ref.watch(aiInsightsProvider);

  return insights.when(
    data: (insights) {
      final grouped = <InsightType, List<AIInsight>>{};
      for (final insight in insights) {
        grouped.putIfAbsent(insight.type, () => []).add(insight);
      }
      return grouped;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Insights by severity provider
///
/// Returns insights grouped by severity for priority display
final insightsBySeverityProvider = Provider.autoDispose<Map<InsightSeverity, List<AIInsight>>>((ref) {
  final insights = ref.watch(aiInsightsProvider);

  return insights.when(
    data: (insights) {
      final grouped = <InsightSeverity, List<AIInsight>>{};
      for (final insight in insights) {
        grouped.putIfAbsent(insight.severity, () => []).add(insight);
      }
      return grouped;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Critical insights count provider
///
/// Returns count of critical insights for badge display
final criticalInsightsCountProvider = Provider.autoDispose<int>((ref) {
  final insights = ref.watch(aiInsightsProvider);

  return insights.when(
    data: (insights) => insights
        .where((i) => i.severity == InsightSeverity.critical)
        .length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

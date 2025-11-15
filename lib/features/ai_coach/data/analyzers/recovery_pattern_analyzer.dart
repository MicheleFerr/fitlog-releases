/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/analyzers
/// 🎯 Feature: ai_coach
/// 🔧 Type: analyzer
///
/// Recovery Pattern Analyzer - detects insufficient/excessive recovery
/// Extracted from legacy ai_coach_service.dart _analyzeRecoveryPatterns
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_insight.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/insight_analyzer.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Analyzes recovery patterns between workouts
///
/// Based on scientific evidence:
/// - Dattilo et al. (2011): Sleep and muscle recovery
/// - McMaster et al. (2013): Strength retention and decay rates
///
/// Detection criteria:
/// - Insufficient recovery: < 1 day between workouts (overtraining risk)
/// - Excessive recovery: > 4 days without training (detraining risk)
/// - Optimal: 1-4 days between workouts (MPS window)
class RecoveryPatternAnalyzer implements InsightAnalyzer {
  @override
  InsightType get type => InsightType.recoveryPattern;

  @override
  int get basePriority => 2; // Important - recovery is critical

  @override
  bool shouldAnalyze(UserContext context) {
    // Available for all tiers (free feature)
    return true;
  }

  @override
  Future<AIInsight?> analyze(
    List<Workout> workouts,
    UserContext context,
  ) async {
    // Need at least 2 workouts to analyze recovery patterns
    if (workouts.length < 2) return null;

    // Sort workouts by date (most recent first)
    final sortedWorkouts = List<Workout>.from(workouts)
      ..sort((a, b) {
        final aDate = a.endTime ?? a.createdAt;
        final bDate = b.endTime ?? b.createdAt;
        return bDate.compareTo(aDate);
      });

    final lastWorkout = sortedWorkouts.first;
    final lastWorkoutDate = lastWorkout.endTime ?? lastWorkout.createdAt;

    final hoursSinceLastWorkout = DateTime.now().difference(lastWorkoutDate).inHours;
    final daysSinceLastWorkout = hoursSinceLastWorkout / 24.0;

    // Insufficient recovery: < 24 hours between workouts
    if (daysSinceLastWorkout < 1.0) {
      return _createInsufficientRecoveryInsight(daysSinceLastWorkout);
    }

    // Excessive recovery: > 4 days without training
    if (daysSinceLastWorkout > 4.0) {
      return _createExcessiveRecoveryInsight(daysSinceLastWorkout);
    }

    // Recovery is optimal (1-4 days) - no insight needed
    return null;
  }

  /// Create insight for insufficient recovery
  AIInsight _createInsufficientRecoveryInsight(double daysSinceLastWorkout) {
    return AIInsight(
      id: 'recovery_insufficient_${DateTime.now().millisecondsSinceEpoch}',
      type: InsightType.recoveryPattern,
      severity: InsightSeverity.medium,
      title: 'Insufficient Recovery',
      description: 'You worked out ${daysSinceLastWorkout.toStringAsFixed(1)} days ago. Training again within 24 hours may compromise recovery and muscle growth.',
      recommendation: 'Allow at least 24-48 hours between intense sessions targeting the same muscle groups. Consider active recovery (light cardio, stretching).',
      priority: basePriority,
      affectedExercise: null,
      affectedTemplates: null,
      scientificStrategies: [
        'Optimize sleep: 7-9 hours per night for muscle protein synthesis (Dattilo et al. 2011)',
        'Periodize training: Alternate between high/low intensity days to allow recovery',
        'Active recovery: Light cardio or mobility work on rest days to enhance circulation',
        'Nutrition timing: Consume protein within 2h post-workout for optimal recovery',
      ],
      dataPoints: {
        'daysSinceLastWorkout': daysSinceLastWorkout.toStringAsFixed(1),
        'minimumRecovery': '24 hours',
        'optimalRange': '24-72 hours',
        'currentStatus': 'Insufficient recovery',
        'mpsWindow': 'Muscle Protein Synthesis peaks 24-72h post-workout',
      },
      timestamp: DateTime.now(),
    );
  }

  /// Create insight for excessive recovery
  AIInsight _createExcessiveRecoveryInsight(double daysSinceLastWorkout) {
    return AIInsight(
      id: 'recovery_excessive_${DateTime.now().millisecondsSinceEpoch}',
      type: InsightType.recoveryPattern,
      severity: InsightSeverity.medium,
      title: 'Long Recovery Period',
      description: 'It has been ${daysSinceLastWorkout.toStringAsFixed(1)} days since your last workout. Extended breaks may lead to detraining effects.',
      recommendation: 'Resume training soon to maintain muscle mass and strength. If returning from a break, start with reduced volume (60-70% of previous).',
      priority: 3,
      affectedExercise: null,
      affectedTemplates: null,
      scientificStrategies: [
        'Schedule consistency: Set recurring workout times to build habit (Gardner et al. 2012)',
        'Minimum dose: Even 1-2 sessions per week maintains adaptations (Bickel et al. 2011)',
        'Progressive return: Reduce volume by 30-40% when returning after >1 week break',
        'Detraining prevention: Strength declines 7-12% after 2-3 weeks inactivity',
      ],
      dataPoints: {
        'daysSinceLastWorkout': daysSinceLastWorkout.toStringAsFixed(1),
        'maxRecommended': '4 days',
        'proteinSynthesisPeak': 'MPS peaks 24-72h, returns to baseline after 96h',
        'detrainingRisk': 'Moderate (muscle strength declines after 7-10 days)',
        'optimalFrequency': '3-5 days per week for hypertrophy',
      },
      timestamp: DateTime.now(),
    );
  }
}

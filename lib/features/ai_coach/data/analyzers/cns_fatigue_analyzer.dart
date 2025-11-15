/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/analyzers
/// 🎯 Feature: ai_coach
/// 🔧 Type: analyzer
///
/// CNS Fatigue Analyzer - detects Central Nervous System stress
/// NEW analyzer addressing blind spot in original AI Coach design
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_insight.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/insight_analyzer.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Analyzes CNS fatigue from heavy compound lifts
///
/// Based on scientific evidence:
/// - Fry & Kraemer (1997): Resistance exercise overtraining and CNS stress
/// - González-Badillo et al. (2011): Velocity loss as CNS fatigue marker
/// - Zatsiorsky & Kraemer (2006): Science and Practice of Strength Training
///
/// Detection criteria:
/// - Compound lifts: Squat, Deadlift, Bench Press, Overhead Press, Clean, Snatch
/// - Heavy sets: ≥85% estimated 1RM (typically 1-6 reps with near-max weight)
/// - CNS fatigue threshold: >12 heavy compound sets per week
/// - Critical threshold: >18 heavy compound sets per week
class CNSFatigueAnalyzer implements InsightAnalyzer {
  @override
  InsightType get type => InsightType.cnsFatigue;

  @override
  int get basePriority => 1; // Critical - injury risk & performance decline

  @override
  bool shouldAnalyze(UserContext context) {
    // Premium feature (addresses advanced blind spot)
    // For now, available to all for testing phase
    return true;
  }

  @override
  Future<AIInsight?> analyze(
    List<Workout> workouts,
    UserContext context,
  ) async {
    // Require 1+ weeks of data
    if (workouts.isEmpty) return null;

    // Filter last 7 days
    final weeklyWorkouts = workouts.where(
      (w) => w.createdAt.isAfter(
        DateTime.now().subtract(const Duration(days: 7)),
      ),
    ).toList();

    if (weeklyWorkouts.isEmpty) return null;

    // Count heavy compound sets
    int heavyCompoundSets = 0;
    final compoundExercises = <String>[];

    for (final workout in weeklyWorkouts) {
      for (final exercise in workout.exercises) {
        if (_isCompoundLift(exercise.name)) {
          final heavySets = _countHeavySets(exercise.sets);
          if (heavySets > 0) {
            heavyCompoundSets += heavySets;
            if (!compoundExercises.contains(exercise.name)) {
              compoundExercises.add(exercise.name);
            }
          }
        }
      }
    }

    // Thresholds based on experience level
    final thresholds = _getThresholds(context.experienceLevel);

    // Critical CNS fatigue (>18 heavy sets)
    if (heavyCompoundSets >= thresholds.critical) {
      return _createCriticalCNSInsight(
        heavyCompoundSets,
        compoundExercises,
        thresholds,
      );
    }

    // Moderate CNS stress (>12 heavy sets)
    if (heavyCompoundSets >= thresholds.warning) {
      return _createModerateCNSInsight(
        heavyCompoundSets,
        compoundExercises,
        thresholds,
      );
    }

    return null; // CNS fatigue within safe range
  }

  /// Check if exercise is a compound lift
  bool _isCompoundLift(String exerciseName) {
    final name = exerciseName.toLowerCase();

    // Heavy compound lifts that tax CNS heavily
    return name.contains('squat') ||
        name.contains('deadlift') ||
        name.contains('bench press') && !name.contains('db') ||
        name.contains('overhead press') ||
        name.contains('military press') ||
        name.contains('clean') && !name.contains('machine') ||
        name.contains('snatch') ||
        name.contains('jerk') ||
        name.contains('front press') ||
        name.contains('push press');
  }

  /// Count heavy sets (≥85% 1RM estimated from low reps)
  int _countHeavySets(List<dynamic> sets) {
    int count = 0;
    for (final set in sets) {
      if (set.isCompleted) {
        final reps = _parseReps(set.reps);
        // Heavy set heuristic: ≤6 reps with good weight (approximates ≥85% 1RM)
        if (reps > 0 && reps <= 6) {
          count++;
        }
      }
    }
    return count;
  }

  /// Get CNS fatigue thresholds by experience level
  CNSThresholds _getThresholds(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        // Beginners: Lower tolerance to CNS stress
        return const CNSThresholds(warning: 10, critical: 15);
      case ExperienceLevel.intermediate:
        // Intermediate: Moderate tolerance
        return const CNSThresholds(warning: 12, critical: 18);
      case ExperienceLevel.advanced:
        // Advanced: Higher tolerance from neural adaptations
        return const CNSThresholds(warning: 15, critical: 22);
    }
  }

  /// Create critical CNS fatigue insight
  AIInsight _createCriticalCNSInsight(
    int heavyCompoundSets,
    List<String> compoundExercises,
    CNSThresholds thresholds,
  ) {
    return AIInsight(
      id: 'cns_fatigue_critical_${DateTime.now().millisecondsSinceEpoch}',
      type: InsightType.cnsFatigue,
      severity: InsightSeverity.critical,
      title: 'Critical: CNS Fatigue Detected',
      description: 'You performed $heavyCompoundSets heavy compound sets this week (${heavyCompoundSets - thresholds.critical} sets over critical threshold). High risk of CNS fatigue and performance decline.',
      recommendation: 'IMMEDIATE ACTION: Deload week required. Reduce all training volume by 50% for 5-7 days. Prioritize sleep (8-9h/night) and nutrition.',
      priority: basePriority,
      affectedExercise: null,
      affectedTemplates: null,
      scientificStrategies: [
        'Deload immediately: Reduce volume by 50%, maintain intensity at 60-70% (Fry & Kraemer 1997)',
        'Sleep priority: 8-9 hours per night essential for CNS recovery',
        'Reduce frequency: Limit heavy compound lifts to 2x per week maximum',
        'Wave periodization: Alternate heavy (3-5 reps) and light (8-12 reps) weeks',
        'Monitor velocity: Use velocity-based training to detect CNS fatigue early (González-Badillo 2011)',
      ],
      dataPoints: {
        'heavyCompoundSets': heavyCompoundSets,
        'criticalThreshold': thresholds.critical,
        'warningThreshold': thresholds.warning,
        'excess': heavyCompoundSets - thresholds.critical,
        'compoundExercises': compoundExercises.take(5).join(', '),
        'risk': 'CRITICAL - Immediate intervention required',
      },
      timestamp: DateTime.now(),
    );
  }

  /// Create moderate CNS stress insight
  AIInsight _createModerateCNSInsight(
    int heavyCompoundSets,
    List<String> compoundExercises,
    CNSThresholds thresholds,
  ) {
    return AIInsight(
      id: 'cns_fatigue_moderate_${DateTime.now().millisecondsSinceEpoch}',
      type: InsightType.cnsFatigue,
      severity: InsightSeverity.high,
      title: 'High CNS Stress',
      description: 'You performed $heavyCompoundSets heavy compound sets this week (${heavyCompoundSets - thresholds.warning} sets above optimal). Moderate risk of CNS fatigue.',
      recommendation: 'Reduce heavy compound volume next week by 20-30%. Consider replacing 1-2 heavy sessions with lighter, higher-rep work (8-12 reps).',
      priority: 2,
      affectedExercise: null,
      affectedTemplates: null,
      scientificStrategies: [
        'Volume reduction: Decrease heavy compound sets to ${thresholds.warning} per week',
        'Rep range variation: Alternate weeks between 3-5 reps and 8-12 reps',
        'Light days: Include 1-2 technique-focused days at 60-70% intensity',
        'Recovery modalities: Prioritize sleep, nutrition, and active recovery',
        'Deload planning: Schedule deload week every 4-6 weeks proactively',
      ],
      dataPoints: {
        'heavyCompoundSets': heavyCompoundSets,
        'warningThreshold': thresholds.warning,
        'criticalThreshold': thresholds.critical,
        'excess': heavyCompoundSets - thresholds.warning,
        'compoundExercises': compoundExercises.take(5).join(', '),
        'risk': 'MODERATE - Reduce volume soon',
      },
      timestamp: DateTime.now(),
    );
  }

  /// Parse reps safely
  double _parseReps(dynamic reps) {
    if (reps == null) return 0.0;
    if (reps is double) return reps;
    if (reps is int) return reps.toDouble();
    if (reps is String) return double.tryParse(reps) ?? 0.0;
    return 0.0;
  }
}

/// CNS fatigue thresholds
class CNSThresholds {
  const CNSThresholds({
    required this.warning,
    required this.critical,
  });

  final int warning; // Moderate CNS stress threshold
  final int critical; // Critical CNS fatigue threshold
}

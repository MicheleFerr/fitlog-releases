/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/analyzers
/// 🎯 Feature: ai_coach
/// 🔧 Type: analyzer
///
/// Periodization Analyzer - suggests training phase transitions
/// NEW analyzer addressing blind spot in original AI Coach design
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_insight.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/insight_analyzer.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Analyzes training phase duration and suggests periodization transitions
///
/// Based on scientific evidence:
/// - Rhea et al. (2003): Periodization models comparison
/// - Williams et al. (2017): Periodization strategies for athletes
/// - Bompa & Haff (2009): Periodization: Theory and Methodology
///
/// Detection criteria:
/// - Hypertrophy phase: 8-12 reps, high volume (detect if >4 weeks)
/// - Strength phase: 1-6 reps, low volume (detect if >4 weeks)
/// - Endurance phase: 15+ reps (detect if >4 weeks)
/// - Suggests transition after 4-6 weeks in same phase
class PeriodizationAnalyzer implements InsightAnalyzer {
  @override
  InsightType get type => InsightType.periodization;

  @override
  int get basePriority => 5; // Informational - optimization

  @override
  bool shouldAnalyze(UserContext context) {
    // Premium feature (advanced training concept)
    // For now, available to all for testing phase
    return true;
  }

  @override
  Future<AIInsight?> analyze(
    List<Workout> workouts,
    UserContext context,
  ) async {
    // Require at least 4 weeks of data (28 days)
    if (workouts.length < 8) return null;

    // Analyze last 4-6 weeks of training
    final recentWorkouts = workouts.where(
      (w) => w.createdAt.isAfter(
        DateTime.now().subtract(const Duration(days: 42)), // 6 weeks
      ),
    ).toList();

    if (recentWorkouts.length < 8) return null;

    // Detect current training phase
    final phaseData = _detectTrainingPhase(recentWorkouts);

    // If phase duration ≥4 weeks, suggest transition
    if (phaseData.weeksDuration >= 4.0) {
      return _createPeriodizationInsight(phaseData, context.primaryGoal);
    }

    return null; // Phase duration optimal
  }

  /// Detect current training phase from rep ranges
  TrainingPhaseData _detectTrainingPhase(List<Workout> workouts) {
    int strengthSets = 0; // 1-6 reps
    int hypertrophySets = 0; // 8-12 reps
    int enduranceSets = 0; // 15+ reps

    DateTime? earliestWorkout;
    DateTime? latestWorkout;

    for (final workout in workouts) {
      final workoutDate = workout.createdAt;
      earliestWorkout ??= workoutDate;
      latestWorkout ??= workoutDate;

      if (workoutDate.isBefore(earliestWorkout)) {
        earliestWorkout = workoutDate;
      }
      if (workoutDate.isAfter(latestWorkout)) {
        latestWorkout = workoutDate;
      }

      for (final exercise in workout.exercises) {
        for (final set in exercise.sets) {
          if (set.isCompleted) {
            final reps = _parseReps(set.reps);
            if (reps >= 1 && reps <= 6) {
              strengthSets++;
            } else if (reps >= 8 && reps <= 12) {
              hypertrophySets++;
            } else if (reps >= 15) {
              enduranceSets++;
            }
          }
        }
      }
    }

    // Determine dominant phase
    final totalSets = strengthSets + hypertrophySets + enduranceSets;
    if (totalSets == 0) {
      return const TrainingPhaseData(
        phase: TrainingPhase.hypertrophy,
        weeksDuration: 0,
        setsInPhase: 0,
      );
    }

    final strengthPercent = strengthSets / totalSets;
    final hypertrophyPercent = hypertrophySets / totalSets;
    final endurancePercent = enduranceSets / totalSets;

    TrainingPhase dominantPhase;
    int dominantSets;

    if (strengthPercent > hypertrophyPercent && strengthPercent > endurancePercent) {
      dominantPhase = TrainingPhase.strength;
      dominantSets = strengthSets;
    } else if (endurancePercent > hypertrophyPercent && endurancePercent > strengthPercent) {
      dominantPhase = TrainingPhase.endurance;
      dominantSets = enduranceSets;
    } else {
      dominantPhase = TrainingPhase.hypertrophy;
      dominantSets = hypertrophySets;
    }

    // Calculate duration in weeks
    final duration = latestWorkout!.difference(earliestWorkout!);
    final weeksDuration = duration.inDays / 7.0;

    return TrainingPhaseData(
      phase: dominantPhase,
      weeksDuration: weeksDuration,
      setsInPhase: dominantSets,
    );
  }

  /// Create periodization transition insight
  AIInsight _createPeriodizationInsight(
    TrainingPhaseData phaseData,
    TrainingGoal primaryGoal,
  ) {
    final currentPhase = phaseData.phase;
    final nextPhase = _suggestNextPhase(currentPhase, primaryGoal);

    return AIInsight(
      id: 'periodization_transition_${DateTime.now().millisecondsSinceEpoch}',
      type: InsightType.periodization,
      severity: InsightSeverity.low,
      title: 'Periodization: Consider Phase Transition',
      description: 'You have been training in ${_phaseToString(currentPhase)} phase for ${phaseData.weeksDuration.toStringAsFixed(1)} weeks. Research suggests transitioning phases every 4-6 weeks optimizes adaptations.',
      recommendation: 'Consider transitioning to ${_phaseToString(nextPhase)} phase. This provides novel stimulus and prevents adaptation plateaus.',
      priority: basePriority,
      affectedExercise: null,
      affectedTemplates: null,
      scientificStrategies: [
        'Linear periodization: Progress from high volume (hypertrophy) → low volume/high intensity (strength) (Rhea et al. 2003)',
        'Undulating periodization: Vary rep ranges weekly (8-12 → 5-8 → 12-15) for continuous adaptation',
        'Block periodization: Focus 3-4 weeks per quality (accumulation → intensification → realization)',
        'Deload integration: Include 1 deload week (50% volume) between phase transitions',
        'Phase-specific goals: Hypertrophy (muscle size) → Strength (neural efficiency) → Power (rate of force)',
      ],
      dataPoints: {
        'currentPhase': _phaseToString(currentPhase),
        'nextPhase': _phaseToString(nextPhase),
        'weeksDuration': phaseData.weeksDuration.toStringAsFixed(1),
        'optimalDuration': '4-6 weeks per phase',
        'setsInPhase': phaseData.setsInPhase,
        'transitionTiming': 'Now (optimal window for phase change)',
      },
      timestamp: DateTime.now(),
    );
  }

  /// Suggest next phase based on current phase and goals
  TrainingPhase _suggestNextPhase(
    TrainingPhase currentPhase,
    TrainingGoal primaryGoal,
  ) {
    // Follow linear periodization progression aligned with goals
    switch (primaryGoal) {
      case TrainingGoal.hypertrophy:
        // Hypertrophy goal: Hypertrophy → Strength → Hypertrophy cycle
        return currentPhase == TrainingPhase.hypertrophy
            ? TrainingPhase.strength
            : TrainingPhase.hypertrophy;

      case TrainingGoal.strength:
        // Strength goal: Strength → Hypertrophy (muscle building for strength base)
        return currentPhase == TrainingPhase.strength
            ? TrainingPhase.hypertrophy
            : TrainingPhase.strength;

      case TrainingGoal.endurance:
        // Endurance goal: Endurance → Strength (neural adaptations) → Endurance
        return currentPhase == TrainingPhase.endurance
            ? TrainingPhase.strength
            : TrainingPhase.endurance;
    }
  }

  /// Convert phase enum to readable string
  String _phaseToString(TrainingPhase phase) {
    switch (phase) {
      case TrainingPhase.strength:
        return 'Strength (1-6 reps, high intensity)';
      case TrainingPhase.hypertrophy:
        return 'Hypertrophy (8-12 reps, high volume)';
      case TrainingPhase.endurance:
        return 'Endurance (15+ reps, metabolic stress)';
    }
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

/// Training phase enum
enum TrainingPhase {
  strength,
  hypertrophy,
  endurance,
}

/// Training phase data
class TrainingPhaseData {
  const TrainingPhaseData({
    required this.phase,
    required this.weeksDuration,
    required this.setsInPhase,
  });

  final TrainingPhase phase;
  final double weeksDuration;
  final int setsInPhase;
}

/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/data/analyzers
/// 🎯 Feature: ai_coach
/// 🔧 Type: analyzer
///
/// Progressive Overload Analyzer - detects training plateaus
/// Extracted from legacy ai_coach_service.dart _analyzeProgressiveOverload
library;

import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/ai_insight.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/user_context.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/repositories/insight_analyzer.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Analyzes progressive overload patterns to detect plateaus
///
/// Based on scientific evidence:
/// - Schoenfeld et al. (2017): Mechanisms of Hypertrophy
/// - Progressive overload is essential for muscle growth
///
/// Detection criteria:
/// - Requires 3+ sessions of same exercise
/// - Plateau if weight variation < 5% of average weight
/// - Adaptive threshold: 5% for heavy weights, 10% for light weights
class ProgressiveOverloadAnalyzer implements InsightAnalyzer {
  @override
  InsightType get type => InsightType.progressOverload;

  @override
  int get basePriority => 3; // Medium priority - plateau detection

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
    // Require at least 6 workouts for trend analysis
    if (workouts.length < 6) return null;

    // Group exercises by name from all workouts
    final exerciseGroups = <String, List<ExerciseData>>{};

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        exerciseGroups.putIfAbsent(exercise.name, () => []).add(
          ExerciseData(
            name: exercise.name,
            date: workout.createdAt,
            maxWeight: _getMaxWeight(exercise.sets),
            totalVolume: _calculateTotalVolume(exercise.sets),
          ),
        );
      }
    }

    // Analyze each exercise group for plateaus
    for (final entry in exerciseGroups.entries) {
      final exerciseName = entry.key;
      final exerciseData = entry.value
        ..sort((a, b) => a.date.compareTo(b.date));

      // Need at least 3 sessions for plateau detection
      if (exerciseData.length >= 3) {
        final recent = exerciseData.length >= 3
            ? exerciseData.sublist(exerciseData.length - 3)
            : exerciseData;

        final weights = recent.map((e) => e.maxWeight).toList();

        if (weights.isNotEmpty && weights.first > 0) {
          final minWeight = weights.reduce((a, b) => a < b ? a : b);
          final maxWeight = weights.reduce((a, b) => a > b ? a : b);
          final avgWeight = weights.reduce((a, b) => a + b) / weights.length;
          final weightRange = maxWeight - minWeight;

          // Adaptive threshold based on weight magnitude
          final isLowWeight = avgWeight < 20;
          final plateauThreshold = isLowWeight ? 0.10 : 0.05; // 10% for light, 5% for heavy

          // Plateau if variation is less than threshold
          final variationPercent = weightRange / avgWeight;
          final isStagnant = variationPercent < plateauThreshold;

          if (isStagnant) {
            return _createPlateauInsight(
              exerciseName,
              weights,
              avgWeight,
              weightRange,
              variationPercent,
            );
          }
        }
      }
    }

    return null; // No plateaus detected
  }

  /// Create plateau insight
  AIInsight _createPlateauInsight(
    String exerciseName,
    List<double> recentWeights,
    double avgWeight,
    double weightRange,
    double variationPercent,
  ) {
    return AIInsight(
      id: 'progressive_overload_plateau_${exerciseName}_${DateTime.now().millisecondsSinceEpoch}',
      type: InsightType.progressOverload,
      severity: InsightSeverity.medium,
      title: 'Plateau Alert',
      description: 'Your $exerciseName weight has plateaued (${(variationPercent * 100).toStringAsFixed(1)}% variation over last 3 sessions). Time to break through!',
      recommendation: 'Try increasing volume (+1-2 sets), varying rep ranges (5-8 for strength, 12-15 for hypertrophy), or using advanced techniques (drop sets, rest-pause).',
      priority: basePriority,
      affectedExercise: exerciseName,
      affectedTemplates: null,
      scientificStrategies: [
        'Increase volume: Add 1-2 sets per week until weight increases (Schoenfeld et al. 2017)',
        'Vary rep ranges: Alternate between strength (5-8 reps) and hypertrophy (12-15 reps) phases',
        'Advanced techniques: Use drop sets, rest-pause, or tempo variations for new stimulus (Fink et al. 2018)',
        'Change exercise: Switch to similar movement with different angle or equipment (Fonseca et al. 2014)',
        'Deload week: Reduce volume by 40-50% for one week to supercompensate (Pritchard et al. 2015)',
      ],
      dataPoints: {
        'exercise': exerciseName,
        'currentWeight': avgWeight.toStringAsFixed(1),
        'weightRange': weightRange.toStringAsFixed(1),
        'variationPercent': (variationPercent * 100).toStringAsFixed(1),
        'session1': recentWeights[0].toStringAsFixed(1),
        'session2': recentWeights[1].toStringAsFixed(1),
        'session3': recentWeights[2].toStringAsFixed(1),
        'averageWeight': avgWeight.toStringAsFixed(1),
      },
      timestamp: DateTime.now(),
    );
  }

  /// Get maximum weight from sets
  double _getMaxWeight(List<dynamic> sets) {
    double maxWeight = 0;
    for (final set in sets) {
      if (set.isCompleted) {
        final weight = _parseWeight(set.weight);
        if (weight > maxWeight) {
          maxWeight = weight;
        }
      }
    }
    return maxWeight;
  }

  /// Calculate total volume (weight × reps)
  double _calculateTotalVolume(List<dynamic> sets) {
    double volume = 0;
    for (final set in sets) {
      if (set.isCompleted) {
        final weight = _parseWeight(set.weight);
        final reps = _parseReps(set.reps);
        volume += weight * reps;
      }
    }
    return volume;
  }

  /// Parse weight safely
  double _parseWeight(dynamic weight) {
    if (weight == null) return 0.0;
    if (weight is double) return weight;
    if (weight is int) return weight.toDouble();
    if (weight is String) return double.tryParse(weight) ?? 0.0;
    return 0.0;
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

/// Exercise data for trend analysis
class ExerciseData {
  const ExerciseData({
    required this.name,
    required this.date,
    required this.maxWeight,
    required this.totalVolume,
  });

  final String name;
  final DateTime date;
  final double maxWeight;
  final double totalVolume;
}

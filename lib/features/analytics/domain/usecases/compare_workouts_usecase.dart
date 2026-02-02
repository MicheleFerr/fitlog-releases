/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: domain
/// 🎯 Feature: analytics
/// 🔧 Type: usecase
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
///
/// Dependencies:
/// - workout/domain/entities: Workout
/// - analytics/domain/entities: WorkoutMetrics, WorkoutComparison
library;

import 'dart:math';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';

/// Use case for comparing workouts and finding similar training sessions
class CompareWorkoutsUseCase {
  /// Compare current workout with historical workouts
  WorkoutComparison? execute(
    Workout currentWorkout,
    List<Workout> historicalWorkouts,
  ) {
    if (historicalWorkouts.isEmpty) return null;

    final bestMatch = _findBestMatch(currentWorkout, historicalWorkouts);
    if (bestMatch == null) return null;

    return _createComparison(currentWorkout, bestMatch);
  }

  /// Find most similar historical workouts
  List<WorkoutSimilarity> findSimilarWorkouts(
    Workout targetWorkout,
    List<Workout> workouts, {
    int limit = 5,
    double minSimilarity = 0.3,
  }) {
    final similarities = <WorkoutSimilarity>[];

    for (final workout in workouts) {
      if (workout.id == targetWorkout.id) continue;

      final similarity = _calculateWorkoutSimilarity(targetWorkout, workout);
      if (similarity >= minSimilarity) {
        similarities.add(
          WorkoutSimilarity(
            workout: workout,
            similarity: similarity,
            comparison: _createComparison(targetWorkout, workout),
          ),
        );
      }
    }

    // Sort by similarity and limit results
    similarities.sort((a, b) => b.similarity.compareTo(a.similarity));
    return similarities.take(limit).toList();
  }

  /// Compare two specific workouts in detail
  DetailedWorkoutComparison compareDetailed(
    Workout workout1,
    Workout workout2,
  ) {
    final metrics1 = WorkoutMetrics.fromWorkout(workout1);
    final metrics2 = WorkoutMetrics.fromWorkout(workout2);

    return DetailedWorkoutComparison(
      workout1: workout1,
      workout2: workout2,
      metrics1: metrics1,
      metrics2: metrics2,
      volumeComparison: _compareVolume(metrics1, metrics2),
      intensityComparison: _compareIntensity(metrics1, metrics2),
      durationComparison: _compareDuration(metrics1, metrics2),
      exerciseComparison: _compareExercises(workout1, workout2),
      overallScore: _calculateOverallScore(metrics1, metrics2),
    );
  }

  /// Get workout improvement trends over time
  List<WorkoutTrend> getWorkoutTrends(
    List<Workout> workouts, {
    int periodDays = 30,
  }) {
    if (workouts.length < 2) return [];

    // Sort workouts by date
    final sortedWorkouts = [...workouts];
    sortedWorkouts.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));

    final trends = <WorkoutTrend>[];
    final now = DateTime.now();

    // Calculate trends for different periods
    for (int i = 1; i < sortedWorkouts.length; i++) {
      final current = sortedWorkouts[i];
      final previous = sortedWorkouts[i - 1];

      // Only include workouts within the period
      if (now.difference(current.updatedAt).inDays > periodDays) continue;

      final comparison = _createComparison(current, previous);
      trends.add(
        WorkoutTrend(
          date: current.updatedAt,
          workout: current,
          comparison: comparison,
          trendDirection: _getTrendDirection(comparison.improvementScore),
        ),
      );
    }

    return trends;
  }

  // Private helper methods

  Workout? _findBestMatch(Workout targetWorkout, List<Workout> candidates) {
    Workout? bestMatch;
    double highestSimilarity = 0;

    for (final candidate in candidates) {
      if (candidate.id == targetWorkout.id) continue;

      final similarity = _calculateWorkoutSimilarity(targetWorkout, candidate);
      if (similarity > highestSimilarity) {
        highestSimilarity = similarity;
        bestMatch = candidate;
      }
    }

    return highestSimilarity > 0.3 ? bestMatch : null;
  }

  double _calculateWorkoutSimilarity(Workout workout1, Workout workout2) {
    // Calculate similarity based on multiple factors

    // 1. Exercise overlap (50% weight)
    final exerciseSimilarity = _calculateExerciseSimilarity(workout1, workout2);

    // 2. Muscle group overlap (30% weight)
    final muscleGroupSimilarity = _calculateMuscleGroupSimilarity(
      workout1,
      workout2,
    );

    // 3. Volume similarity (20% weight)
    final volumeSimilarity = _calculateVolumeSimilarity(workout1, workout2);

    return (exerciseSimilarity * 0.5) +
        (muscleGroupSimilarity * 0.3) +
        (volumeSimilarity * 0.2);
  }

  double _calculateExerciseSimilarity(Workout workout1, Workout workout2) {
    final exercises1 = workout1.exercises
        .map((e) => e.name.toLowerCase())
        .toSet();
    final exercises2 = workout2.exercises
        .map((e) => e.name.toLowerCase())
        .toSet();

    final intersection = exercises1.intersection(exercises2);
    final union = exercises1.union(exercises2);

    return union.isEmpty ? 0 : intersection.length / union.length;
  }

  double _calculateMuscleGroupSimilarity(Workout workout1, Workout workout2) {
    final groups1 = workout1.exercises.map((e) => e.category).toSet();
    final groups2 = workout2.exercises.map((e) => e.category).toSet();

    final intersection = groups1.intersection(groups2);
    final union = groups1.union(groups2);

    return union.isEmpty ? 0 : intersection.length / union.length;
  }

  double _calculateVolumeSimilarity(Workout workout1, Workout workout2) {
    final metrics1 = WorkoutMetrics.fromWorkout(workout1);
    final metrics2 = WorkoutMetrics.fromWorkout(workout2);

    if (metrics1.totalVolume == 0 && metrics2.totalVolume == 0) return 1.0;
    if (metrics1.totalVolume == 0 || metrics2.totalVolume == 0) return 0.0;

    final ratio =
        min(metrics1.totalVolume, metrics2.totalVolume) /
        max(metrics1.totalVolume, metrics2.totalVolume);

    return ratio;
  }

  WorkoutComparison _createComparison(Workout current, Workout previous) {
    final currentMetrics = WorkoutMetrics.fromWorkout(current);
    final previousMetrics = WorkoutMetrics.fromWorkout(previous);

    // Calculate changes
    final volumeChange =
        currentMetrics.totalVolume - previousMetrics.totalVolume;
    final volumeChangePercentage = previousMetrics.totalVolume > 0
        ? (volumeChange / previousMetrics.totalVolume) * 100
        : 0;

    final intensityChange =
        currentMetrics.averageRPE - previousMetrics.averageRPE;
    final intensityChangePercentage = previousMetrics.averageRPE > 0
        ? (intensityChange / previousMetrics.averageRPE) * 100
        : 0;

    final durationChange =
        currentMetrics.totalDuration - previousMetrics.totalDuration;
    final densityChange =
        currentMetrics.trainingDensity - previousMetrics.trainingDensity;

    // Calculate overall improvement score
    final improvementScore = _calculateImprovementScore(
      volumeChangePercentage.toDouble(),
      intensityChangePercentage.toDouble(),
      durationChange.inMinutes.toDouble(),
      densityChange,
    );

    return WorkoutComparison(
      comparisonId: previous.id,
      comparisonDate: previous.updatedAt,
      comparisonName: previous.name,
      volumeChange: volumeChange,
      volumeChangePercentage: volumeChangePercentage.toDouble(),
      intensityChange: intensityChange,
      intensityChangePercentage: intensityChangePercentage.toDouble(),
      durationChange: durationChange,
      densityChange: densityChange,
      improvementScore: improvementScore,
    );
  }

  double _calculateImprovementScore(
    double volumeChange,
    double intensityChange,
    double durationChange,
    double densityChange,
  ) {
    double score = 0;

    // Volume improvement (40% weight)
    score += (volumeChange * 0.4);

    // Intensity improvement (30% weight)
    score += (intensityChange * 0.3);

    // Density improvement (20% weight)
    score += (densityChange > 0 ? densityChange * 5 : densityChange * 2) * 0.2;

    // Duration efficiency (10% weight) - shorter is better if volume/intensity maintained
    if (volumeChange >= 0 && intensityChange >= 0) {
      score +=
          (durationChange < 0 ? durationChange.abs() * 2 : -durationChange) *
          0.1;
    }

    return score.clamp(-100, 100);
  }

  MetricComparison _compareVolume(
    WorkoutMetrics metrics1,
    WorkoutMetrics metrics2,
  ) {
    return MetricComparison(
      current: metrics1.totalVolume,
      previous: metrics2.totalVolume,
      change: metrics1.totalVolume - metrics2.totalVolume,
      changePercentage: metrics2.totalVolume > 0
          ? ((metrics1.totalVolume - metrics2.totalVolume) /
                    metrics2.totalVolume) *
                100
          : 0,
    );
  }

  MetricComparison _compareIntensity(
    WorkoutMetrics metrics1,
    WorkoutMetrics metrics2,
  ) {
    return MetricComparison(
      current: metrics1.averageRPE,
      previous: metrics2.averageRPE,
      change: metrics1.averageRPE - metrics2.averageRPE,
      changePercentage: metrics2.averageRPE > 0
          ? ((metrics1.averageRPE - metrics2.averageRPE) /
                    metrics2.averageRPE) *
                100
          : 0,
    );
  }

  MetricComparison _compareDuration(
    WorkoutMetrics metrics1,
    WorkoutMetrics metrics2,
  ) {
    final current = metrics1.totalDuration.inMinutes.toDouble();
    final previous = metrics2.totalDuration.inMinutes.toDouble();

    return MetricComparison(
      current: current,
      previous: previous,
      change: current - previous,
      changePercentage: previous > 0
          ? ((current - previous) / previous) * 100
          : 0,
    );
  }

  Map<String, ExerciseComparison> _compareExercises(
    Workout workout1,
    Workout workout2,
  ) {
    final comparisons = <String, ExerciseComparison>{};

    // Get all exercise names from both workouts
    final allExercises = {
      ...workout1.exercises.map((e) => e.name),
      ...workout2.exercises.map((e) => e.name),
    };

    for (final exerciseName in allExercises) {
      final exercise1 = workout1.exercises.cast().firstWhere(
        (e) => e.name == exerciseName,
        orElse: () => null,
      );
      final exercise2 = workout2.exercises.cast().firstWhere(
        (e) => e.name == exerciseName,
        orElse: () => null,
      );

      comparisons[exerciseName] = ExerciseComparison(
        exerciseName: exerciseName,
        inWorkout1: exercise1 != null,
        inWorkout2: exercise2 != null,
        volume1: exercise1?.sets.fold(0.0, (sum, set) => sum + set.volume) ?? 0,
        volume2: exercise2?.sets.fold(0.0, (sum, set) => sum + set.volume) ?? 0,
        sets1: exercise1?.sets.length ?? 0,
        sets2: exercise2?.sets.length ?? 0,
      );
    }

    return comparisons;
  }

  double _calculateOverallScore(
    WorkoutMetrics metrics1,
    WorkoutMetrics metrics2,
  ) {
    // Calculate a comprehensive comparison score
    final volumeScore = metrics2.totalVolume > 0
        ? (metrics1.totalVolume / metrics2.totalVolume - 1) * 100
        : 0;

    final intensityScore = metrics2.averageRPE > 0
        ? (metrics1.averageRPE / metrics2.averageRPE - 1) * 100
        : 0;

    final densityScore = metrics2.trainingDensity > 0
        ? (metrics1.trainingDensity / metrics2.trainingDensity - 1) * 100
        : 0;

    return (volumeScore * 0.5) + (intensityScore * 0.3) + (densityScore * 0.2);
  }

  TrendDirection _getTrendDirection(double improvementScore) {
    if (improvementScore > 10) return TrendDirection.strongUp;
    if (improvementScore > 5) return TrendDirection.up;
    if (improvementScore < -10) return TrendDirection.strongDown;
    if (improvementScore < -5) return TrendDirection.down;
    return TrendDirection.stable;
  }
}

/// Workout similarity result
class WorkoutSimilarity {
  const WorkoutSimilarity({
    required this.workout,
    required this.similarity,
    required this.comparison,
  });
  final Workout workout;
  final double similarity;
  final WorkoutComparison comparison;
}

/// Detailed comparison between two workouts
class DetailedWorkoutComparison {
  const DetailedWorkoutComparison({
    required this.workout1,
    required this.workout2,
    required this.metrics1,
    required this.metrics2,
    required this.volumeComparison,
    required this.intensityComparison,
    required this.durationComparison,
    required this.exerciseComparison,
    required this.overallScore,
  });
  final Workout workout1;
  final Workout workout2;
  final WorkoutMetrics metrics1;
  final WorkoutMetrics metrics2;
  final MetricComparison volumeComparison;
  final MetricComparison intensityComparison;
  final MetricComparison durationComparison;
  final Map<String, ExerciseComparison> exerciseComparison;
  final double overallScore;
}

/// Comparison of a specific metric
class MetricComparison {
  const MetricComparison({
    required this.current,
    required this.previous,
    required this.change,
    required this.changePercentage,
  });
  final double current;
  final double previous;
  final double change;
  final double changePercentage;

  bool get isImprovement => change > 0;
  bool get isRegression => change < 0;
  bool get isStable => change.abs() < 0.01;
}

/// Exercise-specific comparison
class ExerciseComparison {
  const ExerciseComparison({
    required this.exerciseName,
    required this.inWorkout1,
    required this.inWorkout2,
    required this.volume1,
    required this.volume2,
    required this.sets1,
    required this.sets2,
  });
  final String exerciseName;
  final bool inWorkout1;
  final bool inWorkout2;
  final double volume1;
  final double volume2;
  final int sets1;
  final int sets2;

  bool get isInBoth => inWorkout1 && inWorkout2;
  bool get isNewExercise => inWorkout1 && !inWorkout2;
  bool get isRemovedExercise => !inWorkout1 && inWorkout2;

  double get volumeChange => volume1 - volume2;
  int get setsChange => sets1 - sets2;
}

/// Workout trend over time
class WorkoutTrend {
  const WorkoutTrend({
    required this.date,
    required this.workout,
    required this.comparison,
    required this.trendDirection,
  });
  final DateTime date;
  final Workout workout;
  final WorkoutComparison comparison;
  final TrendDirection trendDirection;
}

/// Trend direction enum
enum TrendDirection { strongUp, up, stable, down, strongDown }

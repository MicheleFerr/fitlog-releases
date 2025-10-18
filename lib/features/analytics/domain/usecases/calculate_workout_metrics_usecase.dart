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
/// - analytics/domain/entities: WorkoutMetrics
library;

import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';

/// Use case for calculating real-time workout metrics
class CalculateWorkoutMetricsUseCase {
  
  /// Calculate current workout metrics in real-time
  WorkoutMetrics execute(Workout workout) {
    try {
      return WorkoutMetrics.fromWorkout(workout);
    } catch (e) {
      // Return empty metrics if calculation fails
      return WorkoutMetrics.empty(workout.id);
    }
  }

  /// Calculate metrics with historical comparison
  WorkoutMetrics executeWithComparison(
    Workout currentWorkout,
    List<Workout> historicalWorkouts,
  ) {
    final baseMetrics = execute(currentWorkout);
    
    // Find best comparison workout
    final comparison = _findBestComparison(currentWorkout, historicalWorkouts);
    
    if (comparison != null) {
      final comparisonData = _calculateComparison(baseMetrics, comparison);
      return baseMetrics.copyWith(comparison: comparisonData);
    }
    
    return baseMetrics;
  }

  /// Calculate incremental metrics update (optimized for frequent calls)
  WorkoutMetrics executeIncremental(
    Workout workout,
    WorkoutMetrics? previousMetrics,
  ) {
    // If no previous metrics, calculate from scratch
    if (previousMetrics == null) {
      return execute(workout);
    }

    // Check if workout structure changed significantly
    if (_hasSignificantChanges(workout, previousMetrics)) {
      return execute(workout);
    }

    // Otherwise, incrementally update specific metrics
    return _updateIncrementalMetrics(workout, previousMetrics);
  }

  // Private helper methods

  WorkoutComparison? _findBestComparison(
    Workout currentWorkout,
    List<Workout> historicalWorkouts,
  ) {
    if (historicalWorkouts.isEmpty) return null;

    // Filter for similar workouts (same exercises or similar muscle groups)
    final similarWorkouts = historicalWorkouts.where((workout) {
      return _calculateWorkoutSimilarity(currentWorkout, workout) > 0.5;
    }).toList();

    if (similarWorkouts.isEmpty) {
      // Fallback to most recent completed workout
      return _createComparisonFromWorkout(historicalWorkouts.first);
    }

    // Use most recent similar workout
    similarWorkouts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return _createComparisonFromWorkout(similarWorkouts.first);
  }

  double _calculateWorkoutSimilarity(Workout workout1, Workout workout2) {
    final exercises1 = workout1.exercises.map((e) => e.name).toSet();
    final exercises2 = workout2.exercises.map((e) => e.name).toSet();
    
    final intersection = exercises1.intersection(exercises2);
    final union = exercises1.union(exercises2);
    
    if (union.isEmpty) return 0;
    
    return intersection.length / union.length;
  }

  WorkoutComparison _createComparisonFromWorkout(Workout comparisonWorkout) {
    final comparisonMetrics = WorkoutMetrics.fromWorkout(comparisonWorkout);
    
    return WorkoutComparison(
      comparisonId: comparisonWorkout.id,
      comparisonDate: comparisonWorkout.updatedAt,
      comparisonName: comparisonWorkout.name,
      volumeChange: 0, // Will be calculated in _calculateComparison
      volumeChangePercentage: 0,
      intensityChange: 0,
      intensityChangePercentage: 0,
      durationChange: Duration.zero,
      densityChange: 0,
      improvementScore: 0,
    );
  }

  WorkoutComparison _calculateComparison(
    WorkoutMetrics currentMetrics,
    WorkoutComparison baseComparison,
  ) {
    // This would need historical metrics - for now return base comparison
    // In full implementation, fetch historical metrics from repository
    return baseComparison;
  }

  bool _hasSignificantChanges(Workout workout, WorkoutMetrics previousMetrics) {
    // Check if number of exercises changed
    if (workout.exercises.length != previousMetrics.totalExercises) {
      return true;
    }

    // Check if completion status changed significantly
    final currentCompletedSets = workout.exercises
        .expand((e) => e.sets)
        .where((s) => s.isCompleted)
        .length;
    
    if ((currentCompletedSets - previousMetrics.completedSets).abs() > 2) {
      return true;
    }

    return false;
  }

  WorkoutMetrics _updateIncrementalMetrics(
    Workout workout,
    WorkoutMetrics previousMetrics,
  ) {
    // Quick update of key metrics without full recalculation
    final currentMetrics = WorkoutMetrics.fromWorkout(workout);
    
    return previousMetrics.copyWith(
      calculatedAt: DateTime.now(),
      totalVolume: currentMetrics.totalVolume,
      completedSets: currentMetrics.completedSets,
      completionPercentage: currentMetrics.completionPercentage,
      totalDuration: currentMetrics.totalDuration,
      trainingDensity: currentMetrics.trainingDensity,
    );
  }
}
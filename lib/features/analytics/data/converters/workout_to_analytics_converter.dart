/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/data/converters
/// 🎯 Feature: analytics
/// 🔧 Type: converter utility
///
/// Workout to Analytics Converter
///
/// **Purpose**: Centralized logic for converting Workout entities to Analytics sessions
///
/// **Used By**:
/// - WorkoutProvider (presentation layer)
/// - HybridWorkoutRepository (data layer)
///
/// **Why This Exists**:
/// - Prevents code duplication between provider and repository
/// - Single source of truth for analytics conversion logic
/// - Easier to maintain and test
///
/// **Usage**:
/// ```dart
/// final analyticsData = WorkoutToAnalyticsConverter.convert(workout);
/// for (final data in analyticsData) {
///   await analyticsRepo.updateExerciseHistory(
///     userId: userId,
///     exerciseName: data.exerciseName,
///     muscleGroup: data.muscleGroup,
///     session: data.session,
///   );
/// }
/// ```
library;

import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';

/// Data class for analytics conversion result
class ExerciseAnalyticsData {
  const ExerciseAnalyticsData({
    required this.exerciseName,
    required this.muscleGroup,
    required this.session,
  });

  final String exerciseName;
  final String muscleGroup;
  final ExerciseSession session;
}

/// Converter utility for transforming Workout entities to Analytics sessions
///
/// **Algorithm**:
/// 1. Extract session date from workout (startTime or createdAt)
/// 2. For each exercise in workout:
///    a. Filter completed sets with valid data (weight > 0, reps > 0)
///    b. Convert to AnalyticsSets
///    c. Create ExerciseSession
/// 3. Return list of ExerciseAnalyticsData (ready for repository)
class WorkoutToAnalyticsConverter {
  /// Private constructor (utility class, no instantiation)
  WorkoutToAnalyticsConverter._();

  /// Convert Workout to list of ExerciseAnalyticsData
  ///
  /// **Returns**: List of analytics data, one per exercise with valid sets
  ///
  /// **Filters**:
  /// - Only completed sets
  /// - Only sets with weight > 0
  /// - Only sets with reps > 0
  ///
  /// **Example**:
  /// ```dart
  /// final workout = Workout(...); // Completed workout with 3 exercises
  /// final analyticsData = WorkoutToAnalyticsConverter.convert(workout);
  /// // Returns: [
  /// //   ExerciseAnalyticsData(exerciseName: 'Squat', muscleGroup: 'legs', ...),
  /// //   ExerciseAnalyticsData(exerciseName: 'Bench Press', muscleGroup: 'chest', ...),
  /// // ]
  /// ```
  static List<ExerciseAnalyticsData> convert(Workout workout) {
    // Extract session date (use workout startTime or createdAt)
    final sessionDate = workout.startTime ?? workout.createdAt;

    final analyticsDataList = <ExerciseAnalyticsData>[];

    // Process each exercise
    for (final exercise in workout.exercises) {
      // Filter completed sets with valid data
      final completedSets = exercise.sets
          .where((set) =>
              set.isCompleted &&
              set.weight != null &&
              set.weight! > 0 &&
              (set.actualReps ?? set.reps) != null &&
              (set.actualReps ?? set.reps)! > 0)
          .toList();

      // Skip exercises with no valid sets
      if (completedSets.isEmpty) continue;

      // Convert to AnalyticsSets
      final analyticsSets = completedSets.map((set) {
        return AnalyticsSet(
          weight: set.weight!,
          reps: set.actualReps ?? set.reps!,
          date: set.completedAt ?? sessionDate,
        );
      }).toList();

      // Create ExerciseSession
      final session = ExerciseSession(
        exerciseName: exercise.name,
        muscleGroup: exercise.category.name, // Enum name matches string
        sets: analyticsSets,
        date: sessionDate,
      );

      // Add to result list
      analyticsDataList.add(
        ExerciseAnalyticsData(
          exerciseName: exercise.name,
          muscleGroup: exercise.category.name,
          session: session,
        ),
      );
    }

    return analyticsDataList;
  }

  /// Validate if workout can be converted to analytics
  ///
  /// **Returns**: true if workout has at least one exercise with valid sets
  ///
  /// **Use Case**: Check before calling convert() to avoid empty results
  ///
  /// **Example**:
  /// ```dart
  /// if (WorkoutToAnalyticsConverter.canConvert(workout)) {
  ///   final data = WorkoutToAnalyticsConverter.convert(workout);
  ///   // Process data...
  /// }
  /// ```
  static bool canConvert(Workout workout) {
    return workout.exercises.any((exercise) {
      return exercise.sets.any((set) =>
          set.isCompleted &&
          set.weight != null &&
          set.weight! > 0 &&
          (set.actualReps ?? set.reps) != null &&
          (set.actualReps ?? set.reps)! > 0);
    });
  }

  /// Count how many exercises in workout can be converted to analytics
  ///
  /// **Returns**: Number of exercises with valid sets
  ///
  /// **Use Case**: Logging/debugging
  ///
  /// **Example**:
  /// ```dart
  /// final count = WorkoutToAnalyticsConverter.countValidExercises(workout);
  /// debugPrint('Converting $count exercises to analytics');
  /// ```
  static int countValidExercises(Workout workout) {
    return workout.exercises.where((exercise) {
      return exercise.sets.any((set) =>
          set.isCompleted &&
          set.weight != null &&
          set.weight! > 0 &&
          (set.actualReps ?? set.reps) != null &&
          (set.actualReps ?? set.reps)! > 0);
    }).length;
  }
}

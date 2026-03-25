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
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/abstractions/exercise_counting_mode.dart';

/// Data class for analytics conversion result
class ExerciseAnalyticsData {
  const ExerciseAnalyticsData({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.session,
  });

  /// Unique identifier for the exercise (from database)
  final String exerciseId;
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
  /// **Parameters**:
  /// - workout: The completed workout to convert
  /// - userBodyWeightKg: Optional user body weight for bodyweight exercises
  ///
  /// **Filters**:
  /// - Only completed sets
  /// - Only sets with weight > 0 (or bodyweight exercises with reps > 0)
  /// - Only sets with reps > 0
  ///
  /// **Bodyweight Exercise Handling**:
  /// For exercises with countingMode == ExerciseCountingMode.reps (bodyweight):
  /// - Uses userBodyWeightKg as the weight if provided
  /// - Falls back to 0 if no body weight available (still tracked for reps)
  ///
  /// **Example**:
  /// ```dart
  /// final workout = Workout(...); // Completed workout with 3 exercises
  /// final analyticsData = WorkoutToAnalyticsConverter.convert(
  ///   workout,
  ///   userBodyWeightKg: 75.0,
  /// );
  /// // Returns: [
  /// //   ExerciseAnalyticsData(exerciseName: 'Squat', muscleGroup: 'legs', ...),
  /// //   ExerciseAnalyticsData(exerciseName: 'Push-ups', muscleGroup: 'chest', ...),
  /// // ]
  /// ```
  static List<ExerciseAnalyticsData> convert(
    Workout workout, {
    double? userBodyWeightKg,
  }) {
    // Extract session date (use workout startTime or createdAt)
    final sessionDate = workout.startTime ?? workout.createdAt;

    final analyticsDataList = <ExerciseAnalyticsData>[];

    // Process each exercise
    for (final exercise in workout.exercises) {
      // Check if this is a bodyweight exercise
      final isBodyweight = exercise.countingMode == ExerciseCountingMode.reps;

      // Filter completed sets with valid data
      // For bodyweight exercises: only require reps > 0
      // For weighted exercises: require weight > 0 AND reps > 0
      final completedSets = exercise.sets.where((set) {
        if (!set.isCompleted) return false;

        final reps = set.actualReps ?? set.reps;
        if (reps == null || reps <= 0) return false;

        if (isBodyweight) {
          // Bodyweight: only need valid reps
          return true;
        } else {
          // Weighted: need weight > 0
          return set.weight != null && set.weight! > 0;
        }
      }).toList();

      // Skip exercises with no valid sets
      if (completedSets.isEmpty) continue;

      // Convert to AnalyticsSets
      final analyticsSets = completedSets.map((set) {
        // Determine effective weight
        double effectiveWeight;
        if (isBodyweight) {
          // Bodyweight exercise: use user's body weight if available
          effectiveWeight = userBodyWeightKg ?? 0.0;
        } else {
          effectiveWeight = set.weight!;
        }

        return AnalyticsSet(
          weight: effectiveWeight,
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
          exerciseId: exercise.stableExerciseId,
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
  /// **Note**: Bodyweight exercises (countingMode == reps) only need valid reps
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
      final isBodyweight = exercise.countingMode == ExerciseCountingMode.reps;

      return exercise.sets.any((set) {
        if (!set.isCompleted) return false;

        final reps = set.actualReps ?? set.reps;
        if (reps == null || reps <= 0) return false;

        if (isBodyweight) {
          return true; // Bodyweight only needs valid reps
        } else {
          return set.weight != null && set.weight! > 0;
        }
      });
    });
  }

  /// Count how many exercises in workout can be converted to analytics
  ///
  /// **Returns**: Number of exercises with valid sets
  ///
  /// **Use Case**: Logging/debugging
  ///
  /// **Note**: Bodyweight exercises (countingMode == reps) only need valid reps
  ///
  /// **Example**:
  /// ```dart
  /// final count = WorkoutToAnalyticsConverter.countValidExercises(workout);
  /// debugPrint('Converting $count exercises to analytics');
  /// ```
  static int countValidExercises(Workout workout) {
    return workout.exercises.where((exercise) {
      final isBodyweight = exercise.countingMode == ExerciseCountingMode.reps;

      return exercise.sets.any((set) {
        if (!set.isCompleted) return false;

        final reps = set.actualReps ?? set.reps;
        if (reps == null || reps <= 0) return false;

        if (isBodyweight) {
          return true; // Bodyweight only needs valid reps
        } else {
          return set.weight != null && set.weight! > 0;
        }
      });
    }).length;
  }
}

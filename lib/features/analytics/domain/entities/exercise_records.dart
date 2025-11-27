/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/entities
/// 🎯 Feature: analytics
/// 🔧 Type: entity
///
/// ExerciseRecords - Personal records and computed statistics for an exercise
///
/// **Purpose**: Aggregated view of personal records for Exercise Detail Screen
///
/// **Data Structure**:
/// - Personal Records: maxWeight, estimated1RM, totalVolume, totalSets
/// - Recent Activity: lastWorkoutDate, weeklyFrequency
/// - Time Range: firstWorkoutDate, totalWorkouts
///
/// **Usage**:
/// ```dart
/// final records = ExerciseRecords(
///   exerciseName: 'Bench Press',
///   maxWeightRecord: 100.0,
///   estimated1RM: 110.5,
///   totalVolumeRecord: 5000.0,
///   totalSetsRecord: 150,
///   lastWorkoutDate: DateTime.now(),
///   firstWorkoutDate: DateTime.now().subtract(Duration(days: 90)),
///   totalWorkouts: 30,
///   weeklyFrequency: 2.5,
/// );
/// ```
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_records.freezed.dart';
part 'exercise_records.g.dart';

@freezed
abstract class ExerciseRecords with _$ExerciseRecords {
  const factory ExerciseRecords({
    /// Exercise name (matches ExerciseHistory.exerciseName)
    required String exerciseName,

    /// Personal Records
    required double maxWeightRecord, // Heaviest single set weight (kg)
    required double estimated1RM, // Estimated 1 rep max (Epley formula)
    required double totalVolumeRecord, // Highest single-workout volume (kg)
    required int totalSetsRecord, // Most sets in single workout

    /// Recent Activity
    required DateTime lastWorkoutDate, // Most recent workout date
    required double weeklyFrequency, // Avg workouts per week (last 4 weeks)

    /// Time Range
    required DateTime firstWorkoutDate, // First recorded workout
    required int totalWorkouts, // Total workout sessions
  }) = _ExerciseRecords;

  factory ExerciseRecords.fromJson(Map<String, dynamic> json) =>
      _$ExerciseRecordsFromJson(json);
}

/// Extension methods for ExerciseRecords calculations
extension ExerciseRecordsX on ExerciseRecords {
  /// Days since last workout
  int get daysSinceLastWorkout {
    return DateTime.now().difference(lastWorkoutDate).inDays;
  }

  /// Total training days (first to last workout)
  int get totalTrainingDays {
    return lastWorkoutDate.difference(firstWorkoutDate).inDays;
  }

  /// Average frequency over entire history (not just recent)
  double get overallFrequency {
    if (totalTrainingDays == 0) return 0.0;
    return (totalWorkouts / (totalTrainingDays / 7.0));
  }
}

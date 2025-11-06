/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/domain/models
/// 🎯 Feature: admin
/// 🔧 Type: model
///
/// Exercise statistics data model for Database Manager Overview tab
library;

import 'package:equatable/equatable.dart';

/// Exercise statistics breakdown for a specific language collection
class ExerciseStatistics extends Equatable {
  const ExerciseStatistics({
    required this.equipmentBreakdown,
    required this.muscleGroupBreakdown,
    required this.difficultyBreakdown,
    required this.exerciseTypeBreakdown,
    required this.totalExercises,
    required this.bodyweightCount,
    required this.compoundCount,
    required this.isolationCount,
  });

  /// Equipment distribution (e.g., "Bilanciere": 320, "Manubri": 280)
  final Map<String, int> equipmentBreakdown;

  /// Primary muscle group distribution (e.g., "Petto": 180, "Schiena": 220)
  final Map<String, int> muscleGroupBreakdown;

  /// Difficulty distribution (e.g., "Principiante": 400, "Intermedio": 800)
  final Map<String, int> difficultyBreakdown;

  /// Exercise type distribution (e.g., "Compound": 600, "Isolation": 500)
  final Map<String, int> exerciseTypeBreakdown;

  /// Total number of exercises
  final int totalExercises;

  /// Number of bodyweight exercises
  final int bodyweightCount;

  /// Number of compound exercises
  final int compoundCount;

  /// Number of isolation exercises
  final int isolationCount;

  @override
  List<Object?> get props => [
        equipmentBreakdown,
        muscleGroupBreakdown,
        difficultyBreakdown,
        exerciseTypeBreakdown,
        totalExercises,
        bodyweightCount,
        compoundCount,
        isolationCount,
      ];

  /// Get sorted entries by count (descending)
  List<MapEntry<String, int>> getSortedEquipment() {
    final entries = equipmentBreakdown.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Get sorted muscle groups by count (descending)
  List<MapEntry<String, int>> getSortedMuscleGroups() {
    final entries = muscleGroupBreakdown.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Get sorted difficulties by count (descending)
  List<MapEntry<String, int>> getSortedDifficulties() {
    final entries = difficultyBreakdown.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Get sorted exercise types by count (descending)
  List<MapEntry<String, int>> getSortedExerciseTypes() {
    final entries = exerciseTypeBreakdown.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Get percentage for a specific equipment
  double getEquipmentPercentage(String equipment) {
    if (totalExercises == 0) return 0.0;
    return (equipmentBreakdown[equipment] ?? 0) / totalExercises * 100;
  }

  /// Get percentage for a specific muscle group
  double getMuscleGroupPercentage(String muscleGroup) {
    if (totalExercises == 0) return 0.0;
    return (muscleGroupBreakdown[muscleGroup] ?? 0) / totalExercises * 100;
  }

  /// Get percentage for a specific difficulty
  double getDifficultyPercentage(String difficulty) {
    if (totalExercises == 0) return 0.0;
    return (difficultyBreakdown[difficulty] ?? 0) / totalExercises * 100;
  }

  /// Get percentage for a specific exercise type
  double getExerciseTypePercentage(String type) {
    if (totalExercises == 0) return 0.0;
    return (exerciseTypeBreakdown[type] ?? 0) / totalExercises * 100;
  }
}

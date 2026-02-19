import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/tier1_muscle_balance_chart.dart';
import 'package:gymbro_flutter_new/shared/domain/mappers/muscle_abbreviation_mapper.dart';

/// Shared utility for mapping ExerciseCategory to MuscleGroup
///
/// This eliminates code duplication across analyzers and ensures
/// consistent categorization logic throughout the app.
///
/// Note: Cardio and "other" exercises return null as they shouldn't
/// be tracked in muscle group volume analysis.
class MuscleGroupMapper {
  /// Maps an ExerciseCategory to its corresponding MuscleGroup
  ///
  /// Returns null for cardio/other exercises that shouldn't be tracked
  /// in volume analysis
  static MuscleGroup? fromExerciseCategory(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return MuscleGroup.chest;
      case ExerciseCategory.back:
        return MuscleGroup.back;
      case ExerciseCategory.shoulders:
        return MuscleGroup.shoulders;
      case ExerciseCategory.arms:
        return MuscleGroup.arms;
      case ExerciseCategory.legs:
        return MuscleGroup.legs;
      case ExerciseCategory.abs:
        return MuscleGroup.core;
      case ExerciseCategory.cardio:
      case ExerciseCategory.other:
        // Cardio and uncategorized exercises are excluded from volume analysis
        return null;
    }
  }

  /// Maps a MuscleCategory to its corresponding MuscleGroup
  static MuscleGroup fromMuscleCategory(MuscleCategory category) {
    return switch (category) {
      MuscleCategory.chest => MuscleGroup.chest,
      MuscleCategory.back => MuscleGroup.back,
      MuscleCategory.shoulders => MuscleGroup.shoulders,
      MuscleCategory.arms => MuscleGroup.arms,
      MuscleCategory.legs => MuscleGroup.legs,
      MuscleCategory.core => MuscleGroup.core,
    };
  }

  /// Maps a muscle abbreviation (e.g., "PETT", "LAT") to its MuscleGroup
  ///
  /// Returns null if the abbreviation is not recognized
  static MuscleGroup? fromMuscleAbbreviation(String abbreviation) {
    final muscleInfo = MuscleAbbreviationMapper.getMuscleInfo(abbreviation);
    if (muscleInfo == null) return null;
    return fromMuscleCategory(muscleInfo.category);
  }

  /// Maps a list of muscle abbreviations to MuscleGroups
  ///
  /// Returns unique MuscleGroups (no duplicates)
  static List<MuscleGroup> fromMuscleAbbreviations(List<String> abbreviations) {
    final groups = <MuscleGroup>{};
    for (final abbr in abbreviations) {
      final group = fromMuscleAbbreviation(abbr);
      if (group != null) {
        groups.add(group);
      }
    }
    return groups.toList();
  }

  /// Maps an English muscle name string to its MuscleGroup
  ///
  /// Handles common EN names like 'chest', 'back', 'lats', 'shoulders', etc.
  /// Returns null if the string is not recognized.
  ///
  /// This uses MuscleAbbreviationMapper.normalizeToHeatmapKey to convert
  /// the EN string to a normalized key, then maps to MuscleGroup.
  static MuscleGroup? fromEnglishString(String muscle) {
    final normalized = MuscleAbbreviationMapper.normalizeToHeatmapKey(muscle);

    // Map normalized heatmap key to MuscleGroup
    return switch (normalized) {
      'chest' => MuscleGroup.chest,
      'lats' || 'trapezius' || 'lower_back' || 'upper_back' => MuscleGroup.back,
      'shoulders' => MuscleGroup.shoulders,
      'biceps' || 'triceps' || 'forearms' => MuscleGroup.arms,
      'quadriceps' ||
      'hamstrings' ||
      'glutes' ||
      'calves' ||
      'adductors' ||
      'abductors' => MuscleGroup.legs,
      'abs' || 'obliques' => MuscleGroup.core,
      _ => null,
    };
  }
}

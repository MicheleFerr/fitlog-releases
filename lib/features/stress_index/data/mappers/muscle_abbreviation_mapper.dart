/// Muscle Abbreviation Mapper
///
/// Maps abbreviated muscle names from exercise JSON files (focus field)
/// to standardized muscle identifiers for stress index calculation.
///
/// Abbreviations found in exercises_it.json / exercises.json:
/// - TRIC, BICI, TRAP, LAT, CORE, PETT, DELT, GLUT, POLP, AVA, FEMOR, QUAD, ADDO, ADD, LOMBAR
library;

import 'package:gymbro_flutter_new/features/stress_index/domain/constants/stress_index_constants.dart';

/// Represents muscle group categories for grouping in UI
enum MuscleCategory {
  chest,
  back,
  shoulders,
  arms,
  legs,
  core,
}

/// Information about a specific muscle
class MuscleInfo {
  const MuscleInfo({
    required this.id,
    required this.displayNameEn,
    required this.displayNameIt,
    required this.category,
  });

  /// Unique identifier (matches abbreviation uppercase)
  final String id;

  /// Display name in English
  final String displayNameEn;

  /// Display name in Italian
  final String displayNameIt;

  /// Category for grouping
  final MuscleCategory category;

  /// Get recovery hours for this muscle
  int get recoveryHours =>
      StressIndexConstants.muscleRecoveryHours[id] ??
      StressIndexConstants.defaultRecoveryHours;
}

/// Maps focus field abbreviations to standardized muscle info
class MuscleAbbreviationMapper {
  MuscleAbbreviationMapper._();

  /// Mapping from abbreviation to muscle info
  static const Map<String, MuscleInfo> _abbreviationMap = {
    // Arms
    'TRIC': MuscleInfo(
      id: 'TRIC',
      displayNameEn: 'Triceps',
      displayNameIt: 'Tricipiti',
      category: MuscleCategory.arms,
    ),
    'BICI': MuscleInfo(
      id: 'BICI',
      displayNameEn: 'Biceps',
      displayNameIt: 'Bicipiti',
      category: MuscleCategory.arms,
    ),
    'BIC': MuscleInfo(
      id: 'BICI',
      displayNameEn: 'Biceps',
      displayNameIt: 'Bicipiti',
      category: MuscleCategory.arms,
    ),
    'AVA': MuscleInfo(
      id: 'AVA',
      displayNameEn: 'Forearms',
      displayNameIt: 'Avambracci',
      category: MuscleCategory.arms,
    ),

    // Back
    'LAT': MuscleInfo(
      id: 'LAT',
      displayNameEn: 'Lats',
      displayNameIt: 'Dorsali',
      category: MuscleCategory.back,
    ),
    'TRAP': MuscleInfo(
      id: 'TRAP',
      displayNameEn: 'Trapezius',
      displayNameIt: 'Trapezio',
      category: MuscleCategory.back,
    ),
    'LOMBAR': MuscleInfo(
      id: 'LOMBAR',
      displayNameEn: 'Lower Back',
      displayNameIt: 'Lombari',
      category: MuscleCategory.back,
    ),

    // Chest
    'PETT': MuscleInfo(
      id: 'PETT',
      displayNameEn: 'Chest',
      displayNameIt: 'Pettorali',
      category: MuscleCategory.chest,
    ),

    // Shoulders
    'DELT': MuscleInfo(
      id: 'DELT',
      displayNameEn: 'Shoulders',
      displayNameIt: 'Deltoidi',
      category: MuscleCategory.shoulders,
    ),

    // Legs
    'GLUT': MuscleInfo(
      id: 'GLUT',
      displayNameEn: 'Glutes',
      displayNameIt: 'Glutei',
      category: MuscleCategory.legs,
    ),
    'QUAD': MuscleInfo(
      id: 'QUAD',
      displayNameEn: 'Quadriceps',
      displayNameIt: 'Quadricipiti',
      category: MuscleCategory.legs,
    ),
    'FEMOR': MuscleInfo(
      id: 'FEMOR',
      displayNameEn: 'Hamstrings',
      displayNameIt: 'Femorali',
      category: MuscleCategory.legs,
    ),
    'POLP': MuscleInfo(
      id: 'POLP',
      displayNameEn: 'Calves',
      displayNameIt: 'Polpacci',
      category: MuscleCategory.legs,
    ),
    'ADD': MuscleInfo(
      id: 'ADD',
      displayNameEn: 'Adductors',
      displayNameIt: 'Adduttori',
      category: MuscleCategory.legs,
    ),
    'ADDO': MuscleInfo(
      id: 'ADD',
      displayNameEn: 'Adductors',
      displayNameIt: 'Adduttori',
      category: MuscleCategory.legs,
    ),

    // Core
    'CORE': MuscleInfo(
      id: 'CORE',
      displayNameEn: 'Core',
      displayNameIt: 'Core',
      category: MuscleCategory.core,
    ),
  };

  /// Get muscle info from abbreviation
  ///
  /// Returns null if abbreviation is not recognized
  static MuscleInfo? getMuscleInfo(String abbreviation) {
    return _abbreviationMap[abbreviation.toUpperCase().trim()];
  }

  /// Parse focus field (e.g., "BICI, TRIC") into list of muscles
  ///
  /// Focus field format: comma-separated abbreviations
  /// Example: "BICI, TRIC" -> [MuscleInfo(biceps), MuscleInfo(triceps)]
  ///
  /// Returns empty list if focus is null, empty, or "null"
  static List<MuscleInfo> parseFocusField(String? focus) {
    if (focus == null || focus.isEmpty || focus.toLowerCase() == 'null') {
      return [];
    }

    final muscles = <MuscleInfo>[];
    final parts = focus.split(',');

    for (final part in parts) {
      final abbr = part.trim().toUpperCase();
      final info = _abbreviationMap[abbr];
      if (info != null) {
        // Avoid duplicates (e.g., BIC and BICI both map to BICI)
        if (!muscles.any((m) => m.id == info.id)) {
          muscles.add(info);
        }
      }
    }

    return muscles;
  }

  /// Get all known muscle infos
  static List<MuscleInfo> getAllMuscles() {
    final seen = <String>{};
    final muscles = <MuscleInfo>[];

    for (final info in _abbreviationMap.values) {
      if (!seen.contains(info.id)) {
        seen.add(info.id);
        muscles.add(info);
      }
    }

    return muscles;
  }

  /// Get muscles by category
  static List<MuscleInfo> getMusclesByCategory(MuscleCategory category) {
    return getAllMuscles().where((m) => m.category == category).toList();
  }
}

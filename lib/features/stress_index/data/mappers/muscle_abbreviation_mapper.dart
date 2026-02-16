/// Muscle Abbreviation Mapper
///
/// Maps abbreviated muscle names from exercise JSON files (focus field)
/// to standardized muscle identifiers for stress index calculation.
///
/// **CANONICAL ABBREVIATIONS (4-letter standard):**
/// Arms: TRIC, BICI, AVA (3)
/// Back: LAT (3), TRAP, LOMB
/// Chest: PETT
/// Shoulders: DELT, DELT_ANT, DELT_LAT, DELT_POST, COLL
/// Legs: GLUT, QUAD, FEMO, POLP, ADD (3), ABDU
/// Core: CORE
///
/// **VARIANTS (mapped to canonical):**
/// Arms: BIC→BICI, AVAMB→AVA
/// Back: LOMBAR→LOMB, LOM→LOMB, DORSO→LAT
/// Shoulders: COLLO→COLL
/// Legs: FEMOR→FEMO, POLL→POLP, ADDO→ADD, ADDUT→ADD, ADDU→ADD, ABDUT→ABDU
/// Core: ADDOM→CORE
library;

import 'package:gymbro_flutter_new/features/stress_index/domain/constants/stress_index_constants.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

/// Represents muscle group categories for grouping in UI
enum MuscleCategory { chest, back, shoulders, arms, legs, core }

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
    'AVAMB': MuscleInfo(
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
    'LOMB': MuscleInfo(
      id: 'LOMB',
      displayNameEn: 'Lower Back',
      displayNameIt: 'Lombari',
      category: MuscleCategory.back,
    ),
    'LOMBAR': MuscleInfo(
      id: 'LOMB',
      displayNameEn: 'Lower Back',
      displayNameIt: 'Lombari',
      category: MuscleCategory.back,
    ),
    'LOM': MuscleInfo(
      id: 'LOMB',
      displayNameEn: 'Lower Back',
      displayNameIt: 'Lombari',
      category: MuscleCategory.back,
    ),
    'DORSO': MuscleInfo(
      id: 'LAT',
      displayNameEn: 'Back',
      displayNameIt: 'Dorsali',
      category: MuscleCategory.back,
    ),

    // Chest
    'PETT': MuscleInfo(
      id: 'PETT',
      displayNameEn: 'Chest',
      displayNameIt: 'Pettorali',
      category: MuscleCategory.chest,
    ),

    // Shoulders - Deltoid portions (P0 fix: split DELT into ANT/LAT/POST)
    'DELT_ANT': MuscleInfo(
      id: 'DELT_ANT',
      displayNameEn: 'Front Delts',
      displayNameIt: 'Deltoidi Anteriori',
      category: MuscleCategory.shoulders,
    ),
    'DELT_LAT': MuscleInfo(
      id: 'DELT_LAT',
      displayNameEn: 'Side Delts',
      displayNameIt: 'Deltoidi Laterali',
      category: MuscleCategory.shoulders,
    ),
    'DELT_POST': MuscleInfo(
      id: 'DELT_POST',
      displayNameEn: 'Rear Delts',
      displayNameIt: 'Deltoidi Posteriori',
      category: MuscleCategory.shoulders,
    ),
    // Backward compatibility - generic DELT (should be phased out)
    'DELT': MuscleInfo(
      id: 'DELT',
      displayNameEn: 'Shoulders',
      displayNameIt: 'Deltoidi',
      category: MuscleCategory.shoulders,
    ),
    'COLL': MuscleInfo(
      id: 'COLL',
      displayNameEn: 'Neck',
      displayNameIt: 'Collo',
      category: MuscleCategory.shoulders,
    ),
    'COLLO': MuscleInfo(
      id: 'COLL',
      displayNameEn: 'Neck',
      displayNameIt: 'Collo',
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
    'FEMO': MuscleInfo(
      id: 'FEMO',
      displayNameEn: 'Hamstrings',
      displayNameIt: 'Femorali',
      category: MuscleCategory.legs,
    ),
    'FEMOR': MuscleInfo(
      id: 'FEMO',
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
    'POLL': MuscleInfo(
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
    'ADDUT': MuscleInfo(
      id: 'ADD',
      displayNameEn: 'Adductors',
      displayNameIt: 'Adduttori',
      category: MuscleCategory.legs,
    ),
    'ADDU': MuscleInfo(
      id: 'ADD',
      displayNameEn: 'Adductors',
      displayNameIt: 'Adduttori',
      category: MuscleCategory.legs,
    ),
    'ABDUT': MuscleInfo(
      id: 'ABDU',
      displayNameEn: 'Abductors',
      displayNameIt: 'Abduttori',
      category: MuscleCategory.legs,
    ),
    'ABDU': MuscleInfo(
      id: 'ABDU',
      displayNameEn: 'Abductors',
      displayNameIt: 'Abduttori',
      category: MuscleCategory.legs,
    ),

    // Core
    'CORE': MuscleInfo(
      id: 'CORE',
      displayNameEn: 'Core',
      displayNameIt: 'Core',
      category: MuscleCategory.core,
    ),
    'ADDOM': MuscleInfo(
      id: 'CORE',
      displayNameEn: 'Abs',
      displayNameIt: 'Addominali',
      category: MuscleCategory.core,
    ),
    'OBL': MuscleInfo(
      id: 'OBL',
      displayNameEn: 'Obliques',
      displayNameIt: 'Obliqui',
      category: MuscleCategory.core,
    ),
    'OBLIQUI': MuscleInfo(
      id: 'OBL',
      displayNameEn: 'Obliques',
      displayNameIt: 'Obliqui',
      category: MuscleCategory.core,
    ),

    // Back - Rhomboids (added for secondary muscles)
    'ROMB': MuscleInfo(
      id: 'ROMB',
      displayNameEn: 'Rhomboids',
      displayNameIt: 'Romboidi',
      category: MuscleCategory.back,
    ),
    'ROMBOIDI': MuscleInfo(
      id: 'ROMB',
      displayNameEn: 'Rhomboids',
      displayNameIt: 'Romboidi',
      category: MuscleCategory.back,
    ),
  };

  /// Get muscle info from abbreviation
  ///
  /// Returns null if abbreviation is not recognized
  static MuscleInfo? getMuscleInfo(String abbreviation) {
    return _abbreviationMap[abbreviation.toUpperCase().trim()];
  }

  /// Normalize abbreviation to canonical ID
  ///
  /// Handles variations like:
  /// - BIC → BICI (canonical)
  /// - AVAMB → AVA (canonical)
  /// - LOMB → LOMBAR (canonical)
  /// - ADDO → ADD (canonical)
  ///
  /// **SINGLE SOURCE OF TRUTH** for abbreviation normalization.
  /// Returns the input uppercase if not found in mapping.
  static String normalizeToCanonicalId(String abbreviation) {
    final normalized = abbreviation.toUpperCase().trim();
    final info = _abbreviationMap[normalized];
    return info?.id ?? normalized;
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

  /// Convert MuscleCategory to ExerciseCategory
  ///
  /// This is the SINGLE SOURCE OF TRUTH for category conversion.
  /// All analytics and muscle group mappings should use this method.
  static ExerciseCategory muscleCategoryToExerciseCategory(
    MuscleCategory category,
  ) {
    return switch (category) {
      MuscleCategory.chest => ExerciseCategory.chest,
      MuscleCategory.back => ExerciseCategory.back,
      MuscleCategory.shoulders => ExerciseCategory.shoulders,
      MuscleCategory.arms => ExerciseCategory.arms,
      MuscleCategory.legs => ExerciseCategory.legs,
      MuscleCategory.core => ExerciseCategory.abs,
    };
  }

  /// Convert focus abbreviation(s) to ExerciseCategory
  ///
  /// This is the SINGLE SOURCE OF TRUTH for focus → category conversion.
  /// Use this instead of custom string matching logic.
  ///
  /// Takes a focus string (single abbreviation like "LAT" or comma-separated
  /// like "LAT, TRAP") and returns the corresponding ExerciseCategory.
  ///
  /// Returns the category of the FIRST valid muscle found.
  /// Returns ExerciseCategory.other if no valid muscle is found.
  ///
  /// Examples:
  /// - "LAT" → ExerciseCategory.back
  /// - "PETT" → ExerciseCategory.chest
  /// - "QUAD, GLUT" → ExerciseCategory.legs (first match)
  /// - "unknown" → ExerciseCategory.other
  static ExerciseCategory focusToExerciseCategory(String? focus) {
    if (focus == null || focus.isEmpty || focus.toLowerCase() == 'null') {
      return ExerciseCategory.other;
    }

    final muscles = parseFocusField(focus);
    if (muscles.isEmpty) {
      return ExerciseCategory.other;
    }

    // Return category of first muscle found
    return muscleCategoryToExerciseCategory(muscles.first.category);
  }

  /// Convert a list of focus abbreviations to ExerciseCategory
  ///
  /// Useful when ExerciseDefinition.focus is already parsed as List<String>.
  ///
  /// Returns the category of the FIRST valid muscle found.
  /// Returns ExerciseCategory.other if list is empty or no valid muscle found.
  static ExerciseCategory focusListToExerciseCategory(List<String> focusList) {
    if (focusList.isEmpty) {
      return ExerciseCategory.other;
    }

    for (final abbr in focusList) {
      final info = getMuscleInfo(abbr);
      if (info != null) {
        return muscleCategoryToExerciseCategory(info.category);
      }
    }

    return ExerciseCategory.other;
  }

  // ============================================================
  // HEATMAP SVG INTEGRATION
  // ============================================================
  // The SVG heatmap (from muscle_selector package) uses specific
  // English group names as keys. This mapping ensures consistency
  // between our abbreviations and the SVG muscle groups.

  /// Maps muscle ID to the SVG heatmap group key
  ///
  /// The SVG uses specific keys like 'lats', 'chest', 'quadriceps'.
  /// This is the SINGLE SOURCE OF TRUTH for abbreviation → heatmap key.
  static const Map<String, String> _muscleIdToHeatmapKey = {
    // Back
    'LAT': 'lats',
    'TRAP': 'trapezius',
    'LOMB': 'lower_back',
    'ROMB': 'trapezius', // Rhomboids group with upper back
    // Chest
    'PETT': 'chest',
    // Shoulders
    'DELT': 'shoulders',
    'DELT_ANT': 'shoulders',
    'DELT_LAT': 'shoulders',
    'DELT_POST': 'shoulders',
    'COLL': 'neck',
    // Arms
    'BICI': 'biceps',
    'TRIC': 'triceps',
    'AVA': 'forearms',
    // Legs
    'QUAD': 'quadriceps',
    'FEMO': 'hamstrings',
    'GLUT': 'glutes',
    'POLP': 'calves',
    'ADD': 'adductors',
    'ABDU': 'abductors',
    // Core
    'CORE': 'abs',
    'OBL': 'abs', // Obliques group with core
  };

  /// Convert any muscle abbreviation to the SVG heatmap group key
  ///
  /// This method normalizes all abbreviation variants (e.g., BIC, BICI, LOMB, LOMBAR)
  /// to their canonical heatmap group key (e.g., 'biceps', 'lower_back').
  ///
  /// Returns null if abbreviation is not recognized.
  ///
  /// Examples:
  /// - 'LAT' → 'lats'
  /// - 'DORSO' → 'lats' (via LAT id)
  /// - 'BIC' → 'biceps' (via BICI id)
  /// - 'LOMB' → 'lower_back' (via LOMBAR id)
  /// - 'PETT' → 'chest'
  /// - 'unknown' → null
  static String? toHeatmapGroupKey(String abbreviation) {
    final info = getMuscleInfo(abbreviation);
    if (info == null) return null;

    // Use the canonical muscle ID to get the heatmap key
    return _muscleIdToHeatmapKey[info.id];
  }

  /// Convert any key (abbreviation or English name) to heatmap group key
  ///
  /// Handles both:
  /// - IT abbreviations: 'lat', 'pett', 'quad'
  /// - EN names: 'back', 'chest', 'quads'
  /// - Already correct keys: 'lats', 'quadriceps'
  ///
  /// This is what MuscleHeatValues should use for normalization.
  static String normalizeToHeatmapKey(String key) {
    final keyLower = key.toLowerCase().trim();

    // First try as abbreviation (most common case)
    final fromAbbr = toHeatmapGroupKey(keyLower.toUpperCase());
    if (fromAbbr != null) return fromAbbr;

    // Handle English fallback names from MuscleBalanceCalculator
    const englishToHeatmap = {
      'chest': 'chest',
      'back': 'lats',
      'lats': 'lats',
      'shoulders': 'shoulders',
      'biceps': 'biceps',
      'triceps': 'triceps',
      'quads': 'quadriceps',
      'quadriceps': 'quadriceps',
      'hamstrings': 'hamstrings',
      'glutes': 'glutes',
      'calves': 'calves',
      'abs': 'abs',
      'core': 'abs',
      'forearms': 'forearms',
      'adductors': 'adductors',
      'abductors': 'abductors',
      'lower_back': 'lower_back',
      'neck': 'neck',
      'trapezius': 'trapezius',
      'traps': 'trapezius',
    };

    return englishToHeatmap[keyLower] ?? keyLower;
  }

  // ============================================================
  // UNIFIED MAPPING METHODS
  // ============================================================
  // These methods provide a single source of truth for ALL muscle
  // name/code conversions across the entire app.

  /// Convert muscle name (IT/EN) to standard abbreviation code
  ///
  /// Supports:
  /// - Italian names: "Pettorali" → "PETT"
  /// - English names: "Chest" → "PETT"
  /// - Already abbreviations: "PETT" → "PETT"
  ///
  /// Returns null if not recognized.
  static String? nameToAbbreviation(String name) {
    final lower = name.toLowerCase().trim();

    // First check if it's already an abbreviation
    final direct = getMuscleInfo(name);
    if (direct != null) return direct.id;

    // Map common IT/EN names to abbreviations
    const nameMap = {
      // Italian names
      'pettorali': 'PETT',
      'petto': 'PETT',
      'dorsali': 'LAT',
      'dorso': 'LAT',
      'deltoidi': 'DELT',
      'spalle': 'DELT',
      'bicipiti': 'BICI',
      'tricipiti': 'TRIC',
      'trapezi': 'TRAP',
      'trapezio': 'TRAP',
      'quadricipiti': 'QUAD',
      'glutei': 'GLUT',
      'femorali': 'FEMO',
      'polpacci': 'POLP',
      'addominali': 'CORE',
      'core': 'CORE',
      'avambracci': 'AVA',
      'lombari': 'LOMB',
      'adduttori': 'ADD',
      'abduttori': 'ABDU',
      // English names
      'chest': 'PETT',
      'back': 'LAT',
      'lats': 'LAT',
      'shoulders': 'DELT',
      'biceps': 'BICI',
      'triceps': 'TRIC',
      'traps': 'TRAP',
      'trapezius': 'TRAP',
      'quads': 'QUAD',
      'quadriceps': 'QUAD',
      'glutes': 'GLUT',
      'hamstrings': 'FEMO',
      'calves': 'POLP',
      'abs': 'CORE',
      'forearms': 'AVA',
      'lower back': 'LOMB',
      'lower_back': 'LOMB',
      'rear delts': 'DELT_POST',
      'rear_delts': 'DELT_POST',
      'adductors': 'ADD',
      'abductors': 'ABDU',
    };

    return nameMap[lower];
  }

  /// Get display name from abbreviation code
  ///
  /// Returns the display name in Italian or English.
  /// Returns the code itself if not recognized.
  ///
  /// Examples:
  /// - codeToDisplayName('PETT') → 'Pettorali'
  /// - codeToDisplayName('PETT', italian: false) → 'Chest'
  static String codeToDisplayName(String code, {bool italian = true}) {
    final info = getMuscleInfo(code);
    if (info == null) return code;
    return italian ? info.displayNameIt : info.displayNameEn;
  }

  /// Get all abbreviation codes for an ExerciseCategory
  ///
  /// This is the SINGLE SOURCE OF TRUTH for category → abbreviations.
  /// Use this instead of hardcoding category mappings.
  ///
  /// Examples:
  /// - categoryToAbbreviations(ExerciseCategory.chest) → ['PETT']
  /// - categoryToAbbreviations(ExerciseCategory.back) → ['LAT', 'TRAP', 'LOMBAR']
  static List<String> categoryToAbbreviations(ExerciseCategory category) {
    final muscleCategory = switch (category) {
      ExerciseCategory.chest => MuscleCategory.chest,
      ExerciseCategory.back => MuscleCategory.back,
      ExerciseCategory.shoulders => MuscleCategory.shoulders,
      ExerciseCategory.arms => MuscleCategory.arms,
      ExerciseCategory.legs => MuscleCategory.legs,
      ExerciseCategory.abs => MuscleCategory.core,
      ExerciseCategory.cardio => null,
      ExerciseCategory.other => null,
    };

    if (muscleCategory == null) return [];

    return getMusclesByCategory(muscleCategory).map((m) => m.id).toList();
  }

  /// Get all primary muscles for UI selector (MuscleChipSelector)
  ///
  /// Returns a map of abbreviation → Italian display name
  /// for the most commonly used muscles in exercise creation.
  ///
  /// Ordered by category for better UX.
  static Map<String, String> getAllMusclesForSelector() {
    // Manually ordered for better UX in selectors
    return {
      // Chest
      'PETT': 'Pettorali',
      // Shoulders
      'DELT_ANT': 'Deltoidi Anteriori',
      'DELT_LAT': 'Deltoidi Laterali',
      'DELT_POST': 'Deltoidi Posteriori',
      'COLL': 'Collo',
      // Arms
      'TRIC': 'Tricipiti',
      'BICI': 'Bicipiti',
      'AVA': 'Avambracci',
      // Back
      'LAT': 'Dorsali',
      'TRAP': 'Trapezio',
      'LOMB': 'Lombari',
      // Legs
      'QUAD': 'Quadricipiti',
      'FEMO': 'Femorali',
      'GLUT': 'Glutei',
      'POLP': 'Polpacci',
      'ADD': 'Adduttori',
      'ABDU': 'Abduttori',
      // Core
      'CORE': 'Core',
    };
  }

  /// Normalize display name variations to MuscleCategory
  ///
  /// Handles various input formats (EN, IT, abbreviations) and normalizes
  /// to a canonical MuscleCategory enum value.
  ///
  /// This is the SINGLE SOURCE OF TRUTH for category name normalization.
  ///
  /// Examples:
  /// - normalizeToCategory('chest') → MuscleCategory.chest
  /// - normalizeToCategory('petto') → MuscleCategory.chest
  /// - normalizeToCategory('Back') → MuscleCategory.back
  /// - normalizeToCategory('schiena') → MuscleCategory.back
  /// - normalizeToCategory('gambe') → MuscleCategory.legs
  static MuscleCategory? normalizeToCategory(String displayName) {
    final lower = displayName.toLowerCase().trim();

    return switch (lower) {
      // Chest variations
      'chest' || 'petto' || 'pettorali' || 'pecs' => MuscleCategory.chest,

      // Back variations
      'back' ||
      'schiena' ||
      'dorsali' ||
      'dorso' ||
      'lats' => MuscleCategory.back,

      // Shoulders variations
      'shoulders' ||
      'spalle' ||
      'delts' ||
      'deltoids' => MuscleCategory.shoulders,

      // Arms variations
      'arms' || 'braccia' || 'biceps' || 'triceps' => MuscleCategory.arms,

      // Legs variations
      'legs' ||
      'gambe' ||
      'lower body' ||
      'quads' ||
      'hamstrings' => MuscleCategory.legs,

      // Core variations
      'core' || 'abs' || 'addominali' || 'abdominals' => MuscleCategory.core,

      // Unknown
      _ => null,
    };
  }

  /// Get abbreviation codes matching a search term
  ///
  /// Supports pattern-based search (push, pull, legs, etc.)
  /// and direct muscle name matching.
  ///
  /// This is the SINGLE SOURCE OF TRUTH for search → abbreviations.
  static List<String> getSearchAbbreviations(String searchTerm) {
    final lower = searchTerm.toLowerCase().trim();

    // Pattern-based searches
    const patternMap = {
      // Movement patterns
      'push': ['PETT', 'TRIC', 'DELT', 'DELT_ANT'],
      'pull': ['LAT', 'TRAP', 'BICI', 'LOMB'],
      'legs': ['QUAD', 'GLUT', 'FEMO', 'POLP', 'ADD'],
      'hinge': ['FEMO', 'GLUT', 'LOMB', 'TRAP'],
      'squat': ['QUAD', 'GLUT'],
      // Body regions
      'upper body': ['PETT', 'LAT', 'DELT', 'BICI', 'TRIC', 'TRAP'],
      'lower body': ['QUAD', 'GLUT', 'FEMO', 'POLP', 'ADD'],
      'full body': [
        'PETT',
        'LAT',
        'DELT',
        'BICI',
        'TRIC',
        'QUAD',
        'GLUT',
        'FEMO',
      ],
      'core': ['CORE'],
      // Italian patterns
      'braccia': ['BICI', 'TRIC', 'AVA'],
      'gambe': ['QUAD', 'GLUT', 'FEMO', 'POLP', 'ADD'],
      'schiena': ['LAT', 'TRAP', 'LOMB'],
    };

    if (patternMap.containsKey(lower)) {
      return patternMap[lower]!;
    }

    // Try direct name to abbreviation
    final abbr = nameToAbbreviation(lower);
    if (abbr != null) return [abbr];

    return [];
  }

  // ============================================================
  // EXERCISE NAME CATEGORIZATION (SSOT)
  // ============================================================

  /// Categorize exercise by name with pattern matching
  ///
  /// **SINGLE SOURCE OF TRUTH** for exercise name → muscle group categorization.
  /// Used as fallback when exercise is not found in database.
  ///
  /// Returns EN display name (Chest, Back, etc.) for use as stable keys.
  ///
  /// Scientific Note: Muscle group categorization affects volume distribution
  /// analysis for balance and injury prevention (Croisier et al., 2008)
  ///
  /// Examples:
  /// - categorizeExerciseByName('Bench Press') → 'Chest'
  /// - categorizeExerciseByName('Lat Pulldown') → 'Back'
  /// - categorizeExerciseByName('Squat') → 'Legs'
  static String categorizeExerciseByName(String exerciseName) {
    final name = exerciseName.toLowerCase();

    // CHEST patterns - order matters (specific first)
    if (name.contains('bench') ||
        name.contains('chest') ||
        name.contains('fly') ||
        name.contains('flyes') ||
        name.contains('pec') ||
        name.contains('panca') ||
        name.contains('pettoral') ||
        name.contains('croci') ||
        (name.contains('dip') && !name.contains('shoulder'))) {
      return 'Chest';
    }

    // BACK patterns - distinguish from bench/chest
    if ((name.contains('pull') && !name.contains('pullover')) ||
        name.contains('row') ||
        name.contains('lat') ||
        name.contains('back') ||
        name.contains('deadlift') ||
        name.contains('stacco') ||
        name.contains('t-bar') ||
        name.contains('chin') ||
        name.contains('pulley') ||
        name.contains('rematore') ||
        name.contains('trazion') ||
        name.contains('dorsal')) {
      return 'Back';
    }

    // SHOULDERS patterns - distinguish from chest press
    if (name.contains('shoulder') ||
        name.contains('delt') ||
        name.contains('lateral') ||
        name.contains('spall') ||
        name.contains('alzat') ||
        (name.contains('overhead') && name.contains('press')) ||
        name.contains('military') ||
        name.contains('arnold') ||
        name.contains('face pull') ||
        name.contains('upright row') ||
        (name.contains('press') &&
            !name.contains('leg') &&
            !name.contains('chest') &&
            !name.contains('bench') &&
            !name.contains('french'))) {
      return 'Shoulders';
    }

    // LEGS patterns - separate quad/hamstring when possible
    if (name.contains('squat') ||
        name.contains('leg') ||
        name.contains('quad') ||
        name.contains('hamstring') ||
        name.contains('glute') ||
        name.contains('glut') ||
        name.contains('lunge') ||
        name.contains('affondi') ||
        name.contains('calf') ||
        name.contains('polpacc') ||
        name.contains('rdl') ||
        name.contains('romanian') ||
        name.contains('hip thrust')) {
      return 'Legs';
    }

    // ARMS patterns - check before general patterns
    // Triceps first (before biceps patterns)
    if (name.contains('tricep') ||
        name.contains('french press') ||
        name.contains('pushdown') ||
        name.contains('skull')) {
      return 'Arms';
    }
    // Biceps
    if ((name.contains('curl') && !name.contains('leg')) ||
        name.contains('bicep') ||
        name.contains('bicip')) {
      return 'Arms';
    }
    // General arms
    if (name.contains('arm') ||
        (name.contains('extension') && !name.contains('leg')) ||
        name.contains('kickback')) {
      return 'Arms';
    }

    // CORE patterns
    if (name.contains('ab') ||
        name.contains('core') ||
        name.contains('plank') ||
        name.contains('crunch') ||
        name.contains('sit up') ||
        name.contains('addominal') ||
        name.contains('russian twist') ||
        (name.contains('leg raise') && !name.contains('calf'))) {
      return 'Core';
    }

    return 'Other';
  }

  /// Get MuscleCategory from exercise name
  ///
  /// Convenience method that combines [categorizeExerciseByName] with
  /// [normalizeToCategory] for when you need the enum instead of string.
  static MuscleCategory? categoryFromExerciseName(String exerciseName) {
    final groupName = categorizeExerciseByName(exerciseName);
    return normalizeToCategory(groupName);
  }

  /// Categorize exercise by name to granular muscle abbreviation
  ///
  /// **SINGLE SOURCE OF TRUTH** for exercise name → abbreviation code.
  /// Returns more granular codes (QUAD, FEMOR, PETT, DORS, etc.) instead of
  /// generic categories (Legs, Back, etc.).
  ///
  /// Used for volume calculation where specific muscles need tracking.
  ///
  /// Examples:
  /// - categorizeExerciseToAbbreviation('Squat') → 'QUAD'
  /// - categorizeExerciseToAbbreviation('Leg Curl') → 'FEMOR'
  /// - categorizeExerciseToAbbreviation('Bench Press') → 'PETT'
  static String categorizeExerciseToAbbreviation(String exerciseName) {
    final name = exerciseName.toLowerCase();

    // QUAD - Quadriceps
    if (name.contains('squat') ||
        name.contains('leg press') ||
        name.contains('leg extension') ||
        name.contains('affondi') ||
        name.contains('lunge')) {
      return 'QUAD';
    }

    // FEMOR - Hamstrings
    if (name.contains('deadlift') ||
        name.contains('romanian') ||
        name.contains('stacco') ||
        name.contains('leg curl') ||
        name.contains('hamstring') ||
        name.contains('rdl') ||
        name.contains('good morning')) {
      return 'FEMOR';
    }

    // PETT - Chest
    if (name.contains('bench') ||
        name.contains('chest') ||
        name.contains('panca') ||
        name.contains('pettoral') ||
        name.contains('croci') ||
        name.contains('fly') ||
        name.contains('flyes') ||
        name.contains('pec')) {
      return 'PETT';
    }

    // DORS/LAT - Back (check before tricep patterns because of "pulldown")
    if ((name.contains('pull') && !name.contains('pullover')) ||
        name.contains('row') ||
        name.contains('lat') ||
        name.contains('pulley') ||
        name.contains('rematore') ||
        name.contains('trazion') ||
        name.contains('dorsal') ||
        name.contains('t-bar') ||
        name.contains('chin')) {
      return 'LAT';
    }

    // TRIC - Triceps (check before DELT because "french press" contains "press")
    if (name.contains('tricep') ||
        name.contains('french press') ||
        name.contains('pushdown') ||
        name.contains('skull') ||
        (name.contains('dip') && !name.contains('shoulder'))) {
      return 'TRIC';
    }

    // DELT - Shoulders
    if (name.contains('shoulder') ||
        name.contains('lateral') ||
        name.contains('spall') ||
        name.contains('alzat') ||
        name.contains('military') ||
        name.contains('delt') ||
        name.contains('face pull') ||
        name.contains('upright row') ||
        name.contains('arnold') ||
        (name.contains('overhead') && name.contains('press')) ||
        (name.contains('press') &&
            !name.contains('leg') &&
            !name.contains('chest') &&
            !name.contains('bench') &&
            !name.contains('french'))) {
      return 'DELT';
    }

    // BICI - Biceps
    if ((name.contains('curl') && !name.contains('leg')) ||
        name.contains('bicep') ||
        name.contains('bicip')) {
      return 'BICI';
    }

    // POLP - Calves
    if (name.contains('calf') || name.contains('polpacc')) {
      return 'POLP';
    }

    // GLUT - Glutes
    if (name.contains('glute') ||
        name.contains('glut') ||
        name.contains('hip thrust')) {
      return 'GLUT';
    }

    // CORE - Abs
    if (name.contains('ab') ||
        name.contains('core') ||
        name.contains('plank') ||
        name.contains('crunch') ||
        name.contains('addominal') ||
        name.contains('sit up') ||
        name.contains('russian twist') ||
        (name.contains('leg raise') && !name.contains('calf'))) {
      return 'CORE';
    }

    return 'VARIO';
  }
}

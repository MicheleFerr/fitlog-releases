import 'package:gymbro_flutter_new/features/strength_standards/data/datasources/strength_standards_local_datasource.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/exercise_mapping.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';

/// Repository for accessing strength standards and exercise mappings.
///
/// Implements caching strategy to avoid reloading JSON on every access.
/// Data is loaded once on first access and cached in memory.
class StrengthStandardsRepositoryImpl implements StrengthStandardsRepository {

  StrengthStandardsRepositoryImpl(this._localDataSource);
  final StrengthStandardsLocalDataSource _localDataSource;

  // In-memory cache
  List<StrengthStandard>? _cachedStandards;
  List<ExerciseMapping>? _cachedMappings;
  Map<String, StrengthStandard>? _standardsById;
  Map<String, ExerciseMapping>? _mappingsByExerciseId;
  Map<String, ExerciseMapping>? _mappingsByExerciseName; // Index by name for UI lookups

  @override
  Future<List<StrengthStandard>> getStrengthStandards({
    bool forceRefresh = false,
  }) async {
    if (_cachedStandards != null && !forceRefresh) {
      return _cachedStandards!;
    }

    _cachedStandards = await _localDataSource.loadStrengthStandards();
    _buildStandardsIndex();
    return _cachedStandards!;
  }

  @override
  Future<List<ExerciseMapping>> getExerciseMappings({
    bool forceRefresh = false,
  }) async {
    if (_cachedMappings != null && !forceRefresh) {
      return _cachedMappings!;
    }

    _cachedMappings = await _localDataSource.loadExerciseMappings();
    _buildMappingsIndex();
    return _cachedMappings!;
  }

  @override
  Future<StrengthStandard?> getStrengthStandardById(String id) async {
    if (_standardsById == null) {
      await getStrengthStandards();
    }
    return _standardsById?[id];
  }

  @override
  Future<ExerciseMapping?> getMappingForExercise(String exerciseKey) async {
    if (_mappingsByExerciseId == null) {
      await getExerciseMappings();
    }
    // Try lookup by gymbroId first, then by normalized name
    // This allows both ID-based and name-based lookups from UI
    return _mappingsByExerciseId?[exerciseKey]
        ?? _mappingsByExerciseName?[_normalizeForLookup(exerciseKey)];
  }

  /// Normalize string for name-based lookup (lowercase, trim)
  String _normalizeForLookup(String text) {
    return text.toLowerCase().trim();
  }

  @override
  Future<List<ExerciseMapping>> getMappingsByStatus(
    MappingStatus status,
  ) async {
    final mappings = await getExerciseMappings();
    return mappings.where((m) => m.status == status).toList();
  }

  @override
  Future<List<ExerciseMapping>> getHighConfidenceMappings({
    double minConfidence = 0.80,
  }) async {
    final mappings = await getExerciseMappings();
    return mappings.where((m) => m.confidence >= minConfidence).toList();
  }

  @override
  Future<List<StrengthStandard>> getStrengthStandardsByEquipment(
    String equipment,
  ) async {
    final standards = await getStrengthStandards();
    return standards
        .where((s) => s.equipment.toLowerCase() == equipment.toLowerCase())
        .toList();
  }

  @override
  Future<List<StrengthStandard>> getStrengthStandardsByMuscleGroup(
    String muscleGroup,
  ) async {
    final standards = await getStrengthStandards();
    return standards
        .where((s) => s.muscleGroups.any(
              (mg) => mg.toLowerCase().contains(muscleGroup.toLowerCase()),
            ))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getMetadata() async {
    final standardsMetadata =
        await _localDataSource.loadStrengthStandardsMetadata();
    final mappingsMetadata =
        await _localDataSource.loadExerciseMappingsMetadata();

    return {
      'strengthStandards': standardsMetadata,
      'exerciseMappings': mappingsMetadata,
    };
  }

  @override
  void clearCache() {
    _cachedStandards = null;
    _cachedMappings = null;
    _standardsById = null;
    _mappingsByExerciseId = null;
    _mappingsByExerciseName = null;
  }

  /// Build index for fast ID lookup
  void _buildStandardsIndex() {
    if (_cachedStandards == null) return;
    _standardsById = {
      for (final standard in _cachedStandards!) standard.id: standard
    };
  }

  /// Build index for fast exercise ID lookup
  /// Creates two indices: by gymbroId and by gymbroName (normalized)
  void _buildMappingsIndex() {
    if (_cachedMappings == null) return;

    // Primary index: by gymbroId (e.g., "barbell_bench_press")
    _mappingsByExerciseId = {
      for (final mapping in _cachedMappings!) mapping.gymbroId: mapping
    };

    // Secondary index: by gymbroName normalized (e.g., "barbell bench press")
    // Allows UI to lookup by exercise display name
    _mappingsByExerciseName = {
      for (final mapping in _cachedMappings!)
        mapping.gymbroName.toLowerCase().trim(): mapping
    };
  }
}

/// Repository interface for strength standards and exercise mappings
abstract class StrengthStandardsRepository {
  /// Get all strength standards
  Future<List<StrengthStandard>> getStrengthStandards({
    bool forceRefresh = false,
  });

  /// Get all exercise mappings
  Future<List<ExerciseMapping>> getExerciseMappings({
    bool forceRefresh = false,
  });

  /// Get strength standard by ID
  Future<StrengthStandard?> getStrengthStandardById(String id);

  /// Get exercise mapping for a specific exercise
  Future<ExerciseMapping?> getMappingForExercise(String exerciseId);

  /// Get mappings by status (auto, review, fallback)
  Future<List<ExerciseMapping>> getMappingsByStatus(MappingStatus status);

  /// Get high confidence mappings
  Future<List<ExerciseMapping>> getHighConfidenceMappings({
    double minConfidence = 0.80,
  });

  /// Get standards by equipment type
  Future<List<StrengthStandard>> getStrengthStandardsByEquipment(
    String equipment,
  );

  /// Get standards by muscle group
  Future<List<StrengthStandard>> getStrengthStandardsByMuscleGroup(
    String muscleGroup,
  );

  /// Get metadata about data sources
  Future<Map<String, dynamic>> getMetadata();

  /// Clear in-memory cache
  void clearCache();
}

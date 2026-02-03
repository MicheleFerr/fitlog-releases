import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/exercise_mapping.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';

/// Local datasource for loading strength standards and exercise mappings from assets.
///
/// Loads JSON files bundled with the app:
/// - assets/data/strength_standards.json (25 standards)
/// - assets/data/exercise_mappings.json (1501 exercise mappings)
///
/// ⚡ PERFORMANCE: Static cache prevents duplicate asset loads
/// - Caches parsed JSON data and entities
/// - Metadata extracted from cached data (no duplicate file loads)
/// - Pending requests prevent concurrent duplicate loads
class StrengthStandardsLocalDataSource {
  static const _strengthStandardsPath = 'assets/data/strength_standards.json';
  static const _exerciseMappingsPath = 'assets/data/exercise_mappings.json';

  /// Static caches for parsed JSON data
  static Map<String, dynamic>? _strengthStandardsJson;
  static Map<String, dynamic>? _exerciseMappingsJson;

  /// Static caches for entity lists
  static List<StrengthStandard>? _strengthStandardsCache;
  static List<ExerciseMapping>? _exerciseMappingsCache;

  /// In-flight requests to prevent concurrent loads
  static Future<Map<String, dynamic>>? _pendingStandards;
  static Future<Map<String, dynamic>>? _pendingMappings;

  /// Load all strength standards from assets
  /// ⚡ CACHED: Returns cached entities if available
  Future<List<StrengthStandard>> loadStrengthStandards() async {
    // Return cached entities if available
    if (_strengthStandardsCache != null) {
      return _strengthStandardsCache!;
    }

    // Load JSON (cached)
    final jsonData = await _loadStrengthStandardsJson();
    final standardsList = jsonData['standards'] as List<dynamic>;

    final standards = standardsList
        .map((e) => StrengthStandard.fromJson(e as Map<String, dynamic>))
        .toList();

    _strengthStandardsCache = standards;
    return standards;
  }

  /// Load all exercise mappings from assets
  /// ⚡ CACHED: Returns cached entities if available
  Future<List<ExerciseMapping>> loadExerciseMappings() async {
    // Return cached entities if available
    if (_exerciseMappingsCache != null) {
      return _exerciseMappingsCache!;
    }

    // Load JSON (cached)
    final jsonData = await _loadExerciseMappingsJson();
    final mappingsList = jsonData['mappings'] as List<dynamic>;

    final mappings = mappingsList
        .map((e) => ExerciseMapping.fromJson(e as Map<String, dynamic>))
        .toList();

    _exerciseMappingsCache = mappings;
    return mappings;
  }

  /// Load metadata from strength standards file
  /// ⚡ OPTIMIZED: Extracts from cached JSON instead of reloading file
  Future<Map<String, dynamic>> loadStrengthStandardsMetadata() async {
    final jsonData = await _loadStrengthStandardsJson();

    return {
      'version': jsonData['version'] as String?,
      'lastUpdated': jsonData['lastUpdated'] as String?,
      'totalStandards': (jsonData['standards'] as List).length,
    };
  }

  /// Load metadata from exercise mappings file
  /// ⚡ OPTIMIZED: Extracts from cached JSON instead of reloading file
  Future<Map<String, dynamic>> loadExerciseMappingsMetadata() async {
    final jsonData = await _loadExerciseMappingsJson();

    return {
      'version': jsonData['version'] as String?,
      'generated': jsonData['generated'] as String?,
      'model': jsonData['model'] as String?,
      'statistics': jsonData['statistics'] as Map<String, dynamic>?,
    };
  }

  /// Internal method to load and cache strength standards JSON
  Future<Map<String, dynamic>> _loadStrengthStandardsJson() async {
    // Return cached JSON if available
    if (_strengthStandardsJson != null) {
      return _strengthStandardsJson!;
    }

    // If already loading, wait for it
    if (_pendingStandards != null) {
      return _pendingStandards!;
    }

    // Start new load
    _pendingStandards = _loadJsonFromAsset(_strengthStandardsPath);

    try {
      final jsonData = await _pendingStandards!;
      _strengthStandardsJson = jsonData;
      return jsonData;
    } catch (e) {
      throw StrengthStandardsLoadException(
        'Failed to load strength standards: $e',
      );
    } finally {
      _pendingStandards = null;
    }
  }

  /// Internal method to load and cache exercise mappings JSON
  Future<Map<String, dynamic>> _loadExerciseMappingsJson() async {
    // Return cached JSON if available
    if (_exerciseMappingsJson != null) {
      return _exerciseMappingsJson!;
    }

    // If already loading, wait for it
    if (_pendingMappings != null) {
      return _pendingMappings!;
    }

    // Start new load
    _pendingMappings = _loadJsonFromAsset(_exerciseMappingsPath);

    try {
      final jsonData = await _pendingMappings!;
      _exerciseMappingsJson = jsonData;
      return jsonData;
    } catch (e) {
      throw ExerciseMappingsLoadException(
        'Failed to load exercise mappings: $e',
      );
    } finally {
      _pendingMappings = null;
    }
  }

  /// Load and parse JSON from asset
  Future<Map<String, dynamic>> _loadJsonFromAsset(String path) async {
    final jsonString = await rootBundle.loadString(path);
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  /// Clear all caches (useful for testing)
  static void clearCache() {
    _strengthStandardsJson = null;
    _exerciseMappingsJson = null;
    _strengthStandardsCache = null;
    _exerciseMappingsCache = null;
    _pendingStandards = null;
    _pendingMappings = null;
  }
}

/// Exception thrown when strength standards fail to load
class StrengthStandardsLoadException implements Exception {
  StrengthStandardsLoadException(this.message);
  final String message;

  @override
  String toString() => 'StrengthStandardsLoadException: $message';
}

/// Exception thrown when exercise mappings fail to load
class ExerciseMappingsLoadException implements Exception {
  ExerciseMappingsLoadException(this.message);
  final String message;

  @override
  String toString() => 'ExerciseMappingsLoadException: $message';
}

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/exercise_mapping.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/strength_standard.dart';

/// Local datasource for loading strength standards and exercise mappings from assets.
///
/// Loads JSON files bundled with the app:
/// - assets/data/strength_standards.json (25 standards)
/// - assets/data/exercise_mappings.json (1501 exercise mappings)
class StrengthStandardsLocalDataSource {
  static const _strengthStandardsPath = 'assets/data/strength_standards.json';
  static const _exerciseMappingsPath = 'assets/data/exercise_mappings.json';

  /// Load all strength standards from assets
  Future<List<StrengthStandard>> loadStrengthStandards() async {
    try {
      final jsonString = await rootBundle.loadString(_strengthStandardsPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final standardsList = jsonData['standards'] as List<dynamic>;

      return standardsList
          .map((e) => StrengthStandard.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw StrengthStandardsLoadException(
        'Failed to load strength standards: $e',
      );
    }
  }

  /// Load all exercise mappings from assets
  Future<List<ExerciseMapping>> loadExerciseMappings() async {
    try {
      final jsonString = await rootBundle.loadString(_exerciseMappingsPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final mappingsList = jsonData['mappings'] as List<dynamic>;

      return mappingsList
          .map((e) => ExerciseMapping.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ExerciseMappingsLoadException(
        'Failed to load exercise mappings: $e',
      );
    }
  }

  /// Load metadata from strength standards file
  Future<Map<String, dynamic>> loadStrengthStandardsMetadata() async {
    try {
      final jsonString = await rootBundle.loadString(_strengthStandardsPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      return {
        'version': jsonData['version'] as String?,
        'lastUpdated': jsonData['lastUpdated'] as String?,
        'totalStandards': (jsonData['standards'] as List).length,
      };
    } catch (e) {
      throw StrengthStandardsLoadException('Failed to load metadata: $e');
    }
  }

  /// Load metadata from exercise mappings file
  Future<Map<String, dynamic>> loadExerciseMappingsMetadata() async {
    try {
      final jsonString = await rootBundle.loadString(_exerciseMappingsPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      return {
        'version': jsonData['version'] as String?,
        'generated': jsonData['generated'] as String?,
        'model': jsonData['model'] as String?,
        'statistics': jsonData['statistics'] as Map<String, dynamic>?,
      };
    } catch (e) {
      throw ExerciseMappingsLoadException('Failed to load metadata: $e');
    }
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

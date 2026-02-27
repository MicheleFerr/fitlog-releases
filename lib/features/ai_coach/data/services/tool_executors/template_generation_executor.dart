/// Template generation tool executor for AI Coach
///
/// Handles: generateTemplate.
///
/// **Layer**: Data - Service
/// **Feature**: AI Coach
library;

import 'dart:convert';

import 'package:flutter/widgets.dart' show Locale;
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_template.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_search_service.dart';

import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/tool_executor_helpers.dart' as h;

class TemplateGenerationExecutor {
  TemplateGenerationExecutor({
    required this.exerciseSearchService,
    this.locale,
  });

  final ExerciseSearchService exerciseSearchService;
  final Locale? locale;

  Future<String> generateTemplate(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final muscleGroup = args['muscleGroup'] as String? ?? 'full_body';
    final difficulty = args['difficulty'] as String? ?? 'intermediate';

    final durationRaw = args['durationMinutes'];
    final duration = durationRaw is num
        ? durationRaw.toInt()
        : int.tryParse(durationRaw?.toString() ?? '45') ?? 45;

    final equipment = args['equipment'] as String? ?? 'all';

    try {
      // 1. Determine exercise count by difficulty
      final exerciseCount = switch (difficulty) {
        'beginner' => 3,
        'intermediate' => 5,
        'advanced' => 6,
        _ => 4,
      };

      // 2. Determine sets/reps by difficulty
      final setsPerExercise = difficulty == 'beginner' ? 3 : 4;
      final repsRange = switch (difficulty) {
        'beginner' => '10-12',
        'intermediate' => '8-12',
        'advanced' => '6-10',
        _ => '8-12',
      };

      // 3. Search exercises from database using muscle group
      // This uses the JSON 'focus' field for anatomically correct results
      final allResults = await exerciseSearchService.searchExercises(
        muscleGroup,
        locale,
      );

      // 4. Filter by equipment if specified
      final filteredResults = _filterByEquipment(allResults, equipment);

      // 5. Select diverse exercises (avoid duplicates and similar names)
      final selectedExercises = h.selectDiverseExercises(
        filteredResults,
        exerciseCount,
      );

      final exercises = selectedExercises.map((ex) {
        return {
          'name': ex.name,
          'category': ex.category.name,
          'muscles': ex.muscleGroups.take(2).toList(),
          'sets': setsPerExercise,
          'reps': repsRange,
          'restSeconds': _getRestForDifficulty(difficulty),
        };
      }).toList();

      // 6. Calculate estimated duration
      final estimatedMinutes =
          exercises.length * setsPerExercise * 2; // ~2 min per set

      return jsonEncode({
        'templateName': _generateTemplateName(muscleGroup, difficulty),
        'muscleGroup': muscleGroup,
        'difficulty': difficulty,
        'requestedDuration': duration,
        'estimatedDuration': estimatedMinutes,
        'exerciseCount': exercises.length,
        'exercises': exercises,
        'equipment': equipment,
        'notes': 'Piano generato dall\'AI Coach basato su scienza dello sport',
      });
    } catch (e, stackTrace) {
      await h.recordToolError(
        e,
        stackTrace,
        reason: 'AI Coach tool execution failed: generateTemplate',
      );

      return jsonEncode({
        'error': 'Exception: $e',
        'toolName': 'generateTemplate',
      });
    }
  }

  /// Filter exercises by equipment type
  List<ExerciseDefinitionTemplate> _filterByEquipment(
    List<ExerciseDefinitionTemplate> exercises,
    String equipment,
  ) {
    if (equipment == 'all') return exercises;

    final equipmentKeywords = switch (equipment) {
      'bodyweight' ||
      'home' => ['corpo libero', 'bodyweight', 'nessuna', 'body weight'],
      'dumbbell' => ['manubri', 'dumbbell', 'manubrio'],
      'barbell' => ['bilanciere', 'barbell'],
      'cables' => ['cavi', 'cable', 'pulley'],
      _ => <String>[],
    };

    if (equipmentKeywords.isEmpty) return exercises;

    return exercises.where((ex) {
      final equipmentStr = ex.equipment.join(' ').toLowerCase();
      return equipmentKeywords.any((kw) => equipmentStr.contains(kw));
    }).toList();
  }

  /// Generate a descriptive template name
  String _generateTemplateName(String muscleGroup, String difficulty) {
    final groupName = switch (muscleGroup) {
      'chest' => 'Petto',
      'back' => 'Schiena',
      'legs' => 'Gambe',
      'shoulders' => 'Spalle',
      'arms' => 'Braccia',
      'push' => 'Push',
      'pull' => 'Pull',
      'upper' => 'Upper Body',
      'lower' => 'Lower Body',
      'full_body' => 'Full Body',
      _ => muscleGroup,
    };

    final levelName = switch (difficulty) {
      'beginner' => 'Principiante',
      'intermediate' => 'Intermedio',
      'advanced' => 'Avanzato',
      _ => difficulty,
    };

    return '$groupName - $levelName';
  }

  /// Get rest time based on difficulty
  int _getRestForDifficulty(String difficulty) {
    return switch (difficulty) {
      'beginner' => 90,
      'intermediate' => 75,
      'advanced' => 60,
      _ => 75,
    };
  }
}

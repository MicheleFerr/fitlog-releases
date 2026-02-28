/// Template query executor for AI Coach
///
/// Handles: getUserTemplates, getTemplateDetails.
///
/// **Layer**: Data - Service
/// **Feature**: AI Coach
library;

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_search_service.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/template_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';

import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/tool_executor_helpers.dart'
    as h;

class TemplateQueryExecutor {
  TemplateQueryExecutor({
    required this.templateRepo,
    required this.exerciseSearchService,
    this.locale,
  });

  final TemplateRepository templateRepo;
  final ExerciseSearchService exerciseSearchService;
  final Locale? locale;

  Future<String> getUserTemplates(
    Map<String, dynamic> args,
    String userId,
  ) async {
    try {
      final templates = await templateRepo.getUserTemplates();
      if (templates.isEmpty) {
        return jsonEncode({'message': 'Nessun template salvato', 'count': 0});
      }

      Map<String, int> emptyDistribution() => {
        'chest': 0,
        'back': 0,
        'shoulders': 0,
        'arms': 0,
        'legs': 0,
        'core': 0,
        'cardio': 0,
        'other': 0,
      };

      String bucketForCategory(ExerciseCategory category) {
        return switch (category) {
          ExerciseCategory.chest => 'chest',
          ExerciseCategory.back => 'back',
          ExerciseCategory.shoulders => 'shoulders',
          ExerciseCategory.arms => 'arms',
          ExerciseCategory.legs => 'legs',
          ExerciseCategory.abs => 'core',
          ExerciseCategory.cardio => 'cardio',
          ExerciseCategory.other => 'other',
        };
      }

      Map<String, int> buildSetDistribution(List<Exercise> exercises) {
        final distribution = emptyDistribution();
        for (final ex in exercises) {
          final bucket = bucketForCategory(ex.category);
          final sets = ex.sets.isNotEmpty ? ex.sets.length : 1;
          distribution[bucket] = (distribution[bucket] ?? 0) + sets;
        }
        return distribution;
      }

      List<String> topFocus(Map<String, int> distribution, {int take = 2}) {
        final ordered = distribution.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        return ordered
            .where((e) => e.value > 0)
            .take(take)
            .map((e) => e.key)
            .toList();
      }

      final category = args['category'] as String?;

      // Filter by category if provided
      final filtered = category != null
          ? templates
                .where(
                  (t) =>
                      t.category.name.toLowerCase() == category.toLowerCase(),
                )
                .toList()
          : templates;

      if (filtered.isEmpty && category != null) {
        return jsonEncode({
          'message': 'Nessun template trovato per categoria "$category"',
          'availableCategories': templates
              .map((t) => t.category.name)
              .toSet()
              .toList(),
          'suggestions': templates.map((t) => t.name).take(6).toList(),
          'count': 0,
        });
      }

      final templateSuggestions = filtered.map((t) => t.name).take(8).toList();
      final templateList = filtered.take(10).map((t) {
        final totalSets = t.exercises.fold<int>(
          0,
          (sum, ex) => sum + ex.sets.length,
        );
        final estimatedMinutes = totalSets * 2;
        final exerciseNames = t.exercises.map((ex) => ex.name).toList();
        final previewCount = exerciseNames.length > 6
            ? 6
            : exerciseNames.length;
        final distribution = buildSetDistribution(t.exercises);
        final primaryFocus = topFocus(distribution);

        return {
          'name': t.name,
          'category': t.category.name,
          'exerciseCount': t.exercises.length,
          'totalSets': totalSets,
          'estimatedDuration': t.estimatedDurationMinutes ?? estimatedMinutes,
          'targetMuscles': t.targetMuscles.take(3).toList(),
          'exercisePreview': exerciseNames.take(previewCount).toList(),
          'remainingExercises': exerciseNames.length - previewCount,
          'setDistribution': distribution,
          'primaryFocus': primaryFocus,
        };
      }).toList();

      final aggregateAll = emptyDistribution();
      for (final template in templates) {
        final distribution = buildSetDistribution(template.exercises);
        for (final entry in distribution.entries) {
          aggregateAll[entry.key] =
              (aggregateAll[entry.key] ?? 0) + entry.value;
        }
      }
      final totalAllSets = aggregateAll.values.fold<int>(0, (a, b) => a + b);
      final aggregateAllPercent = {
        for (final entry in aggregateAll.entries)
          entry.key: totalAllSets == 0
              ? 0.0
              : ((entry.value / totalAllSets) * 100).toStringAsFixed(1),
      };
      final upperAll =
          (aggregateAll['chest'] ?? 0) +
          (aggregateAll['back'] ?? 0) +
          (aggregateAll['shoulders'] ?? 0) +
          (aggregateAll['arms'] ?? 0);
      final lowerAll = aggregateAll['legs'] ?? 0;
      final upperLowerRatioAll = lowerAll > 0 ? upperAll / lowerAll : null;
      final upperLowerStatusAll = upperLowerRatioAll == null
          ? 'insufficient_data'
          : upperLowerRatioAll > 1.7
          ? 'upper_dominant'
          : upperLowerRatioAll < 0.7
          ? 'lower_dominant'
          : 'balanced';

      final aggregateFiltered = emptyDistribution();
      for (final template in filtered) {
        final distribution = buildSetDistribution(template.exercises);
        for (final entry in distribution.entries) {
          aggregateFiltered[entry.key] =
              (aggregateFiltered[entry.key] ?? 0) + entry.value;
        }
      }
      final totalFilteredSets = aggregateFiltered.values.fold<int>(
        0,
        (a, b) => a + b,
      );

      final nameTokens = templates.map((t) => t.name.toLowerCase()).toList();
      final hasUpperToken = nameTokens.any(
        (n) => n.contains('upper') || n.contains('push') || n.contains('pull'),
      );
      final hasLowerToken = nameTokens.any(
        (n) => n.contains('lower') || n.contains('leg') || n.contains('gambe'),
      );
      final splitLikely =
          templates.length >= 2 && hasUpperToken && hasLowerToken;

      return jsonEncode({
        'templates': templateList,
        'count': templates.length,
        'showing': templateList.length,
        'suggestions': templateSuggestions,
        'analysisFramework': {
          'singleTemplateScope':
              'Valuta ogni template come seduta specifica (non come programma completo).',
          'globalScope':
              'Valuta eventuali squilibri solo sommando tutti i template usati in rotazione.',
          'splitDetected': splitLikely,
        },
        'aggregateBalanceAllTemplates': {
          'setDistribution': aggregateAll,
          'setDistributionPercent': aggregateAllPercent,
          'totalSets': totalAllSets,
          'upperLowerRatio': upperLowerRatioAll,
          'upperLowerStatus': upperLowerStatusAll,
          'topFocus': topFocus(aggregateAll, take: 3),
        },
        'aggregateBalanceSelection': {
          'setDistribution': aggregateFiltered,
          'totalSets': totalFilteredSets,
          'selectionCount': filtered.length,
          if (category != null) 'categoryFilter': category,
        },
        'detailHint':
            'Usa getTemplateDetails(templateName) per analizzare serie/ripetizioni/recuperi completi.',
      });
    } catch (e, st) {
      await h.recordToolError(e, st, reason: 'getUserTemplates failed');
      return jsonEncode({'error': '$e'});
    }
  }

  Future<String> getTemplateDetails(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final templateName = args['templateName'] as String?;
    if (templateName == null || templateName.isEmpty) {
      try {
        final templates = await templateRepo.getUserTemplates();
        if (templates.isNotEmpty) {
          final templateNames = templates.map((t) => t.name).take(8).toList();
          return jsonEncode({
            'disambiguation': true,
            'query': 'template',
            'message': 'Scegli il template da analizzare',
            'options': templateNames.map((name) => {'name': name}).toList(),
            'suggestions': templateNames,
            'toolName': 'getTemplateDetails',
          });
        }
      } catch (_) {
        // Fallback to base error.
      }
      return jsonEncode({'error': 'Nome template richiesto'});
    }

    try {
      final templates = await templateRepo.getUserTemplates();
      if (templates.isEmpty) {
        return jsonEncode({
          'error': 'Nessun template salvato',
          'suggestion': 'Crea prima un template di allenamento',
        });
      }

      // Find template by name (case-insensitive, partial match)
      final searchName = templateName.toLowerCase();
      final matchingTemplate = templates.firstWhereOrNull(
        (t) =>
            t.name.toLowerCase().contains(searchName) ||
            searchName.contains(t.name.toLowerCase()),
      );

      if (matchingTemplate == null) {
        // Return available templates for suggestion
        final availableNames = templates.map((t) => t.name).take(5).toList();
        return jsonEncode({
          'error': 'Template "$templateName" non trovato',
          'availableTemplates': availableNames,
          'suggestions': availableNames,
          'suggestion':
              'Prova con uno di questi nomi: ${availableNames.join(", ")}',
        });
      }

      // Build detailed exercise list
      final exerciseDetails = matchingTemplate.exercises.map((ex) {
        // Get default sets info if available
        final setsCount = ex.sets.length;
        final repsInfo = setsCount > 0
            ? ex.sets.map((s) => s.reps).whereType<int>().toList()
            : <int>[];
        final avgReps = repsInfo.isNotEmpty
            ? (repsInfo.reduce((a, b) => a + b) / repsInfo.length).round()
            : null;

        return {
          'name': ex.name,
          'category': ex.category.name,
          'sets': setsCount,
          'reps': avgReps ?? 'non configurato',
          'restSeconds': ex.restTime ?? 'non configurato',
          'notes': ex.notes,
        };
      }).toList();

      // Calculate estimated duration
      final totalSets = matchingTemplate.exercises.fold<int>(
        0,
        (sum, ex) => sum + ex.sets.length,
      );
      final estimatedMinutes = totalSets * 2; // ~2 min per set
      final setDistribution = <String, int>{
        'chest': 0,
        'back': 0,
        'shoulders': 0,
        'arms': 0,
        'legs': 0,
        'core': 0,
        'cardio': 0,
        'other': 0,
      };
      String bucketForCategory(ExerciseCategory category) {
        return switch (category) {
          ExerciseCategory.chest => 'chest',
          ExerciseCategory.back => 'back',
          ExerciseCategory.shoulders => 'shoulders',
          ExerciseCategory.arms => 'arms',
          ExerciseCategory.legs => 'legs',
          ExerciseCategory.abs => 'core',
          ExerciseCategory.cardio => 'cardio',
          ExerciseCategory.other => 'other',
        };
      }

      for (final ex in matchingTemplate.exercises) {
        final bucket = bucketForCategory(ex.category);
        final sets = ex.sets.isNotEmpty ? ex.sets.length : 1;
        setDistribution[bucket] = (setDistribution[bucket] ?? 0) + sets;
      }
      final primaryFocus = setDistribution.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return jsonEncode({
        'templateName': matchingTemplate.name,
        'category': matchingTemplate.category.name,
        'difficulty': matchingTemplate.difficultyLevel ?? 'non specificato',
        'targetMuscles': matchingTemplate.targetMuscles,
        'exerciseCount': matchingTemplate.exercises.length,
        'totalSets': totalSets,
        'estimatedDuration':
            matchingTemplate.estimatedDurationMinutes ?? estimatedMinutes,
        'exercises': exerciseDetails,
        'setDistribution': setDistribution,
        'primaryFocus': primaryFocus
            .where((entry) => entry.value > 0)
            .take(2)
            .map((entry) => entry.key)
            .toList(),
        'scopeNote':
            'Questo è il bilanciamento interno della singola seduta, non quello dell\'intero programma.',
        'description': matchingTemplate.description,
        'requiredEquipment': matchingTemplate.requiredEquipment,
      });
    } catch (e, st) {
      await h.recordToolError(e, st, reason: 'getTemplateDetails failed');
      return jsonEncode({'error': '$e'});
    }
  }
}

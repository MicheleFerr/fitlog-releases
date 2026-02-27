/// Template CRUD tool executor for AI Coach
///
/// Handles: getUserTemplates, getTemplateDetails, addExerciseToTemplate,
/// replaceExerciseInTemplate, removeExerciseFromTemplate,
/// updateTemplateRestTime, updateTemplateExerciseSetup.
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

import 'package:gymbro_flutter_new/features/ai_coach/data/services/tool_executors/tool_executor_helpers.dart' as h;

class TemplateCrudExecutor {
  TemplateCrudExecutor({
    required this.templateRepo,
    required this.exerciseSearchService,
    this.locale,
  });

  final TemplateRepository templateRepo;
  final ExerciseSearchService exerciseSearchService;
  final Locale? locale;

  Future<String?> _tryGetExerciseImage(String exerciseName) =>
      h.tryGetExerciseImage(exerciseName, exerciseSearchService, locale);

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

  Future<String> addExerciseToTemplate(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final templateName = (args['templateName'] as String?)?.trim();
    final exerciseQuery = (args['exerciseName'] as String?)?.trim();

    if (templateName == null || templateName.isEmpty) {
      try {
        final templates = await templateRepo.getUserTemplates();
        if (templates.isNotEmpty) {
          final templateNames = templates.map((t) => t.name).take(8).toList();
          return jsonEncode({
            'disambiguation': true,
            'query': 'template',
            'message': 'Seleziona il template da modificare',
            'options': templateNames.map((name) => {'name': name}).toList(),
            'suggestions': templateNames,
            'toolName': 'addExerciseToTemplate',
          });
        }
      } catch (_) {
        // Fallback to standard error below.
      }
      return jsonEncode({
        'error': 'Nome template richiesto',
        'toolName': 'addExerciseToTemplate',
      });
    }
    if (exerciseQuery == null || exerciseQuery.isEmpty) {
      return jsonEncode({
        'error': 'Nome esercizio richiesto',
        'toolName': 'addExerciseToTemplate',
      });
    }

    final sets = h.parseBoundedInt(
      args['sets'],
      defaultValue: 3,
      min: 1,
      max: 8,
    );
    final reps = h.parseBoundedInt(
      args['reps'],
      defaultValue: 10,
      min: 3,
      max: 30,
    );
    final restSeconds = h.parseBoundedInt(
      args['restSeconds'],
      defaultValue: 90,
      min: 20,
      max: 300,
    );
    final notes = (args['notes'] as String?)?.trim();
    final allowDuplicate = h.parseBoolFlag(args['allowDuplicate']);
    final confirmed = h.parseBoolFlag(args['confirmed']);

    try {
      final templates = await templateRepo.getUserTemplates();
      if (templates.isEmpty) {
        return jsonEncode({
          'error': 'Nessun template salvato',
          'suggestion': 'Crea prima un template di allenamento',
          'toolName': 'addExerciseToTemplate',
        });
      }

      final searchTemplate = templateName.toLowerCase();
      final templateMatches = templates.where((t) {
        final name = t.name.toLowerCase();
        return name.contains(searchTemplate) || searchTemplate.contains(name);
      }).toList();

      if (templateMatches.isEmpty) {
        final availableNames = templates.map((t) => t.name).take(6).toList();
        return jsonEncode({
          'error': 'Template "$templateName" non trovato',
          'availableTemplates': availableNames,
          'suggestions': availableNames,
          'toolName': 'addExerciseToTemplate',
        });
      }

      final exactTemplateMatch = templateMatches.firstWhereOrNull(
        (t) => t.name.toLowerCase() == searchTemplate,
      );

      if (exactTemplateMatch == null && templateMatches.length > 1) {
        final options = templateMatches
            .take(6)
            .map(
              (t) => {
                'name': t.name,
                'exerciseCount': t.exercises.length,
                'category': t.category.name,
              },
            )
            .toList();
        return jsonEncode({
          'disambiguation': true,
          'query': templateName,
          'options': options,
          'suggestions': options.map((o) => o['name'] as String).toList(),
          'toolName': 'addExerciseToTemplate',
        });
      }

      final selectedTemplate = exactTemplateMatch ?? templateMatches.first;
      final exerciseResults = await exerciseSearchService.searchExercises(
        exerciseQuery,
        locale,
      );

      if (exerciseResults.isEmpty) {
        return jsonEncode({
          'error': 'Esercizio "$exerciseQuery" non trovato nel database',
          'suggestion':
              'Prova con un nome più specifico o usa searchExercises prima',
          'toolName': 'addExerciseToTemplate',
        });
      }

      final normalizedExerciseQuery = exerciseQuery.toLowerCase();
      final exactExerciseMatch = exerciseResults.firstWhereOrNull(
        (ex) => ex.name.toLowerCase() == normalizedExerciseQuery,
      );

      if (confirmed &&
          exactExerciseMatch == null &&
          exerciseResults.length > 1) {
        final exerciseOptions = exerciseResults
            .take(6)
            .map(
              (ex) => {
                'name': ex.name,
                'muscles': ex.muscleGroups.take(3).toList(),
              },
            )
            .toList();
        return jsonEncode({
          'disambiguation': true,
          'query': exerciseQuery,
          'options': exerciseOptions,
          'suggestions': exerciseOptions
              .map((o) => o['name'] as String)
              .toList(),
          'toolName': 'addExerciseToTemplate',
        });
      }

      final selectedExercise = exactExerciseMatch ?? exerciseResults.first;
      final selectedExerciseImage =
          (selectedExercise.imageUrl?.isNotEmpty ?? false)
          ? selectedExercise.imageUrl
          : exerciseResults
                .firstWhereOrNull((ex) => ex.imageUrl?.isNotEmpty ?? false)
                ?.imageUrl;
      final alternativeExercises = h.buildExerciseChoiceCards(
        candidates: exerciseResults,
        commandBuilder: (exercise) {
          return 'Aggiungi "${exercise.name}" al template "${selectedTemplate.name}" '
              'con $sets serie da $reps ripetizioni e $restSeconds secondi di recupero.';
        },
        excludeName: selectedExercise.name,
        limit: 8,
      );

      if (!confirmed) {
        final confirmCommand =
            'Confermo: aggiungi "${selectedExercise.name}" al template "${selectedTemplate.name}" '
            'con $sets serie da $reps ripetizioni e $restSeconds secondi di recupero.';
        return jsonEncode({
          'confirmationRequired': true,
          'templateName': selectedTemplate.name,
          'templateId': selectedTemplate.id,
          'exercise': {
            'name': selectedExercise.name,
            'muscles': selectedExercise.muscleGroups.take(3).toList(),
            'imageUrl': selectedExerciseImage,
          },
          'plannedSetup': {
            'sets': sets,
            'reps': reps,
            'restSeconds': restSeconds,
            if (notes != null && notes.isNotEmpty) 'notes': notes,
          },
          'message':
              'Conferma per aggiungere "${selectedExercise.name}" al template "${selectedTemplate.name}".',
          'suggestedPayload': {
            'templateName': selectedTemplate.name,
            'exerciseName': selectedExercise.name,
            'sets': sets,
            'reps': reps,
            'restSeconds': restSeconds,
            if (notes != null && notes.isNotEmpty) 'notes': notes,
            if (allowDuplicate) 'allowDuplicate': true,
            'confirmed': true,
          },
          'inlineCard': h.buildTemplateActionInlineCard(
            title: 'Anteprima modifica template',
            subtitle:
                'Aggiungere "${selectedExercise.name}" a "${selectedTemplate.name}" ($sets×$reps, $restSeconds s).',
            imageUrl: selectedExerciseImage,
            templateName: selectedTemplate.name,
            exerciseName: selectedExercise.name,
            selectionHint: alternativeExercises.isNotEmpty
                ? 'Puoi anche scegliere un esercizio alternativo qui sotto.'
                : null,
            alternatives: alternativeExercises,
            actions: [
              h.buildTemplateAction(
                label: 'Conferma aggiunta',
                command: confirmCommand,
                actionType: 'add',
                style: 'primary',
              ),
            ],
          ),
          'toolName': 'addExerciseToTemplate',
        });
      }

      final exerciseToAdd = Exercise(
        name: selectedExercise.name,
        type: selectedExercise.type,
        category: selectedExercise.category,
        sets: List.generate(
          sets,
          (index) => ExerciseSet(
            setNumber: index + 1,
            reps: reps,
            restTime: restSeconds,
          ),
        ),
        restTime: restSeconds,
        notes: notes != null && notes.isNotEmpty ? notes : null,
      );

      final updatedTemplate = await templateRepo.addExerciseToTemplate(
        templateId: selectedTemplate.id,
        exercise: exerciseToAdd,
        allowDuplicate: allowDuplicate,
      );

      return jsonEncode({
        'success': true,
        'templateName': updatedTemplate.name,
        'addedExercise': selectedExercise.name,
        'exerciseCount': updatedTemplate.exercises.length,
        'appliedSetup': {
          'sets': sets,
          'reps': reps,
          'restSeconds': restSeconds,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
        'message':
            'Esercizio aggiunto con successo a "${updatedTemplate.name}".',
        'inlineCard': h.buildTemplateActionInlineCard(
          title: 'Template aggiornato',
          subtitle:
              'Aggiunto "${selectedExercise.name}" a "${updatedTemplate.name}".',
          imageUrl: selectedExerciseImage,
          templateName: updatedTemplate.name,
          exerciseName: selectedExercise.name,
          actions: [
            h.buildTemplateAction(
              label: 'Aggiungi altro esercizio',
              command:
                  'Aggiungi un altro esercizio al template "${updatedTemplate.name}".',
              actionType: 'add',
              style: 'primary',
            ),
            h.buildTemplateAction(
              label: 'Sostituisci esercizio esistente',
              command:
                  'Voglio sostituire un esercizio nel template "${updatedTemplate.name}".',
              actionType: 'replace',
            ),
          ],
        ),
        'toolName': 'addExerciseToTemplate',
      });
    } catch (e, st) {
      await h.recordToolError(e, st, reason: 'addExerciseToTemplate failed');

      final rawError = e.toString();
      if (rawError.toLowerCase().contains('already exists in template')) {
        return jsonEncode({
          'error': 'L\'esercizio è già presente nel template',
          'suggestion':
              'Imposta allowDuplicate=true solo se vuoi davvero duplicarlo',
          'toolName': 'addExerciseToTemplate',
        });
      }

      return jsonEncode({
        'error': rawError,
        'toolName': 'addExerciseToTemplate',
      });
    }
  }

  Future<String> replaceExerciseInTemplate(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final templateName = (args['templateName'] as String?)?.trim();
    final oldExerciseQuery = (args['oldExerciseName'] as String?)?.trim();
    final newExerciseQuery = (args['newExerciseName'] as String?)?.trim();

    if (templateName == null || templateName.isEmpty) {
      try {
        final templates = await templateRepo.getUserTemplates();
        if (templates.isNotEmpty) {
          final templateNames = templates.map((t) => t.name).take(8).toList();
          return jsonEncode({
            'disambiguation': true,
            'query': 'template',
            'message': 'Seleziona il template da modificare',
            'options': templateNames.map((name) => {'name': name}).toList(),
            'suggestions': templateNames,
            'toolName': 'replaceExerciseInTemplate',
          });
        }
      } catch (_) {
        // Fallback to standard error below.
      }
      return jsonEncode({
        'error': 'Nome template richiesto',
        'toolName': 'replaceExerciseInTemplate',
      });
    }

    final sets = h.parseBoundedInt(
      args['sets'],
      defaultValue: 3,
      min: 1,
      max: 8,
    );
    final reps = h.parseBoundedInt(
      args['reps'],
      defaultValue: 10,
      min: 3,
      max: 30,
    );
    final restSeconds = h.parseBoundedInt(
      args['restSeconds'],
      defaultValue: 90,
      min: 20,
      max: 300,
    );
    final notes = (args['notes'] as String?)?.trim();
    final confirmed = h.parseBoolFlag(args['confirmed']);

    try {
      final templates = await templateRepo.getUserTemplates();
      if (templates.isEmpty) {
        return jsonEncode({
          'error': 'Nessun template salvato',
          'suggestion': 'Crea prima un template di allenamento',
          'toolName': 'replaceExerciseInTemplate',
        });
      }

      final normalizedTemplateSearch = h.normalizeForMatch(templateName);
      final templateMatches = templates.where((t) {
        final normalized = h.normalizeForMatch(t.name);
        return normalized.contains(normalizedTemplateSearch) ||
            normalizedTemplateSearch.contains(normalized);
      }).toList();

      if (templateMatches.isEmpty) {
        final availableNames = templates.map((t) => t.name).take(6).toList();
        return jsonEncode({
          'error': 'Template "$templateName" non trovato',
          'availableTemplates': availableNames,
          'suggestions': availableNames,
          'toolName': 'replaceExerciseInTemplate',
        });
      }

      final exactTemplateMatch = templateMatches.firstWhereOrNull(
        (t) => h.normalizeForMatch(t.name) == normalizedTemplateSearch,
      );

      if (exactTemplateMatch == null && templateMatches.length > 1) {
        final options = templateMatches
            .take(6)
            .map(
              (t) => {
                'name': t.name,
                'exerciseCount': t.exercises.length,
                'category': t.category.name,
              },
            )
            .toList();
        return jsonEncode({
          'disambiguation': true,
          'query': templateName,
          'options': options,
          'suggestions': options.map((o) => o['name'] as String).toList(),
          'toolName': 'replaceExerciseInTemplate',
        });
      }

      final selectedTemplate = exactTemplateMatch ?? templateMatches.first;
      if (oldExerciseQuery == null || oldExerciseQuery.isEmpty) {
        final options = selectedTemplate.exercises
            .take(10)
            .map((e) => {'name': e.name, 'sets': e.sets.length})
            .toList();
        final suggestions = selectedTemplate.exercises
            .map((e) => e.name)
            .take(10)
            .toList();
        return jsonEncode({
          'disambiguation': true,
          'query': 'esercizio da sostituire',
          'message':
              'Quale esercizio vuoi sostituire nel template "${selectedTemplate.name}"?',
          'options': options,
          'suggestions': suggestions,
          'toolName': 'replaceExerciseInTemplate',
        });
      }

      final oldMatches = h.findTemplateExercisesByQuery(
        selectedTemplate.exercises,
        oldExerciseQuery,
      );

      if (oldMatches.isEmpty) {
        return jsonEncode({
          'error':
              'Esercizio "$oldExerciseQuery" non trovato nel template "${selectedTemplate.name}"',
          'availableExercises': selectedTemplate.exercises
              .map((e) => e.name)
              .take(8)
              .toList(),
          'suggestions': selectedTemplate.exercises
              .map((e) => e.name)
              .take(8)
              .toList(),
          'toolName': 'replaceExerciseInTemplate',
        });
      }

      if (oldMatches.length > 1) {
        return jsonEncode({
          'disambiguation': true,
          'query': oldExerciseQuery,
          'options': oldMatches
              .take(6)
              .map((e) => {'name': e.name, 'sets': e.sets.length})
              .toList(),
          'suggestions': oldMatches.take(6).map((e) => e.name).toList(),
          'toolName': 'replaceExerciseInTemplate',
        });
      }

      final oldExercise = oldMatches.first;
      if (newExerciseQuery == null || newExerciseQuery.isEmpty) {
        final defaultQuery = switch (oldExercise.category) {
          ExerciseCategory.chest => 'petto',
          ExerciseCategory.back => 'schiena',
          ExerciseCategory.shoulders => 'spalle',
          ExerciseCategory.arms => 'braccia',
          ExerciseCategory.legs => 'gambe',
          ExerciseCategory.abs => 'addome',
          ExerciseCategory.cardio => 'cardio',
          ExerciseCategory.other => oldExercise.name,
        };
        final alternatives = await exerciseSearchService.searchExercises(
          defaultQuery,
          locale,
        );
        final options = alternatives
            .where(
              (ex) =>
                  h.normalizeForMatch(ex.name) !=
                  h.normalizeForMatch(oldExercise.name),
            )
            .take(8)
            .map(
              (ex) => {
                'name': ex.name,
                'muscles': ex.muscleGroups.take(3).toList(),
              },
            )
            .toList();
        return jsonEncode({
          'disambiguation': true,
          'query': 'nuovo esercizio',
          'message':
              'Con quale esercizio vuoi sostituire "${oldExercise.name}" in "${selectedTemplate.name}"?',
          'options': options,
          'suggestions': options.map((o) => o['name'] as String).toList(),
          'toolName': 'replaceExerciseInTemplate',
        });
      }

      final newExerciseResults = await exerciseSearchService.searchExercises(
        newExerciseQuery,
        locale,
      );

      if (newExerciseResults.isEmpty) {
        return jsonEncode({
          'error': 'Esercizio "$newExerciseQuery" non trovato nel database',
          'toolName': 'replaceExerciseInTemplate',
        });
      }

      final normalizedNewQuery = h.normalizeForMatch(newExerciseQuery);
      final exactNew = newExerciseResults.firstWhereOrNull(
        (e) => h.normalizeForMatch(e.name) == normalizedNewQuery,
      );
      final newExerciseTemplate = exactNew ?? newExerciseResults.first;
      final newExerciseImage =
          (newExerciseTemplate.imageUrl?.isNotEmpty ?? false)
          ? newExerciseTemplate.imageUrl
          : newExerciseResults
                .firstWhereOrNull((e) => e.imageUrl?.isNotEmpty ?? false)
                ?.imageUrl;
      final replacementAlternatives = h.buildExerciseChoiceCards(
        candidates: newExerciseResults,
        commandBuilder: (exercise) {
          return 'Sostituisci "${oldExercise.name}" con "${exercise.name}" nel template "${selectedTemplate.name}".';
        },
        excludeName: newExerciseTemplate.name,
        limit: 8,
      );

      if (!confirmed) {
        final confirmCommand =
            'Confermo: sostituisci "${oldExercise.name}" con "${newExerciseTemplate.name}" '
            'nel template "${selectedTemplate.name}" con $sets serie da $reps ripetizioni e $restSeconds secondi di recupero.';
        return jsonEncode({
          'confirmationRequired': true,
          'templateName': selectedTemplate.name,
          'oldExercise': oldExercise.name,
          'newExercise': {
            'name': newExerciseTemplate.name,
            'muscles': newExerciseTemplate.muscleGroups.take(3).toList(),
            'imageUrl': newExerciseImage,
          },
          'plannedSetup': {
            'sets': sets,
            'reps': reps,
            'restSeconds': restSeconds,
            if (notes != null && notes.isNotEmpty) 'notes': notes,
          },
          'suggestedPayload': {
            'templateName': selectedTemplate.name,
            'oldExerciseName': oldExercise.name,
            'newExerciseName': newExerciseTemplate.name,
            'sets': sets,
            'reps': reps,
            'restSeconds': restSeconds,
            if (notes != null && notes.isNotEmpty) 'notes': notes,
            'confirmed': true,
          },
          'inlineCard': h.buildTemplateActionInlineCard(
            title: 'Anteprima sostituzione',
            subtitle:
                '"${oldExercise.name}" → "${newExerciseTemplate.name}" in "${selectedTemplate.name}".',
            imageUrl: newExerciseImage,
            templateName: selectedTemplate.name,
            exerciseName: newExerciseTemplate.name,
            selectionHint: replacementAlternatives.isNotEmpty
                ? 'Se vuoi, scegli una sostituzione alternativa qui sotto.'
                : null,
            alternatives: replacementAlternatives,
            actions: [
              h.buildTemplateAction(
                label: 'Conferma sostituzione',
                command: confirmCommand,
                actionType: 'replace',
                style: 'primary',
              ),
            ],
          ),
          'toolName': 'replaceExerciseInTemplate',
        });
      }

      final replacementExercise = Exercise(
        name: newExerciseTemplate.name,
        type: newExerciseTemplate.type,
        category: newExerciseTemplate.category,
        sets: List.generate(
          sets,
          (index) => ExerciseSet(
            setNumber: index + 1,
            reps: reps,
            restTime: restSeconds,
          ),
        ),
        restTime: restSeconds,
        notes: notes != null && notes.isNotEmpty ? notes : null,
      );

      final updatedTemplate = await templateRepo.replaceExerciseInTemplate(
        templateId: selectedTemplate.id,
        oldExerciseName: oldExercise.name,
        newExercise: replacementExercise,
      );

      return jsonEncode({
        'success': true,
        'templateName': updatedTemplate.name,
        'oldExercise': oldExercise.name,
        'newExercise': newExerciseTemplate.name,
        'exerciseCount': updatedTemplate.exercises.length,
        'message':
            'Sostituzione completata: "${oldExercise.name}" → "${newExerciseTemplate.name}".',
        'inlineCard': h.buildTemplateActionInlineCard(
          title: 'Sostituzione completata',
          subtitle:
              '"${oldExercise.name}" sostituito con "${newExerciseTemplate.name}".',
          imageUrl: newExerciseImage,
          templateName: updatedTemplate.name,
          exerciseName: newExerciseTemplate.name,
          actions: [
            h.buildTemplateAction(
              label: 'Aggiungi nuovo esercizio',
              command:
                  'Aggiungi "${newExerciseTemplate.name}" al template "${updatedTemplate.name}".',
              actionType: 'add',
            ),
            h.buildTemplateAction(
              label: 'Sostituisci un altro esercizio',
              command:
                  'Sostituisci un altro esercizio nel template "${updatedTemplate.name}".',
              actionType: 'replace',
              style: 'primary',
            ),
          ],
        ),
        'toolName': 'replaceExerciseInTemplate',
      });
    } catch (e, st) {
      await h.recordToolError(
        e,
        st,
        reason: 'replaceExerciseInTemplate failed',
      );
      return jsonEncode({
        'error': e.toString(),
        'toolName': 'replaceExerciseInTemplate',
      });
    }
  }

  Future<String> removeExerciseFromTemplate(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final templateName = (args['templateName'] as String?)?.trim();
    final exerciseQuery = (args['exerciseName'] as String?)?.trim();
    if (templateName == null || templateName.isEmpty) {
      try {
        final templates = await templateRepo.getUserTemplates();
        if (templates.isNotEmpty) {
          final templateNames = templates.map((t) => t.name).take(8).toList();
          return jsonEncode({
            'disambiguation': true,
            'query': 'template',
            'message': 'Seleziona il template da modificare',
            'options': templateNames.map((name) => {'name': name}).toList(),
            'suggestions': templateNames,
            'toolName': 'removeExerciseFromTemplate',
          });
        }
      } catch (_) {
        // Fallback to standard error below.
      }
      return jsonEncode({
        'error': 'Nome template richiesto',
        'toolName': 'removeExerciseFromTemplate',
      });
    }

    final removeAllMatches = h.parseBoolFlag(args['removeAllMatches']);
    final confirmed = h.parseBoolFlag(args['confirmed']);

    try {
      final templates = await templateRepo.getUserTemplates();
      if (templates.isEmpty) {
        return jsonEncode({
          'error': 'Nessun template salvato',
          'toolName': 'removeExerciseFromTemplate',
        });
      }

      final normalizedTemplateSearch = h.normalizeForMatch(templateName);
      final templateMatches = templates.where((t) {
        final normalized = h.normalizeForMatch(t.name);
        return normalized.contains(normalizedTemplateSearch) ||
            normalizedTemplateSearch.contains(normalized);
      }).toList();

      if (templateMatches.isEmpty) {
        final availableNames = templates.map((t) => t.name).take(6).toList();
        return jsonEncode({
          'error': 'Template "$templateName" non trovato',
          'availableTemplates': availableNames,
          'suggestions': availableNames,
          'toolName': 'removeExerciseFromTemplate',
        });
      }

      final exactTemplateMatch = templateMatches.firstWhereOrNull(
        (t) => h.normalizeForMatch(t.name) == normalizedTemplateSearch,
      );

      if (exactTemplateMatch == null && templateMatches.length > 1) {
        final options = templateMatches
            .take(6)
            .map((t) => {'name': t.name, 'exerciseCount': t.exercises.length})
            .toList();
        return jsonEncode({
          'disambiguation': true,
          'query': templateName,
          'options': options,
          'suggestions': options.map((o) => o['name'] as String).toList(),
          'toolName': 'removeExerciseFromTemplate',
        });
      }

      final selectedTemplate = exactTemplateMatch ?? templateMatches.first;
      if (exerciseQuery == null || exerciseQuery.isEmpty) {
        final options = selectedTemplate.exercises
            .take(10)
            .map((e) => {'name': e.name, 'sets': e.sets.length})
            .toList();
        final suggestions = selectedTemplate.exercises
            .map((e) => e.name)
            .take(10)
            .toList();
        return jsonEncode({
          'disambiguation': true,
          'query': 'esercizio da rimuovere',
          'message':
              'Quale esercizio vuoi rimuovere dal template "${selectedTemplate.name}"?',
          'options': options,
          'suggestions': suggestions,
          'toolName': 'removeExerciseFromTemplate',
        });
      }

      final matches = h.findTemplateExercisesByQuery(
        selectedTemplate.exercises,
        exerciseQuery,
      );
      if (matches.isEmpty) {
        return jsonEncode({
          'error':
              'Esercizio "$exerciseQuery" non trovato nel template "${selectedTemplate.name}"',
          'availableExercises': selectedTemplate.exercises
              .map((e) => e.name)
              .take(8)
              .toList(),
          'suggestions': selectedTemplate.exercises
              .map((e) => e.name)
              .take(8)
              .toList(),
          'toolName': 'removeExerciseFromTemplate',
        });
      }

      if (!removeAllMatches && matches.length > 1) {
        return jsonEncode({
          'disambiguation': true,
          'query': exerciseQuery,
          'options': matches
              .take(6)
              .map((e) => {'name': e.name, 'sets': e.sets.length})
              .toList(),
          'suggestions': matches.take(6).map((e) => e.name).toList(),
          'toolName': 'removeExerciseFromTemplate',
        });
      }

      final exerciseToRemove = matches.first;
      final imageUrl = await _tryGetExerciseImage(exerciseToRemove.name);

      if (!confirmed) {
        final confirmCommand =
            'Confermo: rimuovi "${exerciseToRemove.name}" dal template "${selectedTemplate.name}".';
        return jsonEncode({
          'confirmationRequired': true,
          'templateName': selectedTemplate.name,
          'exerciseName': exerciseToRemove.name,
          'removeAllMatches': removeAllMatches,
          'message':
              'Conferma per rimuovere "${exerciseToRemove.name}" da "${selectedTemplate.name}".',
          'suggestedPayload': {
            'templateName': selectedTemplate.name,
            'exerciseName': exerciseToRemove.name,
            if (removeAllMatches) 'removeAllMatches': true,
            'confirmed': true,
          },
          'inlineCard': h.buildTemplateActionInlineCard(
            title: 'Anteprima rimozione',
            subtitle:
                'Rimuovere "${exerciseToRemove.name}" da "${selectedTemplate.name}".',
            imageUrl: imageUrl,
            templateName: selectedTemplate.name,
            exerciseName: exerciseToRemove.name,
            actions: [
              h.buildTemplateAction(
                label: 'Conferma rimozione',
                command: confirmCommand,
                actionType: 'remove',
                style: 'danger',
              ),
            ],
          ),
          'toolName': 'removeExerciseFromTemplate',
        });
      }

      final updatedTemplate = await templateRepo.removeExerciseFromTemplate(
        templateId: selectedTemplate.id,
        exerciseName: exerciseToRemove.name,
        removeAllMatches: removeAllMatches,
      );

      return jsonEncode({
        'success': true,
        'templateName': updatedTemplate.name,
        'removedExercise': exerciseToRemove.name,
        'exerciseCount': updatedTemplate.exercises.length,
        'message':
            'Esercizio "${exerciseToRemove.name}" rimosso da "${updatedTemplate.name}".',
        'inlineCard': h.buildTemplateActionInlineCard(
          title: 'Rimozione completata',
          subtitle:
              '"${exerciseToRemove.name}" rimosso da "${updatedTemplate.name}".',
          imageUrl: imageUrl,
          templateName: updatedTemplate.name,
          exerciseName: exerciseToRemove.name,
          actions: [
            h.buildTemplateAction(
              label: 'Aggiungi nuovo esercizio',
              command:
                  'Aggiungi un nuovo esercizio al template "${updatedTemplate.name}".',
              actionType: 'add',
              style: 'primary',
            ),
            h.buildTemplateAction(
              label: 'Sostituisci esercizio',
              command:
                  'Sostituisci un esercizio nel template "${updatedTemplate.name}".',
              actionType: 'replace',
            ),
            h.buildTemplateAction(
              label: 'Rimuovi un altro esercizio',
              command:
                  'Rimuovi un altro esercizio dal template "${updatedTemplate.name}".',
              actionType: 'remove',
            ),
          ],
        ),
        'toolName': 'removeExerciseFromTemplate',
      });
    } catch (e, st) {
      await h.recordToolError(
        e,
        st,
        reason: 'removeExerciseFromTemplate failed',
      );
      return jsonEncode({
        'error': e.toString(),
        'toolName': 'removeExerciseFromTemplate',
      });
    }
  }

  Future<String> updateTemplateRestTime(
    Map<String, dynamic> args,
    String userId,
  ) async {
    final templateName = (args['templateName'] as String?)?.trim();
    final exerciseQuery = (args['exerciseName'] as String?)?.trim();
    final applyToAllExercises = h.parseBoolFlag(args['applyToAllExercises']);
    final updateAllMatches = h.parseBoolFlag(args['updateAllMatches']);
    final confirmed = h.parseBoolFlag(args['confirmed']);

    final explicitRestSeconds = args.containsKey('restSeconds')
        ? h.parseBoundedInt(
            args['restSeconds'],
            defaultValue: 90,
            min: 20,
            max: 300,
          )
        : null;

    final deltaRaw = args['deltaSeconds'];
    final parsedDelta = deltaRaw is num
        ? deltaRaw.toInt()
        : int.tryParse(deltaRaw?.toString() ?? '');
    final deltaSeconds = parsedDelta?.clamp(-120, 120);

    if (templateName == null || templateName.isEmpty) {
      try {
        final templates = await templateRepo.getUserTemplates();
        if (templates.isNotEmpty) {
          final templateNames = templates.map((t) => t.name).take(8).toList();
          return jsonEncode({
            'disambiguation': true,
            'query': 'template',
            'message': 'Seleziona il template da modificare',
            'options': templateNames.map((name) => {'name': name}).toList(),
            'suggestions': templateNames,
            'toolName': 'updateTemplateRestTime',
          });
        }
      } catch (_) {
        // Fallback to standard error below.
      }
      return jsonEncode({
        'error': 'Nome template richiesto',
        'toolName': 'updateTemplateRestTime',
      });
    }

    try {
      final templates = await templateRepo.getUserTemplates();
      if (templates.isEmpty) {
        return jsonEncode({
          'error': 'Nessun template salvato',
          'suggestion': 'Crea prima un template di allenamento',
          'toolName': 'updateTemplateRestTime',
        });
      }

      final normalizedTemplateSearch = h.normalizeForMatch(templateName);
      final templateMatches = templates.where((t) {
        final normalized = h.normalizeForMatch(t.name);
        return normalized.contains(normalizedTemplateSearch) ||
            normalizedTemplateSearch.contains(normalized);
      }).toList();

      if (templateMatches.isEmpty) {
        final availableNames = templates.map((t) => t.name).take(6).toList();
        return jsonEncode({
          'error': 'Template "$templateName" non trovato',
          'availableTemplates': availableNames,
          'suggestions': availableNames,
          'toolName': 'updateTemplateRestTime',
        });
      }

      final exactTemplateMatch = templateMatches.firstWhereOrNull(
        (t) => h.normalizeForMatch(t.name) == normalizedTemplateSearch,
      );

      if (exactTemplateMatch == null && templateMatches.length > 1) {
        final options = templateMatches
            .take(6)
            .map(
              (t) => {
                'name': t.name,
                'exerciseCount': t.exercises.length,
                'category': t.category.name,
              },
            )
            .toList();
        return jsonEncode({
          'disambiguation': true,
          'query': templateName,
          'options': options,
          'suggestions': options.map((o) => o['name'] as String).toList(),
          'toolName': 'updateTemplateRestTime',
        });
      }

      final selectedTemplate = exactTemplateMatch ?? templateMatches.first;
      if (selectedTemplate.exercises.isEmpty) {
        return jsonEncode({
          'error': 'Template "${selectedTemplate.name}" non ha esercizi',
          'toolName': 'updateTemplateRestTime',
        });
      }

      int currentRest;
      String targetLabel;
      String? imageUrl;
      Exercise? selectedExercise;

      if (applyToAllExercises) {
        final restValues = selectedTemplate.exercises
            .map((e) => e.restTime)
            .whereType<int>()
            .toList();
        currentRest = restValues.isNotEmpty
            ? (restValues.reduce((a, b) => a + b) / restValues.length).round()
            : 90;
        targetLabel = 'tutti gli esercizi';
      } else {
        if (exerciseQuery == null || exerciseQuery.isEmpty) {
          final options = selectedTemplate.exercises
              .take(8)
              .map((e) => {'name': e.name, 'restSeconds': e.restTime ?? 90})
              .toList();
          final suggestions = selectedTemplate.exercises
              .map((e) => e.name)
              .take(8)
              .toList();
          return jsonEncode({
            'disambiguation': true,
            'query': 'esercizio',
            'message':
                'Quale esercizio vuoi aggiornare nel template "${selectedTemplate.name}"?',
            'options': options,
            'suggestions': suggestions,
            'toolName': 'updateTemplateRestTime',
          });
        }

        final matches = h.findTemplateExercisesByQuery(
          selectedTemplate.exercises,
          exerciseQuery,
        );
        if (matches.isEmpty) {
          return jsonEncode({
            'error':
                'Esercizio "$exerciseQuery" non trovato nel template "${selectedTemplate.name}"',
            'availableExercises': selectedTemplate.exercises
                .map((e) => e.name)
                .take(8)
                .toList(),
            'suggestions': selectedTemplate.exercises
                .map((e) => e.name)
                .take(8)
                .toList(),
            'toolName': 'updateTemplateRestTime',
          });
        }

        if (matches.length > 1 && !updateAllMatches) {
          return jsonEncode({
            'disambiguation': true,
            'query': exerciseQuery,
            'options': matches
                .take(6)
                .map(
                  (e) => {
                    'name': e.name,
                    'sets': e.sets.length,
                    'restSeconds': e.restTime ?? 90,
                  },
                )
                .toList(),
            'suggestions': matches.take(6).map((e) => e.name).toList(),
            'toolName': 'updateTemplateRestTime',
          });
        }

        selectedExercise = matches.first;
        currentRest = selectedExercise.restTime ?? 90;
        targetLabel = selectedExercise.name;
        imageUrl = await _tryGetExerciseImage(selectedExercise.name);
      }

      int recommendedRestForTemplate(int baseline) {
        final normalizedName = h.normalizeForMatch(selectedTemplate.name);
        final category = selectedTemplate.category.name.toLowerCase();
        final isPower =
            normalizedName.contains('power') ||
            normalizedName.contains('strength') ||
            normalizedName.contains('forza') ||
            category == 'strength' ||
            category == 'powerlifting';
        final isHypertrophy =
            normalizedName.contains('hypertrophy') ||
            normalizedName.contains('ipertrof') ||
            category == 'hypertrophy' ||
            category == 'bodybuilding';

        if (isPower) return 180;
        if (isHypertrophy) return 90;
        return baseline.clamp(60, 150);
      }

      var targetRest =
          explicitRestSeconds ?? recommendedRestForTemplate(currentRest);
      if (deltaSeconds != null) {
        final startingPoint = explicitRestSeconds ?? currentRest;
        targetRest = (startingPoint + deltaSeconds).clamp(20, 300).toInt();
      }
      targetRest = targetRest.clamp(20, 300).toInt();

      String buildUpdateCommand(int seconds) {
        final safeSeconds = seconds.clamp(20, 300);
        if (applyToAllExercises) {
          return 'Confermo: imposta il recupero di tutti gli esercizi nel template "${selectedTemplate.name}" a $safeSeconds secondi.';
        }
        return 'Confermo: imposta il recupero di "$targetLabel" nel template "${selectedTemplate.name}" a $safeSeconds secondi.';
      }

      final suggestedPayload = <String, dynamic>{
        'templateName': selectedTemplate.name,
        if (!applyToAllExercises) 'exerciseName': targetLabel,
        if (applyToAllExercises) 'applyToAllExercises': true,
        if (updateAllMatches) 'updateAllMatches': true,
        'restSeconds': targetRest,
        'confirmed': true,
      };

      if (!confirmed) {
        return jsonEncode({
          'confirmationRequired': true,
          'templateName': selectedTemplate.name,
          'target': targetLabel,
          'currentRestSeconds': currentRest,
          'proposedRestSeconds': targetRest,
          'message':
              'Conferma aggiornamento recupero: $targetLabel in "${selectedTemplate.name}" ($currentRest s → $targetRest s).',
          'suggestedPayload': suggestedPayload,
          'inlineCard': h.buildTemplateActionInlineCard(
            title: 'Aggiorna recupero',
            subtitle:
                '$targetLabel • ${selectedTemplate.name}\n$currentRest s → $targetRest s',
            imageUrl: imageUrl,
            templateName: selectedTemplate.name,
            exerciseName: applyToAllExercises ? null : targetLabel,
            actions: [
              h.buildTemplateAction(
                label: 'Applica',
                command: buildUpdateCommand(targetRest),
                actionType: 'edit',
                style: 'primary',
              ),
              h.buildTemplateAction(
                label: '-15s',
                command: buildUpdateCommand(targetRest - 15),
                actionType: 'edit',
              ),
              h.buildTemplateAction(
                label: '+15s',
                command: buildUpdateCommand(targetRest + 15),
                actionType: 'edit',
              ),
            ],
          ),
          'toolName': 'updateTemplateRestTime',
        });
      }

      final updatedTemplate = await templateRepo
          .updateExerciseRestTimeInTemplate(
            templateId: selectedTemplate.id,
            exerciseName: applyToAllExercises ? null : targetLabel,
            restSeconds: targetRest,
            applyToAllExercises: applyToAllExercises,
            updateAllMatches: updateAllMatches,
          );

      return jsonEncode({
        'success': true,
        'templateName': updatedTemplate.name,
        'target': targetLabel,
        'previousRestSeconds': currentRest,
        'restSeconds': targetRest,
        'message':
            'Recupero aggiornato: $targetLabel in "${updatedTemplate.name}" a $targetRest secondi.',
        'inlineCard': h.buildTemplateActionInlineCard(
          title: 'Recupero aggiornato',
          subtitle:
              '$targetLabel • ${updatedTemplate.name}\nOra: $targetRest s',
          imageUrl: imageUrl,
          templateName: updatedTemplate.name,
          exerciseName: applyToAllExercises ? null : targetLabel,
          actions: [
            h.buildTemplateAction(
              label: '-15s',
              command: buildUpdateCommand(targetRest - 15),
              actionType: 'edit',
            ),
            h.buildTemplateAction(
              label: '+15s',
              command: buildUpdateCommand(targetRest + 15),
              actionType: 'edit',
            ),
            h.buildTemplateAction(
              label: '120s',
              command: buildUpdateCommand(120),
              actionType: 'edit',
            ),
          ],
        ),
        'toolName': 'updateTemplateRestTime',
      });
    } catch (e, st) {
      await h.recordToolError(
        e,
        st,
        reason: 'updateTemplateRestTime failed',
      );
      return jsonEncode({
        'error': e.toString(),
        'toolName': 'updateTemplateRestTime',
      });
    }
  }

  Future<String> updateTemplateExerciseSetup(
    Map<String, dynamic> args,
    String userId,
  ) async {
    int? parseOptionalBounded(
      dynamic raw, {
      required int min,
      required int max,
    }) {
      final parsed = raw is num
          ? raw.toInt()
          : int.tryParse(raw?.toString() ?? '');
      if (parsed == null) return null;
      if (parsed < min) return min;
      if (parsed > max) return max;
      return parsed;
    }

    ({int repsNumeric, String repsDisplay}) currentRepsInfo(Exercise exercise) {
      if (exercise.sets.isEmpty) {
        return (repsNumeric: 10, repsDisplay: '10');
      }
      final first = exercise.sets.first;
      if (first.minReps != null &&
          first.maxReps != null &&
          first.minReps != first.maxReps) {
        final avg = ((first.minReps! + first.maxReps!) / 2).round();
        return (
          repsNumeric: avg,
          repsDisplay: '${first.minReps}-${first.maxReps}',
        );
      }
      final reps = first.reps ?? first.minReps ?? first.maxReps ?? 10;
      return (repsNumeric: reps, repsDisplay: '$reps');
    }

    final templateName = (args['templateName'] as String?)?.trim();
    final exerciseQuery = (args['exerciseName'] as String?)?.trim();
    final applyToAllExercises = h.parseBoolFlag(args['applyToAllExercises']);
    final updateAllMatches = h.parseBoolFlag(args['updateAllMatches']);
    final confirmed = h.parseBoolFlag(args['confirmed']);

    final explicitSets = args.containsKey('sets')
        ? h.parseBoundedInt(args['sets'], defaultValue: 3, min: 1, max: 8)
        : null;
    final explicitReps = args.containsKey('reps')
        ? h.parseBoundedInt(args['reps'], defaultValue: 10, min: 3, max: 30)
        : null;
    var explicitMinReps = parseOptionalBounded(
      args['minReps'],
      min: 3,
      max: 30,
    );
    var explicitMaxReps = parseOptionalBounded(
      args['maxReps'],
      min: 3,
      max: 30,
    );
    if (explicitMinReps != null &&
        explicitMaxReps != null &&
        explicitMinReps > explicitMaxReps) {
      final tmp = explicitMinReps;
      explicitMinReps = explicitMaxReps;
      explicitMaxReps = tmp;
    }

    final parsedDeltaSets = parseOptionalBounded(
      args['deltaSets'],
      min: -3,
      max: 3,
    );
    final parsedDeltaReps = parseOptionalBounded(
      args['deltaReps'],
      min: -8,
      max: 8,
    );

    if ((explicitMinReps == null) != (explicitMaxReps == null)) {
      return jsonEncode({
        'error':
            'Per usare un range ripetizioni servono sia minReps che maxReps',
        'toolName': 'updateTemplateExerciseSetup',
      });
    }

    if (templateName == null || templateName.isEmpty) {
      try {
        final templates = await templateRepo.getUserTemplates();
        if (templates.isNotEmpty) {
          final templateNames = templates.map((t) => t.name).take(8).toList();
          return jsonEncode({
            'disambiguation': true,
            'query': 'template',
            'message': 'Seleziona il template da modificare',
            'options': templateNames.map((name) => {'name': name}).toList(),
            'suggestions': templateNames,
            'toolName': 'updateTemplateExerciseSetup',
          });
        }
      } catch (_) {
        // Fallback to standard error below.
      }
      return jsonEncode({
        'error': 'Nome template richiesto',
        'toolName': 'updateTemplateExerciseSetup',
      });
    }

    try {
      final templates = await templateRepo.getUserTemplates();
      if (templates.isEmpty) {
        return jsonEncode({
          'error': 'Nessun template salvato',
          'suggestion': 'Crea prima un template di allenamento',
          'toolName': 'updateTemplateExerciseSetup',
        });
      }

      final normalizedTemplateSearch = h.normalizeForMatch(templateName);
      final templateMatches = templates.where((t) {
        final normalized = h.normalizeForMatch(t.name);
        return normalized.contains(normalizedTemplateSearch) ||
            normalizedTemplateSearch.contains(normalized);
      }).toList();

      if (templateMatches.isEmpty) {
        final availableNames = templates.map((t) => t.name).take(6).toList();
        return jsonEncode({
          'error': 'Template "$templateName" non trovato',
          'availableTemplates': availableNames,
          'suggestions': availableNames,
          'toolName': 'updateTemplateExerciseSetup',
        });
      }

      final exactTemplateMatch = templateMatches.firstWhereOrNull(
        (t) => h.normalizeForMatch(t.name) == normalizedTemplateSearch,
      );

      if (exactTemplateMatch == null && templateMatches.length > 1) {
        final options = templateMatches
            .take(6)
            .map(
              (t) => {
                'name': t.name,
                'exerciseCount': t.exercises.length,
                'category': t.category.name,
              },
            )
            .toList();
        return jsonEncode({
          'disambiguation': true,
          'query': templateName,
          'options': options,
          'suggestions': options.map((o) => o['name'] as String).toList(),
          'toolName': 'updateTemplateExerciseSetup',
        });
      }

      final selectedTemplate = exactTemplateMatch ?? templateMatches.first;
      if (selectedTemplate.exercises.isEmpty) {
        return jsonEncode({
          'error': 'Template "${selectedTemplate.name}" non ha esercizi',
          'toolName': 'updateTemplateExerciseSetup',
        });
      }

      int currentSets;
      int currentReps;
      String currentRepsDisplay;
      String targetLabel;
      String? imageUrl;
      Exercise? selectedExercise;

      if (applyToAllExercises) {
        final setValues = selectedTemplate.exercises
            .map((e) => e.sets.isNotEmpty ? e.sets.length : 3)
            .toList();
        currentSets = (setValues.reduce((a, b) => a + b) / setValues.length)
            .round();
        final repsValues = selectedTemplate.exercises
            .map((e) => currentRepsInfo(e).repsNumeric)
            .toList();
        currentReps = repsValues.isNotEmpty
            ? (repsValues.reduce((a, b) => a + b) / repsValues.length).round()
            : 10;
        currentRepsDisplay = '~$currentReps';
        targetLabel = 'tutti gli esercizi';
      } else {
        if (exerciseQuery == null || exerciseQuery.isEmpty) {
          final options = selectedTemplate.exercises.take(8).map((e) {
            final info = currentRepsInfo(e);
            return {
              'name': e.name,
              'sets': e.sets.isNotEmpty ? e.sets.length : 3,
              'reps': info.repsDisplay,
            };
          }).toList();
          final suggestions = selectedTemplate.exercises
              .map((e) => e.name)
              .take(8)
              .toList();
          return jsonEncode({
            'disambiguation': true,
            'query': 'esercizio',
            'message':
                'Quale esercizio vuoi aggiornare nel template "${selectedTemplate.name}"?',
            'options': options,
            'suggestions': suggestions,
            'toolName': 'updateTemplateExerciseSetup',
          });
        }

        final matches = h.findTemplateExercisesByQuery(
          selectedTemplate.exercises,
          exerciseQuery,
        );
        if (matches.isEmpty) {
          return jsonEncode({
            'error':
                'Esercizio "$exerciseQuery" non trovato nel template "${selectedTemplate.name}"',
            'availableExercises': selectedTemplate.exercises
                .map((e) => e.name)
                .take(8)
                .toList(),
            'suggestions': selectedTemplate.exercises
                .map((e) => e.name)
                .take(8)
                .toList(),
            'toolName': 'updateTemplateExerciseSetup',
          });
        }

        if (matches.length > 1 && !updateAllMatches) {
          return jsonEncode({
            'disambiguation': true,
            'query': exerciseQuery,
            'options': matches.take(6).map((e) {
              final info = currentRepsInfo(e);
              return {
                'name': e.name,
                'sets': e.sets.isNotEmpty ? e.sets.length : 3,
                'reps': info.repsDisplay,
              };
            }).toList(),
            'suggestions': matches.take(6).map((e) => e.name).toList(),
            'toolName': 'updateTemplateExerciseSetup',
          });
        }

        selectedExercise = matches.first;
        currentSets = selectedExercise.sets.isNotEmpty
            ? selectedExercise.sets.length
            : 3;
        final info = currentRepsInfo(selectedExercise);
        currentReps = info.repsNumeric;
        currentRepsDisplay = info.repsDisplay;
        targetLabel = selectedExercise.name;
        imageUrl = await _tryGetExerciseImage(selectedExercise.name);
      }

      ({int sets, int reps}) recommendedSetupForTemplate() {
        final normalizedName = h.normalizeForMatch(selectedTemplate.name);
        final category = selectedTemplate.category.name.toLowerCase();
        final isPower =
            normalizedName.contains('power') ||
            normalizedName.contains('strength') ||
            normalizedName.contains('forza') ||
            category == 'strength' ||
            category == 'powerlifting';
        final isHypertrophy =
            normalizedName.contains('hypertrophy') ||
            normalizedName.contains('ipertrof') ||
            category == 'hypertrophy' ||
            category == 'bodybuilding';

        if (isPower) return (sets: 4, reps: 5);
        if (isHypertrophy) return (sets: 4, reps: 10);
        return (
          sets: currentSets.clamp(3, 5).toInt(),
          reps: currentReps.clamp(8, 12).toInt(),
        );
      }

      final hasExplicitInput =
          explicitSets != null ||
          explicitReps != null ||
          explicitMinReps != null ||
          explicitMaxReps != null ||
          parsedDeltaSets != null ||
          parsedDeltaReps != null;

      var targetSets = explicitSets ?? currentSets;
      if (parsedDeltaSets != null) {
        targetSets = ((explicitSets ?? currentSets) + parsedDeltaSets)
            .clamp(1, 8)
            .toInt();
      }

      int? targetReps;
      int? targetMinReps;
      int? targetMaxReps;
      final isRangeMode = explicitMinReps != null && explicitMaxReps != null;

      if (isRangeMode) {
        targetMinReps = explicitMinReps;
        targetMaxReps = explicitMaxReps;
      } else {
        targetReps = explicitReps ?? currentReps;
        if (parsedDeltaReps != null) {
          targetReps = ((explicitReps ?? currentReps) + parsedDeltaReps)
              .clamp(3, 30)
              .toInt();
        }
      }

      if (!hasExplicitInput) {
        final recommended = recommendedSetupForTemplate();
        targetSets = recommended.sets;
        targetReps = recommended.reps;
        targetMinReps = null;
        targetMaxReps = null;
      }

      targetSets = targetSets.clamp(1, 8).toInt();
      if (targetReps != null) {
        targetReps = targetReps.clamp(3, 30).toInt();
      }

      final proposedRepsDisplay =
          (targetMinReps != null && targetMaxReps != null)
          ? '$targetMinReps-$targetMaxReps'
          : '${targetReps ?? currentReps}';

      String buildSetupCommand({
        required int sets,
        int? reps,
        int? minReps,
        int? maxReps,
      }) {
        final safeSets = sets.clamp(1, 8);
        String repsText;
        if (minReps != null && maxReps != null) {
          var safeMin = minReps.clamp(3, 30);
          var safeMax = maxReps.clamp(3, 30);
          if (safeMin > safeMax) {
            final temp = safeMin;
            safeMin = safeMax;
            safeMax = temp;
          }
          repsText = 'range $safeMin-$safeMax ripetizioni';
        } else {
          final safeReps = (reps ?? currentReps).clamp(3, 30);
          repsText = '$safeReps ripetizioni';
        }

        if (applyToAllExercises) {
          return 'Confermo: imposta tutti gli esercizi del template "${selectedTemplate.name}" a $safeSets serie con $repsText.';
        }
        return 'Confermo: imposta "$targetLabel" nel template "${selectedTemplate.name}" a $safeSets serie con $repsText.';
      }

      final suggestedPayload = <String, dynamic>{
        'templateName': selectedTemplate.name,
        if (!applyToAllExercises) 'exerciseName': targetLabel,
        if (applyToAllExercises) 'applyToAllExercises': true,
        if (updateAllMatches) 'updateAllMatches': true,
        'sets': targetSets,
        if (targetMinReps != null && targetMaxReps != null) ...{
          'minReps': targetMinReps,
          'maxReps': targetMaxReps,
        } else ...{
          'reps': targetReps ?? currentReps,
        },
        'confirmed': true,
      };

      final actions = <Map<String, dynamic>>[
        h.buildTemplateAction(
          label: 'Applica',
          command: buildSetupCommand(
            sets: targetSets,
            reps: targetReps,
            minReps: targetMinReps,
            maxReps: targetMaxReps,
          ),
          actionType: 'edit',
          style: 'primary',
        ),
        h.buildTemplateAction(
          label: '+1 serie',
          command: buildSetupCommand(
            sets: targetSets + 1,
            reps: targetReps,
            minReps: targetMinReps,
            maxReps: targetMaxReps,
          ),
          actionType: 'edit',
        ),
        h.buildTemplateAction(
          label: '-1 serie',
          command: buildSetupCommand(
            sets: targetSets - 1,
            reps: targetReps,
            minReps: targetMinReps,
            maxReps: targetMaxReps,
          ),
          actionType: 'edit',
        ),
      ];

      if (targetMinReps != null && targetMaxReps != null) {
        actions.add(
          h.buildTemplateAction(
            label: '8-12 reps',
            command: buildSetupCommand(
              sets: targetSets,
              minReps: 8,
              maxReps: 12,
            ),
            actionType: 'edit',
          ),
        );
      } else {
        final repsForActions = targetReps ?? currentReps;
        actions.add(
          h.buildTemplateAction(
            label: '+2 reps',
            command: buildSetupCommand(
              sets: targetSets,
              reps: repsForActions + 2,
            ),
            actionType: 'edit',
          ),
        );
      }

      if (!confirmed) {
        return jsonEncode({
          'confirmationRequired': true,
          'templateName': selectedTemplate.name,
          'target': targetLabel,
          'currentSets': currentSets,
          'currentReps': currentRepsDisplay,
          'proposedSets': targetSets,
          'proposedReps': proposedRepsDisplay,
          'message':
              'Conferma aggiornamento setup: $targetLabel in "${selectedTemplate.name}" ($currentSets×$currentRepsDisplay → $targetSets×$proposedRepsDisplay).',
          'suggestedPayload': suggestedPayload,
          'inlineCard': h.buildTemplateActionInlineCard(
            title: 'Aggiorna serie e ripetizioni',
            subtitle:
                '$targetLabel • ${selectedTemplate.name}\n$currentSets×$currentRepsDisplay → $targetSets×$proposedRepsDisplay',
            imageUrl: imageUrl,
            templateName: selectedTemplate.name,
            exerciseName: applyToAllExercises ? null : targetLabel,
            actions: actions,
          ),
          'toolName': 'updateTemplateExerciseSetup',
        });
      }

      final updatedTemplate = await templateRepo
          .updateExerciseSetRepsInTemplate(
            templateId: selectedTemplate.id,
            exerciseName: applyToAllExercises ? null : targetLabel,
            sets: targetSets,
            reps: targetMinReps == null ? (targetReps ?? currentReps) : null,
            minReps: targetMinReps,
            maxReps: targetMaxReps,
            applyToAllExercises: applyToAllExercises,
            updateAllMatches: updateAllMatches,
          );

      return jsonEncode({
        'success': true,
        'templateName': updatedTemplate.name,
        'target': targetLabel,
        'sets': targetSets,
        'reps': proposedRepsDisplay,
        'message':
            'Setup aggiornato: $targetLabel in "${updatedTemplate.name}" ora è $targetSets×$proposedRepsDisplay.',
        'inlineCard': h.buildTemplateActionInlineCard(
          title: 'Setup aggiornato',
          subtitle:
              '$targetLabel • ${updatedTemplate.name}\nOra: $targetSets×$proposedRepsDisplay',
          imageUrl: imageUrl,
          templateName: updatedTemplate.name,
          exerciseName: applyToAllExercises ? null : targetLabel,
          actions: actions,
        ),
        'toolName': 'updateTemplateExerciseSetup',
      });
    } catch (e, st) {
      await h.recordToolError(
        e,
        st,
        reason: 'updateTemplateExerciseSetup failed',
      );
      return jsonEncode({
        'error': e.toString(),
        'toolName': 'updateTemplateExerciseSetup',
      });
    }
  }
}

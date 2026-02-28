/// Template exercise executor for AI Coach
///
/// Handles: addExerciseToTemplate, replaceExerciseInTemplate,
/// removeExerciseFromTemplate.
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

class TemplateExerciseExecutor {
  TemplateExerciseExecutor({
    required this.templateRepo,
    required this.exerciseSearchService,
    this.locale,
  });

  final TemplateRepository templateRepo;
  final ExerciseSearchService exerciseSearchService;
  final Locale? locale;

  Future<String?> _tryGetExerciseImage(String exerciseName) =>
      h.tryGetExerciseImage(exerciseName, exerciseSearchService, locale);

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
}

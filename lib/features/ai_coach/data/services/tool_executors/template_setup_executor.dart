/// Template setup executor for AI Coach
///
/// Handles: updateTemplateRestTime, updateTemplateExerciseSetup.
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

class TemplateSetupExecutor {
  TemplateSetupExecutor({
    required this.templateRepo,
    required this.exerciseSearchService,
    this.locale,
  });

  final TemplateRepository templateRepo;
  final ExerciseSearchService exerciseSearchService;
  final Locale? locale;

  Future<String?> _tryGetExerciseImage(String exerciseName) =>
      h.tryGetExerciseImage(exerciseName, exerciseSearchService, locale);

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

/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/home/presentation/widgets
/// 🎯 Feature: home
/// 🔧 Type: widget
/// 🌍 Localization: Full
/// 🎨 Theme: Adaptive
/// 📱 Platform: Universal
///
/// Dialog for selecting replacement exercise and templates
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/home/domain/services/ai_coach_service.dart';
import 'package:gymbro_flutter_new/features/home/domain/services/exercise_replacement_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class ExerciseReplacementDialog extends ConsumerStatefulWidget {

  const ExerciseReplacementDialog({
    super.key,
    required this.affectedExercise,
    required this.affectedTemplates,
    required this.exerciseDatabase,
  });
  final String affectedExercise;
  final List<AffectedTemplate> affectedTemplates;
  final Map<String, Exercise> exerciseDatabase;

  @override
  ConsumerState<ExerciseReplacementDialog> createState() => _ExerciseReplacementDialogState();
}

class _ExerciseReplacementDialogState extends ConsumerState<ExerciseReplacementDialog> {
  Exercise? selectedReplacement;
  final Set<String> selectedTemplateIds = {};
  String weightOption = 'keep'; // 'keep', 'reset', 'manual'

  @override
  void initState() {
    super.initState();
    // Pre-select all templates
    selectedTemplateIds.addAll(widget.affectedTemplates.map((t) => t.templateId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Find similar exercises
    final similarExercises = ExerciseReplacementService.findSimilarExercises(
      currentExerciseName: widget.affectedExercise,
      exerciseDatabase: widget.exerciseDatabase,
    );

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(AppIcons.swapHoriz, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.selectReplacement,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(AppIcons.close, color: colorScheme.onPrimaryContainer),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Similar Exercises Section
                    Text(
                      l10n.similarExercises,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (similarExercises.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.noSimilarExercises,
                          style: TextStyle(color: colorScheme.onErrorContainer),
                        ),
                      )
                    else
                      ...similarExercises.map((exercise) => _buildExerciseTile(
                            exercise,
                            theme,
                            colorScheme,
                          )),

                    const SizedBox(height: 24),

                    // Template Selection Section
                    Text(
                      l10n.selectTemplates,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...widget.affectedTemplates.map((template) => CheckboxListTile(
                          value: selectedTemplateIds.contains(template.templateId),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedTemplateIds.add(template.templateId);
                              } else {
                                selectedTemplateIds.remove(template.templateId);
                              }
                            });
                          },
                          title: Text(template.templateName),
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                        )),

                    const SizedBox(height: 24),

                    // Weight Handling Section
                    Text(
                      l10n.weightHandling,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    RadioGroup<String>(
                      groupValue: weightOption,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => weightOption = value);
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile<String>(
                            value: 'keep',
                            title: Text(l10n.keepCurrentWeight),
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          RadioListTile<String>(
                            value: 'reset',
                            title: Text(l10n.resetWeight),
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          RadioListTile<String>(
                            value: 'manual',
                            title: Text(l10n.setManually),
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: selectedReplacement == null || selectedTemplateIds.isEmpty
                        ? null
                        : () => Navigator.pop(context, {
                              'replacement': selectedReplacement,
                              'templateIds': selectedTemplateIds.toList(),
                              'weightOption': weightOption,
                            }),
                    child: Text(l10n.applyToTemplates(selectedTemplateIds.length)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseTile(Exercise exercise, ThemeData theme, ColorScheme colorScheme) {
    final isSelected = selectedReplacement?.id == exercise.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => selectedReplacement = exercise),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              if (isSelected)
                Icon(AppIcons.complete, color: colorScheme.primary)
              else
                Icon(AppIcons.radioButtonUnchecked, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.nome,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ExerciseReplacementService.getExerciseDetails(exercise),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                            : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: workout_templates/presentation/widgets
/// 🎯 Feature: Template Creation Modals
/// 🔧 Type: widget
///
/// Modals per creare template personalizzati di tecniche avanzate
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/exercise_search_screen.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_target_muscle_map.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/superset_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/dropset_template.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/rest_pause_template.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/superset_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/dropset_template_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/rest_pause_template_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/equipment_icon_badge.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

Widget _buildExerciseSelectionSubtitle(
  BuildContext context,
  Exercise exercise,
) {
  final hasMuscleData =
      exercise.focus.isNotEmpty || exercise.muscoliSecondari.isNotEmpty;

  return Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xs),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasMuscleData)
          ExerciseTargetMuscleMap(
            primaryMuscles: exercise.focus,
            secondaryMuscles: exercise.muscoliSecondari,
            previewWidth: 78,
            previewHeight: 58,
            enableFullscreen: false,
          ),
        if (hasMuscleData && exercise.attrezzatura.isNotEmpty)
          const SizedBox(height: AppSpacing.xs),
        if (exercise.attrezzatura.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                EquipmentIconBadge(equipment: exercise.attrezzatura, size: 16),
                const SizedBox(width: 6),
                Text(exercise.attrezzatura, style: context.textTheme.bodySmall),
              ],
            ),
          ),
      ],
    ),
  );
}

// ============================================================================
// SUPERSET TEMPLATE CREATION MODAL
// ============================================================================

/// Modal per creare un template Superset personalizzato
class SupersetTemplateCreationModal extends ConsumerStatefulWidget {
  const SupersetTemplateCreationModal({super.key});

  static Future<void> show(BuildContext context) {
    return ModalService.showSheet<void>(
      context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) =>
            const SupersetTemplateCreationModal(),
      ),
    );
  }

  @override
  ConsumerState<SupersetTemplateCreationModal> createState() =>
      _SupersetTemplateCreationModalState();
}

class _SupersetTemplateCreationModalState
    extends ConsumerState<SupersetTemplateCreationModal> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _roundsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '10-12');
  final _restAfterRoundController = TextEditingController(text: '90');
  final _restBetweenController = TextEditingController(text: '0');

  // Selected exercises (by ID)
  final List<Exercise> _selectedExercises = [];
  TemplateDifficulty _selectedDifficulty = TemplateDifficulty.intermediate;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _roundsController.dispose();
    _repsController.dispose();
    _restAfterRoundController.dispose();
    _restBetweenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          _buildHandleBar(context),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: SemanticIcon(
                      icon: AppIcons.link,
                      semanticLabel: l10n.superset,
                      size: AppIconSize.medium,
                      color: context.colors.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n.createSuperset,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: SemanticIcon(
                    icon: AppIcons.close,
                    semanticLabel: l10n.close,
                    size: AppIconSize.medium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Template Name
                  _buildSectionTitle(context, l10n.templateName),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: l10n.enterTemplateName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Exercise Selection
                  _buildSectionTitle(context, l10n.exercises),
                  _buildExerciseSelector(context, l10n),

                  const SizedBox(height: AppSpacing.lg),

                  // Configuration
                  _buildSectionTitle(context, l10n.configuration),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          context,
                          controller: _roundsController,
                          label: l10n.rounds,
                          suffix: '',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildTextField(
                          context,
                          controller: _repsController,
                          label: l10n.reps,
                          hint: '10-12',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          context,
                          controller: _restAfterRoundController,
                          label: l10n.restAfterRound,
                          suffix: 's',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildNumberField(
                          context,
                          controller: _restBetweenController,
                          label: l10n.restBetweenExercises,
                          suffix: 's',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Difficulty
                  _buildSectionTitle(context, l10n.difficulty),
                  _buildDifficultySelector(context),

                  const SizedBox(height: AppSpacing.lg),

                  // Notes
                  _buildSectionTitle(context, l10n.notes),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.optionalNotes,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _canSave() ? _saveTemplate : null,
                      icon: SemanticIcon(
                        icon: AppIcons.save,
                        semanticLabel: l10n.save,
                        size: AppIconSize.small,
                      ),
                      label: Text(l10n.saveTemplate),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSelector(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // Selected exercises
        if (_selectedExercises.isNotEmpty) ...[
          ...List.generate(_selectedExercises.length, (index) {
            final exercise = _selectedExercises[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: context.colors.secondaryContainer,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: context.colors.secondary),
                  ),
                ),
                title: Text(exercise.nome),
                subtitle: _buildExerciseSelectionSubtitle(context, exercise),
                trailing: IconButton(
                  icon: SemanticIcon(
                    icon: AppIcons.close,
                    semanticLabel: l10n.remove,
                    size: AppIconSize.small,
                    color: context.colors.error,
                  ),
                  onPressed: () {
                    setState(() => _selectedExercises.removeAt(index));
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Add exercise button
        if (_selectedExercises.length < 4)
          OutlinedButton.icon(
            onPressed: () => _showExercisePicker(context),
            icon: SemanticIcon(
              icon: AppIcons.add,
              semanticLabel: l10n.add,
              size: AppIconSize.small,
            ),
            label: Text(
              _selectedExercises.isEmpty
                  ? l10n.addExercise
                  : l10n.addAnotherExercise,
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),

        if (_selectedExercises.length >= 4)
          Text(
            l10n.maxExercisesReached,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  void _showExercisePicker(BuildContext context) {
    ModalService.showSheet<Exercise>(
      context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => const ExerciseSearchScreen(
          selectionMode: true,
          showSupersetTemplates: false,
        ),
      ),
    ).then((exercise) {
      if (exercise != null && mounted) {
        // Evita duplicati
        if (!_selectedExercises.any((e) => e.id == exercise.id)) {
          setState(() => _selectedExercises.add(exercise));
        }
      }
    });
  }

  Widget _buildDifficultySelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final difficulties = [
      (TemplateDifficulty.beginner, l10n.beginnerLevel),
      (TemplateDifficulty.intermediate, l10n.intermediateLevel),
      (TemplateDifficulty.advanced, l10n.advancedLevel),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      children: difficulties.map((d) {
        final isSelected = _selectedDifficulty == d.$1;
        return ChoiceChip(
          label: Text(d.$2),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) setState(() => _selectedDifficulty = d.$1);
          },
        );
      }).toList(),
    );
  }

  bool _canSave() {
    return _nameController.text.trim().isNotEmpty &&
        _selectedExercises.length >= 2;
  }

  Future<void> _saveTemplate() async {
    final l10n = AppLocalizations.of(context);

    final template = SupersetTemplate(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      exerciseIds: _selectedExercises.map((e) => e.id).toList(),
      exerciseNames: _selectedExercises.map((e) => e.nome).toList(),
      rounds: int.tryParse(_roundsController.text) ?? 3,
      repsRange: _repsController.text.trim(),
      restAfterRound: int.tryParse(_restAfterRoundController.text) ?? 90,
      restAfterSuperset: int.tryParse(_restBetweenController.text) ?? 0,
      difficulty: _selectedDifficulty,
      estimatedTimeMinutes: _calculateEstimatedTime(),
      scientificBasis: 'Custom template created by user',
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      isCustom: true,
      createdAt: DateTime.now(),
    );

    try {
      await ref
          .read(supersetTemplateNotifierProvider.notifier)
          .saveCustomTemplate(template);

      if (mounted) {
        Navigator.pop(context);
        SnackBarService.showSuccess(context, l10n.templateSaved);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, l10n.errorSavingTemplate);
      }
    }
  }

  int _calculateEstimatedTime() {
    final rounds = int.tryParse(_roundsController.text) ?? 3;
    final restAfterRound = int.tryParse(_restAfterRoundController.text) ?? 90;
    final restBetween = int.tryParse(_restBetweenController.text) ?? 0;
    final exerciseCount = _selectedExercises.length;

    // Stima: 45s per esercizio + rest
    final workTime = rounds * exerciseCount * 45;
    final restTime =
        rounds * restAfterRound + (exerciseCount - 1) * restBetween;
    return ((workTime + restTime) / 60).ceil();
  }

  Widget _buildHandleBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildNumberField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ============================================================================
// DROPSET TEMPLATE CREATION MODAL
// ============================================================================

/// Modal per creare un template Dropset personalizzato
class DropsetTemplateCreationModal extends ConsumerStatefulWidget {
  const DropsetTemplateCreationModal({super.key});

  static Future<void> show(BuildContext context) {
    return ModalService.showSheet<void>(
      context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) =>
            const DropsetTemplateCreationModal(),
      ),
    );
  }

  @override
  ConsumerState<DropsetTemplateCreationModal> createState() =>
      _DropsetTemplateCreationModalState();
}

class _DropsetTemplateCreationModalState
    extends ConsumerState<DropsetTemplateCreationModal> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _dropsController = TextEditingController(text: '3');
  final _initialRepsController = TextEditingController(text: '8-10');
  final _dropPercentageController = TextEditingController(text: '20');
  final _restBetweenDropsController = TextEditingController(text: '5');
  final _totalSetsController = TextEditingController(text: '3');
  final _restBetweenSetsController = TextEditingController(text: '90');

  Exercise? _selectedExercise;
  DropsetDifficulty _selectedDifficulty = DropsetDifficulty.intermediate;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _dropsController.dispose();
    _initialRepsController.dispose();
    _dropPercentageController.dispose();
    _restBetweenDropsController.dispose();
    _totalSetsController.dispose();
    _restBetweenSetsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          _buildHandleBar(context),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.colors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: SemanticIcon(
                      icon: AppIcons.trendDown,
                      semanticLabel: l10n.dropset,
                      size: AppIconSize.medium,
                      color: context.colors.tertiary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n.createDropset,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: SemanticIcon(
                    icon: AppIcons.close,
                    semanticLabel: l10n.close,
                    size: AppIconSize.medium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Template Name
                  _buildSectionTitle(context, l10n.templateName),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: l10n.enterTemplateName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Exercise Selection
                  _buildSectionTitle(context, l10n.exercise),
                  _buildExerciseSelector(context, l10n),

                  const SizedBox(height: AppSpacing.lg),

                  // Dropset Configuration
                  _buildSectionTitle(context, l10n.dropsetConfiguration),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          context,
                          controller: _dropsController,
                          label: l10n.numberOfDrops,
                          suffix: '',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildNumberField(
                          context,
                          controller: _dropPercentageController,
                          label: l10n.dropPercentage,
                          suffix: '%',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          context,
                          controller: _initialRepsController,
                          label: l10n.initialReps,
                          hint: '8-10',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildNumberField(
                          context,
                          controller: _restBetweenDropsController,
                          label: l10n.restBetweenDrops,
                          suffix: 's',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          context,
                          controller: _totalSetsController,
                          label: l10n.totalSets,
                          suffix: '',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildNumberField(
                          context,
                          controller: _restBetweenSetsController,
                          label: l10n.restBetweenSets,
                          suffix: 's',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Difficulty
                  _buildSectionTitle(context, l10n.difficulty),
                  _buildDifficultySelector(context),

                  const SizedBox(height: AppSpacing.lg),

                  // Notes
                  _buildSectionTitle(context, l10n.notes),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.optionalNotes,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _canSave() ? _saveTemplate : null,
                      icon: SemanticIcon(
                        icon: AppIcons.save,
                        semanticLabel: l10n.save,
                        size: AppIconSize.small,
                      ),
                      label: Text(l10n.saveTemplate),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSelector(BuildContext context, AppLocalizations l10n) {
    if (_selectedExercise != null) {
      return Card(
        color: context.colors.tertiaryContainer.withValues(alpha: 0.3),
        child: ListTile(
          leading: Icon(AppIcons.checkCircle, color: context.colors.tertiary),
          title: Text(_selectedExercise!.nome),
          subtitle: _buildExerciseSelectionSubtitle(
            context,
            _selectedExercise!,
          ),
          trailing: IconButton(
            icon: SemanticIcon(
              icon: AppIcons.close,
              semanticLabel: l10n.remove,
              size: AppIconSize.small,
              color: context.colors.error,
            ),
            onPressed: () => setState(() => _selectedExercise = null),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _showExercisePicker(context),
      icon: SemanticIcon(
        icon: AppIcons.search,
        semanticLabel: l10n.selectExercise,
        size: AppIconSize.small,
      ),
      label: Text(l10n.selectExercise),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  void _showExercisePicker(BuildContext context) {
    ModalService.showSheet<Exercise>(
      context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => const ExerciseSearchScreen(
          selectionMode: true,
          showSupersetTemplates: false,
        ),
      ),
    ).then((exercise) {
      if (exercise != null && mounted) {
        setState(() {
          _selectedExercise = exercise;
          if (_nameController.text.isEmpty) {
            _nameController.text = '${exercise.nome} Dropset';
          }
        });
      }
    });
  }

  Widget _buildDifficultySelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final difficulties = [
      (DropsetDifficulty.beginner, l10n.beginnerLevel),
      (DropsetDifficulty.intermediate, l10n.intermediateLevel),
      (DropsetDifficulty.advanced, l10n.advancedLevel),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      children: difficulties.map((d) {
        final isSelected = _selectedDifficulty == d.$1;
        return ChoiceChip(
          label: Text(d.$2),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) setState(() => _selectedDifficulty = d.$1);
          },
        );
      }).toList(),
    );
  }

  bool _canSave() {
    return _nameController.text.trim().isNotEmpty && _selectedExercise != null;
  }

  Future<void> _saveTemplate() async {
    final l10n = AppLocalizations.of(context);

    final template = DropsetTemplate(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      exerciseName: _selectedExercise!.nome,
      drops: int.tryParse(_dropsController.text) ?? 3,
      initialReps: _initialRepsController.text.trim(),
      dropPercentage: int.tryParse(_dropPercentageController.text) ?? 20,
      restBetweenDrops: int.tryParse(_restBetweenDropsController.text) ?? 5,
      totalSets: int.tryParse(_totalSetsController.text) ?? 3,
      restBetweenSets: int.tryParse(_restBetweenSetsController.text) ?? 90,
      difficulty: _selectedDifficulty,
      estimatedTimeMinutes: _calculateEstimatedTime(),
      scientificBasis: 'Custom dropset template created by user',
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      targetMuscles: _selectedExercise!.focus,
      isCustom: true,
      createdAt: DateTime.now(),
    );

    try {
      await ref
          .read(dropsetTemplateNotifierProvider.notifier)
          .saveCustomTemplate(template);

      if (mounted) {
        Navigator.pop(context);
        SnackBarService.showSuccess(context, l10n.templateSaved);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, l10n.errorSavingTemplate);
      }
    }
  }

  int _calculateEstimatedTime() {
    final drops = int.tryParse(_dropsController.text) ?? 3;
    final totalSets = int.tryParse(_totalSetsController.text) ?? 3;
    final restBetweenSets = int.tryParse(_restBetweenSetsController.text) ?? 90;

    // Stima: 20s per drop + rest tra set
    final workTime = totalSets * drops * 20;
    final restTime = (totalSets - 1) * restBetweenSets;
    return ((workTime + restTime) / 60).ceil();
  }

  Widget _buildHandleBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildNumberField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ============================================================================
// REST-PAUSE TEMPLATE CREATION MODAL
// ============================================================================

/// Modal per creare un template Rest-Pause personalizzato
class RestPauseTemplateCreationModal extends ConsumerStatefulWidget {
  const RestPauseTemplateCreationModal({super.key});

  static Future<void> show(BuildContext context) {
    return ModalService.showSheet<void>(
      context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) =>
            const RestPauseTemplateCreationModal(),
      ),
    );
  }

  @override
  ConsumerState<RestPauseTemplateCreationModal> createState() =>
      _RestPauseTemplateCreationModalState();
}

class _RestPauseTemplateCreationModalState
    extends ConsumerState<RestPauseTemplateCreationModal> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _initialRepsController = TextEditingController(text: '6-8');
  final _clustersController = TextEditingController(text: '3');
  final _clusterRepsController = TextEditingController(text: '2-3');
  final _pauseDurationController = TextEditingController(text: '15');
  final _totalSetsController = TextEditingController(text: '3');
  final _restBetweenSetsController = TextEditingController(text: '180');

  Exercise? _selectedExercise;
  RestPauseDifficulty _selectedDifficulty = RestPauseDifficulty.intermediate;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _initialRepsController.dispose();
    _clustersController.dispose();
    _clusterRepsController.dispose();
    _pauseDurationController.dispose();
    _totalSetsController.dispose();
    _restBetweenSetsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          _buildHandleBar(context),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.colors.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: SemanticIcon(
                      icon: AppIcons.timer,
                      semanticLabel: l10n.restPause,
                      size: AppIconSize.medium,
                      color: context.colors.error,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n.createRestPause,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: SemanticIcon(
                    icon: AppIcons.close,
                    semanticLabel: l10n.close,
                    size: AppIconSize.medium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Template Name
                  _buildSectionTitle(context, l10n.templateName),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: l10n.enterTemplateName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Exercise Selection
                  _buildSectionTitle(context, l10n.exercise),
                  _buildExerciseSelector(context, l10n),

                  const SizedBox(height: AppSpacing.lg),

                  // Rest-Pause Configuration
                  _buildSectionTitle(context, l10n.restPauseConfiguration),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          context,
                          controller: _initialRepsController,
                          label: l10n.initialReps,
                          hint: '6-8',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildNumberField(
                          context,
                          controller: _clustersController,
                          label: l10n.clusters,
                          suffix: '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          context,
                          controller: _clusterRepsController,
                          label: l10n.clusterReps,
                          hint: '2-3',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildNumberField(
                          context,
                          controller: _pauseDurationController,
                          label: l10n.pauseDuration,
                          suffix: 's',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          context,
                          controller: _totalSetsController,
                          label: l10n.totalSets,
                          suffix: '',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildNumberField(
                          context,
                          controller: _restBetweenSetsController,
                          label: l10n.restBetweenSets,
                          suffix: 's',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Difficulty
                  _buildSectionTitle(context, l10n.difficulty),
                  _buildDifficultySelector(context),

                  const SizedBox(height: AppSpacing.lg),

                  // Notes
                  _buildSectionTitle(context, l10n.notes),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.optionalNotes,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _canSave() ? _saveTemplate : null,
                      icon: SemanticIcon(
                        icon: AppIcons.save,
                        semanticLabel: l10n.save,
                        size: AppIconSize.small,
                      ),
                      label: Text(l10n.saveTemplate),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSelector(BuildContext context, AppLocalizations l10n) {
    if (_selectedExercise != null) {
      return Card(
        color: context.colors.errorContainer.withValues(alpha: 0.3),
        child: ListTile(
          leading: Icon(AppIcons.checkCircle, color: context.colors.error),
          title: Text(_selectedExercise!.nome),
          subtitle: _buildExerciseSelectionSubtitle(
            context,
            _selectedExercise!,
          ),
          trailing: IconButton(
            icon: SemanticIcon(
              icon: AppIcons.close,
              semanticLabel: l10n.remove,
              size: AppIconSize.small,
              color: context.colors.error,
            ),
            onPressed: () => setState(() => _selectedExercise = null),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _showExercisePicker(context),
      icon: SemanticIcon(
        icon: AppIcons.search,
        semanticLabel: l10n.selectExercise,
        size: AppIconSize.small,
      ),
      label: Text(l10n.selectExercise),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  void _showExercisePicker(BuildContext context) {
    ModalService.showSheet<Exercise>(
      context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => const ExerciseSearchScreen(
          selectionMode: true,
          showSupersetTemplates: false,
        ),
      ),
    ).then((exercise) {
      if (exercise != null && mounted) {
        setState(() {
          _selectedExercise = exercise;
          if (_nameController.text.isEmpty) {
            _nameController.text = '${exercise.nome} Rest-Pause';
          }
        });
      }
    });
  }

  Widget _buildDifficultySelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final difficulties = [
      (RestPauseDifficulty.beginner, l10n.beginnerLevel),
      (RestPauseDifficulty.intermediate, l10n.intermediateLevel),
      (RestPauseDifficulty.advanced, l10n.advancedLevel),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      children: difficulties.map((d) {
        final isSelected = _selectedDifficulty == d.$1;
        return ChoiceChip(
          label: Text(d.$2),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) setState(() => _selectedDifficulty = d.$1);
          },
        );
      }).toList(),
    );
  }

  bool _canSave() {
    return _nameController.text.trim().isNotEmpty && _selectedExercise != null;
  }

  Future<void> _saveTemplate() async {
    final l10n = AppLocalizations.of(context);

    final template = RestPauseTemplate(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      exerciseName: _selectedExercise!.nome,
      initialReps: _initialRepsController.text.trim(),
      clusters: int.tryParse(_clustersController.text) ?? 3,
      clusterReps: _clusterRepsController.text.trim(),
      pauseDuration: int.tryParse(_pauseDurationController.text) ?? 15,
      totalSets: int.tryParse(_totalSetsController.text) ?? 3,
      restBetweenSets: int.tryParse(_restBetweenSetsController.text) ?? 180,
      difficulty: _selectedDifficulty,
      estimatedTimeMinutes: _calculateEstimatedTime(),
      scientificBasis: 'Custom rest-pause template created by user',
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      targetMuscles: _selectedExercise!.focus,
      isCustom: true,
      createdAt: DateTime.now(),
    );

    try {
      await ref
          .read(restPauseTemplateNotifierProvider.notifier)
          .saveCustomTemplate(template);

      if (mounted) {
        Navigator.pop(context);
        SnackBarService.showSuccess(context, l10n.templateSaved);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, l10n.errorSavingTemplate);
      }
    }
  }

  int _calculateEstimatedTime() {
    final clusters = int.tryParse(_clustersController.text) ?? 3;
    final totalSets = int.tryParse(_totalSetsController.text) ?? 3;
    final pauseDuration = int.tryParse(_pauseDurationController.text) ?? 15;
    final restBetweenSets =
        int.tryParse(_restBetweenSetsController.text) ?? 180;

    // Stima: 30s initial + (clusters * 15s) + rest tra set
    final workTime = totalSets * (30 + clusters * (10 + pauseDuration));
    final restTime = (totalSets - 1) * restBetweenSets;
    return ((workTime + restTime) / 60).ceil();
  }

  Widget _buildHandleBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildNumberField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

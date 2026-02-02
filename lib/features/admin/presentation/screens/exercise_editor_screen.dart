/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/screens
/// 🎯 Feature: admin
/// 🔧 Type: screen
///
/// Schermata editor completo per singolo esercizio
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/admin/data/services/database_manager_service.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/database_manager_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/tut_selector.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

class ExerciseEditorScreen extends ConsumerStatefulWidget {
  // null = new exercise

  const ExerciseEditorScreen({super.key, this.exercise});
  final Exercise? exercise;

  @override
  ConsumerState<ExerciseEditorScreen> createState() =>
      _ExerciseEditorScreenState();
}

class _ExerciseEditorScreenState extends ConsumerState<ExerciseEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _techNoteController = TextEditingController();
  final _tempoNoteController = TextEditingController();

  String? _selectedDifficulty;
  String? _selectedEquipment;
  String? _selectedExerciseType;
  String? _selectedMovementPattern;
  String? _selectedRepRange;
  String? _selectedTUT;
  List<String> _selectedFocusMuscles = [];
  List<String> _selectedSecondaryMuscles = [];

  ExerciseDropdownValues? _dropdownValues;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDropdownValues();
    if (widget.exercise != null) {
      _initializeWithExistingExercise();
    }
  }

  void _loadDropdownValues() async {
    final service = ref.read(databaseManagerServiceProvider);
    final values = await service.getDropdownValues();
    if (mounted) {
      setState(() {
        _dropdownValues = values;
      });
    }
  }

  void _initializeWithExistingExercise() {
    final exercise = widget.exercise!;
    _nameController.text = exercise.nome;
    _descriptionController.text = exercise.noteTecniche ?? '';
    _imageUrlController.text = exercise.imageUrl ?? '';
    _techNoteController.text = exercise.noteTecniche ?? '';
    // Note: tempoNote field not in ExerciseDefinition entity - using tempoEsecuzione for TUT
    _tempoNoteController.text = exercise.tempoEsecuzione ?? '';
    _selectedDifficulty = exercise.difficolta;
    _selectedEquipment = exercise.attrezzatura;
    _selectedExerciseType = exercise.tipoEsercizio;
    _selectedMovementPattern = exercise.patternMovimento;
    _selectedRepRange = exercise.rangeRipetizioni;
    _selectedTUT = exercise.tempoEsecuzione;
    _selectedFocusMuscles = List.from(exercise.focus);
    _selectedSecondaryMuscles = List.from(exercise.muscoliSecondari);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _techNoteController.dispose();
    _tempoNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.exercise != null;

    if (_dropdownValues == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            isEditing ? context.l10n.editExercise : context.l10n.addExercise,
          ),
        ),
        body: const Center(child: LoadingIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? context.l10n.editExercise : context.l10n.addExercise,
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: LoadingIndicator()),
            )
          else
            TextButton.icon(
              onPressed: _saveExercise,
              icon: const SemanticIcon(
                icon: AppIcons.save,
                semanticLabel: 'Save',
              ),
              label: Text(context.l10n.save),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionTitle(context.l10n.generalInformation),

              // Exercise Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.exerciseName,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.l10n.exerciseNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Image URL
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
              const SizedBox(height: 24),

              // Exercise Properties Section
              _buildSectionTitle('Exercise Properties'),

              // Difficulty
              _buildDropdown(
                label: 'Difficulty',
                value: _selectedDifficulty,
                items: _dropdownValues!.difficulties,
                onChanged: (value) =>
                    setState(() => _selectedDifficulty = value),
              ),
              const SizedBox(height: 16),

              // Equipment
              _buildDropdown(
                label: 'Equipment',
                value: _selectedEquipment,
                items: _dropdownValues!.equipments,
                onChanged: (value) =>
                    setState(() => _selectedEquipment = value),
              ),
              const SizedBox(height: 16),

              // Exercise Type
              _buildDropdown(
                label: 'Exercise Type',
                value: _selectedExerciseType,
                items: _dropdownValues!.exerciseTypes,
                onChanged: (value) =>
                    setState(() => _selectedExerciseType = value),
              ),
              const SizedBox(height: 16),

              // Movement Pattern
              _buildDropdown(
                label: 'Movement Pattern',
                value: _selectedMovementPattern,
                items: _dropdownValues!.movementPatterns,
                onChanged: (value) =>
                    setState(() => _selectedMovementPattern = value),
              ),
              const SizedBox(height: 16),

              // Rep Range
              _buildDropdown(
                label: 'Rep Range',
                value: _selectedRepRange,
                items: _dropdownValues!.repRanges,
                onChanged: (value) => setState(() => _selectedRepRange = value),
              ),
              const SizedBox(height: 16),

              // TUT (Time Under Tension)
              _buildTutSelector(),
              const SizedBox(height: 24),

              // Muscles Section
              _buildSectionTitle('Target Muscles'),

              // Focus Muscles
              _buildMuscleSelector(
                title: 'Primary Muscles',
                selectedMuscles: _selectedFocusMuscles,
                availableMuscles: _dropdownValues!.muscles,
                onChanged: (muscles) =>
                    setState(() => _selectedFocusMuscles = muscles),
              ),
              const SizedBox(height: 16),

              // Secondary Muscles
              _buildMuscleSelector(
                title: 'Secondary Muscles',
                selectedMuscles: _selectedSecondaryMuscles,
                availableMuscles: _dropdownValues!.muscles,
                onChanged: (muscles) =>
                    setState(() => _selectedSecondaryMuscles = muscles),
              ),
              const SizedBox(height: 24),

              // Technical Notes Section
              _buildSectionTitle('Technical Notes'),

              // Technical Notes
              TextFormField(
                controller: _techNoteController,
                decoration: const InputDecoration(
                  labelText: 'Technical Notes',
                  border: OutlineInputBorder(),
                  hintText: 'Form cues, tips, safety notes...',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // Tempo Notes
              TextFormField(
                controller: _tempoNoteController,
                decoration: const InputDecoration(
                  labelText: 'Tempo Execution Notes',
                  border: OutlineInputBorder(),
                  hintText: 'Explanation of tempo execution...',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveExercise,
                  icon: const SemanticIcon(
                    icon: AppIcons.save,
                    semanticLabel: 'Save',
                  ),
                  label: Text(
                    isEditing
                        ? context.l10n.updateExercise
                        : context.l10n.createExercise,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildMuscleSelector({
    required String title,
    required List<String> selectedMuscles,
    required List<String> availableMuscles,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableMuscles.map((muscle) {
              final isSelected = selectedMuscles.contains(muscle);
              return FilterChip(
                label: Text(muscle),
                selected: isSelected,
                onSelected: (selected) {
                  final newList = List<String>.from(selectedMuscles);
                  if (selected) {
                    newList.add(muscle);
                  } else {
                    newList.remove(muscle);
                  }
                  onChanged(newList);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(databaseManagerServiceProvider);

      // Create or update exercise
      final exercise = Exercise(
        id: widget.exercise?.id ?? '',
        nome: _nameController.text.trim(),
        focus: _selectedFocusMuscles,
        muscoliSecondari: _selectedSecondaryMuscles,
        difficolta: _selectedDifficulty ?? 'Principiante',
        attrezzatura: _selectedEquipment ?? 'Corpo Libero',
        tipoEsercizio: _selectedExerciseType ?? 'Strength',
        patternMovimento: _selectedMovementPattern ?? 'Push',
        rangeRipetizioni: _selectedRepRange ?? '8-12',
        imageUrl: _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : null,
        noteTecniche: _techNoteController.text.trim().isNotEmpty
            ? _techNoteController.text.trim()
            : null,
        tempoEsecuzione:
            _selectedTUT ??
            (_tempoNoteController.text.trim().isNotEmpty
                ? _tempoNoteController.text.trim()
                : null),
      );

      DatabaseOperationResult result;
      if (widget.exercise != null) {
        // Update existing exercise
        result = await service.updateExercise(exercise);
      } else {
        // Add new exercise
        result = await service.addExercise(exercise);
      }

      if (mounted) {
        if (result.success) {
          SnackBarService.showSuccess(context, result.message);
          Navigator.of(context).pop(true); // Return true to indicate success
        } else {
          SnackBarService.showError(context, result.message);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, context.l10n.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTutSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context.l10n.tempoEsecuzione),
        const SizedBox(height: 8),
        TutSelector(
          initialValue: _selectedTUT ?? '3-1-2-0',
          showLabels: true,
          onChanged: (value) {
            setState(() {
              _selectedTUT = value;
            });
          },
        ),
      ],
    );
  }
}

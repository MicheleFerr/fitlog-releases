import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart' as WorkoutExercise;
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/domain/converters/exercise_converter.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/weight_settings_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/utils/weight_helper.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_details_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class ExerciseCustomizationScreen extends ConsumerStatefulWidget { // 🔥 FIX: Add callback parameter

  const ExerciseCustomizationScreen({
    super.key,
    required this.selectedExercises,
    this.onExerciseAdded, // 🔥 FIX: Optional callback
  });
  final List<Exercise> selectedExercises;
  final Function(WorkoutExercise.Exercise)? onExerciseAdded;

  @override
  ConsumerState<ExerciseCustomizationScreen> createState() => _ExerciseCustomizationScreenState();
}

class _ExerciseCustomizationScreenState extends ConsumerState<ExerciseCustomizationScreen> {
  late List<ExerciseCustomization> _customizations;

  @override
  void initState() {
    super.initState();
    _customizations = widget.selectedExercises.map((exercise) => 
      ExerciseCustomization(
        exercise: exercise,
        sets: [
          SetCustomization(setNumber: 1, weight: 0, reps: 10),
          SetCustomization(setNumber: 2, weight: 0, reps: 10),
          SetCustomization(setNumber: 3, weight: 0, reps: 10),
        ],
      )
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personalizza Esercizi (${_customizations.length})'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(AppIcons.back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: _addAllToWorkout,
            child: const Text('Aggiungi Tutti'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _customizations.length,
        itemBuilder: (context, index) {
          final customization = _customizations[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildExerciseCard(customization, index),
          );
        },
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseCustomization customization, int exerciseIndex) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customization.exercise.nome,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customization.exercise.focusDisplayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(customization.exercise.difficolta).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              customization.exercise.difficolta,
                              style: TextStyle(
                                fontSize: 10,
                                color: _getDifficultyColor(customization.exercise.difficolta),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            customization.exercise.attrezzatura,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showExerciseDetails(customization.exercise),
                  icon: const Icon(AppIcons.info),
                  tooltip: 'Dettagli Esercizio',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Sets Section
            Row(
              children: [
                Text(
                  'Set',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _addSet(exerciseIndex),
                  icon: const Icon(AppIcons.add, size: 18),
                  label: const Text('Aggiungi Set'),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Set List
            ...customization.sets.asMap().entries.map((entry) {
              final setIndex = entry.key;
              final setCustomization = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildSetRow(exerciseIndex, setIndex, setCustomization),
              );
            }),
            
            const SizedBox(height: 16),
            
            // Add Single Exercise Button (only if callback is available)
            if (widget.onExerciseAdded != null) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _addSingleExercise(exerciseIndex),
                  icon: const Icon(AppIcons.add),
                  label: const Text('Aggiungi Solo Questo Esercizio'),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Notes Section
            TextField(
              decoration: const InputDecoration(
                labelText: 'Note aggiuntive (opzionale)',
                hintText: 'Es: Concentrati sulla forma, aumenta peso la prossima volta...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
              onChanged: (value) {
                setState(() {
                  _customizations[exerciseIndex] = _customizations[exerciseIndex].copyWith(
                    notes: value.isEmpty ? null : value,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(int exerciseIndex, int setIndex, SetCustomization setCustomization) {
    return Row(
      children: [
        // Set Number
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${setCustomization.setNumber}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Weight Picker Button
        Expanded(
          child: _buildPickerButton(
            label: AppLocalizations.of(context).weight,
            value: setCustomization.weight == 0
                ? '-'
                : setCustomization.weight.toStringAsFixed(1),
            icon: AppIcons.workout,
            color: Theme.of(context).colorScheme.primary,
            onTap: () => _showWeightPicker(
              exerciseIndex,
              setIndex,
              setCustomization,
            ),
          ),
        ),

        const SizedBox(width: 8),
        const Text('×', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),

        // Reps Picker Button
        Expanded(
          child: _buildPickerButton(
            label: AppLocalizations.of(context).reps,
            value: '${setCustomization.reps}',
            icon: AppIcons.repeat,
            color: Theme.of(context).colorScheme.secondary,
            onTap: () => _showRepsPicker(exerciseIndex, setIndex, setCustomization),
          ),
        ),

        const SizedBox(width: 8),

        // Remove Set Button
        if (_customizations[exerciseIndex].sets.length > 1)
          IconButton(
            onPressed: () => _removeSet(exerciseIndex, setIndex),
            icon: const Icon(AppIcons.removeCircleOutline, size: 20),
            tooltip: 'Rimuovi Set',
          ),
      ],
    );
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final currentSets = _customizations[exerciseIndex].sets;
      final newSetNumber = currentSets.length + 1;
      final lastSet = currentSets.isNotEmpty ? currentSets.last : null;
      
      final newSet = SetCustomization(
        setNumber: newSetNumber,
        weight: lastSet?.weight ?? 0,
        reps: lastSet?.reps ?? 10,
      );
      
      _customizations[exerciseIndex] = _customizations[exerciseIndex].copyWith(
        sets: [...currentSets, newSet],
      );
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      final currentSets = List<SetCustomization>.from(_customizations[exerciseIndex].sets);
      currentSets.removeAt(setIndex);
      
      // Renumber sets
      for (int i = 0; i < currentSets.length; i++) {
        currentSets[i] = currentSets[i].copyWith(setNumber: i + 1);
      }
      
      _customizations[exerciseIndex] = _customizations[exerciseIndex].copyWith(
        sets: currentSets,
      );
    });
  }

  void _updateSet(int exerciseIndex, int setIndex, SetCustomization updatedSet) {
    setState(() {
      final currentSets = List<SetCustomization>.from(_customizations[exerciseIndex].sets);
      currentSets[setIndex] = updatedSet;
      
      _customizations[exerciseIndex] = _customizations[exerciseIndex].copyWith(
        sets: currentSets,
      );
    });
  }

  void _addSingleExercise(int exerciseIndex) {
    final customization = _customizations[exerciseIndex];
    final workoutExercise = _convertToWorkoutExercise(customization);
    
    // print('🔍 EXERCISE_CUSTOMIZATION: Adding single exercise "${customization.exercise.nome}" via callback: ${widget.onExerciseAdded != null}');
    
    // 🔥 FIX: Call the callback to trigger _addExercise in EditTemplateScreen
    if (widget.onExerciseAdded != null) {
      // print('🔥 EXERCISE_CUSTOMIZATION: Calling callback for exercise: ${workoutExercise.name}');
      widget.onExerciseAdded!(workoutExercise);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${customization.exercise.nome} aggiunto al template!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Navigate back to template screen
      Navigator.of(context).popUntil((route) => 
        route.settings.name?.contains('edit_template') == true || route.isFirst);
    } else {
      // print('❌ EXERCISE_CUSTOMIZATION: No callback available!');
    }
  }

  void _addAllToWorkout() {
    for (final customization in _customizations) {
      final workoutExercise = _convertToWorkoutExercise(customization);
      
      // 🔥 FIX: Use callback if available, otherwise fallback to provider
      if (widget.onExerciseAdded != null) {
        widget.onExerciseAdded!(workoutExercise);
      } else {
        ref.read(currentWorkoutProvider.notifier).addExercise(workoutExercise);
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_customizations.length} esercizi aggiunti alla scheda!'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
    
    // Go back - different behavior based on context
    if (widget.onExerciseAdded != null) {
      // We're in template editing mode, go back exactly 2 steps (this screen + search screen)
      Navigator.of(context).pop(); // Pop customization screen
      Navigator.of(context).pop(); // Pop search screen -> back to template editor
    } else {
      // We're in normal workout mode, go back to workout screen
      Navigator.of(context).popUntil((route) => route.settings.name == '/workout' || route.isFirst);
    }
  }

  WorkoutExercise.Exercise _convertToWorkoutExercise(ExerciseCustomization customization) {
    // Convert custom sets to workout sets
    final sets = customization.sets.map((setCustomization) =>
      WorkoutExercise.ExerciseSet(
        setNumber: setCustomization.setNumber,
        weight: setCustomization.weight,
        reps: setCustomization.reps,
      )
    ).toList();

    // Use centralized converter with custom sets and notes
    final exercise = ExerciseConverter.fromDatabaseExerciseWithSets(
      customization.exercise,
      sets,
    );

    // Override notes ONLY if user wrote custom notes (NO fallback to noteTecniche)
    return exercise.copyWith(
      notes: customization.notes, // Note utente separate - non usare noteTecniche
    );
  }

  WorkoutExercise.ExerciseCategory _mapFocusToCategory(List<String> focus) {
    // Use centralized converter
    return ExerciseConverter.mapFocusToCategory(focus);
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'principiante':
        return Colors.green;
      case 'intermedio':
        return Colors.orange;
      case 'avanzato':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showExerciseDetails(Exercise exercise) {
    ExerciseDetailsModal.show(context, exercise);
  }

  /// ✅ Picker button widget (same as superset_builder_widget)
  Widget _buildPickerButton({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Show reps picker dialog with quick select buttons
  void _showRepsPicker(int exerciseIndex, int setIndex, SetCustomization setCustomization) {
    final theme = Theme.of(context);
    int selectedReps = setCustomization.reps;
    final controller = FixedExtentScrollController(initialItem: selectedReps - 1);

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 350,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Text(
                AppLocalizations.of(context).reps,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // ✅ Quick select buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [5, 8, 10, 12, 15].map((reps) {
                  final isSelected = selectedReps == reps;
                  return FilterChip(
                    label: Text('$reps'),
                    selected: isSelected,
                    onSelected: (_) {
                      setModalState(() => selectedReps = reps);
                      controller.animateToItem(
                        reps - 1,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    },
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.secondaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              // Picker
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: 50,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 50, // 1-50 reps
                    builder: (context, index) {
                      final reps = index + 1;
                      final isSelected = reps == selectedReps;
                      return Center(
                        child: Text(
                          reps.toString(),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
                  ),
                  onSelectedItemChanged: (index) {
                    setModalState(() => selectedReps = index + 1);
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Confirm button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    _updateSet(exerciseIndex, setIndex, setCustomization.copyWith(reps: selectedReps));
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context).confirm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show weight picker dialog with unit support (kg/lbs)
  void _showWeightPicker(
    int exerciseIndex,
    int setIndex,
    SetCustomization setCustomization,
  ) {
    final theme = Theme.of(context);
    final unit = ref.read(measurementUnitProvider);

    // Convert stored weight (kg) to display unit
    double selectedWeight = setCustomization.weight.toDisplayUnit(unit);
    final controller = FixedExtentScrollController(
      initialItem: WeightHelper.weightToIndex(selectedWeight, unit),
    );

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 380,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title and current weight
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).weight,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${WeightHelper.formatPickerWeight(selectedWeight, unit)} $unit',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quick increment buttons (custom or default from settings)
              ref.watch(weightSettingsProvider).when(
                data: (settings) {
                  final increment = settings.activeIncrement.value;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Decrement button
                      OutlinedButton.icon(
                        onPressed: () {
                          final newWeight = (selectedWeight - increment).clamp(0.0, 999.0).toDouble();
                          setModalState(() => selectedWeight = newWeight);
                          controller.animateToItem(
                            WeightHelper.weightToIndex(newWeight, unit),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                          HapticFeedback.mediumImpact();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(80, 36),
                          foregroundColor: theme.colorScheme.error,
                        ),
                        icon: const Icon(AppIcons.remove, size: 16),
                        label: Text(
                          increment.toStringAsFixed(increment.truncateToDouble() == increment ? 0 : 1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Increment button
                      FilledButton.icon(
                        onPressed: () {
                          final newWeight = (selectedWeight + increment).clamp(0.0, 999.0).toDouble();
                          setModalState(() => selectedWeight = newWeight);
                          controller.animateToItem(
                            WeightHelper.weightToIndex(newWeight, unit),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                          HapticFeedback.mediumImpact();
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(80, 36),
                        ),
                        icon: const Icon(AppIcons.add, size: 16),
                        label: Text(
                          '+${increment.toStringAsFixed(increment.truncateToDouble() == increment ? 0 : 1)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Quick jumps (10, 20, 50 for kg or similar for lbs)
                      ...WeightHelper.getQuickJumps(selectedWeight, unit).map((jump) {
                        return OutlinedButton(
                          onPressed: () {
                            final newWeight = WeightHelper.applyQuickJump(
                              currentWeight: selectedWeight,
                              jump: jump,
                              unit: unit,
                            );
                            setModalState(() => selectedWeight = newWeight);
                            controller.animateToItem(
                              WeightHelper.weightToIndex(newWeight, unit),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                            HapticFeedback.mediumImpact();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(60, 36),
                          ),
                          child: Text(
                            jump > 0 ? '+$jump' : '$jump',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: jump > 0
                                  ? theme.colorScheme.tertiary
                                  : theme.colorScheme.error,
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: WeightHelper.getQuickJumps(selectedWeight, unit).map((jump) {
                    return OutlinedButton(
                      onPressed: () {
                        final newWeight = WeightHelper.applyQuickJump(
                          currentWeight: selectedWeight,
                          jump: jump,
                          unit: unit,
                        );
                        setModalState(() => selectedWeight = newWeight);
                        controller.animateToItem(
                          WeightHelper.weightToIndex(newWeight, unit),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        HapticFeedback.mediumImpact();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(60, 36),
                      ),
                      child: Text(
                        jump > 0 ? '+$jump' : '$jump',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: jump > 0
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),
              // Picker
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: 50,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: WeightConversion.getChildCount(unit),
                    builder: (context, index) {
                      final weight = WeightHelper.indexToWeight(index, unit);
                      final isSelected = (weight - selectedWeight).abs() < 0.05;
                      final displayText = WeightHelper.formatPickerWeight(weight, unit);

                      return Center(
                        child: Text(
                          displayText,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
                  ),
                  onSelectedItemChanged: (index) {
                    setModalState(() => selectedWeight = WeightHelper.indexToWeight(index, unit));
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Confirm button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // Convert display weight back to kg for storage
                    final weightInKg = selectedWeight.fromDisplayUnit(unit);
                    _updateSet(exerciseIndex, setIndex, setCustomization.copyWith(weight: weightInKg));
                    Navigator.of(context).pop();
                    HapticFeedback.mediumImpact();
                  },
                  child: Text(AppLocalizations.of(context).confirm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Data Classes
class ExerciseCustomization {

  ExerciseCustomization({
    required this.exercise,
    required this.sets,
    this.notes,
  });
  final Exercise exercise;
  final List<SetCustomization> sets;
  final String? notes;

  ExerciseCustomization copyWith({
    Exercise? exercise,
    List<SetCustomization>? sets,
    String? notes,
  }) {
    return ExerciseCustomization(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
    );
  }
}

class SetCustomization {

  SetCustomization({
    required this.setNumber,
    required this.weight,
    required this.reps,
  });
  final int setNumber;
  final double weight;
  final int reps;

  SetCustomization copyWith({
    int? setNumber,
    double? weight,
    int? reps,
  }) {
    return SetCustomization(
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
    );
  }
}

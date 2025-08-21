import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/exercise.dart';
import '../../../workout/domain/entities/exercise.dart' as WorkoutExercise;
import '../../../workout/presentation/providers/workout_provider.dart';

class ExerciseCustomizationScreen extends ConsumerStatefulWidget {
  final List<Exercise> selectedExercises;
  final Function(WorkoutExercise.Exercise)? onExerciseAdded; // 🔥 FIX: Add callback parameter

  const ExerciseCustomizationScreen({
    super.key,
    required this.selectedExercises,
    this.onExerciseAdded, // 🔥 FIX: Optional callback
  });

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
          icon: const Icon(Icons.arrow_back),
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
                  icon: const Icon(Icons.info_outline),
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
                  icon: const Icon(Icons.add, size: 18),
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
                  icon: const Icon(Icons.add),
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
        
        // Weight Input
        Expanded(
          child: TextFormField(
            initialValue: setCustomization.weight.toString(),
            decoration: const InputDecoration(
              labelText: 'Peso (kg)',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final weight = double.tryParse(value) ?? 0;
              _updateSet(exerciseIndex, setIndex, setCustomization.copyWith(weight: weight));
            },
          ),
        ),
        
        const SizedBox(width: 8),
        const Text('×', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        
        // Reps Input
        Expanded(
          child: TextFormField(
            initialValue: setCustomization.reps.toString(),
            decoration: const InputDecoration(
              labelText: 'Rip.',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final reps = int.tryParse(value) ?? 0;
              _updateSet(exerciseIndex, setIndex, setCustomization.copyWith(reps: reps));
            },
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Remove Set Button
        if (_customizations[exerciseIndex].sets.length > 1)
          IconButton(
            onPressed: () => _removeSet(exerciseIndex, setIndex),
            icon: const Icon(Icons.remove_circle_outline, size: 20),
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
    
    print('🔍 EXERCISE_CUSTOMIZATION: Adding single exercise "${customization.exercise.nome}" via callback: ${widget.onExerciseAdded != null}');
    
    // 🔥 FIX: Call the callback to trigger _addExercise in EditTemplateScreen
    if (widget.onExerciseAdded != null) {
      print('🔥 EXERCISE_CUSTOMIZATION: Calling callback for exercise: ${workoutExercise.name}');
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
      print('❌ EXERCISE_CUSTOMIZATION: No callback available!');
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
    final category = _mapFocusToCategory(customization.exercise.focus);
    
    return WorkoutExercise.Exercise(
      name: customization.exercise.nome,
      type: WorkoutExercise.ExerciseType.single,
      category: category,
      notes: customization.notes ?? customization.exercise.noteTecniche,
      sets: customization.sets.map((setCustomization) => 
        WorkoutExercise.ExerciseSet(
          setNumber: setCustomization.setNumber,
          weight: setCustomization.weight,
          reps: setCustomization.reps,
        )
      ).toList(),
    );
  }

  WorkoutExercise.ExerciseCategory _mapFocusToCategory(List<String> focus) {
    if (focus.any((f) => ['PETTO', 'CHEST'].contains(f.toUpperCase()))) {
      return WorkoutExercise.ExerciseCategory.chest;
    }
    if (focus.any((f) => ['DORSO', 'BACK', 'LAT'].contains(f.toUpperCase()))) {
      return WorkoutExercise.ExerciseCategory.back;
    }
    if (focus.any((f) => ['SPALLE', 'DELT', 'SHOULDERS'].contains(f.toUpperCase()))) {
      return WorkoutExercise.ExerciseCategory.shoulders;
    }
    if (focus.any((f) => ['BICIPITI', 'TRICIPITI', 'ARMS', 'BRACCI'].contains(f.toUpperCase()))) {
      return WorkoutExercise.ExerciseCategory.arms;
    }
    if (focus.any((f) => ['QUAD', 'GLUT', 'FEMOR', 'POLP', 'LEGS'].contains(f.toUpperCase()))) {
      return WorkoutExercise.ExerciseCategory.legs;
    }
    if (focus.any((f) => ['CORE', 'ADDOME', 'ABS'].contains(f.toUpperCase()))) {
      return WorkoutExercise.ExerciseCategory.abs;
    }
    
    return WorkoutExercise.ExerciseCategory.other;
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  exercise.nome,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Focus: ${exercise.focusDisplayName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                
                if (exercise.noteTecniche != null) ...[
                  Text('Note Tecniche:', style: Theme.of(context).textTheme.titleSmall),
                  Text(exercise.noteTecniche!),
                  const SizedBox(height: 12),
                ],
                
                if (exercise.mobilitaPre != null) ...[
                  Text('Mobilità Pre-Workout:', style: Theme.of(context).textTheme.titleSmall),
                  Text(exercise.mobilitaPre!),
                  const SizedBox(height: 12),
                ],
                
                if (exercise.attivazionePre != null) ...[
                  Text('Attivazione Pre-Workout:', style: Theme.of(context).textTheme.titleSmall),
                  Text(exercise.attivazionePre!),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Data Classes
class ExerciseCustomization {
  final Exercise exercise;
  final List<SetCustomization> sets;
  final String? notes;

  ExerciseCustomization({
    required this.exercise,
    required this.sets,
    this.notes,
  });

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
  final int setNumber;
  final double weight;
  final int reps;

  SetCustomization({
    required this.setNumber,
    required this.weight,
    required this.reps,
  });

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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import '../../../../shared/presentation/l10n/generated/app_localizations.dart';

class SupersetExecutionSheet extends ConsumerStatefulWidget {
  final SupersetExercise superset;
  final int setIndex;
  final Function(
    Map<String, int> actualReps,
    Map<String, int> rpes,
    Map<String, double> weights,
  ) onComplete;
  
  const SupersetExecutionSheet({
    Key? key,
    required this.superset,
    required this.setIndex,
    required this.onComplete,
  }) : super(key: key);

  @override
  ConsumerState<SupersetExecutionSheet> createState() => _SupersetExecutionSheetState();
}

class _SupersetExecutionSheetState extends ConsumerState<SupersetExecutionSheet> {
  late PageController _pageController;
  late Map<String, bool> _exerciseCompleted;
  late Map<String, int> _actualReps;
  late Map<String, int> _rpes;
  late Map<String, double> _weights;
  late Map<String, FixedExtentScrollController> _weightControllers;
  late Map<String, FixedExtentScrollController> _repsControllers;
  late Map<String, FixedExtentScrollController> _rpeControllers;
  
  int _currentPage = 0;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _exerciseCompleted = {};
    _actualReps = {};
    _rpes = {};
    _weights = {};
    _weightControllers = {};
    _repsControllers = {};
    _rpeControllers = {};
    
    // Initialize values for each exercise
    for (final exercise in widget.superset.exercises) {
      _exerciseCompleted[exercise.id] = false;
      
      if (widget.setIndex < exercise.sets.length) {
        final set = exercise.sets[widget.setIndex];
        final weight = set.weight ?? 0.0;
        final reps = set.reps ?? 10;
        final rpe = 7; // Default RPE
        
        _actualReps[exercise.id] = reps;
        _weights[exercise.id] = weight;
        _rpes[exercise.id] = rpe;
        
        // Initialize controllers
        _weightControllers[exercise.id] = FixedExtentScrollController(
          initialItem: (weight * 2).round().clamp(0, 400)
        );
        _repsControllers[exercise.id] = FixedExtentScrollController(
          initialItem: (reps - 1).clamp(0, 49)
        );
        _rpeControllers[exercise.id] = FixedExtentScrollController(
          initialItem: (rpe - 1).clamp(0, 9)
        );
      }
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _weightControllers.values) {
      controller.dispose();
    }
    for (final controller in _repsControllers.values) {
      controller.dispose();
    }
    for (final controller in _rpeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  
  bool get _allExercisesCompleted => 
    _exerciseCompleted.values.every((completed) => completed);
  
  Exercise get _currentExercise => widget.superset.exercises[_currentPage];
  
  void _toggleExerciseComplete(String exerciseId) {
    setState(() {
      _exerciseCompleted[exerciseId] = !(_exerciseCompleted[exerciseId] ?? false);
    });
    HapticFeedback.mediumImpact();
  }
  
  void _quickAdjustWeight(String exerciseId, double increment) {
    setState(() {
      final currentWeight = _weights[exerciseId] ?? 0.0;
      final newWeight = (currentWeight + increment).clamp(0, 200);
      _weights[exerciseId] = newWeight;
      
      final weightIndex = (newWeight * 2).round().clamp(0, 400);
      _weightControllers[exerciseId]?.animateToItem(
        weightIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
    HapticFeedback.lightImpact();
  }
  
  void _quickAdjustReps(String exerciseId, int increment) {
    setState(() {
      final currentReps = _actualReps[exerciseId] ?? 1;
      final newReps = (currentReps + increment).clamp(1, 50);
      _actualReps[exerciseId] = newReps;
      
      final repsIndex = (newReps - 1).clamp(0, 49);
      _repsControllers[exerciseId]?.animateToItem(
        repsIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
    HapticFeedback.lightImpact();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.repeat,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.superset.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Set ${widget.setIndex + 1} di ${widget.superset.sets.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Exercises list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: widget.superset.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = widget.superset.exercises[index];
                  final isCompleted = _exerciseCompleted[exercise.id] ?? false;
                  
                  if (widget.setIndex >= exercise.sets.length) {
                    return const SizedBox.shrink();
                  }
                  
                  final set = exercise.sets[widget.setIndex];
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isCompleted 
                      ? Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3)
                      : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Exercise header
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: isCompleted
                                    ? Icon(
                                        Icons.check,
                                        size: 18,
                                        color: Theme.of(context).colorScheme.onSecondary,
                                      )
                                    : Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.name,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    Text(
                                      'Target: ${set.weight?.toStringAsFixed(1) ?? '0'} kg × ${set.reps ?? 0} reps',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Input fields
                          Row(
                            children: [
                              // Weight input
                              Expanded(
                                child: TextField(
                                  enabled: !isCompleted,
                                  decoration: InputDecoration(
                                    labelText: 'Peso (kg)',
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: isCompleted,
                                    fillColor: Theme.of(context).colorScheme.surface,
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  controller: TextEditingController(
                                    text: (_weights[exercise.id] ?? 0.0).toString(),
                                  ),
                                  onChanged: (value) {
                                    _weights[exercise.id] = double.tryParse(value) ?? 0.0;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              
                              // Reps input
                              Expanded(
                                child: TextField(
                                  enabled: !isCompleted,
                                  decoration: InputDecoration(
                                    labelText: 'Reps',
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: isCompleted,
                                    fillColor: Theme.of(context).colorScheme.surface,
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: TextEditingController(
                                    text: (_actualReps[exercise.id] ?? 0).toString(),
                                  ),
                                  onChanged: (value) {
                                    _actualReps[exercise.id] = int.tryParse(value) ?? 0;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              
                              // RPE selector
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: _rpes[exercise.id] ?? 7,
                                  decoration: InputDecoration(
                                    labelText: 'RPE',
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: isCompleted,
                                    fillColor: Theme.of(context).colorScheme.surface,
                                  ),
                                  items: List.generate(11, (i) => i).map((rpe) {
                                    return DropdownMenuItem(
                                      value: rpe,
                                      child: Text(
                                        rpe.toString(),
                                        style: TextStyle(
                                          color: _getRpeColor(rpe),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: isCompleted ? null : (value) {
                                    setState(() {
                                      _rpes[exercise.id] = value ?? 7;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Complete exercise button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isCompleted ? null : () {
                                setState(() {
                                  _exerciseCompleted[exercise.id] = true;
                                });
                                HapticFeedback.lightImpact();
                              },
                              icon: Icon(isCompleted ? Icons.check : Icons.fitness_center),
                              label: Text(isCompleted ? 'Completato' : 'Completa Esercizio'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCompleted 
                                  ? Theme.of(context).colorScheme.secondaryContainer
                                  : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Bottom actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Progress indicator
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progresso',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: _exerciseCompleted.values.where((c) => c).length / 
                                 _exerciseCompleted.length,
                          backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Complete superset button
                  FilledButton.icon(
                    onPressed: _allExercisesCompleted ? () {
                      widget.onComplete(_actualReps, _rpes, _weights);
                      Navigator.pop(context);
                    } : null,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Completa Superset'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getRpeColor(int rpe) {
    if (rpe <= 4) return Colors.green;
    if (rpe <= 6) return Colors.lightGreen;
    if (rpe <= 7) return Colors.yellow.shade700;
    if (rpe <= 8) return Colors.orange;
    if (rpe <= 9) return Colors.deepOrange;
    return Colors.red;
  }
}
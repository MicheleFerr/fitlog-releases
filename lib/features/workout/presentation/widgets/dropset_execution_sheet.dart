import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';

class DropSetExecutionSheet extends ConsumerStatefulWidget {
  final DropSetExercise dropset;
  final int setIndex;
  final Function(
    List<double> weights,
    List<int> actualReps,
    List<int> rpes,
  ) onComplete;

  const DropSetExecutionSheet({
    super.key,
    required this.dropset,
    required this.setIndex,
    required this.onComplete,
  });

  @override
  ConsumerState<DropSetExecutionSheet> createState() => _DropSetExecutionSheetState();
}

class _DropSetExecutionSheetState extends ConsumerState<DropSetExecutionSheet> {
  final Map<int, TextEditingController> _weightControllers = {};
  final Map<int, TextEditingController> _repsControllers = {};
  final Map<int, int> _rpes = {};
  final Map<int, bool> _completedDrops = {};
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }
  
  void _initializeControllers() {
    for (int i = 0; i < widget.dropset.stages.length; i++) {
      final stage = widget.dropset.stages[i];
      _weightControllers[i] = TextEditingController(
        text: stage.weight > 0 ? stage.weight.toString() : '',
      );
      _repsControllers[i] = TextEditingController(
        text: stage.targetReps > 0 ? stage.targetReps.toString() : '',
      );
      _rpes[i] = 7; // Default RPE
      _completedDrops[i] = false;
    }
  }
  
  @override
  void dispose() {
    _weightControllers.values.forEach((c) => c.dispose());
    _repsControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }
  
  bool get _canComplete => _completedDrops.values.every((completed) => completed);
  
  double get _completionProgress {
    final completed = _completedDrops.values.where((c) => c).length;
    return completed / widget.dropset.stages.length;
  }
  
  void _toggleDropCompletion(int index) {
    setState(() {
      _completedDrops[index] = !_completedDrops[index]!;
    });
    HapticFeedback.lightImpact();
  }
  
  void _completeDropSet() {
    final weights = <double>[];
    final actualReps = <int>[];
    final rpes = <int>[];
    
    for (int i = 0; i < widget.dropset.stages.length; i++) {
      weights.add(double.tryParse(_weightControllers[i]!.text) ?? 0);
      actualReps.add(int.tryParse(_repsControllers[i]!.text) ?? 0);
      rpes.add(_rpes[i] ?? 7);
    }
    
    widget.onComplete(weights, actualReps, rpes);
    Navigator.pop(context);
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
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'DROPSET',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.error,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Set ${widget.setIndex + 1}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.dropset.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  
                  // Progress bar
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progresso Drops',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${(_completionProgress * 100).toInt()}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _completionProgress,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Drops list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: widget.dropset.stages.length,
                itemBuilder: (context, index) {
                  final stage = widget.dropset.stages[index];
                  final isCompleted = _completedDrops[index] ?? false;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isCompleted 
                        ? Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drop header
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).colorScheme.error.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isCompleted
                                          ? Theme.of(context).colorScheme.onSecondary
                                          : Theme.of(context).colorScheme.error,
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
                                      index == 0 ? 'Serie Principale' : 'Drop ${index}',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (stage.percentageOfMax != null)
                                      Text(
                                        '${stage.percentageOfMax}% del massimale',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _toggleDropCompletion(index),
                                icon: Icon(
                                  isCompleted 
                                      ? Icons.check_circle 
                                      : Icons.radio_button_unchecked,
                                  color: isCompleted
                                      ? Theme.of(context).colorScheme.secondary
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Weight and reps inputs
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _weightControllers[index],
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Peso (kg)',
                                    prefixIcon: const Icon(Icons.fitness_center, size: 20),
                                    border: const OutlineInputBorder(),
                                    isDense: true,
                                    enabled: !isCompleted,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _repsControllers[index],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Reps',
                                    hintText: 'Target: ${stage.targetReps}',
                                    prefixIcon: const Icon(Icons.repeat, size: 20),
                                    border: const OutlineInputBorder(),
                                    isDense: true,
                                    enabled: !isCompleted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // RPE selector
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RPE (Sforzo Percepito)',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(6, (i) {
                                  final rpe = i + 5;
                                  return InkWell(
                                    onTap: isCompleted ? null : () {
                                      setState(() {
                                        _rpes[index] = rpe;
                                      });
                                      HapticFeedback.selectionClick();
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _rpes[index] == rpe
                                            ? _getRPEColor(rpe)
                                            : Theme.of(context).colorScheme.surfaceVariant,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          rpe.toString(),
                                          style: TextStyle(
                                            fontWeight: _rpes[index] == rpe
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: _rpes[index] == rpe
                                                ? Colors.white
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                          
                          // Important note for dropsets
                          if (index < widget.dropset.stages.length - 1) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Nessun riposo! Riduci il peso e continua subito',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Complete button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _canComplete ? _completeDropSet : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Completa Dropset'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getRPEColor(int rpe) {
    if (rpe <= 6) return Colors.green;
    if (rpe <= 7) return Colors.lightGreen;
    if (rpe <= 8) return Colors.orange;
    if (rpe <= 9) return Colors.deepOrange;
    return Colors.red;
  }
}
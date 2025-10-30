import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

class WarmupSet {

  WarmupSet({
    required this.percentage,
    required this.weight,
    required this.reps,
    this.notes,
    this.completed = false,
  });
  final int percentage;
  final double weight;
  final int reps;
  final String? notes;
  bool completed;
}

class WarmupProgressionV2 extends StatefulWidget {

  const WarmupProgressionV2({
    super.key,
    required this.exerciseName,
    required this.workingWeight,
    this.onComplete,
  });
  final String exerciseName;
  final double workingWeight;
  final VoidCallback? onComplete;

  @override
  State<WarmupProgressionV2> createState() => _WarmupProgressionV2State();
}

class _WarmupProgressionV2State extends State<WarmupProgressionV2> {
  late List<WarmupSet> warmupSets;
  
  @override
  void initState() {
    super.initState();
    _generateWarmupSets();
  }

  void _generateWarmupSets() {
    // Standard warmup progression
    warmupSets = [
      WarmupSet(
        percentage: 40,
        weight: _roundWeight(widget.workingWeight * 0.4),
        reps: 10,
        notes: 'Focus on form and muscle activation',
      ),
      WarmupSet(
        percentage: 50,
        weight: _roundWeight(widget.workingWeight * 0.5),
        reps: 8,
        notes: 'Increase speed and power',
      ),
      WarmupSet(
        percentage: 60,
        weight: _roundWeight(widget.workingWeight * 0.6),
        reps: 5,
        notes: 'Prepare nervous system',
      ),
      WarmupSet(
        percentage: 70,
        weight: _roundWeight(widget.workingWeight * 0.7),
        reps: 3,
        notes: 'Near working weight',
      ),
      WarmupSet(
        percentage: 80,
        weight: _roundWeight(widget.workingWeight * 0.8),
        reps: 2,
        notes: 'Final preparation',
      ),
      WarmupSet(
        percentage: 90,
        weight: _roundWeight(widget.workingWeight * 0.9),
        reps: 1,
        notes: 'Ready for working sets!',
      ),
    ];
  }

  double _roundWeight(double weight) {
    // Round to nearest 2.5kg
    return (weight / 2.5).round() * 2.5;
  }

  void _editWeight(int index) async {
    final TextEditingController controller = TextEditingController(
      text: warmupSets[index].weight.toStringAsFixed(1),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${warmupSets[index].percentage}% - Adjust Weight'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            suffixText: 'kg',
            border: OutlineInputBorder(),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              final newWeight = double.tryParse(controller.text);
              if (newWeight != null && newWeight > 0) {
                setState(() {
                  warmupSets[index] = WarmupSet(
                    percentage: warmupSets[index].percentage,
                    weight: newWeight,
                    reps: warmupSets[index].reps,
                    notes: warmupSets[index].notes,
                    completed: warmupSets[index].completed,
                  );
                });
                Navigator.pop(context);
              }
            },
            child: Text(AppLocalizations.of(context).save),
          ),
        ],
      ),
    );
  }

  void _markCompleted(int index) {
    setState(() {
      warmupSets[index].completed = true;
    });

    // Check if all completed
    if (warmupSets.every((set) => set.completed)) {
      widget.onComplete?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Warmup completed! Ready for working sets 💪'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _getWarmupTip(int percentage) {
    if (percentage <= 40) return 'Focus on perfect form';
    if (percentage <= 60) return 'Activate target muscles';
    if (percentage <= 80) return 'Prepare nervous system';
    return 'Almost at working weight';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedCount = warmupSets.where((s) => s.completed).length;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.whatshot,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Warmup Progression',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.exerciseName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: completedCount / warmupSets.length,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                completedCount == warmupSets.length 
                  ? Colors.green 
                  : Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Warmup sets list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: warmupSets.length,
              itemBuilder: (context, index) {
                final set = warmupSets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: set.completed ? 0 : 1,
                  color: set.completed 
                    ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                    : null,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Percentage indicator
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: set.completed 
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: set.completed 
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.orange.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${set.percentage}%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: set.completed ? Colors.green : Colors.orange,
                                ),
                              ),
                              Text(
                                'WARMUP',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: set.completed ? Colors.green : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Weight and reps
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Weight (editable)
                                  InkWell(
                                    onTap: set.completed ? null : () => _editWeight(index),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12, 
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer
                                          .withValues(alpha: set.completed ? 0.3 : 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            set.weight.toStringAsFixed(1),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: set.completed 
                                                ? theme.colorScheme.onSurfaceVariant
                                                : theme.colorScheme.onPrimaryContainer,
                                            ),
                                          ),
                                          const Text(' kg'),
                                          if (!set.completed) ...[
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.edit,
                                              size: 14,
                                              color: theme.colorScheme.onPrimaryContainer
                                                .withValues(alpha: 0.5),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Reps (fixed)
                                  Text(
                                    '× ${set.reps} reps',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: theme.colorScheme.onSurfaceVariant,
                                      decoration: set.completed 
                                        ? TextDecoration.lineThrough 
                                        : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                set.notes ?? _getWarmupTip(set.percentage),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Action button
                        if (set.completed)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 32,
                          )
                        else
                          FilledButton.tonal(
                            onPressed: () => _markCompleted(index),
                            child: const Text('Done'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Footer info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'These warmup sets are for guidance only and will not be saved to your workout data',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
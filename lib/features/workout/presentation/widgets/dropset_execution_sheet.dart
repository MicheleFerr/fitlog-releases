import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/utils/weight_helper.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class DropSetExecutionSheet extends ConsumerStatefulWidget {

  const DropSetExecutionSheet({
    super.key,
    required this.dropset,
    required this.setIndex,
    required this.onComplete,
  });
  final DropSetExercise dropset;
  final int setIndex;
  final Function(
    List<double> weights,
    List<int> actualReps,
    List<int> rpes,
  ) onComplete;

  @override
  ConsumerState<DropSetExecutionSheet> createState() => _DropSetExecutionSheetState();
}

class _DropSetExecutionSheetState extends ConsumerState<DropSetExecutionSheet> {
  final Map<int, double> _weights = {}; // Store in kg
  final Map<int, int> _reps = {};
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
      _weights[i] = stage.weight; // Already in kg
      _reps[i] = stage.reps;
      _rpes[i] = 7; // Default RPE
      _completedDrops[i] = false;
    }
  }

  @override
  void dispose() {
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
      weights.add(_weights[i] ?? 0);
      actualReps.add(_reps[i] ?? 0);
      rpes.add(_rpes[i] ?? 7);
    }

    widget.onComplete(weights, actualReps, rpes);
    Navigator.pop(context);
  }

  void _showWeightPicker(BuildContext context, int dropIndex) {
    final unit = ref.read(measurementUnitProvider);
    double selectedWeight = (_weights[dropIndex] ?? 0).toDisplayUnit(unit);

    final controller = FixedExtentScrollController(
      initialItem: WeightHelper.weightToIndex(selectedWeight, unit),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${WeightHelper.formatPickerWeight(selectedWeight, unit)} $unit',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: controller,
                    itemExtent: 50,
                    physics: const FixedExtentScrollPhysics(),
                    diameterRatio: 1.5,
                    onSelectedItemChanged: (index) {
                      setModalState(() {
                        selectedWeight = WeightHelper.indexToWeight(index, unit);
                      });
                      HapticFeedback.selectionClick();
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: WeightConversion.getChildCount(unit),
                      builder: (context, index) {
                        final weight = WeightHelper.indexToWeight(index, unit);
                        final isSelected = weight == selectedWeight;
                        return Center(
                          child: Text(
                            WeightHelper.formatPickerWeight(weight, unit),
                            style: TextStyle(
                              fontSize: isSelected ? 28 : 20,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _weights[dropIndex] = selectedWeight.fromDisplayUnit(unit);
                        });
                        Navigator.pop(context);
                        HapticFeedback.mediumImpact();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(AppLocalizations.of(context).confirm),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRepsPicker(BuildContext context, int dropIndex) {
    int selectedReps = _reps[dropIndex] ?? widget.dropset.stages[dropIndex].reps;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$selectedReps ${AppLocalizations.of(context).reps}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: FixedExtentScrollController(
                      initialItem: selectedReps - 1,
                    ),
                    itemExtent: 50,
                    physics: const FixedExtentScrollPhysics(),
                    diameterRatio: 1.5,
                    onSelectedItemChanged: (index) {
                      setModalState(() => selectedReps = index + 1);
                      HapticFeedback.selectionClick();
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 30,
                      builder: (context, index) {
                        final reps = index + 1;
                        final isSelected = reps == selectedReps;
                        return Center(
                          child: Text(
                            reps.toString(),
                            style: TextStyle(
                              fontSize: isSelected ? 28 : 20,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        setState(() => _reps[dropIndex] = selectedReps);
                        Navigator.pop(context);
                        HapticFeedback.mediumImpact();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(AppLocalizations.of(context).confirm),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
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
                                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
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
                        icon: const SemanticIcon(
  icon: AppIcons.close,
  semanticLabel: 'Close',
),
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
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                        ? Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3)
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
                                      : Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
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
                                      index == 0 ? 'Serie Principale' : 'Drop $index',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _toggleDropCompletion(index),
                                icon: Icon(
                                  isCompleted 
                                      ? AppIcons.checkCircle 
                                      : AppIcons.radioButtonUnchecked,
                                  color: isCompleted
                                      ? Theme.of(context).colorScheme.secondary
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Weight and reps picker buttons
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: isCompleted ? null : () => _showWeightPicker(context, index),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: isCompleted
                                          ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
  size: AppIconSize.small,
  color: Theme.of(context,
).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            (_weights[index] ?? 0) > 0
                                                ? (_weights[index] ?? 0).formatWeight(ref.read(measurementUnitProvider))
                                                : AppLocalizations.of(context).selectWeight,
                                            style: Theme.of(context).textTheme.bodyLarge,
                                          ),
                                        ),
                                        if (!isCompleted)
                                          Icon(
                                            AppIcons.arrowDropDown,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: isCompleted ? null : () => _showRepsPicker(context, index),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: isCompleted
                                          ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        SemanticIcon(
  icon: AppIcons.repeat,
  semanticLabel: 'Repeat',
  size: AppIconSize.small,
  color: Theme.of(context,
).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${_reps[index] ?? stage.reps} ${AppLocalizations.of(context).reps}',
                                                style: Theme.of(context).textTheme.bodyLarge,
                                              ),
                                              if (stage.reps > 0)
                                                Text(
                                                  'Target: ${stage.reps}',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (!isCompleted)
                                          Icon(
                                            AppIcons.arrowDropDown,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                      ],
                                    ),
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
                                            : Theme.of(context).colorScheme.surfaceContainerHighest,
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
                                                ? context.colors.surface
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
                                color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  SemanticIcon(
  icon: AppIcons.warningAmberRounded,
  semanticLabel: 'Warning amber rounded',
  size: AppIconSize.tiny,
  color: Theme.of(context,
).colorScheme.error,
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
                  icon: const SemanticIcon(
  icon: AppIcons.check,
  semanticLabel: 'Check',
),
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
    if (rpe <= 6) return context.colors.success;
    if (rpe <= 7) return context.colors.success;
    if (rpe <= 8) return context.colors.secondary;
    if (rpe <= 9) return context.colors.warning;
    return context.colors.error;
  }
}

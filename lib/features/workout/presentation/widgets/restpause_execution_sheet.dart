import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/utils/weight_helper.dart';
import 'dart:async';

class RestPauseExecutionSheet extends ConsumerStatefulWidget {

  const RestPauseExecutionSheet({
    super.key,
    required this.restPause,
    required this.setIndex,
    required this.onComplete,
  });
  final RestPauseExercise restPause;
  final int setIndex;
  final Function(
    double weight,
    List<int> reps, // Reps for each mini-set
    int rpe,
  ) onComplete;

  @override
  ConsumerState<RestPauseExecutionSheet> createState() => _RestPauseExecutionSheetState();
}

class _RestPauseExecutionSheetState extends ConsumerState<RestPauseExecutionSheet> {
  double _weight = 0.0; // Store in kg
  final Map<int, int> _reps = {};
  final Map<int, bool> _completedMiniSets = {};
  int _currentMiniSet = 0;
  int _rpe = 8;
  bool _isResting = false;
  int _restSeconds = 0;
  Timer? _restTimer;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }
  
  void _initializeControllers() {
    // Initialize with target weight from first set if available
    if (widget.restPause.sets.isNotEmpty && widget.setIndex < widget.restPause.sets.length) {
      final set = widget.restPause.sets[widget.setIndex];
      _weight = set.weight ?? 0.0; // Already in kg, default to 0 if null
    }

    // Initialize reps for main set + mini sets
    final totalMiniSets = 1 + widget.restPause.miniSets; // Main set + additional mini sets
    for (int i = 0; i < totalMiniSets; i++) {
      _reps[i] = 0;
      _completedMiniSets[i] = false;
    }
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }
  
  bool get _canComplete {
    // All mini-sets must be completed
    return _completedMiniSets.values.every((completed) => completed);
  }
  
  double get _completionProgress {
    final completed = _completedMiniSets.values.where((c) => c).length;
    return completed / _completedMiniSets.length;
  }
  
  void _completeMiniSet(int index) {
    if (_reps[index] == null || _reps[index]! == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseEnterValidData),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _completedMiniSets[index] = true;
    });
    
    HapticFeedback.mediumImpact();
    
    // If not the last mini-set, start rest timer
    if (index < _completedMiniSets.length - 1) {
      _startRestTimer();
      setState(() {
        _currentMiniSet = index + 1;
      });
    }
  }
  
  void _startRestTimer() {
    setState(() {
      _isResting = true;
      _restSeconds = widget.restPause.restPauseSets.isNotEmpty
        ? widget.restPause.restPauseSets[_currentMiniSet].restSeconds
        : 15; // Default 15s if no sets defined
    });
    
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSeconds > 0) {
        setState(() {
          _restSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isResting = false;
        });
        HapticFeedback.heavyImpact();
        // Play sound notification
      }
    });
  }
  
  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _restSeconds = 0;
    });
  }
  
  void _completeRestPause() {
    final reps = <int>[];

    for (int i = 0; i < _completedMiniSets.length; i++) {
      reps.add(_reps[i] ?? 0);
    }

    widget.onComplete(_weight, reps, _rpe);
    Navigator.pop(context);
  }

  void _showWeightPicker(BuildContext context) {
    final unit = ref.read(measurementUnitProvider);
    double selectedWeight = _weight.toDisplayUnit(unit);

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
                    color: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${WeightHelper.formatPickerWeight(selectedWeight, unit)} $unit',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.tertiary,
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
                                  ? Theme.of(context).colorScheme.tertiary
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
                          _weight = selectedWeight.fromDisplayUnit(unit);
                        });
                        Navigator.pop(context);
                        HapticFeedback.mediumImpact();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
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

  void _showRepsPicker(BuildContext context, int miniSetIndex) {
    int selectedReps = _reps[miniSetIndex] ?? widget.restPause.targetReps;

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
                    color: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$selectedReps ${AppLocalizations.of(context).reps}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.tertiary,
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
                                  ? Theme.of(context).colorScheme.tertiary
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
                        setState(() => _reps[miniSetIndex] = selectedReps);
                        Navigator.pop(context);
                        HapticFeedback.mediumImpact();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
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
                                  color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  'REST-PAUSE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.tertiary,
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
                            widget.restPause.name,
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
                            'Progresso Mini-Set',
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
                          Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Rest timer display (if resting)
            if (_isResting) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'MICRO-PAUSA',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_restSeconds',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _skipRest,
                      child: const Text('Salta pausa'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Weight picker button (shared for all mini-sets)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: () => _showWeightPicker(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).weight,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _weight > 0
                                  ? _weight.formatWeight(ref.read(measurementUnitProvider))
                                  : AppLocalizations.of(context).selectWeight,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context).selectWeight,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Mini-sets list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _completedMiniSets.length,
                itemBuilder: (context, index) {
                  final isCompleted = _completedMiniSets[index] ?? false;
                  final isCurrent = index == _currentMiniSet;
                  final isLocked = index > _currentMiniSet && !isCompleted;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isCompleted 
                        ? Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3)
                        : isCurrent 
                            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2)
                            : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mini-set header
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? Theme.of(context).colorScheme.secondary
                                      : isCurrent
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: isCompleted
                                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                                      : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isCurrent
                                                ? Theme.of(context).colorScheme.onPrimary
                                                : Theme.of(context).colorScheme.onSurfaceVariant,
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
                                      index == 0 ? 'Serie Principale' : 'Mini-Set $index',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (index > 0 && index < widget.restPause.restPauseSets.length)
                                      Text(
                                        'Dopo ${widget.restPause.restPauseSets[index].restSeconds}s di pausa',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                  ],
                                ),
                              ),
                              if (isCurrent && !_isResting && !isCompleted)
                                FilledButton.tonal(
                                  onPressed: () => _completeMiniSet(index),
                                  child: const Text('Fatto'),
                                ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Reps picker button
                          InkWell(
                            onTap: (!isCompleted && !isLocked && !_isResting)
                                ? () => _showRepsPicker(context, index)
                                : null,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: (isCompleted || isLocked || _isResting)
                                    ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.repeat,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context).reps,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _reps[index] != null && _reps[index]! > 0
                                              ? '${_reps[index]} ${AppLocalizations.of(context).reps}'
                                              : (index == 0
                                                  ? 'Target: ${widget.restPause.targetReps}'
                                                  : AppLocalizations.of(context).selectTargetReps),
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isCompleted && !isLocked && !_isResting)
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Instructions
                          if (isCurrent && !isCompleted && !_isResting) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      index == 0 
                                          ? 'Esegui fino al cedimento o quasi'
                                          : 'Esegui il massimo numero di ripetizioni possibili',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: Theme.of(context).colorScheme.primary,
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
            
            // RPE selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RPE Complessivo (Sforzo Percepito)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (i) {
                      final rpe = i + 5;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _rpe = rpe;
                          });
                          HapticFeedback.selectionClick();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: _rpe == rpe
                                ? _getRPEColor(rpe)
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              rpe.toString(),
                              style: TextStyle(
                                fontWeight: _rpe == rpe
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _rpe == rpe
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
            ),
            
            // Complete button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _canComplete && !_isResting ? _completeRestPause : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Completa Rest-Pause'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
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
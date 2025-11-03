import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// ⚠️ DEPRECATED: Use SupersetSequentialExecutionSheet instead
///
/// This widget is deprecated because it violates the scientific superset methodology:
/// - Uses PageView allowing free navigation (should be sequential A→B)
/// - Reads from wrong data structure (exercise.sets instead of supersetSets)
/// - Allows partial completion (violates "no rest between exercises" rule)
///
/// Use [SupersetSequentialExecutionSheet] for correct superset execution flow.
@Deprecated('Use SupersetSequentialExecutionSheet instead')
class SupersetExecutionSheetV2 extends ConsumerStatefulWidget {
  
  const SupersetExecutionSheetV2({
    super.key,
    required this.superset,
    required this.setIndex,
    required this.onComplete,
  });
  final SupersetExercise superset;
  final int setIndex;
  final Function(
    Map<String, int> actualReps,
    Map<String, int> rpes,
    Map<String, double> weights,
  ) onComplete;

  @override
  ConsumerState<SupersetExecutionSheetV2> createState() => _SupersetExecutionSheetV2State();
}

class _SupersetExecutionSheetV2State extends ConsumerState<SupersetExecutionSheetV2> {
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

    // ✅ FIX: Usa supersetSets invece di exercise.sets
    // Get the current superset set
    final currentSupersetSet = widget.setIndex < widget.superset.supersetSets.length
        ? widget.superset.supersetSets[widget.setIndex]
        : null;

    // Initialize values for each exercise
    for (final exercise in widget.superset.exercises) {
      _exerciseCompleted[exercise.id] = false;

      // ✅ FIX: Get data from SupersetSet.exerciseData
      final exerciseData = currentSupersetSet?.exerciseData[exercise.id];

      if (exerciseData != null) {
        final weight = exerciseData.actualWeight ?? exerciseData.targetWeight ?? 0.0;
        final reps = exerciseData.actualReps ?? exerciseData.targetReps ?? 10;
        final rpe = exerciseData.rpe ?? 7; // Default RPE

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
      } else {
        // Fallback for new sets without data
        _actualReps[exercise.id] = 10;
        _weights[exercise.id] = 0.0;
        _rpes[exercise.id] = 7;

        _weightControllers[exercise.id] = FixedExtentScrollController(initialItem: 0);
        _repsControllers[exercise.id] = FixedExtentScrollController(initialItem: 9);
        _rpeControllers[exercise.id] = FixedExtentScrollController(initialItem: 6);
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
  
  void _toggleExerciseComplete() {
    final exerciseId = _currentExercise.id;
    setState(() {
      _exerciseCompleted[exerciseId] = !(_exerciseCompleted[exerciseId] ?? false);
    });
    HapticFeedback.mediumImpact();
  }
  
  void _quickAdjustWeight(double increment) {
    final exerciseId = _currentExercise.id;
    setState(() {
      final currentWeight = _weights[exerciseId] ?? 0.0;
      final newWeight = (currentWeight + increment).clamp(0.0, 200.0);
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
  
  void _quickAdjustReps(int increment) {
    final exerciseId = _currentExercise.id;
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
  
  void _onSave() {
    if (_allExercisesCompleted) {
      widget.onComplete(_actualReps, _rpes, _weights);
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
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
                color: context.colors.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header with navigation arrows
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Left arrow
                  IconButton(
                    onPressed: _currentPage > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: Icon(
                      AppIcons.arrowBackIos,
                      color: _currentPage > 0 
                          ? context.colors.primary
                          : context.colors.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  
                  // Title area
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _currentExercise.name,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${_currentPage + 1} di ${widget.superset.exercises.length} • Set ${widget.setIndex + 1}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  // Right arrow
                  IconButton(
                    onPressed: _currentPage < widget.superset.exercises.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: _currentPage < widget.superset.exercises.length - 1
                          ? context.colors.primary
                          : context.colors.outline.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            
            // Toggle switch "Verify Weight & Reps" 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Verify Weight & Reps',
                    style: context.textTheme.titleMedium,
                  ),
                  Switch(
                    value: !(_exerciseCompleted[_currentExercise.id] ?? false),
                    onChanged: (value) => _toggleExerciseComplete(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // PageView content
            SizedBox(
              height: 400,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: widget.superset.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = widget.superset.exercises[index];
                  final exerciseId = exercise.id;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Weight and Reps controls
                        Row(
                          children: [
                            // Weight section
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.fitness_center, 
                                        color: context.colors.primary, 
                                        size: 20
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Weight',
                                        style: context.textTheme.titleMedium?.copyWith(
                                          color: context.colors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () => _quickAdjustWeight(-2.5),
                                        icon: Icon(Icons.remove, 
                                          color: context.colors.error),
                                        style: IconButton.styleFrom(
                                          backgroundColor: context.colors.errorContainer,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: context.colors.outline),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              (_weights[exerciseId] ?? 0.0).toStringAsFixed(1),
                                              style: context.textTheme.headlineSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'kg',
                                              style: context.textTheme.bodySmall?.copyWith(
                                                color: context.colors.outline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        onPressed: () => _quickAdjustWeight(2.5),
                                        icon: Icon(Icons.add, 
                                          color: context.colors.primary),
                                        style: IconButton.styleFrom(
                                          backgroundColor: context.colors.primaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: 24),
                            
                            // Reps section
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.repeat, 
                                        color: context.colors.primary, 
                                        size: 20
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Reps',
                                        style: context.textTheme.titleMedium?.copyWith(
                                          color: context.colors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () => _quickAdjustReps(-1),
                                        icon: Icon(Icons.remove, 
                                          color: context.colors.error),
                                        style: IconButton.styleFrom(
                                          backgroundColor: context.colors.errorContainer,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: context.colors.outline),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              (_actualReps[exerciseId] ?? 1).toString(),
                                              style: context.textTheme.headlineSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: context.colors.primary,
                                              ),
                                            ),
                                            Text(
                                              '/10',
                                              style: context.textTheme.bodySmall?.copyWith(
                                                color: context.colors.outline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        onPressed: () => _quickAdjustReps(1),
                                        icon: Icon(Icons.add, 
                                          color: context.colors.primary),
                                        style: IconButton.styleFrom(
                                          backgroundColor: context.colors.primaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // RPE section
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'RPE',
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.info_outline, 
                                  color: context.colors.outline, 
                                  size: 20
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Quanto è stata difficile questa serie?',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.outline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            
                            // RPE buttons
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: List.generate(5, (index) {
                                final rpeValue = index + 6;
                                final isSelected = (_rpes[exerciseId] ?? 7) == rpeValue;
                                final emoji = ['😌', '🙂', '😤', '😵', '🤯'][index];
                                final label = ['Very\nEasy', 'Easy', 'Moderate', 'Hard', 'Max'][index];
                                
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _rpes[exerciseId] = rpeValue;
                                    });
                                    HapticFeedback.selectionClick();
                                  },
                                  child: Container(
                                    width: 60,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? context.colors.primaryContainer
                                          : context.colors.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected 
                                            ? context.colors.primary
                                            : context.colors.outline.withValues(alpha: 0.3),
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          emoji,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          rpeValue.toString(),
                                          style: context.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected 
                                                ? context.colors.primary
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          label,
                                          style: context.textTheme.bodySmall?.copyWith(
                                            fontSize: 10,
                                            color: context.colors.outline,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Bottom buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Skip RPE button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Skip RPE - just mark as completed without RPE
                        setState(() {
                          _exerciseCompleted[_currentExercise.id] = true;
                        });
                        if (_allExercisesCompleted) {
                          _onSave();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Salta RPE'),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Confirm button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _exerciseCompleted[_currentExercise.id] = true;
                        });
                        
                        if (_allExercisesCompleted) {
                          _onSave();
                        } else {
                          // Move to next exercise if not all completed
                          if (_currentPage < widget.superset.exercises.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: context.colors.primary,
                        foregroundColor: context.colors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _allExercisesCompleted 
                            ? 'Conferma Serie'
                            : 'Conferma Serie',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

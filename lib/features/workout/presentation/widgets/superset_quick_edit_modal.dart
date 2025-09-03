import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import '../providers/exercise_history_provider.dart';
import '../../../../shared/presentation/l10n/generated/app_localizations.dart';

/// Quick edit modal for superset sets - allows editing each exercise in the superset
class SupersetQuickEditModal extends ConsumerStatefulWidget {
  final SupersetExercise supersetExercise;
  final int setIndex;
  final Function(ExerciseSet) onSave;
  final VoidCallback? onCancel;
  
  const SupersetQuickEditModal({
    super.key,
    required this.supersetExercise,
    required this.setIndex,
    required this.onSave,
    this.onCancel,
  });

  static Future<void> show({
    required BuildContext context,
    required SupersetExercise supersetExercise,
    required int setIndex,
    required Function(ExerciseSet) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      builder: (context) => SupersetQuickEditModal(
        supersetExercise: supersetExercise,
        setIndex: setIndex,
        onSave: onSave,
      ),
    );
  }

  @override
  ConsumerState<SupersetQuickEditModal> createState() => _SupersetQuickEditModalState();
}

class _SupersetQuickEditModalState extends ConsumerState<SupersetQuickEditModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  late PageController _pageController;
  int _currentExerciseIndex = 0;
  
  // Data for each exercise in superset
  late List<SupersetExerciseData> _exerciseData;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize data for each exercise in superset
    final currentSet = widget.setIndex < widget.supersetExercise.sets.length 
        ? widget.supersetExercise.sets[widget.setIndex]
        : null;
        
    _exerciseData = widget.supersetExercise.exercises.map((exercise) {
      return SupersetExerciseData(
        exercise: exercise,
        weight: currentSet?.weight ?? 20.0,
        reps: currentSet?.reps ?? 10,
        rpe: currentSet?.rpe,
        isCompleted: currentSet?.isCompleted ?? false,
      );
    }).toList();
    
    _pageController = PageController();
    
    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _nextExercise() {
    if (_currentExerciseIndex < _exerciseData.length - 1) {
      _currentExerciseIndex++;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    }
  }
  
  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      _currentExerciseIndex--;
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    }
  }
  
  void _save() {
    // Create updated set with combined data from all exercises
    final currentSet = widget.setIndex < widget.supersetExercise.sets.length 
        ? widget.supersetExercise.sets[widget.setIndex]
        : ExerciseSet(setNumber: widget.setIndex + 1);
        
    // For now, use the first exercise's data as main set data
    // TODO: Properly handle multiple exercises data
    final firstExerciseData = _exerciseData.first;
    
    final updatedSet = currentSet.copyWith(
      weight: firstExerciseData.weight,
      reps: firstExerciseData.reps,
      rpe: firstExerciseData.rpe,
      isCompleted: _exerciseData.every((data) => data.isCompleted),
      completedAt: _exerciseData.every((data) => data.isCompleted) ? DateTime.now() : null,
    );
    
    HapticFeedback.mediumImpact();
    widget.onSave(updatedSet);
    Navigator.of(context).pop();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final config = ref.watch(appConfigProvider);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 4),
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Row(
                          children: [
                            // Superset indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.secondary.withValues(alpha: 0.2),
                                    colorScheme.primary.withValues(alpha: 0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.link,
                                    size: 16,
                                    color: colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Superset ${widget.setIndex + 1}',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Close button
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                widget.onCancel?.call();
                              },
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      
                      // Exercise indicator
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              '${_currentExerciseIndex + 1} of ${_exerciseData.length}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: (_currentExerciseIndex + 1) / _exerciseData.length,
                                backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Exercise pages
                      SizedBox(
                        height: 500,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentExerciseIndex = index;
                            });
                            HapticFeedback.selectionClick();
                          },
                          itemCount: _exerciseData.length,
                          itemBuilder: (context, index) {
                            final exerciseData = _exerciseData[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildExerciseEditor(
                                context,
                                exerciseData,
                                index,
                                theme,
                                colorScheme,
                                config,
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Navigation and save buttons
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Row(
                          children: [
                            // Previous button
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _currentExerciseIndex > 0 ? _previousExercise : null,
                                icon: const Icon(Icons.chevron_left),
                                label: const Text('Previous'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Next/Save button
                            Expanded(
                              flex: 2,
                              child: _currentExerciseIndex < _exerciseData.length - 1
                                  ? FilledButton.icon(
                                      onPressed: _nextExercise,
                                      icon: const Icon(Icons.chevron_right),
                                      label: const Text('Next'),
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    )
                                  : FilledButton.icon(
                                      onPressed: _save,
                                      icon: const Icon(Icons.check),
                                      label: const Text('Save Superset'),
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        backgroundColor: colorScheme.tertiary,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildExerciseEditor(
    BuildContext context,
    SupersetExerciseData exerciseData,
    int index,
    ThemeData theme,
    ColorScheme colorScheme,
    config,
  ) {
    return Column(
      children: [
        // Exercise name and info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      exerciseData.exercise.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Completion toggle
                  IconButton(
                    onPressed: () {
                      setState(() {
                        exerciseData.isCompleted = !exerciseData.isCompleted;
                      });
                      HapticFeedback.lightImpact();
                    },
                    icon: Icon(
                      exerciseData.isCompleted 
                        ? Icons.check_circle 
                        : Icons.radio_button_unchecked,
                      color: exerciseData.isCompleted 
                        ? colorScheme.tertiary 
                        : colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Category: ${exerciseData.exercise.category.name}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Weight and Reps input
        Row(
          children: [
            // Weight
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Weight (${config.measurementUnit})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          exerciseData.weight.toStringAsFixed(
                            exerciseData.weight % 1 == 0 ? 0 : 1
                          ),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: ListWheelScrollView.useDelegate(
                            controller: FixedExtentScrollController(
                              initialItem: (exerciseData.weight * 2).round(),
                            ),
                            itemExtent: 24,
                            perspective: 0.01,
                            diameterRatio: 1.5,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (weightIndex) {
                              final newWeight = weightIndex / 2.0;
                              setState(() {
                                exerciseData.weight = newWeight.clamp(0, 200);
                              });
                              HapticFeedback.selectionClick();
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 401, // 0 to 200kg in 0.5kg increments
                              builder: (context, weightIndex) {
                                final weight = weightIndex / 2.0;
                                final isSelected = (weight - exerciseData.weight).abs() < 0.1;
                                return Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    weight.toStringAsFixed(1),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isSelected 
                                          ? colorScheme.primary
                                          : colorScheme.onSurface.withValues(alpha: 0.5),
                                      fontWeight: isSelected 
                                          ? FontWeight.bold 
                                          : FontWeight.normal,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Reps
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Reps',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.secondary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${exerciseData.reps}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: ListWheelScrollView.useDelegate(
                            controller: FixedExtentScrollController(
                              initialItem: exerciseData.reps - 1,
                            ),
                            itemExtent: 24,
                            perspective: 0.01,
                            diameterRatio: 1.5,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (repsIndex) {
                              final newReps = repsIndex + 1;
                              setState(() {
                                exerciseData.reps = newReps.clamp(1, 50);
                              });
                              HapticFeedback.selectionClick();
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 50, // 1 to 50 reps
                              builder: (context, repsIndex) {
                                final reps = repsIndex + 1;
                                final isSelected = reps == exerciseData.reps;
                                return Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$reps',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isSelected 
                                          ? colorScheme.secondary
                                          : colorScheme.onSurface.withValues(alpha: 0.5),
                                      fontWeight: isSelected 
                                          ? FontWeight.bold 
                                          : FontWeight.normal,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // RPE selection
        if (exerciseData.isCompleted) ...[
          Text(
            'RPE - Rate of Perceived Exertion',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(5, (index) {
              final rpe = index + 6;
              final isSelected = exerciseData.rpe == rpe;
              
              Color chipColor;
              if (rpe <= 6) {
                chipColor = Colors.green;
              } else if (rpe <= 7) {
                chipColor = Colors.lightGreen;
              } else if (rpe <= 8) {
                chipColor = Colors.orange;
              } else if (rpe <= 9) {
                chipColor = Colors.deepOrange;
              } else {
                chipColor = Colors.red;
              }
              
              return Material(
                color: isSelected
                    ? chipColor.withValues(alpha: 0.2)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      exerciseData.rpe = isSelected ? null : rpe;
                    });
                    HapticFeedback.lightImpact();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? chipColor
                            : colorScheme.outline.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      '$rpe',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? chipColor : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
  
  Widget _buildQuickButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
    Color color,
  ) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class SupersetExerciseData {
  final Exercise exercise;
  double weight;
  int reps;
  int? rpe;
  bool isCompleted;

  SupersetExerciseData({
    required this.exercise,
    required this.weight,
    required this.reps,
    this.rpe,
    required this.isCompleted,
  });
}
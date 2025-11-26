/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/widgets
/// 🎯 Feature: workout
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - workout/domain/entities: Workout, Exercise
/// - workout/presentation/providers: WorkoutHistoryProvider
/// - shared/presentation/l10n: AppLocalizations
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_history_provider.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

class WorkoutHistoryEditor extends ConsumerStatefulWidget {

  const WorkoutHistoryEditor({
    super.key,
    required this.workout,
  });
  final Workout workout;

  @override
  ConsumerState<WorkoutHistoryEditor> createState() => _WorkoutHistoryEditorState();
}

class _WorkoutHistoryEditorState extends ConsumerState<WorkoutHistoryEditor> 
    with WidgetsBindingObserver {
  late TextEditingController _nameController;
  late DateTime _selectedDate;
  late List<Exercise> _exercises;
  final ScrollController _scrollController = ScrollController();
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;
  
  // Focus nodes for input fields - organized by exercise and set index
  final Map<String, FocusNode> _focusNodes = {};
  
  // Keep track of currently focused input for auto-scroll
  FocusNode? _currentFocusNode;
  
  // Track keyboard state for UI adjustments
  double _keyboardHeight = 0.0;
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _nameController = TextEditingController(text: widget.workout.name);
    _selectedDate = widget.workout.createdAt;
    _exercises = widget.workout.exercises.map((e) => Exercise(
      id: e.id,
      name: e.name,
      type: e.type,
      category: e.category,
      sets: e.sets.map((s) => ExerciseSet(
        id: s.id,
        setNumber: s.setNumber,
        weight: s.weight,
        reps: s.reps,
        actualReps: s.actualReps,
        rpe: s.rpe,
        isCompleted: s.isCompleted,
        isWarmup: s.isWarmup,
        restTime: s.restTime,
      )).toList(),
      notes: e.notes,
    )).toList();

    _nameController.addListener(_onContentChanged);
    
    // Initialize keyboard state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateKeyboardState();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    _scrollController.dispose();
    _currentFocusNode?.dispose();
    
    // Dispose all focus nodes
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    _focusNodes.clear();
    
    super.dispose();
  }
  
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _updateKeyboardState();
  }
  
  void _updateKeyboardState() {
    if (!mounted) return;
    
    final mediaQuery = MediaQuery.of(context);
    final newKeyboardHeight = mediaQuery.viewInsets.bottom;
    final newKeyboardVisible = newKeyboardHeight > 0;
    
    if (_keyboardHeight != newKeyboardHeight || _keyboardVisible != newKeyboardVisible) {
      setState(() {
        _keyboardHeight = newKeyboardHeight;
        _keyboardVisible = newKeyboardVisible;
      });
      
      // Flutter's SingleChildScrollView with keyboard padding handles this automatically
    }
  }
  

  void _onContentChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        // CRUCIAL: Add keyboard padding to push content above keyboard
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min, // CRUCIAL: Don't expand to full screen
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
            child: Row(
              children: [
                // Close button
                IconButton(
                  onPressed: _onClosePressed,
                  icon: const SemanticIcon(
  icon: AppIcons.close,
  semanticLabel: 'Close',
),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.editWorkout,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_hasUnsavedChanges)
                        Text(
                          l10n.unsavedChanges,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Save button
                FilledButton.icon(
                  onPressed: _hasUnsavedChanges && !_isSaving ? _saveWorkout : null,
                  icon: _isSaving 
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const SemanticIcon(
  icon: AppIcons.save,
  semanticLabel: 'Save',
  size: AppIconSize.small,
),
                  label: Text(l10n.save),
                ),
              ],
            ),
          ),

              // Content - Now directly in the main column
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Workout name
                  _buildWorkoutNameSection(theme, l10n),
                  
                  const SizedBox(height: 24),
                  
                  // Workout date
                  _buildWorkoutDateSection(theme, l10n),
                  
                  const SizedBox(height: 24),
                  
                  // Exercises header
                  _buildExercisesHeader(theme, l10n),
                  
                  const SizedBox(height: 16),
                  
                  // Exercises list
                  ..._exercises.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildExerciseCard(entry.key, entry.value, theme, l10n),
                  )),
                    // Add bottom padding for safe scrolling
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutNameSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.workoutName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: l10n.enterWorkoutName,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _buildWorkoutDateSection(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.workoutDate(_selectedDate.day, _selectedDate.month, _selectedDate.year),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.calendar,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd MMMM yyyy', 'it_IT').format(_selectedDate),
                  style: theme.textTheme.bodyLarge,
                ),
                const Spacer(),
                SemanticIcon(
  icon: AppIcons.forwardIos,
  semanticLabel: 'Forward ios',
  size: AppIconSize.tiny,
  color: theme.colorScheme.onSurfaceVariant,
),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesHeader(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Icon(
          AppIcons.workout,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.exercises,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _exercises.length.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(int index, Exercise exercise, ThemeData theme, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise header
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${exercise.sets.where((s) => s.isCompleted).length}/${exercise.sets.length} ${l10n.sets.toLowerCase()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Sets list
            ...exercise.sets.asMap().entries.map((setEntry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildSetRow(
                index,
                setEntry.key,
                setEntry.value,
                theme,
                l10n,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(int exerciseIndex, int setIndex, ExerciseSet set, ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: set.isCompleted
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: set.isWarmup
            ? Border.all(
                color: theme.colorScheme.tertiary,
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          // Set number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: set.isCompleted 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (setIndex + 1).toString(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: set.isCompleted
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Weight input
          Expanded(
            child: _buildSetInput(
              value: set.weight.toString(),
              hint: l10n.weight,
              suffix: 'kg',
              keyboardType: TextInputType.number,
              onChanged: (value) => _updateSet(exerciseIndex, setIndex, weight: value),
              theme: theme,
              exerciseIndex: exerciseIndex,
              setIndex: setIndex,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Reps input
          Expanded(
            child: _buildSetInput(
              value: set.reps.toString(),
              hint: l10n.reps,
              suffix: '',
              keyboardType: TextInputType.number,
              onChanged: (value) => _updateSet(exerciseIndex, setIndex, reps: value),
              theme: theme,
              exerciseIndex: exerciseIndex,
              setIndex: setIndex,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // RPE input
          SizedBox(
            width: 80,
            child: _buildSetInput(
              value: set.rpe?.toString() ?? '',
              hint: 'RPE',
              suffix: '',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final rpe = int.tryParse(value);
                _updateSet(exerciseIndex, setIndex, rpe: rpe);
              },
              theme: theme,
              exerciseIndex: exerciseIndex,
              setIndex: setIndex,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Completed checkbox
          InkWell(
            onTap: () => _updateSet(exerciseIndex, setIndex, isCompleted: !set.isCompleted),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                set.isCompleted ? AppIcons.checkBox : AppIcons.checkBoxOutlineBlank,
                color: set.isCompleted 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetInput({
    required String value,
    required String hint,
    required String suffix,
    required TextInputType keyboardType,
    required Function(String) onChanged,
    required ThemeData theme,
    int? exerciseIndex,
    int? setIndex,
  }) {
    // Create unique key for this input field
    final key = '${exerciseIndex}_${setIndex}_$hint';
    
    // Get or create focus node for this input
    final focusNode = _focusNodes.putIfAbsent(key, () {
      final node = FocusNode();
      
      // Simple focus tracking - Flutter will handle keyboard automatically
      node.addListener(() {
        if (node.hasFocus) {
          _currentFocusNode = node;
        }
      });
      
      return node;
    });
    
    return TextField(
      controller: TextEditingController(text: value)..selection = TextSelection.fromPosition(
        TextPosition(offset: value.length),
      ),
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffix.isNotEmpty ? suffix : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
          : null,
      onChanged: (newValue) {
        onChanged(newValue);
        _onContentChanged();
      },
      style: theme.textTheme.bodySmall,
    );
  }


  void _updateSet(int exerciseIndex, int setIndex, {
    String? weight,
    String? reps,
    int? rpe,
    bool? isCompleted,
  }) {
    setState(() {
      final exercise = _exercises[exerciseIndex];
      final set = exercise.sets[setIndex];
      
      _exercises[exerciseIndex] = exercise.copyWith(
        sets: exercise.sets.asMap().entries.map((entry) {
          if (entry.key == setIndex) {
            return set.copyWith(
              weight: weight != null ? double.tryParse(weight) ?? set.weight : set.weight,
              reps: reps != null ? int.tryParse(reps) ?? set.reps : set.reps,
              rpe: rpe ?? set.rpe,
              isCompleted: isCompleted ?? set.isCompleted,
            );
          }
          return entry.value;
        }).toList(),
      );
    });
    
    _onContentChanged();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _saveWorkout() async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    
    try {
      final updatedWorkout = Workout(
        id: widget.workout.id,
        name: _nameController.text.trim(),
        createdAt: _selectedDate,
        updatedAt: DateTime.now(),
        exercises: _exercises,
        status: widget.workout.status,
        startTime: widget.workout.startTime,
        endTime: widget.workout.endTime,
        notes: widget.workout.notes,
      );
      
      await ref.read(workoutHistoryProvider.notifier).updateWorkout(updatedWorkout);
      
      setState(() {
        _hasUnsavedChanges = false;
        _isSaving = false;
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).workoutSaved),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _isSaving = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorSavingWorkout),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _onClosePressed() {
    final l10n = AppLocalizations.of(context);
    final parentNavigator = Navigator.of(context); // Capture parent navigator before dialog

    if (_hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.unsavedChanges),
          content: Text(l10n.unsavedChangesMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                parentNavigator.pop(); // Close editor using captured parent navigator
              },
              child: Text(l10n.discard),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                _saveWorkout(); // This will close editor after saving
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }
}

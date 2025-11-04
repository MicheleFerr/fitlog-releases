/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/widgets
/// 🎯 Feature: history
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
///
/// Enhanced editor for workout history with exercise replacement support
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/features/history/presentation/providers/workout_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_replacement_modal.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class WorkoutHistoryEditorEnhanced extends ConsumerStatefulWidget {

  const WorkoutHistoryEditorEnhanced({
    super.key,
    required this.historyWorkout,
  });
  final WorkoutHistoryDetail historyWorkout;

  @override
  ConsumerState<WorkoutHistoryEditorEnhanced> createState() =>
      _WorkoutHistoryEditorEnhancedState();
}

class _WorkoutHistoryEditorEnhancedState
    extends ConsumerState<WorkoutHistoryEditorEnhanced>
    with WidgetsBindingObserver {
  late TextEditingController _nameController;
  late DateTime _selectedDate;
  late List<Exercise> _exercises;
  final ScrollController _scrollController = ScrollController();
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  final Map<String, FocusNode> _focusNodes = {};
  FocusNode? _currentFocusNode;
  double _keyboardHeight = 0.0;
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _nameController =
        TextEditingController(text: widget.historyWorkout.name);
    _selectedDate = widget.historyWorkout.completedAt;

    _exercises = widget.historyWorkout.exercises
        .map((e) => e.toExercise())
        .toList();

    _nameController.addListener(_onContentChanged);

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

    if (_keyboardHeight != newKeyboardHeight ||
        _keyboardVisible != newKeyboardVisible) {
      setState(() {
        _keyboardHeight = newKeyboardHeight;
        _keyboardVisible = newKeyboardVisible;
      });
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
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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
                    IconButton(
                      onPressed: _onClosePressed,
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                    FilledButton.icon(
                      onPressed:
                          _hasUnsavedChanges && !_isSaving ? _saveWorkout : null,
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
                          : const Icon(Icons.save, size: 18),
                      label: Text(l10n.save),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWorkoutNameSection(theme, l10n),
                    const SizedBox(height: 24),
                    _buildWorkoutDateSection(theme, l10n),
                    const SizedBox(height: 24),
                    _buildExercisesHeader(theme, l10n),
                    const SizedBox(height: 16),
                    ..._exercises.asMap().entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildExerciseCard(
                              entry.key, entry.value, theme, l10n),
                        )),
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
            prefixIcon: const Icon(Icons.fitness_center),
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
          'Date',
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
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd MMMM yyyy', 'it_IT').format(_selectedDate),
                  style: theme.textTheme.bodyLarge,
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
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
          Icons.fitness_center,
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

  Widget _buildExerciseCard(
      int index, Exercise exercise, ThemeData theme, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                IconButton(
                  icon: Icon(
                    Icons.swap_horiz_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () => _replaceExercise(index, exercise),
                  tooltip: l10n.replaceExercise,
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

  Widget _buildSetRow(int exerciseIndex, int setIndex, ExerciseSet set,
      ThemeData theme, AppLocalizations l10n) {
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
                style: TextStyle(
                  color: set.isCompleted
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSetInput(
              value: set.weight.toString(),
              hint: l10n.weight,
              suffix: 'kg',
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  _updateSet(exerciseIndex, setIndex, weight: value),
              theme: theme,
              exerciseIndex: exerciseIndex,
              setIndex: setIndex,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSetInput(
              value: set.reps.toString(),
              hint: l10n.reps,
              suffix: '',
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  _updateSet(exerciseIndex, setIndex, reps: value),
              theme: theme,
              exerciseIndex: exerciseIndex,
              setIndex: setIndex,
            ),
          ),
          const SizedBox(width: 8),
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
          InkWell(
            onTap: () => _updateSet(exerciseIndex, setIndex,
                isCompleted: !set.isCompleted),
            borderRadius: BorderRadius.circular(4),
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
    final key = '${exerciseIndex}_${setIndex}_$hint';

    final focusNode = _focusNodes.putIfAbsent(key, () {
      final node = FocusNode();

      node.addListener(() {
        if (node.hasFocus) {
          _currentFocusNode = node;
        }
      });

      return node;
    });

    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.fromPosition(
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

  void _updateSet(int exerciseIndex, int setIndex,
      {String? weight, String? reps, int? rpe, bool? isCompleted}) {
    setState(() {
      final exercise = _exercises[exerciseIndex];
      final set = exercise.sets[setIndex];

      _exercises[exerciseIndex] = exercise.copyWith(
        sets: exercise.sets.asMap().entries.map((entry) {
          if (entry.key == setIndex) {
            return set.copyWith(
              weight: weight != null
                  ? double.tryParse(weight) ?? set.weight
                  : set.weight,
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

  void _replaceExercise(int exerciseIndex, Exercise currentExercise) {
    ExerciseReplacementModal.show(
      context,
      currentExercise,
      (newExercise) {
        setState(() {
          final oldSets = _exercises[exerciseIndex].sets;
          _exercises[exerciseIndex] = newExercise.copyWith(
            sets: oldSets,
          );
          _hasUnsavedChanges = true;
        });
      },
    );
  }

  Future<void> _saveWorkout() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final updatedHistory = widget.historyWorkout.copyWith(
        name: _nameController.text.trim(),
        completedAt: _selectedDate,
        updatedAt: DateTime.now(),
        exercises: _exercises.map((e) {
          return ExerciseHistoryDetail(
            id: e.id,
            name: e.name,
            category: e.category.name,
            notes: e.notes,
            sets: e.sets.map((s) {
              return SetHistoryDetail(
                setNumber: s.setNumber,
                weight: s.weight ?? 0.0,
                reps: s.reps ?? 0,
                rpe: s.rpe ?? 0,
                restSeconds: null,
                isWarmup: s.isWarmup,
              );
            }).toList(),
            exerciseData: {},
          );
        }).toList(),
      );

      await ref
          .read(workoutHistoryOperationsProvider)
          .updateWorkout(updatedHistory);

      setState(() {
        _hasUnsavedChanges = false;
        _isSaving = false;
      });

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
    if (_hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context).unsavedChanges),
          content: Text(AppLocalizations.of(context).unsavedChangesMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context).discard),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveWorkout();
              },
              child: Text(AppLocalizations.of(context).save),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }
}
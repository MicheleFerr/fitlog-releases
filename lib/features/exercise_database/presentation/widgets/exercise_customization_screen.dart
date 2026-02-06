import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart'
    as WorkoutExercise;
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/domain/converters/exercise_converter.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/weight_settings_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/utils/weight_helper.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/widgets/exercise_details_modal.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

class ExerciseCustomizationScreen extends ConsumerStatefulWidget {
  // 🔥 FIX: Add callback parameter

  const ExerciseCustomizationScreen({
    super.key,
    required this.selectedExercises,
    this.onExerciseAdded, // 🔥 FIX: Optional callback
    this.countingModeOverrides, // ✅ User-saved counting mode preferences
  });
  final List<Exercise> selectedExercises;
  final Function(WorkoutExercise.Exercise)? onExerciseAdded;

  /// Map of exerciseId → ExerciseCountingMode from user preferences
  final Map<String, ExerciseCountingMode>? countingModeOverrides;

  @override
  ConsumerState<ExerciseCustomizationScreen> createState() =>
      _ExerciseCustomizationScreenState();
}

class _ExerciseCustomizationScreenState
    extends ConsumerState<ExerciseCustomizationScreen> {
  late List<ExerciseCustomization> _customizations;

  @override
  void initState() {
    super.initState();
    _customizations = widget.selectedExercises.map((exercise) {
      // ✅ Priority: 1. User override, 2. Database default
      final countingMode =
          widget.countingModeOverrides?[exercise.id] ?? exercise.countingMode;

      // ✅ NUOVO: Create default sets based on counting mode
      List<SetCustomization> defaultSets;
      switch (countingMode) {
        case ExerciseCountingMode.weighted:
          defaultSets = [
            SetCustomization(setNumber: 1, weight: 0, reps: 10),
            SetCustomization(setNumber: 2, weight: 0, reps: 10),
            SetCustomization(setNumber: 3, weight: 0, reps: 10),
          ];
          break;
        case ExerciseCountingMode.reps:
          defaultSets = [
            SetCustomization(setNumber: 1, weight: 0, reps: 15),
            SetCustomization(setNumber: 2, weight: 0, reps: 15),
            SetCustomization(setNumber: 3, weight: 0, reps: 15),
          ];
          break;
        case ExerciseCountingMode.time:
          defaultSets = [
            SetCustomization(setNumber: 1, seconds: 60),
            SetCustomization(setNumber: 2, seconds: 60),
            SetCustomization(setNumber: 3, seconds: 60),
          ];
          break;
      }

      return ExerciseCustomization(
        exercise: exercise,
        sets: defaultSets,
        countingMode: countingMode,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.customize} (${_customizations.length})'),
        centerTitle: true,
        leading: IconButton(
          icon: const SemanticIcon(icon: AppIcons.back, semanticLabel: 'Back'),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          Semantics(
            label: l10n.addAll,
            button: true,
            child: FilledButton.tonal(
              onPressed: _addAllToWorkout,
              child: Text(l10n.addAll),
            ),
          ),
          const SizedBox(width: 8),
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

  Widget _buildExerciseCard(
    ExerciseCustomization customization,
    int exerciseIndex,
  ) {
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
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(
                                customization.exercise.difficolta,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              customization.exercise.difficolta,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: _getDifficultyColor(
                                      customization.exercise.difficolta,
                                    ),
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
                  icon: const SemanticIcon(
                    icon: AppIcons.info,
                    semanticLabel: 'Information',
                  ),
                  tooltip: context.l10n.exerciseDetails,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ✅ Counting Mode Selector
            _buildCountingModeSelector(customization, exerciseIndex),

            const SizedBox(height: 16),

            // Rest Timer Picker (between sets)
            _buildRestTimerPicker(customization, exerciseIndex),

            const SizedBox(height: 12),

            // Rest After Exercise Picker (between exercises)
            _buildRestAfterExercisePicker(customization, exerciseIndex),

            const SizedBox(height: 16),

            // Sets Section
            Row(
              children: [
                Text(
                  context.l10n.sets.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _addSet(exerciseIndex),
                  icon: const SemanticIcon(
                    icon: AppIcons.add,
                    semanticLabel: 'Add',
                    size: AppIconSize.small,
                  ),
                  label: Text(context.l10n.addSet),
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

            // Notes Section
            TextField(
              decoration: InputDecoration(
                labelText: context.l10n.notesOptional,
                hintText: context.l10n.notesHint,
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.primary,
                    width: 2.0,
                  ),
                ),
                isDense: true,
              ),
              maxLines: 2,
              onChanged: (value) {
                setState(() {
                  _customizations[exerciseIndex] =
                      _customizations[exerciseIndex].copyWith(
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

  // ✅ Counting Mode Selector - Design coerente con picker buttons dei set
  Widget _buildCountingModeSelector(
    ExerciseCustomization customization,
    int exerciseIndex,
  ) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: _buildCountingModeButton(
            label: '${l10n.weight} × ${l10n.reps}',
            icon: AppIcons.fitnessCenter,
            isSelected: customization.countingMode == ExerciseCountingMode.weighted,
            onTap: () => _changeCountingMode(exerciseIndex, ExerciseCountingMode.weighted),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCountingModeButton(
            label: l10n.reps,
            icon: AppIcons.repeat,
            isSelected: customization.countingMode == ExerciseCountingMode.reps,
            onTap: () => _changeCountingMode(exerciseIndex, ExerciseCountingMode.reps),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCountingModeButton(
            label: l10n.duration,
            icon: AppIcons.timer,
            isSelected: customization.countingMode == ExerciseCountingMode.time,
            onTap: () => _changeCountingMode(exerciseIndex, ExerciseCountingMode.time),
          ),
        ),
      ],
    );
  }

  /// Singolo bottone per counting mode - stile coerente con picker buttons
  Widget _buildCountingModeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      label: label,
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.6)
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Rest Timer Picker - tempo di riposo tra i set
  Widget _buildRestTimerPicker(
    ExerciseCustomization customization,
    int exerciseIndex,
  ) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final hasCustomRestTime = customization.restTime != null;
    final displayValue = hasCustomRestTime
        ? _formatRestTime(customization.restTime!)
        : l10n.automatic;

    return Row(
      children: [
        Expanded(
          child: Semantics(
            label: '${l10n.restTimer}: $displayValue',
            button: true,
            child: InkWell(
              onTap: () => _showRestTimePicker(exerciseIndex, customization),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.timerOutlined,
                      size: 18,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.restTimer,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displayValue,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: hasCustomRestTime
                                  ? theme.colorScheme.tertiary
                                  : theme.colorScheme.onSurfaceVariant,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasCustomRestTime)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _customizations[exerciseIndex] =
                                _customizations[exerciseIndex].copyWith(
                              clearRestTime: true,
                            );
                          });
                        },
                        icon: Icon(
                          AppIcons.close,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        tooltip: l10n.reset,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Formatta il rest time in formato leggibile (es. "1m 30s")
  String _formatRestTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0 && remainingSeconds > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else if (minutes > 0) {
      return '${minutes}m';
    }
    return '${seconds}s';
  }

  /// Show rest time picker dialog
  void _showRestTimePicker(int exerciseIndex, ExerciseCustomization customization) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    int selectedSeconds = customization.restTime ?? 90; // Default 90s
    final controller = FixedExtentScrollController(
      initialItem: (selectedSeconds / 5).round() - 1,
    );

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 380,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Text(
                l10n.restTimer,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Quick select buttons (common rest times)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [30, 60, 90, 120, 180].map((seconds) {
                  final isSelected = selectedSeconds == seconds;
                  return FilterChip(
                    label: Text(_formatRestTime(seconds)),
                    selected: isSelected,
                    onSelected: (_) {
                      setModalState(() => selectedSeconds = seconds);
                      controller.animateToItem(
                        (seconds / 5).round() - 1,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    },
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.tertiaryContainer,
                    labelStyle: theme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onTertiaryContainer
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              // Picker (5s increments, 5s to 5min)
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: 50,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 60, // 5s to 300s (5min)
                    builder: (context, index) {
                      final seconds = (index + 1) * 5;
                      final isSelected = seconds == selectedSeconds;
                      return Center(
                        child: Text(
                          _formatRestTime(seconds),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
                  ),
                  onSelectedItemChanged: (index) {
                    setModalState(() => selectedSeconds = (index + 1) * 5);
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Confirm button
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  label: l10n.confirm,
                  button: true,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _customizations[exerciseIndex] =
                            _customizations[exerciseIndex].copyWith(
                          restTime: selectedSeconds,
                        );
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.confirm),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Rest After Exercise Picker - tempo di riposo DOPO l'esercizio (tra esercizi)
  Widget _buildRestAfterExercisePicker(
    ExerciseCustomization customization,
    int exerciseIndex,
  ) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final hasCustomRestAfter = customization.restAfterExercise != null;
    final displayValue = hasCustomRestAfter
        ? _formatRestTime(customization.restAfterExercise!)
        : l10n.automatic;

    return Row(
      children: [
        Expanded(
          child: Semantics(
            label: '${l10n.restBetweenExercises}: $displayValue',
            button: true,
            child: InkWell(
              onTap: () =>
                  _showRestAfterExercisePicker(exerciseIndex, customization),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.skipNext,
                      size: 18,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.restBetweenExercises,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displayValue,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: hasCustomRestAfter
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.onSurfaceVariant,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasCustomRestAfter)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _customizations[exerciseIndex] =
                                _customizations[exerciseIndex].copyWith(
                              clearRestAfterExercise: true,
                            );
                          });
                        },
                        icon: Icon(
                          AppIcons.close,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        tooltip: l10n.reset,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Show rest after exercise picker dialog
  void _showRestAfterExercisePicker(
    int exerciseIndex,
    ExerciseCustomization customization,
  ) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    // Get global default from config
    final appConfig = ref.read(appConfigProvider);
    int selectedSeconds =
        customization.restAfterExercise ?? appConfig.defaultRestBetweenExercises;
    final controller = FixedExtentScrollController(
      initialItem: (selectedSeconds / 5).round() - 1,
    );

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 380,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Text(
                l10n.restBetweenExercises,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Quick select buttons (common rest times)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [60, 90, 120, 180, 240].map((seconds) {
                  final isSelected = selectedSeconds == seconds;
                  return FilterChip(
                    label: Text(_formatRestTime(seconds)),
                    selected: isSelected,
                    onSelected: (_) {
                      setModalState(() => selectedSeconds = seconds);
                      controller.animateToItem(
                        (seconds / 5).round() - 1,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    },
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.secondaryContainer,
                    labelStyle: theme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              // Picker (5s increments, 5s to 5min)
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: 50,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 60, // 5s to 300s (5min)
                    builder: (context, index) {
                      final seconds = (index + 1) * 5;
                      final isSelected = seconds == selectedSeconds;
                      return Center(
                        child: Text(
                          _formatRestTime(seconds),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
                  ),
                  onSelectedItemChanged: (index) {
                    setModalState(() => selectedSeconds = (index + 1) * 5);
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Confirm button
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  label: l10n.confirm,
                  button: true,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _customizations[exerciseIndex] =
                            _customizations[exerciseIndex].copyWith(
                          restAfterExercise: selectedSeconds,
                        );
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.confirm),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Change Counting Mode Handler
  void _changeCountingMode(int exerciseIndex, ExerciseCountingMode newMode) {
    if (kDebugMode) {
      debugPrint(
        '🔍 [CustomizationScreen] _changeCountingMode: exerciseIndex=$exerciseIndex, newMode=$newMode',
      );
      debugPrint(
        '🔍 [CustomizationScreen] Before: ${_customizations[exerciseIndex].countingMode}',
      );
    }

    setState(() {
      // Update counting mode
      _customizations[exerciseIndex] = _customizations[exerciseIndex].copyWith(
        countingMode: newMode,
      );

      // Reset sets to default values for new counting mode
      final List<SetCustomization> newSets;
      switch (newMode) {
        case ExerciseCountingMode.weighted:
          newSets = _customizations[exerciseIndex].sets.map((set) {
            return SetCustomization(
              setNumber: set.setNumber,
              weight: set.weight, // Keep existing weight
              reps: set.reps, // Keep existing reps
              seconds: null, // Clear seconds
            );
          }).toList();
          break;
        case ExerciseCountingMode.reps:
          newSets = _customizations[exerciseIndex].sets.map((set) {
            return SetCustomization(
              setNumber: set.setNumber,
              weight: 0, // Clear weight (set to 0)
              reps: set.reps, // Keep existing reps
              seconds: null, // Clear seconds
            );
          }).toList();
          break;
        case ExerciseCountingMode.time:
          newSets = _customizations[exerciseIndex].sets.map((set) {
            return SetCustomization(
              setNumber: set.setNumber,
              weight: 0, // Clear weight (set to 0)
              reps: 1, // Set to 1 (will be ignored in time mode)
              seconds: set.seconds ?? 60, // Use existing or default to 60s
            );
          }).toList();
          break;
      }

      _customizations[exerciseIndex] = _customizations[exerciseIndex].copyWith(
        sets: newSets,
      );
    });

    if (kDebugMode) {
      debugPrint(
        '🔍 [CustomizationScreen] After setState: ${_customizations[exerciseIndex].countingMode}',
      );
    }
  }

  Widget _buildSetRow(
    int exerciseIndex,
    int setIndex,
    SetCustomization setCustomization,
  ) {
    final countingMode = _customizations[exerciseIndex].countingMode;

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

        // ✅ MODIFICATO: Mostra campi in base al counting mode
        if (countingMode == ExerciseCountingMode.weighted) ...[
          // Weight Picker Button (solo per weighted)
          Expanded(
            child: _buildPickerButton(
              label: AppLocalizations.of(context).weight,
              value: setCustomization.weight == 0
                  ? '-'
                  : setCustomization.weight.toStringAsFixed(1),
              icon: AppIcons.fitnessCenter,
              color: Theme.of(context).colorScheme.primary,
              onTap: () =>
                  _showWeightPicker(exerciseIndex, setIndex, setCustomization),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '×',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
        ],

        // Reps Picker Button (per weighted e reps)
        if (countingMode == ExerciseCountingMode.weighted ||
            countingMode == ExerciseCountingMode.reps)
          Expanded(
            child: _buildPickerButton(
              label: AppLocalizations.of(context).reps,
              value: '${setCustomization.reps}',
              icon: AppIcons.repeat,
              color: Theme.of(context).colorScheme.secondary,
              onTap: () =>
                  _showRepsPicker(exerciseIndex, setIndex, setCustomization),
            ),
          ),

        // Duration Picker Button (solo per time)
        if (countingMode == ExerciseCountingMode.time)
          Expanded(
            child: _buildPickerButton(
              label: AppLocalizations.of(context).duration,
              value: _formatDuration(setCustomization.seconds ?? 60),
              icon: AppIcons.timer,
              color: Theme.of(context).colorScheme.tertiary,
              onTap: () => _showDurationPicker(
                exerciseIndex,
                setIndex,
                setCustomization,
              ),
            ),
          ),

        const SizedBox(width: 8),

        // Remove Set Button
        if (_customizations[exerciseIndex].sets.length > 1)
          IconButton(
            onPressed: () => _removeSet(exerciseIndex, setIndex),
            icon: const SemanticIcon(
              icon: AppIcons.removeCircleOutline,
              semanticLabel: 'Remove circle outline',
              size: AppIconSize.small,
            ),
            tooltip: 'Rimuovi Set',
          ),
      ],
    );
  }

  // ✅ NUOVO: Format duration in mm:ss
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${seconds}s';
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
      final currentSets = List<SetCustomization>.from(
        _customizations[exerciseIndex].sets,
      );
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

  void _updateSet(
    int exerciseIndex,
    int setIndex,
    SetCustomization updatedSet,
  ) {
    setState(() {
      final currentSets = List<SetCustomization>.from(
        _customizations[exerciseIndex].sets,
      );
      currentSets[setIndex] = updatedSet;

      _customizations[exerciseIndex] = _customizations[exerciseIndex].copyWith(
        sets: currentSets,
      );
    });
  }

  void _addAllToWorkout() {
    for (final customization in _customizations) {
      if (kDebugMode) {
        debugPrint(
          '🔍 [CustomizationScreen] _addAllToWorkout: exercise=${customization.exercise.nome}, countingMode=${customization.countingMode}',
        );
      }

      final workoutExercise = _convertToWorkoutExercise(customization);

      if (kDebugMode) {
        debugPrint(
          '🔍 [CustomizationScreen] After conversion: name=${workoutExercise.name}, countingMode=${workoutExercise.countingMode}',
        );
      }

      // 🔥 FIX: Use callback if available, otherwise fallback to provider
      if (widget.onExerciseAdded != null) {
        if (kDebugMode)
          debugPrint('🔍 [CustomizationScreen] Using CALLBACK onExerciseAdded');
        widget.onExerciseAdded!(workoutExercise);
      } else {
        if (kDebugMode)
          debugPrint('🔍 [CustomizationScreen] Using PROVIDER addExercise');
        ref.read(currentWorkoutProvider.notifier).addExercise(workoutExercise);
      }
    }

    SnackBarService.showSuccess(
      context,
      context.l10n.exercisesAddedToWorkout(_customizations.length),
    );

    // Go back - different behavior based on context
    if (widget.onExerciseAdded != null) {
      // We're in template editing mode, go back exactly 2 steps (this screen + search screen)
      Navigator.of(context).pop(); // Pop customization screen
      Navigator.of(
        context,
      ).pop(); // Pop search screen -> back to template editor
    } else {
      // We're in normal workout mode, go back to workout screen
      Navigator.of(context).popUntil(
        (route) =>
            route.settings.name == AppRoutes.workoutName || route.isFirst,
      );
    }
  }

  WorkoutExercise.Exercise _convertToWorkoutExercise(
    ExerciseCustomization customization,
  ) {
    // ✅ NUOVO: Convert custom sets to workout sets with counting mode awareness
    final sets = customization.sets
        .map(
          (setCustomization) => WorkoutExercise.ExerciseSet(
            setNumber: setCustomization.setNumber,
            weight: setCustomization.weight,
            reps: setCustomization.reps,
            seconds: setCustomization
                .seconds, // ✅ NUOVO: Include seconds for time-based exercises
          ),
        )
        .toList();

    // Use centralized converter with custom sets and notes
    final exercise = ExerciseConverter.fromDatabaseExerciseWithSets(
      customization.exercise,
      sets,
    );

    // Override notes, counting mode, rest time, and rest after exercise
    final result = exercise.copyWith(
      notes: customization.notes,
      countingMode: customization.countingMode,
      restTime: customization.restTime, // Custom rest time (null = use default)
      restAfterExercise:
          customization.restAfterExercise, // Rest after exercise (null = use global)
    );
    if (kDebugMode) {
      debugPrint(
        '🔍 [CustomizationScreen] _convertToWorkoutExercise FINAL: countingMode=${result.countingMode}',
      );
    }
    return result;
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'principiante':
        return context.colors.success;
      case 'intermedio':
        return context.colors.secondary;
      case 'avanzato':
        return context.colors.error;
      default:
        return context.colors.surfaceContainerHighest;
    }
  }

  void _showExerciseDetails(Exercise exercise) {
    ExerciseDetailsModal.show(context, exercise);
  }

  /// ✅ Picker button widget - stile uniforme con counting mode selector
  Widget _buildPickerButton({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$label: $value',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header: icona + label
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Valore principale
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show reps picker dialog with quick select buttons and quick actions
  void _showRepsPicker(
    int exerciseIndex,
    int setIndex,
    SetCustomization setCustomization,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final sets = _customizations[exerciseIndex].sets;
    final isFirstSet = setIndex == 0;
    final isLastSet = setIndex == sets.length - 1;
    final hasMultipleSets = sets.length > 1;

    int selectedReps = setCustomization.reps;
    final controller = FixedExtentScrollController(
      initialItem: selectedReps - 1,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.55,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title with current value
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.reps,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$selectedReps',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quick select buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [5, 8, 10, 12, 15, 20].map((reps) {
                  final isSelected = selectedReps == reps;
                  return FilterChip(
                    label: Text('$reps'),
                    selected: isSelected,
                    onSelected: (_) {
                      setModalState(() => selectedReps = reps);
                      controller.animateToItem(
                        reps - 1,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    },
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.secondaryContainer,
                    labelStyle: theme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),

              // Quick Actions (only if multiple sets)
              if (hasMultipleSets) ...[
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Apply to all
                      _buildQuickActionChip(
                        label: l10n.applyToAll,
                        icon: AppIcons.selectAll,
                        onTap: () {
                          _applyRepsToAllSets(exerciseIndex, selectedReps);
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 8),
                      // Copy from previous (if not first set)
                      if (!isFirstSet)
                        _buildQuickActionChip(
                          label: l10n.copyFromPrevious,
                          icon: AppIcons.contentCopyRounded,
                          onTap: () {
                            final prevReps = sets[setIndex - 1].reps;
                            setModalState(() => selectedReps = prevReps);
                            controller.animateToItem(
                              prevReps - 1,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      if (!isFirstSet) const SizedBox(width: 8),
                      // Apply to following (if not last set)
                      if (!isLastSet)
                        _buildQuickActionChip(
                          label: l10n.following,
                          icon: AppIcons.arrowForward,
                          onTap: () {
                            _applyRepsToFollowingSets(
                              exerciseIndex,
                              setIndex,
                              selectedReps,
                            );
                            Navigator.of(context).pop();
                          },
                        ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),
              // Picker
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: 50,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 50, // 1-50 reps
                    builder: (context, index) {
                      final reps = index + 1;
                      final isSelected = reps == selectedReps;
                      return Center(
                        child: Text(
                          reps.toString(),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
                  ),
                  onSelectedItemChanged: (index) {
                    setModalState(() => selectedReps = index + 1);
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Confirm button
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  label: l10n.confirm,
                  button: true,
                  child: FilledButton(
                    onPressed: () {
                      _updateSet(
                        exerciseIndex,
                        setIndex,
                        setCustomization.copyWith(reps: selectedReps),
                      );
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.confirm),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Quick action chip for reps picker
  Widget _buildQuickActionChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Apply reps to all sets of an exercise
  void _applyRepsToAllSets(int exerciseIndex, int reps) {
    setState(() {
      final currentSets = _customizations[exerciseIndex].sets;
      final updatedSets = currentSets.map((set) {
        return set.copyWith(reps: reps);
      }).toList();

      _customizations[exerciseIndex] = _customizations[exerciseIndex].copyWith(
        sets: updatedSets,
      );
    });

    SnackBarService.showSuccess(
      context,
      context.l10n.applyToAll,
    );
  }

  /// Apply reps to following sets (from setIndex onwards)
  void _applyRepsToFollowingSets(int exerciseIndex, int fromSetIndex, int reps) {
    setState(() {
      final currentSets = List<SetCustomization>.from(
        _customizations[exerciseIndex].sets,
      );

      // Update current and all following sets
      for (int i = fromSetIndex; i < currentSets.length; i++) {
        currentSets[i] = currentSets[i].copyWith(reps: reps);
      }

      _customizations[exerciseIndex] = _customizations[exerciseIndex].copyWith(
        sets: currentSets,
      );
    });
  }

  /// ✅ NUOVO: Show duration picker dialog with quick select buttons
  void _showDurationPicker(
    int exerciseIndex,
    int setIndex,
    SetCustomization setCustomization,
  ) {
    final theme = Theme.of(context);
    int selectedSeconds = setCustomization.seconds ?? 60;
    final controller = FixedExtentScrollController(
      initialItem: (selectedSeconds / 5).round() - 1, // 5s increments
    );

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 350,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Text(
                AppLocalizations.of(context).duration,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // ✅ Quick select buttons (common durations)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [15, 30, 45, 60, 90].map((seconds) {
                  final isSelected = selectedSeconds == seconds;
                  return FilterChip(
                    label: Text(_formatDuration(seconds)),
                    selected: isSelected,
                    onSelected: (_) {
                      setModalState(() => selectedSeconds = seconds);
                      controller.animateToItem(
                        (seconds / 5).round() - 1,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    },
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.tertiaryContainer,
                    labelStyle: theme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onTertiaryContainer
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              // Picker (5s increments, 5s to 5min)
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: 50,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 60, // 5s to 300s (5min)
                    builder: (context, index) {
                      final seconds = (index + 1) * 5;
                      final isSelected = seconds == selectedSeconds;
                      return Center(
                        child: Text(
                          _formatDuration(seconds),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
                  ),
                  onSelectedItemChanged: (index) {
                    setModalState(() => selectedSeconds = (index + 1) * 5);
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Confirm button
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  label: AppLocalizations.of(context).confirm,
                  button: true,
                  child: FilledButton(
                    onPressed: () {
                      _updateSet(
                        exerciseIndex,
                        setIndex,
                        setCustomization.copyWith(seconds: selectedSeconds),
                      );
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context).confirm),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show weight picker dialog with unit support (kg/lbs) and exercise history
  void _showWeightPicker(
    int exerciseIndex,
    int setIndex,
    SetCustomization setCustomization,
  ) {
    final theme = Theme.of(context);
    final unit = ref.read(measurementUnitProvider);
    final exerciseName = _customizations[exerciseIndex].exercise.nome;

    // Convert stored weight (kg) to display unit
    double selectedWeight = setCustomization.weight.toDisplayUnit(unit);
    final controller = FixedExtentScrollController(
      initialItem: WeightHelper.weightToIndex(selectedWeight, unit),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.65,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title and current weight
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).weight,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${WeightHelper.formatPickerWeight(selectedWeight, unit)} $unit',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 🆕 History section - Quick fill from previous workouts
              Consumer(
                builder: (context, ref, _) {
                  final historyAsync = ref.watch(
                    recentWeightsWithDetailsProvider(exerciseName),
                  );

                  return historyAsync.when(
                    data: (historyList) {
                      if (historyList.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SemanticIcon(
                                icon: AppIcons.historyRounded,
                                semanticLabel: 'History',
                                size: AppIconSize.small,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context).recentWeights,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 56,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: historyList.length.clamp(0, 5),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final historyItem = historyList[index];
                                final weight = historyItem.weight ?? 0;
                                final reps = historyItem.reps ?? 0;
                                final daysAgo = DateTime.now()
                                    .difference(historyItem.date)
                                    .inDays;

                                // Format relative date
                                String dateLabel;
                                if (daysAgo == 0) {
                                  dateLabel = AppLocalizations.of(
                                    context,
                                  ).today;
                                } else if (daysAgo == 1) {
                                  dateLabel = AppLocalizations.of(
                                    context,
                                  ).yesterday;
                                } else if (daysAgo < 7) {
                                  dateLabel = AppLocalizations.of(
                                    context,
                                  ).daysAgo(daysAgo);
                                } else {
                                  dateLabel = DateFormat(
                                    'd MMM',
                                  ).format(historyItem.date);
                                }

                                // Convert to display unit
                                final displayWeight = weight.toDisplayUnit(
                                  unit,
                                );
                                final isSelected =
                                    (displayWeight - selectedWeight).abs() <
                                    0.05;

                                return Material(
                                  color: context.colors.surface.withValues(
                                    alpha: 0,
                                  ),
                                  child: Semantics(
                                    label: 'Select weight $displayWeight $unit',
                                    button: true,
                                    child: InkWell(
                                      onTap: () {
                                        setModalState(
                                          () => selectedWeight = displayWeight,
                                        );
                                        controller.animateToItem(
                                          WeightHelper.weightToIndex(
                                            displayWeight,
                                            unit,
                                          ),
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                        HapticFeedback.mediumImpact();
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? theme.colorScheme.primaryContainer
                                            : theme
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.outline
                                                    .withValues(alpha: 0.3),
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${WeightHelper.formatPickerWeight(displayWeight, unit)}$unit',
                                                style: theme
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isSelected
                                                          ? theme
                                                                .colorScheme
                                                                .primary
                                                          : theme
                                                                .colorScheme
                                                                .onSurface,
                                                    ),
                                              ),
                                              if (reps > 0) ...[
                                                Text(
                                                  ' × $reps',
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: isSelected
                                                            ? theme
                                                                  .colorScheme
                                                                  .primary
                                                                  .withValues(
                                                                    alpha: 0.8,
                                                                  )
                                                            : theme
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                      ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          Text(
                                            dateLabel,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                  fontSize: 10,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                    loading: () => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        height: 56,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, __) => Container(
                            width: 80,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
              ),

              // Quick increment buttons (custom or default from settings)
              ref
                  .watch(weightSettingsProvider)
                  .when(
                    data: (settings) {
                      final increment = settings.activeIncrement.value;
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Decrement button
                          OutlinedButton.icon(
                            onPressed: () {
                              final newWeight = (selectedWeight - increment)
                                  .clamp(0.0, 999.0)
                                  .toDouble();
                              setModalState(() => selectedWeight = newWeight);
                              controller.animateToItem(
                                WeightHelper.weightToIndex(newWeight, unit),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                              HapticFeedback.mediumImpact();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: const Size(80, 36),
                              foregroundColor: theme.colorScheme.error,
                            ),
                            icon: const SemanticIcon(
                              icon: AppIcons.remove,
                              semanticLabel: 'Remove',
                              size: AppIconSize.tiny,
                            ),
                            label: Text(
                              increment.toStringAsFixed(
                                increment.truncateToDouble() == increment
                                    ? 0
                                    : 1,
                              ),
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Increment button
                          FilledButton.icon(
                            onPressed: () {
                              final newWeight = (selectedWeight + increment)
                                  .clamp(0.0, 999.0)
                                  .toDouble();
                              setModalState(() => selectedWeight = newWeight);
                              controller.animateToItem(
                                WeightHelper.weightToIndex(newWeight, unit),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                              HapticFeedback.mediumImpact();
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: const Size(80, 36),
                            ),
                            icon: const SemanticIcon(
                              icon: AppIcons.add,
                              semanticLabel: 'Add',
                              size: AppIconSize.tiny,
                            ),
                            label: Text(
                              '+${increment.toStringAsFixed(increment.truncateToDouble() == increment ? 0 : 1)}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Quick jumps (10, 20, 50 for kg or similar for lbs)
                          ...WeightHelper.getQuickJumps(
                            selectedWeight,
                            unit,
                          ).map((jump) {
                            return Semantics(
                              label: '${jump > 0 ? 'Add' : 'Remove'} ${jump.abs()} weight',
                              button: true,
                              child: OutlinedButton(
                                onPressed: () {
                                  final newWeight = WeightHelper.applyQuickJump(
                                    currentWeight: selectedWeight,
                                    jump: jump,
                                    unit: unit,
                                  );
                                  setModalState(() => selectedWeight = newWeight);
                                  controller.animateToItem(
                                    WeightHelper.weightToIndex(newWeight, unit),
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                  HapticFeedback.mediumImpact();
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  minimumSize: const Size(60, 36),
                                ),
                                child: Text(
                                  jump > 0 ? '+$jump' : '$jump',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: jump > 0
                                        ? theme.colorScheme.tertiary
                                        : theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: WeightHelper.getQuickJumps(selectedWeight, unit)
                          .map((jump) {
                            return OutlinedButton(
                              onPressed: () {
                                final newWeight = WeightHelper.applyQuickJump(
                                  currentWeight: selectedWeight,
                                  jump: jump,
                                  unit: unit,
                                );
                                setModalState(() => selectedWeight = newWeight);
                                controller.animateToItem(
                                  WeightHelper.weightToIndex(newWeight, unit),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                                HapticFeedback.mediumImpact();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                minimumSize: const Size(60, 36),
                              ),
                              child: Text(
                                jump > 0 ? '+$jump' : '$jump',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: jump > 0
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.error,
                                ),
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ),

              const SizedBox(height: 16),
              // Picker
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: 50,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: WeightConversion.getChildCount(unit),
                    builder: (context, index) {
                      final weight = WeightHelper.indexToWeight(index, unit);
                      final isSelected = (weight - selectedWeight).abs() < 0.05;
                      final displayText = WeightHelper.formatPickerWeight(
                        weight,
                        unit,
                      );

                      return Center(
                        child: Text(
                          displayText,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
                  ),
                  onSelectedItemChanged: (index) {
                    setModalState(
                      () => selectedWeight = WeightHelper.indexToWeight(
                        index,
                        unit,
                      ),
                    );
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Confirm button
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  label: AppLocalizations.of(context).confirm,
                  button: true,
                  child: FilledButton(
                    onPressed: () {
                      // Convert display weight back to kg for storage
                      final weightInKg = selectedWeight.fromDisplayUnit(unit);
                      _updateSet(
                        exerciseIndex,
                        setIndex,
                        setCustomization.copyWith(weight: weightInKg),
                      );
                      Navigator.of(context).pop();
                      HapticFeedback.mediumImpact();
                    },
                    child: Text(AppLocalizations.of(context).confirm),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Data Classes
class ExerciseCustomization {
  ExerciseCustomization({
    required this.exercise,
    required this.sets,
    this.notes,
    required this.countingMode,
    this.restTime, // Rest time in seconds between sets
    this.restAfterExercise, // Rest time in seconds AFTER completing this exercise
  });
  final Exercise exercise;
  final List<SetCustomization> sets;
  final String? notes;
  final ExerciseCountingMode countingMode;
  final int? restTime; // Rest time in seconds (null = use default)
  final int? restAfterExercise; // Rest time AFTER exercise (null = use global default)

  ExerciseCustomization copyWith({
    Exercise? exercise,
    List<SetCustomization>? sets,
    String? notes,
    ExerciseCountingMode? countingMode,
    int? restTime,
    bool clearRestTime = false,
    int? restAfterExercise,
    bool clearRestAfterExercise = false,
  }) {
    return ExerciseCustomization(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      countingMode: countingMode ?? this.countingMode,
      restTime: clearRestTime ? null : (restTime ?? this.restTime),
      restAfterExercise: clearRestAfterExercise
          ? null
          : (restAfterExercise ?? this.restAfterExercise),
    );
  }
}

class SetCustomization {
  SetCustomization({
    required this.setNumber,
    this.weight = 0, // Optional for bodyweight/time exercises
    this.reps = 10, // Optional for time exercises
    this.seconds, // ✅ NUOVO: Per esercizi a tempo
  });
  final int setNumber;
  final double weight;
  final int reps;
  final int? seconds; // ✅ NUOVO: Secondi per esercizi a tempo (plank, etc.)

  SetCustomization copyWith({
    int? setNumber,
    double? weight,
    int? reps,
    int? seconds, // ✅ NUOVO
  }) {
    return SetCustomization(
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      seconds: seconds ?? this.seconds, // ✅ NUOVO
    );
  }
}

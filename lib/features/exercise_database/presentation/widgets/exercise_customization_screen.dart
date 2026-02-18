import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/core/navigation/app_routes.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart'
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
import 'package:gymbro_flutter_new/features/workout/data/services/exercise_history_service.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/minimal_set_edit_sheet.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

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
            label: l10n.add,
            button: true,
            child: TextButton(
              onPressed: _addAllToWorkout,
              child: Text(
                l10n.add,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _customizations.length,
        onReorder: _onReorderExercises,
        proxyDecorator: (child, index, animation) {
          return Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: child,
          );
        },
        itemBuilder: (context, index) {
          final customization = _customizations[index];
          return Padding(
            key: ValueKey(customization.exercise.id),
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildExerciseCard(customization, index),
          );
        },
      ),
    );
  }

  /// Riordina gli esercizi con drag & drop
  void _onReorderExercises(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _customizations.removeAt(oldIndex);
      _customizations.insert(newIndex, item);
    });
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
            // Exercise Header with Drag Handle
            Row(
              children: [
                // Drag Handle
                if (_customizations.length > 1)
                  ReorderableDragStartListener(
                    index: exerciseIndex,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        AppIcons.dragHandle,
                        size: AppIconSize.small,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
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

            const SizedBox(height: 12),

            // ✅ Counting Mode Selector - compatto
            _buildCountingModeSelector(customization, exerciseIndex),

            const SizedBox(height: 10),

            // Rest Timers Row - Timer Recupero + Riposo Tra Esercizi affiancati
            Row(
              children: [
                Expanded(
                  child: _buildRestTimerPickerCompact(customization, exerciseIndex),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRestAfterExercisePickerCompact(customization, exerciseIndex),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Last Workout Section
            _buildLastWorkoutSection(customization, exerciseIndex),

            const SizedBox(height: 10),

            // Sets Section Header + Quick Presets
            Row(
              children: [
                Text(
                  context.l10n.sets.toUpperCase(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                // Quick Presets
                Expanded(
                  child: _buildQuickSetPresets(customization, exerciseIndex),
                ),
                // Add Set button
                GestureDetector(
                  onTap: () => _addSet(exerciseIndex),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.add,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          context.l10n.addSet,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Set List - compatto
            ...customization.sets.asMap().entries.map((entry) {
              final setIndex = entry.key;
              final setCustomization = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _buildSetRow(exerciseIndex, setIndex, setCustomization),
              );
            }),

            const SizedBox(height: 8),

            // Notes Section - Collapsibile
            _buildCollapsibleNotes(customization, exerciseIndex),
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
        const SizedBox(width: 6),
        Expanded(
          child: _buildCountingModeButton(
            label: l10n.reps,
            icon: AppIcons.repeat,
            isSelected: customization.countingMode == ExerciseCountingMode.reps,
            onTap: () => _changeCountingMode(exerciseIndex, ExerciseCountingMode.reps),
          ),
        ),
        const SizedBox(width: 6),
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

  /// Singolo bottone per counting mode - stile compatto coerente
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
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
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
              const SizedBox(width: 4),
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
    final l10n = context.l10n;
    final initialSeconds = customization.restTime ?? 90;

    ModalService.showSheet(context,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      isScrollControlled: true,
      builder: (context) => _RestTimePickerSheet(
        title: l10n.restTimer,
        presetSeconds: const [30, 60, 90, 120, 180, 300],
        initialSeconds: initialSeconds,
        onConfirm: (seconds) {
          setState(() {
            _customizations[exerciseIndex] =
                _customizations[exerciseIndex].copyWith(
              restTime: seconds,
            );
          });
        },
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
    final l10n = context.l10n;
    final appConfig = ref.read(appConfigProvider);
    final initialSeconds =
        customization.restAfterExercise ?? appConfig.defaultRestBetweenExercises;

    ModalService.showSheet(context,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      isScrollControlled: true,
      builder: (context) => _RestTimePickerSheet(
        title: l10n.restBetweenExercises,
        presetSeconds: const [60, 90, 120, 180, 240, 300],
        initialSeconds: initialSeconds,
        onConfirm: (seconds) {
          setState(() {
            _customizations[exerciseIndex] =
                _customizations[exerciseIndex].copyWith(
              restAfterExercise: seconds,
            );
          });
        },
      ),
    );
  }

  /// Timer Recupero - versione compatta per layout affiancato
  Widget _buildRestTimerPickerCompact(
    ExerciseCustomization customization,
    int exerciseIndex,
  ) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final hasCustomRestTime = customization.restTime != null;
    final displayValue = hasCustomRestTime
        ? _formatRestTime(customization.restTime!)
        : l10n.automatic;

    return Semantics(
      label: '${l10n.restTimer}: $displayValue',
      button: true,
      child: InkWell(
        onTap: () => _showRestTimePicker(exerciseIndex, customization),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                size: 16,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.restTimer,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      displayValue,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: hasCustomRestTime
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasCustomRestTime)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _customizations[exerciseIndex] =
                          _customizations[exerciseIndex].copyWith(
                        clearRestTime: true,
                      );
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      AppIcons.close,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Riposo Tra Esercizi - versione compatta per layout affiancato
  Widget _buildRestAfterExercisePickerCompact(
    ExerciseCustomization customization,
    int exerciseIndex,
  ) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final hasCustomRestAfter = customization.restAfterExercise != null;
    final displayValue = hasCustomRestAfter
        ? _formatRestTime(customization.restAfterExercise!)
        : l10n.automatic;

    return Semantics(
      label: '${l10n.restBetweenExercises}: $displayValue',
      button: true,
      child: InkWell(
        onTap: () => _showRestAfterExercisePicker(exerciseIndex, customization),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                size: 16,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.restBetweenExercises,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      displayValue,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: hasCustomRestAfter
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasCustomRestAfter)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _customizations[exerciseIndex] =
                          _customizations[exerciseIndex].copyWith(
                        clearRestAfterExercise: true,
                      );
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      AppIcons.close,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Note collapsibili - si espandono al tap
  Widget _buildCollapsibleNotes(
    ExerciseCustomization customization,
    int exerciseIndex,
  ) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final hasNotes = customization.notes != null && customization.notes!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header tappabile
        InkWell(
          onTap: () {
            setState(() {
              _customizations[exerciseIndex] = _customizations[exerciseIndex].copyWith(
                notesExpanded: !(_customizations[exerciseIndex].notesExpanded ?? hasNotes),
              );
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.notes,
                  size: 18,
                  color: hasNotes
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasNotes ? customization.notes! : l10n.notesOptional,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: hasNotes
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                      fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  (_customizations[exerciseIndex].notesExpanded ?? hasNotes)
                      ? AppIcons.expandLess
                      : AppIcons.expandMore,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        // TextField espandibile
        if (_customizations[exerciseIndex].notesExpanded ?? hasNotes) ...[
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: customization.notes ?? ''),
            decoration: InputDecoration(
              hintText: context.l10n.notesHint,
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: context.colors.primary,
                  width: 2.0,
                ),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      ],
    );
  }

  /// Last Workout Section - mostra ultima configurazione usata
  Widget _buildLastWorkoutSection(
    ExerciseCustomization customization,
    int exerciseIndex,
  ) {
    final theme = Theme.of(context);
    final exerciseName = customization.exercise.nome;

    // Watch the history provider
    final historyAsync = ref.watch(
      exerciseHistoryDataGroupedProvider(exerciseName),
    );

    return historyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (grouped) {
        if (grouped.isEmpty) return const SizedBox.shrink();

        // Get most recent date
        final sortedDates = grouped.keys.toList()
          ..sort((a, b) => b.compareTo(a));
        final lastDate = sortedDates.first;
        final lastSets = grouped[lastDate] ?? [];

        if (lastSets.isEmpty) return const SizedBox.shrink();

        // Calculate days ago
        final daysAgo = DateTime.now().difference(lastDate).inDays;
        final daysAgoText = daysAgo == 0
            ? context.l10n.today
            : daysAgo == 1
                ? context.l10n.yesterday
                : '${daysAgo}d fa';

        // Format sets summary (e.g., "3×8 @ 60kg")
        final numSets = lastSets.length;
        final avgReps = lastSets.isNotEmpty
            ? (lastSets.map((s) => s.reps ?? 0).reduce((a, b) => a + b) / numSets).round()
            : 0;
        final maxWeight = lastSets.isNotEmpty
            ? lastSets.map((s) => s.weight ?? 0.0).reduce((a, b) => a > b ? a : b)
            : 0.0;

        final summaryText = maxWeight > 0
            ? '$numSets×$avgReps @ ${maxWeight.toStringAsFixed(maxWeight % 1 == 0 ? 0 : 1)}kg'
            : '$numSets×$avgReps';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                AppIcons.history,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.lastTime,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          summaryText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '($daysAgoText)',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // "Use these values" button
              GestureDetector(
                onTap: () => _applyLastWorkoutConfig(exerciseIndex, lastSets),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.l10n.use,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Applica la configurazione dell'ultimo allenamento
  void _applyLastWorkoutConfig(int exerciseIndex, List<ExerciseHistoryData> lastSets) {
    setState(() {
      final newSets = lastSets.asMap().entries.map((entry) {
        return SetCustomization(
          setNumber: entry.key + 1,
          weight: entry.value.weight ?? 0,
          reps: entry.value.reps ?? 10,
        );
      }).toList();

      _customizations[exerciseIndex] = _customizations[exerciseIndex].copyWith(
        sets: newSets,
      );
    });

    SnackBarService.showSuccess(
      context,
      context.l10n.previousWeightsLoaded,
    );
  }

  /// Quick Set Presets - bottoni per configurazioni veloci
  Widget _buildQuickSetPresets(
    ExerciseCustomization customization,
    int exerciseIndex,
  ) {
    final theme = Theme.of(context);
    final countingMode = customization.countingMode;

    // Presets diversi in base al counting mode
    final presets = countingMode == ExerciseCountingMode.time
        ? [
            (sets: 3, value: 30, label: '3×30s'),
            (sets: 3, value: 60, label: '3×60s'),
            (sets: 4, value: 45, label: '4×45s'),
          ]
        : [
            (sets: 3, value: 10, label: '3×10'),
            (sets: 4, value: 8, label: '4×8'),
            (sets: 5, value: 5, label: '5×5'),
          ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: presets.map((preset) {
          final isSelected = customization.sets.length == preset.sets &&
              (countingMode == ExerciseCountingMode.time
                  ? customization.sets.every((s) => s.seconds == preset.value)
                  : customization.sets.every((s) => s.reps == preset.value));

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => _applySetPreset(exerciseIndex, preset.sets, preset.value),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  preset.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Applica un preset di serie
  void _applySetPreset(int exerciseIndex, int numSets, int value) {
    final countingMode = _customizations[exerciseIndex].countingMode;

    setState(() {
      final newSets = List.generate(numSets, (i) {
        if (countingMode == ExerciseCountingMode.time) {
          return SetCustomization(
            setNumber: i + 1,
            weight: 0,
            reps: 1,
            seconds: value,
          );
        } else {
          return SetCustomization(
            setNumber: i + 1,
            weight: 0,
            reps: value,
          );
        }
      });

      _customizations[exerciseIndex] = _customizations[exerciseIndex].copyWith(
        sets: newSets,
      );
    });
  }

  // Change Counting Mode Handler
  void _changeCountingMode(int exerciseIndex, ExerciseCountingMode newMode) {
    // Safety check per evitare crash
    if (exerciseIndex < 0 || exerciseIndex >= _customizations.length) {
      debugPrint('❌ [CustomizationScreen] Invalid exerciseIndex: $exerciseIndex');
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '🔍 [CustomizationScreen] _changeCountingMode: exerciseIndex=$exerciseIndex, newMode=$newMode',
      );
      debugPrint(
        '🔍 [CustomizationScreen] Before: ${_customizations[exerciseIndex].countingMode}',
      );
    }

    try {
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
    } catch (e, stack) {
      debugPrint('❌ [CustomizationScreen] Error in _changeCountingMode: $e');
      debugPrint('❌ Stack trace: $stack');
      return;
    }

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
    // Safety check
    if (exerciseIndex < 0 || exerciseIndex >= _customizations.length) {
      return const SizedBox.shrink();
    }
    final countingMode = _customizations[exerciseIndex].countingMode;
    final theme = Theme.of(context);

    return Row(
      children: [
        // Set Number - compatto
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${setCustomization.setNumber}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Pulsante combinato Peso × Reps
        if (countingMode == ExerciseCountingMode.weighted)
          Expanded(
            child: _buildCombinedWeightRepsButton(
              exerciseIndex: exerciseIndex,
              setIndex: setIndex,
              setCustomization: setCustomization,
            ),
          ),

        // Reps Picker Button (solo per reps mode)
        if (countingMode == ExerciseCountingMode.reps)
          Expanded(
            child: _buildPickerButton(
              label: AppLocalizations.of(context).reps,
              value: setCustomization.repsDisplay,
              icon: AppIcons.repeat,
              color: theme.colorScheme.secondary,
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
              color: theme.colorScheme.tertiary,
              onTap: () => _showDurationPicker(
                exerciseIndex,
                setIndex,
                setCustomization,
              ),
            ),
          ),

        // Remove Set Button - compatto
        if (_customizations[exerciseIndex].sets.length > 1)
          GestureDetector(
            onTap: () => _removeSet(exerciseIndex, setIndex),
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                AppIcons.removeCircleOutline,
                size: 22,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
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
        minReps: lastSet?.minReps,
        maxReps: lastSet?.maxReps,
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
        if (kDebugMode) {
          debugPrint('🔍 [CustomizationScreen] Using CALLBACK onExerciseAdded');
        }
        widget.onExerciseAdded!(workoutExercise);
      } else {
        if (kDebugMode) {
          debugPrint('🔍 [CustomizationScreen] Using PROVIDER addExercise');
        }
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
            reps: setCustomization.hasRepRange ? null : setCustomization.reps,
            minReps: setCustomization.minReps,
            maxReps: setCustomization.maxReps,
            seconds: setCustomization.seconds,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
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
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ NUOVO: Pulsante combinato Peso × Reps che apre MinimalSetEditSheet
  Widget _buildCombinedWeightRepsButton({
    required int exerciseIndex,
    required int setIndex,
    required SetCustomization setCustomization,
  }) {
    final theme = Theme.of(context);
    final weightDisplay = setCustomization.weight == 0
        ? '-'
        : setCustomization.weight.toStringAsFixed(1);

    return Semantics(
      label:
          '${AppLocalizations.of(context).weight}: $weightDisplay, ${AppLocalizations.of(context).reps}: ${setCustomization.repsDisplay}',
      button: true,
      child: InkWell(
        onTap: () => _showWeightRepsPicker(
          exerciseIndex,
          setIndex,
          setCustomization,
        ),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Peso
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.fitnessCenter,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context).weight,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    weightDisplay,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              // Separatore ×
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '×',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              // Reps
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.repeat,
                        size: 14,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context).reps,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    setCustomization.repsDisplay,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.secondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ NUOVO: Apre MinimalSetEditSheet per modificare peso e reps insieme
  void _showWeightRepsPicker(
    int exerciseIndex,
    int setIndex,
    SetCustomization setCustomization,
  ) {
    final sets = _customizations[exerciseIndex].sets;
    final weightUnit = ref.read(measurementUnitProvider);

    // Converti SetCustomization in ExerciseSet temporaneo
    final exerciseSet = WorkoutExercise.ExerciseSet(
      setNumber: setCustomization.setNumber,
      weight: setCustomization.weight,
      reps: setCustomization.hasRepRange ? null : setCustomization.reps,
      minReps: setCustomization.minReps,
      maxReps: setCustomization.maxReps,
    );

    // Converti tutti i set per la navigazione
    final allSets = sets
        .map(
          (s) => WorkoutExercise.ExerciseSet(
            setNumber: s.setNumber,
            weight: s.weight,
            reps: s.hasRepRange ? null : s.reps,
            minReps: s.minReps,
            maxReps: s.maxReps,
          ),
        )
        .toList();

    // Set precedente per "Copia precedente"
    final previousSet = setIndex > 0
        ? WorkoutExercise.ExerciseSet(
            setNumber: sets[setIndex - 1].setNumber,
            weight: sets[setIndex - 1].weight,
            reps: sets[setIndex - 1].hasRepRange ? null : sets[setIndex - 1].reps,
            minReps: sets[setIndex - 1].minReps,
            maxReps: sets[setIndex - 1].maxReps,
          )
        : null;

    context.showMinimalSetEditSheet(
      exerciseSet: exerciseSet,
      currentSetIndex: setIndex,
      totalSets: sets.length,
      measurementUnit: weightUnit,
      previousSet: previousSet,
      allSets: allSets,
      countingMode: _customizations[exerciseIndex].countingMode, // ✅ NUOVO: Pass counting mode
      onSave: (updatedSet) {
        _updateSetFromMinimalSheet(exerciseIndex, setIndex, updatedSet);
      },
      onSaveAndNext: setIndex < sets.length - 1
          ? (updatedSet) {
              _updateSetFromMinimalSheet(exerciseIndex, setIndex, updatedSet);
              // Apri il prossimo set
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  _showWeightRepsPicker(
                    exerciseIndex,
                    setIndex + 1,
                    _customizations[exerciseIndex].sets[setIndex + 1],
                  );
                }
              });
            }
          : null,
      onSaveAndPrevious: setIndex > 0
          ? (updatedSet) {
              _updateSetFromMinimalSheet(exerciseIndex, setIndex, updatedSet);
              // Apri il set precedente
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  _showWeightRepsPicker(
                    exerciseIndex,
                    setIndex - 1,
                    _customizations[exerciseIndex].sets[setIndex - 1],
                  );
                }
              });
            }
          : null,
      onApplyToAll: setIndex == 0
          ? (updatedSet) {
              _applyToAllSetsFromMinimalSheet(exerciseIndex, updatedSet);
            }
          : null,
      onCopyPrevious: setIndex > 0
          ? (updatedSet) {
              // Copia già gestita dal MinimalSetEditSheet
              _updateSetFromMinimalSheet(exerciseIndex, setIndex, updatedSet);
            }
          : null,
    );
  }

  /// Aggiorna un set dal MinimalSetEditSheet
  void _updateSetFromMinimalSheet(
    int exerciseIndex,
    int setIndex,
    WorkoutExercise.ExerciseSet updatedSet,
  ) {
    setState(() {
      final currentSets = List<SetCustomization>.from(
        _customizations[exerciseIndex].sets,
      );
      final countingMode = _customizations[exerciseIndex].countingMode;

      final hasRange = updatedSet.minReps != null &&
          updatedSet.maxReps != null &&
          updatedSet.minReps != updatedSet.maxReps;

      currentSets[setIndex] = SetCustomization(
        setNumber: currentSets[setIndex].setNumber,
        weight: countingMode.requiresWeight ? (updatedSet.weight ?? 0) : 0,
        reps: countingMode.requiresReps
            ? (hasRange ? (updatedSet.minReps ?? 10) : (updatedSet.reps ?? 10))
            : 0,
        seconds: countingMode.requiresTime ? (updatedSet.seconds ?? 60) : null,
        minReps: hasRange ? updatedSet.minReps : null,
        maxReps: hasRange ? updatedSet.maxReps : null,
      );
      _customizations[exerciseIndex] = _customizations[exerciseIndex].copyWith(
        sets: currentSets,
      );
    });
  }

  /// Applica peso e reps a tutti i set
  void _applyToAllSetsFromMinimalSheet(
    int exerciseIndex,
    WorkoutExercise.ExerciseSet updatedSet,
  ) {
    setState(() {
      final currentSets = List<SetCustomization>.from(
        _customizations[exerciseIndex].sets,
      );
      final countingMode = _customizations[exerciseIndex].countingMode;

      final hasRange = updatedSet.minReps != null &&
          updatedSet.maxReps != null &&
          updatedSet.minReps != updatedSet.maxReps;

      for (int i = 0; i < currentSets.length; i++) {
        currentSets[i] = SetCustomization(
          setNumber: currentSets[i].setNumber,
          weight: countingMode.requiresWeight ? (updatedSet.weight ?? 0) : 0,
          reps: countingMode.requiresReps
              ? (hasRange ? (updatedSet.minReps ?? 10) : (updatedSet.reps ?? 10))
              : 0,
          seconds: countingMode.requiresTime ? (updatedSet.seconds ?? 60) : null,
          minReps: hasRange ? updatedSet.minReps : null,
          maxReps: hasRange ? updatedSet.maxReps : null,
        );
      }
      _customizations[exerciseIndex] = _customizations[exerciseIndex].copyWith(
        sets: currentSets,
      );
    });
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

    ModalService.showSheet(context,
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

    ModalService.showSheet(context,
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

    ModalService.showSheet(context,
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
/// Unified rest time picker sheet matching header timer modal style
class _RestTimePickerSheet extends StatefulWidget {
  const _RestTimePickerSheet({
    required this.title,
    required this.presetSeconds,
    required this.initialSeconds,
    required this.onConfirm,
  });

  final String title;
  final List<int> presetSeconds;
  final int initialSeconds;
  final void Function(int seconds) onConfirm;

  @override
  State<_RestTimePickerSheet> createState() => _RestTimePickerSheetState();
}

class _RestTimePickerSheetState extends State<_RestTimePickerSheet> {
  late int _selectedMinutes;
  late int _selectedSeconds;

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.initialSeconds ~/ 60;
    _selectedSeconds = widget.initialSeconds % 60;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            widget.title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.selectRestDuration,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Preset chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: widget.presetSeconds.map((seconds) {
              return _buildPresetChip(context, seconds);
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Divider with "oppure"
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: colors.outline.withValues(alpha: 0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.orCustom,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: colors.outline.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Number picker
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNumberPicker(
                context,
                value: _selectedMinutes,
                maxValue: 10,
                label: l10n.minutes,
                onChanged: (val) => setState(() => _selectedMinutes = val),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  ':',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildNumberPicker(
                context,
                value: _selectedSeconds,
                maxValue: 59,
                label: l10n.seconds,
                onChanged: (val) => setState(() => _selectedSeconds = val),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: Semantics(
              label: l10n.confirm,
              button: true,
              child: FilledButton(
                onPressed: () {
                  final totalSeconds = (_selectedMinutes * 60) + _selectedSeconds;
                  if (totalSeconds > 0) {
                    HapticFeedback.mediumImpact();
                    widget.onConfirm(totalSeconds);
                  }
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(
                  '${l10n.confirm} ${_formatDuration(_selectedMinutes, _selectedSeconds)}',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPresetChip(BuildContext context, int seconds) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final label = _formatPresetLabel(seconds);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onConfirm(seconds);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: colors.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPicker(
    BuildContext context, {
    required int value,
    required int maxValue,
    required String label,
    required void Function(int) onChanged,
  }) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                icon: const Icon(AppIcons.remove),
                iconSize: AppIconSize.small,
              ),
              SizedBox(
                width: 50,
                child: Text(
                  value.toString().padLeft(2, '0'),
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              IconButton(
                onPressed: value < maxValue ? () => onChanged(value + 1) : null,
                icon: const Icon(AppIcons.add),
                iconSize: AppIconSize.small,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPresetLabel(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0 && secs > 0) {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    } else if (minutes > 0) {
      return '$minutes:00';
    }
    return '${secs}s';
  }

  String _formatDuration(int minutes, int seconds) {
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '0:${seconds.toString().padLeft(2, '0')}';
  }
}

class ExerciseCustomization {
  ExerciseCustomization({
    required this.exercise,
    required this.sets,
    this.notes,
    required this.countingMode,
    this.restTime, // Rest time in seconds between sets
    this.restAfterExercise, // Rest time in seconds AFTER completing this exercise
    this.notesExpanded, // Whether notes section is expanded
  });
  final Exercise exercise;
  final List<SetCustomization> sets;
  final String? notes;
  final ExerciseCountingMode countingMode;
  final int? restTime; // Rest time in seconds (null = use default)
  final int? restAfterExercise; // Rest time AFTER exercise (null = use global default)
  final bool? notesExpanded; // UI state: notes section expanded

  ExerciseCustomization copyWith({
    Exercise? exercise,
    List<SetCustomization>? sets,
    String? notes,
    ExerciseCountingMode? countingMode,
    int? restTime,
    bool clearRestTime = false,
    int? restAfterExercise,
    bool clearRestAfterExercise = false,
    bool? notesExpanded,
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
      notesExpanded: notesExpanded ?? this.notesExpanded,
    );
  }
}

class SetCustomization {
  SetCustomization({
    required this.setNumber,
    this.weight = 0, // Optional for bodyweight/time exercises
    this.reps = 10, // Optional for time exercises
    this.seconds, // ✅ NUOVO: Per esercizi a tempo
    this.minReps, // Rep range min
    this.maxReps, // Rep range max
  });
  final int setNumber;
  final double weight;
  final int reps;
  final int? seconds;
  final int? minReps;
  final int? maxReps;

  /// True se ha un range di reps (es. 8-10)
  bool get hasRepRange =>
      minReps != null && maxReps != null && minReps != maxReps;

  /// Display string: "8-10" se range, altrimenti "10"
  String get repsDisplay =>
      hasRepRange ? '$minReps-$maxReps' : '$reps';

  SetCustomization copyWith({
    int? setNumber,
    double? weight,
    int? reps,
    int? seconds,
    int? minReps,
    int? maxReps,
    bool clearRepRange = false,
  }) {
    return SetCustomization(
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      seconds: seconds ?? this.seconds,
      minReps: clearRepRange ? null : (minReps ?? this.minReps),
      maxReps: clearRepRange ? null : (maxReps ?? this.maxReps),
    );
  }
}

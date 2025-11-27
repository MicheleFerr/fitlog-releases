import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/edit_set_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/quick_edit_overlay_v2.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rpe_selector_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/calculation_metadata_display.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_expansion_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/set_duration_tracker_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/apre_auto_regulation_service.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/haptic_feedback_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/rpe_indicator.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/services/exercise_counting_mode_service.dart';

/// Sets section component for ExerciseListItem
///
/// **Presentation Layer** - Displays and manages exercise sets
///
/// Displays:
/// - Set rows with number, weight, reps, RPE
/// - Add set button with collapse button when completed
/// - Set editing via tap, double-tap, long-press
/// - Swipe to delete with undo
/// - RPE selector on completion
/// - APRE metadata banner (after Set 4)
/// - DropSet/RestPause execute buttons
///
/// Handles:
/// - Set completion with duration tracking
/// - Set editing (quick edit on double-tap, full edit on long-press)
/// - Set deletion with undo functionality
/// - APRE and RPE auto-regulation suggestions
/// - Rest timer starting after set completion
///
/// Extracted from exercise_list_item.dart for Single Responsibility Principle.
/// Part of the ExerciseListItem decomposition to reduce file size from ~5600 to ~1500 lines.
class ExerciseListItemSets extends ConsumerStatefulWidget {
  const ExerciseListItemSets({
    super.key,
    required this.exercise,
    required this.config,
    required this.onExerciseUpdate,
    required this.onSetToggleComplete,
    required this.onStartRestTimer,
    required this.onExecuteDropSet,
    required this.onExecuteRestPause,
    required this.onCollapseExercise,
  });

  final Exercise exercise;
  final AppConfig config;
  final Function(Exercise) onExerciseUpdate;
  final Function(ExerciseSet) onSetToggleComplete;
  final Function(BuildContext, ExerciseSet) onStartRestTimer;
  final Function(DropSetExercise) onExecuteDropSet;
  final Function(RestPauseExercise) onExecuteRestPause;
  final VoidCallback onCollapseExercise;

  @override
  ConsumerState<ExerciseListItemSets> createState() => _ExerciseListItemSetsState();
}

class _ExerciseListItemSetsState extends ConsumerState<ExerciseListItemSets> {
  bool _showMetadataBanner = false; // Collapsed by default

  @override
  Widget build(BuildContext context) {
    return _buildSetsSection(context, widget.config);
  }

  Widget _buildSetsSection(BuildContext context, AppConfig config) {
    if (widget.exercise.sets.isEmpty) {
      // For DropSet exercises, show execute button instead of "No sets yet"
      if (widget.exercise.type == ExerciseType.dropset) {
        final dropsetExercise = widget.exercise as DropSetExercise;
        return GestureDetector(
          onTap: () => widget.onExecuteDropSet(dropsetExercise),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.colors.tertiary.withValues(alpha: 0.5),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.playCircleOutline,
                  semanticLabel: context.l10n.executeDropset,
                  size: AppIconSize.small,
                  color: context.colors.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.executeDropset,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SemanticIcon(
                  icon: AppIcons.forwardIos,
                  semanticLabel: context.l10n.executeDropset,
                  size: AppIconSize.tiny,
                  color: context.colors.tertiary,
                )
              ],
            ),
          ),
        );
      }

      // For RestPause exercises, show execute button
      if (widget.exercise.type == ExerciseType.restPause) {
        final restPauseExercise = widget.exercise as RestPauseExercise;
        return GestureDetector(
          onTap: () => widget.onExecuteRestPause(restPauseExercise),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.5),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.playCircleOutline,
                  semanticLabel: context.l10n.executeRestPause,
                  size: AppIconSize.small,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.executeRestPause,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SemanticIcon(
                  icon: AppIcons.forwardIos,
                  semanticLabel: context.l10n.executeRestPause,
                  size: AppIconSize.tiny,
                  color: context.colors.primary,
                )
              ],
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.colors.outline.withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            SemanticIcon(
              icon: AppIcons.addCircleOutline,
              semanticLabel: context.l10n.addSet,
              size: AppIconSize.small,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'No sets yet - tap to add',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    // Get expansion state for collapse button visibility
    final expansionState = ref.watch(
      exerciseExpansionProvider(widget.exercise.id),
    );
    final isExpanded = expansionState.isExpanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.exerciseListSetsProgress(
                widget.exercise.sets.where((s) => s.isCompleted).length.toString(),
                widget.exercise.sets.length.toString(),
              ),
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (widget.exercise.sets.isNotEmpty)
              Text(
                'Weight × Reps',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...widget.exercise.sets.asMap().entries.expand(
          (entry) => [
            _buildSetItem(context, entry.key, entry.value, config),
            // Inject metadata banner after Set 4 if APRE enabled
            if (entry.key == 3 && widget.exercise.useAPRE && widget.exercise.sets.length >= 4)
              _buildMetadataBanner(context),
          ],
        ),
        const SizedBox(height: 8),
        // Add set button (with smooth animated collapse button when completed)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: _areAllSetsCompleted() && isExpanded
              ? Row(
                  key: const ValueKey('buttons_with_collapse'),
                  children: [
                    // Add Set button (left)
                    Expanded(
                      child: InkWell(
                        onTap: () => _addNewSet(),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: context.colors.primaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: context.colors.primary.withValues(alpha: 0.3),
                              style: BorderStyle.solid,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SemanticIcon(
                                icon: AppIcons.addCircleOutline,
                                semanticLabel: context.l10n.addSet,
                                size: AppIconSize.small,
                                color: context.colors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.l10n.addSet,
                                style: context.textTheme.labelLarge?.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Collapse button (right)
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 500),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: InkWell(
                          onTap: () {
                            widget.onCollapseExercise();
                            HapticFeedback.lightImpact();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: context.colors.secondaryContainer.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.colors.secondary.withValues(alpha: 0.3),
                                style: BorderStyle.solid,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SemanticIcon(
                                  icon: AppIcons.unfoldLess,
                                  semanticLabel: context.l10n.collapseExercise,
                                  size: AppIconSize.small,
                                  color: context.colors.secondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  context.l10n.collapseExercise,
                                  style: context.textTheme.labelLarge?.copyWith(
                                    color: context.colors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  key: const ValueKey('button_add_only'),
                  onTap: () => _addNewSet(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: context.colors.primary.withValues(alpha: 0.3),
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SemanticIcon(
                          icon: AppIcons.addCircleOutline,
                          semanticLabel: context.l10n.addSet,
                          size: AppIconSize.small,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.addSet,
                          style: context.textTheme.labelLarge?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSetItem(
    BuildContext context,
    int index,
    ExerciseSet set,
    AppConfig config,
  ) {
    final isWarmup = set.isWarmup;

    return Dismissible(
      key: Key('${widget.exercise.id}_set_${set.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: context.errorColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SemanticIcon(
          icon: AppIcons.deleteOutline,
          semanticLabel: context.l10n.delete,
          size: AppIconSize.medium,
          color: context.colors.surface,
        ),
      ),
      confirmDismiss: (direction) async {
        final l10n = context.l10n;

        return await showGeneralDialog<bool>(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Dismiss',
          barrierColor: context.colors.onSurface.withValues(alpha: 0.54),
          transitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) {
            return Container();
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: curvedAnimation,
                child: AlertDialog(
                  title: Text(
                    isWarmup
                        ? l10n.deleteWarmupSetTitle
                        : l10n.deleteSetTitle(index + 1),
                  ),
                  content: Text(l10n.deleteSetMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: context.errorColor),
                      child: Text(l10n.delete),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteSet(set, index);
      },
      child: GestureDetector(
        onTap: () => _toggleSetCompletionWithFeedback(context, set),
        onDoubleTap: () => _quickEditSet(context, set),
        onLongPress: () => _editSet(context, set),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isWarmup
                ? context.warningContainer
                : set.isCompleted
                    ? context.colors.tertiary.withValues(alpha: 0.1)
                    : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: isWarmup
                ? Border.all(color: context.warningColor.withValues(alpha: 0.3))
                : set.isCompleted
                    ? Border.all(color: context.colors.tertiary.withValues(alpha: 0.3))
                    : null,
          ),
          child: Row(
            children: [
              // Set number with warmup indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isWarmup
                      ? context.warningColor.withValues(alpha: 0.3)
                      : set.isCompleted
                          ? context.colors.tertiary
                          : context.colors.outline.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isWarmup
                      ? SemanticIcon(
                          icon: AppIcons.streak,
                          semanticLabel: 'Warmup set',
                          size: AppIconSize.tiny,
                          color: context.warningColor,
                        )
                      : Text(
                          '${index + 1}',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: set.isCompleted
                                ? context.colors.onTertiary
                                : context.colors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Warmup badge
              if (isWarmup) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.warningContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'W',
                    style: context.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.warningColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Set details (adapted based on counting mode)
              Expanded(
                child: Row(
                  children: [
                    ..._buildSetDetailsForMode(set, config),

                    // RPE indicator if completed
                    if (set.isCompleted && set.rpe != null) ...[
                      const SizedBox(width: 8),
                      RpeIndicator(rpe: set.rpe!),
                    ],
                  ],
                ),
              ),

              // Completion checkmark
              if (set.isCompleted)
                SemanticIcon(
                  icon: AppIcons.checkCircle,
                  semanticLabel: 'Completed',
                  size: AppIconSize.small,
                  color: context.colors.tertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build set details widgets based on counting mode
  List<Widget> _buildSetDetailsForMode(ExerciseSet set, AppConfig config) {
    final mode = ExerciseCountingModeService.getModeFromWorkoutExercise(widget.exercise);

    switch (mode) {
      case ExerciseCountingMode.weighted:
        // Weighted: Show weight × reps
        return [
          if (set.weight != null) ...[
            Text(
              set.weight!.formatWeight(config.measurementUnit),
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration: set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(width: 4),
            Text('×', style: context.textTheme.bodySmall),
            const SizedBox(width: 4),
          ],
          if (set.reps != null)
            Text(
              set.actualReps != null && set.isCompleted
                  ? '${set.actualReps}/${set.reps} reps'
                  : '${set.reps} reps',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration: set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
        ];

      case ExerciseCountingMode.reps:
        // Reps-only: Show reps only (bodyweight exercises)
        return [
          if (set.reps != null)
            Text(
              set.actualReps != null && set.isCompleted
                  ? '${set.actualReps}/${set.reps} reps'
                  : '${set.reps} reps',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration: set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
        ];

      case ExerciseCountingMode.time:
        // Time-based: Show duration (isometric exercises)
        return [
          if (set.reps != null)
            Text(
              '${set.reps}s',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration: set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          // Also show 'seconds' field if exists (for backward compatibility)
          if (set.seconds != null && set.reps == null)
            Text(
              '${set.seconds}s',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration: set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
        ];
    }
  }

  void _addNewSet() {
    // Get the last set's values as defaults for the new set
    ExerciseSet? lastSet;
    if (widget.exercise.sets.isNotEmpty) {
      // Find the last non-warmup set
      final workingSets = widget.exercise.sets.where((s) => !s.isWarmup).toList();
      lastSet = workingSets.isNotEmpty ? workingSets.last : widget.exercise.sets.last;
    }

    // Create new set with default or copied values
    final newSet = ExerciseSet(
      setNumber: widget.exercise.sets.length + 1,
      weight: lastSet?.weight,
      reps: lastSet?.reps ?? 10,
      isWarmup: false,
    );

    final updatedSets = [...widget.exercise.sets, newSet];
    final updatedExercise = widget.exercise.copyWith(sets: updatedSets);
    widget.onExerciseUpdate(updatedExercise);

    // Show feedback
    SnackBarService.showInfo(
      context,
      context.l10n.exerciseListSetAdded(newSet.setNumber.toString()),
    );

    HapticFeedback.lightImpact();
  }

  void _deleteSet(ExerciseSet set, int index) {
    // Remove the set from the list
    final updatedSets = List<ExerciseSet>.from(widget.exercise.sets);
    updatedSets.removeAt(index);

    // Renumber remaining sets
    for (var i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
    }

    final updatedExercise = widget.exercise.copyWith(sets: updatedSets);
    widget.onExerciseUpdate(updatedExercise);

    // Show feedback
    SnackBarService.showCustom(
      context,
      message: set.isWarmup
          ? '🗑️ Warmup set deleted'
          : '🗑️ Set ${index + 1} deleted',
      actionLabel: 'Undo',
      onAction: () {
        // Restore the set
        final restoredSets = List<ExerciseSet>.from(updatedSets);
        restoredSets.insert(index, set);

        // Renumber again
        for (var i = 0; i < restoredSets.length; i++) {
          restoredSets[i] = restoredSets[i].copyWith(setNumber: i + 1);
        }

        final restoredExercise = widget.exercise.copyWith(sets: restoredSets);
        widget.onExerciseUpdate(restoredExercise);
      },
    );

    HapticFeedback.mediumImpact();
  }

  void _editSet(BuildContext context, ExerciseSet set) {
    // Find previous set for APRE calculations
    ExerciseSet? previousSet;
    final currentSetIndex = widget.exercise.sets.indexWhere((s) => s.id == set.id);
    if (currentSetIndex > 0) {
      previousSet = widget.exercise.sets[currentSetIndex - 1];
    }

    context.showEditSetModal(
      set,
      (updatedSet) {
        final updatedSets = List<ExerciseSet>.from(
          widget.exercise.sets.map((s) {
            return s.id == set.id ? updatedSet : s;
          }),
        );
        final updatedExercise = widget.exercise.copyWith(sets: updatedSets);
        widget.onExerciseUpdate(updatedExercise);
      },
      exercise: widget.exercise,
      previousSet: previousSet,
    );
  }

  void _quickEditSet(BuildContext context, ExerciseSet set) {
    // Get the position of the set item for the overlay
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    // Find the previous set for copying values
    ExerciseSet? previousSet;
    final currentSetIndex = widget.exercise.sets.indexWhere((s) => s.id == set.id);
    if (currentSetIndex > 0) {
      previousSet = widget.exercise.sets[currentSetIndex - 1];
    }

    // Haptic feedback for quick edit
    HapticFeedback.selectionClick();

    // Get counting mode
    final countingMode = ExerciseCountingModeService.getModeFromWorkoutExercise(widget.exercise);

    // Show quick edit overlay using BuildContext extension
    context.showQuickEditOverlayV2(
      exerciseSet: set,
      onSave: (updatedSet) {
        final updatedSets = widget.exercise.sets.map((s) {
          return s.id == set.id ? updatedSet : s;
        }).toList();
        final updatedExercise = widget.exercise.copyWith(sets: updatedSets);
        widget.onExerciseUpdate(updatedExercise);
      },
      position: position,
      previousSet: previousSet,
      exerciseName: widget.exercise.name,
      countingMode: countingMode,
      setNumber: set.setNumber, // For pre-fill from last workout
    );
  }

  void _toggleSetCompletionWithFeedback(BuildContext context, ExerciseSet set) {
    final wasCompleted = set.isCompleted;

    // Check if RPE tracking is enabled and if it's NOT a warmup set
    final config = widget.config;
    final rpeEnabled = config.rpeTracking ?? true;
    final isWarmupSet = set.isWarmup;

    if (!wasCompleted) {
      // If RPE tracking is disabled OR it's a warmup set, complete directly
      if (!rpeEnabled || isWarmupSet) {
        double? duration;
        DateTime? existingStartTime;

        // Only track duration for non-warmup sets
        if (!isWarmupSet) {
          final durationTracker = ref.read(setDurationTrackerProvider);

          // Check if we have a start time for this set
          existingStartTime = durationTracker.getSetStartTime(
            widget.exercise.id,
            set.setNumber,
          );

          // If no start time, calculate one based on previous sets
          if (existingStartTime == null) {
            if (set.setNumber == 1) {
              existingStartTime = DateTime.now().subtract(const Duration(seconds: 30));
              durationTracker.setStartTime(
                widget.exercise.id,
                set.setNumber,
                existingStartTime,
              );
            } else {
              // For subsequent sets, use previous set completion time
              final previousSetIndex = set.setNumber - 2;
              if (previousSetIndex >= 0 && previousSetIndex < widget.exercise.sets.length) {
                final previousSet = widget.exercise.sets[previousSetIndex];
                if (previousSet.completedAt != null) {
                  existingStartTime = previousSet.completedAt!;
                  durationTracker.setStartTime(
                    widget.exercise.id,
                    set.setNumber,
                    existingStartTime,
                  );
                }
              }

              // Fallback to 30 seconds ago
              if (existingStartTime == null) {
                existingStartTime = DateTime.now().subtract(const Duration(seconds: 30));
                durationTracker.setStartTime(
                  widget.exercise.id,
                  set.setNumber,
                  existingStartTime,
                );
              }
            }
          }

          // Calculate duration
          duration = DateTime.now().difference(existingStartTime).inMilliseconds.toDouble();

          // Cap at 5 minutes max
          if (duration > 300000) {
            duration = 30000;
          }
        }

        // Update set with duration (null for warmup sets)
        final updatedSet = set.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
          setDurationMillis: isWarmupSet ? null : duration,
          setStartedAt: isWarmupSet ? null : existingStartTime,
          isWarmup: set.isWarmup, // Explicitly preserve warmup flag
        );

        widget.onSetToggleComplete(updatedSet);

        // Haptic feedback for set completion
        try {
          HapticFeedbackService.setCompletion(ref);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Haptic feedback error: $e');
          }
        }

        // Start rest timer for next set (if not warmup)
        if (!isWarmupSet) {
          widget.onStartRestTimer(context, updatedSet);
        }

        // Show feedback
        if (isWarmupSet) {
          SnackBarService.showCustom(
            context,
            message: '🔥 Warmup set ${set.setNumber} completed!',
            backgroundColor: context.warningColor,
          );
        } else {
          SnackBarService.showInfo(
            context,
            '✅ Set ${set.setNumber} completed!',
          );
        }
        return;
      }

      // Show RPE selector when completing a set
      final targetReps = set.reps ?? 10;

      RpeSelectorBottomSheet.show(
        context: context,
        set: set,
        targetReps: targetReps,
        exercise: widget.exercise,
        onAPRESuggestion: (suggestedWeight) {
          _handleAPRESuggestion(set, suggestedWeight);
        },
        onRPESuggestion: (suggestedWeight) {
          _handleRPESuggestion(suggestedWeight);
        },
        onConfirm: (actualReps, actualWeight, rpe) {
          // Create updated set with RPE data
          final updatedSet = set.copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
            actualReps: actualReps,
            weight: actualWeight,
            rpe: rpe,
          );

          widget.onSetToggleComplete(updatedSet);

          // Haptic feedback
          try {
            HapticFeedbackService.setCompletion(ref);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Haptic feedback error: $e');
            }
          }

          // Start rest timer
          widget.onStartRestTimer(context, updatedSet);
        },
      );
    } else {
      // Uncomplete the set
      final updatedSet = set.copyWith(
        isCompleted: false,
        completedAt: null,
        rpe: null,
      );
      widget.onSetToggleComplete(updatedSet);

      SnackBarService.showInfo(
        context,
        '↩️ Set ${set.setNumber} uncompleted',
      );
    }
  }

  void _handleAPRESuggestion(ExerciseSet currentSet, double suggestedWeight) {
    // Find the next set (Set 4 in APRE protocol)
    final nextSetIndex = currentSet.setNumber;
    if (nextSetIndex < widget.exercise.sets.length) {
      final updatedSets = List<ExerciseSet>.from(widget.exercise.sets);
      updatedSets[nextSetIndex] = updatedSets[nextSetIndex].copyWith(
        weight: suggestedWeight,
      );

      final updatedExercise = widget.exercise.copyWith(sets: updatedSets);
      widget.onExerciseUpdate(updatedExercise);

      // Show confirmation
      SnackBarService.showInfo(
        context,
        'APRE: Set ${nextSetIndex + 1} weight adjusted to ${suggestedWeight.toStringAsFixed(1)} ${widget.config.measurementUnit}',
      );
    }
  }

  void _handleRPESuggestion(double suggestedWeight) {
    // Apply suggested weight to all remaining incomplete sets
    final updatedSets = List<ExerciseSet>.from(widget.exercise.sets);
    bool hasUpdated = false;

    for (int i = 0; i < updatedSets.length; i++) {
      if (!updatedSets[i].isCompleted) {
        updatedSets[i] = updatedSets[i].copyWith(weight: suggestedWeight);
        hasUpdated = true;
      }
    }

    if (hasUpdated) {
      final updatedExercise = widget.exercise.copyWith(sets: updatedSets);
      widget.onExerciseUpdate(updatedExercise);

      // Show confirmation
      SnackBarService.showInfo(
        context,
        '${context.l10n.rpeAutoregulation}: ${context.l10n.weightAdjustedTo} ${suggestedWeight.toStringAsFixed(1)} ${widget.config.measurementUnit}',
      );
    }
  }

  bool _areAllSetsCompleted() {
    if (widget.exercise.sets.isEmpty) return false;
    return widget.exercise.sets.every((set) => set.isCompleted);
  }

  /// Builds collapsible metadata banner for APRE calculations
  Widget _buildMetadataBanner(BuildContext context) {
    final calculations = _parseCalculationMetadata();

    // Don't show banner if no calculations available
    if (calculations == null) return const SizedBox.shrink();

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Collapsible header
          InkWell(
            onTap: () {
              setState(() {
                _showMetadataBanner = !_showMetadataBanner;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  SemanticIcon(
                    icon: _showMetadataBanner ? AppIcons.expandLess : AppIcons.expandMore,
                    semanticLabel: _showMetadataBanner ? 'Collapse' : 'Expand',
                    size: AppIconSize.small,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _showMetadataBanner
                          ? context.l10n.apreHideCalculationDetails
                          : context.l10n.apreShowCalculationDetails,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SemanticIcon(
                    icon: AppIcons.info,
                    semanticLabel: 'Information',
                    size: AppIconSize.small,
                    color: context.colors.primary,
                  )
                ],
              ),
            ),
          ),
          // Expanded metadata details
          if (_showMetadataBanner) ...[
            const SizedBox(height: 8),
            CalculationMetadataDisplay(
              calculations: calculations,
              lastCalculationDate: widget.exercise.lastCalculationDate,
            ),
          ],
        ],
      ),
    );
  }

  /// Parses calculation metadata from JSON string
  Map<String, dynamic>? _parseCalculationMetadata() {
    if (widget.exercise.calculationMetadata == null) return null;

    try {
      final decoded = jsonDecode(widget.exercise.calculationMetadata!);
      return {
        'confidence': _parseConfidence(decoded['confidence']),
        'dataPoints': decoded['dataPoints'] ?? 0,
        'formula': decoded['formula'] ?? 'Brzycki',
        'dataAge': Duration(days: decoded['dataAge']?['inDays'] ?? 0),
        'standardDeviation': decoded['standardDeviation']?.toDouble() ?? 0.0,
      };
    } catch (e) {
      debugPrint('⚠️ Error parsing calculation metadata: $e');
      return null;
    }
  }

  /// Parses confidence string to enum
  CalculationConfidence _parseConfidence(dynamic confidence) {
    if (confidence == null) return CalculationConfidence.unknown;
    if (confidence is CalculationConfidence) return confidence;

    final confStr = confidence.toString().toLowerCase();
    switch (confStr) {
      case 'high':
        return CalculationConfidence.high;
      case 'medium':
        return CalculationConfidence.medium;
      case 'low':
        return CalculationConfidence.low;
      default:
        return CalculationConfidence.unknown;
    }
  }
}

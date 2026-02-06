import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/minimal_set_edit_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/rpe_selector_bottom_sheet.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/add_dropset_stage_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/add_rest_pause_set_modal.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_expansion_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_weight_prefill_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/set_display_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/set_duration_tracker_provider.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/haptic_feedback_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/rpe_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/progress_badge.dart';
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
/// - DropSet/RestPause execute buttons
///
/// Handles:
/// - Set completion with duration tracking
/// - Set editing (quick edit on double-tap, full edit on long-press)
/// - Set deletion with undo functionality
/// - RPE auto-regulation suggestions
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
    this.tutorialFirstSetKey,
  });

  final Exercise exercise;
  final AppConfig config;
  final Function(Exercise) onExerciseUpdate;
  final Function(ExerciseSet) onSetToggleComplete;
  final Function(BuildContext, ExerciseSet) onStartRestTimer;
  final Function(DropSetExercise) onExecuteDropSet;
  final Function(RestPauseExercise) onExecuteRestPause;
  final VoidCallback onCollapseExercise;

  /// Optional key for tutorial overlay on the first set row
  final GlobalKey? tutorialFirstSetKey;

  @override
  ConsumerState<ExerciseListItemSets> createState() =>
      _ExerciseListItemSetsState();
}

class _ExerciseListItemSetsState extends ConsumerState<ExerciseListItemSets> {
  // ✅ OPTIMIZATION: Cache counting mode to avoid calling service for every set
  // Previous implementation called ExerciseCountingModeService.getModeFromWorkoutExercise()
  // inside _buildSetDetailsForMode() which was executed for EVERY set on EVERY rebuild.
  late ExerciseCountingMode _cachedCountingMode;

  // ✅ TUT: Track if user has started the first set (for explicit start button)
  bool _firstSetManuallyStarted = false;

  @override
  void initState() {
    super.initState();
    _cachedCountingMode =
        ExerciseCountingModeService.getModeFromWorkoutExercise(widget.exercise);

    // ✅ FIX: Start duration tracking for the first incomplete set
    // Only auto-initialize if setDurationTracking is OFF (no manual start needed)
    _initializeDurationTracking();
  }

  /// Initialize duration tracking for the first incomplete set
  /// When setDurationTracking is ON, we wait for the manual "Start Set" button
  /// When setDurationTracking is OFF, tracking starts automatically
  void _initializeDurationTracking() {
    // Use post-frame callback to ensure ref is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final config = ref.read(appConfigProvider);
      final setDurationTracking = config.setDurationTracking ?? false;

      // If setDurationTracking is ON, wait for manual start button
      // Don't auto-initialize tracking for the first set
      if (setDurationTracking && !_firstSetManuallyStarted) {
        if (kDebugMode) {
          debugPrint(
            '⏱️ [TUT] Waiting for manual start button (setDurationTracking=ON)',
          );
        }
        return;
      }

      // Find first incomplete non-warmup set
      final firstIncompleteSet = widget.exercise.sets.firstWhere(
        (s) => !s.isCompleted && !s.isWarmup,
        orElse: () => widget.exercise.sets.isNotEmpty
            ? widget.exercise.sets.first
            : ExerciseSet(setNumber: 1),
      );

      // Only start tracking if there's an incomplete set
      if (!firstIncompleteSet.isCompleted) {
        final durationTracker = ref.read(setDurationTrackerProvider);

        // Check if tracking is already started for this set
        final existingStartTime = durationTracker.getSetStartTime(
          widget.exercise.id,
          firstIncompleteSet.setNumber,
        );

        if (existingStartTime == null) {
          durationTracker.startSet(
            widget.exercise.id,
            firstIncompleteSet.setNumber,
          );

          if (kDebugMode) {
            debugPrint(
              '⏱️ [TUT FIX] Initialized tracking for first incomplete set '
              '${firstIncompleteSet.setNumber} (exercise: ${widget.exercise.id})',
            );
          }
        }
      }
    });
  }

  /// ✅ TUT: Handle manual start of first set
  void _onStartFirstSet() {
    setState(() {
      _firstSetManuallyStarted = true;
    });

    // Find first incomplete non-warmup set
    final firstIncompleteSet = widget.exercise.sets.firstWhere(
      (s) => !s.isCompleted && !s.isWarmup,
      orElse: () => widget.exercise.sets.first,
    );

    final durationTracker = ref.read(setDurationTrackerProvider);
    durationTracker.startSet(widget.exercise.id, firstIncompleteSet.setNumber);

    if (kDebugMode) {
      debugPrint(
        '⏱️ [TUT] Manual start for set ${firstIncompleteSet.setNumber} '
        '(exercise: ${widget.exercise.id})',
      );
    }

    // Haptic feedback
    HapticFeedback.mediumImpact();
  }

  @override
  void didUpdateWidget(ExerciseListItemSets oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only recalculate counting mode if exercise changed
    if (oldWidget.exercise.countingMode != widget.exercise.countingMode ||
        oldWidget.exercise.id != widget.exercise.id) {
      _cachedCountingMode =
          ExerciseCountingModeService.getModeFromWorkoutExercise(
            widget.exercise,
          );
    }

    // ✅ FIX: Re-initialize tracking if exercise ID changed (new exercise)
    // or if sets were added (handle adding new sets during workout)
    if (oldWidget.exercise.id != widget.exercise.id) {
      _initializeDurationTracking();
    } else if (widget.exercise.sets.length > oldWidget.exercise.sets.length) {
      // New sets were added - ensure tracking is active for first incomplete
      _initializeDurationTracking();
    }
  }

  /// Localized label for a [PrefillSource].
  String _prefillSourceLabel(PrefillSource source) {
    switch (source) {
      case PrefillSource.history:
        return context.l10n.weightSuggestionFromHistory;
      case PrefillSource.progressiveOverload:
        return context.l10n.weightSuggestionProgressiveOverload;
      case PrefillSource.strengthStandard:
        return context.l10n.weightSuggestionFromStandard;
      case PrefillSource.fallback:
        return context.l10n.weightSuggestionFallback;
    }
  }

  /// Whether [set]'s weight matches the prefill suggestion (not yet edited).
  bool _isSuggestedWeight(ExerciseSet set) {
    if (set.isCompleted || set.weight == null) return false;
    final prefill = ref.read(
      exerciseWeightPrefillProvider(widget.exercise.name),
    );
    final prefillValue = prefill.value;
    if (prefillValue == null) return false;
    return (set.weight! - prefillValue.weight).abs() < 0.01;
  }

  @override
  Widget build(BuildContext context) {
    return _buildSetsSection(context, widget.config);
  }

  Widget _buildSetsSection(BuildContext context, AppConfig config) {
    if (widget.exercise.sets.isEmpty) {
      // For DropSet exercises, show stages and execute button
      if (widget.exercise.type == ExerciseType.dropset) {
        final dropsetExercise = widget.exercise as DropSetExercise;
        return _buildDropSetSection(context, dropsetExercise);
      }

      // For RestPause exercises, show section with sets
      if (widget.exercise.type == ExerciseType.restPause) {
        final restPauseExercise = widget.exercise as RestPauseExercise;
        return _buildRestPauseSection(context, restPauseExercise);
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
                widget.exercise.sets
                    .where((s) => s.isCompleted)
                    .length
                    .toString(),
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
        // ✅ TUT: Show "Start Set" button when setDurationTracking is ON
        // and user hasn't started the first set yet
        _buildStartSetButtonIfNeeded(context, config),
        ...widget.exercise.sets.asMap().entries.map(
          (entry) => _buildSetItem(context, entry.key, entry.value, config),
        ),
        const SizedBox(height: 8),
        // Add set button (with smooth animated collapse button when completed)
        // ✅ FIX: Wrap in ClipRect to prevent red box overflow during slide animation
        ClipRect(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position:
                    Tween<Offset>(
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
                        child: Semantics(
                          label: context.l10n.addSet,
                          button: true,
                          child: InkWell(
                            onTap: () => _addNewSet(),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: context.colors.primaryContainer.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.colors.primary.withValues(
                                  alpha: 0.3,
                                ),
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
                      ),
                      const SizedBox(width: 8),
                      // Collapse button (right) - no animation to prevent flash on scroll rebuild
                      Expanded(
                        child: Semantics(
                          label: context.l10n.collapseExercise,
                          button: true,
                          child: InkWell(
                            onTap: () {
                              widget.onCollapseExercise();
                              HapticFeedback.lightImpact();
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: context.colors.secondaryContainer
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: context.colors.secondary.withValues(
                                  alpha: 0.3,
                                ),
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
                : Semantics(
                    label: context.l10n.addSet,
                    button: true,
                    child: InkWell(
                      key: const ValueKey('button_add_only'),
                      onTap: () => _addNewSet(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer.withValues(
                          alpha: 0.2,
                        ),
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
    final displayMode = ref.watch(setDisplayProvider);

    // Use robust key that includes index as fallback in case IDs are empty
    final exerciseId = widget.exercise.id.isNotEmpty
        ? widget.exercise.id
        : 'ex_$index';
    final setId = set.id.isNotEmpty ? set.id : 'set_$index';

    return Slidable(
      key: ValueKey('slidable_${exerciseId}_${setId}_$index'),
      // Swipe RIGHT → Toggle Warmup (swipe completo = toggle diretto)
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.3,
        dismissible: DismissiblePane(
          onDismissed: () {
            // Non viene mai chiamato perché confirmDismiss ritorna false
          },
          closeOnCancel: true,
          confirmDismiss: () async {
            // Esegui toggle e poi ritorna false per NON rimuovere la riga
            unawaited(HapticFeedback.mediumImpact());
            _toggleWarmupSet(set, index);
            return false; // NON dismissare, solo toggle
          },
        ),
        children: [
          CustomSlidableAction(
            onPressed: (slideContext) {
              HapticFeedback.mediumImpact();
              _toggleWarmupSet(set, index);
              Slidable.of(slideContext)?.close();
            },
            backgroundColor: context.colors.surface.withValues(alpha: 0),
            foregroundColor: isWarmup
                ? context.colors.onSurfaceVariant
                : context.warningColor,
            padding: EdgeInsets.zero,
            child: SemanticIcon(
              icon: isWarmup ? AppIcons.workout : AppIcons.streak,
              semanticLabel: isWarmup
                  ? context.l10n.workingSet
                  : context.l10n.warmupSet,
              size: AppIconSize.large,
              color: isWarmup
                  ? context.colors.onSurfaceVariant
                  : context.warningColor,
            ),
          ),
        ],
      ),
      // Swipe LEFT → Delete (with confirmation)
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.3,
        dismissible: DismissiblePane(
          onDismissed: () {
            // Will be handled after confirmation
          },
          closeOnCancel: true,
          confirmDismiss: () async {
            unawaited(HapticFeedback.heavyImpact());
            final confirmed = await _showDeleteConfirmation(
              context,
              set,
              index,
              isWarmup,
            );
            if (confirmed) {
              _deleteSet(set, index);
            }
            return false; // Don't actually dismiss, we handle it manually
          },
        ),
        children: [
          CustomSlidableAction(
            onPressed: (slideContext) {
              HapticFeedback.heavyImpact();
              Slidable.of(slideContext)?.close();
              _confirmDeleteSet(context, set, index, isWarmup);
            },
            backgroundColor: context.colors.surface.withValues(alpha: 0),
            foregroundColor: context.errorColor,
            padding: EdgeInsets.zero,
            child: SemanticIcon(
              icon: AppIcons.deleteOutline,
              semanticLabel: context.l10n.delete,
              size: AppIconSize.large,
              color: context.errorColor,
            ),
          ),
        ],
      ),
      // ✅ IMPROVED UX: Larger row with visible action icons
      child: Semantics(
        label: 'Set ${index + 1}${isWarmup ? ' warmup' : ''}${set.isCompleted ? ' completed' : ''}',
        hint: set.isCompleted ? 'Tap to mark as incomplete' : 'Tap to mark as complete',
        button: true,
        child: GestureDetector(
          onTap: () => _toggleSetCompletionWithFeedback(context, set),
          child: Container(
            // Apply tutorial key only to the first set (index 0)
            key: index == 0 ? widget.tutorialFirstSetKey : null,
            margin: EdgeInsets.only(bottom: displayMode.bottomMargin),
            padding: EdgeInsets.symmetric(
              horizontal: displayMode.horizontalPadding,
              vertical: displayMode.verticalPadding,
            ),
            decoration: BoxDecoration(
            color: isWarmup
                ? context.warningContainer
                : set.isCompleted
                ? context.colors.tertiary.withValues(alpha: 0.1)
                : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(displayMode.borderRadius),
            border: isWarmup
                ? Border.all(color: context.warningColor.withValues(alpha: 0.3))
                : set.isCompleted
                ? Border.all(
                    color: context.colors.tertiary.withValues(alpha: 0.3),
                  )
                : null,
          ),
          child: Row(
            children: [
              // Set number with warmup indicator
              Container(
                width: displayMode.circleSize,
                height: displayMode.circleSize,
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
                            fontSize: 12,
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

                    // Suggested weight indicator (lightbulb)
                    if (_isSuggestedWeight(set)) ...[
                      const SizedBox(width: 4),
                      Icon(
                        AppIcons.lightbulbOutline,
                        size: 14,
                        color: context.colors.primary,
                      ),
                    ],

                    // RPE indicator if completed
                    if (set.isCompleted && set.rpe != null) ...[
                      const SizedBox(width: 8),
                      RpeIndicator(rpe: set.rpe!),
                    ],
                  ],
                ),
              ),

              // ✅ NEW: Visible action icons (edit + delete)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Set duration indicator (when setDurationTracking enabled)
                  if (set.isCompleted &&
                      set.setDurationMillis != null &&
                      (config.setDurationTracking ?? false)) ...[
                    _buildSetDurationChip(set.setDurationMillis!),
                    const SizedBox(width: 8),
                  ],
                  // Completion checkmark
                  if (set.isCompleted) ...[
                    SemanticIcon(
                      icon: AppIcons.checkCircle,
                      semanticLabel: 'Completed',
                      size: AppIconSize.small,
                      color: context.colors.tertiary,
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Edit button (delete via swipe left)
                  Semantics(
                    label: context.l10n.edit,
                    button: true,
                    child: InkWell(
                      onTap: () => _quickEditSet(context, set),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SemanticIcon(
                        icon: AppIcons.edit,
                        semanticLabel: context.l10n.edit,
                        size: AppIconSize.small,
                        color: context.colors.primary,
                      ),
                    ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  /// Build set details widgets based on counting mode
  /// ✅ OPTIMIZATION: Uses cached counting mode instead of calling service per set
  List<Widget> _buildSetDetailsForMode(ExerciseSet set, AppConfig config) {
    switch (_cachedCountingMode) {
      case ExerciseCountingMode.weighted:
        // Weighted: Show weight × reps
        // ✅ Removed lineThrough - completed sets already show check icon
        return [
          if (set.weight != null) ...[
            Text(
              set.weight!.formatWeight(config.measurementUnit),
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
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
              ),
            ),
        ];

      case ExerciseCountingMode.reps:
        // Reps-only: Show reps only (bodyweight exercises)
        // ✅ Removed lineThrough - completed sets already show check icon
        return [
          if (set.reps != null)
            Text(
              set.actualReps != null && set.isCompleted
                  ? '${set.actualReps}/${set.reps} reps'
                  : '${set.reps} reps',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
        ];

      case ExerciseCountingMode.time:
        // Time-based: Show duration (isometric exercises)
        // ✅ FIX: Prioritize seconds field for time mode, fallback to reps for backward compatibility
        // ✅ Removed lineThrough - completed sets already show check icon
        final duration = set.seconds ?? set.reps ?? 60;
        return [
          Text(
            _formatDuration(duration),
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
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
      final workingSets = widget.exercise.sets
          .where((s) => !s.isWarmup)
          .toList();
      lastSet = workingSets.isNotEmpty
          ? workingSets.last
          : widget.exercise.sets.last;
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

  /// Toggle warmup state of a set (swipe right gesture)
  void _toggleWarmupSet(ExerciseSet set, int index) {
    final isCurrentlyWarmup = set.isWarmup;
    final updatedSet = set.copyWith(isWarmup: !isCurrentlyWarmup);

    final updatedSets = List<ExerciseSet>.from(widget.exercise.sets);
    updatedSets[index] = updatedSet;

    final updatedExercise = widget.exercise.copyWith(sets: updatedSets);
    widget.onExerciseUpdate(updatedExercise);

    // Show feedback
    if (!isCurrentlyWarmup) {
      SnackBarService.showCustom(
        context,
        message: '🔥 ${context.l10n.setMarkedAsWarmup}',
        backgroundColor: context.warningColor,
      );
    } else {
      SnackBarService.showInfo(
        context,
        '💪 ${context.l10n.setMarkedAsWorking}',
      );
    }
  }

  /// Show delete confirmation dialog and return result
  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    ExerciseSet set,
    int index,
    bool isWarmup,
  ) async {
    final l10n = context.l10n;

    final confirmed = await showGeneralDialog<bool>(
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
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
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
                  style: TextButton.styleFrom(
                    foregroundColor: context.errorColor,
                  ),
                  child: Text(l10n.delete),
                ),
              ],
            ),
          ),
        );
      },
    );

    return confirmed == true;
  }

  /// ✅ Confirm delete with dialog (visible button action)
  Future<void> _confirmDeleteSet(
    BuildContext context,
    ExerciseSet set,
    int index,
    bool isWarmup,
  ) async {
    final l10n = context.l10n;

    final confirmed = await showGeneralDialog<bool>(
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
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
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
                  style: TextButton.styleFrom(
                    foregroundColor: context.errorColor,
                  ),
                  child: Text(l10n.delete),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      _deleteSet(set, index);
    }
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

  void _quickEditSet(BuildContext context, ExerciseSet set) {
    final currentSetIndex = widget.exercise.sets.indexWhere(
      (s) => s.id == set.id,
    );
    final previousSet = currentSetIndex > 0
        ? widget.exercise.sets[currentSetIndex - 1]
        : null;

    // Haptic feedback for quick edit
    HapticFeedback.selectionClick();

    // Suggested weight from prefill provider
    final prefill = ref
        .read(exerciseWeightPrefillProvider(widget.exercise.name))
        .value;
    final suggestedSource = prefill != null
        ? _prefillSourceLabel(prefill.source)
        : null;

    // ✅ NEW: Use MinimalSetEditSheet for cleaner UX
    context.showMinimalSetEditSheet(
      exerciseSet: set,
      suggestedWeight: prefill?.weight,
      suggestedSource: suggestedSource,
      onSave: (updatedSet) {
        final updatedSets = widget.exercise.sets.map((s) {
          return s.id == set.id ? updatedSet : s;
        }).toList();
        final updatedExercise = widget.exercise.copyWith(sets: updatedSets);
        widget.onExerciseUpdate(updatedExercise);
      },
      currentSetIndex: currentSetIndex,
      totalSets: widget.exercise.sets.length,
      allSets: widget.exercise.sets,
      previousSet: previousSet,
      // Apply to all sets (first set only)
      onApplyToAll: (updatedSet) {
        final updatedSets = widget.exercise.sets.map((s) {
          return s.copyWith(weight: updatedSet.weight, reps: updatedSet.reps);
        }).toList();
        final updatedExercise = widget.exercise.copyWith(sets: updatedSets);
        widget.onExerciseUpdate(updatedExercise);
      },
      onSaveAndNext: (updatedSet) {
        // Save current set
        final updatedSets = widget.exercise.sets.map((s) {
          return s.id == set.id ? updatedSet : s;
        }).toList();
        final updatedExercise = widget.exercise.copyWith(sets: updatedSets);
        widget.onExerciseUpdate(updatedExercise);

        // Open edit for next set (if exists)
        final nextSetIndex = currentSetIndex + 1;
        if (nextSetIndex < widget.exercise.sets.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _quickEditSet(context, widget.exercise.sets[nextSetIndex]);
            }
          });
        }
      },
      onSaveAndPrevious: (updatedSet) {
        // Save current set
        final updatedSets = widget.exercise.sets.map((s) {
          return s.id == set.id ? updatedSet : s;
        }).toList();
        final updatedExercise = widget.exercise.copyWith(sets: updatedSets);
        widget.onExerciseUpdate(updatedExercise);

        // Open edit for previous set (if exists)
        final prevSetIndex = currentSetIndex - 1;
        if (prevSetIndex >= 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _quickEditSet(context, widget.exercise.sets[prevSetIndex]);
            }
          });
        }
      },
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
              existingStartTime = DateTime.now().subtract(
                const Duration(seconds: 30),
              );
              durationTracker.setStartTime(
                widget.exercise.id,
                set.setNumber,
                existingStartTime,
              );
            } else {
              // For subsequent sets, use previous set completion time
              final previousSetIndex = set.setNumber - 2;
              if (previousSetIndex >= 0 &&
                  previousSetIndex < widget.exercise.sets.length) {
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
                existingStartTime = DateTime.now().subtract(
                  const Duration(seconds: 30),
                );
                durationTracker.setStartTime(
                  widget.exercise.id,
                  set.setNumber,
                  existingStartTime,
                );
              }
            }
          }

          // Calculate duration
          duration = DateTime.now()
              .difference(existingStartTime)
              .inMilliseconds
              .toDouble();

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

        // ✅ FIX: Start duration tracking for NEXT set immediately
        // This ensures accurate tracking even if user doesn't use the rest timer
        _startTrackingNextSet(set.setNumber);

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

          // ✅ FIX: Start duration tracking for NEXT set immediately
          // This ensures accurate tracking even if user doesn't use the rest timer
          _startTrackingNextSet(set.setNumber);
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

      SnackBarService.showInfo(context, '↩️ Set ${set.setNumber} uncompleted');
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

  /// ✅ FIX: Start duration tracking for the next set
  ///
  /// This ensures accurate tracking even if the user doesn't use the rest timer.
  /// Called after completing a set to immediately start tracking the next one.
  void _startTrackingNextSet(int completedSetNumber) {
    final nextSetNumber = completedSetNumber + 1;

    // Check if there's a next set to track
    final hasNextSet = widget.exercise.sets.any(
      (s) => s.setNumber == nextSetNumber && !s.isCompleted,
    );

    if (hasNextSet) {
      final durationTracker = ref.read(setDurationTrackerProvider);
      durationTracker.startSet(widget.exercise.id, nextSetNumber);

      if (kDebugMode) {
        debugPrint(
          '⏱️ [TUT FIX] Started tracking for next set $nextSetNumber (exercise: ${widget.exercise.id})',
        );
      }
    }
  }

  /// ✅ TUT: Build "Start Set" button when setDurationTracking is enabled
  ///
  /// Shows a prominent button before the first incomplete set to let the user
  /// explicitly start tracking the set duration. This provides accurate TUT
  /// measurements as tracking only begins when the user is truly ready.
  Widget _buildStartSetButtonIfNeeded(BuildContext context, AppConfig config) {
    final setDurationTracking = config.setDurationTracking ?? false;

    // Don't show if tracking is disabled
    if (!setDurationTracking) {
      return const SizedBox.shrink();
    }

    // Don't show if user already started
    if (_firstSetManuallyStarted) {
      return const SizedBox.shrink();
    }

    // Don't show if all sets are completed
    final hasIncompleteSet = widget.exercise.sets.any((s) => !s.isCompleted);
    if (!hasIncompleteSet) {
      return const SizedBox.shrink();
    }

    // Check if there's already a start time (e.g., from rest timer)
    final firstIncompleteSet = widget.exercise.sets.firstWhere(
      (s) => !s.isCompleted && !s.isWarmup,
      orElse: () => widget.exercise.sets.firstWhere(
        (s) => !s.isCompleted,
        orElse: () => widget.exercise.sets.first,
      ),
    );

    final durationTracker = ref.read(setDurationTrackerProvider);
    final existingStartTime = durationTracker.getSetStartTime(
      widget.exercise.id,
      firstIncompleteSet.setNumber,
    );

    // If tracking already started (e.g., from rest timer), don't show button
    if (existingStartTime != null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FilledButton.icon(
        onPressed: _onStartFirstSet,
        icon: const SemanticIcon(
          icon: AppIcons.playArrow,
          semanticLabel: 'Start',
          size: AppIconSize.small,
        ),
        label: Text(context.l10n.startSet),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          backgroundColor: context.colors.secondary,
          foregroundColor: context.colors.onSecondary,
        ),
      ),
    );
  }

  /// Build the set duration chip showing tracked TUT
  /// Displays milliseconds as seconds with 1 decimal (e.g., "12.3s")
  Widget _buildSetDurationChip(double durationMillis) {
    final seconds = durationMillis / 1000;
    final displayText = seconds < 10
        ? '${seconds.toStringAsFixed(1)}s'
        : '${seconds.toStringAsFixed(0)}s';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.colors.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SemanticIcon(
            icon: AppIcons.timer,
            semanticLabel: 'Duration',
            size: AppIconSize.tiny,
            color: context.colors.secondary,
          ),
          const SizedBox(width: 2),
          Text(
            displayText,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Format duration in seconds to human readable format
  /// e.g., 60 -> "1:00", 90 -> "1:30", 30 -> "0:30"
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '${seconds}s';
  }

  // ============================================================================
  // DROPSET SECTION
  // ============================================================================

  /// Build the DropSet section showing stages and execute button
  Widget _buildDropSetSection(
    BuildContext context,
    DropSetExercise dropsetExercise,
  ) {
    final stages = dropsetExercise.stages;
    final completedStages = stages.where((s) => s.isCompleted).toList();
    final allCompleted =
        completedStages.length == stages.length && stages.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with progress
        Row(
          children: [
            Text(
              context.l10n.dropsetStages(stages.length),
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            // Info button for dropset explanation (helps beginners like Marco)
            GestureDetector(
              onTap: () => _showDropsetInfoDialog(context),
              child: SemanticIcon(
                icon: AppIcons.infoOutline,
                semanticLabel: context.l10n.dropsetInfoTitle,
                size: AppIconSize.tiny,
                color: context.colors.primary,
              ),
            ),
            // ✅ FASE 5: Usa ProgressBadge widget per consistenza
            if (stages.isNotEmpty) ...[
              const SizedBox(width: 8),
              ProgressBadge(
                completed: completedStages.length,
                total: stages.length,
                showAsComplete: allCompleted,
                compact: true,
              ),
            ],
            const Spacer(),
            // ✅ COERENZA: Mostra sempre l'header colonne (come Single Exercise)
            if (stages.isNotEmpty)
              Text(
                'Weight × Reps',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // ✅ COERENZA: Mostra SEMPRE gli stages (come Single Exercise mostra sempre i sets)
        // Questo permette a Marco (principiante) di vedere cosa aspettarsi PRIMA di eseguire
        if (stages.isNotEmpty) ...[
          ...stages.asMap().entries.map((entry) {
            final index = entry.key;
            final stage = entry.value;
            return _buildDropSetStageRow(context, index, stage, stages);
          }),
          const SizedBox(height: 8),

          // ✅ Task 3: Volume Summary with trend indicator
          if (allCompleted)
            _buildDropSetVolumeSummary(
              context,
              dropsetExercise,
              completedStages,
            ),
        ],

        // Execute/Re-run button
        Semantics(
          label: context.l10n.executeDropset,
          button: true,
          child: GestureDetector(
            onTap: () => widget.onExecuteDropSet(dropsetExercise),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
              color: allCompleted
                  ? context.colors.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    )
                  : context.colors.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: allCompleted
                    ? context.colors.outline.withValues(alpha: 0.3)
                    : context.colors.tertiary.withValues(alpha: 0.5),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                SemanticIcon(
                  icon: allCompleted
                      ? AppIcons.refresh
                      : AppIcons.playCircleOutline,
                  semanticLabel: context.l10n.executeDropset,
                  size: AppIconSize.small,
                  color: allCompleted
                      ? context.colors.onSurfaceVariant
                      : context.colors.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    allCompleted
                        ? context.l10n.rerunDropset
                        : context.l10n.executeDropset,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: allCompleted
                          ? context.colors.onSurfaceVariant
                          : context.colors.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SemanticIcon(
                  icon: AppIcons.forwardIos,
                  semanticLabel: context.l10n.executeDropset,
                  size: AppIconSize.tiny,
                  color: allCompleted
                      ? context.colors.onSurfaceVariant
                      : context.colors.tertiary,
                ),
              ],
            ),
          ),
          ),
        ),

        // Add Stage button (only when dropset is completed)
        if (allCompleted) ...[
          const SizedBox(height: 8),
          Semantics(
            label: context.l10n.addDropsetStage,
            button: true,
            child: GestureDetector(
              onTap: () => _onAddDropSetStage(context, dropsetExercise),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.5),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SemanticIcon(
                    icon: AppIcons.add,
                    semanticLabel: context.l10n.addDropsetStage,
                    size: AppIconSize.small,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.addDropsetStage,
                    style: context.textTheme.bodySmall?.copyWith(
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
      ],
    );
  }

  /// Show informational dialog explaining what a dropset is
  /// Helps beginners (like Marco persona) understand the technique
  void _showDropsetInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            SemanticIcon(
              icon: AppIcons.info,
              semanticLabel: context.l10n.dropsetInfoTitle,
              size: AppIconSize.small,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.dropsetInfoTitle,
                style: context.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.dropsetInfoDescription,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemanticIcon(
                    icon: AppIcons.lightbulbOutline,
                    semanticLabel: 'Tip',
                    size: AppIconSize.small,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.dropsetInfoTip,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.gotIt),
          ),
        ],
      ),
    );
  }

  /// Handle adding a new stage to a completed dropset
  Future<void> _onAddDropSetStage(
    BuildContext context,
    DropSetExercise dropsetExercise,
  ) async {
    final stages = dropsetExercise.stages;
    if (stages.isEmpty) return;

    final lastStage = stages.last;
    final newStageNumber = stages.length + 1;

    final newStage = await AddDropsetStageModal.show(
      context: context,
      exerciseName: dropsetExercise.name,
      lastStageWeight: lastStage.weight,
      lastStageReps: lastStage.effectiveReps,
      stageNumber: newStageNumber,
    );

    if (newStage != null && mounted) {
      // Create updated exercise with the new stage
      final updatedStages = [...stages, newStage];
      final updatedExercise = DropSetExercise(
        id: dropsetExercise.id,
        name: dropsetExercise.name,
        category: dropsetExercise.category,
        stages: updatedStages,
        notes: dropsetExercise.notes,
        restTime: dropsetExercise.restTime,
      );

      widget.onExerciseUpdate(updatedExercise);

      // Haptic feedback
      HapticFeedbackService.selection(ref);
    }
  }

  /// Build volume summary with trend indicator (Task 3)
  /// Shows total volume and comparison with previous dropset if available
  Widget _buildDropSetVolumeSummary(
    BuildContext context,
    DropSetExercise dropsetExercise,
    List<DropSetStage> completedStages,
  ) {
    // Calculate total volume (weight × reps for each stage)
    final totalVolume = completedStages.fold<double>(
      0.0,
      (sum, stage) => sum + (stage.weight * stage.effectiveReps),
    );

    // Get previous dropset volume from history (if available)
    final previousVolume = ref.watch(
      previousDropsetVolumeProvider(dropsetExercise.name),
    );

    return previousVolume.when(
      data: (prevVol) {
        // Calculate trend
        final ({IconData icon, Color color, String label})? trend;
        if (prevVol != null && prevVol > 0) {
          final diff = totalVolume - prevVol;
          final percentChange = (diff / prevVol * 100).abs();
          if (diff > 0) {
            trend = (
              icon: AppIcons.trendUp,
              color: context.colors.success,
              label: '+${percentChange.toStringAsFixed(0)}%',
            );
          } else if (diff < 0) {
            trend = (
              icon: AppIcons.trendDown,
              color: context.colors.error,
              label: '-${percentChange.toStringAsFixed(0)}%',
            );
          } else {
            trend = (
              icon: AppIcons.horizontalRule,
              color: context.colors.onSurfaceVariant,
              label: '=',
            );
          }
        } else {
          trend = null;
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.colors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              // Volume icon
              SemanticIcon(
                icon: AppIcons.analytics,
                semanticLabel: context.l10n.totalVolume,
                size: AppIconSize.small,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              // Volume value
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.totalVolume,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${totalVolume.toStringAsFixed(0)} kg',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              // Trend indicator (if available)
              if (trend != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: trend.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SemanticIcon(
                        icon: trend.icon,
                        semanticLabel: trend.label,
                        size: AppIconSize.tiny,
                        color: trend.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend.label,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: trend.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Build a single dropset stage row with completion animation
  Widget _buildDropSetStageRow(
    BuildContext context,
    int index,
    DropSetStage stage,
    List<DropSetStage> allStages,
  ) {
    final isCompleted = stage.isCompleted;
    final isFirst = index == 0;

    // Calculate weight drop from previous stage
    String? weightDropText;
    if (!isFirst && index < allStages.length) {
      final prevWeight = allStages[index - 1].weight;
      final drop = prevWeight - stage.weight;
      if (drop > 0) {
        weightDropText = '-${drop.toStringAsFixed(1)}';
      }
    }

    // ✅ UX: AnimatedContainer for smooth transitions (Task 2)
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCompleted
            ? context.colors.surfaceContainerHighest.withValues(alpha: 0.5)
            : context.colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted
              ? context.colors.success.withValues(alpha: 0.3)
              : context.colors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Stage number with animated checkmark
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted
                  ? context.colors.success.withValues(alpha: 0.1)
                  : context.colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  // ✅ Animated scale on checkmark for completion feedback
                  ? TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.elasticOut,
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, scale, child) => Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                      child: SemanticIcon(
                        icon: AppIcons.complete,
                        semanticLabel: 'Completed',
                        size: AppIconSize.tiny,
                        color: context.colors.success,
                      ),
                    )
                  : Text(
                      '${index + 1}',
                      style: context.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Weight
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  '${stage.weight.toStringAsFixed(stage.weight.truncateToDouble() == stage.weight ? 0 : 1)} kg',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? context.colors.onSurface
                        : context.colors.onSurfaceVariant,
                  ),
                ),
                if (weightDropText != null) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      weightDropText,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Reps
          Expanded(
            child: Text(
              '${stage.effectiveReps} reps',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isCompleted
                    ? context.colors.onSurface
                    : context.colors.onSurfaceVariant,
              ),
            ),
          ),

          // RPE indicator (if completed with RPE)
          if (isCompleted && stage.rpe != null)
            RpeIndicator(rpe: stage.rpe!, showLabel: false, compact: true),
        ],
      ),
    );
  }

  /// Build the RestPause section showing sets and execute button
  Widget _buildRestPauseSection(
    BuildContext context,
    RestPauseExercise restPauseExercise,
  ) {
    final sets = restPauseExercise.restPauseSets;
    final completedSets = sets.where((s) => s.isCompleted).toList();
    // Use isCompleted which checks if ALL sets are completed
    final allCompleted = restPauseExercise.isCompleted;
    final hasCompletedSets = completedSets.isNotEmpty;
    final totalReps = completedSets.fold(0, (sum, s) => sum + s.effectiveReps);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with info
        Row(
          children: [
            Text(
              '${restPauseExercise.weight.toStringAsFixed(restPauseExercise.weight.truncateToDouble() == restPauseExercise.weight ? 0 : 1)} kg',
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.colors.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.l10n.restPauseSets(sets.length),
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // ✅ FASE 5: Usa ProgressBadge widget per consistenza
            const SizedBox(width: 8),
            ProgressBadge(
              completed: totalReps,
              total: restPauseExercise.targetReps,
              suffix: 'reps',
              showAsComplete: totalReps >= restPauseExercise.targetReps,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ✅ FASE 5: Usa ProgressBadgeWithBar per progress visivo
        if (restPauseExercise.targetReps > 0) ...[
          ProgressBadgeWithBar(
            current: totalReps,
            target: restPauseExercise.targetReps,
            suffix: 'reps',
            barHeight: 6,
          ),
          const SizedBox(height: 8),
        ],

        // Show sets if any are completed
        if (hasCompletedSets) ...[
          ...completedSets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;
            return _buildRestPauseSetRow(context, index, set);
          }),
          const SizedBox(height: 8),
        ],

        // Execute/Re-run button
        Semantics(
          label: allCompleted ? context.l10n.rerunRestPause : context.l10n.executeRestPause,
          button: true,
          child: GestureDetector(
            onTap: () => widget.onExecuteRestPause(restPauseExercise),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: allCompleted
                    ? context.colors.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      )
                    : context.colors.tertiaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: allCompleted
                      ? context.colors.outline.withValues(alpha: 0.3)
                      : context.colors.tertiary.withValues(alpha: 0.5),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  SemanticIcon(
                    icon: allCompleted
                        ? AppIcons.refresh
                        : AppIcons.playCircleOutline,
                    semanticLabel: context.l10n.executeRestPause,
                    size: AppIconSize.small,
                    color: allCompleted
                        ? context.colors.onSurfaceVariant
                        : context.colors.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      allCompleted
                          ? context.l10n.rerunRestPause
                          : context.l10n.executeRestPause,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: allCompleted
                            ? context.colors.onSurfaceVariant
                            : context.colors.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SemanticIcon(
                    icon: AppIcons.forwardIos,
                    semanticLabel: context.l10n.executeRestPause,
                    size: AppIconSize.tiny,
                    color: allCompleted
                        ? context.colors.onSurfaceVariant
                        : context.colors.tertiary,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Add Set button (only when rest-pause has been executed)
        if (allCompleted) ...[
          const SizedBox(height: 8),
          Semantics(
            label: context.l10n.addRestPauseSet,
            button: true,
            child: GestureDetector(
              onTap: () => _onAddRestPauseSet(context, restPauseExercise),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.colors.primary.withValues(alpha: 0.5),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SemanticIcon(
                      icon: AppIcons.add,
                      semanticLabel: context.l10n.addRestPauseSet,
                      size: AppIconSize.small,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.addRestPauseSet,
                      style: context.textTheme.bodySmall?.copyWith(
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
      ],
    );
  }

  /// Build a single rest-pause set row
  Widget _buildRestPauseSetRow(
    BuildContext context,
    int index,
    RestPauseSet set,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Set number
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: context.colors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SemanticIcon(
                icon: AppIcons.complete,
                semanticLabel: 'Completed',
                size: AppIconSize.tiny,
                color: context.colors.success,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Set info
          Expanded(
            child: Text(
              'Set ${index + 1}',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Reps
          Text(
            '${set.effectiveReps} reps',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          // RPE indicator (if set)
          if (set.rpe != null) ...[
            const SizedBox(width: 8),
            RpeIndicator(rpe: set.rpe!, showLabel: false, compact: true),
          ],
        ],
      ),
    );
  }

  /// Handle adding a new set to a completed rest-pause
  Future<void> _onAddRestPauseSet(
    BuildContext context,
    RestPauseExercise restPauseExercise,
  ) async {
    final sets = restPauseExercise.restPauseSets;
    if (sets.isEmpty) return;

    // Show the dedicated AddRestPauseSetModal
    final newSet = await AddRestPauseSetModal.show(
      context: context,
      exerciseName: restPauseExercise.name,
      weight: restPauseExercise.weight,
      targetReps: restPauseExercise.targetReps,
      completedSets: sets,
      setNumber: sets.length + 1,
    );

    if (newSet != null && mounted) {
      final updatedSets = [...sets, newSet];
      // Using copyWith() to preserve all fields (restAfterExercise, tut, advanced fields)
      final updatedExercise = restPauseExercise.copyWith(
        restPauseSets: updatedSets,
      );

      widget.onExerciseUpdate(updatedExercise);
      HapticFeedbackService.selection(ref);

      if (kDebugMode) {
        debugPrint(
          '✅ [RestPause] Added set ${sets.length + 1}: ${newSet.effectiveReps} reps',
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/exercise_merge/domain/entities/merge_candidate.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_gif_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_autocollapse_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/upgrade_matches_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_widget.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/exercise_card_settings_provider.dart';

/// Header component for ExerciseListItem
///
/// Displays:
/// - Exercise type icon (GIF for single exercises, icons for superset/dropset/restpause)
/// - Exercise name with inline insight chip (tappable for navigation to details)
/// - Badge row with configurable chips (Timer, Countdown, TUT, Quick Info, Warmup, Prevention)
/// - Popup menu with exercise actions
///
/// Extracted from exercise_list_item.dart for Single Responsibility Principle.
/// Part of the ExerciseListItem decomposition to reduce file size from ~5600 to ~1500 lines.
///
/// ✅ REDESIGN: Insight chip moved inline with name, Notes moved to footer
/// ✅ PERFORMANCE FIX: Changed from ConsumerWidget to StatelessWidget
/// The GIF provider watch is now isolated in _ExerciseGifIcon widget.
/// This prevents rebuild of the ENTIRE header (including insight chip)
/// when only the GIF loading state changes.
class ExerciseListItemHeader extends ConsumerWidget {
  const ExerciseListItemHeader({
    super.key,
    required this.exercise,
    required this.config,
    required this.isProMode,
    required this.autoCollapseState,
    required this.lastActivity,
    required this.onCancelAutoCollapse,
    required this.onShowAutoAdjustmentModal,
    required this.onShowQuickTimerSettings,
    required this.onShowTutExplanationModal,
    required this.onLoadExerciseData,
    required this.onShowExerciseInfoModal,
    required this.onShowWarmupModal,
    required this.onShowInjuryPreventionModal,
    required this.onShowExerciseHistory,
    required this.onShowExerciseEditor,
    required this.onShowExerciseReplacement,
    required this.onDuplicateExercise,
    required this.onShowDeleteConfirmation,
    required this.onShowCountingModePicker,
    required this.onAddWarmupSets,
    required this.onEditNotes,
    this.onCreateSuperset,
    this.onShowQuickUpgrade,
    this.hasWarmupData,
    this.hasInjuryPreventionData,
    this.tutorialMenuKey,
    this.formCues,
  });

  final Exercise exercise;
  final AppConfig config;
  final bool isProMode;
  final AutoCollapseState autoCollapseState;
  final ExerciseActivity? lastActivity;

  // Callbacks for actions
  final VoidCallback onCancelAutoCollapse;
  final VoidCallback onShowAutoAdjustmentModal;
  final VoidCallback onShowQuickTimerSettings;
  final VoidCallback onShowTutExplanationModal;
  final Future<Map<String, dynamic>?> Function() onLoadExerciseData;
  final void Function(Map<String, dynamic>) onShowExerciseInfoModal;
  final void Function(Map<String, dynamic>) onShowWarmupModal;
  final void Function(Map<String, dynamic>) onShowInjuryPreventionModal;
  final VoidCallback onShowExerciseHistory;
  final VoidCallback onShowExerciseEditor;
  final VoidCallback onShowExerciseReplacement;
  final VoidCallback onDuplicateExercise;
  final VoidCallback onShowDeleteConfirmation;
  final VoidCallback onShowCountingModePicker;
  final VoidCallback onAddWarmupSets;
  final VoidCallback onEditNotes;
  final VoidCallback? onCreateSuperset;

  /// Callback per mostrare modal upgrade esercizio
  final void Function(MergeCandidate candidate)? onShowQuickUpgrade;

  /// Form Cues (persistent technique reminders) for this exercise
  final String? formCues;

  // Optional validation functions
  final bool Function(Map<String, dynamic>)? hasWarmupData;
  final bool Function(Map<String, dynamic>)? hasInjuryPreventionData;

  /// Optional key for tutorial overlay on the popup menu (⋮)
  final GlobalKey? tutorialMenuKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ PERFORMANCE: Removed debug print that was causing log spam during scroll
    // The header no longer rebuilds when GIF provider changes state

    // Watch ExerciseCardSettings for insight visibility
    final showInsight = ref.watch(showExerciseInsightProvider);

    return Row(
      children: [
        // ✅ PERFORMANCE: GIF icon is now isolated in its own ConsumerWidget
        // This prevents rebuild of the entire header when GIF loads
        _ExerciseGifIcon(exercise: exercise),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise name row - includes inline insight chip and timer
              _buildExerciseNameRow(context, showInsight: showInsight),
              // ✅ REDESIGN: Badge row (Tips, TUT) REMOVED - now in ExerciseListItemFooter
              // Countdown badge for auto-collapse kept if needed
              if (autoCollapseState.countdown > 0 &&
                  (config.showCollapseCountdown ?? isProMode))
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _buildCountdownBadge(context),
                ),
            ],
          ),
        ),
        _buildPopupMenu(context),
      ],
    );
  }

  // NOTE: _buildExerciseTypeIcon was removed and replaced with _ExerciseGifIcon widget
  // This isolates the ref.watch for GIF provider, preventing header rebuilds

  Widget _buildExerciseNameRow(BuildContext context, {required bool showInsight}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // Exercise name - tappable for details
          Flexible(
            child: Semantics(
              label: exercise.name,
              hint: 'View exercise details',
              button: true,
              child: InkWell(
                onTap: () {
                  context.pushNamed(
                    'workout-exercise-detail',
                    pathParameters: {'exerciseName': Uri.encodeComponent(exercise.name)},
                    queryParameters: {
                      'id': exercise.id,
                    },
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Text(
                  exercise.name,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // Upgrade icon - isolated in ConsumerWidget for performance
          if (onShowQuickUpgrade != null)
            _UpgradeIconInline(
              exerciseName: exercise.name,
              onTap: onShowQuickUpgrade!,
            ),
          // ✅ REDESIGN: Inline insight chip (between name and timer)
          if (showInsight && lastActivity != null)
            _buildInlineInsightChip(context),
          // Spacer pushes timer to the right
          const Spacer(),
          // ✅ Timer badge positioned at top right
          if (config.showCustomTimers ?? isProMode)
            _buildCompactTimerBadge(context),
        ],
      ),
    );
  }

  /// ✅ REDESIGN: Compact inline insight chip for name row
  /// Shows "25kg×10" format without time info (too compact)
  Widget _buildInlineInsightChip(BuildContext context) {
    if (lastActivity == null || lastActivity!.sets.isEmpty) {
      return const SizedBox.shrink();
    }

    // Find max weight from last workout
    double maxWeight = 0;
    int maxReps = 0;

    for (final set in lastActivity!.sets) {
      if (set.done) {
        final weight = double.tryParse(set.weight.toString()) ?? 0;
        final reps = int.tryParse(set.reps.toString()) ?? 0;
        if (weight > maxWeight) {
          maxWeight = weight;
          maxReps = reps;
        }
      }
    }

    if (maxWeight == 0) return const SizedBox.shrink();

    // Compact weight format: remove decimal if .0
    final weightStr = maxWeight == maxWeight.truncate()
        ? maxWeight.truncate().toString()
        : maxWeight.toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Semantics(
        label: 'Last workout: ${weightStr}kg for $maxReps reps',
        hint: 'View exercise history',
        button: true,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onShowExerciseHistory();
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SemanticIcon(
                  icon: AppIcons.insights,
                  semanticLabel: 'Insights',
                  size: AppIconSize.tiny,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${weightStr}kg×$maxReps',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Compact timer badge for the name row (top right position)
  Widget _buildCompactTimerBadge(BuildContext context) {
    final restTimeStr = exercise.restTime != null
        ? _formatRestTime(exercise.restTime!)
        : 'Auto';
    final hasCustomTime = exercise.restTime != null;

    return Semantics(
      label: 'Rest timer: $restTimeStr',
      hint: 'Tap to edit timer settings',
      button: true,
      child: InkWell(
        onTap: onShowQuickTimerSettings,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: hasCustomTime
                ? context.colors.primaryContainer.withValues(alpha: 0.6)
                : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasCustomTime
                  ? context.colors.primary.withValues(alpha: 0.4)
                  : context.colors.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SemanticIcon(
                icon: AppIcons.timer,
                semanticLabel: 'Timer',
                size: AppIconSize.tiny,
                color: hasCustomTime
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                restTimeStr,
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: hasCustomTime
                      ? context.colors.primary
                      : context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NOTE: _buildBadgeRow, _buildTipsChip, _showTipsBottomSheet REMOVED
  // Tips and TUT are now in ExerciseListItemFooter

  // NOTE: _buildTimerBadge removed - timer is now in name row (_buildCompactTimerBadge)

  Widget _buildCountdownBadge(BuildContext context) {
    return Semantics(
      label: 'Auto-collapse countdown: ${autoCollapseState.countdown} seconds',
      hint: 'Tap to cancel',
      button: true,
      child: InkWell(
        onTap: onCancelAutoCollapse,
        borderRadius: BorderRadius.circular(8),
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.colors.tertiaryContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.colors.tertiary.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemanticIcon(
              icon: AppIcons.unfoldLess,
              semanticLabel: 'Collapse',
              size: AppIconSize.tiny,
              color: context.colors.tertiary,
            ),
            const SizedBox(width: 4),
            Text(
              '${autoCollapseState.countdown}',
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.tertiary,
              ),
            ),
            const SizedBox(width: 2),
            SemanticIcon(
              icon: AppIcons.close,
              semanticLabel: 'Close',
              size: AppIconSize.tiny,
              color: context.colors.tertiary.withValues(alpha: 0.7),
            ),
          ],
        ),
        ),
      ),
    );
  }

  // NOTE: _buildTutChip REMOVED - TUT is now in ExerciseListItemFooter
  // NOTE: _buildQuickActionIcon removed - consolidated into Tips bottom sheet
  // NOTE: _buildInsightChip and _buildNotesSection moved to ExerciseListItemFooter

  Widget _buildPopupMenu(BuildContext context) {
    final showAdvanced = config.showAdvancedMenu ?? isProMode;
    final showInsights = config.showExerciseInsights ?? isProMode;

    return PopupMenuButton<String>(
      key: tutorialMenuKey,
      onSelected: (value) {
        switch (value) {
          // NOTE: 'auto_adjustment' removed - now controlled via global settings
          case 'edit':
            onShowExerciseEditor();
            break;
          case 'change_exercise':
            onShowExerciseReplacement();
            break;
          case 'duplicate':
            onDuplicateExercise();
            break;
          case 'delete':
            onShowDeleteConfirmation();
            break;
          case 'insight':
            onShowExerciseHistory();
            break;
          case 'change_counting_mode':
            onShowCountingModePicker();
            break;
          case 'add_warmup_sets':
            onAddWarmupSets();
            break;
          case 'create_superset':
            onCreateSuperset?.call();
            break;
        }
      },
      itemBuilder: (context) {
        return [
          // NOTE: Auto Adjustment menu item removed - now controlled via global settings
          // (WorkoutCustomizationModal → "Suggerisci Peso" toggle)

          // Add/Edit Warmup Sets - always shown for single exercises
          // Shows "Edit" if warmup sets already exist, "Add" otherwise
          if (exercise.type == ExerciseType.single) ...[
            PopupMenuItem(
              value: 'add_warmup_sets',
              child: _WarmupSetsMenuItem(exercise: exercise),
            ),
          ],
          const PopupMenuDivider(),

          // Delete - always shown
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.delete,
                  semanticLabel: 'Delete',
                  size: AppIconSize.small,
                  color: context.errorColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Delete',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.errorColor,
                  ),
                ),
              ],
            ),
          ),

          // Advanced options - conditional
          if (showAdvanced) ...[
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const SemanticIcon(
                    icon: AppIcons.edit,
                    semanticLabel: 'Edit',
                    size: AppIconSize.small,
                  ),
                  const SizedBox(width: 8),
                  Text(context.l10n.edit),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'change_exercise',
              child: Row(
                children: [
                  const SemanticIcon(
                    icon: AppIcons.swapHoriz,
                    semanticLabel: 'Change exercise',
                    size: AppIconSize.small,
                  ),
                  const SizedBox(width: 8),
                  Text(context.l10n.exerciseChangeVariation),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  const SemanticIcon(
                    icon: AppIcons.copy,
                    semanticLabel: 'Duplicate',
                    size: AppIconSize.small,
                  ),
                  const SizedBox(width: 8),
                  Text(context.l10n.duplicate),
                ],
              ),
            ),
            // Create superset - only for single exercises
            if (exercise.type == ExerciseType.single &&
                onCreateSuperset != null)
              PopupMenuItem(
                value: 'create_superset',
                child: Row(
                  children: [
                    SemanticIcon(
                      icon: AppIcons.link,
                      semanticLabel: context.l10n.createSuperset,
                      size: AppIconSize.small,
                      color: context.colors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.createSuperset,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            // Change counting mode - always in advanced menu
            PopupMenuItem(
              value: 'change_counting_mode',
              child: Row(
                children: [
                  const SemanticIcon(
                    icon: AppIcons.swapHoriz,
                    semanticLabel: 'Change counting format',
                    size: AppIconSize.small,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.exerciseOptionsChangeCountingFormat,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      exercise.countingMode.name.toUpperCase(),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Insights - conditional
          if (showInsights) ...[
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'insight',
              child: Row(
                children: [
                  const SemanticIcon(
                    icon: AppIcons.insights,
                    semanticLabel: 'View insights',
                    size: AppIconSize.small,
                  ),
                  const SizedBox(width: 8),
                  Text(context.l10n.exerciseListInsight),
                ],
              ),
            ),
          ],
        ];
      },
    );
  }

  // Helper methods

  String _formatRestTime(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    }
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (remainingSeconds == 0) {
      return '${minutes}m';
    }
    return '${minutes}m ${remainingSeconds}s';
  }

  // NOTE: _getDefaultTut and _formatTutDisplay REMOVED - TUT now in footer
}

/// Private widget for warmup sets menu item
/// Shows different icon and label based on whether warmup sets exist
class _WarmupSetsMenuItem extends StatelessWidget {
  const _WarmupSetsMenuItem({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final hasExistingWarmup = exercise.sets.any((s) => s.isWarmup);

    return Row(
      children: [
        SemanticIcon(
          icon: hasExistingWarmup ? AppIcons.edit : AppIcons.streak,
          semanticLabel: hasExistingWarmup
              ? context.l10n.editWarmupSets
              : context.l10n.addWarmupSets,
          size: AppIconSize.small,
          color: context.colors.warning,
        ),
        const SizedBox(width: 8),
        Text(
          hasExistingWarmup
              ? context.l10n.editWarmupSets
              : context.l10n.addWarmupSets,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.warning,
          ),
        ),
      ],
    );
  }
}

/// ✅ PERFORMANCE FIX: Isolated GIF icon widget
///
/// This widget is a ConsumerWidget that watches the GIF provider.
/// By isolating the ref.watch here, we prevent rebuild of the entire
/// ExerciseListItemHeader when the GIF loads or changes state.
///
/// Before: GIF loading → entire header rebuild → insight chip flickers
/// After: GIF loading → only this widget rebuilds → no flicker
class _ExerciseGifIcon extends ConsumerWidget {
  const _ExerciseGifIcon({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colors;

    // For single type exercises, use animated GIF
    if (exercise.type == ExerciseType.single) {
      final gifUrlAsync = ref.watch(exerciseGifUrlProvider(exercise.name));

      return gifUrlAsync.when(
        // RepaintBoundary isolates GIF animation from parent repaints
        data: (gifUrl) => RepaintBoundary(
          child: ExerciseGifWidget(
            gifUrl: gifUrl,
            exerciseName: exercise.name,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            iconColor: colorScheme.primary,
          ),
        ),
        loading: () => Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: LoadingIndicator(size: 20, color: colorScheme.primary),
          ),
        ),
        error: (_, __) =>
            _buildStaticIcon(context, AppIcons.workout, colorScheme.primary),
      );
    }

    // For other exercise types, use traditional icons
    final (icon, color) = switch (exercise.type) {
      ExerciseType.superset => (AppIcons.repeat, colorScheme.secondary),
      ExerciseType.dropset => (AppIcons.trendDown, colorScheme.tertiary),
      ExerciseType.restPause => (AppIcons.pauseCircle, colorScheme.error),
      ExerciseType.single => (AppIcons.workout, colorScheme.primary),
    };

    return _buildStaticIcon(context, icon, color);
  }

  Widget _buildStaticIcon(BuildContext context, IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: SemanticIcon(
        icon: icon,
        semanticLabel: exercise.type.name,
        color: color,
        size: AppIconSize.small,
      ),
    );
  }
}

/// Icona upgrade inline isolata in ConsumerWidget
///
/// ✅ PERFORMANCE: Isolato per evitare rebuild dell'header
/// quando cambia lo stato del provider upgrade matches.
class _UpgradeIconInline extends ConsumerWidget {
  const _UpgradeIconInline({required this.exerciseName, required this.onTap});

  final String exerciseName;
  final void Function(MergeCandidate candidate) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidate = ref.watch(upgradeMatchForExerciseProvider(exerciseName));

    // Non mostrare se non c'è match
    if (candidate == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: context.l10n.upgradeExerciseTooltip,
        child: Semantics(
          label: context.l10n.upgradeExerciseTooltip,
          hint: 'Match score: ${(candidate.bestMatchScore * 100).toStringAsFixed(0)}%',
          button: true,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap(candidate);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.syncAlt,
                  size: 18,
                  color: context.colors.onPrimaryContainer,
                ),
                const SizedBox(width: 2),
                Text(
                  '${(candidate.bestMatchScore * 100).toStringAsFixed(0)}%',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}

// NOTE: _TipsBottomSheet class REMOVED - Tips now shown in ExerciseListItemFooter

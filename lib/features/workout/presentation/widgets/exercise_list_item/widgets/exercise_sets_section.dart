/// Exercise Sets Section Widget
///
/// Displays the sets list for an exercise including:
/// - Empty state for different exercise types (dropset, restPause, normal)
/// - Sets progress header
/// - List of set items with completion status
/// - Add set button with optional collapse button
/// - APRE metadata banner (after set 4 if enabled)
///
/// Part of ExerciseListItem refactoring (split per sezione).
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/apre_auto_regulation_service.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/calculation_metadata_display.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/exercise_counting_mode.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/rpe_indicator.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/progress_arrow_widget.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_history_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/set_progress_data.dart';

/// Sets section widget for ExerciseListItem
///
/// Displays:
/// - Empty state with action buttons (execute dropset/restPause, or add first set)
/// - Sets progress header (X/Y Sets)
/// - List of set items (dismissible, editable, completable)
/// - Add set button (with collapse button when all sets complete)
/// - APRE metadata banner (collapsible, appears after set 4)
class ExerciseSetsSection extends ConsumerWidget {
  const ExerciseSetsSection({
    super.key,
    required this.exercise,
    required this.config,
    required this.isExpanded,
    required this.areAllSetsCompleted,
    required this.countingMode,
    required this.onAddSet,
    required this.onDeleteSet,
    required this.onToggleComplete,
    required this.onEditSet,
    required this.onQuickEditSet,
    required this.onCollapse,
    this.onExecuteDropSet,
    this.onExecuteRestPause,
    this.showMetadataBanner = false,
    this.onToggleMetadataBanner,
  });

  final Exercise exercise;
  final AppConfig config;
  final bool isExpanded;
  final bool areAllSetsCompleted;
  final ExerciseCountingMode countingMode;
  final VoidCallback onAddSet;
  final void Function(ExerciseSet set, int index) onDeleteSet;
  final void Function(ExerciseSet set) onToggleComplete;
  final void Function(ExerciseSet set) onEditSet;
  final void Function(ExerciseSet set) onQuickEditSet;
  final VoidCallback onCollapse;
  final void Function(DropSetExercise exercise)? onExecuteDropSet;
  final void Function(RestPauseExercise exercise)? onExecuteRestPause;
  final bool showMetadataBanner;
  final VoidCallback? onToggleMetadataBanner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Empty state handling
    if (exercise.sets.isEmpty) {
      return _buildEmptyState(context);
    }

    // Main sets section
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSetsProgressHeader(context),
        const SizedBox(height: 8),
        ...exercise.sets.asMap().entries.expand(
          (entry) => [
            _buildSetItem(context, ref, entry.key, entry.value),
            // Inject metadata banner after Set 4 if APRE enabled
            if (entry.key == 3 &&
                exercise.useAPRE &&
                exercise.sets.length >= 4)
              _buildMetadataBanner(context),
          ],
        ),
        const SizedBox(height: 8),
        _buildAddSetButton(context),
      ],
    );
  }

  /// Builds empty state based on exercise type
  Widget _buildEmptyState(BuildContext context) {
    // For DropSet exercises, show execute button
    if (exercise.type == ExerciseType.dropset) {
      final dropsetExercise = exercise as DropSetExercise;
      return GestureDetector(
        onTap: () => onExecuteDropSet?.call(dropsetExercise),
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
                semanticLabel: context.l10n.next,
                size: AppIconSize.tiny,
                color: context.colors.tertiary,
              )
            ],
          ),
        ),
      );
    }

    // For RestPause exercises, show execute button
    if (exercise.type == ExerciseType.restPause) {
      final restPauseExercise = exercise as RestPauseExercise;
      return GestureDetector(
        onTap: () => onExecuteRestPause?.call(restPauseExercise),
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
                semanticLabel: context.l10n.next,
                size: AppIconSize.tiny,
                color: context.colors.primary,
              )
            ],
          ),
        ),
      );
    }

    // Default empty state for normal exercises
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
            context.l10n.addSet,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds sets progress header
  Widget _buildSetsProgressHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          context.l10n.exerciseListSetsProgress(
            exercise.sets.where((s) => s.isCompleted).length.toString(),
            exercise.sets.length.toString(),
          ),
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        if (exercise.sets.isNotEmpty)
          Text(
            context.l10n.weightTimesReps,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  /// Builds a single set item
  Widget _buildSetItem(
    BuildContext context,
    WidgetRef ref,
    int index,
    ExerciseSet set,
  ) {
    final isWarmup = set.isWarmup;

    // Get progress data for completed sets (not warmup sets)
    SetProgressData? progressData;
    if (set.isCompleted && !isWarmup) {
      final weight = set.weight ?? 0.0;
      final reps = set.reps ?? 0;

      if (weight > 0 && reps > 0) {
        final params = SetProgressParams(
          exerciseName: exercise.name,
          setNumber: set.setNumber,
          currentWeight: weight,
          currentReps: reps,
        );
        progressData = ref.watch(setProgressProvider(params)).valueOrNull;
      }
    }

    return Dismissible(
      key: Key('${exercise.id}_set_${set.id}'),
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
        return await _showDeleteConfirmation(context, set, index);
      },
      onDismissed: (direction) {
        onDeleteSet(set, index);
      },
      child: GestureDetector(
        onTap: () => onToggleComplete(set),
        onDoubleTap: () => onQuickEditSet(set),
        onLongPress: () => onEditSet(set),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isWarmup
                ? context.warningContainer
                : set.isCompleted
                    ? context.colors.tertiary.withValues(alpha: 0.1)
                    : context.colors.surfaceContainerHighest
                        .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: isWarmup
                ? Border.all(
                    color: context.warningColor.withValues(alpha: 0.3))
                : set.isCompleted
                    ? Border.all(
                        color: context.colors.tertiary.withValues(alpha: 0.3))
                    : null,
          ),
          child: Row(
            children: [
              _buildSetNumberIndicator(context, set, index, isWarmup),
              const SizedBox(width: 12),
              if (isWarmup) ...[
                _buildWarmupBadge(context),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Row(
                  children: [
                    ..._buildSetDetailsForMode(context, set),
                    if (set.isCompleted && set.rpe != null) ...[
                      const SizedBox(width: 8),
                      RpeIndicator(rpe: set.rpe!, compact: true),
                    ],
                    // Progress arrow for completed sets
                    if (progressData != null) ...[
                      const SizedBox(width: 6),
                      SetRowProgressIndicator(progressData: progressData),
                    ],
                    const Spacer(),
                    _buildQuickEditHint(context),
                  ],
                ),
              ),
              _buildCompletionCheckbox(context, set),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds set number indicator (circular badge)
  Widget _buildSetNumberIndicator(
    BuildContext context,
    ExerciseSet set,
    int index,
    bool isWarmup,
  ) {
    return Container(
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
                semanticLabel: context.l10n.warmupSets,
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
    );
  }

  /// Builds warmup badge
  Widget _buildWarmupBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
    );
  }

  /// Builds set details based on counting mode
  List<Widget> _buildSetDetailsForMode(BuildContext context, ExerciseSet set) {
    switch (countingMode) {
      case ExerciseCountingMode.weighted:
        // Weighted: Show weight × reps
        return [
          if (set.weight != null) ...[
            Text(
              set.weight!.formatWeight(config.measurementUnit),
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration:
                    set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(width: 4),
            Text('×', style: context.textTheme.bodySmall),
            const SizedBox(width: 4),
          ],
          if (set.reps != null)
            Text(
              set.actualReps != null && set.isCompleted
                  ? '${set.actualReps}/${set.reps} ${context.l10n.reps}'
                  : '${set.reps} ${context.l10n.reps}',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration:
                    set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
        ];

      case ExerciseCountingMode.reps:
        // Reps-only: Show reps only (bodyweight exercises)
        return [
          if (set.reps != null)
            Text(
              set.actualReps != null && set.isCompleted
                  ? '${set.actualReps}/${set.reps} ${context.l10n.reps}'
                  : '${set.reps} ${context.l10n.reps}',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration:
                    set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
        ];

      case ExerciseCountingMode.time:
        // Time-based: Show duration (isometric exercises)
        // Note: For TIME exercises, duration is stored in 'reps' field
        return [
          if (set.reps != null)
            Text(
              '${set.reps}s',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration:
                    set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          // Also show 'seconds' field if exists (for backward compatibility)
          if (set.seconds != null && set.reps == null)
            Text(
              '${set.seconds}s',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                decoration:
                    set.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
        ];
    }
  }

  /// Builds quick edit hint (emoji indicator)
  Widget _buildQuickEditHint(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.outline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '✏️',
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  /// Builds completion checkbox
  Widget _buildCompletionCheckbox(BuildContext context, ExerciseSet set) {
    return InkWell(
      onTap: () => onToggleComplete(set),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: set.isCompleted
              ? SemanticIcon(
                  icon: AppIcons.complete,
                  semanticLabel: context.l10n.setCompleted,
                  key: const ValueKey('completed'),
                  size: AppIconSize.small,
                  color: context.colors.tertiary,
                )
              : SemanticIcon(
                  icon: AppIcons.radioButtonUnchecked,
                  semanticLabel: context.l10n.pending,
                  key: const ValueKey('uncompleted'),
                  size: AppIconSize.small,
                  color: context.colors.outline,
                ),
        ),
      ),
    );
  }

  /// Builds add set button (with collapse button when all complete)
  Widget _buildAddSetButton(BuildContext context) {
    return AnimatedSwitcher(
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
      child: areAllSetsCompleted && isExpanded
          ? _buildAddSetWithCollapseButtons(context)
          : _buildAddSetButtonOnly(context),
    );
  }

  /// Builds add set button with collapse button (when all sets complete)
  Widget _buildAddSetWithCollapseButtons(BuildContext context) {
    return Row(
      key: const ValueKey('buttons_with_collapse'),
      children: [
        // Add Set button (left)
        Expanded(
          child: InkWell(
            onTap: onAddSet,
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
                onCollapse();
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
    );
  }

  /// Builds add set button only (default state)
  Widget _buildAddSetButtonOnly(BuildContext context) {
    return InkWell(
      key: const ValueKey('button_add_only'),
      onTap: onAddSet,
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
    );
  }

  /// Builds APRE metadata banner (collapsible)
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
            onTap: onToggleMetadataBanner,
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
                    icon: AppIcons.expandLess,
                    semanticLabel: context.l10n.collapse,
                    size: AppIconSize.small,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      showMetadataBanner
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
                    semanticLabel: context.l10n.exerciseInformation,
                    size: AppIconSize.small,
                    color: context.colors.primary,
                  )
                ],
              ),
            ),
          ),
          // Expanded metadata details
          if (showMetadataBanner) ...[
            const SizedBox(height: 8),
            CalculationMetadataDisplay(
              calculations: calculations,
              lastCalculationDate: exercise.lastCalculationDate,
            ),
          ],
        ],
      ),
    );
  }

  /// Parses calculation metadata from JSON string
  Map<String, dynamic>? _parseCalculationMetadata() {
    if (exercise.calculationMetadata == null) return null;

    try {
      final decoded = jsonDecode(exercise.calculationMetadata!);
      return {
        'confidence': _parseConfidence(decoded['confidence']),
        'dataPoints': decoded['dataPoints'] ?? 0,
        'formula': decoded['formula'] ?? 'Brzycki',
        'dataAge': Duration(days: decoded['dataAge']?['inDays'] ?? 0),
        'standardDeviation': decoded['standardDeviation']?.toDouble() ?? 0.0,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error parsing calculation metadata: $e');
      }
      return null;
    }
  }

  /// Parses confidence string to enum
  CalculationConfidence _parseConfidence(dynamic confidence) {
    if (confidence == null) return CalculationConfidence.unknown;
    if (confidence is CalculationConfidence) return confidence;

    final confStr = confidence.toString().toLowerCase();
    switch (confStr) {
      case 'veryhigh':
        return CalculationConfidence.veryHigh;
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

  /// Shows delete confirmation dialog
  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    ExerciseSet set,
    int index,
  ) async {
    final isWarmup = set.isWarmup;

    return await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.dismiss,
      barrierColor: context.colors.onSurface.withValues(alpha: 0.54),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container(); // Not used with transitionBuilder
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
                    ? context.l10n.deleteWarmupSetTitle
                    : context.l10n.deleteSetTitle(index + 1),
              ),
              content: Text(context.l10n.deleteSetMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(context.l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style:
                      TextButton.styleFrom(foregroundColor: context.errorColor),
                  child: Text(context.l10n.delete),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

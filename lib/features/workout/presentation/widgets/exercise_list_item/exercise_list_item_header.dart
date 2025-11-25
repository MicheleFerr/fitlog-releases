import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise_activity.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_gif_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/exercise_autocollapse_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/exercise_gif_widget.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Header component for ExerciseListItem
///
/// Displays:
/// - Exercise type icon (GIF for single exercises, icons for superset/dropset/restpause)
/// - Exercise name (tappable for navigation to details)
/// - Badge row with configurable chips (APRE, Timer, Countdown, TUT, Quick Info, Warmup, Prevention)
/// - Insight chip showing last workout performance
/// - Popup menu with exercise actions
///
/// Extracted from exercise_list_item.dart for Single Responsibility Principle.
/// Part of the ExerciseListItem decomposition to reduce file size from ~5600 to ~1500 lines.
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
    required this.onShowCommunityAdvice,
    this.hasWarmupData,
    this.hasInjuryPreventionData,
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
  final VoidCallback onShowCommunityAdvice;

  // Optional validation functions
  final bool Function(Map<String, dynamic>)? hasWarmupData;
  final bool Function(Map<String, dynamic>)? hasInjuryPreventionData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _buildExerciseTypeIcon(context, ref),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise name - tappable for details
              _buildExerciseNameRow(context),
              // Spacing between name and badges
              const SizedBox(height: 6),
              // Badge row (APRE, Timer, Countdown) - Horizontally scrollable
              _buildBadgeRow(context),
              // Insight chip - conditional on showExerciseInsights
              if (lastActivity != null &&
                  (config.showExerciseInsights ?? isProMode)) ...[
                const SizedBox(height: 4),
                _buildInsightChip(context),
              ],
            ],
          ),
        ),
        _buildPopupMenu(context),
      ],
    );
  }

  Widget _buildExerciseTypeIcon(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colors;

    // For single type exercises, use animated GIF
    if (exercise.type == ExerciseType.single) {
      final gifUrlAsync = ref.watch(
        exerciseGifUrlProvider(exercise.name),
      );

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
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          ),
        ),
        error: (_, __) => Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: SemanticIcon(
            icon: AppIcons.workout,
            semanticLabel: 'Workout',
            color: colorScheme.primary,
            size: AppIconSize.small,
          ),
        ),
      );
    }

    // For other exercise types, use traditional icons
    IconData icon;
    Color color;

    switch (exercise.type) {
      case ExerciseType.superset:
        icon = AppIcons.repeat;
        color = colorScheme.secondary;
        break;
      case ExerciseType.dropset:
        icon = AppIcons.trendDown;
        color = colorScheme.tertiary;
        break;
      case ExerciseType.restPause:
        icon = AppIcons.pauseCircle;
        color = colorScheme.error;
        break;
      case ExerciseType.single:
        icon = AppIcons.workout;
        color = colorScheme.primary;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: SemanticIcon(
        icon: icon,
        semanticLabel: 'Exercise type',
        color: color,
        size: AppIconSize.small,
      ),
    );
  }

  Widget _buildExerciseNameRow(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          'workout-exercise-detail',
          pathParameters: {
            'exerciseName': Uri.encodeComponent(exercise.name),
          },
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                exercise.name,
                style: context.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SemanticIcon(
              icon: AppIcons.info,
              semanticLabel: 'Information',
              size: AppIconSize.small,
              color: context.colors.primary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // APRE badge indicator (tappable)
          if (exercise.autoAdjustmentType == AutoAdjustmentType.apre &&
              (config.enableApre ?? false)) ...[
            _buildApreBadge(context),
            const SizedBox(width: 8),
          ],
          // Rest timer indicator (tappable) - conditional on showCustomTimers
          if (config.showCustomTimers ?? isProMode) ...[
            _buildTimerBadge(context),
            const SizedBox(width: 8),
          ],
          // Countdown visual for auto-collapse - conditional on showCollapseCountdown
          if (autoCollapseState.countdown > 0 &&
              (config.showCollapseCountdown ?? isProMode)) ...[
            _buildCountdownBadge(context),
            const SizedBox(width: 8),
          ],
          // TUT chip - conditional on showTutInfo
          if (config.showTutInfo ?? isProMode) ...[
            _buildTutChip(context),
            const SizedBox(width: 8),
          ],
          // Quick Info icon - conditional on showQuickInfoIcon
          if (config.showQuickInfoIcon ?? isProMode) ...[
            _buildQuickActionIcon(
              context: context,
              icon: AppIcons.info,
              color: context.infoColor,
              onTap: () async {
                final data = await onLoadExerciseData();
                if (data != null) {
                  onShowExerciseInfoModal(data);
                }
              },
            ),
            const SizedBox(width: 8),
          ],
          // Warmup icon - conditional on showWarmupIcon
          if (config.showWarmupIcon ?? isProMode) ...[
            _buildQuickActionIcon(
              context: context,
              icon: AppIcons.whatshot,
              color: context.warningColor,
              onTap: () async {
                final data = await onLoadExerciseData();
                if (data != null &&
                    (hasWarmupData?.call(data) ?? true)) {
                  onShowWarmupModal(data);
                }
              },
            ),
            const SizedBox(width: 8),
          ],
          // Prevention icon - conditional on showPreventionIcon
          if (config.showPreventionIcon ?? isProMode) ...[
            _buildQuickActionIcon(
              context: context,
              icon: AppIcons.shieldOutlined,
              color: context.successColor,
              onTap: () async {
                final data = await onLoadExerciseData();
                if (data != null &&
                    (hasInjuryPreventionData?.call(data) ?? true)) {
                  onShowInjuryPreventionModal(data);
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApreBadge(BuildContext context) {
    return InkWell(
      onTap: onShowAutoAdjustmentModal,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemanticIcon(
              icon: AppIcons.autoAwesome,
              semanticLabel: 'AI suggestion',
              size: AppIconSize.tiny,
              color: context.colors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'APRE ${exercise.apreProtocol ?? 6}',
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerBadge(BuildContext context) {
    return InkWell(
      onTap: onShowQuickTimerSettings,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: exercise.restTime != null
              ? context.colors.primaryContainer.withValues(alpha: 0.5)
              : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: exercise.restTime != null
                ? context.colors.primary.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemanticIcon(
              icon: AppIcons.timer,
              semanticLabel: 'Rest timer',
              size: AppIconSize.tiny,
              color: exercise.restTime != null
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              exercise.restTime != null
                  ? _formatRestTime(exercise.restTime!)
                  : 'Default',
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: exercise.restTime != null
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 2),
            SemanticIcon(
              icon: AppIcons.edit,
              semanticLabel: 'Edit',
              size: AppIconSize.tiny,
              color: exercise.restTime != null
                  ? context.colors.primary.withValues(alpha: 0.7)
                  : context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownBadge(BuildContext context) {
    return InkWell(
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
    );
  }

  Widget _buildTutChip(BuildContext context) {
    final tutText = exercise.tut ?? _getDefaultTut();
    final isDefault = exercise.tut == null;

    return GestureDetector(
      onTap: onShowTutExplanationModal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDefault
              ? context.colors.surfaceContainerHighest.withValues(alpha: 0.3)
              : context.colors.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDefault
                ? context.colors.outline.withValues(alpha: 0.3)
                : context.colors.primary.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemanticIcon(
              icon: AppIcons.speed,
              semanticLabel: 'Speed',
              size: AppIconSize.tiny,
              color: isDefault
                  ? context.colors.onSurfaceVariant
                  : context.colors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              _formatTutDisplay(tutText),
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDefault
                    ? context.colors.onSurfaceVariant
                    : context.colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionIcon({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        ),
        child: SemanticIcon(
          icon: icon,
          semanticLabel: 'Quick action',
          size: AppIconSize.tiny,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInsightChip(BuildContext context) {
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

    final daysAgo = DateTime.now().difference(lastActivity!.createdAt).inDays;
    final String timeAgo = daysAgo == 0
        ? 'Oggi'
        : daysAgo == 1
            ? 'Ieri'
            : '$daysAgo giorni fa';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onShowExerciseHistory();
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: context.colors.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0, end: 1),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: SemanticIcon(
                      icon: AppIcons.insights,
                      semanticLabel: 'Insights',
                      size: AppIconSize.tiny,
                      color: context.colors.primary,
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              Text(
                'Ultimo: ${maxWeight.toStringAsFixed(1)}kg x $maxReps ($timeAgo)',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              SemanticIcon(
                icon: AppIcons.chevronRight,
                semanticLabel: 'View history',
                size: AppIconSize.tiny,
                color: context.colors.primary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    final showAdvanced = config.showAdvancedMenu ?? isProMode;
    final showCommunity = config.showCommunitySuggestions ?? isProMode;
    final showInsights = config.showExerciseInsights ?? isProMode;

    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'auto_adjustment':
            onShowAutoAdjustmentModal();
            break;
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
          case 'community_advice':
            onShowCommunityAdvice();
            break;
        }
      },
      itemBuilder: (context) {
        return [
          // Auto Adjustment - always shown
          PopupMenuItem(
            value: 'auto_adjustment',
            child: Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.autoAwesome,
                  semanticLabel: 'AI suggestion',
                  size: AppIconSize.small,
                  color: exercise.autoAdjustmentType != null
                      ? context.colors.primary
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.autoAdjustment,
                  style: exercise.autoAdjustmentType != null
                      ? context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                        )
                      : null,
                ),
                if (exercise.autoAdjustmentType != null) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      exercise.autoAdjustmentType == AutoAdjustmentType.apre
                          ? 'APRE'
                          : 'RPE',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
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
                  style: context.textTheme.bodyMedium
                      ?.copyWith(color: context.errorColor),
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

          // Community advice - conditional
          if (showCommunity) ...[
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'community_advice',
              child: Row(
                children: [
                  const SemanticIcon(
                    icon: AppIcons.tip,
                    semanticLabel: 'Tips',
                    size: AppIconSize.small,
                  ),
                  const SizedBox(width: 8),
                  Text(context.l10n.communityAdvice),
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

  String _getDefaultTut() {
    // Default TUT based on exercise type
    switch (exercise.type) {
      case ExerciseType.single:
        return exercise.category == ExerciseCategory.legs ? '3-0-1-0' : '2-1-2-0';
      case ExerciseType.superset:
        return '2-0-1-0';
      case ExerciseType.dropset:
        return '2-1-2-0';
      case ExerciseType.restPause:
        return '2-1-2-1';
    }
  }

  String _formatTutDisplay(String tut) {
    if (tut == 'ISO') return 'ISO';
    if (tut == 'EXP') return 'ESP';
    return tut; // Show as-is for tempo like "3-1-2-0"
  }
}

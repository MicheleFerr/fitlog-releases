import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/suggestion_feedback.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/antagonist_conflict.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout_suggestion.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/workout_analytics.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_suggestion_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Smart workout CTA button with 4 states:
/// - REST_MODE: User already worked out today
/// - INSUFFICIENT_DATA: <3 workouts in history
/// - READY: Smart suggestion available
/// - WARNING: Suggestion with antagonist conflict warning
class SmartWorkoutCTA extends ConsumerWidget {
  const SmartWorkoutCTA({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionAsync = ref.watch(workoutSuggestionProvider);

    return suggestionAsync.when(
      loading: () => _buildLoadingState(context),
      error: (error, _) => _buildErrorState(context, error.toString()),
      data: (state) => state.when(
        loading: () => _buildLoadingState(context),
        restMode: (workout) => _buildRestModeState(context, ref, workout),
        insufficientData: (count, required) =>
            _buildInsufficientDataState(context, count, required),
        ready: (suggestion) => _buildReadyState(context, ref, suggestion),
        warning: (suggestion, conflict) =>
            _buildWarningState(context, ref, suggestion, conflict),
        error: (message, _) => _buildErrorState(context, message),
      ),
    );
  }

  // ========== LOADING STATE ==========
  Widget _buildLoadingState(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const LoadingIndicator(),
    );
  }

  // ========== ERROR STATE ==========
  Widget _buildErrorState(BuildContext context, String message) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.error,
                  size: AppIconSize.medium,
                  color: context.colors.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.smartWorkoutCTAErrorTitle,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== INSUFFICIENT DATA STATE ==========
  Widget _buildInsufficientDataState(
    BuildContext context,
    int workoutCount,
    int requiredCount,
  ) {
    final remaining = requiredCount - workoutCount;
    final progress = workoutCount / requiredCount;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + Title
            Row(
              children: [
                Icon(
                  AppIcons.barChart,
                  size: AppIconSize.large,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.smartWorkoutCTAInsufficientDataTitle,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Subtitle with remaining count
            Text(
              context.l10n.smartWorkoutCTAInsufficientDataSubtitle(remaining),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: context.colors.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation(context.colors.primary),
              ),
            ),

            const SizedBox(height: 8),

            // Progress text
            Text(
              context.l10n.smartWorkoutCTAInsufficientDataProgress(
                workoutCount,
                requiredCount,
              ),
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== READY STATE (Main CTA) ==========
  Widget _buildReadyState(
    BuildContext context,
    WidgetRef ref,
    WorkoutSuggestion suggestion,
  ) {
    return GestureDetector(
      onTap: () => _onSuggestionAccepted(context, ref, suggestion),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.primary,
              context.colors.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + Title
              Row(
                children: [
                  Icon(
                    AppIcons.workout,
                    size: AppIconSize.large,
                    color: context.colors.surface,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.smartWorkoutCTAReadyTitle,
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.colors.surface.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          suggestion.workoutName,
                          style: context.textTheme.titleLarge?.copyWith(
                            color: context.colors.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Confidence indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.surface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      suggestion.displayConfidence,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colors.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Reason
              Text(
                suggestion.reason,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.surface.withValues(alpha: 0.9),
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons row
              Row(
                children: [
                  // Start button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _onSuggestionAccepted(context, ref, suggestion),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.surface,
                        foregroundColor: context.colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(AppIcons.play, size: AppIconSize.small),
                      label: Text(context.l10n.smartWorkoutCTAStartButton),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Reject button
                  IconButton(
                    onPressed: () => _showReasonPicker(context, ref, suggestion),
                    style: IconButton.styleFrom(
                      backgroundColor: context.colors.surface.withValues(alpha: 0.2),
                    ),
                    icon: Icon(
                      AppIcons.close,
                      color: context.colors.surface,
                      size: AppIconSize.small,
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

  // ========== WARNING STATE (Antagonist Conflict) ==========
  Widget _buildWarningState(
    BuildContext context,
    WidgetRef ref,
    WorkoutSuggestion suggestion,
    AntagonistConflict conflict,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.colors.warning.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.warning,
                    size: AppIconSize.small,
                    color: context.colors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.smartWorkoutCTAWarningBanner(
                        conflict.pair.antagonistMuscleEN,
                      ),
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Suggestion info
            Row(
              children: [
                Icon(
                  AppIcons.workout,
                  size: AppIconSize.large,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.smartWorkoutCTAReadyTitle,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        suggestion.workoutName,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                // Proceed anyway button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _onSuggestionAccepted(context, ref, suggestion),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.warning,
                      side: BorderSide(color: context.colors.warning),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(AppIcons.play, size: AppIconSize.small),
                    label: Text(context.l10n.smartWorkoutCTAProceedAnyway),
                  ),
                ),

                const SizedBox(width: 12),

                // Alternative suggestion button (if available)
                if (conflict.suggestedAlternative != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to alternative template
                        HapticFeedback.mediumImpact();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: context.colors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(AppIcons.swapHoriz, size: AppIconSize.small),
                      label: Text(
                        conflict.suggestedAlternative!,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========== REST MODE STATE ==========
  Widget _buildRestModeState(BuildContext context, WidgetRef ref, Workout workout) {
    final stats = _calculateWorkoutStats(workout);

    // Track analytics - use select() to only rebuild when uid changes
    final userId = ref.watch(
      firebaseUserProvider.select((async) => async.valueOrNull?.uid),
    );
    if (userId != null) {
      WorkoutAnalytics.trackEvent(
        'rest_mode_shown',
        properties: {
          'workoutId': workout.id,
          'workoutName': workout.name,
          'volumeKg': stats.volume,
          'duration': stats.duration,
          'sets': stats.sets,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.primary,
            context.colors.tertiary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.achievement,
                  size: AppIconSize.large,
                  color: context.colors.surface,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.smartWorkoutCTARestModeTitle,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.colors.surface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.smartWorkoutCTARestModeSubtitle,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.surface.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                    context,
                    AppIcons.weight,
                    context.l10n.smartWorkoutCTARestModeVolume(stats.volume),
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    context,
                    AppIcons.timer,
                    context.l10n.smartWorkoutCTARestModeDuration(stats.duration),
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    context,
                    AppIcons.checkCircle,
                    context.l10n.smartWorkoutCTARestModeSets(stats.sets),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== HELPERS ==========

  Widget _buildStatRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppIconSize.small,
          color: context.colors.surface.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.surface.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }

  WorkoutStats _calculateWorkoutStats(Workout workout) {
    double totalVolume = 0;
    int totalSets = 0;

    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        final weight = set.weight ?? 0;
        final reps = set.reps ?? 0;
        totalVolume += weight * reps;
        totalSets++;
      }
    }

    final duration = workout.endTime != null
        ? workout.endTime!.difference(workout.startTime ?? DateTime.now())
        : Duration.zero;

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return WorkoutStats(
      volume: NumberFormat('#,##0', 'it_IT').format(totalVolume.round()),
      duration: '${minutes}m ${seconds}s',
      sets: totalSets.toString(),
    );
  }

  // ========== ACTIONS ==========

  void _onSuggestionAccepted(
    BuildContext context,
    WidgetRef ref,
    WorkoutSuggestion suggestion,
  ) {
    HapticFeedback.mediumImpact();

    // Record acceptance
    ref.read(suggestionFeedbackNotifierProvider.notifier).recordAcceptance(
      templateSuggested: suggestion.workoutName,
      confidenceAtSuggestion: suggestion.confidence,
    );

    // Navigate to workout with template
    context.push('/workout?template=${Uri.encodeComponent(suggestion.workoutName)}');
  }

  void _showReasonPicker(
    BuildContext context,
    WidgetRef ref,
    WorkoutSuggestion suggestion,
  ) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReasonPickerSheet(
        suggestion: suggestion,
        onReasonSelected: (reason, customReason) {
          ref.read(suggestionFeedbackNotifierProvider.notifier).recordRejection(
            templateSuggested: suggestion.workoutName,
            reason: reason,
            customReason: customReason,
            confidenceAtSuggestion: suggestion.confidence,
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}

String generateSessionId() => const Uuid().v4();

/// Statistics calculated from completed workout
class WorkoutStats {
  const WorkoutStats({
    required this.volume,
    required this.duration,
    required this.sets,
  });

  final String volume;
  final String duration;
  final String sets;
}

/// Bottom sheet for selecting rejection reason
class ReasonPickerSheet extends StatefulWidget {
  const ReasonPickerSheet({
    super.key,
    required this.suggestion,
    required this.onReasonSelected,
  });

  final WorkoutSuggestion suggestion;
  final void Function(RejectionReason reason, String? customReason) onReasonSelected;

  @override
  State<ReasonPickerSheet> createState() => _ReasonPickerSheetState();
}

class _ReasonPickerSheetState extends State<ReasonPickerSheet> {
  RejectionReason? _selectedReason;
  final _customReasonController = TextEditingController();

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                context.l10n.smartWorkoutCTAReasonPickerTitle,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                context.l10n.smartWorkoutCTAReasonPickerSubtitle(
                  widget.suggestion.workoutName,
                ),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 20),

              // Reason options
              ...RejectionReason.values.map((reason) => _buildReasonTile(reason)),

              // Custom reason input (if "other" selected)
              if (_selectedReason == RejectionReason.other) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _customReasonController,
                  decoration: InputDecoration(
                    hintText: context.l10n.smartWorkoutCTAReasonPickerCustomHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                ),
              ],

              const SizedBox(height: 20),

              // Confirm button
              ElevatedButton(
                onPressed: _selectedReason != null
                    ? () {
                        widget.onReasonSelected(
                          _selectedReason!,
                          _selectedReason == RejectionReason.other
                              ? _customReasonController.text
                              : null,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(context.l10n.smartWorkoutCTAReasonPickerConfirm),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonTile(RejectionReason reason) {
    final isSelected = _selectedReason == reason;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedReason = reason);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.primaryContainer
                : context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: context.colors.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                _getReasonIcon(reason),
                color: isSelected
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getReasonLabel(context, reason),
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: isSelected
                        ? context.colors.onPrimaryContainer
                        : context.colors.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  AppIcons.checkCircle,
                  color: context.colors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getReasonIcon(RejectionReason reason) {
    return switch (reason) {
      RejectionReason.tooTired => AppIcons.batteryAlert,
      RejectionReason.noTime => AppIcons.clock,
      RejectionReason.injury => AppIcons.healing,
      RejectionReason.notInMood => AppIcons.bedtime,
      RejectionReason.other => AppIcons.moreHoriz,
    };
  }

  String _getReasonLabel(BuildContext context, RejectionReason reason) {
    return switch (reason) {
      RejectionReason.tooTired => context.l10n.smartWorkoutCTAReasonTooTired,
      RejectionReason.noTime => context.l10n.smartWorkoutCTAReasonNoTime,
      RejectionReason.injury => context.l10n.smartWorkoutCTAReasonInjury,
      RejectionReason.notInMood => context.l10n.smartWorkoutCTAReasonNotInMood,
      RejectionReason.other => context.l10n.smartWorkoutCTAReasonOther,
    };
  }
}

/// Athlete Card Widget
///
/// Displays athlete information in a card format for coaches.
/// Shows avatar, name, workout status, and progress.
///
/// **Layer**: Presentation
/// **Feature**: Coach
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/coach/domain/entities/coach_relationship.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_spacing.dart';

/// Status of athlete's current workout session
enum AthleteWorkoutStatus {
  /// Currently doing a workout
  inProgress,

  /// Has a workout scheduled for today, not started
  scheduled,

  /// Rest day, no workout scheduled
  restDay,

  /// Warning: inactive for multiple days
  inactive,
}

/// Athlete card for coach's athlete list
///
/// Design specs (from wireframes):
/// - Card: surfaceContainerLow, borderRadius: 16
/// - Avatar: 48dp circle with initials or photo
/// - Status indicator: 12dp circle (success/warning/outline)
/// - Progress bar: LinearProgressIndicator, height: 4
/// - Touch target: entire card tappable
class AthleteCard extends StatelessWidget {
  const AthleteCard({
    required this.relationship,
    required this.onTap,
    this.workoutStatus = AthleteWorkoutStatus.restDay,
    this.workoutName,
    this.progressPercent,
    this.currentSet,
    this.totalSets,
    this.lastWorkoutDaysAgo,
    this.nextWorkoutDay,
    super.key,
  });

  /// The coach-athlete relationship data
  final CoachRelationship relationship;

  /// Called when card is tapped
  final VoidCallback onTap;

  /// Current workout status
  final AthleteWorkoutStatus workoutStatus;

  /// Name of current or scheduled workout (e.g., "Push Day")
  final String? workoutName;

  /// Progress percentage for in-progress workout (0-100)
  final int? progressPercent;

  /// Current set number (for in-progress workout)
  final int? currentSet;

  /// Total sets (for in-progress workout)
  final int? totalSets;

  /// Days since last workout (for inactive warning)
  final int? lastWorkoutDaysAgo;

  /// Next scheduled workout day (for rest day)
  final String? nextWorkoutDay;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Avatar with status indicator
              _buildAvatar(context),
              const SizedBox(width: AppSpacing.sm),

              // Name and status info
              Expanded(child: _buildContent(context)),

              // Navigation arrow
              Icon(
                AppIcons.chevronRight,
                color: context.colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final initials = _getInitials(relationship.athleteName ?? 'A');
    final statusColor = _getStatusColor(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Avatar circle
        CircleAvatar(
          radius: 24,
          backgroundColor: context.colors.primaryContainer,
          child: Text(
            initials,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colors.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Status indicator
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name
        Text(
          relationship.athleteName ?? context.l10n.athlete,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xxs),

        // Status line
        _buildStatusLine(context),

        // Progress bar (if in progress)
        if (workoutStatus == AthleteWorkoutStatus.inProgress &&
            progressPercent != null) ...[
          const SizedBox(height: AppSpacing.xs),
          _buildProgressBar(context),
        ],
      ],
    );
  }

  Widget _buildStatusLine(BuildContext context) {
    switch (workoutStatus) {
      case AthleteWorkoutStatus.inProgress:
        final setInfo = (currentSet != null && totalSets != null)
            ? ' • Set $currentSet/$totalSets'
            : '';
        return Text(
          '${workoutName ?? "Workout"}$setInfo',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );

      case AthleteWorkoutStatus.scheduled:
        return Row(
          children: [
            Text(
              '${workoutName ?? "Workout"} • ${context.l10n.notStarted}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (lastWorkoutDaysAgo != null && lastWorkoutDaysAgo! >= 3) ...[
              const SizedBox(width: AppSpacing.xs),
              _buildWarningBadge(context),
            ],
          ],
        );

      case AthleteWorkoutStatus.inactive:
        return Row(
          children: [
            Flexible(
              child: Text(
                workoutName ?? 'Rest Day',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            _buildWarningBadge(context),
          ],
        );

      case AthleteWorkoutStatus.restDay:
        final nextInfo = nextWorkoutDay != null
            ? '${context.l10n.next}: ${workoutName ?? "Workout"} ($nextWorkoutDay)'
            : context.l10n.restDay;
        return Text(
          nextInfo,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
    }
  }

  Widget _buildWarningBadge(BuildContext context) {
    final days = lastWorkoutDaysAgo ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: context.colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        context.l10n.daysAgo(days),
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.error,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: (progressPercent ?? 0) / 100,
            minHeight: 4,
            backgroundColor: context.colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(context.colors.primary),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$progressPercent%',
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(BuildContext context) {
    switch (workoutStatus) {
      case AthleteWorkoutStatus.inProgress:
        return context.colors.primary; // Green/Primary - actively training
      case AthleteWorkoutStatus.scheduled:
        if (lastWorkoutDaysAgo != null && lastWorkoutDaysAgo! >= 3) {
          return context.colors.error; // Red - inactive warning
        }
        return context.colors.tertiary; // Yellow/Tertiary - scheduled
      case AthleteWorkoutStatus.inactive:
        return context.colors.error; // Red - inactive
      case AthleteWorkoutStatus.restDay:
        return context.colors.outline; // Gray - rest day
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'A';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

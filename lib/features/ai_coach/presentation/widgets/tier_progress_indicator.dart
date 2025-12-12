/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: ai_coach
/// 🔧 Type: widget
///
/// Tier Progress Indicator - Visual progress toward tier unlock
///
/// **Displays**:
/// - Current tier status (locked/unlocked)
/// - Workouts completed / required
/// - Days of data / required
/// - Visual progress bars
/// - Unlock requirements
///
/// **Design**:
/// - Card-based UI with tier icon
/// - Dual progress bars (workouts + days)
/// - Color-coded by unlock status
/// - Responsive to theme (dark/light)
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/recovery_tier.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Widget to display tier unlock progress
///
/// **Usage**:
/// ```dart
/// TierProgressIndicator(
///   status: RecoveryTierStatus(
///     tier: RecoveryTier.basic,
///     isUnlocked: false,
///     currentWorkouts: 4,
///     currentDays: 10,
///     config: RecoveryTierConfig.basic,
///   ),
/// )
/// ```
class TierProgressIndicator extends StatelessWidget {
  const TierProgressIndicator({
    required this.status,
    this.onTap,
    super.key,
  });

  /// Tier status to display
  final RecoveryTierStatus status;

  /// Optional callback when tapped (e.g., show details)
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              if (!status.isUnlocked) ...[
                _buildWorkoutsProgress(context),
                const SizedBox(height: 12),
                _buildDaysProgress(context),
                const SizedBox(height: 12),
                _buildProgressDescription(context),
              ] else
                _buildUnlockedStatus(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header with tier icon and name
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Tier icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: status.isUnlocked
                ? context.colors.primary.withValues(alpha: 0.1)
                : context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTierIcon(),
            color: status.isUnlocked
                ? context.colors.primary
                : context.colors.onSurfaceVariant,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        // Tier name and description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    status.tier.displayName,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (status.isUnlocked)
                    Icon(
                      AppIcons.checkCircle,
                      color: context.colors.primary,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                status.tier.description,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build workouts progress bar
  Widget _buildWorkoutsProgress(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Workouts',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colors.onSurface,
              ),
            ),
            Text(
              '${status.currentWorkouts} / ${status.config.minWorkouts}',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: status.workoutsProgress,
          backgroundColor: context.colors.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(
            _getProgressColor(context, status.workoutsProgress),
          ),
          borderRadius: BorderRadius.circular(8),
          minHeight: 8,
        ),
      ],
    );
  }

  /// Build days progress bar
  Widget _buildDaysProgress(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Days of Data',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colors.onSurface,
              ),
            ),
            Text(
              '${status.currentDays} / ${status.config.minDays}',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: status.daysProgress,
          backgroundColor: context.colors.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(
            _getProgressColor(context, status.daysProgress),
          ),
          borderRadius: BorderRadius.circular(8),
          minHeight: 8,
        ),
      ],
    );
  }

  /// Build progress description text
  Widget _buildProgressDescription(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.info,
            color: context.colors.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              status.progressDescription,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build unlocked status indicator
  Widget _buildUnlockedStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.checkCircle,
            color: context.colors.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlocked!',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.unlockedAt != null
                      ? 'Unlocked ${_formatDate(status.unlockedAt!)}'
                      : 'This tier is now available',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get tier-specific icon
  IconData _getTierIcon() {
    switch (status.tier) {
      case RecoveryTier.basic:
        return AppIcons.workout;
      case RecoveryTier.intermediate:
        return AppIcons.insights;
      case RecoveryTier.advanced:
        return AppIcons.ai;
    }
  }

  /// Get progress color based on completion percentage
  Color _getProgressColor(BuildContext context, double progress) {
    if (progress >= 1.0) {
      return context.colors.primary; // Complete
    } else if (progress >= 0.66) {
      return context.colors.primary.withValues(alpha: 0.8); // High progress
    } else if (progress >= 0.33) {
      return context.colors.primary.withValues(alpha: 0.6); // Medium progress
    } else {
      return context.colors.primary.withValues(alpha: 0.4); // Low progress
    }
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }
}

/// Widget to display all three tiers in a list
///
/// **Usage**:
/// ```dart
/// TierProgressList(
///   tierStatuses: [basicStatus, intermediateStatus, advancedStatus],
///   onTierTap: (tier) => _showTierDetails(tier),
/// )
/// ```
class TierProgressList extends StatelessWidget {
  const TierProgressList({
    required this.tierStatuses,
    this.onTierTap,
    super.key,
  });

  /// List of tier statuses (Basic, Intermediate, Advanced)
  final List<RecoveryTierStatus> tierStatuses;

  /// Callback when tier is tapped
  final void Function(RecoveryTier tier)? onTierTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tierStatuses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final status = tierStatuses[index];
        return TierProgressIndicator(
          status: status,
          onTap: onTierTap != null ? () => onTierTap!(status.tier) : null,
        );
      },
    );
  }
}

/// Compact tier progress indicator for dashboard
///
/// **Usage**:
/// ```dart
/// CompactTierProgress(
///   status: basicTierStatus,
///   onTap: () => _navigateToTierDetails(),
/// )
/// ```
class CompactTierProgress extends StatelessWidget {
  const CompactTierProgress({
    required this.status,
    this.onTap,
    super.key,
  });

  final RecoveryTierStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Tier icon (small)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: status.isUnlocked
                    ? context.colors.primary.withValues(alpha: 0.1)
                    : context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getTierIcon(),
                color: status.isUnlocked
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Tier info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.tier.displayName,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (status.isUnlocked)
                    Text(
                      'Unlocked',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      status.progressDescription,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Progress indicator (circular)
            if (!status.isUnlocked)
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: status.overallProgress,
                  backgroundColor: context.colors.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(context.colors.primary),
                  strokeWidth: 4,
                ),
              )
            else
              Icon(
                AppIcons.checkCircle,
                color: context.colors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getTierIcon() {
    switch (status.tier) {
      case RecoveryTier.basic:
        return AppIcons.workout;
      case RecoveryTier.intermediate:
        return AppIcons.insights;
      case RecoveryTier.advanced:
        return AppIcons.ai;
    }
  }
}

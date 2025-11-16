/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/ai_coach/presentation/widgets
/// 🎯 Feature: ai_coach
/// 🔧 Type: widget
///
/// Streak Badge Widget - Visual indicator for workout streaks
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/ai_coach/domain/entities/streak_data.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/providers/streak_tracker_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Streak Badge Widget
///
/// Displays workout consistency streak with:
/// - Current streak count
/// - Status indicator (active/at-risk/broken)
/// - Progress to next milestone
/// - Motivational message
/// - Personal record indicator
///
/// Usage:
/// ```dart
/// StreakBadge.compact() // Small badge for cards
/// StreakBadge.expanded() // Full badge with details
/// ```
class StreakBadge extends ConsumerWidget {
  const StreakBadge({
    this.isCompact = false,
    this.showProgress = true,
    super.key,
  });

  /// Factory: Compact badge for cards
  factory StreakBadge.compact() {
    return const StreakBadge(isCompact: true, showProgress: false);
  }

  /// Factory: Expanded badge with full details
  factory StreakBadge.expanded() {
    return const StreakBadge(isCompact: false, showProgress: true);
  }

  /// Whether to show compact version (no details)
  final bool isCompact;

  /// Whether to show progress indicator
  final bool showProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakTrackerProvider);

    return streakAsync.when(
      data: (streakData) => isCompact
          ? _buildCompactBadge(context, streakData)
          : _buildExpandedBadge(context, ref, streakData),
      loading: () => _buildLoadingSkeleton(context),
      error: (error, stack) => _buildErrorBadge(context),
    );
  }

  /// Build compact badge (for cards)
  Widget _buildCompactBadge(BuildContext context, StreakData streakData) {
    final statusColor = _getStatusColor(context, streakData.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SemanticIcon(
            icon: _getStatusIcon(streakData.status),
            semanticLabel: context.l10n.streak,
            size: AppIconSize.small,
            color: statusColor,
          ),
          const SizedBox(width: 6),
          Text(
            '${streakData.currentStreak}',
            style: context.textTheme.titleSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (streakData.isPersonalRecord) ...[
            const SizedBox(width: 4),
            SemanticIcon(
              icon: AppIcons.stars,
              semanticLabel: context.l10n.personalRecord,
              size: AppIconSize.small,
              color: context.colors.tertiary,
            ),
          ],
        ],
      ),
    );
  }

  /// Build expanded badge (with details)
  Widget _buildExpandedBadge(
    BuildContext context,
    WidgetRef ref,
    StreakData streakData,
  ) {
    final statusColor = _getStatusColor(context, streakData.status);
    final notifier = ref.read(streakTrackerProvider.notifier);
    final progress = notifier.getProgressToNextMilestone();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon + Streak count
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: SemanticIcon(
                      icon: _getStatusIcon(streakData.status),
                      semanticLabel: context.l10n.streak,
                      size: AppIconSize.large,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${streakData.currentStreak}',
                            style: context.textTheme.headlineMedium?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.days,
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                          if (streakData.isPersonalRecord) ...[
                            const SizedBox(width: 8),
                            SemanticIcon(
                              icon: AppIcons.stars,
                              semanticLabel: context.l10n.personalRecord,
                              size: AppIconSize.medium,
                              color: context.colors.tertiary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusText(context, streakData),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Progress to next milestone
            if (showProgress && streakData.nextMilestone != null) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.nextMilestone,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${streakData.daysToNextMilestone} ${context.l10n.daysRemaining}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor:
                          context.colors.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ],
              ),
            ],

            // Longest streak
            if (streakData.longestStreak > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.stars,
                    semanticLabel: context.l10n.longestStreak,
                    size: AppIconSize.small,
                    color: context.colors.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${context.l10n.longestStreak}: ${streakData.longestStreak} ${context.l10n.days}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build loading skeleton
  Widget _buildLoadingSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.refresh,
            size: AppIconSize.small,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            '...',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error badge
  Widget _buildErrorBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.error,
            size: AppIconSize.small,
            color: context.colors.error,
          ),
          const SizedBox(width: 6),
          Text(
            '0',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colors.error,
            ),
          ),
        ],
      ),
    );
  }

  /// Get status icon
  IconData _getStatusIcon(StreakStatus status) {
    switch (status) {
      case StreakStatus.none:
        return AppIcons.help;
      case StreakStatus.active:
        return AppIcons.checkCircle;
      case StreakStatus.atRisk:
        return AppIcons.warning;
      case StreakStatus.broken:
        return AppIcons.cancel;
    }
  }

  /// Get status color
  Color _getStatusColor(BuildContext context, StreakStatus status) {
    switch (status) {
      case StreakStatus.none:
        return context.colors.onSurfaceVariant;
      case StreakStatus.active:
        return context.iconSuccess;
      case StreakStatus.atRisk:
        return context.iconWarning;
      case StreakStatus.broken:
        return context.iconError;
    }
  }

  /// Get status text
  String _getStatusText(BuildContext context, StreakData streakData) {
    switch (streakData.status) {
      case StreakStatus.none:
        return context.l10n.streakMessageNone;
      case StreakStatus.active:
        if (streakData.isPersonalRecord) {
          return context.l10n.streakMessagePersonalRecord;
        }
        return context.l10n.streakMessageActive;
      case StreakStatus.atRisk:
        return context.l10n.streakMessageAtRisk;
      case StreakStatus.broken:
        return context.l10n.streakMessageBroken;
    }
  }
}

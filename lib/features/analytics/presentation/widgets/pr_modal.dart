/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets
/// 🎯 Feature: analytics_pr
/// 🔧 Type: widget
/// 🌍 Localization: ✅ ENFORCED (context.l10n.*)
/// 🎨 Theme: ✅ ENFORCED (context.colors.*)
/// 📱 Platform: Universal
///
/// PR MODAL - Personal Record tracking with achievement list
///
/// This modal provides:
/// - Recent PRs count (last 7 days)
/// - PR explanation (what is a personal record)
/// - Complete list of all PRs with dates
/// - Recent achievement badges (highlighted)
/// - Reset option with confirmation dialog
///
/// Example:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (_) => PRModal(
///     exerciseHistories: histories,
///     recentPRCount: 3,
///   ),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:intl/intl.dart';

/// Personal Record data for display
class _PRInfo {
  const _PRInfo({
    required this.exerciseName,
    required this.personalRecord,
    required this.achievedDate,
    required this.isRecent,
  });

  final String exerciseName;
  final double personalRecord;
  final DateTime achievedDate;
  final bool isRecent; // Achieved in last 7 days

  String formatWeight() {
    return '${personalRecord.toStringAsFixed(1)} kg';
  }

  String formatDate(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(achievedDate).inDays;

    if (difference == 0) return context.l10n.prToday;
    if (difference == 1) return context.l10n.prYesterday;
    if (difference < 7) return context.l10n.prDaysAgo(difference);
    return DateFormat('MMM d, yyyy').format(achievedDate);
  }
}

/// Modal for displaying personal records with achievement list
class PRModal extends StatelessWidget {
  const PRModal({
    required this.exerciseHistories,
    required this.recentPRCount,
    super.key,
  });

  final List<ExerciseHistory> exerciseHistories;
  final int recentPRCount;

  /// Get all PRs with details
  List<_PRInfo> _getAllPRs() {
    final prInfoList = <_PRInfo>[];
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    for (final history in exerciseHistories) {
      if (history.sessions.isEmpty) continue;

      final pr = history.personalRecord;
      if (pr == 0) continue;

      // Find the session where PR was achieved
      DateTime? prDate;
      for (final session in history.sessions) {
        if (session.highestEstimated1RM >= pr * 0.99) {
          // Within 1% of PR
          if (prDate == null || session.date.isAfter(prDate)) {
            prDate = session.date;
          }
        }
      }

      if (prDate == null) continue;

      // Check if PR is recent (last 7 days)
      final isRecent = prDate.isAfter(weekAgo);

      prInfoList.add(_PRInfo(
        exerciseName: history.exerciseName,
        personalRecord: pr,
        achievedDate: prDate,
        isRecent: isRecent,
      ));
    }

    // Sort by date (most recent first)
    prInfoList.sort((a, b) => b.achievedDate.compareTo(a.achievedDate));

    return prInfoList;
  }

  /// Show reset confirmation dialog
  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: SemanticIcon(
          icon: AppIcons.warning,
          semanticLabel: context.l10n.warning,
          size: AppIconSize.large,
          color: context.colors.error,
        ),
        title: Text(context.l10n.resetAllPRsQuestion),
        content: Text(
          context.l10n.resetAllPRsMessage,
          style: context.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implement PR reset functionality
              HapticFeedback.mediumImpact();
              Navigator.pop(dialogContext);
              Navigator.pop(context); // Close modal
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.prResetComingSoon),
                  backgroundColor: context.colors.warning,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.onError,
            ),
            child: Text(context.l10n.resetAll),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPRs = _getAllPRs();
    final totalPRs = allPRs.length;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: 20),

              // Recent PRs card
              _buildRecentPRsCard(context),
              const SizedBox(height: 24),

              // Explanation
              _buildExplanation(context),
              const SizedBox(height: 24),

              // PR list
              _buildPRList(context, allPRs),
              const SizedBox(height: 24),

              // Reset button
              _buildResetButton(context, totalPRs),
              const SizedBox(height: 24),

              // Close button
              _buildCloseButton(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Header with title and close button
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '🏆 ${context.l10n.prDetails}',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SemanticIcon(
            icon: AppIcons.close,
            semanticLabel: context.l10n.close,
            size: AppIconSize.medium,
          ),
        ),
      ],
    );
  }

  /// Recent PRs card (prominent)
  Widget _buildRecentPRsCard(BuildContext context) {
    final hasRecentPRs = recentPRCount > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasRecentPRs
              ? [
                  context.colors.successContainer,
                  context.colors.primaryContainer,
                ]
              : [
                  context.colors.surfaceContainerHighest,
                  context.colors.surfaceContainer,
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Trophy icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasRecentPRs
                  ? context.colors.success.withValues(alpha: 0.2)
                  : context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SemanticIcon(
              icon: AppIcons.achievement,
              semanticLabel: context.l10n.personalRecords,
              size: AppIconSize.large,
              color: hasRecentPRs
                  ? context.colors.success
                  : context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),

          // Label + Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.recentPRsLastSevenDays,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: hasRecentPRs
                        ? context.colors.onSuccessContainer
                        : context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.prAchievements(recentPRCount),
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hasRecentPRs
                        ? context.colors.onSuccessContainer
                        : context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Badge
          if (hasRecentPRs)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.colors.success,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticIcon(
                    icon: AppIcons.trendUp,
                    semanticLabel: context.l10n.newBadge,
                    size: AppIconSize.tiny,
                    color: context.colors.onSuccess,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.newBadge,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSuccess,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Explanation section
  Widget _buildExplanation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SemanticIcon(
                icon: AppIcons.info,
                semanticLabel: context.l10n.info,
                size: AppIconSize.medium,
                color: context.colors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.whatIsPR,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.prExplanation,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// PR list (all exercises with PRs)
  Widget _buildPRList(BuildContext context, List<_PRInfo> prList) {
    if (prList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            SemanticIcon(
              icon: AppIcons.achievement,
              semanticLabel: context.l10n.noPRsYet,
              size: AppIconSize.xxlarge,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noPRsYet,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.noPRsYetMessage,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.allPersonalRecords,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // PR list items
        ...prList.map((pr) => _buildPRItem(context, pr)),
      ],
    );
  }

  /// Individual PR item
  Widget _buildPRItem(BuildContext context, _PRInfo pr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pr.isRecent
            ? context.colors.successContainer.withValues(alpha: 0.3)
            : context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: pr.isRecent
            ? Border.all(
                color: context.colors.success.withValues(alpha: 0.5),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          // Trophy icon (colored if recent)
          SemanticIcon(
            icon: AppIcons.achievement,
            semanticLabel: context.l10n.pr,
            size: AppIconSize.medium,
            color: pr.isRecent
                ? context.colors.success
                : context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: 12),

          // Exercise name + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pr.exerciseName,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pr.formatDate(context),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // PR value
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                pr.formatWeight(),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: pr.isRecent
                      ? context.colors.success
                      : context.colors.primary,
                ),
              ),
              if (pr.isRecent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.colors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.l10n.newLabel,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSuccess,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reset button
  Widget _buildResetButton(BuildContext context, int totalPRs) {
    if (totalPRs == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SemanticIcon(
                icon: AppIcons.warning,
                semanticLabel: context.l10n.warning,
                size: AppIconSize.medium,
                color: context.colors.error,
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.resetPRs,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.resetPRsMessage,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showResetConfirmation(context);
            },
            icon: SemanticIcon(
              icon: AppIcons.refresh,
              semanticLabel: context.l10n.reset,
              size: AppIconSize.buttonPrimary,
              color: context.colors.error,
            ),
            label: Text(context.l10n.resetAllPRsButton(totalPRs)),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.error,
              side: BorderSide(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Close button
  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        icon: SemanticIcon(
          icon: AppIcons.close,
          semanticLabel: context.l10n.close,
          size: AppIconSize.buttonPrimary,
        ),
        label: Text(context.l10n.close),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

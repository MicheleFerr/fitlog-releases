/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/widgets
/// 🎯 Feature: admin_dashboard
/// 🔧 Type: widget
/// 🌍 Localization: ✅ (context.l10n)
/// 🎨 Theme: ✅ (context.colors)
/// 📱 Platform: Universal
///
/// ADMIN ANALYTICS FEEDBACK WIDGET
///
/// Widget per visualizzare feedback Analytics nella dashboard admin.
/// Mostra statistiche aggregate e lista feedback recenti.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_feedback_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_page_feedback.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';

/// Widget admin per visualizzare feedback Analytics
class AdminAnalyticsFeedbackWidget extends ConsumerWidget {
  const AdminAnalyticsFeedbackWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Fetch stats and recent feedback
    final statsAsync = ref.watch(adminAnalyticsFeedbackStatsProvider);
    final feedbackAsync = ref.watch(
      adminAllAnalyticsFeedbackProvider((limit: 20, isHelpful: null)),
    );

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  AppIcons.analytics,
                  color: colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '📊 Analytics Page Feedback',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Stats Overview
            statsAsync.when(
              data: (stats) => _buildStatsOverview(context, stats),
              loading: () => Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: LoadingIndicator(),
                ),
              ),
              error: (error, _) => Text(
                'Error loading stats: $error',
                style: TextStyle(color: context.colors.error),
              ),
            ),

            const SizedBox(height: 24),

            // Recent Feedback List
            Text(
              'Recent Feedback',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            feedbackAsync.when(
              data: (feedbackList) {
                if (feedbackList.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No feedback yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: feedbackList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final feedback = feedbackList[index];
                    return _buildFeedbackTile(context, feedback);
                  },
                );
              },
              loading: () => Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: LoadingIndicator(),
                ),
              ),
              error: (error, _) => Text(
                'Error loading feedback: $error',
                style: TextStyle(color: context.colors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build statistics overview card
  Widget _buildStatsOverview(BuildContext context, Map<String, dynamic> stats) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalFeedback = stats['totalFeedback'] as int;
    final totalHelpful = stats['totalHelpful'] as int;
    final totalNotHelpful = stats['totalNotHelpful'] as int;
    final helpfulPercentage = stats['helpfulPercentage'] as double;
    final uniqueUsers = stats['uniqueUsers'] as int;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                context,
                icon: AppIcons.feedback,
                label: 'Total',
                value: totalFeedback.toString(),
                color: colorScheme.primary,
              ),
              _buildStatColumn(
                context,
                icon: AppIcons.thumbUp,
                label: 'Helpful',
                value: totalHelpful.toString(),
                color: context.colors.success,
              ),
              _buildStatColumn(
                context,
                icon: AppIcons.thumbDown,
                label: 'Not Helpful',
                value: totalNotHelpful.toString(),
                color: context.colors.error,
              ),
              _buildStatColumn(
                context,
                icon: AppIcons.people,
                label: 'Users',
                value: uniqueUsers.toString(),
                color: colorScheme.secondary,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Helpful Percentage Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Helpful Rate',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${helpfulPercentage.toStringAsFixed(1)}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: helpfulPercentage >= 70
                          ? context.colors.success
                          : helpfulPercentage >= 50
                              ? context.colors.warning
                              : context.colors.error,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: helpfulPercentage / 100,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    helpfulPercentage >= 70
                        ? context.colors.success
                        : helpfulPercentage >= 50
                            ? context.colors.warning
                            : context.colors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build single stat column
  Widget _buildStatColumn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// Build single feedback tile
  Widget _buildFeedbackTile(
    BuildContext context,
    AnalyticsPageFeedback feedback,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Icon(
        feedback.isHelpful ? AppIcons.thumbUp : AppIcons.thumbDown,
        color: feedback.isHelpful
            ? context.colors.success
            : context.colors.error,
      ),
      title: Row(
        children: [
          Text(
            'User: ${feedback.userId.substring(0, 8)}...',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          if (feedback.lastViewedSection != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                feedback.lastViewedSection!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (feedback.comment != null && feedback.comment!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              feedback.comment!,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 4),
          Text(
            feedback.formattedTimestamp,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

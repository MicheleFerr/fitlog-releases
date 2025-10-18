/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/screens
/// 🎯 Feature: admin
/// 🔧 Type: screen
///
/// Dashboard per visualizzare e gestire il feedback su esercizi
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/exercise_feedback_provider.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/screens/feedback_detail_screen.dart';

class ExerciseFeedbackScreen extends ConsumerWidget {
  const ExerciseFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(feedbackStatsProvider);
    final l10n = context.l10n;

    debugPrint('🔧 ExerciseFeedbackScreen: Building with statsAsync state: ${statsAsync.runtimeType}');

    statsAsync.when(
      data: (stats) => debugPrint('🔧 ExerciseFeedbackScreen: Data loaded - ${stats.totalFeedback} total feedback'),
      loading: () => debugPrint('🔧 ExerciseFeedbackScreen: Loading...'),
      error: (error, stack) => debugPrint('🔧 ExerciseFeedbackScreen: Error - $error'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.flag_circle,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Text(l10n.exerciseFeedback),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => ref.refresh(feedbackStatsProvider),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.feedbackRefresh,
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => _buildContent(context, ref, stats, l10n),
        loading: () => _buildLoadingState(context, l10n),
        error: (error, _) => _buildErrorState(context, l10n, error.toString()),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    FeedbackStats stats,
    dynamic l10n,
  ) {
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(feedbackStatsProvider),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            _buildStatsCards(context, stats),
            const SizedBox(height: 24),

            // Feedback by Type
            if (stats.byType.isNotEmpty) ...[
              Text(
                l10n.feedbackByType,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._buildFeedbackTypeCards(context, stats.byType),
              const SizedBox(height: 24),
            ],

            // Feedback by Severity
            if (stats.bySeverity.isNotEmpty) ...[
              Text(
                l10n.feedbackBySeverity,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._buildSeverityCards(context, stats.bySeverity, l10n),
              const SizedBox(height: 24),
            ],

            // Critical Feedback Section
            _buildCriticalFeedbackSection(context, ref),

            // Recent Feedback Section
            _buildRecentFeedbackSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, FeedbackStats stats) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: l10n.feedbackStatsTotal,
            value: stats.totalFeedback.toString(),
            icon: Icons.list,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: l10n.feedbackStatsOpen,
            value: stats.openCount.toString(),
            icon: Icons.pending,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: l10n.feedbackStatsResolved,
            value: stats.resolvedCount.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFeedbackTypeCards(
    BuildContext context,
    Map<String, int> byType,
  ) {
    final typeEmojis = {
      'BUG': '🐛',
      'SUGGESTION': '💡',
      'TYPO': '📝',
      'OTHER': '❓',
    };

    return byType.entries.map((entry) {
      final type = entry.key;
      final count = entry.value;
      final emoji = typeEmojis[type] ?? '•';

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    type,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildSeverityCards(
    BuildContext context,
    Map<String, int> bySeverity,
    dynamic l10n,
  ) {
    return bySeverity.entries.map((entry) {
      final severity = int.tryParse(entry.key) ?? 2;
      final count = entry.value;

      Color severityColor;
      String severityLabel;

      if (severity >= 4) {
        severityColor = Colors.red;
        severityLabel = l10n.feedbackSeverityCritical;
      } else if (severity == 3) {
        severityColor = Colors.orange;
        severityLabel = l10n.feedbackSeverityHigh;
      } else if (severity == 2) {
        severityColor = Colors.amber;
        severityLabel = l10n.feedbackSeverityMedium;
      } else {
        severityColor = Colors.green;
        severityLabel = l10n.feedbackSeverityLow;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 32,
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    severityLabel,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCriticalFeedbackSection(
    BuildContext context,
    WidgetRef ref,
  ) {
    final criticalAsync = ref.watch(criticalFeedbackProvider);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.feedbackCriticalIssues,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 12),
        criticalAsync.when(
          data: (feedbacks) {
            if (feedbacks.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      l10n.feedbackNoCriticalIssues,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: feedbacks
                  .take(5)
                  .map((feedback) => _buildFeedbackCard(context, feedback))
                  .toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(l10n.feedbackErrorLoadingCritical),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRecentFeedbackSection(
    BuildContext context,
    WidgetRef ref,
  ) {
    final openAsync = ref.watch(feedbackByStatusProvider('OPEN'));
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.feedbackRecentOpen,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        openAsync.when(
          data: (feedbacks) {
            if (feedbacks.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      l10n.feedbackNoOpenFeedback,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: feedbacks
                  .take(10)
                  .map((feedback) => _buildFeedbackCard(context, feedback))
                  .toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(l10n.feedbackErrorLoading),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(BuildContext context, ExerciseFeedback feedback) {
    final l10n = context.l10n;
    final typeEmojis = {
      'BUG': '🐛',
      'SUGGESTION': '💡',
      'TYPO': '📝',
      'OTHER': '❓',
    };

    Color severityColor;
    if (feedback.severity >= 4) {
      severityColor = Colors.red;
    } else if (feedback.severity == 3) {
      severityColor = Colors.orange;
    } else if (feedback.severity == 2) {
      severityColor = Colors.amber;
    } else {
      severityColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FeedbackDetailScreen(feedback: feedback),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  typeEmojis[feedback.feedbackType] ?? '•',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.exerciseName,
                        style: context.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        feedback.feedbackType,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              feedback.message,
              style: context.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.feedbackByUser(feedback.userEmail),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _formatDate(feedback.createdAt, l10n),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, dynamic l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l10n.feedbackLoadingMessage),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, dynamic l10n, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 64,
            color: context.colors.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.feedbackErrorLoading,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, dynamic l10n) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return l10n.feedbackTimeMinutesAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return l10n.feedbackTimeHoursAgo(diff.inHours);
    } else if (diff.inDays < 7) {
      return l10n.feedbackTimeDaysAgo(diff.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

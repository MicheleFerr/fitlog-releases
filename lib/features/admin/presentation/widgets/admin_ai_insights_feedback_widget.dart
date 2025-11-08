/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/widgets
/// 🎯 Feature: admin
/// 🔧 Type: widget
/// 🌍 Localization: ✅ YES (context.l10n)
/// 🎨 Theme: ✅ YES (context.colors)
/// 📱 Platform: Universal
///
/// Admin widget for displaying AI Coach Insights feedback from all users
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/home/presentation/providers/insight_feedback_provider.dart';
import 'package:gymbro_flutter_new/features/home/domain/entities/insight_feedback.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class AdminAIInsightsFeedbackWidget extends ConsumerWidget {
  const AdminAIInsightsFeedbackWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statsAsync = ref.watch(adminFeedbackStatsProvider);
    final feedbackAsync = ref.watch(adminAllFeedbackProvider(20)); // Show last 20

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  AppIcons.psychology,
                  color: colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'AI Coach Insights Feedback',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Feedback degli utenti sugli insights AI Coach',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),

            // Overall Stats
            statsAsync.when(
              data: (stats) => _buildStatsOverview(context, stats),
              loading: () => const LoadingIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            // Recent Feedback List
            Text(
              'Feedback Recenti (ultimi 20)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            feedbackAsync.when(
              data: (feedbackList) {
                if (feedbackList.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildFeedbackList(context, feedbackList);
              },
              loading: () => const LoadingIndicator(),
              error: (error, _) => Text(
                'Errore: $error',
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          // Main stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                context,
                icon: AppIcons.feedback,
                label: 'Totale',
                value: totalFeedback.toString(),
                color: colorScheme.primary,
              ),
              _buildStatColumn(
                context,
                icon: AppIcons.thumbUp,
                label: 'Utile',
                value: totalHelpful.toString(),
                color: context.colors.success,
              ),
              _buildStatColumn(
                context,
                icon: AppIcons.thumbDown,
                label: 'Non Utile',
                value: totalNotHelpful.toString(),
                color: context.colors.error,
              ),
              _buildStatColumn(
                context,
                icon: AppIcons.people,
                label: 'Utenti',
                value: uniqueUsers.toString(),
                color: colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Helpful percentage bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Percentuale "Utile"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${helpfulPercentage.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: helpfulPercentage / 100,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    helpfulPercentage >= 70 ? context.colors.success :
                    helpfulPercentage >= 50 ? context.colors.secondary : context.colors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              AppIcons.feedbackOutlined,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nessun feedback disponibile',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackList(BuildContext context, List<InsightFeedback> feedbackList) {
    return Column(
      children: feedbackList.map((feedback) => _buildFeedbackItem(context, feedback)).toList(),
    );
  }

  Widget _buildFeedbackItem(BuildContext context, InsightFeedback feedback) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Parse insight type to readable format
    final insightType = _parseInsightType(feedback.insightType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: feedback.isHelpful
              ? context.colors.success.withValues(alpha: 0.3)
              : context.colors.error.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Feedback icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: feedback.isHelpful
                  ? context.colors.success.withValues(alpha: 0.1)
                  : context.colors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              feedback.isHelpful ? AppIcons.thumbUp : AppIcons.thumbDown,
              color: feedback.isHelpful ? context.colors.success : context.colors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Feedback details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        insightType,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      dateFormat.format(feedback.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'User: ${feedback.userId.substring(0, 8)}...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    fontFamily: 'monospace',
                  ),
                ),
                if (feedback.comment != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      feedback.comment!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _parseInsightType(String insightType) {
    // Convert InsightType.enumValue to readable string
    final type = insightType.split('.').last;

    return switch (type) {
      'muscleGroupBalance' => '⚖️ Bilanciamento Muscolare',
      'volumeOptimization' => '📊 Ottimizzazione Volume',
      'progressOverload' => '📈 Sovraccarico Progressivo',
      'frequencyRecommendation' => '📅 Frequenza Allenamento',
      'restRecommendation' => '😴 Raccomandazione Riposo',
      'formCheck' => '✅ Controllo Tecnica',
      _ => type,
    };
  }
}

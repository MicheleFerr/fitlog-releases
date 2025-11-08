import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/exercise_review_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Admin screen for viewing monthly exercise review reports
class ExerciseReviewScreen extends ConsumerWidget {
  const ExerciseReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewStream = ref.watch(latestReviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.exerciseReviewReport),
        elevation: 0,
      ),
      body: reviewStream.when(
        loading: () => const LoadingIndicator(
          message: 'Caricando il report...',
        ),
        error: (error, stack) => _buildErrorWidget(context, error),
        data: (review) => review == null
            ? _buildNoReportWidget(context)
            : _buildReportContent(context, review),
      ),
    );
  }

  /// Build error widget
  Widget _buildErrorWidget(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.error,
            size: 64,
            color: context.colors.error,
          ),
          SizedBox(height: 16),
          Text(
            'Errore nel caricamento del report',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colors.error,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  /// Build no report available widget
  Widget _buildNoReportWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.assignmentOutlined,
            size: 64,
            color: context.colors.onSurfaceVariant,
          ),
          SizedBox(height: 16),
          Text(
            'Nessun report disponibile',
            style: context.textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Il report mensile sarà disponibile dopo la prima esecuzione',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build main report content
  Widget _buildReportContent(BuildContext context, Map<String, dynamic> review) {
    final stats = review['statistics'] as Map<String, dynamic>? ?? {};
    final recommendations = (review['recommendations'] as List?)?.cast<String>() ?? [];
    final period = review['period'] as String? ?? 'Unknown';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report period header
          _buildPeriodHeader(context, period),
          const SizedBox(height: 24),

          // Statistics cards
          _buildStatisticsSection(context, stats),
          const SizedBox(height: 24),

          // Recommendations
          if (recommendations.isNotEmpty) ...[
            _buildRecommendationsSection(context, recommendations),
            const SizedBox(height: 24),
          ],

          // Stale exercises section
          if (review['staleExercises'] != null) ...[
            _buildStaleExercisesSection(
              context,
              (review['staleExercises'] as List?)?.cast<Map<String, dynamic>>() ?? [],
            ),
            const SizedBox(height: 24),
          ],

          // Flagged exercises section
          if (review['flaggedExercises'] != null) ...[
            _buildFlaggedExercisesSection(
              context,
              (review['flaggedExercises'] as List?)?.cast<Map<String, dynamic>>() ?? [],
            ),
          ],

          SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Build period header
  Widget _buildPeriodHeader(BuildContext context, String period) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report: $period',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Revisione automatica mensile degli esercizi',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Build statistics section with stat cards
  Widget _buildStatisticsSection(
    BuildContext context,
    Map<String, dynamic> stats,
  ) {
    final staleCount = (stats['staleExercisesCount'] as num?)?.toInt() ?? 0;
    final flaggedCount = (stats['flaggedExercisesCount'] as num?)?.toInt() ?? 0;
    final totalFeedback = (stats['totalFeedbackFlagged'] as num?)?.toInt() ?? 0;
    final criticalCount = (stats['criticalIssuesCount'] as num?)?.toInt() ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiche',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              context,
              icon: AppIcons.scheduleOutlined,
              label: 'Esercizi Obsoleti',
              value: staleCount.toString(),
              color: context.colors.secondary,
              subtitle: '>90 giorni',
            ),
            _buildStatCard(
              context,
              icon: AppIcons.flagOutlined,
              label: 'Esercizi Flaggati',
              value: flaggedCount.toString(),
              color: context.colors.warning,
              subtitle: '≥3 feedback',
            ),
            _buildStatCard(
              context,
              icon: AppIcons.commentOutlined,
              label: 'Feedback Totali',
              value: totalFeedback.toString(),
              color: context.colors.primary,
              subtitle: 'flaggati',
            ),
            _buildStatCard(
              context,
              icon: AppIcons.error,
              label: 'Problemi Critici',
              value: criticalCount.toString(),
              color: context.colors.error,
              subtitle: 'severità ≥4',
            ),
          ],
        ),
      ],
    );
  }

  /// Build individual stat card
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              value,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build recommendations section
  Widget _buildRecommendationsSection(
    BuildContext context,
    List<String> recommendations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Raccomandazioni',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Card(
          color: context.colors.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                recommendations.length,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index < recommendations.length - 1 ? 8 : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8, top: 2),
                        child: Text(
                          '•',
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          recommendations[index],
                          style: context.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build stale exercises section
  Widget _buildStaleExercisesSection(
    BuildContext context,
    List<Map<String, dynamic>> staleExercises,
  ) {
    if (staleExercises.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Esercizi Obsoleti (${staleExercises.length})',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              AppIcons.scheduleOutlined,
              color: context.colors.secondary,
              size: 20,
            ),
          ],
        ),
        SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: staleExercises.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: context.colors.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final exercise = staleExercises[index];
              return _buildExerciseListTile(
                context,
                exerciseName: exercise['nome'] as String? ?? 'Unknown',
                subtitle:
                    'Modificato ${exercise['lastModifiedDaysAgo'] ?? 0} giorni fa',
                icon: AppIcons.schedule,
                color: context.colors.secondary,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build flagged exercises section
  Widget _buildFlaggedExercisesSection(
    BuildContext context,
    List<Map<String, dynamic>> flaggedExercises,
  ) {
    if (flaggedExercises.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Esercizi Flaggati (${flaggedExercises.length})',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              AppIcons.flagOutlined,
              color: context.colors.warning,
              size: 20,
            ),
          ],
        ),
        SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: flaggedExercises.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: context.colors.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final exercise = flaggedExercises[index];
              final feedbackCount = (exercise['feedbackCount'] as num?)?.toInt() ?? 0;
              final criticalCount = (exercise['criticalCount'] as num?)?.toInt() ?? 0;

              return _buildExerciseListTile(
                context,
                exerciseName: exercise['nome'] as String? ?? 'Unknown',
                subtitle:
                    '$feedbackCount feedback${criticalCount > 0 ? ' ($criticalCount critici)' : ''}',
                icon: AppIcons.flag,
                color: criticalCount > 0 ? context.colors.error : context.colors.warning,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build exercise list tile
  Widget _buildExerciseListTile(
    BuildContext context, {
    required String exerciseName,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(exerciseName),
      subtitle: Text(subtitle),
      trailing: Icon(
        AppIcons.chevronRight,
        color: context.colors.onSurfaceVariant,
      ),
    );
  }
}

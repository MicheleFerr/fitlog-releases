/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation
/// 🎯 Feature: analytics
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: ConsumerWidget
/// - Material: Card, LinearProgressIndicator, IconButton
/// - analytics/presentation/providers: workoutAnalyticsProvider
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/workout_analytics_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/pr_celebration_widget.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/widgets/workout_comparison_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Real-time analytics bar showing key workout metrics during workout
class WorkoutAnalyticsBar extends ConsumerWidget {

  const WorkoutAnalyticsBar({
    super.key,
    this.isCompact = false,
    this.onTap,
  });
  final bool isCompact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Use selective watching to prevent unnecessary rebuilds
    final volume = ref.watch(currentWorkoutVolumeProvider);
    final completion = ref.watch(workoutCompletionProvider);
    final quality = ref.watch(workoutQualityProvider);
    final isLoading = ref.watch(analyticsLoadingProvider);
    final hasNewPRs = ref.watch(currentPRsProvider).isNotEmpty;
    final showsImprovement = ref.watch(workoutImprovementProvider);

    if (volume == 0 && completion == 0 && !isLoading) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: isCompact ? _buildCompactView(
            context, ref, l10n, colorScheme, volume, completion, quality,
            isLoading, hasNewPRs, showsImprovement,
          ) : _buildExpandedView(
            context, ref, l10n, colorScheme, volume, completion, quality,
            isLoading, hasNewPRs, showsImprovement,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactView(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    double volume,
    double completion,
    double quality,
    bool isLoading,
    bool hasNewPRs,
    bool showsImprovement,
  ) {
    return Row(
      children: [
        // PR Achievement Indicator
        if (hasNewPRs)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              shape: BoxShape.circle,
            ),
          ),

        // Main Metrics
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCompactMetric(
                l10n.volume,
                '${volume.toStringAsFixed(0)} kg',
                AppIcons.workout,
                colorScheme.primary,
              ),
              _buildCompactMetric(
                l10n.completion,
                '${(completion * 100).toStringAsFixed(0)}%',
                AppIcons.completeOutline,
                _getCompletionColor(completion, colorScheme),
              ),
              _buildCompactMetric(
                l10n.quality,
                _getQualityGrade(quality),
                AppIcons.stars,
                _getQualityColor(quality, colorScheme),
              ),
            ],
          ),
        ),

        // Loading indicator
        if (isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),

        // Expand button
        IconButton(
          icon: const Icon(AppIcons.expandMore),
          onPressed: onTap,
          tooltip: l10n.viewDetails,
        ),
      ],
    );
  }

  Widget _buildExpandedView(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    double volume,
    double completion,
    double quality,
    bool isLoading,
    bool hasNewPRs,
    bool showsImprovement,
  ) {
    final analytics = ref.watch(workoutAnalyticsProvider);
    final metrics = analytics.currentMetrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with status indicators
        Row(
          children: [
            Icon(
              AppIcons.analytics,
              color: colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.workoutAnalytics,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (showsImprovement)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.secondary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.trendUp,
                      color: colorScheme.secondary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.improving,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Progress indicator
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.workoutProgress,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${(completion * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: completion,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(_getCompletionColor(completion, colorScheme)),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Key metrics grid
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                l10n.volume,
                '${volume.toStringAsFixed(0)} kg',
                AppIcons.workout,
                colorScheme.primary,
                metrics?.workingSetsVolume != null 
                    ? '${l10n.working}: ${metrics!.workingSetsVolume.toStringAsFixed(0)} kg'
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                context,
                l10n.intensity,
                metrics?.averageRPE != null && metrics!.averageRPE > 0
                    ? '${metrics.averageRPE.toStringAsFixed(1)} RPE'
                    : l10n.noData,
                AppIcons.whatshot,
                colorScheme.secondary,
                metrics?.peakIntensity != null
                    ? '${l10n.peak}: ${metrics!.peakIntensity.toStringAsFixed(0)}'
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                context,
                l10n.quality,
                _getQualityGrade(quality),
                AppIcons.stars,
                _getQualityColor(quality, colorScheme),
                '${quality.toStringAsFixed(0)}/100',
              ),
            ),
          ],
        ),

        // PR celebrations if any
        if (hasNewPRs) ...[
          const SizedBox(height: 12),
          const PRCelebrationWidget(),
        ],

        // Workout comparison if available
        const SizedBox(height: 12),
        const WorkoutComparisonWidget(),
      ],
    );
  }

  Widget _buildCompactMetric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String? subtitle,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Color _getCompletionColor(double completion, ColorScheme colorScheme) {
    if (completion >= 0.8) return colorScheme.secondary;
    if (completion >= 0.5) return colorScheme.primary;
    return colorScheme.outline;
  }

  Color _getQualityColor(double quality, ColorScheme colorScheme) {
    if (quality >= 85) return colorScheme.secondary;
    if (quality >= 70) return colorScheme.primary;
    if (quality >= 60) return colorScheme.tertiary;
    return colorScheme.outline;
  }

  String _getQualityGrade(double quality) {
    if (quality >= 90) return 'A+';
    if (quality >= 85) return 'A';
    if (quality >= 80) return 'B+';
    if (quality >= 75) return 'B';
    if (quality >= 70) return 'C+';
    if (quality >= 65) return 'C';
    if (quality >= 60) return 'D';
    return 'F';
  }
}

/// Analytics summary widget for quick overview
class WorkoutAnalyticsSummary extends ConsumerWidget {
  const WorkoutAnalyticsSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final analytics = ref.watch(workoutAnalyticsProvider);
    final metrics = analytics.currentMetrics;
    
    if (metrics == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.workoutSummary,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${metrics.formattedVolume} • ${metrics.formattedDuration} • ${_getQualityGrade(metrics.qualityScore)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
                if (analytics.hasNewPRs) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        AppIcons.celebration,
                        color: colorScheme.secondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.newPersonalRecords(analytics.totalPRs),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getQualityGrade(metrics.qualityScore),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getQualityGrade(double quality) {
    if (quality >= 90) return 'A+';
    if (quality >= 85) return 'A';
    if (quality >= 80) return 'B+';
    if (quality >= 75) return 'B';
    if (quality >= 70) return 'C+';
    if (quality >= 65) return 'C';
    if (quality >= 60) return 'D';
    return 'F';
  }
}

/// Floating analytics widget for minimal distraction
class FloatingAnalyticsWidget extends ConsumerWidget {

  const FloatingAnalyticsWidget({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final volume = ref.watch(currentWorkoutVolumeProvider);
    final hasNewPRs = ref.watch(currentPRsProvider).isNotEmpty;
    
    if (volume == 0) return const SizedBox.shrink();

    return Positioned(
      top: kToolbarHeight + 8,
      right: 16,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: hasNewPRs 
                ? Border.all(color: colorScheme.secondary, width: 2)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasNewPRs) ...[
                Icon(
                  AppIcons.celebration,
                  color: colorScheme.secondary,
                  size: 14,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                '${volume.toStringAsFixed(0)} kg',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasNewPRs ? colorScheme.secondary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

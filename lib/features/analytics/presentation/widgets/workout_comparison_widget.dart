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
/// - Material: Card, LinearProgressIndicator
/// - analytics/presentation/providers: workoutAnalyticsProvider
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/workout_analytics_provider.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/workout_metrics.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Widget showing comparison with previous similar workout
class WorkoutComparisonWidget extends ConsumerWidget {

  const WorkoutComparisonWidget({
    super.key,
    this.isCompact = false,
  });
  final bool isCompact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final comparison = ref.watch(workoutComparisonProvider);
    
    if (comparison == null) return const SizedBox.shrink();
    
    return Card(
      elevation: 0,
      color: _getComparisonBackgroundColor(comparison, colorScheme),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _getComparisonBorderColor(comparison, colorScheme),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _getComparisonIcon(comparison),
                  color: _getComparisonColor(comparison, colorScheme),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.comparedToLast,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: _getComparisonColor(comparison, colorScheme),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatComparisonDate(comparison.comparisonDate, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            if (isCompact)
              _buildCompactComparison(context, theme, colorScheme, comparison, l10n)
            else
              _buildDetailedComparison(context, theme, colorScheme, comparison, l10n),
            
            // Overall status
            const SizedBox(height: 8),
            
            _buildOverallStatus(context, theme, colorScheme, comparison, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactComparison(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    WorkoutComparison comparison,
    AppLocalizations l10n,
  ) {
    return Text(
      '${l10n.volume}: ${comparison.formattedVolumeChange}',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: _getComparisonColor(comparison, colorScheme),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDetailedComparison(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    WorkoutComparison comparison,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        // Volume comparison
        _buildMetricComparison(
          context,
          theme,
          colorScheme,
          l10n.volume,
          comparison.formattedVolumeChange,
          comparison.volumeChangePercentage,
          AppIcons.workout,
        ),
        
        const SizedBox(height: 6),
        
        // Intensity comparison
        if (comparison.intensityChange.abs() > 0.1)
          _buildMetricComparison(
            context,
            theme,
            colorScheme,
            l10n.intensity,
            comparison.formattedIntensityChange,
            comparison.intensityChangePercentage,
            AppIcons.whatshot,
          ),
        
        const SizedBox(height: 6),
        
        // Duration comparison
        if (comparison.durationChange.inMinutes.abs() > 0)
          _buildMetricComparison(
            context,
            theme,
            colorScheme,
            l10n.duration,
            comparison.formattedDurationChange,
            comparison.durationChange.inMinutes.toDouble(),
            AppIcons.timer,
          ),
      ],
    );
  }

  Widget _buildMetricComparison(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    String formattedChange,
    double changePercentage,
    IconData icon,
  ) {
    final isPositive = changePercentage > 0;
    final color = isPositive 
        ? colorScheme.secondary 
        : changePercentage < 0 
            ? colorScheme.error
            : colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 14,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          formattedChange,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildOverallStatus(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    WorkoutComparison comparison,
    AppLocalizations l10n,
  ) {
    final statusText = comparison.isImprovement
        ? l10n.improvementDetected
        : comparison.isSimilar
            ? l10n.similarPerformance
            : l10n.performanceDeclined;
    
    final statusColor = comparison.isImprovement
        ? colorScheme.secondary
        : comparison.isSimilar
            ? colorScheme.primary
            : colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(comparison),
            color: statusColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods

  Color _getComparisonBackgroundColor(WorkoutComparison comparison, ColorScheme colorScheme) {
    if (comparison.isImprovement) {
      return colorScheme.secondary.withValues(alpha: 0.05);
    } else if (comparison.isRegression) {
      return colorScheme.error.withValues(alpha: 0.05);
    } else {
      return colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    }
  }

  Color _getComparisonBorderColor(WorkoutComparison comparison, ColorScheme colorScheme) {
    if (comparison.isImprovement) {
      return colorScheme.secondary.withValues(alpha: 0.3);
    } else if (comparison.isRegression) {
      return colorScheme.error.withValues(alpha: 0.3);
    } else {
      return colorScheme.outline.withValues(alpha: 0.3);
    }
  }

  Color _getComparisonColor(WorkoutComparison comparison, ColorScheme colorScheme) {
    if (comparison.isImprovement) {
      return colorScheme.secondary;
    } else if (comparison.isRegression) {
      return colorScheme.error;
    } else {
      return colorScheme.onSurfaceVariant;
    }
  }

  IconData _getComparisonIcon(WorkoutComparison comparison) {
    if (comparison.isImprovement) {
      return AppIcons.trendUp;
    } else if (comparison.isRegression) {
      return AppIcons.trendDown;
    } else {
      return AppIcons.trendFlat;
    }
  }

  IconData _getStatusIcon(WorkoutComparison comparison) {
    if (comparison.isImprovement) {
      return AppIcons.thumbUp;
    } else if (comparison.isRegression) {
      return AppIcons.thumbDown;
    } else {
      return AppIcons.remove;
    }
  }

  String _formatComparisonDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return l10n.today;
    } else if (difference == 1) {
      return l10n.yesterday;
    } else if (difference < 7) {
      return l10n.daysAgo(difference);
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return l10n.weeksAgo(weeks);
    } else {
      final months = (difference / 30).floor();
      return l10n.monthsAgo(months);
    }
  }
}

/// Detailed workout comparison view
class DetailedWorkoutComparison extends ConsumerWidget {

  const DetailedWorkoutComparison({
    super.key,
    required this.workoutId,
  });
  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final comparison = ref.watch(workoutComparisonProvider);
    
    if (comparison == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.analytics,
              color: colorScheme.onSurfaceVariant,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noComparisonData,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.needMoreWorkouts,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getComparisonIcon(comparison),
                        color: _getComparisonColor(comparison, colorScheme),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.workoutComparison,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.comparedTo}: ${comparison.comparisonName}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _formatComparisonDate(comparison.comparisonDate, l10n),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Metrics comparison cards
          _buildMetricCard(
            context,
            theme,
            colorScheme,
            l10n.volume,
            comparison.formattedVolumeChange,
            comparison.volumeChangePercentage,
            AppIcons.workout,
            l10n.totalWeightLifted,
          ),

          const SizedBox(height: 12),

          _buildMetricCard(
            context,
            theme,
            colorScheme,
            l10n.intensity,
            comparison.formattedIntensityChange,
            comparison.intensityChangePercentage,
            AppIcons.whatshot,
            l10n.averageEffortLevel,
          ),

          const SizedBox(height: 12),

          _buildMetricCard(
            context,
            theme,
            colorScheme,
            l10n.duration,
            comparison.formattedDurationChange,
            comparison.durationChange.inMinutes.toDouble(),
            AppIcons.timer,
            l10n.workoutDuration,
          ),

          const SizedBox(height: 20),

          // Overall assessment
          Card(
            color: _getComparisonBackgroundColor(comparison, colorScheme),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(comparison),
                        color: _getComparisonColor(comparison, colorScheme),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.overallAssessment,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getAssessmentText(comparison, l10n),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (comparison.improvementScore + 100) / 200,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(
                      _getComparisonColor(comparison, colorScheme),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.declined,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        l10n.improved,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String formattedChange,
    double changePercentage,
    IconData icon,
    String description,
  ) {
    final isPositive = changePercentage > 0;
    final isNegative = changePercentage < 0;
    
    final color = isPositive
        ? colorScheme.secondary
        : isNegative
            ? colorScheme.error
            : colorScheme.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  isPositive
                      ? AppIcons.arrowUpward
                      : isNegative
                          ? AppIcons.arrowDownward
                          : Icons.remove,
                  color: color,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedChange,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${changePercentage >= 0 ? '+' : ''}${changePercentage.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
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

  String _getAssessmentText(WorkoutComparison comparison, AppLocalizations l10n) {
    if (comparison.isImprovement) {
      return l10n.workoutImprovementDescription;
    } else if (comparison.isSimilar) {
      return l10n.workoutSimilarDescription;
    } else {
      return l10n.workoutDeclineDescription;
    }
  }

  // Helper methods (same as WorkoutComparisonWidget)
  Color _getComparisonBackgroundColor(WorkoutComparison comparison, ColorScheme colorScheme) {
    if (comparison.isImprovement) {
      return colorScheme.secondary.withValues(alpha: 0.05);
    } else if (comparison.isRegression) {
      return colorScheme.error.withValues(alpha: 0.05);
    } else {
      return colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    }
  }

  Color _getComparisonColor(WorkoutComparison comparison, ColorScheme colorScheme) {
    if (comparison.isImprovement) {
      return colorScheme.secondary;
    } else if (comparison.isRegression) {
      return colorScheme.error;
    } else {
      return colorScheme.onSurfaceVariant;
    }
  }

  IconData _getComparisonIcon(WorkoutComparison comparison) {
    if (comparison.isImprovement) {
      return AppIcons.trendUp;
    } else if (comparison.isRegression) {
      return AppIcons.trendDown;
    } else {
      return AppIcons.trendFlat;
    }
  }

  IconData _getStatusIcon(WorkoutComparison comparison) {
    if (comparison.isImprovement) {
      return AppIcons.thumbUp;
    } else if (comparison.isRegression) {
      return AppIcons.thumbDown;
    } else {
      return AppIcons.remove;
    }
  }

  String _formatComparisonDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return l10n.today;
    } else if (difference == 1) {
      return l10n.yesterday;
    } else if (difference < 7) {
      return l10n.daysAgo(difference);
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return l10n.weeksAgo(weeks);
    } else {
      final months = (difference / 30).floor();
      return l10n.monthsAgo(months);
    }
  }
}

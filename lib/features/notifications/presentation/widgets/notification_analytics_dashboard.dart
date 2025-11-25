import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/services/notification_analytics_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/notifications/domain/entities/notification_type.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Dashboard widget for displaying notification analytics
class NotificationAnalyticsDashboard extends ConsumerWidget {
  const NotificationAnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(notificationAnalyticsMetricsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return metricsAsync.when(
      data: (metrics) => _buildDashboard(context, metrics, theme),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading analytics: $error'),
      ),
    );
  }
  
  Widget _buildDashboard(
    BuildContext context, 
    NotificationAnalyticsMetrics metrics,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(context, metrics, theme),
          const SizedBox(height: 24),
          _buildClickRateChart(context, metrics, theme),
          const SizedBox(height: 24),
          _buildHourlyDistribution(context, metrics, theme),
          const SizedBox(height: 24),
          _buildTypeBreakdown(context, metrics, theme),
          if (metrics.recentErrors.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildErrorLog(context, metrics, theme),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSummaryCards(
    BuildContext context,
    NotificationAnalyticsMetrics metrics,
    ThemeData theme,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          title: 'Scheduled',
          value: metrics.totalScheduled.toString(),
          icon: Icons.schedule,
          color: theme.colorScheme.primary,
          theme: theme,
        ),
        _buildMetricCard(
          title: 'Delivered',
          value: '${metrics.totalDelivered}',
          subtitle: '${(metrics.deliveryRate * 100).toStringAsFixed(1)}%',
          icon: Icons.check_circle,
          color: theme.colorScheme.tertiary,
          theme: theme,
        ),
        _buildMetricCard(
          title: 'Clicked',
          value: '${metrics.totalClicked}',
          subtitle: '${(metrics.clickRate * 100).toStringAsFixed(1)}% CTR',
          icon: Icons.touch_app,
          color: theme.colorScheme.primary,
          theme: theme,
        ),
        _buildMetricCard(
          title: 'Failed',
          value: '${metrics.totalFailed}',
          subtitle: '${(metrics.failureRate * 100).toStringAsFixed(1)}%',
          icon: Icons.error,
          color: theme.colorScheme.error,
          theme: theme,
        ),
      ],
    );
  }
  
  Widget _buildMetricCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildClickRateChart(
    BuildContext context,
    NotificationAnalyticsMetrics metrics,
    ThemeData theme,
  ) {
    if (metrics.clickRateByType.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final sortedTypes = metrics.clickRateByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Click Rate by Type',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1.0,
                  barTouchData: const BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= sortedTypes.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _getShortTypeName(sortedTypes[value.toInt()].key),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value * 100).toInt()}%',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: sortedTypes.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value,
                          color: theme.colorScheme.primary,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHourlyDistribution(
    BuildContext context,
    NotificationAnalyticsMetrics metrics,
    ThemeData theme,
  ) {
    if (metrics.scheduledByHour.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final spots = <FlSpot>[];
    for (int hour = 0; hour < 24; hour++) {
      spots.add(FlSpot(
        hour.toDouble(),
        (metrics.scheduledByHour[hour] ?? 0).toDouble(),
      ));
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity by Hour',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 6,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}h',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: 23,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTypeBreakdown(
    BuildContext context,
    NotificationAnalyticsMetrics metrics,
    ThemeData theme,
  ) {
    if (metrics.scheduledByType.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications by Type',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...metrics.scheduledByType.entries.map((entry) {
              final delivered = metrics.deliveredByType[entry.key] ?? 0;
              final clicked = metrics.clickedByType[entry.key] ?? 0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getTypeName(entry.key),
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          '${entry.value} scheduled',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: delivered > 0 ? delivered / entry.value : 0,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(
                              theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$delivered/$clicked',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorLog(
    BuildContext context,
    NotificationAnalyticsMetrics metrics,
    ThemeData theme,
  ) {
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Errors',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...metrics.recentErrors.take(5).map((error) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  error,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  String _getTypeName(NotificationType type) {
    switch (type) {
      case NotificationType.timerComplete:
        return 'Timer Complete';
      case NotificationType.workoutReminder:
        return 'Workout Reminder';
      case NotificationType.achievementUnlocked:
        return 'Achievement';
      case NotificationType.progressMilestone:
        return 'Progress';
      case NotificationType.coachMessage:
        return 'Coach Message';
      case NotificationType.friendActivity:
        return 'Social';
      case NotificationType.systemUpdate:
        return 'System';
      case NotificationType.restReminder:
        return 'Rest Reminder';
      case NotificationType.workoutSummary:
        return 'Workout Summary';
      case NotificationType.streakReminder:
        return 'Streak Reminder';
      case NotificationType.promotional:
        return 'Promotional';
      case NotificationType.emergency:
        return 'Emergency';
      default:
        return type.toString().split('.').last;
    }
  }
  
  String _getShortTypeName(NotificationType type) {
    switch (type) {
      case NotificationType.timerComplete:
        return 'Timer';
      case NotificationType.workoutReminder:
        return 'Reminder';
      case NotificationType.achievementUnlocked:
        return 'Achieve';
      case NotificationType.progressMilestone:
        return 'Progress';
      case NotificationType.coachMessage:
        return 'Coach';
      case NotificationType.friendActivity:
        return 'Social';
      case NotificationType.systemUpdate:
        return 'System';
      case NotificationType.restReminder:
        return 'Rest';
      case NotificationType.workoutSummary:
        return 'Summary';
      case NotificationType.streakReminder:
        return 'Streak';
      case NotificationType.promotional:
        return 'Promo';
      case NotificationType.emergency:
        return 'Alert';
      default:
        return type.toString().split('.').last.substring(0, 6);
    }
  }
}
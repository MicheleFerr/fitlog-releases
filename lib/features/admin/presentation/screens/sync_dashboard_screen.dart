/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/screens
/// 🎯 Feature: admin
/// 🔧 Type: screen
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Admin dashboard for monitoring sync status
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/admin_sync_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/auth_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class SyncDashboardScreen extends ConsumerStatefulWidget {
  const SyncDashboardScreen({super.key});

  @override
  ConsumerState<SyncDashboardScreen> createState() => _SyncDashboardScreenState();
}

class _SyncDashboardScreenState extends ConsumerState<SyncDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Start monitoring
    Future.microtask(() {
      ref.read(syncMonitorProvider.notifier).startMonitoring();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final syncData = ref.watch(syncMonitorProvider);
    final user = ref.watch(currentUserProvider).value;
    
    // Check if user is admin
    final isAdmin = user?.email.contains('admin') ?? false;
    
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sync Dashboard'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.lockOutline,
                size: 64,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Admin access required',
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.refresh),
            onPressed: () {
              ref.read(syncMonitorProvider.notifier).refreshStats();
            },
          ),
        ],
      ),
      body: syncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.error,
                size: 48,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading sync data',
                style: TextStyle(color: colorScheme.error),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            await ref.read(syncMonitorProvider.notifier).refreshStats();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Overview Cards
              _buildOverviewSection(context, data),
              const SizedBox(height: 24),
              
              // Sync Status Chart
              _buildSyncChart(context, data),
              const SizedBox(height: 24),
              
              // Feature-by-Feature Status
              _buildFeatureStatus(context, data),
              const SizedBox(height: 24),
              
              // Recent Sync Activity
              _buildRecentActivity(context, data),
              const SizedBox(height: 24),
              
              // User Statistics
              _buildUserStats(context, data),
              const SizedBox(height: 24),
              
              // System Health
              _buildSystemHealth(context, data),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context, SyncDashboardData data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildStatCard(
              context,
              icon: AppIcons.people,
              title: 'Total Users',
              value: data.totalUsers.toString(),
              subtitle: '${data.premiumUsers} premium',
              color: colorScheme.primary,
            ),
            _buildStatCard(
              context,
              icon: AppIcons.syncIcon,
              title: 'Active Syncs',
              value: data.activeSyncs.toString(),
              subtitle: 'Last ${data.lastSyncTime}',
              color: colorScheme.secondary,
            ),
            _buildStatCard(
              context,
              icon: AppIcons.storage,
              title: 'Local Data',
              value: _formatBytes(data.localDataSize),
              subtitle: '${data.localEntities} entities',
              color: colorScheme.tertiary,
            ),
            _buildStatCard(
              context,
              icon: AppIcons.cloudUpload,
              title: 'Cloud Synced',
              value: '${data.syncPercentage}%',
              subtitle: '${data.pendingSyncs} pending',
              color: colorScheme.primaryContainer,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncChart(BuildContext context, SyncDashboardData data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sync Activity (Last 24h)',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final hour = value.toInt();
                          return Text(
                            '${hour}h',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.syncHistory.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureStatus(BuildContext context, SyncDashboardData data) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feature Status',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ...data.featureStats.entries.map((entry) {
          return _buildFeatureRow(context, entry.key, entry.value);
        }),
      ],
    );
  }

  Widget _buildFeatureRow(BuildContext context, String feature, FeatureSyncStats stats) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: stats.isHealthy 
              ? colorScheme.primaryContainer 
              : colorScheme.errorContainer,
          child: Icon(
            _getFeatureIcon(feature),
            color: stats.isHealthy 
                ? colorScheme.onPrimaryContainer 
                : colorScheme.onErrorContainer,
          ),
        ),
        title: Text(feature),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Local: ${stats.localEntities} | Cloud: ${stats.cloudEntities}'),
            if (stats.pendingSync > 0)
              Text(
                '${stats.pendingSync} pending sync',
                style: TextStyle(color: colorScheme.error),
              ),
            LinearProgressIndicator(
              value: stats.syncPercentage / 100,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                stats.isHealthy ? colorScheme.primary : colorScheme.error,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${stats.syncPercentage}%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: stats.isHealthy ? colorScheme.primary : colorScheme.error,
              ),
            ),
            Text(
              stats.lastSync,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, SyncDashboardData data) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Sync Activity',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.recentActivities.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final activity = data.recentActivities[index];
              return ListTile(
                leading: Icon(
                  activity.isSuccess ? AppIcons.complete : AppIcons.error,
                  color: activity.isSuccess 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.error,
                ),
                title: Text(activity.description),
                subtitle: Text(activity.timestamp),
                trailing: Text(
                  activity.userId,
                  style: theme.textTheme.bodySmall,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserStats(BuildContext context, SyncDashboardData data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Statistics',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPieChart(
                context,
                title: 'User Distribution',
                data: {
                  'Free': data.freeUsers.toDouble(),
                  'Premium': data.premiumUsers.toDouble(),
                  'Pro': data.proUsers.toDouble(),
                },
                colors: [
                  colorScheme.surfaceContainerHighest,
                  colorScheme.primary,
                  colorScheme.secondary,
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPieChart(
                context,
                title: 'Sync Usage',
                data: {
                  'Active': data.activeSyncUsers.toDouble(),
                  'Inactive': (data.totalUsers - data.activeSyncUsers).toDouble(),
                },
                colors: [
                  colorScheme.primary,
                  colorScheme.surfaceContainerHighest,
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPieChart(
    BuildContext context, {
    required String title,
    required Map<String, double> data,
    required List<Color> colors,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: data.entries.map((entry) {
                    final index = data.keys.toList().indexOf(entry.key);
                    final total = data.values.reduce((a, b) => a + b);
                    final percentage = (entry.value / total * 100).toStringAsFixed(1);
                    
                    return PieChartSectionData(
                      value: entry.value,
                      title: '$percentage%',
                      color: colors[index % colors.length],
                      radius: 50,
                      titleStyle: theme.textTheme.bodySmall?.copyWith(
                        color: context.colors.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...data.entries.map((entry) {
              final index = data.keys.toList().indexOf(entry.key);
              return Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: colors[index % colors.length],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.key}: ${entry.value.toInt()}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealth(BuildContext context, SyncDashboardData data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Health',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: data.systemHealth.isHealthy 
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : colorScheme.errorContainer.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      data.systemHealth.isHealthy 
                          ? AppIcons.complete 
                          : AppIcons.warning,
                      color: data.systemHealth.isHealthy 
                          ? colorScheme.primary 
                          : colorScheme.error,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.systemHealth.isHealthy 
                                ? 'System Healthy' 
                                : 'Issues Detected',
                            style: theme.textTheme.titleLarge,
                          ),
                          Text(
                            data.systemHealth.message,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...data.systemHealth.metrics.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          entry.value,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getFeatureIcon(String feature) {
    switch (feature.toLowerCase()) {
      case 'workouts':
        return AppIcons.workout;
      case 'templates':
        return AppIcons.template;
      case 'achievements':
        return AppIcons.achievement;
      case 'community':
        return AppIcons.people;
      case 'preferences':
        return AppIcons.settings;
      default:
        return AppIcons.folder;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/screens
/// 🎯 Feature: admin
/// 🔧 Type: screen (admin analytics dashboard)
/// 
/// Admin dashboard for collecting and viewing global analytics
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/admin_analytics_sync_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load previous analytics on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminAnalyticsSyncProvider.notifier).loadCollectedAnalytics();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final syncState = ref.watch(adminAnalyticsSyncProvider);
    final isAdmin = ref.watch(isAdminProvider);
    
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Only'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SemanticIcon(
  icon: AppIcons.lockOutline,
  semanticLabel: 'Lock outline',
  size: AppIconSize.medium,
  color: theme.colorScheme.outline,
),
              const SizedBox(height: 16),
              Text(
                'Admin Access Required',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'This feature is only available for administrators',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Admin Analytics'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: SemanticIcon(
  icon: AppIcons.dashboard,
  semanticLabel: 'Dashboard',
)),
            Tab(text: 'Users', icon: SemanticIcon(
  icon: AppIcons.people,
  semanticLabel: 'People',
)),
            Tab(text: 'Exercises', icon: SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
)),
            Tab(text: 'Trends', icon: SemanticIcon(
  icon: AppIcons.trendUp,
  semanticLabel: 'Trend up',
)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Sync controls
          _buildSyncControls(context, syncState),
          
          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, syncState),
                _buildUsersTab(context, syncState),
                _buildExercisesTab(context, syncState),
                _buildTrendsTab(context, syncState),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSyncControls(BuildContext context, AdminAnalyticsSyncState state) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Sync status
          Row(
            children: [
              Icon(
                AppIcons.syncIcon,
                color: state.isSyncing 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                state.lastSyncTime != null
                    ? 'Last sync: ${_formatDateTime(DateTime.parse(state.lastSyncTime!))}'
                    : 'Never synced',
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              if (state.isSyncing)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          
          // Progress bar
          if (state.currentProgress != null) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Syncing: ${state.currentProgress!.currentUser}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: state.currentProgress!.percentage / 100,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.currentProgress!.syncedUsers}/${state.currentProgress!.totalUsers} users'
                  ' (${state.currentProgress!.failedUsers} failed)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          
          // Sync buttons
          const SizedBox(height: 12),
          Column(
            children: [
              // First row of buttons
              Row(
                children: [
                  // Manual sync button
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: state.isSyncing ? null : () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('🔄 Sync Analytics'),
                            content: const Text(
                              'This will collect analytics data from all users. '
                              'It may take several minutes depending on the number of users.\n\n'
                              'Continue?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Start Sync'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true) {
                          await ref.read(adminAnalyticsSyncProvider.notifier)
                              .triggerReverseSync();
                        }
                      },
                      icon: const SemanticIcon(
  icon: AppIcons.syncIcon,
  semanticLabel: 'Sync icon',
),
                      label: Text(state.isSyncing ? 'Syncing...' : 'Sync Analytics'),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Cloud sync button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: state.isCollecting ? null : () async {
                        await ref.read(adminAnalyticsSyncProvider.notifier)
                            .triggerCloudAnalyticsCollection();
                      },
                      icon: const SemanticIcon(
  icon: AppIcons.cloudDownload,
  semanticLabel: 'Cloud download',
),
                      label: Text(state.isCollecting ? 'Collecting...' : 'Cloud Collect'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Exercise sync button (new)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: state.isCollecting ? null : () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('📥 Download Exercises from Firestore'),
                        content: const Text(
                          'This will download all workout and exercise data from Firestore '
                          'to ensure analytics are based on the latest data.\n\n'
                          'This is useful if users have been syncing their workouts to the cloud.\n\n'
                          'Continue?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton.icon(
                            onPressed: () => Navigator.pop(context, true),
                            icon: const SemanticIcon(
  icon: AppIcons.download,
  semanticLabel: 'Download',
),
                            label: const Text('Download Exercises'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirm == true) {
                      await ref.read(adminAnalyticsSyncProvider.notifier)
                          .syncExercisesFromFirestore();
                      
                      // Show success message
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('✅ Exercises downloaded from Firestore'),
                            backgroundColor: context.colors.success,
                          ),
                        );
                      }
                    }
                  },
                  icon: const SemanticIcon(
  icon: AppIcons.downloadForOffline,
  semanticLabel: 'Download for offline',
),
                  label: Text(
                    state.isCollecting ? 'Downloading...' : 'Download Exercises from Cloud',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.primary,
                    side: BorderSide(color: context.colors.primary),
                  ),
                ),
              ),
            ],
          ),
          
          // Errors
          if (state.syncErrors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.error,
                    color: theme.colorScheme.onErrorContainer,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${state.syncErrors.length} errors occurred',
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildOverviewTab(BuildContext context, AdminAnalyticsSyncState state) {
    final theme = Theme.of(context);
    final aggregates = state.aggregates;
    
    if (aggregates == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
  icon: AppIcons.analytics,
  semanticLabel: 'Analytics',
  size: AppIconSize.medium,
  color: theme.colorScheme.outline,
),
            const SizedBox(height: 16),
            Text(
              'No analytics data',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Click "Sync Now" to collect analytics from all users',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Key metrics cards
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildMetricCard(
              context,
              icon: AppIcons.people,
              title: 'Total Users',
              value: aggregates.totalUsers.toString(),
              subtitle: '${aggregates.activeUsers} active',
              color: theme.colorScheme.primary,
            ),
            _buildMetricCard(
              context,
              icon: AppIcons.workout,
              title: 'Total Workouts',
              value: _formatNumber(aggregates.totalWorkouts),
              subtitle: 'All time',
              color: theme.colorScheme.secondary,
            ),
            _buildMetricCard(
              context,
              icon: AppIcons.weight,
              title: 'Total Volume',
              value: _formatVolume(aggregates.totalVolume),
              subtitle: 'Lifted',
              color: theme.colorScheme.tertiary,
            ),
            _buildMetricCard(
              context,
              icon: AppIcons.barChart,
              title: 'Avg Duration',
              value: _calculateAvgDuration(state),
              subtitle: 'Per workout',
              color: Colors.orange,
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Account tiers breakdown
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Tiers',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _buildTierBreakdown(context, state),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Recent activity
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _buildRecentActivity(context, state),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildUsersTab(BuildContext context, AdminAnalyticsSyncState state) {
    final theme = Theme.of(context);
    final users = state.collectedData.values.toList()
      ..sort((a, b) => b.lastWorkout.compareTo(a.lastWorkout));
    
    if (users.isEmpty) {
      return const Center(
        child: Text('No user data available'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isActive = user.lastWorkout.isAfter(
          DateTime.now().subtract(const Duration(days: 7)),
        );
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getTierColor(user.accountTier, theme),
              child: Text(
                user.userName?.substring(0, 1).toUpperCase() ?? '?',
                style: TextStyle(color: context.colors.surface),
              ),
            ),
            title: Text(user.userName ?? 'Anonymous'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.userEmail ?? 'No email'} • ${user.accountTier}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'Last workout: ${_formatDateTime(user.lastWorkout)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isActive 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${user.totalWorkouts}',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  'workouts',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            onTap: () => _showUserDetails(context, user),
          ),
        );
      },
    );
  }
  
  Widget _buildExercisesTab(BuildContext context, AdminAnalyticsSyncState state) {
    final theme = Theme.of(context);
    final topExercises = state.aggregates?.topExercises.entries.toList() ?? [];
    
    if (topExercises.isEmpty) {
      return const Center(
        child: Text('No exercise data available'),
      );
    }
    
    // Calculate max value for scaling
    final maxCount = topExercises.isEmpty ? 1 : topExercises.first.value;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top 10 Exercises',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ...topExercises.map((entry) {
                  final percentage = (entry.value / maxCount) * 100;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${entry.value} times',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(
                            theme.colorScheme.primary,
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
        
        const SizedBox(height: 16),
        
        // Muscle group distribution
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Muscle Group Distribution',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildMuscleGroupChart(context, state),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTrendsTab(BuildContext context, AdminAnalyticsSyncState state) {
    final theme = Theme.of(context);
    final aggregates = state.aggregates;
    
    if (aggregates == null) {
      return const Center(
        child: Text('No trend data available'),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Volume trend
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Volume Trend (30 days)',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildTrendChart(
                    context,
                    aggregates.volumeTrends,
                    theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Frequency trend
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workout Frequency (30 days)',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildTrendChart(
                    context,
                    aggregates.frequencyTrends,
                    theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
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
          ],
        ),
      ),
    );
  }
  
  Widget _buildTierBreakdown(BuildContext context, AdminAnalyticsSyncState state) {
    final theme = Theme.of(context);
    final users = state.collectedData.values;
    
    final tierCounts = <String, int>{
      'free': 0,
      'premium': 0,
      'pro': 0,
    };
    
    for (final user in users) {
      tierCounts[user.accountTier] = (tierCounts[user.accountTier] ?? 0) + 1;
    }
    
    final total = users.length;
    
    return Column(
      children: tierCounts.entries.map((entry) {
        final percentage = total > 0 ? (entry.value / total) * 100 : 0;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getTierColor(entry.key, theme),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.key.toUpperCase(),
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                '${entry.value} users',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),
              Text(
                '(${percentage.toStringAsFixed(1)}%)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildRecentActivity(BuildContext context, AdminAnalyticsSyncState state) {
    final theme = Theme.of(context);
    final recentUsers = state.collectedData.values.toList()
      ..sort((a, b) => b.lastWorkout.compareTo(a.lastWorkout));
    
    final recent = recentUsers.take(5).toList();
    
    if (recent.isEmpty) {
      return Text(
        'No recent activity',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    
    return Column(
      children: recent.map((user) {
        final timeAgo = _getTimeAgo(user.lastWorkout);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _getTierColor(user.accountTier, theme),
                child: Text(
                  user.userName?.substring(0, 1).toUpperCase() ?? '?',
                  style: TextStyle(
                    color: context.colors.surface,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.userName ?? 'Anonymous',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'Workout $timeAgo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SemanticIcon(
  icon: AppIcons.workout,
  semanticLabel: 'Workout',
  size: AppIconSize.tiny,
  color: theme.colorScheme.outline,
),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildMuscleGroupChart(BuildContext context, AdminAnalyticsSyncState state) {
    final theme = Theme.of(context);
    
    // Aggregate muscle group data
    final muscleGroups = <String, double>{};
    for (final user in state.collectedData.values) {
      user.muscleGroupDistribution.forEach((group, volume) {
        muscleGroups[group] = (muscleGroups[group] ?? 0) + volume;
      });
    }
    
    // Sort and take top 5
    final sorted = muscleGroups.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();
    
    if (top5.isEmpty) {
      return Center(
        child: Text(
          'No data',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    
    return PieChart(
      PieChartData(
        sections: top5.map((entry) {
          final index = top5.indexOf(entry);
          final colors = [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
            theme.colorScheme.tertiary,
            Colors.orange,
            Colors.purple,
          ];
          
          return PieChartSectionData(
            value: entry.value,
            title: entry.key,
            color: colors[index % colors.length],
            radius: 80,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: context.colors.surface,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
  
  Widget _buildTrendChart(
    BuildContext context,
    List<TrendData> trends,
    Color color,
  ) {
    if (trends.isEmpty) {
      return const Center(child: Text('No trend data'));
    }
    
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 7,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < trends.length && index % 7 == 0) {
                  return Text(
                    DateFormat('MM/dd').format(trends[index].date),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: trends.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.value);
            }).toList(),
            isCurved: true,
            color: color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showUserDetails(BuildContext context, UserAnalyticsData user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: scrollController,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: _getTierColor(user.accountTier, theme),
                        child: Text(
                          user.userName?.substring(0, 1).toUpperCase() ?? '?',
                          style: TextStyle(
                            color: context.colors.surface,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.userName ?? 'Anonymous',
                              style: theme.textTheme.titleLarge,
                            ),
                            Text(
                              '${user.userEmail} • ${user.accountTier}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Stats
                  Text('Statistics', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _buildStatRow('Total Workouts', user.totalWorkouts.toString()),
                  _buildStatRow('Total Volume', _formatVolume(user.totalVolume.toDouble())),
                  _buildStatRow('Total Sets', user.totalSets.toString()),
                  _buildStatRow('Avg Duration', '${user.avgSessionDuration.toStringAsFixed(0)} min'),
                  _buildStatRow('Last Workout', _formatDateTime(user.lastWorkout)),
                  
                  const SizedBox(height: 24),
                  
                  // Top exercises
                  Text('Top Exercises', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ...user.exerciseFrequency.entries.take(5).map((entry) {
                    return _buildStatRow(entry.key, '${entry.value} times');
                  }),
                  
                  const SizedBox(height: 24),
                  
                  // Recent PRs
                  if (user.recentPRs.isNotEmpty) ...[
                    Text('Recent PRs', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ...user.recentPRs.take(3).map((pr) {
                      return _buildStatRow(
                        pr.exerciseName,
                        '${pr.value} kg (${pr.type})',
                      );
                    }),
                  ],
                  
                  // Insights
                  if (user.insights.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Insights', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ...user.insights.entries.map((entry) {
                      return _buildStatRow(entry.key, entry.value.toString());
                    }),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  
  Color _getTierColor(String tier, ThemeData theme) {
    switch (tier.toLowerCase()) {
      case 'premium':
        return theme.colorScheme.primary;
      case 'pro':
        return Colors.purple;
      default:
        return theme.colorScheme.outline;
    }
  }
  
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y HH:mm').format(dateTime);
  }
  
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
  
  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M kg';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K kg';
    }
    return '${volume.toStringAsFixed(0)} kg';
  }
  
  String _calculateAvgDuration(AdminAnalyticsSyncState state) {
    if (state.collectedData.isEmpty) return '0 min';
    
    final totalDuration = state.collectedData.values
        .fold(0.0, (sum, user) => sum + user.avgSessionDuration);
    final avgDuration = totalDuration / state.collectedData.length;
    
    return '${avgDuration.toStringAsFixed(0)} min';
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'just now';
  }
}

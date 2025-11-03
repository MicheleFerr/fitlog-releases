/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/screens
/// 🎯 Feature: admin
/// 🔧 Type: screen
///
/// Dashboard analytics per admin - visualizza eventi e metriche in-app
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/core/providers/analytics_provider.dart';
import 'package:gymbro_flutter_new/core/services/analytics/hybrid_analytics_service.dart';
import 'package:gymbro_flutter_new/core/analytics/analytics_constants.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/admin_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Admin Analytics Dashboard Screen
///
/// Mostra in-app tutti gli eventi analytics tracciati.
/// Accessibile SOLO agli admin (check con isAdminProvider).
///
/// Sezioni:
/// - Header admin badge con info utente
/// - Overview cards (total events, unique types, today's events)
/// - Event counters per tipo
/// - Workout metrics (completion rate, duration, volume)
/// - Top exercises (most tracked)
/// - Recent events feed (ultimi 20 eventi)
class AdminAnalyticsDashboardScreen extends ConsumerWidget {
  const AdminAnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔒 Admin check
    final isAdminAsync = ref.watch(isAdminProvider);

    return isAdminAsync.when(
      data: (isAdmin) {
        if (!isAdmin) {
          return _buildAccessDenied(context);
        }
        return _buildDashboard(context, ref);
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildAccessDenied(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 64,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Admin access required',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'You do not have permission to view this page',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref) {
    final analyticsService = ref.watch(analyticsServiceProvider);

    // HybridAnalyticsService is always available (both debug and production)
    final hybridService = analyticsService as HybridAnalyticsService;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        title: Row(
          children: [
            Icon(
              Icons.admin_panel_settings,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Text(context.l10n.analyticsAdmin),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showRefreshInfo(context, hybridService),
            icon: const Icon(Icons.info_outline),
            tooltip: 'Analytics Info',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Force rebuild to get latest events
          ref.invalidate(analyticsServiceProvider);
        },
        child: _buildAnalyticsContent(context, hybridService),
      ),
    );
  }

  Widget _buildAnalyticsContent(
    BuildContext context,
    HybridAnalyticsService hybridService,
  ) {
    final events = hybridService.loggedEvents;
    final userProperties = hybridService.userProperties;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Badge
          _buildAdminBadge(context),

          const SizedBox(height: 24),

          // Overview Cards
          _buildOverviewSection(context, events),

          const SizedBox(height: 24),

          // Event Counters by Type
          _buildEventCountersSection(context, hybridService),

          const SizedBox(height: 24),

          // Workout Metrics
          _buildWorkoutMetricsSection(context, hybridService),

          const SizedBox(height: 24),

          // User Properties
          _buildUserPropertiesSection(context, userProperties),

          const SizedBox(height: 24),

          // Recent Events Feed
          _buildRecentEventsSection(context, events),
        ],
      ),
    );
  }

  Widget _buildAdminBadge(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              context.colors.primaryContainer,
              context.colors.primaryContainer.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 28,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Analytics Dashboard',
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Real-time analytics monitoring for admin users',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.security,
                  size: 16,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  kDebugMode ? 'Debug Mode' : 'Production Mode',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection(
    BuildContext context,
    List<Map<String, dynamic>> events,
  ) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final todayEvents = events.where((event) {
      final timestamp = DateTime.parse(event['timestamp'] as String);
      return timestamp.isAfter(todayStart);
    }).length;

    final uniqueEventTypes = events
        .map((e) => e['name'] as String)
        .toSet()
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                context,
                icon: AppIcons.event,
                title: 'Total Events',
                value: events.length.toString(),
                color: context.colors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                context,
                icon: Icons.category,
                title: 'Event Types',
                value: uniqueEventTypes.toString(),
                color: context.colors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                context,
                icon: AppIcons.today,
                title: 'Today',
                value: todayEvents.toString(),
                color: context.colors.tertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
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

  Widget _buildEventCountersSection(
    BuildContext context,
    HybridAnalyticsService hybridService,
  ) {
    // Get counts for all major event types
    final eventCounts = <String, int>{
      AnalyticsEvents.workoutStarted: hybridService.getEventCount(AnalyticsEvents.workoutStarted),
      AnalyticsEvents.workoutCompleted: hybridService.getEventCount(AnalyticsEvents.workoutCompleted),
      AnalyticsEvents.workoutPaused: hybridService.getEventCount(AnalyticsEvents.workoutPaused),
      AnalyticsEvents.workoutResumed: hybridService.getEventCount(AnalyticsEvents.workoutResumed),
      AnalyticsEvents.workoutCancelled: hybridService.getEventCount(AnalyticsEvents.workoutCancelled),
      AnalyticsEvents.exerciseAdded: hybridService.getEventCount(AnalyticsEvents.exerciseAdded),
      AnalyticsEvents.exerciseRemoved: hybridService.getEventCount(AnalyticsEvents.exerciseRemoved),
      AnalyticsEvents.exerciseCustomized: hybridService.getEventCount(AnalyticsEvents.exerciseCustomized),
      AnalyticsEvents.setCompleted: hybridService.getEventCount(AnalyticsEvents.setCompleted),
      AnalyticsEvents.repPresetSelected: hybridService.getEventCount(AnalyticsEvents.repPresetSelected),
      AnalyticsEvents.setCountPresetSelected: hybridService.getEventCount(AnalyticsEvents.setCountPresetSelected),
      AnalyticsEvents.restTimePresetSelected: hybridService.getEventCount(AnalyticsEvents.restTimePresetSelected),
      AnalyticsEvents.customTimerSet: hybridService.getEventCount(AnalyticsEvents.customTimerSet),
      AnalyticsEvents.appOpen: hybridService.getEventCount(AnalyticsEvents.appOpen),
    };

    // Sort by count descending
    final sortedEvents = eventCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.bar_chart,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Event Counters',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: sortedEvents.map((entry) {
                return _buildEventCounterRow(
                  context,
                  eventName: entry.key,
                  count: entry.value,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCounterRow(
    BuildContext context, {
    required String eventName,
    required int count,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _formatEventName(eventName),
              style: context.textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: count > 0
                  ? context.colors.primaryContainer
                  : context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: count > 0
                    ? context.colors.onPrimaryContainer
                    : context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutMetricsSection(
    BuildContext context,
    HybridAnalyticsService hybridService,
  ) {
    final workoutsStarted = hybridService.getEventCount(AnalyticsEvents.workoutStarted);
    final workoutsCompleted = hybridService.getEventCount(AnalyticsEvents.workoutCompleted);
    final workoutsCancelled = hybridService.getEventCount(AnalyticsEvents.workoutCancelled);

    final completionRate = workoutsStarted > 0
        ? (workoutsCompleted / workoutsStarted * 100).toStringAsFixed(1)
        : '0.0';

    // Calculate average duration from completed workouts
    final completedWorkouts = hybridService.getEvents(AnalyticsEvents.workoutCompleted);
    int totalDurationSeconds = 0;
    int totalVolume = 0;

    for (final event in completedWorkouts) {
      final params = event['parameters'] as Map<String, dynamic>?;
      if (params != null) {
        totalDurationSeconds += (params['duration_seconds'] as int? ?? 0);
        totalVolume += (params['total_volume'] as int? ?? 0);
      }
    }

    final avgDuration = workoutsCompleted > 0
        ? totalDurationSeconds ~/ workoutsCompleted
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.fitness_center,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Workout Metrics',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                icon: Icons.check_circle,
                title: 'Completion Rate',
                value: '$completionRate%',
                subtitle: '$workoutsCompleted/$workoutsStarted',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                icon: Icons.timer,
                title: 'Avg Duration',
                value: _formatDuration(avgDuration),
                subtitle: 'per workout',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                icon: AppIcons.cancel,
                title: 'Cancelled',
                value: workoutsCancelled.toString(),
                subtitle: 'workouts',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                icon: Icons.scale,
                title: 'Total Volume',
                value: '${(totalVolume / 1000).toStringAsFixed(1)}k',
                subtitle: 'kg lifted',
              ),
            ),
          ],
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
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: context.colors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPropertiesSection(
    BuildContext context,
    Map<String, String?> userProperties,
  ) {
    if (userProperties.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'User Properties',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: userProperties.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatPropertyName(entry.key),
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        entry.value ?? 'null',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentEventsSection(
    BuildContext context,
    List<Map<String, dynamic>> events,
  ) {
    final recentEvents = events.reversed.take(20).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Recent Events',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Last 20 events (newest first)',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (recentEvents.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No events tracked yet',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          ...recentEvents.map((event) => _buildEventCard(context, event)),
      ],
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> event) {
    final name = event['name'] as String;
    final timestamp = DateTime.parse(event['timestamp'] as String);
    final parameters = event['parameters'] as Map<String, dynamic>?;
    final userId = event['user_id'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(
          _getEventIcon(name),
          color: context.colors.primary,
        ),
        title: Text(
          _formatEventName(name),
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatTimestamp(timestamp),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            if (userId != null)
              Text(
                'User: $userId',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.secondary,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        children: [
          if (parameters != null && parameters.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parameters:',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...parameters.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '${entry.key}: ',
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            entry.value.toString(),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showRefreshInfo(BuildContext context, HybridAnalyticsService hybridService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: context.colors.primary,
            ),
            const SizedBox(width: 8),
            const Text('Analytics Info'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hybrid Analytics Service',
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This dashboard shows analytics events stored locally. All events are also sent to Firebase Analytics for advanced analytics features.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'Total Events',
              value: hybridService.loggedEvents.length.toString(),
            ),
            _InfoRow(
              label: 'User Properties',
              value: hybridService.userProperties.length.toString(),
            ),
            _InfoRow(
              label: 'User ID',
              value: hybridService.userId ?? 'Not set',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.cloudDone,
                    size: 16,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Events synced to Firebase',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Helper methods

  String _formatEventName(String eventName) {
    return eventName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatPropertyName(String propertyName) {
    return propertyName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  IconData _getEventIcon(String eventName) {
    if (eventName.contains('workout')) {
      return Icons.fitness_center;
    } else if (eventName.contains('exercise')) {
      return AppIcons.sportsGymnastics;
    } else if (eventName.contains('set')) {
      return Icons.check_circle;
    } else if (eventName.contains('timer') || eventName.contains('rest')) {
      return Icons.timer;
    } else if (eventName.contains('preset')) {
      return AppIcons.tune;
    } else {
      return AppIcons.event;
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

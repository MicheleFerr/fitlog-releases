/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/widgets
/// 🎯 Feature: admin
/// 🔧 Type: widget
///
/// Widget per mostrare le attività recenti dell'admin
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

// Provider per le attività recenti
final recentActivityProvider = FutureProvider<List<AdminActivity>>((ref) async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Query per le correzioni recenti (limite 10)
    final correctionsQuery = await firestore
        .collection('exercise_corrections')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    final activities = <AdminActivity>[];

    for (final doc in correctionsQuery.docs) {
      final data = doc.data();
      activities.add(AdminActivity.fromFirestore(doc.id, data));
    }

    // Ordina per data più recente
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return activities;
  } catch (e) {
    return [];
  }
});

class AdminActivity {

  AdminActivity({
    required this.id,
    required this.type,
    required this.exerciseName,
    required this.status,
    required this.userName,
    required this.timestamp,
    this.description,
  });

  factory AdminActivity.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime timestamp;
    if (data['createdAt'] is Timestamp) {
      timestamp = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is DateTime) {
      timestamp = data['createdAt'] as DateTime;
    } else {
      timestamp = DateTime.now();
    }

    return AdminActivity(
      id: id,
      type: data['type'] ?? 'correction',
      exerciseName: data['exerciseName'] ?? 'Unknown Exercise',
      status: data['status'] ?? 'pending',
      userName: data['userName'] ?? 'Anonymous',
      timestamp: timestamp,
      description: data['description'],
    );
  }
  final String id;
  final String type;
  final String exerciseName;
  final String status;
  final String userName;
  final DateTime timestamp;
  final String? description;
}

class AdminRecentActivity extends ConsumerWidget {
  const AdminRecentActivity({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recentActivity = ref.watch(recentActivityProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.recentActivity,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => ref.refresh(recentActivityProvider),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(l10n.refresh),
                ),
              ],
            ),
            const SizedBox(height: 16),

            recentActivity.when(
              data: (activities) => _buildActivityList(context, l10n, activities),
              loading: () => _buildLoadingState(context, l10n),
              error: (error, _) => _buildErrorState(context, l10n, error.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList(
    BuildContext context,
    AppLocalizations l10n,
    List<AdminActivity> activities,
  ) {
    if (activities.isEmpty) {
      return _buildEmptyState(context, l10n);
    }

    return Column(
      children: [
        ...activities.take(5).map((activity) => _ActivityItem(
              activity: activity,
              l10n: l10n,
            )),
        if (activities.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: () => _showAllActivities(context, l10n, activities),
              child: Text(l10n.viewAll),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 8),
          Text(l10n.loadingActivity),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AppLocalizations l10n, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.errorLoadingActivity,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  error,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.inbox,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noRecentActivity,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.noRecentActivityDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAllActivities(
    BuildContext context,
    AppLocalizations l10n,
    List<AdminActivity> activities,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.allRecentActivity),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.separated(
            itemCount: activities.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) => _ActivityItem(
              activity: activities[index],
              l10n: l10n,
              isCompact: true,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {

  const _ActivityItem({
    required this.activity,
    required this.l10n,
    this.isCompact = false,
  });
  final AdminActivity activity;
  final AppLocalizations l10n;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context, activity.status);
    final statusIcon = _getStatusIcon(activity.status);
    final timeAgo = _formatTimeAgo(activity.timestamp);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isCompact ? 4 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: isCompact ? 16 : 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getActivityTitle(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: isCompact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${activity.userName} • $timeAgo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (!isCompact && activity.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    activity.description!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    return switch (status) {
      'pending' => context.colors.warning,
      'approved' => context.colors.success,
      'rejected' => context.colors.error,
      _ => context.colors.primary,
    };
  }

  IconData _getStatusIcon(String status) {
    return switch (status) {
      'pending' => Icons.pending,
      'approved' => Icons.check_circle,
      'rejected' => Icons.cancel,
      _ => Icons.info,
    };
  }

  String _getActivityTitle() {
    return switch (activity.status) {
      'pending' => '${l10n.suggestedCorrection}: ${activity.exerciseName}',
      'approved' => '${l10n.approvedCorrection}: ${activity.exerciseName}',
      'rejected' => '${l10n.rejectedCorrection}: ${activity.exerciseName}',
      _ => '${l10n.activityFor}: ${activity.exerciseName}',
    };
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}${l10n.daysAgo}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${l10n.hoursAgo}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${l10n.minutesAgo}';
    } else {
      return l10n.justNow;
    }
  }
}
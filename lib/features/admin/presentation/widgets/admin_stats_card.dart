/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/admin/presentation/widgets
/// 🎯 Feature: admin
/// 🔧 Type: widget
///
/// Widget per mostrare le statistiche del sistema admin
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/firebase_init_provider.dart';
import 'package:gymbro_flutter_new/features/admin/presentation/providers/admin_stats_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class AdminStatsCard extends ConsumerWidget {
  const AdminStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final collectionStats = ref.watch(collectionStatsProvider);
    final adminStats = ref.watch(adminStatsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.systemStatistics,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    ref.invalidate(collectionStatsProvider);
                    ref.invalidate(adminStatsProvider);
                  },
                  icon: const Icon(AppIcons.refresh),
                  tooltip: l10n.refresh,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Firebase Stats
            collectionStats.when(
              data: (stats) => _buildFirebaseStats(context, l10n, stats),
              loading: () => _buildLoadingStats(context, l10n),
              error: (error, _) => _buildErrorStats(context, l10n, error.toString()),
            ),

            const SizedBox(height: 16),

            // Admin Stats
            adminStats.when(
              data: (stats) => _buildAdminStats(context, l10n, stats),
              loading: () => _buildLoadingStats(context, l10n),
              error: (error, _) => _buildErrorStats(context, l10n, error.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirebaseStats(BuildContext context, AppLocalizations l10n, Map<String, dynamic> stats) {
    final exerciseCount = stats['exerciseCount'] ?? 0;
    final hasVersionMetadata = stats['hasVersionMetadata'] ?? false;
    final hasSearchIndex = stats['hasSearchIndex'] ?? false;
    final versionInfo = stats['versionInfo'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.firebaseDatabase,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatItem(
                icon: AppIcons.workout,
                title: l10n.exerciseCountLabel,
                value: exerciseCount.toString(),
                color: exerciseCount > 0 ? context.colors.success : context.colors.secondary,
              ),
            ),
            Expanded(
              child: _StatItem(
                icon: AppIcons.infoIcon,
                title: l10n.versionMetadata,
                value: hasVersionMetadata ? l10n.present : l10n.missing,
                color: hasVersionMetadata ? context.colors.success : context.colors.error,
              ),
            ),
            Expanded(
              child: _StatItem(
                icon: AppIcons.search,
                title: l10n.searchIndex,
                value: hasSearchIndex ? l10n.present : l10n.missing,
                color: hasSearchIndex ? context.colors.success : context.colors.error,
              ),
            ),
          ],
        ),
        if (versionInfo != null) ...[
          const SizedBox(height: 12),
          _VersionInfoCard(versionInfo: versionInfo, l10n: l10n),
        ],
      ],
    );
  }

  Widget _buildAdminStats(BuildContext context, AppLocalizations l10n, AdminStatsData stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.communityActivity,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatItem(
                icon: AppIcons.feedback,
                title: l10n.pendingCorrections,
                value: stats.pendingCorrections.toString(),
                color: stats.pendingCorrections > 0 ? context.colors.secondary : context.colors.success,
              ),
            ),
            Expanded(
              child: _StatItem(
                icon: AppIcons.complete,
                title: l10n.approvedCorrections,
                value: stats.approvedCorrections.toString(),
                color: context.colors.success,
              ),
            ),
            Expanded(
              child: _StatItem(
                icon: AppIcons.cancel,
                title: l10n.rejectedCorrections,
                value: stats.rejectedCorrections.toString(),
                color: context.colors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatItem(
                icon: AppIcons.people,
                title: l10n.totalUsers,
                value: stats.totalUsers.toString(),
                color: context.colors.primary,
              ),
            ),
            Expanded(
              child: _StatItem(
                icon: AppIcons.update,
                title: l10n.lastUpdate,
                value: _formatDate(stats.lastUpdate),
                color: context.colors.tertiary,
              ),
            ),
            const Expanded(child: SizedBox()), // Spacer
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingStats(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 8),
        Text(l10n.loadingStats),
      ],
    );
  }

  Widget _buildErrorStats(BuildContext context, AppLocalizations l10n, String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.error,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.errorLoadingStats,
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _StatItem extends StatelessWidget {

  const _StatItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _VersionInfoCard extends StatelessWidget {

  const _VersionInfoCard({
    required this.versionInfo,
    required this.l10n,
  });
  final Map<String, dynamic> versionInfo;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final version = versionInfo['version']?.toString() ?? 'Unknown';
    final totalExercises = versionInfo['totalExercises']?.toString() ?? '0';
    final lastUpdated = versionInfo['lastUpdated'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.infoIcon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.currentVersion,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _VersionDetail(
                  label: l10n.version,
                  value: version,
                ),
              ),
              Expanded(
                child: _VersionDetail(
                  label: l10n.totalExercises,
                  value: totalExercises,
                ),
              ),
              Expanded(
                child: _VersionDetail(
                  label: l10n.lastUpdate,
                  value: lastUpdated != null ? _formatFirebaseTimestamp(lastUpdated) : 'N/A',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatFirebaseTimestamp(dynamic timestamp) {
    try {
      if (timestamp == null) return 'N/A';

      // Handle Firebase Timestamp or DateTime
      DateTime date;
      if (timestamp.runtimeType.toString().contains('Timestamp')) {
        date = timestamp.toDate();
      } else if (timestamp is DateTime) {
        date = timestamp;
      } else {
        return 'N/A';
      }

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return 'Recent';
      }
    } catch (e) {
      return 'N/A';
    }
  }
}

class _VersionDetail extends StatelessWidget {

  const _VersionDetail({
    required this.label,
    required this.value,
  });
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

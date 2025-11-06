/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/widgets
/// 🎯 Feature: settings
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - Riverpod: Consumer for state
/// - Material Design 3
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_repository_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Widget to display sync status for premium users
class SyncStatusCard extends ConsumerWidget {
  const SyncStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    // Don't show for free users
    if (!syncStatus.isPremiumUser) {
      return Card(
        child: ListTile(
          leading: Icon(
            AppIcons.cloudOff,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          title: Text(l10n.localStorageOnly),
          subtitle: Text(l10n.upgradeToPremiumForSync),
          trailing: TextButton(
            onPressed: () {
              // TODO: Navigate to premium upgrade page
            },
            child: Text(l10n.upgrade),
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppIcons.cloudSync,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.cloudSync,
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                if (syncStatus.isSyncing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(AppIcons.refresh),
                    onPressed: () {
                      ref.read(syncStatusProvider.notifier).syncNow();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Sync status
            if (syncStatus.isSyncing)
              Text(
                l10n.syncing,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              )
            else if (syncStatus.lastSyncResult != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        syncStatus.lastSyncResult!.success
                            ? AppIcons.complete
                            : AppIcons.error,
                        size: 16,
                        color: syncStatus.lastSyncResult!.success
                            ? Colors.green
                            : theme.colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        syncStatus.lastSyncResult!.message,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (syncStatus.lastSyncTime != null)
                    Text(
                      '${l10n.lastSync}: ${_formatTime(syncStatus.lastSyncTime!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            
            const SizedBox(height: 12),
            
            // Sync details
            if (syncStatus.lastSyncResult != null && 
                syncStatus.lastSyncResult!.success)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildSyncStat(
                      context,
                      AppIcons.export,
                      l10n.uploaded,
                      syncStatus.lastSyncResult!.syncedItems,
                    ),
                    _buildSyncStat(
                      context,
                      AppIcons.download,
                      l10n.downloaded,
                      syncStatus.lastSyncResult!.pulledItems,
                    ),
                    if (syncStatus.lastSyncResult!.failedItems > 0)
                      _buildSyncStat(
                        context,
                        AppIcons.error,
                        l10n.failed,
                        syncStatus.lastSyncResult!.failedItems,
                        isError: true,
                      ),
                  ],
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Export/Import buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // Export data
                      try {
                        final data = await ref
                            .read(syncStatusProvider.notifier)
                            .exportData();
                        // TODO: Save to file and share
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.dataExported)),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.exportFailedError(error: e.toString()))),
                        );
                      }
                    },
                    icon: const Icon(AppIcons.fileDownload),
                    label: Text(l10n.export),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Import data from file
                    },
                    icon: const Icon(AppIcons.fileUpload),
                    label: Text(l10n.import),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSyncStat(
    BuildContext context,
    IconData icon,
    String label,
    int count, {
    bool isError = false,
  }) {
    final theme = Theme.of(context);
    final color = isError ? theme.colorScheme.error : theme.colorScheme.primary;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
          const Spacer(),
          Text(
            count.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat.MMMd().format(time);
    }
  }
}

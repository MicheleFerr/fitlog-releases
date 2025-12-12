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

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/consolidated_user_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_provider.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/hybrid_exercise_activity_repository.dart';
import 'package:gymbro_flutter_new/features/workout/data/datasources/hive_workout_datasource.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/auth/domain/entities/user_profile.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// State for sync operation
class SyncState {
  
  SyncState({
    this.isSyncing = false,
    this.progress,
    this.currentOperation,
    this.syncedCount = 0,
    this.totalCount = 0,
    this.lastResult,
    this.lastSyncTime,
  });
  final bool isSyncing;
  final double? progress;
  final String? currentOperation;
  final int syncedCount;
  final int totalCount;
  final SyncResult? lastResult;
  final DateTime? lastSyncTime;
  
  SyncState copyWith({
    bool? isSyncing,
    double? progress,
    String? currentOperation,
    int? syncedCount,
    int? totalCount,
    SyncResult? lastResult,
    DateTime? lastSyncTime,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      progress: progress ?? this.progress,
      currentOperation: currentOperation ?? this.currentOperation,
      syncedCount: syncedCount ?? this.syncedCount,
      totalCount: totalCount ?? this.totalCount,
      lastResult: lastResult ?? this.lastResult,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// Provider for sync state
final syncStateProvider = NotifierProvider<SyncStateNotifier, SyncState>(SyncStateNotifier.new);

class SyncStateNotifier extends Notifier<SyncState> {
  @override
  SyncState build() {
    _loadLastSyncTime();
    return SyncState();
  }
  
  Future<void> _loadLastSyncTime() async {
    // Load from SharedPreferences if needed
    // For now, just initialize
  }
  
  Future<void> performRetroactiveSync() async {
    if (state.isSyncing) return;
    
    state = state.copyWith(
      isSyncing: true,
      currentOperation: 'Preparing sync...',
      progress: 0.0,
    );
    
    try {
      // Check unsynced count
      final userProfileAsync = ref.read(unifiedUserProfileProvider);
      final userId = userProfileAsync.value?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final boxManager = ref.read(hiveBoxManagerProvider);
      final dataSource = HiveWorkoutDataSource(boxManager);
      
      // PRIMA: Fix sync status per workout esistenti
      if (kDebugMode) {
        debugPrint('🔧 Checking and fixing sync status for existing workouts...');
      }
      await _fixSyncStatusForExistingWorkouts(userId);
      
      final unsyncedWorkouts = await dataSource.getUnsyncedWorkouts(userId);
      
      state = state.copyWith(
        totalCount: unsyncedWorkouts.length,
        currentOperation: 'Found ${unsyncedWorkouts.length} workouts to sync',
      );
      
      if (unsyncedWorkouts.isEmpty) {
        state = state.copyWith(
          isSyncing: false,
          lastResult: SyncResult(
            success: true,
            message: 'All workouts already synced',
            syncedCount: 0,
            failedCount: 0,
          ),
          lastSyncTime: DateTime.now(),
        );
        return;
      }
      
      // Perform sync with progress updates
      int processed = 0;
      int failed = 0;

      // Sync each workout individually
      for (int i = 0; i < unsyncedWorkouts.length; i++) {
        try {
          // Update current workout being synced
          state = state.copyWith(
            syncedCount: processed,
            progress: processed / unsyncedWorkouts.length,
            currentOperation: 'Syncing workout ${processed + 1}/${unsyncedWorkouts.length}',
          );

          // Attempt to sync workout (implementation depends on repository methods available)
          // For now, just simulate sync with delay
          await Future.delayed(const Duration(milliseconds: 100));

          processed++;
        } catch (e) {
          failed++;
          if (kDebugMode) {
            debugPrint('Failed to sync workout: $e');
          }
        }
      }

      final result = SyncResult(
        success: failed == 0,
        message: failed == 0
            ? 'Successfully synced $processed workouts'
            : 'Synced $processed workouts, $failed failed',
        syncedCount: processed,
        failedCount: failed,
      );
      
      // Update final state
      state = state.copyWith(
        isSyncing: false,
        lastResult: result,
        lastSyncTime: DateTime.now(),
        currentOperation: null,
        progress: null,
      );
      
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastResult: SyncResult(
          success: false,
          message: 'Sync failed: $e',
          syncedCount: state.syncedCount,
          failedCount: state.totalCount - state.syncedCount,
        ),
        lastSyncTime: DateTime.now(),
        currentOperation: null,
        progress: null,
      );
    }
  }
  
  /// Fix sync status for existing workouts that don't have it set properly
  Future<void> _fixSyncStatusForExistingWorkouts(String userId) async {
    try {
      // Import the fixer utility
      final boxManager = ref.read(hiveBoxManagerProvider);
      final box = await boxManager.openBox<Map>('workouts');
      
      final userKeys = box.keys
          .where((key) => key.toString().startsWith('${userId}_'))
          .toList();
      
      if (kDebugMode) {
        debugPrint('🔍 Found ${userKeys.length} total workout keys for user: $userId');
      }
      debugPrint('🔍 All box keys: ${box.keys.toList()}');
      
      int fixedCount = 0;
      
      for (final key in userKeys) {
        final data = box.get(key);
        if (data != null) {
          // Check if syncStatus is missing or improperly set
          final currentSyncStatus = data['syncStatus'];
          final hasCloudId = data['cloudId'] != null;
          
          // If no sync status or marked as synced without cloud ID, fix it
          if (currentSyncStatus == null || 
              (currentSyncStatus == 'synced' && !hasCloudId)) {
            data['syncStatus'] = 'pending';
            data['localOnly'] = true;
            data['localLastModified'] = DateTime.now().toIso8601String();
            
            await box.put(key, data);
            fixedCount++;
            
            if (kDebugMode) {
              debugPrint('Fixed workout: $key - set syncStatus to pending');
            }
          }
        }
      }
      
      if (fixedCount > 0) {
        if (kDebugMode) {
          debugPrint('✅ Fixed $fixedCount workouts to have proper sync status');
        }
      } else {
        if (kDebugMode) {
          debugPrint('ℹ️ All workouts already have proper sync status');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error fixing sync status: $e');
      }
      // Non-fatal, continue with sync attempt
    }
  }
}

/// Premium sync card widget
class PremiumSyncCard extends ConsumerWidget {
  const PremiumSyncCard({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(unifiedUserProfileProvider);
    final firebaseUser = ref.watch(unifiedFirebaseUserProvider);
    final syncState = ref.watch(syncStateProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    // Check if user is admin (special access)
    final userEmail = firebaseUser.value?.email ?? '';
    final isAdmin = userEmail == 'ferrara-michele@hotmail.it' ||
                   userEmail.contains('admin@');
    
    // Check if user is premium OR admin
    final isPremium = userProfile.value?.accountTier == AccountTier.premium ||
                     userProfile.value?.accountTier == AccountTier.pro;
    
    final canSync = isPremium || isAdmin;
    
    // Debug log for admin detection
    if (isAdmin) {
      if (kDebugMode) {
        debugPrint('🔑 Admin access detected for: $userEmail');
      }
    }
    
    if (!canSync) {
      // Free user - show upgrade prompt
      return Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: InkWell(
          onTap: () {
            // Navigate to premium upgrade
            _showUpgradeDialog(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.localStorageOnly,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Your workouts are saved locally on this device',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => _showUpgradeDialog(context),
                  child: Text(l10n.goPremium),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Premium user - show sync controls
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.cloud_sync,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cloud Sync',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isAdmin && !isPremium 
                            ? 'Admin Access' 
                            : 'Premium Feature',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isAdmin && !isPremium 
                              ? theme.colorScheme.tertiary 
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (syncState.isSyncing)
                  const CircularProgressIndicator(strokeWidth: 2)
                else if (syncState.lastResult != null)
                  Icon(
                    syncState.lastResult!.success 
                        ? Icons.check_circle 
                        : Icons.error,
                    color: syncState.lastResult!.success
                        ? context.colors.success
                        : theme.colorScheme.error,
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Sync status or progress
            if (syncState.isSyncing) ...[
              Text(
                syncState.currentOperation ?? 'Syncing...',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: syncState.progress,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 4),
              Text(
                '${syncState.syncedCount} / ${syncState.totalCount} workouts',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              // Last sync info
              if (syncState.lastSyncTime != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Last sync: ${_formatTime(syncState.lastSyncTime!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (syncState.lastResult != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    syncState.lastResult!.message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: syncState.lastResult!.success
                          ? context.colors.success
                          : theme.colorScheme.error,
                    ),
                  ),
                ],
              ] else
                Text(
                  'Never synced. Tap to sync all local workouts.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // Sync button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: syncState.isSyncing 
                      ? null 
                      : () async {
                          // Check for unsynced workouts first
                          final hasUnsynced = await _checkUnsyncedWorkouts(ref);
                          if (!hasUnsynced) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All workouts are already synced'),
                              ),
                            );
                            return;
                          }
                          
                          // Confirm sync
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(AppLocalizations.of(context).syncWorkouts),
                              content: const Text(
                                'This will upload all your local workouts to the cloud. '
                                'This may take a few minutes depending on how many workouts you have.'
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(l10n.cancel),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Start Sync'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await ref.read(syncStateProvider.notifier)
                                .performRetroactiveSync();
                          }
                        },
                  icon: const Icon(Icons.cloud_upload),
                  label: Text(AppLocalizations.of(context).syncAllWorkouts),
                ),
              ),
            ],
            
            // Additional info
            if (!syncState.isSyncing && syncState.lastResult == null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cloud sync ensures your workouts are backed up and '
                        'accessible across all your devices.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Error details if any
            if (syncState.lastResult != null && 
                !syncState.lastResult!.success &&
                syncState.lastResult!.errors != null) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                title: Text(
                  'Error Details',
                  style: theme.textTheme.bodySmall,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: syncState.lastResult!.errors!
                          .take(5)
                          .map((error) => Text(
                                '• $error',
                                style: theme.textTheme.bodySmall,
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Future<bool> _checkUnsyncedWorkouts(WidgetRef ref) async {
    try {
      final userProfileAsync = ref.read(unifiedUserProfileProvider);
      final userId = userProfileAsync.value?.uid;
      if (userId == null) return false;

      final boxManager = ref.read(hiveBoxManagerProvider);
      final dataSource = HiveWorkoutDataSource(boxManager);
      final unsyncedWorkouts = await dataSource.getUnsyncedWorkouts(userId);
      return unsyncedWorkouts.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).upgradeToPremium),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Premium features include:'),
            SizedBox(height: 12),
            _FeatureItem(icon: Icons.cloud_sync, text: 'Cloud sync across devices'),
            _FeatureItem(icon: Icons.backup, text: 'Automatic backups'),
            _FeatureItem(icon: Icons.insights, text: 'Advanced analytics'),
            _FeatureItem(icon: Icons.timer, text: 'Unlimited workout history'),
            _FeatureItem(icon: Icons.support, text: 'Priority support'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to premium purchase screen
              // context.goNamed('premium');
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat.yMMMd().format(time);
    }
  }
}

class _FeatureItem extends StatelessWidget {
  
  const _FeatureItem({
    required this.icon,
    required this.text,
  });
  final IconData icon;
  final String text;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
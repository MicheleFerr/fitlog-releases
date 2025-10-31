/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/exercise_database/presentation/widgets
/// 🎯 Feature: exercise_database
/// 🔧 Type: widget
///
/// Widget per mostrare stato sincronizzazione esercizi
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/sync_status.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_database/data/services/exercise_sync_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

class ExerciseSyncStatusWidget extends ConsumerWidget {
  const ExerciseSyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(exerciseSyncStatusProvider);
    final versionWatch = ref.watch(exerciseVersionWatchProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sync,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).exerciseSync,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stato sincronizzazione corrente
            syncStatus.when(
              data: (status) => _buildSyncStatusIndicator(context, status),
              loading: () => _buildLoadingIndicator(context),
              error: (error, _) => _buildErrorIndicator(context, error),
            ),

            const SizedBox(height: 16),

            // Informazioni versione e aggiornamenti
            versionWatch.when(
              data: (versionCheck) => _buildVersionInfo(context, ref, versionCheck),
              loading: () => _buildVersionLoading(context),
              error: (error, _) => _buildVersionError(context, error),
            ),

            const SizedBox(height: 16),

            // Azioni disponibili
            _buildActionButtons(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusIndicator(BuildContext context, SyncStatus status) {
    late String text;
    late Color color;
    late IconData icon;

    switch (status) {
      case SyncStatus.idle:
        text = AppLocalizations.of(context).syncIdle;
        color = Theme.of(context).colorScheme.onSurface;
        icon = Icons.check_circle_outline;
        break;
      case SyncStatus.loading:
        text = AppLocalizations.of(context).syncLoading;
        color = Theme.of(context).colorScheme.primary;
        icon = Icons.download;
        break;
      case SyncStatus.syncing:
        text = AppLocalizations.of(context).syncSyncing;
        color = Theme.of(context).colorScheme.primary;
        icon = Icons.sync;
        break;
      case SyncStatus.success:
        text = AppLocalizations.of(context).syncSuccess;
        color = context.colors.success;
        icon = Icons.check_circle;
        break;
      case SyncStatus.error:
        text = AppLocalizations.of(context).syncError;
        color = Theme.of(context).colorScheme.error;
        icon = Icons.error;
        break;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
        if (status == SyncStatus.syncing || status == SyncStatus.loading) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        Text(AppLocalizations.of(context).checkingStatus),
      ],
    );
  }

  Widget _buildErrorIndicator(BuildContext context, Object error) {
    return Row(
      children: [
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${AppLocalizations.of(context).statusError}: $error',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVersionInfo(BuildContext context, WidgetRef ref, VersionCheckResult versionCheck) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).versionInfo,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context).localVersion),
              Text(
                versionCheck.localVersion,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),

          if (versionCheck.remoteVersion != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context).remoteVersion),
                Text(
                  versionCheck.remoteVersion!.version,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],

          if (versionCheck.hasUpdates) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.colors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.new_releases,
                    size: 16,
                    color: context.colors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context).updateAvailable,
                    style: const TextStyle(
                      color: context.colors.secondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
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

  Widget _buildVersionLoading(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context).checkingVersion),
        ],
      ),
    );
  }

  Widget _buildVersionError(BuildContext context, Object error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_outlined,
            size: 16,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${AppLocalizations.of(context).versionCheckError}: $error',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _forceSync(ref),
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(AppLocalizations.of(context).forceSync),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showSyncSettings(context, ref),
            icon: const Icon(Icons.settings, size: 18),
            label: Text(AppLocalizations.of(context).syncSettings),
          ),
        ),
      ],
    );
  }

  Future<void> _forceSync(WidgetRef ref) async {
    try {
      final syncActions = ref.read(exerciseSyncActionsProvider);
      final result = await syncActions.forceSync();

      // Il risultato verrà mostrato automaticamente tramite i provider stream
    } catch (e) {
      // Errore gestito dai provider
    }
  }

  void _showSyncSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const ExerciseSyncSettingsSheet(),
      isScrollControlled: true,
    );
  }
}

/// Sheet per impostazioni sincronizzazione
class ExerciseSyncSettingsSheet extends ConsumerStatefulWidget {
  const ExerciseSyncSettingsSheet({super.key});

  @override
  ConsumerState<ExerciseSyncSettingsSheet> createState() => _ExerciseSyncSettingsSheetState();
}

class _ExerciseSyncSettingsSheetState extends ConsumerState<ExerciseSyncSettingsSheet> {
  bool? _autoSyncEnabled;
  Duration? _syncFrequency;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final syncActions = ref.read(exerciseSyncActionsProvider);

    final autoSync = await syncActions.isAutoSyncEnabled();

    setState(() {
      _autoSyncEnabled = autoSync;
      _syncFrequency = const Duration(hours: 6); // Default
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Titolo
              Text(
                AppLocalizations.of(context).syncSettings,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Auto-sync toggle
              if (_autoSyncEnabled != null)
                SwitchListTile(
                  title: Text(AppLocalizations.of(context).autoSync),
                  subtitle: Text(AppLocalizations.of(context).autoSyncDescription),
                  value: _autoSyncEnabled!,
                  onChanged: (value) => _toggleAutoSync(value),
                ),

              const SizedBox(height: 16),

              // Frequenza sincronizzazione
              ListTile(
                title: Text(AppLocalizations.of(context).syncFrequency),
                subtitle: Text(_getSyncFrequencyText()),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showFrequencySelector,
              ),

              const SizedBox(height: 16),

              // Statistiche cache
              _buildCacheStats(),

              const SizedBox(height: 24),

              // Azioni
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clearCache,
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      label: Text(
                        AppLocalizations.of(context).clearCache,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context).done),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCacheStats() {
    final cacheStats = ref.watch(exerciseCacheStatsProvider);

    return cacheStats.when(
      data: (stats) {
        if (stats == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).cacheStatistics,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context).cachedExercises),
                  Text('${stats.exerciseCount}'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context).cacheSize),
                  Text('${(stats.cacheSize / 1024).toStringAsFixed(1)} KB'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context).lastUpdate),
                  Text(_formatDate(stats.lastUpdated)),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _getSyncFrequencyText() {
    if (_syncFrequency == null) return AppLocalizations.of(context).loading;

    final hours = _syncFrequency!.inHours;
    if (hours == 1) return AppLocalizations.of(context).everyHour;
    if (hours == 6) return AppLocalizations.of(context).every6Hours;
    if (hours == 12) return AppLocalizations.of(context).every12Hours;
    if (hours == 24) return AppLocalizations.of(context).daily;

    return '${AppLocalizations.of(context).every} $hours ${AppLocalizations.of(context).hours}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ${AppLocalizations.of(context).ago}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${AppLocalizations.of(context).ago}';
    } else {
      return '${difference.inMinutes}m ${AppLocalizations.of(context).ago}';
    }
  }

  Future<void> _toggleAutoSync(bool enabled) async {
    final syncActions = ref.read(exerciseSyncActionsProvider);
    await syncActions.setAutoSync(enabled);

    setState(() {
      _autoSyncEnabled = enabled;
    });
  }

  void _showFrequencySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).selectSyncFrequency),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _frequencyOption(const Duration(hours: 1), AppLocalizations.of(context).everyHour),
            _frequencyOption(const Duration(hours: 6), AppLocalizations.of(context).every6Hours),
            _frequencyOption(const Duration(hours: 12), AppLocalizations.of(context).every12Hours),
            _frequencyOption(const Duration(hours: 24), AppLocalizations.of(context).daily),
          ],
        ),
      ),
    );
  }

  Widget _frequencyOption(Duration frequency, String title) {
    return RadioListTile<Duration>(
      title: Text(title),
      value: frequency,
      groupValue: _syncFrequency,
      onChanged: (value) async {
        if (value != null) {
          final syncActions = ref.read(exerciseSyncActionsProvider);
          await syncActions.setSyncFrequency(value);

          setState(() {
            _syncFrequency = value;
          });

          Navigator.of(context).pop();
        }
      },
    );
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).clearCache),
        content: Text(AppLocalizations.of(context).clearCacheConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context).clear),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final syncActions = ref.read(exerciseSyncActionsProvider);
      await syncActions.clearCache();

      // Refresh cache stats
      ref.invalidate(exerciseCacheStatsProvider);
    }
  }
}
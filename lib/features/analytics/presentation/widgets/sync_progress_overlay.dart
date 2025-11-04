import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';

class SyncProgressOverlay extends ConsumerWidget {
  const SyncProgressOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(workoutSyncStatusProvider);
    final theme = Theme.of(context);

    if (!syncStatus.isActive) {
      return const SizedBox.shrink();
    }

    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sync,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),

                Text(
                  _getStatusTitle(syncStatus.state),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Text(
                  _getStatusMessage(syncStatus),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                if (syncStatus.state == SyncState.syncing) ...[
                  LinearProgressIndicator(
                    value: syncStatus.progress,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${syncStatus.currentCount}/${syncStatus.totalCount} workout',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else ...[
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                Text(
                  'Attendi qualche secondo...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusTitle(SyncState state) {
    switch (state) {
      case SyncState.checking:
        return 'Controllo dati...';
      case SyncState.syncing:
        return 'Sincronizzazione in corso';
      case SyncState.completed:
        return 'Completato!';
      case SyncState.error:
        return 'Errore';
      default:
        return '';
    }
  }

  String _getStatusMessage(WorkoutSyncStatus status) {
    switch (status.state) {
      case SyncState.checking:
        return 'Verifico se ci sono nuovi allenamenti da scaricare...';
      case SyncState.syncing:
        return 'Sto scaricando i tuoi allenamenti da Firebase.\nQuesto potrebbe richiedere un momento.';
      case SyncState.completed:
        return 'Tutti i dati sono stati sincronizzati!';
      case SyncState.error:
        return status.errorMessage ?? 'Si è verificato un errore durante la sincronizzazione.';
      default:
        return '';
    }
  }
}
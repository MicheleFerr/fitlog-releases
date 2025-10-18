import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/missing_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/missing_exercise_request.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

class MissingExercisesRequestsScreen extends ConsumerStatefulWidget {
  const MissingExercisesRequestsScreen({super.key});

  @override
  ConsumerState<MissingExercisesRequestsScreen> createState() =>
      _MissingExercisesRequestsScreenState();
}

class _MissingExercisesRequestsScreenState
    extends ConsumerState<MissingExercisesRequestsScreen> {
  RequestStatus _selectedFilter = RequestStatus.pending;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final requestsAsync = ref.watch(requestsByStatusProvider(_selectedFilter));
    final countsAsync = ref.watch(requestCountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.fitness_center,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Richieste Esercizi Mancanti'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(requestsByStatusProvider);
              ref.invalidate(requestCountsProvider);
            },
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          countsAsync.when(
            data: (counts) => _buildFilterTabs(counts),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Requests list
          Expanded(
            child: requestsAsync.when(
              data: (requests) => _buildRequestsList(requests),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(Map<RequestStatus, int> counts) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          _buildFilterChip(
            'In Attesa',
            RequestStatus.pending,
            counts[RequestStatus.pending] ?? 0,
            Colors.orange,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Approvate',
            RequestStatus.approved,
            counts[RequestStatus.approved] ?? 0,
            Colors.green,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Completate',
            RequestStatus.completed,
            counts[RequestStatus.completed] ?? 0,
            Colors.blue,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Rifiutate',
            RequestStatus.rejected,
            counts[RequestStatus.rejected] ?? 0,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    RequestStatus status,
    int count,
    Color color,
  ) {
    final isSelected = _selectedFilter == status;

    return Expanded(
      child: FilterChip(
        label: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _selectedFilter = status);
        },
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        backgroundColor: color.withOpacity(0.1),
      ),
    );
  }

  Widget _buildRequestsList(List<MissingExerciseRequest> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nessuna richiesta ${_getStatusLabel(_selectedFilter).toLowerCase()}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(requestsByStatusProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(MissingExerciseRequest request) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _getStatusIcon(request.status),
                  color: _getStatusColor(request.status),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.exerciseName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Details
            Text(
              'ID: ${request.exerciseId}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Richiesto: ${_formatDate(request.requestedAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),

            if (request.reviewedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Revisionato: ${_formatDate(request.reviewedAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],

            if (request.adminNotes != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.adminNotes!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],

            // Actions (only for pending requests)
            if (request.status == RequestStatus.pending) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectRequest(request),
                      icon: const Icon(Icons.close),
                      label: const Text('Rifiuta'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _approveRequest(request),
                      icon: const Icon(Icons.check),
                      label: const Text('Approva'),
                    ),
                  ),
                ],
              ),
            ],

            // Mark as completed (only for approved requests)
            if (request.status == RequestStatus.approved) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _markAsCompleted(request),
                  icon: const Icon(Icons.done_all),
                  label: const Text('Segna come Completato'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(dynamic error) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Errore: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(requestsByStatusProvider);
            },
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Future<void> _approveRequest(MissingExerciseRequest request) async {
    final service = ref.read(missingExerciseServiceProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approva Richiesta'),
        content: Text(
          'Vuoi approvare la richiesta per "${request.exerciseName}"?\n\n'
          'Dopo l\'approvazione, dovrai aggiungere l\'esercizio completo al database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Approva'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await service.approveRequest(
          requestId: request.id,
          notes: 'Approvato per inserimento nel database',
        );

        if (mounted) {
          SnackBarService.showSuccess(
            context,
            '✅ Richiesta approvata! Ricorda di aggiungere l\'esercizio al database.',
            duration: const Duration(seconds: 4),
          );
        }
      } catch (e) {
        if (mounted) {
          SnackBarService.showError(
            context,
            'Errore: $e',
          );
        }
      }
    }
  }

  Future<void> _rejectRequest(MissingExerciseRequest request) async {
    final service = ref.read(missingExerciseServiceProvider);
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rifiuta Richiesta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rifiutare la richiesta per "${request.exerciseName}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo (opzionale)',
                hintText: 'es. Esercizio già presente, nome troppo generico...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Rifiuta'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await service.rejectRequest(
          requestId: request.id,
          reason: reasonController.text.trim().isEmpty
              ? 'Rifiutato dall\'admin'
              : reasonController.text.trim(),
        );

        if (mounted) {
          SnackBarService.showWarning(
            context,
            'Richiesta rifiutata',
          );
        }
      } catch (e) {
        if (mounted) {
          SnackBarService.showError(
            context,
            'Errore: $e',
          );
        }
      }
    }
  }

  Future<void> _markAsCompleted(MissingExerciseRequest request) async {
    final service = ref.read(missingExerciseServiceProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Segna come Completato'),
        content: Text(
          'Segna "${request.exerciseName}" come completato?\n\n'
          'Usa questa opzione solo dopo aver aggiunto l\'esercizio completo al database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Completato'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await service.markAsCompleted(
          requestId: request.id,
          notes: 'Esercizio aggiunto al database',
        );

        if (mounted) {
          SnackBarService.showSuccess(
            context,
            '✅ Richiesta completata!',
          );
        }
      } catch (e) {
        if (mounted) {
          SnackBarService.showError(
            context,
            'Errore: $e',
          );
        }
      }
    }
  }

  IconData _getStatusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Icons.hourglass_empty;
      case RequestStatus.approved:
        return Icons.check_circle_outline;
      case RequestStatus.rejected:
        return Icons.cancel_outlined;
      case RequestStatus.completed:
        return Icons.done_all;
    }
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.approved:
        return Colors.green;
      case RequestStatus.rejected:
        return Colors.red;
      case RequestStatus.completed:
        return Colors.blue;
    }
  }

  String _getStatusLabel(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'In Attesa';
      case RequestStatus.approved:
        return 'Approvate';
      case RequestStatus.rejected:
        return 'Rifiutate';
      case RequestStatus.completed:
        return 'Completate';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minuti fa';
      }
      return '${difference.inHours} ore fa';
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} giorni fa';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

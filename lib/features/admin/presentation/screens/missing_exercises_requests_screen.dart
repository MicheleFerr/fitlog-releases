import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/missing_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/exercise_database/domain/entities/missing_exercise_request.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

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
    final requestsAsync = ref.watch(requestsByStatusProvider(_selectedFilter));
    final countsAsync = ref.watch(requestCountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              AppIcons.workout,
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
            icon: const SemanticIcon(
  icon: AppIcons.refresh,
  semanticLabel: 'Refresh',
),
            tooltip: context.l10n.refresh,
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
              loading: () => const Center(child: LoadingIndicator()),
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
            context.colors.warning,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Approvate',
            RequestStatus.approved,
            counts[RequestStatus.approved] ?? 0,
            context.colors.success,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Completate',
            RequestStatus.completed,
            counts[RequestStatus.completed] ?? 0,
            context.colors.primary,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Rifiutate',
            RequestStatus.rejected,
            counts[RequestStatus.rejected] ?? 0,
            context.colors.error,
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
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : color,
              ),
            ),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
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
        backgroundColor: color.withValues(alpha: 0.1),
      ),
    );
  }

  Widget _buildRequestsList(List<MissingExerciseRequest> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
  icon: AppIcons.completeOutline,
  semanticLabel: 'Complete outline',
  size: AppIconSize.medium,
  color: Theme.of(context,
).colorScheme.primary.withValues(alpha: 0.5),
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
    final l10n = context.l10n;

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
                      .withValues(alpha: 0.5),
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
                      icon: const SemanticIcon(
  icon: AppIcons.close,
  semanticLabel: 'Close',
),
                      label: Text(l10n.reject),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _approveRequest(request),
                      icon: const SemanticIcon(
  icon: AppIcons.check,
  semanticLabel: 'Check',
),
                      label: Text(l10n.approve),
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
                  icon: const SemanticIcon(
  icon: AppIcons.doneAll,
  semanticLabel: 'Done all',
),
                  label: Text(l10n.markAsCompleted),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SemanticIcon(
  icon: AppIcons.error,
  semanticLabel: 'Error',
  size: AppIconSize.medium,
  color: context.colors.error,
),
          const SizedBox(height: 16),
          Text(context.l10n.error),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(requestsByStatusProvider);
            },
            child: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }

  Future<void> _approveRequest(MissingExerciseRequest request) async {
    final service = ref.read(missingExerciseServiceProvider);
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.approveRequest),
        content: Text(
          l10n.approveRequestMessage(request.exerciseName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.approve),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await service.approveRequest(
          requestId: request.id,
          notes: l10n.approvedForDatabaseInsertion,
        );

        if (mounted) {
          SnackBarService.showSuccess(
            context,
            '✅ ${l10n.requestApprovedSuccess}',
            duration: const Duration(seconds: 4),
          );
        }
      } catch (e) {
        if (mounted) {
          SnackBarService.showError(
            context,
            context.l10n.error,
          );
        }
      }
    }
  }

  Future<void> _rejectRequest(MissingExerciseRequest request) async {
    final service = ref.read(missingExerciseServiceProvider);
    final reasonController = TextEditingController();
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rejectRequest),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.rejectRequestMessage(request.exerciseName)),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: l10n.motivoOpzionale,
                hintText: l10n.rejectionReasonPlaceholder,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.reject),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await service.rejectRequest(
          requestId: request.id,
          reason: reasonController.text.trim().isEmpty
              ? l10n.rejectedByAdmin
              : reasonController.text.trim(),
        );

        if (mounted) {
          SnackBarService.showWarning(
            context,
            l10n.requestRejected,
          );
        }
      } catch (e) {
        if (mounted) {
          SnackBarService.showError(
            context,
            context.l10n.error,
          );
        }
      }
    }
  }

  Future<void> _markAsCompleted(MissingExerciseRequest request) async {
    final service = ref.read(missingExerciseServiceProvider);
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.markAsCompleted),
        content: Text(
          l10n.markAsCompletedMessage(request.exerciseName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.completed),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await service.markAsCompleted(
          requestId: request.id,
          notes: l10n.exerciseAddedToDatabase,
        );

        if (mounted) {
          SnackBarService.showSuccess(
            context,
            '✅ ${l10n.requestMarkedAsCompleted}',
          );
        }
      } catch (e) {
        if (mounted) {
          SnackBarService.showError(
            context,
            context.l10n.error,
          );
        }
      }
    }
  }

  IconData _getStatusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return AppIcons.hourglassEmpty;
      case RequestStatus.approved:
        return AppIcons.completeOutline;
      case RequestStatus.rejected:
        return AppIcons.cancelOutlined;
      case RequestStatus.completed:
        return AppIcons.doneAll;
    }
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return context.colors.warning;
      case RequestStatus.approved:
        return context.colors.success;
      case RequestStatus.rejected:
        return context.colors.error;
      case RequestStatus.completed:
        return context.colors.primary;
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

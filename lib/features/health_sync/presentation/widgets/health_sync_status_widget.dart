import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_sync_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_sync_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Widget that displays the sync status for a specific health data type.
///
/// **Features**:
/// - Real-time sync status (idle, syncing, success, error)
/// - Last sync timestamp with relative time (e.g., "2 hours ago")
/// - Error message display if sync failed
/// - Retry button for failed syncs
/// - Manual sync button
///
/// **Design**:
/// - Card-based layout following DESIGN_GUIDELINES.md
/// - Status icon with semantic colors
/// - Theme-aware (dark/light mode)
/// - Localized strings
///
/// **Usage**:
/// ```dart
/// HealthSyncStatusWidget(
///   dataType: HealthDataType.workout,
///   onManualSync: () async {
///     await ref.read(healthSyncControllerProvider.notifier).syncWorkouts();
///   },
/// )
/// ```
class HealthSyncStatusWidget extends ConsumerWidget {
  const HealthSyncStatusWidget({
    required this.dataType,
    required this.onManualSync,
    super.key,
  });

  /// The health data type to display status for
  final HealthDataType dataType;

  /// Callback when user manually triggers sync
  final VoidCallback onManualSync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatusAsync = ref.watch(
      healthSyncStatusProvider(dataType),
    );

    return syncStatusAsync.when(
      data: (status) => _buildStatusCard(context, ref, status),
      loading: () => _buildLoadingCard(context),
      error: (err, stack) => _buildErrorCard(context, err),
    );
  }

  /// Builds the main status card with sync information
  Widget _buildStatusCard(
    BuildContext context,
    WidgetRef ref,
    HealthSyncStatus status,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Data type title + status icon
            Row(
              children: [
                SemanticIcon(
                  icon: _getDataTypeIcon(dataType),
                  semanticLabel: _getDataTypeName(context, dataType),
                  size: AppIconSize.large,
                  color: context.iconPrimary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getDataTypeName(context, dataType),
                    style: context.textTheme.titleMedium,
                  ),
                ),
                _buildStatusIcon(context, status),
              ],
            ),

            const SizedBox(height: 12),

            // Sync status message
            Text(
              _getSyncStatusMessage(context, status),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),

            // Last sync time (if available)
            if (status.lastSyncTime != null) ...[
              const SizedBox(height: 8),
              Text(
                _getLastSyncText(context, status.lastSyncTime!),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],

            // Error message (if failed)
            if (status.lastResult == SyncResult.error &&
                status.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                status.errorMessage!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Retry button (if error and retries available)
                if (status.lastResult == SyncResult.error &&
                    status.shouldRetry()) ...[
                  TextButton.icon(
                    onPressed: () => _handleRetry(ref),
                    icon: SemanticIcon(
                      icon: AppIcons.refresh,
                      semanticLabel: 'Retry',
                      size: AppIconSize.small,
                      color: context.iconPrimary,
                    ),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(width: 8),
                ],

                // Manual sync button
                FilledButton.icon(
                  onPressed: onManualSync,
                  icon: SemanticIcon(
                    icon: AppIcons.sync,
                    semanticLabel: 'Sync',
                    size: AppIconSize.small,
                    color: context.colors.onPrimary,
                  ),
                  label: const Text('Sync Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds loading state card
  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: LoadingIndicator(),
      ),
    );
  }

  /// Builds error state card
  Widget _buildErrorCard(BuildContext context, Object error) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SemanticIcon(
            icon: AppIcons.error,
            semanticLabel: 'Error',
            size: AppIconSize.large,
            color: context.colors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Failed to load sync status: $error',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds status icon based on sync result
  Widget _buildStatusIcon(BuildContext context, HealthSyncStatus status) {
    final IconData icon;
    final Color color;

    switch (status.lastResult) {
      case SyncResult.idle:
        icon = AppIcons.pending;
        color = context.iconSecondary;
      case SyncResult.syncing:
        icon = AppIcons.sync;
        color = context.iconPrimary;
      case SyncResult.success:
        icon = AppIcons.checkCircle;
        color = context.iconSuccess;
      case SyncResult.error:
        icon = AppIcons.error;
        color = context.iconError;
    }

    return SemanticIcon(
      icon: icon,
      semanticLabel: status.lastResult.name,
      size: AppIconSize.large,
      color: color,
    );
  }

  /// Handles retry button tap
  Future<void> _handleRetry(WidgetRef ref) async {
    final controller = ref.read(healthSyncControllerProvider.notifier);
    await controller.retryFailedSync(dataType);
  }

  /// Gets localized data type name
  String _getDataTypeName(BuildContext context, HealthDataType dataType) {
    switch (dataType) {
      case HealthDataType.workout:
        return 'Workouts'; // TODO: Localize in Task 5.1
      case HealthDataType.bodyWeight:
        return 'Body Weight'; // TODO: Localize in Task 5.1
      case HealthDataType.bodyFat:
        return 'Body Fat'; // TODO: Localize in Task 5.1
      case HealthDataType.leanMass:
        return 'Lean Mass'; // TODO: Localize in Task 5.1
      case HealthDataType.heartRate:
        return 'Heart Rate'; // TODO: Localize in Task 5.1
      case HealthDataType.sleep:
        return 'Sleep'; // TODO: Localize in Task 5.1
      case HealthDataType.nutrition:
        return 'Nutrition'; // TODO: Localize in Task 5.1
    }
  }

  /// Gets icon for data type
  IconData _getDataTypeIcon(HealthDataType dataType) {
    switch (dataType) {
      case HealthDataType.workout:
        return AppIcons.workout;
      case HealthDataType.bodyWeight:
        return AppIcons.scale;
      case HealthDataType.bodyFat:
        return AppIcons.analytics;
      case HealthDataType.leanMass:
        return AppIcons.trendingUp; // Alternative: muscle strength indicator
      case HealthDataType.heartRate:
        return AppIcons.favorite; // Alternative: heart icon
      case HealthDataType.sleep:
        return AppIcons.bedtime; // Sleep/rest icon
      case HealthDataType.nutrition:
        return AppIcons.apple; // Nutrition/food icon
    }
  }

  /// Gets sync status message
  String _getSyncStatusMessage(BuildContext context, HealthSyncStatus status) {
    switch (status.lastResult) {
      case SyncResult.idle:
        return 'Not synced yet'; // TODO: Localize in Task 5.1
      case SyncResult.syncing:
        return 'Syncing...'; // TODO: Localize in Task 5.1
      case SyncResult.success:
        return 'Sync successful'; // TODO: Localize in Task 5.1
      case SyncResult.error:
        final retryCount = status.retryCount;
        if (retryCount > 0) {
          return 'Sync failed (Retry $retryCount/3)'; // TODO: Localize
        }
        return 'Sync failed'; // TODO: Localize in Task 5.1
    }
  }

  /// Gets last sync time text with relative time
  String _getLastSyncText(BuildContext context, DateTime lastSyncTime) {
    final relative = timeago.format(lastSyncTime);
    return 'Last synced $relative'; // TODO: Localize in Task 5.1
  }
}

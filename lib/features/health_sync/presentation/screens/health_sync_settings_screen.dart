import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_permission_provider.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_background_sync_provider.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_sync_provider.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/widgets/health_sync_status_widget.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Settings screen for Apple Health & Health Connect integration.
///
/// **Features**:
/// - Permission management (request/revoke)
/// - Sync status display (workout, body weight)
/// - Manual sync triggers
/// - Background sync configuration
/// - Platform-specific UI (iOS HealthKit vs Android Health Connect)
///
/// **Architecture**:
/// - Uses Riverpod providers for state management
/// - Clean Architecture separation (presentation layer only)
/// - Follows DESIGN_GUIDELINES.md patterns
///
/// **Platform Support**:
/// - iOS 14+: HealthKit integration
/// - Android 14+: Health Connect integration
///
/// **Usage**:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => const HealthSyncSettingsScreen(),
///   ),
/// );
/// ```
class HealthSyncSettingsScreen extends ConsumerWidget {
  const HealthSyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionStatusAsync = ref.watch(healthPermissionStatusProvider);
    final backgroundSyncState = ref.watch(healthBackgroundSyncControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Sync Settings'), // TODO: Localize in Task 5.1
        actions: [
          // Help icon
          IconButton(
            onPressed: () => _showHelpDialog(context),
            icon: SemanticIcon(
              icon: AppIcons.help,
              semanticLabel: 'Help',
              size: AppIconSize.large,
              color: context.iconPrimary,
            ),
          ),
        ],
      ),
      body: permissionStatusAsync.when(
        data: (permissionStatus) => _buildContent(
          context,
          ref,
          permissionStatus,
          backgroundSyncState,
        ),
        loading: () => const Center(child: LoadingIndicator()),
        error: (err, stack) => _buildErrorState(context, err),
      ),
    );
  }

  /// Builds the main content with sections
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    dynamic permissionStatus, // HealthPermissionStatus
    BackgroundSyncState backgroundSyncState,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Platform info banner
        _buildPlatformBanner(context, permissionStatus),

        const SizedBox(height: 24),

        // Permission section
        _buildSectionHeader(context, 'Permissions'), // TODO: Localize
        const SizedBox(height: 12),
        _buildPermissionsList(context, ref, permissionStatus),

        const SizedBox(height: 24),

        // Sync status section
        _buildSectionHeader(context, 'Sync Status'), // TODO: Localize
        const SizedBox(height: 12),
        _buildSyncStatusList(context, ref, permissionStatus),

        const SizedBox(height: 24),

        // Background sync section
        _buildSectionHeader(context, 'Background Sync'), // TODO: Localize
        const SizedBox(height: 12),
        _buildBackgroundSyncCard(context, ref, backgroundSyncState),

        const SizedBox(height: 24),

        // Clear cache button
        _buildClearCacheButton(context, ref),
      ],
    );
  }

  /// Builds platform banner (iOS HealthKit / Android Health Connect)
  Widget _buildPlatformBanner(BuildContext context, dynamic permissionStatus) {
    final isHealthConnectAvailable = permissionStatus.healthConnectAvailable ?? false;
    final platformName = isHealthConnectAvailable ? 'Health Connect' : 'Apple Health';
    final platformIcon = isHealthConnectAvailable ? AppIcons.phoneAndroid : AppIcons.apple;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SemanticIcon(
            icon: platformIcon,
            semanticLabel: platformName,
            size: AppIconSize.xlarge,
            color: context.iconPrimary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platformName,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Sync your workout and body data', // TODO: Localize
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds section header
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: context.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Builds permissions list with toggle switches
  Widget _buildPermissionsList(
    BuildContext context,
    WidgetRef ref,
    dynamic permissionStatus,
  ) {
    final permissions = permissionStatus.permissions as Map;

    return Column(
      children: [
        // Workout permission
        _buildPermissionTile(
          context,
          ref,
          title: 'Workouts', // TODO: Localize
          subtitle: 'Import workouts from Apple Health / Health Connect', // TODO
          dataType: HealthDataType.workout,
          isGranted: permissions[HealthDataType.workout]?.name == 'authorized',
        ),

        const SizedBox(height: 8),

        // Body weight permission
        _buildPermissionTile(
          context,
          ref,
          title: 'Body Weight', // TODO: Localize
          subtitle: 'Sync body weight data (bidirectional)', // TODO
          dataType: HealthDataType.bodyWeight,
          isGranted: permissions[HealthDataType.bodyWeight]?.name == 'authorized',
        ),
      ],
    );
  }

  /// Builds a single permission tile with switch
  Widget _buildPermissionTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required HealthDataType dataType,
    required bool isGranted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        value: isGranted,
        onChanged: (value) => _handlePermissionToggle(
          context,
          ref,
          dataType,
          value,
        ),
        secondary: SemanticIcon(
          icon: isGranted ? AppIcons.checkCircle : AppIcons.block,
          semanticLabel: isGranted ? 'Granted' : 'Denied',
          size: AppIconSize.large,
          color: isGranted ? context.iconSuccess : context.iconError,
        ),
      ),
    );
  }

  /// Builds sync status list (workout + body weight)
  Widget _buildSyncStatusList(
    BuildContext context,
    WidgetRef ref,
    dynamic permissionStatus,
  ) {
    final permissions = permissionStatus.permissions as Map;
    final workoutGranted = permissions[HealthDataType.workout]?.name == 'authorized';
    final weightGranted = permissions[HealthDataType.bodyWeight]?.name == 'authorized';

    return Column(
      children: [
        // Workout sync status
        if (workoutGranted)
          HealthSyncStatusWidget(
            dataType: HealthDataType.workout,
            onManualSync: () => _handleManualSync(
              context,
              ref,
              HealthDataType.workout,
            ),
          ),

        if (workoutGranted) const SizedBox(height: 12),

        // Body weight sync status
        if (weightGranted)
          HealthSyncStatusWidget(
            dataType: HealthDataType.bodyWeight,
            onManualSync: () => _handleManualSync(
              context,
              ref,
              HealthDataType.bodyWeight,
            ),
          ),

        // No permissions message
        if (!workoutGranted && !weightGranted)
          Container(
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.info,
                  semanticLabel: 'Info',
                  size: AppIconSize.large,
                  color: context.iconSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Grant permissions above to enable sync', // TODO: Localize
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Builds background sync configuration card
  Widget _buildBackgroundSyncCard(
    BuildContext context,
    WidgetRef ref,
    BackgroundSyncState backgroundSyncState,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto Sync (Daily)', // TODO: Localize
                      style: context.textTheme.titleMedium,
                    ),
                    Text(
                      'Sync automatically every 24 hours', // TODO: Localize
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: backgroundSyncState.isScheduled,
                onChanged: (value) => _handleBackgroundSyncToggle(
                  context,
                  ref,
                  value,
                ),
              ),
            ],
          ),

          // Last sync time (if available)
          if (backgroundSyncState.lastBackgroundSync != null) ...[
            const SizedBox(height: 12),
            Text(
              'Last synced: ${_formatDateTime(backgroundSyncState.lastBackgroundSync!)}', // TODO
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],

          // Next sync time (if scheduled)
          if (backgroundSyncState.nextScheduledSync != null) ...[
            const SizedBox(height: 4),
            Text(
              'Next sync: ${_formatDateTime(backgroundSyncState.nextScheduledSync!)}', // TODO
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds clear cache button
  Widget _buildClearCacheButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => _handleClearCache(context, ref),
      icon: SemanticIcon(
        icon: AppIcons.delete,
        semanticLabel: 'Clear cache',
        size: AppIconSize.small,
        color: context.iconError,
      ),
      label: const Text('Clear Sync Cache'), // TODO: Localize
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colors.error,
      ),
    );
  }

  /// Builds error state
  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SemanticIcon(
              icon: AppIcons.error,
              semanticLabel: 'Error',
              size: AppIconSize.xxlarge,
              color: context.iconError,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load health sync settings', // TODO: Localize
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
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

  // ============================================================
  // EVENT HANDLERS
  // ============================================================

  /// Handles permission toggle
  Future<void> _handlePermissionToggle(
    BuildContext context,
    WidgetRef ref,
    HealthDataType dataType,
    bool value,
  ) async {
    if (!value) {
      // Cannot revoke from app - must do in iOS Settings / Health Connect
      SnackBarService.showWarning(
        context,
        'Please revoke permission in system settings', // TODO: Localize
      );
      return;
    }

    // Request permission
    final controller = ref.read(healthPermissionControllerProvider.notifier);
    await controller.requestPermissions(dataTypes: [dataType]);

    // Show result
    final newStatus = ref.read(healthPermissionControllerProvider).valueOrNull;
    if (newStatus != null) {
      final isGranted = newStatus.canSync(dataType);
      if (isGranted) {
        SnackBarService.showSuccess(
          context,
          'Permission granted', // TODO: Localize
        );
      } else {
        SnackBarService.showError(
          context,
          'Permission denied', // TODO: Localize
        );
      }
    }
  }

  /// Handles manual sync
  Future<void> _handleManualSync(
    BuildContext context,
    WidgetRef ref,
    HealthDataType dataType,
  ) async {
    final controller = ref.read(healthSyncControllerProvider.notifier);

    try {
      if (dataType == HealthDataType.workout) {
        await controller.syncWorkouts();
      } else if (dataType == HealthDataType.bodyWeight) {
        await controller.syncBodyWeight();
      }

      SnackBarService.showSuccess(
        context,
        'Sync completed successfully', // TODO: Localize
      );
    } catch (e) {
      SnackBarService.showError(
        context,
        'Sync failed: $e', // TODO: Localize
      );
    }
  }

  /// Handles background sync toggle
  Future<void> _handleBackgroundSyncToggle(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    final controller = ref.read(healthBackgroundSyncControllerProvider.notifier);

    try {
      if (value) {
        await controller.enableBackgroundSync();
        SnackBarService.showSuccess(
          context,
          'Background sync enabled', // TODO: Localize
        );
      } else {
        await controller.disableBackgroundSync();
        SnackBarService.showSuccess(
          context,
          'Background sync disabled', // TODO: Localize
        );
      }
    } catch (e) {
      SnackBarService.showError(
        context,
        'Failed to toggle background sync: $e', // TODO: Localize
      );
    }
  }

  /// Handles clear cache
  Future<void> _handleClearCache(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(healthRepositoryProvider);

    // Confirm
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Sync Cache?'), // TODO: Localize
        content: const Text(
          'This will clear all synced data and sync history from local storage. '
          'Data in Apple Health / Health Connect will not be affected.', // TODO
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'), // TODO: Localize
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear Cache'), // TODO: Localize
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Clear cache
    final result = await repository.clearSyncCache();

    result.fold(
      (failure) => SnackBarService.showError(
        context,
        'Failed to clear cache: ${failure.message}', // TODO: Localize
      ),
      (_) => SnackBarService.showSuccess(
        context,
        'Cache cleared successfully', // TODO: Localize
      ),
    );
  }

  /// Shows help dialog
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Sync Help'), // TODO: Localize
        content: const SingleChildScrollView(
          child: Text(
            'Apple Health & Health Connect Integration\n\n'
            'Features:\n'
            '• Import workouts from Apple Health / Health Connect\n'
            '• Sync body weight data (bidirectional)\n'
            '• Automatic daily background sync\n'
            '• Manual sync anytime\n\n'
            'Permissions:\n'
            '• Workout: Import workout sessions\n'
            '• Body Weight: Sync weight data\n\n'
            'Background Sync:\n'
            '• Auto-syncs every 24 hours\n'
            '• Retry on failure (3 attempts max)\n'
            '• Can be disabled if needed', // TODO: Localize all
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'), // TODO: Localize
          ),
        ],
      ),
    );
  }

  /// Formats DateTime for display
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

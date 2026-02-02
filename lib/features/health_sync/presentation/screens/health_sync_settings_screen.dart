/// Health Sync Settings Screen
///
/// Simplified, user-friendly screen for Apple Health / Health Connect integration.
///
/// **Design Goals**:
/// - Clear, single-action primary CTA
/// - Visual status indicator
/// - Minimal cognitive load
/// - Progressive disclosure of advanced options
library;

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_permission_provider.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_background_sync_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Settings screen for Apple Health & Health Connect integration.
class HealthSyncSettingsScreen extends ConsumerStatefulWidget {
  const HealthSyncSettingsScreen({super.key});

  @override
  ConsumerState<HealthSyncSettingsScreen> createState() =>
      _HealthSyncSettingsScreenState();
}

class _HealthSyncSettingsScreenState
    extends ConsumerState<HealthSyncSettingsScreen> {
  bool _isConnecting = false;

  @override
  Widget build(BuildContext context) {
    final permissionStatusAsync = ref.watch(healthPermissionStatusProvider);
    final backgroundSyncState = ref.watch(
      healthBackgroundSyncControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.healthSyncSettings)),
      body: permissionStatusAsync.when(
        data: (permissionStatus) =>
            _buildContent(context, permissionStatus, backgroundSyncState),
        loading: () => const Center(child: LoadingIndicator()),
        error: (err, stack) => _buildNotAvailableState(context),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    dynamic permissionStatus,
    BackgroundSyncState backgroundSyncState,
  ) {
    final permissions = permissionStatus.permissions as Map;
    final isConnected =
        permissions[HealthDataType.workout] == PermissionState.authorized ||
        permissions[HealthDataType.bodyWeight] == PermissionState.authorized;

    // Android: Check if Health Connect is installed
    final healthConnectAvailable =
        permissionStatus.healthConnectAvailable as bool;
    if (Platform.isAndroid && !healthConnectAvailable) {
      return _buildHealthConnectInstallState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero section with connection status
          _buildHeroSection(context, isConnected),
          const SizedBox(height: 32),

          // Data types section
          _buildDataTypesSection(context, permissions),
          const SizedBox(height: 24),

          // Auto-sync option — hidden until native background task is implemented
          // TODO: Re-enable when iOS BGTaskScheduler / Android WorkManager are wired
          // if (isConnected) ...[
          //   _buildAutoSyncSection(context, backgroundSyncState),
          // ],
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isConnected) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final platformName = Platform.isIOS ? 'Apple Health' : 'Health Connect';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isConnected
              ? [
                  colorScheme.primaryContainer.withValues(alpha: 0.5),
                  colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                ]
              : [
                  colorScheme.surfaceContainerHighest,
                  colorScheme.surfaceContainerHigh,
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isConnected
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isConnected
                  ? colorScheme.primary.withValues(alpha: 0.15)
                  : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              boxShadow: isConnected
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Platform.isIOS ? AppIcons.apple : AppIcons.favorite,
              size: 40,
              color: isConnected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            platformName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isConnected
                  ? colorScheme.primary.withValues(alpha: 0.15)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isConnected ? AppIcons.checkCircle : AppIcons.block,
                  size: 18,
                  color: isConnected
                      ? context.successColor
                      : colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  isConnected ? l10n.connected : l10n.notConnected,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isConnected
                        ? context.successColor
                        : colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            l10n.healthSyncDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Primary action button
          if (!isConnected)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isConnecting ? null : _handleConnect,
                icon: _isConnecting
                    ? LoadingIndicator(
                        size: 20,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : const Icon(AppIcons.link, size: 20),
                label: Text(_isConnecting ? l10n.connecting : l10n.connect),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataTypesSection(BuildContext context, Map permissions) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dataTypes,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDataTypeTile(
          context,
          icon: AppIcons.workout,
          title: l10n.healthDataWorkouts,
          description: l10n.healthSyncWorkoutsDescription,
          isEnabled:
              permissions[HealthDataType.workout] == PermissionState.authorized,
          dataType: HealthDataType.workout,
        ),
        const SizedBox(height: 8),
        _buildDataTypeTile(
          context,
          icon: AppIcons.scale,
          title: l10n.healthDataBodyWeight,
          description: l10n.healthSyncBodyWeightDescription,
          isEnabled:
              permissions[HealthDataType.bodyWeight] ==
              PermissionState.authorized,
          dataType: HealthDataType.bodyWeight,
        ),
        const SizedBox(height: 8),
        _buildDataTypeTile(
          context,
          icon: AppIcons.bedtime,
          title: l10n.sleepData,
          description: l10n.sleepTrackingDescription,
          isEnabled:
              permissions[HealthDataType.workout] == PermissionState.authorized,
          dataType: null, // Sleep is read via workout permission
          isReadOnly: true,
        ),
      ],
    );
  }

  Widget _buildDataTypeTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isEnabled,
    HealthDataType? dataType,
    bool isReadOnly = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled
              ? context.successColor.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isEnabled
                ? context.successColor.withValues(alpha: 0.15)
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isEnabled
                ? context.successColor
                : colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isReadOnly
            ? Icon(
                isEnabled ? AppIcons.checkCircle : AppIcons.remove,
                color: isEnabled
                    ? context.successColor
                    : colorScheme.onSurface.withValues(alpha: 0.3),
              )
            : Switch.adaptive(
                value: isEnabled,
                onChanged: dataType != null
                    ? (value) => _handlePermissionToggle(dataType, value)
                    : null,
              ),
      ),
    );
  }

  Widget _buildAutoSyncSection(
    BuildContext context,
    BackgroundSyncState backgroundSyncState,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.autoSyncDaily,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.autoSyncDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: backgroundSyncState.isScheduled,
                onChanged: _handleBackgroundSyncToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotAvailableState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final platformName = Platform.isIOS ? 'Apple Health' : 'Health Connect';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(AppIcons.block, size: 40, color: colorScheme.error),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.healthSyncNotAvailable,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '$platformName ${l10n.notAvailableOnDevice}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Android-specific: Shows Health Connect installation prompt
  Widget _buildHealthConnectInstallState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Health Connect icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.tertiaryContainer,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                AppIcons.favorite,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              l10n.healthConnectNotInstalled,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              l10n.healthConnectInstallDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Install button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _handleInstallHealthConnect,
                icon: const Icon(AppIcons.download, size: 20),
                label: Text(l10n.healthConnectInstall),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Refresh button
            TextButton.icon(
              onPressed: () {
                // Refresh permission status to check if Health Connect was installed
                ref.invalidate(healthPermissionStatusProvider);
              },
              icon: const Icon(AppIcons.refresh, size: 18),
              label: Text(l10n.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleInstallHealthConnect() async {
    HapticFeedback.mediumImpact();

    final repository = ref.read(healthRepositoryProvider);
    final result = await repository.installHealthConnect();

    result.fold(
      (failure) {
        if (mounted) {
          SnackBarService.showError(context, failure.message);
        }
      },
      (_) {
        if (mounted) {
          SnackBarService.showInfo(context, context.l10n.healthConnectInstall);
        }
      },
    );
  }

  // ============================================================
  // EVENT HANDLERS
  // ============================================================

  Future<void> _handleConnect() async {
    HapticFeedback.mediumImpact();
    setState(() => _isConnecting = true);

    try {
      final controller = ref.read(healthPermissionControllerProvider.notifier);
      await controller.requestPermissionsSequential();

      if (mounted) {
        SnackBarService.showSuccess(context, context.l10n.healthKitConnected);
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          context.l10n.healthKitPermissionDenied,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  Future<void> _handlePermissionToggle(
    HealthDataType dataType,
    bool value,
  ) async {
    HapticFeedback.lightImpact();

    if (!value) {
      // Cannot revoke from app - must do in iOS Settings
      SnackBarService.showWarning(
        context,
        context.l10n.healthSyncPermissionRevoke,
      );
      return;
    }

    final controller = ref.read(healthPermissionControllerProvider.notifier);
    await controller.requestPermissions(dataTypes: [dataType]);
  }

  Future<void> _handleBackgroundSyncToggle(bool value) async {
    HapticFeedback.lightImpact();

    final controller = ref.read(
      healthBackgroundSyncControllerProvider.notifier,
    );

    try {
      if (value) {
        await controller.enableBackgroundSync();
        if (mounted) {
          SnackBarService.showSuccess(
            context,
            context.l10n.backgroundSyncEnabled,
          );
        }
      } else {
        await controller.disableBackgroundSync();
        if (mounted) {
          SnackBarService.showSuccess(
            context,
            context.l10n.backgroundSyncDisabled,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          context.l10n.backgroundSyncToggleError,
        );
      }
    }
  }
}

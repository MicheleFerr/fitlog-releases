/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/health_sync/presentation/widgets
/// Feature: health_sync
/// Type: widget
///
/// Apple Watch Status Widget - Shows Watch connection status
///
/// **Features**:
/// - Real-time connection status (paired/unpaired, reachable/not reachable)
/// - App installation status
/// - Last sync timestamp
/// - Tap to open Watch settings
///
/// **Design**:
/// - Compact card layout
/// - Status icon with semantic colors
/// - Theme-aware (dark/light mode)
/// - Localized strings
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/watch_connectivity_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_colors.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Widget that displays Apple Watch connection status
///
/// **Usage**:
/// ```dart
/// WatchStatusWidget()
/// ```
class WatchStatusWidget extends ConsumerWidget {
  const WatchStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchData = ref.watch(watchConnectivityProvider);

    // Don't show widget on platforms that don't support Apple Watch
    if (watchData.state == WatchConnectionState.unavailable) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () => _handleTap(context, ref, watchData),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Watch icon
            SemanticIcon(
              icon: AppIcons.watch,
              semanticLabel: 'Apple Watch',
              size: AppIconSize.large,
              color: _getIconColor(context, watchData.state),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Apple Watch',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Status text
                  Text(
                    _getStatusText(context, watchData),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  // Last sync time
                  if (watchData.lastSyncTime != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _getLastSyncText(context, watchData.lastSyncTime!),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  // Template count
                  if (watchData.templatesCount > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      _getTemplatesText(context, watchData.templatesCount),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Status indicator
            _buildStatusIndicator(context, watchData.state),
          ],
        ),
      ),
    );
  }

  /// Builds status indicator icon
  Widget _buildStatusIndicator(BuildContext context, WatchConnectionState state) {
    final IconData icon;
    final Color color;

    switch (state) {
      case WatchConnectionState.checking:
        icon = AppIcons.pending;
        color = context.iconSecondary;
      case WatchConnectionState.notPaired:
        icon = AppIcons.linkOff;
        color = context.iconError;
      case WatchConnectionState.appNotInstalled:
        icon = AppIcons.download;
        color = context.iconWarning;
      case WatchConnectionState.notReachable:
        icon = AppIcons.cloudOff;
        color = context.iconWarning;
      case WatchConnectionState.connected:
        icon = AppIcons.checkCircle;
        color = context.iconSuccess;
      case WatchConnectionState.unavailable:
        icon = AppIcons.close;
        color = context.iconSecondary;
    }

    return SemanticIcon(
      icon: icon,
      semanticLabel: state.name,
      size: AppIconSize.large,
      color: color,
    );
  }

  /// Gets icon color based on connection state
  Color _getIconColor(BuildContext context, WatchConnectionState state) {
    switch (state) {
      case WatchConnectionState.connected:
        return context.iconSuccess;
      case WatchConnectionState.notReachable:
      case WatchConnectionState.appNotInstalled:
        return context.iconWarning;
      case WatchConnectionState.notPaired:
        return context.iconError;
      case WatchConnectionState.checking:
      case WatchConnectionState.unavailable:
        return context.iconSecondary;
    }
  }

  /// Gets status text based on connection state
  String _getStatusText(BuildContext context, WatchConnectivityData watchData) {
    switch (watchData.state) {
      case WatchConnectionState.checking:
        return 'Checking connection...';
      case WatchConnectionState.notPaired:
        return 'Watch not paired';
      case WatchConnectionState.appNotInstalled:
        return 'Install Watch app to sync workouts';
      case WatchConnectionState.notReachable:
        return 'Watch not reachable';
      case WatchConnectionState.connected:
        return 'Connected and ready';
      case WatchConnectionState.unavailable:
        return 'Not available on this platform';
    }
  }

  /// Gets last sync time text
  String _getLastSyncText(BuildContext context, DateTime lastSyncTime) {
    final relative = timeago.format(lastSyncTime);
    return 'Last synced $relative';
  }

  /// Gets templates count text
  String _getTemplatesText(BuildContext context, int count) {
    return '$count templates synced';
  }

  /// Handles tap on widget
  void _handleTap(
    BuildContext context,
    WidgetRef ref,
    WatchConnectivityData watchData,
  ) {
    switch (watchData.state) {
      case WatchConnectionState.connected:
      case WatchConnectionState.notReachable:
        // Show options sheet
        _showOptionsSheet(context, ref, watchData);
      case WatchConnectionState.notPaired:
      case WatchConnectionState.appNotInstalled:
        // Open Watch app settings
        ref.read(watchConnectivityProvider.notifier).openWatchSettings();
      case WatchConnectionState.checking:
      case WatchConnectionState.unavailable:
        // Do nothing
        break;
    }
  }

  /// Shows bottom sheet with watch options
  void _showOptionsSheet(
    BuildContext context,
    WidgetRef ref,
    WatchConnectivityData watchData,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Apple Watch',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Status
            Text(
              _getStatusText(context, watchData),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Refresh status button
            ListTile(
              leading: SemanticIcon(
                icon: AppIcons.refresh,
                semanticLabel: 'Refresh status',
                size: AppIconSize.medium,
                color: context.iconPrimary,
              ),
              title: const Text('Refresh Status'),
              onTap: () {
                ref.read(watchConnectivityProvider.notifier).checkWatchStatus();
                Navigator.pop(context);
              },
            ),

            // Open settings button
            ListTile(
              leading: SemanticIcon(
                icon: AppIcons.settings,
                semanticLabel: 'Open settings',
                size: AppIconSize.medium,
                color: context.iconPrimary,
              ),
              title: const Text('Open Watch Settings'),
              onTap: () {
                ref.read(watchConnectivityProvider.notifier).openWatchSettings();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

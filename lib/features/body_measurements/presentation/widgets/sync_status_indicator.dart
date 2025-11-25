import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/measurement_repository_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/consent_repository_provider.dart';
import 'package:gymbro_flutter_new/features/ai_coach/presentation/screens/healthkit_debug_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:timeago/timeago.dart' as timeago;

/// SyncStatusIndicator - Display sync status for HealthKit/Health Connect
///
/// **Features**:
/// - Shows sync status (synced, syncing, error, never synced)
/// - Displays platform (HealthKit on iOS, Health Connect on Android)
/// - Shows last sync timestamp
/// - Displays sync counts (measurements read/written)
/// - Manual sync button
/// - Theme-aware colors
/// - Fully localized (EN/IT)
///
/// **Usage**:
/// ```dart
/// SyncStatusIndicator(userId: currentUser.uid)
/// ```
class SyncStatusIndicator extends ConsumerStatefulWidget {
  const SyncStatusIndicator({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  ConsumerState<SyncStatusIndicator> createState() =>
      _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends ConsumerState<SyncStatusIndicator> {
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  SyncResult? _lastSyncResult;

  @override
  void initState() {
    super.initState();
    _loadLastSyncTime();
  }

  /// Load last sync timestamp
  Future<void> _loadLastSyncTime() async {
    final measurementRepo = ref.read(measurementRepositoryProvider);
    final result = await measurementRepo.getLastSyncTimestamp(widget.userId);

    result.fold(
      (failure) {
        // Ignore error, just show "Never synced"
      },
      (timestamp) {
        if (!mounted) return;
        setState(() {
          _lastSyncTime = timestamp;
        });
      },
    );
  }

  /// Handle manual sync
  Future<void> _handleSync() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      // Get consented metrics
      final consentRepo = ref.read(consentRepositoryProvider);
      final consentResult =
          await consentRepo.getConsentedMetrics(widget.userId);

      List<MetricType> consentedMetrics = [];
      consentResult.fold(
        (failure) {
          throw Exception('Failed to get consented metrics: $failure');
        },
        (metrics) {
          consentedMetrics = metrics;
        },
      );

      if (consentedMetrics.isEmpty) {
        if (!mounted) return;
        SnackBarService.showError(
          context,
          'No consented metrics. Please grant consent first.',
        );
        setState(() {
          _isSyncing = false;
        });
        return;
      }

      // Perform sync
      final measurementRepo = ref.read(measurementRepositoryProvider);
      final syncResult = await measurementRepo.syncWithHealthPlatform(
        userId: widget.userId,
        consentedMetrics: consentedMetrics,
        direction: SyncDirection.both,
      );

      syncResult.fold(
        (failure) {
          if (!mounted) return;
          SnackBarService.showError(
            context,
            context.l10n.bodyMeasurementsSyncStatusError(failure.toString()),
          );
        },
        (result) {
          if (!mounted) return;
          setState(() {
            _lastSyncResult = result;
            _lastSyncTime = result.syncedAt;
          });

          SnackBarService.showSuccess(
            context,
            '${context.l10n.bodyMeasurementsSyncMeasurementsRead(result.readCount)}, ${context.l10n.bodyMeasurementsSyncMeasurementsWritten(result.writeCount)}',
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      SnackBarService.showError(
        context,
        'Sync failed: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  /// Get platform name
  String _getPlatformName() {
    if (Platform.isIOS) {
      return 'HealthKit';
    } else if (Platform.isAndroid) {
      return 'Health Connect';
    } else {
      return 'Health Platform';
    }
  }

  /// Format last sync time
  String _formatLastSyncTime() {
    if (_lastSyncTime == null) {
      return context.l10n.bodyMeasurementsSyncNeverSynced;
    }

    // Use timeago for relative time
    final locale = Localizations.localeOf(context).languageCode;
    return timeago.format(_lastSyncTime!, locale: locale);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with platform icon and name
            Row(
              children: [
                Icon(
                  Platform.isIOS
                      ? Icons.apple
                      : Platform.isAndroid
                          ? Icons.android
                          : Icons.health_and_safety,
                  color: context.colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPlatformName(),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _isSyncing
                            ? context.l10n.bodyMeasurementsSyncStatusSyncing
                            : context.l10n.bodyMeasurementsSyncStatusConnected(
                                _getPlatformName()),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: _isSyncing
                              ? context.colors.primary
                              : context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Manual sync button
                FilledButton.icon(
                  onPressed: _isSyncing ? null : _handleSync,
                  icon: _isSyncing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.colors.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.sync),
                  label: Text(context.l10n.bodyMeasurementsSyncNow),
                ),

                // DEBUG: HealthKit diagnostic button (temporary for testing)
                if (Platform.isIOS && kDebugMode) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HealthKitDebugScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Debug'),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: context.colors.outlineVariant),
            const SizedBox(height: 16),

            // Last sync info
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.bodyMeasurementsSyncLastSync(
                    _formatLastSyncTime(),
                  ),
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),

            // Sync counts (if available)
            if (_lastSyncResult != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSyncCount(
                      icon: Icons.download,
                      label: context.l10n
                          .bodyMeasurementsSyncMeasurementsRead(
                        _lastSyncResult!.readCount,
                      ),
                      count: _lastSyncResult!.readCount,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSyncCount(
                      icon: Icons.upload,
                      label: context.l10n
                          .bodyMeasurementsSyncMeasurementsWritten(
                        _lastSyncResult!.writeCount,
                      ),
                      count: _lastSyncResult!.writeCount,
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

  /// Build sync count display
  Widget _buildSyncCount({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: context.colors.primary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

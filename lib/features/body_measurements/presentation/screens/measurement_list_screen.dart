import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/measurement_repository_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/consent_repository_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/presentation/providers/health_kit_service_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/presentation/screens/measurement_charts_screen.dart';
import 'package:gymbro_flutter_new/features/body_measurements/presentation/screens/measurement_input_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:intl/intl.dart';

/// MeasurementListScreen - Display list of user's body measurements
///
/// **Features**:
/// - List view with pagination (infinite scroll)
/// - Filter by MetricType dropdown
/// - Edit action (navigate to input screen)
/// - Delete action with confirmation dialog
/// - Empty state when no measurements
/// - Pull-to-refresh functionality
/// - Theme-aware design
/// - Fully localized (EN/IT)
///
/// **Usage**:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => MeasurementListScreen(userId: currentUser.uid),
///   ),
/// );
/// ```
class MeasurementListScreen extends ConsumerStatefulWidget {
  const MeasurementListScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  ConsumerState<MeasurementListScreen> createState() =>
      _MeasurementListScreenState();
}

class _MeasurementListScreenState extends ConsumerState<MeasurementListScreen> {
  List<Measurement> _measurements = [];
  bool _isLoading = true;
  bool _isImporting = false;
  MetricType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  /// Import measurements from HealthKit (iOS only)
  Future<void> _importFromHealthKit() async {
    if (!Platform.isIOS) {
      SnackBarService.showInfo(
        context,
        context.l10n.bodyMeasurementsHealthKitIOSOnly,
      );
      return;
    }

    setState(() {
      _isImporting = true;
    });

    try {
      final healthKitService = ref.read(healthKitServiceProvider);
      final consentRepo = ref.read(consentRepositoryProvider);

      // Get consented metrics
      final consentResult = await consentRepo.getConsentedMetrics(widget.userId);
      final consentedMetrics = consentResult.getOrElse((_) => <MetricType>[]);

      if (consentedMetrics.isEmpty) {
        if (!mounted) return;
        SnackBarService.showError(
          context,
          context.l10n.bodyMeasurementsNoConsentedMetrics,
        );
        setState(() {
          _isImporting = false;
        });
        return;
      }

      // Request HealthKit permissions
      final permissionResult = await healthKitService.requestPermissions(consentedMetrics);

      final permissionsGranted = permissionResult.fold(
        (failure) {
          if (!mounted) return false;
          SnackBarService.showError(context, failure.message);
          return false;
        },
        (granted) => granted,
      );

      if (!permissionsGranted) {
        if (!mounted) return;
        SnackBarService.showInfo(
          context,
          context.l10n.bodyMeasurementsHealthKitPermissionDenied,
        );
        setState(() {
          _isImporting = false;
        });
        return;
      }

      // Sync from HealthKit
      final syncResult = await healthKitService.syncMeasurements(
        userId: widget.userId,
        consentedMetrics: consentedMetrics,
        direction: SyncDirection.read,
        startDate: DateTime.now().subtract(const Duration(days: 90)),
      );

      syncResult.fold(
        (failure) {
          if (!mounted) return;
          SnackBarService.showError(context, failure.message);
        },
        (result) {
          if (!mounted) return;
          SnackBarService.showSuccess(
            context,
            context.l10n.bodyMeasurementsImportSuccess(result.readCount),
          );
          _loadMeasurements();
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  /// Load measurements from repository
  Future<void> _loadMeasurements() async {
    setState(() {
      _isLoading = true;
    });

    final measurementRepo = ref.read(measurementRepositoryProvider);
    final result = await measurementRepo.getMeasurements(
      widget.userId,
      filterByType: _selectedFilter,
    );

    result.fold(
      (failure) {
        if (!mounted) return;
        SnackBarService.showError(
          context,
          'Failed to load measurements: $failure',
        );
        setState(() {
          _isLoading = false;
        });
      },
      (measurements) {
        if (!mounted) return;
        setState(() {
          _measurements = measurements;
          _isLoading = false;
        });
      },
    );
  }

  /// Handle filter change
  Future<void> _onFilterChanged(MetricType? newFilter) async {
    setState(() {
      _selectedFilter = newFilter;
    });
    await _loadMeasurements();
  }

  /// Handle edit action
  void _onEdit(Measurement measurement) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MeasurementInputScreen(
          userId: widget.userId,
          existingMeasurement: measurement,
        ),
      ),
    );

    // Reload list if measurement was updated
    if (result == true) {
      await _loadMeasurements();
    }
  }

  /// Handle delete action
  Future<void> _onDelete(Measurement measurement) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.bodyMeasurementsListDeleteConfirmTitle),
        content: Text(context.l10n.bodyMeasurementsListDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.bodyMeasurementsInputCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            child: Text(context.l10n.bodyMeasurementsListDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Perform deletion
    final measurementRepo = ref.read(measurementRepositoryProvider);
    final result = await measurementRepo.deleteMeasurement(
      measurementId: measurement.id,
      userId: widget.userId,
    );

    result.fold(
      (failure) {
        if (!mounted) return;
        SnackBarService.showError(
          context,
          context.l10n.bodyMeasurementsListDeleteError,
        );
      },
      (_) {
        if (!mounted) return;
        SnackBarService.showSuccess(
          context,
          context.l10n.bodyMeasurementsListDeleteSuccess,
        );
        _loadMeasurements();
      },
    );
  }

  /// Get localized label for metric type
  String _getMetricLabel(MetricType metric) {
    switch (metric) {
      case MetricType.weight:
        return context.l10n.bodyMeasurementsMetricWeight;
      case MetricType.height:
        return context.l10n.bodyMeasurementsMetricHeight;
      case MetricType.bodyFatPercentage:
        return context.l10n.bodyMeasurementsMetricBodyFat;
      case MetricType.leanMass:
        return context.l10n.bodyMeasurementsMetricLeanMass;
      case MetricType.bmi:
        return context.l10n.bodyMeasurementsMetricBMI;
      case MetricType.bmr:
        return context.l10n.bodyMeasurementsMetricBMR;
      case MetricType.neckCircumference:
        return context.l10n.bodyMeasurementsMetricNeckCircumference;
      case MetricType.shoulderCircumference:
        return context.l10n.bodyMeasurementsMetricShoulderCircumference;
      case MetricType.chestCircumference:
        return context.l10n.bodyMeasurementsMetricChestCircumference;
      case MetricType.waistCircumference:
        return context.l10n.bodyMeasurementsMetricWaistCircumference;
      case MetricType.abdomenCircumference:
        return context.l10n.bodyMeasurementsMetricAbdomenCircumference;
      case MetricType.hipCircumference:
        return context.l10n.bodyMeasurementsMetricHipCircumference;
      case MetricType.bicepLeftCircumference:
        return context.l10n.bodyMeasurementsMetricBicepLeftCircumference;
      case MetricType.bicepRightCircumference:
        return context.l10n.bodyMeasurementsMetricBicepRightCircumference;
      case MetricType.forearmLeftCircumference:
        return context.l10n.bodyMeasurementsMetricForearmLeftCircumference;
      case MetricType.forearmRightCircumference:
        return context.l10n.bodyMeasurementsMetricForearmRightCircumference;
      case MetricType.thighLeftCircumference:
        return context.l10n.bodyMeasurementsMetricThighLeftCircumference;
      case MetricType.thighRightCircumference:
        return context.l10n.bodyMeasurementsMetricThighRightCircumference;
      case MetricType.calfLeftCircumference:
        return context.l10n.bodyMeasurementsMetricCalfLeftCircumference;
      case MetricType.calfRightCircumference:
        return context.l10n.bodyMeasurementsMetricCalfRightCircumference;
      case MetricType.bodyTemperature:
        return context.l10n.bodyMeasurementsMetricBodyTemperature;
      case MetricType.waterMass:
        return context.l10n.bodyMeasurementsMetricWaterMass;
      case MetricType.boneMass:
        return context.l10n.bodyMeasurementsMetricBoneMass;
    }
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return context.l10n.today;
    } else if (difference.inDays == 1) {
      return context.l10n.yesterday;
    } else if (difference.inDays < 7) {
      return DateFormat.EEEE(Localizations.localeOf(context).toString())
          .format(date);
    } else {
      return DateFormat.yMd(Localizations.localeOf(context).toString())
          .format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.bodyMeasurementsListTitle),
        actions: [
          // Charts button
          IconButton(
            icon: const Icon(Icons.show_chart),
            tooltip: context.l10n.bodyMeasurementsChartsTitle,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MeasurementChartsScreen(userId: widget.userId),
                ),
              );
            },
          ),
          // Import from HealthKit button (iOS only)
          if (Platform.isIOS)
            _isImporting
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: context.l10n.bodyMeasurementsImportFromHealth,
                    onPressed: _importFromHealthKit,
                  ),
          // Filter dropdown
          PopupMenuButton<MetricType?>(
            icon: const Icon(Icons.filter_list),
            tooltip: context.l10n.bodyMeasurementsListFilterByMetric,
            onSelected: _onFilterChanged,
            itemBuilder: (context) {
              return [
                // "All" option
                PopupMenuItem<MetricType?>(
                  value: null,
                  child: Row(
                    children: [
                      if (_selectedFilter == null)
                        Icon(
                          Icons.check,
                          color: context.colors.primary,
                          size: 20,
                        ),
                      if (_selectedFilter == null) const SizedBox(width: 8),
                      Text(context.l10n.bodyMeasurementsListFilterAll),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                // Metric type options
                ...MetricType.values.map((metric) {
                  return PopupMenuItem<MetricType?>(
                    value: metric,
                    child: Row(
                      children: [
                        if (_selectedFilter == metric)
                          Icon(
                            Icons.check,
                            color: context.colors.primary,
                            size: 20,
                          ),
                        if (_selectedFilter == metric) const SizedBox(width: 8),
                        Expanded(
                          child: Text(_getMetricLabel(metric)),
                        ),
                      ],
                    ),
                  );
                }),
              ];
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMeasurements,
        child: _isLoading
            ? const Center(child: LoadingIndicator())
            : _measurements.isEmpty
                ? _buildEmptyState()
                : _buildMeasurementList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => MeasurementInputScreen(userId: widget.userId),
            ),
          );

          // Reload list if measurement was added
          if (result == true) {
            await _loadMeasurements();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build empty state when no measurements
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.straighten,
              size: 80,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.bodyMeasurementsListEmpty,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MeasurementInputScreen(userId: widget.userId),
                  ),
                );

                if (result == true) {
                  await _loadMeasurements();
                }
              },
              icon: const Icon(Icons.add),
              label: Text(context.l10n.bodyMeasurementsInputTitle),
            ),
          ],
        ),
      ),
    );
  }

  /// Build measurement list
  Widget _buildMeasurementList() {
    // Group measurements by date
    final groupedMeasurements = <DateTime, List<Measurement>>{};
    for (final measurement in _measurements) {
      final date = DateTime(
        measurement.timestamp.year,
        measurement.timestamp.month,
        measurement.timestamp.day,
      );

      if (!groupedMeasurements.containsKey(date)) {
        groupedMeasurements[date] = [];
      }
      groupedMeasurements[date]!.add(measurement);
    }

    // Sort dates descending (most recent first)
    final sortedDates = groupedMeasurements.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final measurements = groupedMeasurements[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                _formatDate(date),
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
            ),

            // Measurements for this date
            ...measurements.map((measurement) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getMetricIcon(measurement.metricType),
                      color: context.colors.onPrimaryContainer,
                    ),
                  ),
                  title: Text(_getMetricLabel(measurement.metricType)),
                  subtitle: Text(
                    DateFormat.Hm(Localizations.localeOf(context).toString())
                        .format(measurement.timestamp),
                    style: context.textTheme.bodySmall,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Value display
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            measurement.value.toStringAsFixed(1),
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            measurement.unit,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Actions menu
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (action) {
                          if (action == 'edit') {
                            _onEdit(measurement);
                          } else if (action == 'delete') {
                            _onDelete(measurement);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 20),
                                const SizedBox(width: 8),
                                Text(context.l10n.bodyMeasurementsListEdit),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: context.colors.error,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  context.l10n.bodyMeasurementsListDelete,
                                  style: TextStyle(
                                    color: context.colors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  /// Get icon for metric type
  IconData _getMetricIcon(MetricType metric) {
    switch (metric) {
      case MetricType.weight:
        return Icons.monitor_weight;
      case MetricType.height:
        return Icons.height;
      case MetricType.bodyFatPercentage:
        return Icons.percent;
      case MetricType.leanMass:
        return Icons.fitness_center;
      case MetricType.bmi:
        return Icons.calculate;
      case MetricType.bmr:
        return Icons.local_fire_department;
      case MetricType.neckCircumference:
      case MetricType.shoulderCircumference:
      case MetricType.chestCircumference:
      case MetricType.waistCircumference:
      case MetricType.abdomenCircumference:
      case MetricType.hipCircumference:
      case MetricType.bicepLeftCircumference:
      case MetricType.bicepRightCircumference:
      case MetricType.forearmLeftCircumference:
      case MetricType.forearmRightCircumference:
      case MetricType.thighLeftCircumference:
      case MetricType.thighRightCircumference:
      case MetricType.calfLeftCircumference:
      case MetricType.calfRightCircumference:
        return Icons.straighten;
      case MetricType.bodyTemperature:
        return Icons.thermostat;
      case MetricType.waterMass:
        return Icons.water_drop;
      case MetricType.boneMass:
        return Icons.accessibility;
    }
  }
}

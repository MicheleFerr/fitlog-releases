import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/measurement_repository_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/consent_repository_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/consent_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/presentation/providers/health_kit_service_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/presentation/screens/measurement_charts_screen.dart';
import 'package:gymbro_flutter_new/features/body_measurements/presentation/screens/measurement_input_screen.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/metric_display.dart';
import 'package:intl/intl.dart';

/// MeasurementListScreen - Dashboard-style display of body measurements
///
/// Shows metric cards grid (always visible), collapsible sections,
/// and recent measurement history below.
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
  Map<MetricType, Measurement> _latestByType = {};
  bool _isLoading = true;
  bool _isImporting = false;
  bool _circumferencesExpanded = false;
  bool _vitalsExpanded = false;

  /// Essential metrics shown as top-level cards
  static const _essentialMetrics = [
    MetricType.weight,
    MetricType.height,
    MetricType.bodyFatPercentage,
    MetricType.bmi,
    MetricType.leanMass,
    MetricType.bmr,
  ];

  /// Circumference metrics
  static const _circumferenceMetrics = [
    MetricType.waistCircumference,
    MetricType.chestCircumference,
    MetricType.shoulderCircumference,
    MetricType.hipCircumference,
    MetricType.neckCircumference,
    MetricType.abdomenCircumference,
    MetricType.bicepLeftCircumference,
    MetricType.bicepRightCircumference,
    MetricType.forearmLeftCircumference,
    MetricType.forearmRightCircumference,
    MetricType.thighLeftCircumference,
    MetricType.thighRightCircumference,
    MetricType.calfLeftCircumference,
    MetricType.calfRightCircumference,
  ];

  /// Vital metrics
  static const _vitalMetrics = [
    MetricType.bodyTemperature,
    MetricType.waterMass,
    MetricType.boneMass,
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final measurementRepo = ref.read(measurementRepositoryProvider);

    // Load latest by type and all measurements in parallel
    final results = await Future.wait([
      measurementRepo.getLatestMeasurementsByType(widget.userId),
      measurementRepo.getMeasurements(widget.userId),
    ]);

    final latestResult = results[0] as dynamic;
    final allResult = results[1] as dynamic;

    if (!mounted) return;

    latestResult.fold(
      (_) {},
      (Map<MetricType, Measurement> latest) {
        _latestByType = latest;
      },
    );

    allResult.fold(
      (failure) {
        SnackBarService.showError(
          context,
          'Failed to load measurements: $failure',
        );
      },
      (List<Measurement> measurements) {
        _measurements = measurements;
      },
    );

    setState(() => _isLoading = false);

    // Auto-expand sections if they have data
    final hasCircumferenceData = _circumferenceMetrics.any(
      (m) => _latestByType.containsKey(m),
    );
    final hasVitalsData = _vitalMetrics.any(
      (m) => _latestByType.containsKey(m),
    );
    if (hasCircumferenceData) {
      setState(() => _circumferencesExpanded = true);
    }
    if (hasVitalsData) {
      setState(() => _vitalsExpanded = true);
    }
  }

  /// Navigate to input screen for a specific metric
  void _onMetricCardTap(MetricType metricType) async {
    final existing = _latestByType[metricType];

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MeasurementInputScreen(
          userId: widget.userId,
          existingMeasurement: existing,
          // Single-metric mode when card has no data (quick add)
          focusedMetric: existing == null ? metricType : null,
        ),
      ),
    );

    if (result == true) {
      await _loadData();
    }
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

    setState(() => _isImporting = true);

    try {
      final healthKitService = ref.read(healthKitServiceProvider);
      final consentRepo = ref.read(consentRepositoryProvider);

      var consentResult = await consentRepo.getConsentedMetrics(widget.userId);
      var consentedMetrics = consentResult.getOrElse((_) => <MetricType>[]);

      if (consentedMetrics.isEmpty) {
        if (!mounted) return;
        final consentGranted = await _showHealthKitConsentDialog();
        if (!consentGranted) {
          if (!mounted) return;
          setState(() => _isImporting = false);
          return;
        }

        consentResult = await consentRepo.getConsentedMetrics(widget.userId);
        consentedMetrics = consentResult.getOrElse((_) => <MetricType>[]);

        if (consentedMetrics.isEmpty) {
          if (!mounted) return;
          SnackBarService.showError(
            context,
            context.l10n.bodyMeasurementsNoConsentedMetrics,
          );
          setState(() => _isImporting = false);
          return;
        }
      }

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
        setState(() => _isImporting = false);
        return;
      }

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
        (result) async {
          // Save imported measurements to local repository
          if (result.importedMeasurements.isNotEmpty) {
            final measurementRepo = ref.read(measurementRepositoryProvider);
            for (final measurement in result.importedMeasurements) {
              await measurementRepo.addMeasurement(
                measurement,
                hasConsent: true, // Already verified consent above
              );
            }
          }
          if (!mounted) return;
          SnackBarService.showSuccess(
            context,
            context.l10n.bodyMeasurementsImportSuccess(result.readCount),
          );
          _loadData();
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  /// Export measurements to HealthKit (iOS only)
  Future<void> _exportToHealthKit() async {
    if (!Platform.isIOS) return;

    setState(() => _isImporting = true);

    try {
      final healthKitService = ref.read(healthKitServiceProvider);
      final consentRepo = ref.read(consentRepositoryProvider);

      final consentResult = await consentRepo.getConsentedMetrics(widget.userId);
      final consentedMetrics = consentResult.getOrElse((_) => <MetricType>[]);

      if (consentedMetrics.isEmpty) {
        if (!mounted) return;
        SnackBarService.showError(
          context,
          context.l10n.bodyMeasurementsNoConsentedMetrics,
        );
        return;
      }

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
        return;
      }

      final syncResult = await healthKitService.syncMeasurements(
        userId: widget.userId,
        consentedMetrics: consentedMetrics,
        direction: SyncDirection.write,
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        measurements: _measurements,
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
            context.l10n.bodyMeasurementsExportSuccess(result.writeCount),
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  /// Show HealthKit consent dialog and handle consent grant
  Future<bool> _showHealthKitConsentDialog() async {
    final l10n = context.l10n;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(AppIcons.healthAndSafety, color: context.colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l10n.bodyMeasurementsHealthKitConsentTitle),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.bodyMeasurementsHealthKitConsentDescription),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.bodyMeasurementsHealthKitConsentDataTypes,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildConsentDataItem(l10n.bodyMeasurementsMetricWeight),
                    _buildConsentDataItem(l10n.bodyMeasurementsMetricBodyFat),
                    _buildConsentDataItem(l10n.bodyMeasurementsMetricHeight),
                    _buildConsentDataItem(l10n.bodyMeasurementsMetricLeanMass),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    AppIcons.shield,
                    color: context.colors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.bodyMeasurementsHealthKitConsentPrivacy,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.bodyMeasurementsInputCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.bodyMeasurementsHealthKitConsentGrant),
          ),
        ],
      ),
    );

    if (result != true) return false;

    final consentRepo = ref.read(consentRepositoryProvider);
    final existingConsent = await consentRepo.getConsent(widget.userId);

    if (existingConsent.isLeft()) {
      final createResult = await consentRepo.createInitialConsent(
        userId: widget.userId,
        ipAddress: '0.0.0.0',
      );

      final createFailed = createResult.fold(
        (failure) => failure,
        (_) => null,
      );

      if (createFailed != null) {
        if (mounted) {
          SnackBarService.showError(
            context,
            'Failed to create consent: ${_getConsentFailureMessage(createFailed)}',
          );
        }
        return false;
      }
    }

    final grantResult = await consentRepo.grantConsent(
      userId: widget.userId,
      group: MetricGroup.essential,
      ipAddress: '0.0.0.0',
    );

    final grantFailed = grantResult.fold(
      (failure) => failure,
      (_) => null,
    );

    if (grantFailed != null) {
      if (mounted) {
        SnackBarService.showError(
          context,
          'Failed to save consent: ${_getConsentFailureMessage(grantFailed)}',
        );
      }
      return false;
    }

    if (mounted) {
      SnackBarService.showSuccess(
        context,
        context.l10n.bodyMeasurementsHealthKitConsentGranted,
      );
    }

    return true;
  }

  Widget _buildConsentDataItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(AppIcons.check, size: 16, color: context.colors.primary),
          const SizedBox(width: 8),
          Text(text, style: context.textTheme.bodySmall),
        ],
      ),
    );
  }

  String _getConsentFailureMessage(ConsentFailure failure) {
    return switch (failure) {
      FirebaseConsentFailure(:final message) => message,
      ConsentNotFoundFailure() => 'Consent record not found',
      ConsentAlreadyExistsFailure() => 'Consent already exists',
      InvalidVersionFailure(:final currentVersion, :final attemptedVersion) =>
        'Invalid version: $attemptedVersion (current: $currentVersion)',
      RateLimitExceededFailure(:final limitPerDay, :final currentCount) =>
        'Rate limit exceeded: $currentCount/$limitPerDay',
    };
  }

  /// Handle delete action
  Future<void> _onDelete(Measurement measurement) async {
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
        _loadData();
      },
    );
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

    if (result == true) {
      await _loadData();
    }
  }

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

  IconData _getMetricIcon(MetricType metric) {
    switch (metric) {
      case MetricType.weight:
        return AppIcons.weight;
      case MetricType.height:
        return AppIcons.height;
      case MetricType.bodyFatPercentage:
        return AppIcons.percent;
      case MetricType.leanMass:
        return AppIcons.workout;
      case MetricType.bmi:
        return AppIcons.calculate;
      case MetricType.bmr:
        return AppIcons.streak;
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
        return AppIcons.straighten;
      case MetricType.bodyTemperature:
        return AppIcons.thermostat;
      case MetricType.waterMass:
        return AppIcons.waterDrop;
      case MetricType.boneMass:
        return AppIcons.accessibility;
    }
  }

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

  /// Compute trend text for a metric by comparing last two values
  String? _getTrendText(MetricType metricType) {
    final filtered = _measurements
        .where((m) => m.metricType == metricType)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (filtered.length < 2) return null;

    final diff = filtered[0].value - filtered[1].value;
    if (diff == 0) return null;
    final sign = diff > 0 ? '+' : '';
    return '$sign${diff.toStringAsFixed(1)}';
  }

  TrendDirection? _getTrendDirection(MetricType metricType) {
    final filtered = _measurements
        .where((m) => m.metricType == metricType)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (filtered.length < 2) return null;

    final diff = filtered[0].value - filtered[1].value;
    if (diff > 0) return TrendDirection.up;
    if (diff < 0) return TrendDirection.down;
    return TrendDirection.neutral;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.bodyMeasurementsListTitle),
        actions: [
          // Charts button
          IconButton(
            icon: const Icon(AppIcons.lineChart),
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
          // Apple Health sync menu (iOS only)
          if (Platform.isIOS)
            _isImporting
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: LoadingIndicator(size: 20),
                  )
                : PopupMenuButton<String>(
                    icon: const Icon(AppIcons.healthAndSafety),
                    tooltip: context.l10n.bodyMeasurementsSyncWithHealth,
                    onSelected: (action) {
                      if (action == 'import') {
                        _importFromHealthKit();
                      } else if (action == 'export') {
                        _exportToHealthKit();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'import',
                        child: Row(
                          children: [
                            const Icon(AppIcons.download, size: 20),
                            const SizedBox(width: 8),
                            Text(context.l10n.bodyMeasurementsImportFromHealth),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            const Icon(AppIcons.upload, size: 20),
                            const SizedBox(width: 8),
                            Text(context.l10n.bodyMeasurementsExportToHealth),
                          ],
                        ),
                      ),
                    ],
                  ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: LoadingIndicator())
            : _buildDashboard(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => MeasurementInputScreen(userId: widget.userId),
            ),
          );
          if (result == true) {
            await _loadData();
          }
        },
        child: const Icon(AppIcons.add),
      ),
    );
  }

  Widget _buildDashboard() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // A) Essential Metrics Dashboard
        _buildSectionHeader(context.l10n.bodyMeasurementsEssentialMetrics),
        const SizedBox(height: 8),
        _buildMetricGrid(_essentialMetrics),

        const SizedBox(height: 24),

        // B) Circumferences (collapsible)
        _buildCollapsibleSection(
          title: context.l10n.bodyMeasurementsCircumferences,
          metrics: _circumferenceMetrics,
          isExpanded: _circumferencesExpanded,
          onToggle: () => setState(() {
            _circumferencesExpanded = !_circumferencesExpanded;
          }),
        ),

        const SizedBox(height: 16),

        // C) Vitals (collapsible)
        _buildCollapsibleSection(
          title: context.l10n.bodyMeasurementsVitals,
          metrics: _vitalMetrics,
          isExpanded: _vitalsExpanded,
          onToggle: () => setState(() {
            _vitalsExpanded = !_vitalsExpanded;
          }),
        ),

        const SizedBox(height: 24),

        // D) Recent history
        if (_measurements.isNotEmpty) ...[
          _buildSectionHeader(context.l10n.bodyMeasurementsRecentHistory),
          const SizedBox(height: 8),
          _buildRecentHistory(),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: context.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.colors.primary,
      ),
    );
  }

  Widget _buildMetricGrid(List<MetricType> metrics) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        final latest = _latestByType[metric];
        final hasData = latest != null;
        final trendText = _getTrendText(metric);
        final trendDir = _getTrendDirection(metric);

        return MetricCard(
          label: _getMetricLabel(metric),
          value: hasData
              ? latest.value.toStringAsFixed(1)
              : context.l10n.bodyMeasurementsNoData,
          unit: hasData ? latest.unit : null,
          icon: _getMetricIcon(metric),
          trend: trendDir,
          trendValue: trendText,
          size: MetricSize.small,
          onTap: () => _onMetricCardTap(metric),
          backgroundColor: hasData
              ? null
              : context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
        );
      },
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required List<MetricType> metrics,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    final hasAnyData = metrics.any((m) => _latestByType.containsKey(m));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  isExpanded ? AppIcons.expandLess : AppIcons.expandMore,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
                if (!hasAnyData) ...[
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.bodyMeasurementsTapToAdd,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          _buildMetricGrid(metrics),
        ],
      ],
    );
  }

  Widget _buildRecentHistory() {
    // Group measurements by date (show only last 20)
    final recentMeasurements = _measurements.take(20).toList();
    final groupedMeasurements = <DateTime, List<Measurement>>{};

    for (final measurement in recentMeasurements) {
      final date = DateTime(
        measurement.timestamp.year,
        measurement.timestamp.month,
        measurement.timestamp.day,
      );
      groupedMeasurements.putIfAbsent(date, () => []).add(measurement);
    }

    final sortedDates = groupedMeasurements.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedDates.map((date) {
        final measurements = groupedMeasurements[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                _formatDate(date),
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            ...measurements.map((measurement) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getMetricIcon(measurement.metricType),
                      color: context.colors.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _getMetricLabel(measurement.metricType),
                    style: context.textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    DateFormat.Hm(Localizations.localeOf(context).toString())
                        .format(measurement.timestamp),
                    style: context.textTheme.bodySmall,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: measurement.value.toStringAsFixed(1),
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' ${measurement.unit}',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          AppIcons.moreVert,
                          size: 20,
                          color: context.colors.onSurfaceVariant,
                        ),
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
                                const Icon(AppIcons.edit, size: 20),
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
                                  AppIcons.delete,
                                  size: 20,
                                  color: context.colors.error,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  context.l10n.bodyMeasurementsListDelete,
                                  style: context.textTheme.bodyMedium?.copyWith(
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
      }).toList(),
    );
  }
}

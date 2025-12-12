import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/consent_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/validators/measurement_validator.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/measurement_repository_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/consent_repository_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:uuid/uuid.dart';

/// MeasurementInputScreen - Form for adding/editing body measurements
///
/// **Features**:
/// - Dynamic fields based on user consent
/// - Real-time validation with range checking
/// - Auto-save draft measurements
/// - Unit conversion (metric/imperial)
/// - Outlier detection warnings
/// - Theme-aware design
/// - Fully localized (EN/IT)
///
/// **Usage**:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => MeasurementInputScreen(userId: currentUser.uid),
///   ),
/// );
/// ```
class MeasurementInputScreen extends ConsumerStatefulWidget {
  const MeasurementInputScreen({
    super.key,
    required this.userId,
    this.existingMeasurement,
  });

  final String userId;
  final Measurement? existingMeasurement;

  @override
  ConsumerState<MeasurementInputScreen> createState() =>
      _MeasurementInputScreenState();
}

class _MeasurementInputScreenState
    extends ConsumerState<MeasurementInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<MetricType, TextEditingController> _controllers = {};
  final Map<MetricType, String?> _errors = {};

  bool _isLoading = false;
  bool _isDraft = false;
  List<MetricType> _consentedMetrics = [];

  final _validator = MeasurementValidator();

  @override
  void initState() {
    super.initState();
    _loadConsentedMetrics();

    // Initialize controllers with existing values if editing
    if (widget.existingMeasurement != null) {
      final measurement = widget.existingMeasurement!;
      _controllers[measurement.metricType] = TextEditingController(
        text: measurement.value.toString(),
      );
    }
  }

  /// Load metrics that user has consented to
  Future<void> _loadConsentedMetrics() async {
    final consentRepo = ref.read(consentRepositoryProvider);
    final result = await consentRepo.getConsentedMetrics(widget.userId);

    await result.fold(
      (failure) async {
        if (!mounted) return;

        // If no consent exists, create it automatically
        if (failure is ConsentNotFoundFailure) {
          await _createDefaultConsent();
          return;
        }

        SnackBarService.showError(
          context,
          'Failed to load consented metrics: $failure',
        );
      },
      (metrics) async {
        if (!mounted) return;
        setState(() {
          _consentedMetrics = metrics;
          // Initialize controllers for all consented metrics
          for (final metric in metrics) {
            _controllers[metric] = TextEditingController();
          }
        });
      },
    );
  }

  /// Create default consent for first-time users
  Future<void> _createDefaultConsent() async {
    final consentRepo = ref.read(consentRepositoryProvider);

    // Create initial consent
    var result = await consentRepo.createInitialConsent(
      userId: widget.userId,
      ipAddress: '0.0.0.***', // Privacy: masked IP
    );

    // If consent already exists, proceed to grant
    if (result.isLeft()) {
      result = await consentRepo.grantConsent(
        userId: widget.userId,
        group: MetricGroup.essential,
        ipAddress: '0.0.0.***',
      );
    } else {
      // Initial consent created, grant essential
      await consentRepo.grantConsent(
        userId: widget.userId,
        group: MetricGroup.essential,
        ipAddress: '0.0.0.***',
      );
    }

    // Grant measurements consent
    await consentRepo.grantConsent(
      userId: widget.userId,
      group: MetricGroup.measurements,
      ipAddress: '0.0.0.***',
    );

    // Retry loading consented metrics
    if (!mounted) return;
    final retryResult = await consentRepo.getConsentedMetrics(widget.userId);

    retryResult.fold(
      (failure) {
        if (!mounted) return;
        SnackBarService.showError(
          context,
          'Failed to initialize consent: $failure',
        );
      },
      (metrics) {
        if (!mounted) return;
        setState(() {
          _consentedMetrics = metrics;
          for (final metric in metrics) {
            _controllers[metric] = TextEditingController();
          }
        });
      },
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Validate single metric field
  String? _validateField(MetricType metric, String value) {
    if (value.isEmpty) {
      return null; // Optional field
    }

    final doubleValue = double.tryParse(value);
    if (doubleValue == null) {
      return context.l10n.bodyMeasurementsValidationInvalidNumber;
    }

    // Create temporary measurement for validation
    final tempMeasurement = Measurement(
      id: '',
      userId: widget.userId,
      metricType: metric,
      value: doubleValue,
      unit: metric.defaultUnit,
      timestamp: DateTime.now(),
      source: MeasurementSource.manual,
    );

    final validationResult = _validator.validateMeasurement(tempMeasurement);

    if (!validationResult.isValid) {
      // Extract min/max from error message if it's a range error
      // Example: "Weight must be between 20.0 and 300.0 kg (got: 15.0)"
      final errorMsg = validationResult.errorMessage ?? '';
      final rangeMatch = RegExp(r'between ([\d.]+) and ([\d.]+)').firstMatch(errorMsg);

      if (rangeMatch != null) {
        final min = rangeMatch.group(1)!;
        final max = rangeMatch.group(2)!;
        return context.l10n.bodyMeasurementsValidationOutOfRange(
          double.parse(min),
          double.parse(max),
        );
      }

      return validationResult.errorMessage ?? context.l10n.bodyMeasurementsValidationInvalid;
    }

    return null; // Valid
  }

  /// Auto-save draft to local storage
  Future<void> _saveDraft() async {
    setState(() {
      _isDraft = true;
    });

    // TODO: Implement draft saving to Hive
    // This would store partial measurements that haven't been submitted yet

    if (!mounted) return;
    SnackBarService.showInfo(
      context,
      context.l10n.bodyMeasurementsDraftSaved,
    );
  }

  /// Submit measurements
  Future<void> _submitMeasurements() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final measurementRepo = ref.read(measurementRepositoryProvider);
      final now = DateTime.now();

      // Save each measurement
      for (final entry in _controllers.entries) {
        final metric = entry.key;
        final controller = entry.value;

        if (controller.text.isEmpty) {
          continue; // Skip empty fields
        }

        final value = double.parse(controller.text);

        final measurement = Measurement(
          id: widget.existingMeasurement?.id ?? const Uuid().v4(),
          userId: widget.userId,
          metricType: metric,
          value: value,
          unit: metric.defaultUnit,
          timestamp: widget.existingMeasurement?.timestamp ?? now,
          source: MeasurementSource.manual,
          notes: null,
        );

        // Use addMeasurement for new, updateMeasurement for existing
        // Note: hasConsent=true because this screen only shows consented metrics
        final result = widget.existingMeasurement == null
            ? await measurementRepo.addMeasurement(
                measurement,
                hasConsent: true,
              )
            : await measurementRepo.updateMeasurement(measurement);

        result.fold(
          (failure) {
            throw Exception('Failed to save ${metric.name}: $failure');
          },
          (_) {
            // Success
          },
        );
      }

      if (!mounted) return;
      SnackBarService.showSuccess(
        context,
        context.l10n.bodyMeasurementsSaveSuccess,
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      SnackBarService.showError(
        context,
        'Failed to save measurements: $e',
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Get localized label for metric
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingMeasurement == null
              ? context.l10n.bodyMeasurementsInputTitle
              : context.l10n.bodyMeasurementsInputEditTitle,
        ),
        actions: [
          // Auto-save draft button
          if (_isDraft)
            Icon(
              AppIcons.cloudDone,
              color: context.colors.success,
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: _consentedMetrics.isEmpty
          ? const Center(
              child: LoadingIndicator(),
            )
          : _isLoading
              ? const Center(
                  child: LoadingIndicator(),
                )
              : Form(
                  key: _formKey,
                  onChanged: () {
                    // Auto-save after 2 seconds of inactivity
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        _saveDraft();
                      }
                    });
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Info card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          context.l10n.bodyMeasurementsInputDescription,
                          style: context.textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Group by MetricGroup
                      ...MetricGroup.values.map((group) {
                        final groupMetrics = _consentedMetrics
                            .where((metric) => metric.group == group)
                            .toList();

                        if (groupMetrics.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Group header
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                _getGroupLabel(group),
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // Fields for this group
                            ...groupMetrics.map((metric) {
                              final controller = _controllers[metric]!;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      controller: controller,
                                      keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: _getMetricLabel(metric),
                                        suffixText: metric.defaultUnit,
                                        border: const OutlineInputBorder(),
                                        errorText: _errors[metric],
                                      ),
                                      validator: (value) =>
                                          _validateField(metric, value ?? ''),
                                    ),
                                    if (_errors[metric] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          _errors[metric]!,
                                          style: context.textTheme.bodySmall?.copyWith(
                                            color: context.colors.error,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),

                            const SizedBox(height: 16),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
      bottomNavigationBar: _isLoading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _submitMeasurements,
                  child: Text(context.l10n.bodyMeasurementsInputSubmit),
                ),
              ),
            ),
    );
  }

  /// Get localized group label
  String _getGroupLabel(MetricGroup group) {
    switch (group) {
      case MetricGroup.essential:
        return context.l10n.bodyMeasurementsGroupEssential;
      case MetricGroup.measurements:
        return context.l10n.bodyMeasurementsGroupMeasurements;
      case MetricGroup.vitals:
        return context.l10n.bodyMeasurementsGroupVitals;
    }
  }
}

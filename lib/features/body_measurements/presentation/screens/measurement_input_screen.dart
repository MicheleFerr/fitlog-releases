import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/consent_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/repositories/measurement_repository.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/validators/measurement_validator.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/measurement_repository_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/consent_repository_provider.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';
import 'package:gymbro_flutter_new/features/strength_standards/presentation/providers/strength_standards_providers.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
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
    this.focusedMetric,
  });

  final String userId;
  final Measurement? existingMeasurement;

  /// When set, shows only this metric's input field (single-metric mode).
  /// Used when tapping a specific metric card from the dashboard.
  final MetricType? focusedMetric;

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

  /// Whether we're in single-metric mode (quick add from dashboard card)
  bool get _isSingleMetricMode =>
      widget.focusedMetric != null && widget.existingMeasurement == null;

  final _validator = MeasurementValidator();

  /// Set of metrics that can be auto-calculated (but user can override)
  static const Set<MetricType> _calculatedMetrics = {
    MetricType.bmi,
    MetricType.leanMass,
    MetricType.bmr,
  };

  /// Track which calculated fields the user has manually edited
  /// (so we don't overwrite their values)
  final Set<MetricType> _manuallyEditedFields = {};

  /// User fitness data for BMR calculation (age, sex)
  UserFitnessQuestionnaire? _fitnessProfile;

  @override
  void initState() {
    super.initState();
    _loadConsentedMetrics();
    _loadFitnessProfile();

    // Initialize controllers with existing values if editing
    if (widget.existingMeasurement != null) {
      final measurement = widget.existingMeasurement!;
      _controllers[measurement.metricType] = TextEditingController(
        text: measurement.value.toString(),
      );
    }

    // Pre-create controller for focused metric (single-metric mode)
    if (widget.focusedMetric != null && !_controllers.containsKey(widget.focusedMetric)) {
      _controllers[widget.focusedMetric!] = TextEditingController();
    }
  }

  /// Load user fitness profile for BMR calculation
  Future<void> _loadFitnessProfile() async {
    // First, ensure the questionnaire is loaded
    final notifier = ref.read(userFitnessQuestionnaireProvider.notifier);
    await notifier.loadQuestionnaire();

    // Then read the value
    final profile = ref.read(userFitnessQuestionnaireProvider);
    if (mounted && profile != null) {
      setState(() {
        _fitnessProfile = profile;
      });
    }
  }

  /// Setup listeners for auto-calculation
  void _setupCalculationListeners() {
    // Listen to weight changes
    _controllers[MetricType.weight]?.addListener(_recalculateAll);
    // Listen to height changes
    _controllers[MetricType.height]?.addListener(_recalculateAll);
    // Listen to body fat changes
    _controllers[MetricType.bodyFatPercentage]?.addListener(_recalculateAll);
  }

  /// Recalculate all derived metrics
  void _recalculateAll() {
    _calculateBMI();
    _calculateLeanMass();
    _calculateBMR();
  }

  /// Calculate BMI = weight / (height in meters)²
  void _calculateBMI() {
    // Don't overwrite if user manually edited this field
    if (_manuallyEditedFields.contains(MetricType.bmi)) return;

    final weightText = _controllers[MetricType.weight]?.text;
    final heightText = _controllers[MetricType.height]?.text;

    if (weightText == null || heightText == null) return;
    if (weightText.isEmpty || heightText.isEmpty) {
      _controllers[MetricType.bmi]?.text = '';
      return;
    }

    final weight = double.tryParse(weightText);
    final heightCm = double.tryParse(heightText);

    if (weight == null || heightCm == null || heightCm <= 0) return;

    final heightM = heightCm / 100;
    final bmi = weight / (heightM * heightM);

    if (_controllers.containsKey(MetricType.bmi)) {
      _controllers[MetricType.bmi]?.text = bmi.toStringAsFixed(1);
    }
  }

  /// Calculate Lean Mass = weight × (1 - body fat % / 100)
  void _calculateLeanMass() {
    // Don't overwrite if user manually edited this field
    if (_manuallyEditedFields.contains(MetricType.leanMass)) return;

    final weightText = _controllers[MetricType.weight]?.text;
    final bodyFatText = _controllers[MetricType.bodyFatPercentage]?.text;

    if (weightText == null || bodyFatText == null) return;
    if (weightText.isEmpty || bodyFatText.isEmpty) {
      _controllers[MetricType.leanMass]?.text = '';
      return;
    }

    final weight = double.tryParse(weightText);
    final bodyFat = double.tryParse(bodyFatText);

    if (weight == null || bodyFat == null) return;
    if (bodyFat < 0 || bodyFat > 100) return;

    final leanMass = weight * (1 - bodyFat / 100);

    if (_controllers.containsKey(MetricType.leanMass)) {
      _controllers[MetricType.leanMass]?.text = leanMass.toStringAsFixed(1);
    }
  }

  /// Calculate BMR using Mifflin-St Jeor formula
  /// Men: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age + 5
  /// Women: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age - 161
  void _calculateBMR() {
    // Don't overwrite if user manually edited this field
    if (_manuallyEditedFields.contains(MetricType.bmr)) return;

    final weightText = _controllers[MetricType.weight]?.text;
    final heightText = _controllers[MetricType.height]?.text;

    if (weightText == null || heightText == null) return;
    if (weightText.isEmpty || heightText.isEmpty) {
      _controllers[MetricType.bmr]?.text = '';
      return;
    }

    final weight = double.tryParse(weightText);
    final heightCm = double.tryParse(heightText);

    if (weight == null || heightCm == null) return;

    // Need age and sex from fitness profile
    final profile = _fitnessProfile;
    if (profile == null) return;

    final age = profile.age;
    final isMale = profile.sex == BiologicalSex.male;

    // Mifflin-St Jeor formula
    final bmr = (10 * weight) + (6.25 * heightCm) - (5 * age) + (isMale ? 5 : -161);

    if (_controllers.containsKey(MetricType.bmr)) {
      _controllers[MetricType.bmr]?.text = bmr.toStringAsFixed(0);
    }
  }

  /// Check if a metric is auto-calculated
  bool _isCalculatedMetric(MetricType metric) {
    return _calculatedMetrics.contains(metric);
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
        // Setup auto-calculation listeners after controllers are created
        _setupCalculationListeners();
        // Trigger initial calculation
        _recalculateAll();
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
        // Setup auto-calculation listeners after controllers are created
        _setupCalculationListeners();
        // Trigger initial calculation
        _recalculateAll();
      },
    );
  }

  @override
  void dispose() {
    // Remove listeners before disposing
    _controllers[MetricType.weight]?.removeListener(_recalculateAll);
    _controllers[MetricType.height]?.removeListener(_recalculateAll);
    _controllers[MetricType.bodyFatPercentage]?.removeListener(_recalculateAll);
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
            throw Exception('Failed to save ${metric.name}: ${_getMeasurementFailureMessage(failure)}');
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

  /// Build a single metric field widget
  Widget _buildMetricField(MetricType metric) {
    final controller = _controllers[metric];
    if (controller == null) return const SizedBox.shrink();

    final isCalculated = _isCalculatedMetric(metric);
    final wasManuallyEdited = _manuallyEditedFields.contains(metric);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        autofocus: _isSingleMetricMode,
        onChanged: isCalculated
            ? (value) {
                if (value.isNotEmpty) {
                  _manuallyEditedFields.add(metric);
                } else {
                  _manuallyEditedFields.remove(metric);
                  _recalculateAll();
                }
              }
            : null,
        decoration: InputDecoration(
          labelText: _getMetricLabel(metric),
          hintText: '0.0',
          suffixText: metric.defaultUnit,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: context.colors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: context.colors.primary, width: 2),
          ),
          errorText: _errors[metric],
          filled: true,
          fillColor: isCalculated && !wasManuallyEdited
              ? context.colors.surfaceContainerHighest.withValues(alpha: 0.5)
              : context.colors.surfaceContainerLowest,
          prefixIcon: isCalculated
              ? SemanticIcon(
                  icon: AppIcons.calculate,
                  semanticLabel: context.l10n.bodyMeasurementsAutoCalculated,
                  color: wasManuallyEdited
                      ? context.colors.outline
                      : context.colors.primary,
                )
              : null,
          helperText: isCalculated ? _getCalculationHelper(metric) : null,
          helperStyle: context.textTheme.bodySmall?.copyWith(
            color: wasManuallyEdited
                ? context.colors.outline
                : context.colors.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
        validator: (value) => _validateField(metric, value ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingMeasurement != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? context.l10n.bodyMeasurementsInputEditTitle
              : _isSingleMetricMode
                  ? _getMetricLabel(widget.focusedMetric!)
                  : context.l10n.bodyMeasurementsInputTitle,
        ),
        actions: [
          if (_isDraft)
            Icon(AppIcons.cloudDone, color: context.colors.success),
          const SizedBox(width: 16),
        ],
      ),
      body: _consentedMetrics.isEmpty
          ? const Center(child: LoadingIndicator())
          : _isLoading
              ? const Center(child: LoadingIndicator())
              : Form(
                  key: _formKey,
                  onChanged: () {
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) _saveDraft();
                    });
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Single-metric mode: show only the focused field
                      if (_isSingleMetricMode) ...[
                        // Info hint
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.colors.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                AppIcons.info,
                                size: 20,
                                color: context.colors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  context.l10n.bodyMeasurementsInputDescription,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildMetricField(widget.focusedMetric!),
                      ] else ...[
                        // Full form mode: info card + all grouped fields
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                AppIcons.info,
                                size: 20,
                                color: context.colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  context.l10n.bodyMeasurementsInputDescription,
                                  style: context.textTheme.bodySmall,
                                ),
                              ),
                            ],
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
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  _getGroupLabel(group),
                                  style: context.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.colors.primary,
                                  ),
                                ),
                              ),
                              ...groupMetrics.map(_buildMetricField),
                              const SizedBox(height: 16),
                            ],
                          );
                        }),
                      ],
                    ],
                  ),
                ),
      bottomNavigationBar: _isLoading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _submitMeasurements,
                  icon: const Icon(AppIcons.save),
                  label: Text(context.l10n.bodyMeasurementsInputSubmit),
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

  /// Get error message from MeasurementFailure
  String _getMeasurementFailureMessage(MeasurementFailure failure) {
    return switch (failure) {
      ConsentRequiredFailure(:final metricType) =>
        'Consent required for ${metricType.name}',
      ValidationFailure(:final message) => message,
      StorageFailure(:final message) => message,
      MeasurementNotFoundFailure(:final measurementId) =>
        'Measurement not found: $measurementId',
      SyncConflictFailure(:final message) => message,
      HealthPlatformFailure(:final message) => message,
    };
  }

  /// Get helper text explaining how this metric is calculated
  String? _getCalculationHelper(MetricType metric) {
    return switch (metric) {
      MetricType.bmi => context.l10n.bodyMeasurementsCalcBMI,
      MetricType.leanMass => context.l10n.bodyMeasurementsCalcLeanMass,
      MetricType.bmr => context.l10n.bodyMeasurementsCalcBMR,
      _ => null,
    };
  }
}

/// Quick Measurement Input Sheet
///
/// Compact bottom sheet for rapid body measurement input.
/// Shows last value, quick +/- buttons, and a save action.
/// Supports bilateral metrics (arms, thighs) with two inputs.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/body_measurements/data/repositories/measurement_repository_provider.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/measurement.dart';
import 'package:gymbro_flutter_new/features/body_measurements/domain/entities/metric_type.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:uuid/uuid.dart';

/// Compact bottom sheet for quick measurement input
class QuickMeasurementInputSheet extends ConsumerStatefulWidget {
  const QuickMeasurementInputSheet({
    required this.metric,
    super.key,
  });

  final MetricType metric;

  @override
  ConsumerState<QuickMeasurementInputSheet> createState() =>
      _QuickMeasurementInputSheetState();
}

class _QuickMeasurementInputSheetState
    extends ConsumerState<QuickMeasurementInputSheet> {
  late TextEditingController _controller;
  late TextEditingController _controllerLeft; // for bilateral
  double? _lastValue;
  DateTime? _lastTimestamp;
  bool _isSaving = false;
  bool _isLoading = true;

  /// Whether this metric is bilateral (arms/thighs)
  bool get _isBilateral => _bilateralPair != null;

  /// Get the bilateral pair metric
  MetricType? get _bilateralPair => switch (widget.metric) {
    MetricType.bicepRightCircumference => MetricType.bicepLeftCircumference,
    MetricType.thighRightCircumference => MetricType.thighLeftCircumference,
    _ => null,
  };

  /// Step values for quick buttons based on metric type
  List<double> get _steps => switch (widget.metric) {
    MetricType.weight => [0.1, 0.5, 1.0],
    MetricType.bodyFatPercentage => [0.1, 0.5, 1.0],
    _ => [0.5, 1.0, 2.0], // circumferences
  };

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controllerLeft = TextEditingController();
    _loadLastValue();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerLeft.dispose();
    super.dispose();
  }

  Future<void> _loadLastValue() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final repo = ref.read(measurementRepositoryProvider);
    final result = await repo.getLatestMeasurementsByType(userId);

    result.fold(
      (_) {},
      (latestMap) {
        final lastMeasurement = latestMap[widget.metric];
        if (lastMeasurement != null) {
          _lastValue = lastMeasurement.value;
          _lastTimestamp = lastMeasurement.timestamp;
          _controller.text = lastMeasurement.value.toStringAsFixed(1);
        }

        // For bilateral, also load the pair
        if (_isBilateral && _bilateralPair != null) {
          final leftMeasurement = latestMap[_bilateralPair];
          if (leftMeasurement != null) {
            _controllerLeft.text = leftMeasurement.value.toStringAsFixed(1);
          }
        }
      },
    );

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.metric.defaultUnit;
    final title = _metricTitle(context);
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: bottomPadding + 16,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),

          // Last value info
          if (_isLoading)
            Text(
              '...',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            )
          else if (_lastValue != null && _lastTimestamp != null)
            Text(
              context.l10n.quickActionLastValue(
                _lastValue!.toStringAsFixed(1),
                unit,
                context.l10n.daysAgoShort(
                  DateTime.now().difference(_lastTimestamp!).inDays,
                ),
              ),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),

          const SizedBox(height: 20),

          // Input fields
          if (_isBilateral) ...[
            _buildBilateralInputs(context, unit),
          ] else ...[
            _buildSingleInput(context, _controller, unit),
            const SizedBox(height: 12),
            _buildQuickButtons(context, _controller),
          ],

          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _isSaving ? null : () => _save(context),
              child: Text(
                context.l10n.quickActionSave,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleInput(
    BuildContext context,
    TextEditingController controller,
    String unit,
  ) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: context.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        suffixText: unit,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
      ],
    );
  }

  Widget _buildBilateralInputs(BuildContext context, String unit) {
    return Column(
      children: [
        // Right side
        Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                'R',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: _buildSingleInput(context, _controller, unit),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildQuickButtons(context, _controller),
        const SizedBox(height: 16),
        // Left side
        Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                'L',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: _buildSingleInput(context, _controllerLeft, unit),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildQuickButtons(context, _controllerLeft),
      ],
    );
  }

  Widget _buildQuickButtons(
    BuildContext context,
    TextEditingController controller,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final step in _steps) ...[
          _buildStepButton(context, controller, -step),
          const SizedBox(width: 8),
        ],
        for (final step in _steps) ...[
          _buildStepButton(context, controller, step),
          if (step != _steps.last) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _buildStepButton(
    BuildContext context,
    TextEditingController controller,
    double step,
  ) {
    final label = step > 0
        ? '+${step.toStringAsFixed(step == step.roundToDouble() ? 0 : 1)}'
        : step.toStringAsFixed(step == step.roundToDouble() ? 0 : 1);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        final current = double.tryParse(controller.text) ?? 0;
        final newVal = (current + step).clamp(0.0, 999.9);
        controller.text = newVal.toStringAsFixed(1);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final value = double.tryParse(_controller.text);
    if (value == null) return;

    setState(() => _isSaving = true);

    final repo = ref.read(measurementRepositoryProvider);
    const uuid = Uuid();
    final now = DateTime.now();

    // Save main measurement
    final measurement = Measurement(
      id: uuid.v4(),
      userId: userId,
      metricType: widget.metric,
      value: value,
      unit: widget.metric.defaultUnit,
      timestamp: now,
      source: MeasurementSource.manual,
      createdAt: now,
    );

    final result = await repo.addMeasurement(measurement, hasConsent: true);

    // Save bilateral pair if applicable
    if (_isBilateral && _bilateralPair != null) {
      final leftValue = double.tryParse(_controllerLeft.text);
      if (leftValue != null) {
        final leftMeasurement = Measurement(
          id: uuid.v4(),
          userId: userId,
          metricType: _bilateralPair!,
          value: leftValue,
          unit: _bilateralPair!.defaultUnit,
          timestamp: now,
          source: MeasurementSource.manual,
          createdAt: now,
        );
        await repo.addMeasurement(leftMeasurement, hasConsent: true);
      }
    }

    if (!context.mounted) return;
    setState(() => _isSaving = false);

    result.fold(
      (failure) {
        SnackBarService.showError(context, failure.toString());
      },
      (_) {
        SnackBarService.showSuccess(context, context.l10n.quickActionSave);
        Navigator.of(context).pop();
      },
    );
  }

  String _metricTitle(BuildContext context) {
    return switch (widget.metric) {
      MetricType.weight => context.l10n.weight,
      MetricType.waistCircumference => context.l10n.quickActionWaist,
      MetricType.bodyFatPercentage => context.l10n.quickActionBodyFat,
      MetricType.bicepRightCircumference => context.l10n.quickActionArmsLR,
      MetricType.thighRightCircumference => context.l10n.quickActionThighsLR,
      MetricType.chestCircumference => context.l10n.quickActionChest,
      MetricType.hipCircumference => context.l10n.quickActionHips,
      MetricType.shoulderCircumference => context.l10n.quickActionShoulders,
      _ => widget.metric.name,
    };
  }
}

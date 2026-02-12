import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/body_measurement.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_permission_provider.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_sync_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Step 3: Body measurements (height and weight)
class BodyDataStep extends ConsumerStatefulWidget {
  const BodyDataStep({super.key});

  @override
  ConsumerState<BodyDataStep> createState() => _BodyDataStepState();
}

class _BodyDataStepState extends ConsumerState<BodyDataStep> {
  final _weightController = TextEditingController();
  final _weightFocusNode = FocusNode();
  bool _isImportingFromHealth = false;
  bool _showInfoTooltip = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill weight if already set
    final state = ref.read(initialOnboardingNotifierProvider);
    if (state.bodyweightKg != null) {
      _weightController.text = state.bodyweightKg!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  KeyboardActionsConfig _buildKeyboardActionsConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardBarColor: context.colors.surfaceContainerHighest,
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
          focusNode: _weightFocusNode,
          displayDoneButton: false,
          toolbarButtons: [
            // Left side: Weight presets button
            // Accessibility: Weight presets button with semantic label
            (node) => Semantics(
              label: context.l10n.initialOnboardingQuickSelect,
              button: true,
              child: GestureDetector(
                onTap: () => _showWeightPresets(context),
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.weight,
                      size: 20,
                      color: context.colors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.initialOnboardingQuickSelect,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ),
            // Spacer
            (node) => const Expanded(child: SizedBox()),
            // Right side: Done button
            // Accessibility: Done button with semantic label
            (node) => Semantics(
              label: context.l10n.done,
              button: true,
              child: GestureDetector(
                onTap: () => node.unfocus(),
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  context.l10n.done,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            ),
          ],
        ),
      ],
    );
  }

  void _showWeightPresets(BuildContext context) {
    // Common body weights
    final presets = [50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110];

    ModalService.showSheet<void>(context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                context.l10n.initialOnboardingSelectWeight,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Weight grid
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: presets.map((weight) {
                  final currentWeight =
                      double.tryParse(_weightController.text) ?? 0;
                  final isSelected = currentWeight.round() == weight;

                  // Accessibility: Weight preset button with semantic label
                  return Semantics(
                    label: '$weight kg${isSelected ? ', selected' : ''}',
                    button: true,
                    selected: isSelected,
                    child: GestureDetector(
                      onTap: () {
                        _weightController.text = weight.toString();
                        ref
                            .read(initialOnboardingNotifierProvider.notifier)
                            .setBodyweight(weight.toDouble());
                        Navigator.pop(sheetContext);
                        _weightFocusNode.unfocus();
                      },
                    child: Container(
                      width: 64,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colors.primary
                            : context.colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '$weight',
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? context.colors.onPrimary
                              : context.colors.onSurface,
                        ),
                      ),
                    ),
                  ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(initialOnboardingNotifierProvider);
    final heightCm = state.heightCm ?? 175.0;

    return KeyboardActions(
      config: _buildKeyboardActionsConfig(context),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      context.l10n.initialOnboardingBodyMeasurementsTitle,
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle with info tooltip
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.l10n.initialOnboardingBodyMeasurementsSubtitle,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        // Info tooltip button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showInfoTooltip = !_showInfoTooltip;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: context.colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              AppIcons.infoOutline,
                              size: 18,
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Expandable info tooltip
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _showInfoTooltip
                          ? Container(
                              margin: const EdgeInsets.only(top: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                context.l10n.initialOnboardingBodyInfo,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 32),

                    // Height section
                    Text(
                      context.l10n.initialOnboardingHeightLabel,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Height value display (larger, more prominent)
                    Center(
                      child: Text(
                        '${heightCm.round()} ${context.l10n.initialOnboardingHeightCm}',
                        style: context.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.primary,
                          fontSize: 56,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Centimeter-style ruler slider
                    _CentimeterRulerSlider(
                      value: heightCm,
                      onChanged: (value) {
                        ref
                            .read(initialOnboardingNotifierProvider.notifier)
                            .setHeight(value);
                      },
                    ),

                    const SizedBox(height: 40),

                    // Weight section
                    Text(
                      context.l10n.initialOnboardingWeightLabel,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Weight text field
                    TextField(
                      controller: _weightController,
                      focusNode: _weightFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                      ],
                      decoration: InputDecoration(
                        hintText: '75',
                        suffixText: 'kg',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                      ),
                      onChanged: (value) {
                        final weight = double.tryParse(value);
                        if (weight != null) {
                          ref
                              .read(initialOnboardingNotifierProvider.notifier)
                              .setBodyweight(weight);
                        }
                      },
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    ),

                    const SizedBox(height: 32),

                    // HealthKit import card (iOS/macOS only) - separated
                    if (Platform.isIOS || Platform.isMacOS)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: context.colors.outline.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              AppIcons.healthAndSafety,
                              size: 32,
                              color: context.colors.primary,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                context.l10n.initialOnboardingImportHealthKit,
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_isImportingFromHealth)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: LoadingIndicator(size: 20),
                              )
                            else
                              FilledButton.tonal(
                                onPressed: _importFromHealthKit,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(context.l10n.importAction),
                              ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Continue button - fixed at bottom
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: state.canProceedFromStep(3)
                        ? () => ref
                              .read(initialOnboardingNotifierProvider.notifier)
                              .nextStep()
                        : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      context.l10n.initialOnboardingContinue,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importFromHealthKit() async {
    if (!mounted) return;

    debugPrint('[HealthKit] Starting weight + height import...');
    setState(() => _isImportingFromHealth = true);

    try {
      // 1. Request ALL essential permissions (workout + bodyWeight + height)
      // This way user grants everything the app needs in one dialog
      debugPrint(
        '[HealthKit] Requesting essential permissions (workout + bodyWeight + height)...',
      );
      final permissionController = ref.read(
        healthPermissionControllerProvider.notifier,
      );
      await permissionController.requestPermissions(
        dataTypes: [
          HealthDataType.workout,
          HealthDataType.bodyWeight,
          HealthDataType.height,
        ],
      );

      if (!mounted) return;

      // 2. Check if bodyWeight permission was granted (we need this for import)
      final permissionState = ref.read(healthPermissionControllerProvider);
      final hasWeightPermission =
          permissionState.when(
            data: (status) => status.canSync(HealthDataType.bodyWeight),
            loading: () => false,
            error: (_, __) => false,
          );
      final hasHeightPermission =
          permissionState.when(
            data: (status) => status.canSync(HealthDataType.height),
            loading: () => false,
            error: (_, __) => false,
          );
      final hasWorkoutPermission =
          permissionState.when(
            data: (status) => status.canSync(HealthDataType.workout),
            loading: () => false,
            error: (_, __) => false,
          );
      debugPrint(
        '[HealthKit] Permissions granted - workout: $hasWorkoutPermission, '
        'bodyWeight: $hasWeightPermission, height: $hasHeightPermission',
      );

      // Need at least one of weight/height permission to proceed
      if (!hasWeightPermission && !hasHeightPermission) {
        // Permission denied - show dialog with option to open Settings
        debugPrint('[HealthKit] Both weight and height permissions denied, showing dialog...');
        if (mounted) {
          await _showPermissionDeniedDialog();
        }
        return;
      }

      final syncController = ref.read(healthSyncControllerProvider.notifier);
      final repository = ref.read(healthRepositoryProvider);
      final notifier = ref.read(initialOnboardingNotifierProvider.notifier);

      bool importedWeight = false;
      bool importedHeight = false;

      // 3. Sync and import body weight from HealthKit (if permission granted)
      if (hasWeightPermission) {
        debugPrint('[HealthKit] Syncing weight data from HealthKit...');
        await syncController.syncBodyWeight();

        if (!mounted) return;

        debugPrint('[HealthKit] Fetching cached weight measurements (last 90 days)...');
        final weightResult = await repository.getMeasurements(
          dataType: HealthDataType.bodyWeight,
          startDate: DateTime.now().subtract(const Duration(days: 90)),
          endDate: DateTime.now(),
        );

        weightResult.fold(
          (failure) {
            debugPrint('[HealthKit] ERROR: Failed to fetch weight - $failure');
          },
          (measurements) {
            debugPrint('[HealthKit] Found ${measurements.length} weight measurements');

            if (measurements.isNotEmpty) {
              final latestWeight = measurements.first;
              final weightKg = latestWeight.value;
              debugPrint(
                '[HealthKit] Latest weight: ${weightKg.toStringAsFixed(1)} kg '
                '(recorded: ${latestWeight.recordedAt})',
              );

              _weightController.text = weightKg.toStringAsFixed(0);
              notifier.setBodyweight(weightKg);
              importedWeight = true;
              debugPrint('[HealthKit] Weight updated in onboarding state');
            }
          },
        );
      }

      if (!mounted) return;

      // 4. Sync and import height from HealthKit (if permission granted)
      if (hasHeightPermission) {
        debugPrint('[HealthKit] Syncing height data from HealthKit...');
        await syncController.syncHeight();

        if (!mounted) return;

        debugPrint('[HealthKit] Fetching cached height measurements (last 365 days)...');
        final heightResult = await repository.getMeasurements(
          dataType: HealthDataType.height,
          startDate: DateTime.now().subtract(const Duration(days: 365)),
          endDate: DateTime.now(),
        );

        heightResult.fold(
          (failure) {
            debugPrint('[HealthKit] ERROR: Failed to fetch height - $failure');
          },
          (measurements) {
            debugPrint('[HealthKit] Found ${measurements.length} height measurements');

            if (measurements.isNotEmpty) {
              final latestHeight = measurements.first;
              // Height from HealthKit is in meters, convert to cm
              final heightCm = latestHeight.toCentimeters();
              debugPrint(
                '[HealthKit] Latest height: ${heightCm.toStringAsFixed(1)} cm '
                '(recorded: ${latestHeight.recordedAt})',
              );

              notifier.setHeight(heightCm);
              importedHeight = true;
              debugPrint('[HealthKit] Height updated in onboarding state');
            }
          },
        );
      }

      if (!mounted) return;

      // 5. Show appropriate success/info message
      if (importedWeight && importedHeight) {
        SnackBarService.showSuccess(
          context,
          context.l10n.initialOnboardingHealthKitSuccessBoth,
        );
      } else if (importedWeight) {
        final state = ref.read(initialOnboardingNotifierProvider);
        SnackBarService.showSuccess(
          context,
          context.l10n.initialOnboardingHealthKitSuccess(
            state.bodyweightKg?.toStringAsFixed(1) ?? '',
          ),
        );
      } else if (importedHeight) {
        SnackBarService.showSuccess(
          context,
          context.l10n.initialOnboardingHealthKitSuccessHeight,
        );
      } else {
        // No data found
        debugPrint('[HealthKit] No weight or height data found in HealthKit');
        SnackBarService.showInfo(
          context,
          context.l10n.initialOnboardingHealthKitNoData,
        );
      }
    } catch (e, stackTrace) {
      // Unexpected error
      debugPrint('[HealthKit] EXCEPTION: $e');
      debugPrint('[HealthKit] StackTrace: $stackTrace');
      if (mounted) {
        SnackBarService.showError(
          context,
          context.l10n.initialOnboardingHealthKitError,
        );
      }
    } finally {
      debugPrint('[HealthKit] Import flow completed');
      if (mounted) {
        setState(() => _isImportingFromHealth = false);
      }
    }
  }

  /// Shows a dialog when HealthKit permission is denied,
  /// with option to open Settings
  Future<void> _showPermissionDeniedDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          AppIcons.healthAndSafety,
          size: 48,
          color: context.colors.warning,
        ),
        title: Text(context.l10n.initialOnboardingHealthKitDeniedTitle),
        content: Text(context.l10n.initialOnboardingHealthKitDeniedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await openAppSettings();
            },
            child: Text(context.l10n.initialOnboardingOpenSettings),
          ),
        ],
      ),
    );
  }
}

/// iOS-style horizontal picker wheel for height selection
class _CentimeterRulerSlider extends StatefulWidget {
  const _CentimeterRulerSlider({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_CentimeterRulerSlider> createState() => _CentimeterRulerSliderState();
}

class _CentimeterRulerSliderState extends State<_CentimeterRulerSlider> {
  late FixedExtentScrollController _scrollController;
  static const double _minHeight = 140.0;
  static const double _maxHeight = 220.0;

  @override
  void initState() {
    super.initState();
    final initialIndex = (widget.value - _minHeight).round();
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = (_maxHeight - _minHeight).toInt() + 1;

    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Stack(
        children: [
          // Selection highlight in center
          Center(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
          ),

          // Horizontal wheel picker
          RotatedBox(
            quarterTurns: 3, // Rotate to make vertical picker horizontal
            child: ListWheelScrollView.useDelegate(
              controller: _scrollController,
              itemExtent: 60, // Height of each item
              diameterRatio: 1.5, // Less curvature for subtle 3D effect
              perspective: 0.003, // Subtle perspective
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                final newValue = _minHeight + index;
                widget.onChanged(newValue);
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  if (index < 0 || index >= totalItems) return null;

                  final value = _minHeight + index;
                  final isSelected = (value - widget.value).abs() < 0.5;
                  final isMajor = value.toInt() % 5 == 0;

                  return RotatedBox(
                    quarterTurns: 1, // Rotate back to horizontal
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: context.textTheme.titleLarge!.copyWith(
                          fontSize: isSelected ? 28 : (isMajor ? 20 : 16),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : (isMajor ? FontWeight.w600 : FontWeight.normal),
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.onSurface.withValues(
                                  alpha: isMajor ? 0.8 : 0.4,
                                ),
                        ),
                        child: Text('${value.toInt()}'),
                      ),
                    ),
                  );
                },
                childCount: totalItems,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


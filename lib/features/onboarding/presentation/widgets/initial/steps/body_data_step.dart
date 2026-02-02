import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    showModalBottomSheet<void>(
      context: context,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
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

              // Subtitle
              Text(
                context.l10n.initialOnboardingBodyMeasurementsSubtitle,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
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

              const SizedBox(height: 16),

              // Height value display
              Center(
                child: Text(
                  '${heightCm.round()} ${context.l10n.initialOnboardingHeightCm}',
                  style: context.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Height slider
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 24,
                  ),
                  activeTrackColor: context.colors.primary,
                  inactiveTrackColor: context.colors.primary.withValues(
                    alpha: 0.2,
                  ),
                  thumbColor: context.colors.primary,
                  overlayColor: context.colors.primary.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: heightCm,
                  min: 140,
                  max: 220,
                  divisions: 80,
                  onChanged: (value) {
                    ref
                        .read(initialOnboardingNotifierProvider.notifier)
                        .setHeight(value);
                  },
                ),
              ),

              const SizedBox(height: 32),

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
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
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

              const SizedBox(height: 24),

              // HealthKit import card (iOS/macOS only)
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.l10n.initialOnboardingImportHealthKit,
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                        // Accessibility: Import button with semantic label
                        Semantics(
                          label: context.l10n.importAction,
                          button: true,
                          child: FilledButton.tonal(
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
                        ),
                    ],
                  ),
                ),

              const Spacer(),

              // Info text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.infoOutline,
                      size: 20,
                      color: context.colors.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.initialOnboardingBodyInfo,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Continue button
              // Accessibility: Continue button with semantic label
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  label: context.l10n.initialOnboardingContinue,
                  button: true,
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

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _importFromHealthKit() async {
    if (!mounted) return;

    debugPrint('[HealthKit] Starting weight import...');
    setState(() => _isImportingFromHealth = true);

    try {
      // 1. Request ALL essential permissions (workout + bodyWeight)
      // This way user grants everything the app needs in one dialog
      debugPrint(
        '[HealthKit] Requesting essential permissions (workout + bodyWeight)...',
      );
      final permissionController = ref.read(
        healthPermissionControllerProvider.notifier,
      );
      await permissionController.requestPermissions(
        dataTypes: [HealthDataType.workout, HealthDataType.bodyWeight],
      );

      if (!mounted) return;

      // 2. Check if bodyWeight permission was granted (we need this for import)
      final permissionState = ref.read(healthPermissionControllerProvider);
      final hasWeightPermission =
          permissionState.valueOrNull?.canSync(HealthDataType.bodyWeight) ??
          false;
      final hasWorkoutPermission =
          permissionState.valueOrNull?.canSync(HealthDataType.workout) ?? false;
      debugPrint(
        '[HealthKit] Permissions granted - workout: $hasWorkoutPermission, bodyWeight: $hasWeightPermission',
      );

      if (!hasWeightPermission) {
        // Permission denied - show dialog with option to open Settings
        debugPrint('[HealthKit] Weight permission denied, showing dialog...');
        if (mounted) {
          await _showPermissionDeniedDialog();
        }
        return;
      }

      // 3. Sync body weight from HealthKit
      debugPrint('[HealthKit] Syncing weight data from HealthKit...');
      final syncController = ref.read(healthSyncControllerProvider.notifier);
      await syncController.syncBodyWeight();
      debugPrint('[HealthKit] Sync completed');

      if (!mounted) return;

      // 4. Get cached measurements
      debugPrint('[HealthKit] Fetching cached measurements (last 90 days)...');
      final repository = ref.read(healthRepositoryProvider);
      final result = await repository.getMeasurements(
        dataType: HealthDataType.bodyWeight,
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now(),
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          // Failed to fetch measurements
          debugPrint('[HealthKit] ERROR: Failed to fetch - $failure');
          SnackBarService.showError(
            context,
            context.l10n.initialOnboardingHealthKitError,
          );
        },
        (measurements) {
          debugPrint('[HealthKit] Found ${measurements.length} measurements');

          if (measurements.isEmpty) {
            // No weight data found in HealthKit
            debugPrint('[HealthKit] No weight data found in HealthKit');
            SnackBarService.showInfo(
              context,
              context.l10n.initialOnboardingHealthKitNoWeightData,
            );
            return;
          }

          // Get the most recent measurement (sorted by date, most recent first)
          final latestWeight = measurements.first;
          final weightKg = latestWeight.value;
          debugPrint(
            '[HealthKit] Latest weight: ${weightKg.toStringAsFixed(1)} kg '
            '(recorded: ${latestWeight.recordedAt})',
          );

          // Update the text field
          _weightController.text = weightKg.toStringAsFixed(0);

          // Update the onboarding state
          ref
              .read(initialOnboardingNotifierProvider.notifier)
              .setBodyweight(weightKg);
          debugPrint('[HealthKit] Weight updated in onboarding state');

          // Show success message
          SnackBarService.showSuccess(
            context,
            context.l10n.initialOnboardingHealthKitSuccess(
              weightKg.toStringAsFixed(1),
            ),
          );
        },
      );
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

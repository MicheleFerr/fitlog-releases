import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/body_measurement.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_data_type.dart';
import 'package:gymbro_flutter_new/features/health_sync/domain/entities/health_permission_status.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_permission_provider.dart';
import 'package:gymbro_flutter_new/features/health_sync/presentation/providers/health_sync_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/domain/utils/onboarding_health_permissions.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/providers/initial/initial_onboarding_provider.dart';
import 'package:gymbro_flutter_new/features/onboarding/presentation/widgets/initial/initial_onboarding_style.dart';
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
  static const Color _brandForeground = Color(0xFF1F1F1F);
  static const Color _brandDisabledBackground = Color(0xFFE8EAED);
  static const Color _brandDisabledForeground = Color(0xFF5F6368);
  static const Color _selectedBorderColor = Color(0xFF22C55E);

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

    ModalService.showSheet<void>(
      context,
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
    final permissionStatus = ref.watch(healthPermissionStatusProvider);
    final isHealthConnectAvailable = Platform.isAndroid
        ? permissionStatus.maybeWhen(
            data: (status) => status.healthConnectAvailable,
            orElse: () => true,
          )
        : true;

    final content = GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: InitialOnboardingStyle.horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: InitialOnboardingStyle.topSpacing),
                  Text(
                    context.l10n.initialOnboardingBodyMeasurementsTitle,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.colors.onSurface,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context
                              .l10n
                              .initialOnboardingBodyMeasurementsSubtitle,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ),
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
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.initialOnboardingHeightLabel,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      '${heightCm.round()} ${context.l10n.initialOnboardingHeightCm}',
                      style: context.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: context.colors.primary,
                        fontSize: 48,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _CentimeterRulerSlider(
                    value: heightCm,
                    onChanged: (value) {
                      ref
                          .read(initialOnboardingNotifierProvider.notifier)
                          .setHeight(value);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.initialOnboardingWeightLabel,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _weightController,
                    focusNode: _weightFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d*'),
                      ),
                    ],
                    decoration: InputDecoration(
                      hintText: '75',
                      suffixText: 'kg',
                      filled: true,
                      fillColor: context.colors.surface.withValues(alpha: 0.56),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          InitialOnboardingStyle.cardRadius,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          InitialOnboardingStyle.cardRadius,
                        ),
                        borderSide: BorderSide(
                          color: context.colors.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          InitialOnboardingStyle.cardRadius,
                        ),
                        borderSide: const BorderSide(
                          color: _selectedBorderColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
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
                  const SizedBox(height: 20),
                  if (Platform.isIOS || Platform.isMacOS || Platform.isAndroid)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.colors.surface.withValues(alpha: 0.72),
                            context.colors.surfaceContainerHighest.withValues(
                              alpha: 0.3,
                            ),
                          ],
                        ),
                        border: Border.all(
                          color: context.colors.outline.withValues(alpha: 0.18),
                        ),
                        borderRadius: BorderRadius.circular(
                          InitialOnboardingStyle.cardRadius,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Platform.isIOS || Platform.isMacOS
                                ? context.l10n.featureAppleHealth
                                : 'Health Connect',
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            Platform.isAndroid && !isHealthConnectAvailable
                                ? context
                                      .l10n
                                      .bodyMeasurementsHealthConnectRequired
                                : context.l10n.bodyMeasurementsImportFromHealth,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurface.withValues(
                                alpha: 0.72,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child:
                                Platform.isAndroid && !isHealthConnectAvailable
                                    ? FilledButton.icon(
                                        onPressed: _installHealthConnect,
                                        icon: const Icon(
                                          AppIcons.download,
                                          size: 18,
                                        ),
                                        label: Text(
                                          context
                                              .l10n
                                              .bodyMeasurementsInstallHealthConnect,
                                        ),
                                        style: FilledButton.styleFrom(
                                          minimumSize:
                                              const Size.fromHeight(44),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                      )
                                    : FilledButton.icon(
                                        onPressed: _isImportingFromHealth
                                            ? null
                                            : _importFromHealth,
                                        icon: _isImportingFromHealth
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: LoadingIndicator(
                                                  size: 18,
                                                  color: _brandForeground,
                                                ),
                                              )
                                            : SvgPicture.asset(
                                                Platform.isIOS ||
                                                        Platform.isMacOS
                                                    ? 'assets/images/apple_logo.svg'
                                                    : 'assets/images/google_logo.svg',
                                                width: 18,
                                                height: 18,
                                                fit: BoxFit.contain,
                                                colorFilter:
                                                    Platform.isIOS ||
                                                            Platform.isMacOS
                                                        ? ColorFilter.mode(
                                                            context
                                                                .colors
                                                                .onSurface,
                                                            BlendMode.srcIn,
                                                          )
                                                        : null,
                                              ),
                                        label: Text(
                                          Platform.isIOS || Platform.isMacOS
                                              ? context.l10n
                                                  .bodyMeasurementsImportFromHealth
                                              : _androidImportLabel(context),
                                        ),
                                        style: FilledButton.styleFrom(
                                          minimumSize:
                                              const Size.fromHeight(44),
                                          elevation: 0,
                                          shadowColor: Colors.transparent,
                                          backgroundColor: context
                                              .colors
                                              .surface
                                              .withValues(alpha: 0.6),
                                          foregroundColor:
                                              context.colors.onSurface,
                                          disabledBackgroundColor:
                                              _brandDisabledBackground,
                                          disabledForegroundColor:
                                              _brandDisabledForeground,
                                          side: BorderSide(
                                            color: _selectedBorderColor
                                                .withValues(alpha: 0.7),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                      ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                InitialOnboardingStyle.horizontalPadding,
                0,
                InitialOnboardingStyle.horizontalPadding,
                16,
              ),
              child: FilledButton(
                onPressed: state.canProceedFromStep(3)
                    ? () => ref
                          .read(initialOnboardingNotifierProvider.notifier)
                          .nextStep()
                    : null,
                style: InitialOnboardingStyle.primaryButtonStyle(context),
                child: Text(context.l10n.initialOnboardingContinue),
              ),
            ),
          ),
        ],
      ),
    );

    if (Platform.isAndroid) {
      return content;
    }

    return KeyboardActions(
      config: _buildKeyboardActionsConfig(context),
      child: content,
    );
  }

  String _androidImportLabel(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    return isItalian
        ? 'Importa da Health Connect'
        : 'Import from Health Connect';
  }

  Future<void> _installHealthConnect() async {
    if (!mounted) return;
    final repository = ref.read(healthRepositoryProvider);
    final result = await repository.installHealthConnect();
    if (!mounted) return;

    result.fold(
      (failure) => SnackBarService.showError(context, failure.message),
      (_) {
        SnackBarService.showInfo(
          context,
          context.l10n.healthConnectInstallDescription,
        );
        ref.invalidate(healthPermissionStatusProvider);
      },
    );
  }

  Future<void> _importFromHealth() async {
    if (!mounted) return;

    debugPrint('[HealthKit] Starting weight + height import...');
    setState(() => _isImportingFromHealth = true);

    try {
      // 1. Only request missing core permissions to avoid duplicate prompts.
      final currentPermissionStatus = await ref.read(
        healthPermissionStatusProvider.future,
      );
      final missingTypes = missingOnboardingCoreHealthTypes(
        currentPermissionStatus,
      );

      final permissionController = ref.read(
        healthPermissionControllerProvider.notifier,
      );
      if (missingTypes.isNotEmpty) {
        debugPrint(
          '[HealthKit] Requesting missing core permissions: $missingTypes',
        );
        await permissionController.requestPermissions(dataTypes: missingTypes);
      } else {
        debugPrint('[HealthKit] Core permissions already available');
      }

      if (!mounted) return;

      // 2. Refresh runtime status after the optional permission request.
      ref.invalidate(healthPermissionStatusProvider);
      final permissionStatus = await ref.read(
        healthPermissionStatusProvider.future,
      );
      final hasWeightPermission = permissionStatus.canAttemptSync(
        HealthDataType.bodyWeight,
      );
      final hasHeightPermission = permissionStatus.canAttemptSync(
        HealthDataType.height,
      );
      final hasWorkoutPermission = permissionStatus.canAttemptSync(
        HealthDataType.workout,
      );
      debugPrint(
        '[HealthKit] Permissions granted - workout: $hasWorkoutPermission, '
        'bodyWeight: $hasWeightPermission, height: $hasHeightPermission',
      );

      // Need at least one of weight/height permission to proceed
      if (!hasWeightPermission && !hasHeightPermission) {
        // Permission denied - show dialog with option to open Settings
        debugPrint(
          '[HealthKit] Both weight and height permissions denied, showing dialog...',
        );
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

        debugPrint(
          '[HealthKit] Fetching cached weight measurements (last 90 days)...',
        );
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
            debugPrint(
              '[HealthKit] Found ${measurements.length} weight measurements',
            );

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

        debugPrint(
          '[HealthKit] Fetching cached height measurements (last 365 days)...',
        );
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
            debugPrint(
              '[HealthKit] Found ${measurements.length} height measurements',
            );

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
  const _CentimeterRulerSlider({required this.value, required this.onChanged});

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
      height: 94,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(InitialOnboardingStyle.cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.colors.surfaceContainerHighest.withValues(alpha: 0.24),
            context.colors.surface.withValues(alpha: 0.16),
          ],
        ),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.14),
        ),
      ),
      child: Stack(
        children: [
          // Selection highlight in center
          Center(
            child: Container(
              height: 40,
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
              itemExtent: 52, // Height of each item
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
                          fontSize: isSelected ? 22 : (isMajor ? 17 : 14),
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

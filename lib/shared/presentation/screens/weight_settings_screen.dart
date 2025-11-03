import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/weight_settings.dart';
import 'package:gymbro_flutter_new/shared/domain/services/plate_calculator_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/weight_settings_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/loading_indicator.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Weight Settings Screen
///
/// Allows user to configure:
/// - Default weight increments (quick +/- buttons)
/// - Custom weight increments
/// - Available gym plates (for plate calculator)
class WeightSettingsScreen extends ConsumerStatefulWidget {
  const WeightSettingsScreen({super.key});

  @override
  ConsumerState<WeightSettingsScreen> createState() => _WeightSettingsScreenState();
}

class _WeightSettingsScreenState extends ConsumerState<WeightSettingsScreen> {
  final _customIncrementController = TextEditingController();
  final _barWeightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _customIncrementController.dispose();
    _barWeightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(weightSettingsProvider);
    final unit = ref.watch(measurementUnitProvider);
    final unitLabel = unit == 'kg' ? 'kg' : 'lbs';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.weightSettings),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.restore),
            tooltip: context.l10n.resetToDefaults,
            onPressed: () => _showResetConfirmation(),
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) => _buildContent(settings, unitLabel),
        loading: () => const LoadingIndicator(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: context.colors.error,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.errorLoadingSettings,
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(WeightSettings settings, String unitLabel) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section 1: Quick Increments
        _buildSectionHeader(
          icon: Icons.add_circle_outline,
          title: context.l10n.quickIncrements,
          subtitle: context.l10n.quickIncrementsDescription,
        ),
        const SizedBox(height: 12),
        _buildQuickIncrementChips(settings, unitLabel),
        const SizedBox(height: 24),

        // Section 2: Custom Increment
        _buildSectionHeader(
          icon: AppIcons.tune,
          title: context.l10n.customIncrement,
          subtitle: context.l10n.customIncrementDescription,
        ),
        const SizedBox(height: 12),
        _buildCustomIncrementSection(settings, unitLabel),
        const SizedBox(height: 24),

        // Section 3: Plate Calculator
        _buildSectionHeader(
          icon: Icons.calculate_outlined,
          title: context.l10n.plateCalculator,
          subtitle: context.l10n.plateCalculatorDescription,
        ),
        const SizedBox(height: 12),
        _buildPlateCalculatorSection(settings, unitLabel),
        const SizedBox(height: 24),

        // Section 4: Available Plates
        _buildSectionHeader(
          icon: Icons.fitness_center,
          title: context.l10n.availablePlates,
          subtitle: context.l10n.availablePlatesDescription,
        ),
        const SizedBox(height: 12),
        _buildAvailablePlatesList(settings, unitLabel),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: context.colors.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickIncrementChips(WeightSettings settings, String unitLabel) {
    final unit = ref.read(measurementUnitProvider);
    final standardIncrements = unit == 'kg'
        ? [0.5, 1.0, 1.25, 2.5, 5.0, 10.0]
        : [1.0, 2.5, 5.0, 10.0, 25.0, 45.0];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: standardIncrements.map((value) {
        final isSelected = settings.defaultIncrement.value == value;
        return ChoiceChip(
          label: Text('+$value $unitLabel'),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              ref
                  .read(weightSettingsProvider.notifier)
                  .updateDefaultIncrement(value);
            }
          },
          selectedColor: context.colors.primaryContainer,
          labelStyle: TextStyle(
            color: isSelected
                ? context.colors.onPrimaryContainer
                : context.colors.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomIncrementSection(
    WeightSettings settings,
    String unitLabel,
  ) {
    // Initialize controller with current custom increment
    if (_customIncrementController.text.isEmpty) {
      _customIncrementController.text = settings.customIncrement.value.toString();
    }

    return Card(
      elevation: 0,
      color: context.colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          SwitchListTile(
            title: Text(context.l10n.useCustomIncrement),
            subtitle: Text(
              settings.useCustomIncrement
                  ? context.l10n.customIncrementActive
                  : context.l10n.defaultIncrementActive,
            ),
            value: settings.useCustomIncrement,
            onChanged: (value) {
              ref.read(weightSettingsProvider.notifier).toggleUseCustom();
            },
            activeTrackColor: context.colors.primary,
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _customIncrementController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: context.l10n.customIncrementValue,
                suffixText: unitLabel,
                helperText: context.l10n.customIncrementHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.add),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.pleaseEnterValue;
                }
                final parsed = double.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return context.l10n.pleaseEnterValidNumber;
                }
                if (parsed > 100) {
                  return context.l10n.incrementTooLarge;
                }
                return null;
              },
              onFieldSubmitted: (value) => _saveCustomIncrement(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saveCustomIncrement,
            icon: const Icon(Icons.save),
            label: Text(context.l10n.saveCustomIncrement),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildPlateCalculatorSection(
    WeightSettings settings,
    String unitLabel,
  ) {
    _barWeightController.text = _barWeightController.text.isEmpty ? '20' : _barWeightController.text;
    _targetWeightController.text = _targetWeightController.text.isEmpty ? '100' : _targetWeightController.text;

    return Card(
      elevation: 0,
      color: context.colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            context.l10n.calculatePlatesNeeded,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _barWeightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: context.l10n.barWeight,
                    suffixText: unitLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _targetWeightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: context.l10n.targetWeight,
                    suffixText: unitLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _calculatePlates(settings),
            icon: const Icon(Icons.calculate),
            label: Text(context.l10n.calculate),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildAvailablePlatesList(
    WeightSettings settings,
    String unitLabel,
  ) {
    return Card(
      elevation: 0,
      color: context.colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.platesInYourGym,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...settings.availablePlates.map((plate) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${plate.weight}',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.colors.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${plate.weight} $unitLabel',
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${context.l10n.quantity}: ${plate.count}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                // TODO: Implement plate editor
                SnackBarService.showInfo(
                  context,
                  context.l10n.featureComingSoon,
                );
              },
              icon: const Icon(Icons.edit),
              label: Text(context.l10n.editPlates),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCustomIncrement() async {
    if (!_formKey.currentState!.validate()) return;

    final value = double.parse(_customIncrementController.text);
    await ref.read(weightSettingsProvider.notifier).updateCustomIncrement(value);

    if (mounted) {
      SnackBarService.showSuccess(
        context,
        context.l10n.customIncrementSaved,
      );
    }
  }

  Future<void> _calculatePlates(WeightSettings settings) async {
    final barWeight = double.tryParse(_barWeightController.text);
    final targetWeight = double.tryParse(_targetWeightController.text);

    if (barWeight == null || targetWeight == null) {
      SnackBarService.showError(
        context,
        context.l10n.pleaseEnterValidWeights,
      );
      return;
    }

    if (targetWeight < barWeight) {
      SnackBarService.showWarning(
        context,
        context.l10n.targetWeightTooLow,
      );
      return;
    }

    final calculator = PlateCalculatorService();
    final result = calculator.calculatePlates(
      targetWeight: targetWeight,
      barWeight: barWeight,
      availablePlates: settings.availablePlates,
    );

    _showPlateCalculationResult(result);
  }

  void _showPlateCalculationResult(PlateCalculation result) {
    final unit = ref.read(measurementUnitProvider);
    final unitLabel = unit == 'kg' ? 'kg' : 'lbs';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.isExact ? Icons.check_circle : Icons.info,
              color: result.isExact ? context.colors.primary : context.colors.tertiary,
            ),
            const SizedBox(width: 12),
            Text(context.l10n.plateCalculationResult),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultRow(
              context.l10n.targetWeight,
              '${result.targetWeight} $unitLabel',
            ),
            _buildResultRow(
              context.l10n.actualWeight,
              '${result.actualWeight} $unitLabel',
              highlight: !result.isExact,
            ),
            if (!result.isExact)
              _buildResultRow(
                context.l10n.difference,
                '${result.difference > 0 ? '+' : ''}${result.difference.toStringAsFixed(2)} $unitLabel',
                highlight: true,
              ),
            const Divider(height: 24),
            Text(
              context.l10n.platesPerSide,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (result.platesPerSide.isEmpty)
              Text(
                context.l10n.barOnly,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              )
            else
              ...result.platesPerSide.map((plate) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${plate.count}x',
                          style: context.textTheme.labelLarge?.copyWith(
                            color: context.colors.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${plate.weight} $unitLabel',
                        style: context.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? context.colors.tertiary : context.colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showResetConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.resetToDefaults),
        content: Text(context.l10n.resetSettingsConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            child: Text(context.l10n.reset),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(weightSettingsProvider.notifier).resetToDefaults();
      if (mounted) {
        SnackBarService.showSuccess(
          context,
          context.l10n.settingsReset,
        );
      }
    }
  }
}

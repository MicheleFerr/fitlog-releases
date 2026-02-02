import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

import 'package:gymbro_flutter_new/shared/presentation/services/snackbar_service.dart';

/// Modal for configuring RPE-based auto adjustment for exercises.
class AutoAdjustmentModal extends ConsumerStatefulWidget {
  const AutoAdjustmentModal({
    super.key,
    required this.exercise,
    required this.onSave,
  });
  final Exercise exercise;
  final Function(Exercise) onSave;

  @override
  ConsumerState<AutoAdjustmentModal> createState() =>
      _AutoAdjustmentModalState();
}

class _AutoAdjustmentModalState extends ConsumerState<AutoAdjustmentModal> {
  // RPE settings
  final _targetRPEMinController = TextEditingController();
  final _targetRPEMaxController = TextEditingController();
  final _targetRIRController = TextEditingController();
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();

    // Initialize from existing exercise
    _isEnabled = widget.exercise.autoAdjustmentType == AutoAdjustmentType.rpe;

    // RPE settings
    _targetRPEMinController.text =
        widget.exercise.targetRPEMin?.toString() ?? '7';
    _targetRPEMaxController.text =
        widget.exercise.targetRPEMax?.toString() ?? '9';
    _targetRIRController.text = widget.exercise.targetRIR?.toString() ?? '2';
  }

  @override
  void dispose() {
    _targetRPEMinController.dispose();
    _targetRPEMaxController.dispose();
    _targetRIRController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final useRir = ref.watch(useRirModeProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.surfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.autoAwesome,
                  semanticLabel: l10n.autoAdjustment,
                  color: context.colors.primary,
                  size: AppIconSize.large,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.autoAdjustment,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.autoAdjustmentDescription,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Enable toggle
            Card(
              elevation: _isEnabled ? 3 : 0,
              color: _isEnabled
                  ? context.colors.secondaryContainer
                  : context.colors.surfaceContainerHighest,
              child: SwitchListTile(
                title: Text(
                  l10n.rpeBasedAdjustment,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  l10n.rpeBasedDescription,
                  style: context.textTheme.bodySmall,
                ),
                secondary: Icon(
                  AppIcons.ai,
                  color: _isEnabled
                      ? context.colors.secondary
                      : context.colors.onSurfaceVariant,
                ),
                value: _isEnabled,
                onChanged: (value) => setState(() => _isEnabled = value),
              ),
            ),
            const SizedBox(height: 24),

            // Configuration (only show when enabled)
            if (_isEnabled) ...[
              Divider(color: context.colors.outlineVariant),
              const SizedBox(height: 16),
              _buildRPEConfiguration(l10n, useRir),
              const SizedBox(height: 24),
            ],

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearSettings,
                    child: Text(l10n.clear),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _saveSettings,
                    child: Text(l10n.save),
                  ),
                ),
              ],
            ),

            // Bottom padding for safe area
            SizedBox(height: context.mediaQuery.viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildRPEConfiguration(AppLocalizations l10n, bool useRir) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.rpeBasedAdjustment,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        if (!useRir) ...[
          // RPE Range inputs
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _targetRPEMinController,
                  decoration: InputDecoration(
                    labelText: l10n.minRpe,
                    hintText: '7',
                    prefixIcon: const Icon(AppIcons.trendDown),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _targetRPEMaxController,
                  decoration: InputDecoration(
                    labelText: l10n.maxRpe,
                    hintText: '9',
                    prefixIcon: const Icon(AppIcons.trendUp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // RPE explanation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.info,
                  semanticLabel: 'Info',
                  size: AppIconSize.small,
                  color: context.colors.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.rpeAdjustmentExplanation,
                    style: context.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // RIR input
          TextField(
            controller: _targetRIRController,
            decoration: InputDecoration(
              labelText: l10n.targetRir,
              hintText: '2',
              prefixIcon: const Icon(AppIcons.repeat),
              helperText: l10n.repetitionsInReserve,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          // RIR explanation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SemanticIcon(
                  icon: AppIcons.info,
                  semanticLabel: 'Info',
                  size: AppIconSize.small,
                  color: context.colors.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.rirAdjustmentExplanation,
                    style: context.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _clearSettings() {
    setState(() {
      _isEnabled = false;
      _targetRPEMinController.text = '7';
      _targetRPEMaxController.text = '9';
      _targetRIRController.text = '2';
    });
  }

  void _saveSettings() {
    Exercise updatedExercise;

    if (!_isEnabled) {
      // Clear all auto adjustment settings
      updatedExercise = widget.exercise.copyWith(
        autoAdjustmentType: null,
        targetRPEMin: null,
        targetRPEMax: null,
        targetRIR: null,
      );
    } else {
      // Save RPE/RIR settings
      final useRir = ref.read(useRirModeProvider);
      if (!useRir) {
        final minRPE = double.tryParse(_targetRPEMinController.text.trim());
        final maxRPE = double.tryParse(_targetRPEMaxController.text.trim());

        if (minRPE == null ||
            maxRPE == null ||
            minRPE < 1 ||
            maxRPE > 10 ||
            minRPE >= maxRPE) {
          SnackBarService.showError(context, context.l10n.invalidRpeRange);
          return;
        }

        updatedExercise = widget.exercise.copyWith(
          autoAdjustmentType: AutoAdjustmentType.rpe,
          targetRPEMin: minRPE,
          targetRPEMax: maxRPE,
          targetRIR: null,
        );
      } else {
        final targetRIR = int.tryParse(_targetRIRController.text.trim());

        if (targetRIR == null || targetRIR < 0 || targetRIR > 10) {
          SnackBarService.showError(context, context.l10n.invalidRir);
          return;
        }

        updatedExercise = widget.exercise.copyWith(
          autoAdjustmentType: AutoAdjustmentType.rpe,
          targetRIR: targetRIR,
          targetRPEMin: null,
          targetRPEMax: null,
        );
      }
    }

    widget.onSave(updatedExercise);
    Navigator.pop(context);

    SnackBarService.showSuccess(
      context,
      _isEnabled
          ? context.l10n.autoAdjustmentConfigured
          : context.l10n.autoAdjustmentCleared,
    );
  }
}

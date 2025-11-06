import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Modal displayed when user has no historical data for APRE calculations.
/// Provides 3 input methods: from last workout, manual estimate, or test set.
class AutoAdjustmentModalNoHistory extends StatefulWidget {
  const AutoAdjustmentModalNoHistory({
    super.key,
    required this.onOptionSelected,
  });

  /// Callback when user selects an option and provides a value
  final void Function(String option, double? value) onOptionSelected;

  @override
  State<AutoAdjustmentModalNoHistory> createState() =>
      _AutoAdjustmentModalNoHistoryState();
}

class _AutoAdjustmentModalNoHistoryState
    extends State<AutoAdjustmentModalNoHistory> {
  String _selectedOption = 'manual'; // default to manual
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  bool get _isInputValid {
    if (_selectedOption == 'testSet') return true;

    final value = double.tryParse(_inputController.text);
    return value != null && value > 0;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  SemanticIcon(
                    icon: AppIcons.warning,
                    semanticLabel: context.l10n.apreNoHistory,
                    size: AppIconSize.large,
                    color: context.colors.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.apreNoHistory,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                context.l10n.apreNoHistoryDescription,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Options
              _buildOptionCard(
                icon: AppIcons.history,
                title: context.l10n.apreOptionFromLastWorkout,
                description: context.l10n.apreOptionFromLastWorkoutDescription,
                optionKey: 'lastWorkout',
              ),
              const SizedBox(height: 12),

              _buildOptionCard(
                icon: AppIcons.edit,
                title: context.l10n.apreOptionManualEstimate,
                description: context.l10n.apreOptionManualEstimateDescription,
                optionKey: 'manual',
              ),
              const SizedBox(height: 12),

              _buildOptionCard(
                icon: AppIcons.science,
                title: context.l10n.apreOptionTestSet,
                description: context.l10n.apreOptionTestSetDescription,
                optionKey: 'testSet',
              ),
              const SizedBox(height: 24),

              // Input field (only for non-test options)
              if (_selectedOption != 'testSet') ...[
                TextField(
                  controller: _inputController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: context.l10n.apreEnter1RM,
                    hintText: '100',
                    suffixText: 'kg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: context.colors.surfaceContainerHighest,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
              ],

              // Preview weights
              if (_isInputValid && _selectedOption != 'testSet')
                _buildWeightPreview(),

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.apreCancel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _isInputValid ? _handleContinue : null,
                    child: Text(context.l10n.apreContinue),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required String optionKey,
  }) {
    final isSelected = _selectedOption == optionKey;

    return InkWell(
      onTap: () => setState(() => _selectedOption = optionKey),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primaryContainer
              : context.colors.surfaceContainerHighest,
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.outline,
                  width: 2,
                ),
                color: isSelected
                    ? context.colors.primary
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.onPrimary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Icon
            SemanticIcon(
              icon: icon,
              semanticLabel: title,
              size: AppIconSize.large,
              color: isSelected
                  ? context.colors.primary
                  : context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? context.colors.onPrimaryContainer
                          : context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? context.colors.onPrimaryContainer
                          : context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightPreview() {
    final input = double.parse(_inputController.text);
    final rm3 = input * 0.92;
    final rm6 = input * 0.83;
    final rm10 = input * 0.75;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.3),
        border: Border.all(
          color: context.colors.primary,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SemanticIcon(
                icon: AppIcons.preview,
                semanticLabel: context.l10n.aprePreviewWeights,
                size: AppIconSize.medium,
                color: context.colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.aprePreviewWeights,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildPreviewRow('APRE-3 (92%)', rm3),
          const SizedBox(height: 8),
          _buildPreviewRow('APRE-6 (83%)', rm6),
          const SizedBox(height: 8),
          _buildPreviewRow('APRE-10 (75%)', rm10),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, double weight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onPrimaryContainer,
          ),
        ),
        Text(
          '${weight.toStringAsFixed(1)} kg',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  void _handleContinue() {
    double? value;

    if (_selectedOption == 'testSet') {
      // For test set, no value needed upfront
      value = null;
    } else {
      // For manual or last workout, parse the input
      value = double.tryParse(_inputController.text);
    }

    widget.onOptionSelected(_selectedOption, value);
    Navigator.pop(context);
  }
}

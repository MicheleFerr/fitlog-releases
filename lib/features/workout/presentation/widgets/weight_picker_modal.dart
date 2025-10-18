
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/utils/weight_helper.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

class WeightPickerModal {
  static Future<double?> show(
    BuildContext context, {
    required double initialWeight,
  }) {
    return showModalBottomSheet<double>(
      context: context,
      builder: (context) => _WeightPicker(
        initialWeight: initialWeight,
      ),
    );
  }
}

class _WeightPicker extends ConsumerStatefulWidget {

  const _WeightPicker({
    required this.initialWeight,
  });
  final double initialWeight;

  @override
  ConsumerState<_WeightPicker> createState() => _WeightPickerState();
}

class _WeightPickerState extends ConsumerState<_WeightPicker> {
  late double selectedWeight;
  late FixedExtentScrollController controller;

  @override
  void initState() {
    super.initState();
    final unit = ref.read(measurementUnitProvider);

    selectedWeight = widget.initialWeight.toDisplayUnit(unit);

    controller = FixedExtentScrollController(
      initialItem: WeightHelper.weightToIndex(selectedWeight, unit),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;
    final unit = ref.watch(measurementUnitProvider);

    // This is needed to update the picker when the unit changes
    // or when quick jumps are used.
    final currentWeightInDisplayUnit = selectedWeight;

    return StatefulBuilder(
      builder: (context, setModalState) => Container(
        height: 380,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title and current weight
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.weight,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${WeightHelper.formatPickerWeight(currentWeightInDisplayUnit, unit)} $unit',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Quick jump buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: WeightHelper.getQuickJumps(currentWeightInDisplayUnit, unit)
                  .map((jump) {
                return OutlinedButton(
                  onPressed: () {
                    final newWeight = WeightHelper.applyQuickJump(
                      currentWeight: currentWeightInDisplayUnit,
                      jump: jump,
                      unit: unit,
                    );
                    setModalState(() => selectedWeight = newWeight);
                    controller.animateToItem(
                      WeightHelper.weightToIndex(newWeight, unit),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    HapticFeedback.mediumImpact();
                  },
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(60, 36),
                  ),
                  child: Text(
                    jump > 0 ? '+$jump' : '$jump',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: jump > 0
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            // Picker
            Expanded(
              child: ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: 50,
                perspective: 0.005,
                diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: WeightConversion.getChildCount(unit),
                  builder: (context, index) {
                    final weight = WeightHelper.indexToWeight(index, unit);
                    final isSelected =
                        (weight - currentWeightInDisplayUnit).abs() < 0.05;
                    final displayText = WeightHelper.formatPickerWeight(weight, unit);

                    return Center(
                      child: Text(
                        displayText,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
                onSelectedItemChanged: (index) {
                  setModalState(() =>
                      selectedWeight = WeightHelper.indexToWeight(index, unit));
                  HapticFeedback.selectionClick();
                },
              ),
            ),
            const SizedBox(height: 16),
            // Confirm button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final weightInKg = selectedWeight.fromDisplayUnit(unit);
                  Navigator.of(context).pop(weightInKg);
                  HapticFeedback.mediumImpact();
                },
                child: Text(l10n.confirm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class RepsPickerModal {
  static Future<int?> show(BuildContext context, {required int initialReps}) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => _RepsPicker(initialReps: initialReps),
    );
  }
}

class _RepsPicker extends StatefulWidget {
  const _RepsPicker({required this.initialReps});
  final int initialReps;

  @override
  State<_RepsPicker> createState() => _RepsPickerState();
}

class _RepsPickerState extends State<_RepsPicker> {
  late int selectedReps;
  late FixedExtentScrollController controller;

  @override
  void initState() {
    super.initState();
    selectedReps = widget.initialReps;
    // Ensure the initial item is valid
    final initialItem = selectedReps > 0 ? selectedReps - 1 : 9;
    controller = FixedExtentScrollController(initialItem: initialItem);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setModalState) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Text(
              context.l10n.reps,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Quick select buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [5, 8, 10, 12, 15].map((reps) {
                final isSelected = selectedReps == reps;
                return FilterChip(
                  label: Text('$reps'),
                  selected: isSelected,
                  onSelected: (_) {
                    setModalState(() => selectedReps = reps);
                    controller.animateToItem(
                      reps - 1,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  },
                  selectedColor: context.colors.primaryContainer,
                  checkmarkColor: context.colors.primary,
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Picker - fixed height container
            SizedBox(
              height: 150,
              child: ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: 50,
                perspective: 0.005,
                diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: 50, // 1-50 reps
                  builder: (context, index) {
                    final reps = index + 1;
                    final isSelected = reps == selectedReps;
                    return Center(
                      child: Text(
                        reps.toString(),
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.onSurface,
                        ),
                      ),
                    );
                  },
                ),
                onSelectedItemChanged: (index) {
                  setModalState(() => selectedReps = index + 1);
                },
              ),
            ),

            const SizedBox(height: 16),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(selectedReps);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(context.l10n.confirm),
              ),
            ),

            // Bottom safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

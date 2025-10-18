
import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

class RepsPickerModal {
  static Future<int?> show(BuildContext context, {required int initialReps}) {
    return showModalBottomSheet<int>(
      context: context,
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
    final theme = context.theme;
    final l10n = context.l10n;

    return StatefulBuilder(
      builder: (context, setModalState) => Container(
        height: 350,
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
            // Title
            Text(
              l10n.reps,
              style: theme.textTheme.titleMedium?.copyWith(
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
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: theme.colorScheme.secondaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                  childCount: 50, // 1-50 reps
                  builder: (context, index) {
                    final reps = index + 1;
                    final isSelected = reps == selectedReps;
                    return Center(
                      child: Text(
                        reps.toString(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.onSurface,
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
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
                child: Text(l10n.confirm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

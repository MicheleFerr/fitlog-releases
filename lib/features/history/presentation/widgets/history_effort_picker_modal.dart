library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/rpe_autoregulation_service.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

class HistoryEffortPickerModal {
  static Future<int?> show(
    BuildContext context, {
    required int? initialRpe,
    required bool useRirMode,
  }) {
    return ModalService.showSheet<int>(
      context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0),
      builder: (context) =>
          _HistoryEffortPicker(initialRpe: initialRpe, useRirMode: useRirMode),
    );
  }
}

class _HistoryEffortPicker extends StatefulWidget {
  const _HistoryEffortPicker({
    required this.initialRpe,
    required this.useRirMode,
  });

  final int? initialRpe;
  final bool useRirMode;

  @override
  State<_HistoryEffortPicker> createState() => _HistoryEffortPickerState();
}

class _HistoryEffortPickerState extends State<_HistoryEffortPicker> {
  late final FixedExtentScrollController _controller;
  late int _selectedRpe;

  List<int> get _pickerValues =>
      widget.useRirMode ? const [4, 3, 2, 1, 0] : const [6, 7, 8, 9, 10];

  int _sanitizeRpe(int? rpe) {
    final value = rpe ?? 0;
    if (value < 6 || value > 10) return 8;
    return value;
  }

  int get _selectedDisplayValue {
    if (widget.useRirMode) {
      return RPEAutoregulationService.rpeToRIR(_selectedRpe.toDouble());
    }
    return _selectedRpe;
  }

  String get _selectedTitle {
    final label = widget.useRirMode ? context.l10n.rir : context.l10n.rpe;
    return '$label $_selectedDisplayValue';
  }

  String get _selectedDescription {
    switch (_selectedRpe) {
      case 6:
        return context.l10n.rpeScale5_6Desc;
      case 7:
        return context.l10n.rpeScale7Desc;
      case 8:
        return context.l10n.rpeScale8Desc;
      case 9:
        return context.l10n.rpeScale9Desc;
      case 10:
        return context.l10n.rpeScale10Desc;
      default:
        return '';
    }
  }

  Color _accentColor() {
    switch (_selectedRpe) {
      case 6:
      case 7:
        return context.colors.success;
      case 8:
      case 9:
        return context.colors.warning;
      case 10:
        return context.colors.error;
      default:
        return context.colors.primary;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedRpe = _sanitizeRpe(widget.initialRpe);
    _controller = FixedExtentScrollController(
      initialItem: _pickerValues.indexOf(_selectedDisplayValue),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColor();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            widget.useRirMode ? context.l10n.actualRir : context.l10n.actualRpe,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.useRirMode
                ? context.l10n.rirScaleDescription
                : context.l10n.rpeScaleDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedTitle,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedDescription,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListWheelScrollView.useDelegate(
              controller: _controller,
              itemExtent: 56,
              perspective: 0.005,
              diameterRatio: 1.2,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                final displayValue = _pickerValues[index];
                setState(() {
                  _selectedRpe = widget.useRirMode
                      ? RPEAutoregulationService.rirToRPE(displayValue).round()
                      : displayValue;
                });
                HapticFeedback.selectionClick();
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: _pickerValues.length,
                builder: (context, index) {
                  final displayValue = _pickerValues[index];
                  final isSelected = displayValue == _selectedDisplayValue;

                  return Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      style: context.textTheme.headlineSmall!.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? accentColor
                            : context.colors.onSurfaceVariant,
                      ),
                      child: Text(
                        '${widget.useRirMode ? context.l10n.rir : context.l10n.rpe} $displayValue',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_selectedRpe),
                  child: Text(context.l10n.confirm),
                ),
              ),
            ],
          ),
          SizedBox(height: context.bottomPadding),
        ],
      ),
    );
  }
}

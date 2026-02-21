import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/services/modal_service.dart';

/// Result from the reps picker modal
/// If isRange, use minReps/maxReps. Otherwise use reps.
class RepsPickerResult {
  const RepsPickerResult({this.reps, this.minReps, this.maxReps});

  /// Single value (exact mode)
  final int? reps;

  /// Min of range (range mode)
  final int? minReps;

  /// Max of range (range mode)
  final int? maxReps;

  bool get isRange => minReps != null && maxReps != null && minReps != maxReps;
}

class RepsPickerModal {
  /// Shows the reps picker and returns a single int (backward compatible)
  static Future<int?> show(BuildContext context, {required int initialReps}) async {
    final result = await showWithRange(
      context,
      initialReps: initialReps,
    );
    if (result == null) return null;
    return result.reps ?? result.minReps ?? initialReps;
  }

  /// Shows the reps picker with range support
  static Future<RepsPickerResult?> showWithRange(
    BuildContext context, {
    required int initialReps,
    int? initialMinReps,
    int? initialMaxReps,
  }) {
    return ModalService.showSheet<RepsPickerResult>(context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      builder: (context) => _RepsPicker(
        initialReps: initialReps,
        initialMinReps: initialMinReps,
        initialMaxReps: initialMaxReps,
      ),
    );
  }
}

class _RepsPicker extends StatefulWidget {
  const _RepsPicker({
    required this.initialReps,
    this.initialMinReps,
    this.initialMaxReps,
  });
  final int initialReps;
  final int? initialMinReps;
  final int? initialMaxReps;

  @override
  State<_RepsPicker> createState() => _RepsPickerState();
}

class _RepsPickerState extends State<_RepsPicker> {
  late bool _isRangeMode;
  late int _selectedReps;
  late int _selectedMinReps;
  late int _selectedMaxReps;

  late FixedExtentScrollController _singleController;
  late FixedExtentScrollController _minController;
  late FixedExtentScrollController _maxController;

  static const _rangePresets = [
    (3, 5),
    (6, 8),
    (8, 12),
    (12, 15),
    (15, 20),
  ];

  @override
  void initState() {
    super.initState();
    final hasRange = widget.initialMinReps != null &&
        widget.initialMaxReps != null &&
        widget.initialMinReps != widget.initialMaxReps;

    _isRangeMode = hasRange;
    _selectedReps = widget.initialReps;
    _selectedMinReps = widget.initialMinReps ?? widget.initialReps;
    _selectedMaxReps = widget.initialMaxReps ?? widget.initialReps;

    _singleController = FixedExtentScrollController(
      initialItem: _selectedReps > 0 ? _selectedReps - 1 : 9,
    );
    _minController = FixedExtentScrollController(
      initialItem: _selectedMinReps > 0 ? _selectedMinReps - 1 : 7,
    );
    _maxController = FixedExtentScrollController(
      initialItem: _selectedMaxReps > 0 ? _selectedMaxReps - 1 : 11,
    );
  }

  @override
  void dispose() {
    _singleController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _confirmSelection() {
    if (_isRangeMode) {
      // Ensure min <= max
      final min = _selectedMinReps <= _selectedMaxReps
          ? _selectedMinReps
          : _selectedMaxReps;
      final max = _selectedMinReps <= _selectedMaxReps
          ? _selectedMaxReps
          : _selectedMinReps;
      Navigator.of(context).pop(RepsPickerResult(
        reps: null,
        minReps: min,
        maxReps: max,
      ));
    } else {
      Navigator.of(context).pop(RepsPickerResult(reps: _selectedReps));
    }
  }

  String get _displayText {
    if (_isRangeMode) {
      final min = _selectedMinReps <= _selectedMaxReps
          ? _selectedMinReps
          : _selectedMaxReps;
      final max = _selectedMinReps <= _selectedMaxReps
          ? _selectedMaxReps
          : _selectedMinReps;
      return '$min-$max';
    }
    return '$_selectedReps';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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

          // Toggle: Exact / Range
          _buildModeToggle(),
          const SizedBox(height: 12),

          // Quick select chips
          _buildQuickSelectChips(),
          const SizedBox(height: 16),

          // Picker(s)
          if (_isRangeMode) _buildDualWheelPicker() else _buildSingleWheelPicker(),

          const SizedBox(height: 16),

          // Confirm button with display
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _confirmSelection,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('${context.l10n.confirm} ($_displayText)'),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            label: context.l10n.exact,
            isSelected: !_isRangeMode,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _isRangeMode = false);
            },
          ),
          _buildToggleOption(
            label: context.l10n.range,
            isSelected: _isRangeMode,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _isRangeMode = true;
                // Initialize range from current reps if not set
                if (_selectedMinReps == _selectedMaxReps) {
                  _selectedMinReps = (_selectedReps - 2).clamp(1, 50);
                  _selectedMaxReps = (_selectedReps + 2).clamp(1, 50);
                  _minController.jumpToItem(_selectedMinReps - 1);
                  _maxController.jumpToItem(_selectedMaxReps - 1);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: context.textTheme.labelLarge?.copyWith(
            color: isSelected
                ? context.colors.onPrimary
                : context.colors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSelectChips() {
    if (_isRangeMode) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: _rangePresets.map((preset) {
          final (min, max) = preset;
          final isSelected = _selectedMinReps == min && _selectedMaxReps == max;
          return FilterChip(
            label: Text('$min-$max'),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _selectedMinReps = min;
                _selectedMaxReps = max;
              });
              _minController.animateToItem(
                min - 1,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
              _maxController.animateToItem(
                max - 1,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            },
            selectedColor: context.colors.primaryContainer,
            checkmarkColor: context.colors.primary,
          );
        }).toList(),
      );
    } else {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [5, 8, 10, 12, 15].map((reps) {
          final isSelected = _selectedReps == reps;
          return FilterChip(
            label: Text('$reps'),
            selected: isSelected,
            onSelected: (_) {
              setState(() => _selectedReps = reps);
              _singleController.animateToItem(
                reps - 1,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            },
            selectedColor: context.colors.primaryContainer,
            checkmarkColor: context.colors.primary,
          );
        }).toList(),
      );
    }
  }

  Widget _buildSingleWheelPicker() {
    return SizedBox(
      height: 150,
      child: ListWheelScrollView.useDelegate(
        controller: _singleController,
        itemExtent: 50,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: 50,
          builder: (context, index) {
            final reps = index + 1;
            final isSelected = reps == _selectedReps;
            return Center(
              child: Text(
                reps.toString(),
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.onSurface,
                ),
              ),
            );
          },
        ),
        onSelectedItemChanged: (index) {
          setState(() => _selectedReps = index + 1);
        },
      ),
    );
  }

  Widget _buildDualWheelPicker() {
    return SizedBox(
      height: 150,
      child: Row(
        children: [
          // MIN wheel
          Expanded(
            child: Column(
              children: [
                Text(
                  'MIN',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: _minController,
                    itemExtent: 44,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 50,
                      builder: (context, index) {
                        final reps = index + 1;
                        final isSelected = reps == _selectedMinReps;
                        return Center(
                          child: Text(
                            reps.toString(),
                            style: context.textTheme.titleLarge?.copyWith(
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
                      setState(() => _selectedMinReps = index + 1);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Separator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '–',
              style: context.textTheme.headlineMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // MAX wheel
          Expanded(
            child: Column(
              children: [
                Text(
                  'MAX',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: _maxController,
                    itemExtent: 44,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 50,
                      builder: (context, index) {
                        final reps = index + 1;
                        final isSelected = reps == _selectedMaxReps;
                        return Center(
                          child: Text(
                            reps.toString(),
                            style: context.textTheme.titleLarge?.copyWith(
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
                      setState(() => _selectedMaxReps = index + 1);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

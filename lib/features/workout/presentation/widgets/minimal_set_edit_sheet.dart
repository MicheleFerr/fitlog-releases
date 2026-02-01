/// MinimalSetEditSheet - Ultra-minimal set editing modal
///
/// Design principles (from UX research):
/// - "Fewer taps, the better" - Max 3 steps for logging
/// - "One action per screen" - Focus on weight + reps only
/// - "Clutter kills momentum" - No distractions
/// - "Large tappable buttons" - For use during workout
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';

/// Custom scroll physics that accelerates when scrolling fast
/// Based on: https://stackoverflow.com/questions/57671811/flutter-how-to-override-scroll-physics
class FastScrollPhysics extends FixedExtentScrollPhysics {
  const FastScrollPhysics({super.parent});

  @override
  FastScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FastScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Amplify velocity for faster scrolling when user scrolls quickly
    final amplifiedVelocity = velocity.abs() > 500 ? velocity * 1.5 : velocity;
    return super.createBallisticSimulation(position, amplifiedVelocity);
  }

  @override
  double get minFlingVelocity => 50.0; // Lower threshold = easier to fling
}

/// Minimal set edit modal with PageView navigation between sets
class MinimalSetEditSheet extends StatefulWidget {
  const MinimalSetEditSheet({
    super.key,
    required this.exerciseSet,
    required this.onSave,
    this.currentSetIndex,
    this.totalSets,
    this.onSaveAndNext,
    this.onSaveAndPrevious,
    this.onApplyToAll,
    this.onCopyPrevious,
    this.previousSet,
    this.allSets,
    this.measurementUnit = 'kg',
    this.recentWeights,
    this.suggestedWeight,
    this.suggestedSource,
  });

  final ExerciseSet exerciseSet;
  final Function(ExerciseSet) onSave;
  final int? currentSetIndex;
  final int? totalSets;
  final Function(ExerciseSet)? onSaveAndNext;
  final Function(ExerciseSet)? onSaveAndPrevious;
  final Function(ExerciseSet)? onApplyToAll; // Apply current values to all sets
  final Function(ExerciseSet)? onCopyPrevious; // Copy from previous set
  final ExerciseSet? previousSet; // Previous set data for copy
  final List<ExerciseSet>? allSets; // All sets for dot indicators
  final String measurementUnit;
  final List<double>? recentWeights; // History of recent weights for quick select
  final double? suggestedWeight; // Pre-fill weight from suggestion provider
  final String? suggestedSource; // Source label for the suggestion chip

  @override
  State<MinimalSetEditSheet> createState() => _MinimalSetEditSheetState();
}

class _MinimalSetEditSheetState extends State<MinimalSetEditSheet> {
  late double _weight;
  late int _reps;
  bool _isManualInput = false;
  bool _isWeightFastScrubActive = false;
  bool _isRepsFastScrubActive = false;
  int? _lastFastScrubValue; // Track last value to avoid haptic spam

  late FixedExtentScrollController _weightController;
  late FixedExtentScrollController _repsController;
  late TextEditingController _weightTextController;
  late TextEditingController _repsTextController;
  final FocusNode _weightFocusNode = FocusNode();
  final FocusNode _repsFocusNode = FocusNode();

  // Weight range: 0 to 400 in 0.25 increments = 1601 items
  static const double _minWeight = 0;
  static const double _weightStep = 0.25;
  static const int _weightItemCount = 1601; // (400 - 0) / 0.25 + 1

  // Reps range: 1 to 100
  static const int _minReps = 1;
  static const int _maxReps = 100;

  @override
  void initState() {
    super.initState();
    _weight = widget.exerciseSet.weight ?? 0;
    _reps = widget.exerciseSet.reps ?? 10;

    // Initialize wheel controllers at current values
    final weightIndex = ((_weight - _minWeight) / _weightStep).round().clamp(0, _weightItemCount - 1);
    final repsIndex = (_reps - _minReps).clamp(0, _maxReps - _minReps);

    _weightController = FixedExtentScrollController(initialItem: weightIndex);
    _repsController = FixedExtentScrollController(initialItem: repsIndex);
    _weightTextController = TextEditingController(text: _formatWeight(_weight));
    _repsTextController = TextEditingController(text: '$_reps');

    // Select all text when focus is gained
    _weightFocusNode.addListener(() {
      if (_weightFocusNode.hasFocus) {
        _weightTextController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _weightTextController.text.length,
        );
      }
    });
    _repsFocusNode.addListener(() {
      if (_repsFocusNode.hasFocus) {
        _repsTextController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _repsTextController.text.length,
        );
      }
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _weightTextController.dispose();
    _repsTextController.dispose();
    _weightFocusNode.dispose();
    _repsFocusNode.dispose();
    super.dispose();
  }

  String _formatWeight(double weight) {
    if (weight % 1 == 0) return '${weight.toInt()}';
    if ((weight * 2) % 1 == 0) return weight.toStringAsFixed(1); // .5 increments
    return weight.toStringAsFixed(2); // .25 increments
  }

  bool get _isFirstSet => (widget.currentSetIndex ?? 0) == 0;
  bool get _hasMultipleSets => (widget.totalSets ?? 1) > 1;

  bool get _canSwipeNext =>
      widget.onSaveAndNext != null &&
      widget.currentSetIndex != null &&
      widget.totalSets != null &&
      widget.currentSetIndex! < widget.totalSets! - 1;

  bool get _canSwipePrevious =>
      widget.onSaveAndPrevious != null &&
      widget.currentSetIndex != null &&
      widget.currentSetIndex! > 0;

  ExerciseSet _createUpdatedSet() {
    return widget.exerciseSet.copyWith(
      weight: _weight,
      reps: _reps,
    );
  }

  void _save() {
    // Apply manual input if in manual mode
    if (_isManualInput) {
      _applyManualInputToWheel();
    }
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    widget.onSave(_createUpdatedSet());
  }

  void _saveAndNext() {
    if (!_canSwipeNext) return;
    if (_isManualInput) _applyManualInputToWheel();
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
    widget.onSaveAndNext!(_createUpdatedSet());
  }

  void _saveAndPrevious() {
    if (!_canSwipePrevious) return;
    if (_isManualInput) _applyManualInputToWheel();
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
    widget.onSaveAndPrevious!(_createUpdatedSet());
  }

  /// Apply manual text input values to wheel controllers
  void _applyManualInputToWheel() {
    // Parse weight from text
    final weightText = _weightTextController.text.replaceAll(',', '.');
    final parsedWeight = double.tryParse(weightText);
    if (parsedWeight != null && parsedWeight >= _minWeight) {
      _weight = parsedWeight;
      final weightIndex = ((_weight - _minWeight) / _weightStep).round().clamp(0, _weightItemCount - 1);
      _weightController.jumpToItem(weightIndex);
    }

    // Parse reps from text
    final parsedReps = int.tryParse(_repsTextController.text);
    if (parsedReps != null && parsedReps >= _minReps && parsedReps <= _maxReps) {
      _reps = parsedReps;
      final repsIndex = (_reps - _minReps).clamp(0, _maxReps - _minReps);
      _repsController.jumpToItem(repsIndex);
    }
  }

  void _applyToAll() {
    if (widget.onApplyToAll == null) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    widget.onApplyToAll!(_createUpdatedSet());
  }

  void _copyPrevious() {
    if (widget.previousSet == null) return;
    HapticFeedback.selectionClick();
    setState(() {
      _weight = widget.previousSet!.weight ?? 0;
      _reps = widget.previousSet!.reps ?? 10;
      _weightTextController.text = _formatWeight(_weight);
      _repsTextController.text = '$_reps';

      // Update wheel positions
      final weightIndex = ((_weight - _minWeight) / _weightStep).round().clamp(0, _weightItemCount - 1);
      final repsIndex = (_reps - _minReps).clamp(0, _maxReps - _minReps);
      _weightController.jumpToItem(weightIndex);
      _repsController.jumpToItem(repsIndex);
    });
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    const swipeThreshold = 300.0;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < swipeThreshold) return;

    if (velocity < 0 && _canSwipeNext) {
      _saveAndNext();
    } else if (velocity > 0 && _canSwipePrevious) {
      _saveAndPrevious();
    }
  }

  void _handleVerticalSwipe(DragEndDetails details) {
    const swipeThreshold = 300.0;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > swipeThreshold) {
      _save();
    }
  }

  void _onWeightTextChanged(String value) {
    final weight = double.tryParse(value.replaceAll(',', '.'));
    if (weight != null && weight >= 0) {
      setState(() {
        _weight = weight;
      });
    }
  }

  void _onRepsTextChanged(String value) {
    final reps = int.tryParse(value);
    if (reps != null && reps >= 1 && reps <= 100) {
      setState(() {
        _reps = reps;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: _handleHorizontalSwipe,
      onVerticalDragEnd: _handleVerticalSwipe,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              _buildDragHandle(),

              // Dot indicators for sets
              if (_hasMultipleSets) _buildDotIndicators(),

              // Suggested weight chip
              if (widget.suggestedWeight != null)
                _buildSuggestionChip(),

              // Recent weights chips
              if (widget.recentWeights != null && widget.recentWeights!.isNotEmpty)
                _buildRecentWeightsChips(),

              const SizedBox(height: 12),

              // Main content: Weight + Reps pickers
              _buildPickers(),

              const SizedBox(height: 16),

              // Action buttons row (Apply to all / Copy previous)
              _buildActionRow(),

              const SizedBox(height: 16),

              // Hint: swipe down to save
              Text(
                '↓ Swipe down per salvare',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.outline,
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildDotIndicators() {
    final currentIndex = widget.currentSetIndex ?? 0;
    final totalSets = widget.totalSets ?? 1;
    final allSets = widget.allSets;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left arrow
          if (_canSwipePrevious)
            GestureDetector(
              onTap: _saveAndPrevious,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  AppIcons.arrowBackIos,
                  size: 16,
                  color: context.colors.primary,
                ),
              ),
            )
          else
            const SizedBox(width: 32),

          const SizedBox(width: 8),

          // Dot indicators
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(totalSets, (index) {
                  final isActive = index == currentIndex;
                  final hasWeight = allSets != null &&
                      index < allSets.length &&
                      (allSets[index].weight ?? 0) > 0;

                  return GestureDetector(
                    onTap: () {
                      // Navigate to that set
                      if (index < currentIndex && _canSwipePrevious) {
                        // Go backwards
                        for (var i = currentIndex; i > index; i--) {
                          _saveAndPrevious();
                        }
                      } else if (index > currentIndex && _canSwipeNext) {
                        // Go forwards
                        for (var i = currentIndex; i < index; i++) {
                          _saveAndNext();
                        }
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isActive
                            ? context.colors.primary
                            : hasWeight
                                ? context.colors.primary.withValues(alpha: 0.5)
                                : context.colors.outlineVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: !hasWeight && !isActive
                            ? Border.all(
                                color: context.colors.outline.withValues(alpha: 0.3),
                                width: 1,
                              )
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Right arrow
          if (_canSwipeNext)
            GestureDetector(
              onTap: _saveAndNext,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  AppIcons.forwardIos,
                  size: 16,
                  color: context.colors.primary,
                ),
              ),
            )
          else
            const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildPickers() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Toggle for manual input + Done button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Done button (only visible in manual mode)
              if (_isManualInput)
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              TextButton.icon(
                onPressed: () {
                  // Unfocus any text field first
                  FocusScope.of(context).unfocus();

                  setState(() {
                    if (_isManualInput) {
                      // Switching TO wheel: apply typed values to wheel
                      _applyManualInputToWheel();
                    } else {
                      // Switching TO manual: populate text fields
                      _weightTextController.text = _formatWeight(_weight);
                      _repsTextController.text = '$_reps';
                    }
                    _isManualInput = !_isManualInput;
                  });
                },
                icon: Icon(
                  _isManualInput ? AppIcons.dialpad : AppIcons.keyboard,
                  size: 18,
                ),
                label: Text(_isManualInput ? 'Wheel' : 'Digita'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Pickers row
          Row(
            children: [
              // Weight picker
              Expanded(
                child: _isManualInput
                    ? _buildManualInput(
                        label: context.l10n.weightKg.replaceAll('kg', widget.measurementUnit),
                        controller: _weightTextController,
                        focusNode: _weightFocusNode,
                        onChanged: _onWeightTextChanged,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        suffix: widget.measurementUnit,
                      )
                    : _buildWheelPicker(
                        label: context.l10n.weightKg.replaceAll('kg', widget.measurementUnit),
                        controller: _weightController,
                        itemCount: _weightItemCount,
                        itemBuilder: (index) {
                          final weight = _minWeight + (index * _weightStep);
                          final isSelected = (weight - _weight).abs() < 0.01;
                          return _buildPickerItem(
                            text: _formatWeight(weight),
                            isSelected: isSelected,
                          );
                        },
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _weight = _minWeight + (index * _weightStep);
                          });
                          HapticFeedback.selectionClick();
                        },
                        // Fast scrub sidebar - fewer values, easier to hit
                        showFastScrub: true,
                        fastScrubValues: [0, 20, 40, 60, 80, 100, 150, 200],
                        onFastScrubSelect: (value) {
                          final index = ((value - _minWeight) / _weightStep).round().clamp(0, _weightItemCount - 1);
                          _weightController.jumpToItem(index);
                          setState(() => _weight = value.toDouble());
                        },
                        isFastScrubActive: _isWeightFastScrubActive,
                        onFastScrubStart: () => setState(() => _isWeightFastScrubActive = true),
                        onFastScrubEnd: () => setState(() => _isWeightFastScrubActive = false),
                        currentValue: _weight,
                      ),
              ),

              const SizedBox(width: 16),

              // Reps picker
              Expanded(
                child: _isManualInput
                    ? _buildManualInput(
                        label: context.l10n.reps,
                        controller: _repsTextController,
                        focusNode: _repsFocusNode,
                        onChanged: _onRepsTextChanged,
                        keyboardType: TextInputType.number,
                        suffix: '',
                      )
                    : _buildWheelPicker(
                        label: context.l10n.reps,
                        controller: _repsController,
                        itemCount: _maxReps - _minReps + 1,
                        itemBuilder: (index) {
                          final reps = _minReps + index;
                          final isSelected = reps == _reps;
                          return _buildPickerItem(
                            text: '$reps',
                            isSelected: isSelected,
                          );
                        },
                        onSelectedItemChanged: (index) {
                          setState(() => _reps = _minReps + index);
                          HapticFeedback.selectionClick();
                        },
                        // Fast scrub for common rep ranges
                        showFastScrub: true,
                        fastScrubValues: [1, 5, 8, 10, 12, 15, 20, 30],
                        onFastScrubSelect: (value) {
                          final index = (value - _minReps).clamp(0, _maxReps - _minReps);
                          _repsController.jumpToItem(index);
                          setState(() => _reps = value);
                        },
                        isFastScrubActive: _isRepsFastScrubActive,
                        onFastScrubStart: () => setState(() => _isRepsFastScrubActive = true),
                        onFastScrubEnd: () => setState(() => _isRepsFastScrubActive = false),
                        currentValue: _reps.toDouble(),
                        fastScrubOnRight: true,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManualInput({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required ValueChanged<String> onChanged,
    required TextInputType keyboardType,
    required String suffix,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              textInputAction: TextInputAction.done,
              textAlign: TextAlign.center,
              style: context.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
              onSubmitted: (_) {
                // Close keyboard on done
                focusNode.unfocus();
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                suffix: suffix.isNotEmpty
                    ? Text(
                        suffix,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      )
                    : null,
              ),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWheelPicker({
    required String label,
    required FixedExtentScrollController controller,
    required int itemCount,
    required Widget Function(int index) itemBuilder,
    required ValueChanged<int> onSelectedItemChanged,
    bool showFastScrub = false,
    List<int>? fastScrubValues,
    void Function(int value)? onFastScrubSelect,
    bool isFastScrubActive = false,
    VoidCallback? onFastScrubStart,
    VoidCallback? onFastScrubEnd,
    double currentValue = 0,
    bool fastScrubOnRight = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: Row(
            children: [
              // Fast scrub sidebar (LEFT)
              if (showFastScrub && fastScrubValues != null && !fastScrubOnRight)
                _buildFastScrubSidebar(
                  values: fastScrubValues,
                  onSelect: onFastScrubSelect,
                  isActive: isFastScrubActive,
                  onStart: onFastScrubStart,
                  onEnd: onFastScrubEnd,
                  currentValue: currentValue,
                  onRight: false,
                ),
              // Main wheel picker
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Selection highlight
                      Center(
                        child: Container(
                          height: 44,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
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
                      // Wheel picker with fast scroll physics
                      ListWheelScrollView.useDelegate(
                        controller: controller,
                        itemExtent: 44,
                        perspective: 0.003,
                        diameterRatio: 1.5,
                        physics: const FastScrollPhysics(),
                        onSelectedItemChanged: onSelectedItemChanged,
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: itemCount,
                          builder: (context, index) => itemBuilder(index),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Fast scrub sidebar (RIGHT)
              if (showFastScrub && fastScrubValues != null && fastScrubOnRight)
                _buildFastScrubSidebar(
                  values: fastScrubValues,
                  onSelect: onFastScrubSelect,
                  isActive: isFastScrubActive,
                  onStart: onFastScrubStart,
                  onEnd: onFastScrubEnd,
                  currentValue: currentValue,
                  onRight: true,
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Fast scrub sidebar - hidden by default, reveals values on drag
  /// User drags up/down to quickly jump between values
  Widget _buildFastScrubSidebar({
    required List<int> values,
    void Function(int value)? onSelect,
    required bool isActive,
    VoidCallback? onStart,
    VoidCallback? onEnd,
    required double currentValue,
    bool onRight = false,
  }) {
    return GestureDetector(
      onVerticalDragStart: (_) {
        _lastFastScrubValue = null;
        onStart?.call();
        HapticFeedback.lightImpact();
      },
      onVerticalDragUpdate: (details) {
        // Calculate which value based on Y position
        final localY = details.localPosition.dy;
        final itemHeight = 150 / values.length;
        final index = (localY / itemHeight).clamp(0, values.length - 1).toInt();
        final selectedValue = values[index];

        // Only update if value changed (prevents haptic spam)
        if (selectedValue != _lastFastScrubValue) {
          _lastFastScrubValue = selectedValue;
          onSelect?.call(selectedValue);
          HapticFeedback.selectionClick();
        }
      },
      onVerticalDragEnd: (_) {
        _lastFastScrubValue = null;
        onEnd?.call();
      },
      onVerticalDragCancel: () {
        _lastFastScrubValue = null;
        onEnd?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: isActive ? 36 : 12,
        margin: EdgeInsets.only(right: onRight ? 0 : 4, left: onRight ? 4 : 0),
        decoration: BoxDecoration(
          color: isActive
              ? context.colors.primary.withValues(alpha: 0.15)
              : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? Border.all(color: context.colors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: isActive
            // Expanded: show values
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: values.map((value) {
                  final isNearCurrent = (currentValue - value).abs() < 3;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
                    decoration: isNearCurrent
                        ? BoxDecoration(
                            color: context.colors.primary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Text(
                      '$value',
                      style: context.textTheme.labelSmall?.copyWith(
                        fontSize: 8,
                        fontWeight: isNearCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isNearCurrent
                            ? context.colors.primary
                            : context.colors.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              )
            // Collapsed: just show a subtle indicator line
            : Center(
                child: Container(
                  width: 3,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPickerItem({
    required String text,
    required bool isSelected,
  }) {
    return Center(
      child: Text(
        text,
        style: context.textTheme.headlineSmall?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? context.colors.primary
              : context.colors.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // First set: "Applica a tutti"
          // Other sets: "Copia precedente"
          if (_isFirstSet && widget.onApplyToAll != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _applyToAll,
                icon: const Icon(AppIcons.doneAll, size: 18),
                label: Text(context.l10n.applyToAll),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            )
          else if (!_isFirstSet && widget.previousSet != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _copyPrevious,
                icon: const Icon(AppIcons.contentCopyRounded, size: 18),
                label: Text(context.l10n.copyPrevious),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds a highlighted chip for the AI-suggested weight.
  Widget _buildSuggestionChip() {
    final weight = widget.suggestedWeight!;
    final isSelected = (_weight - weight).abs() < 0.01;
    final label = widget.suggestedSource ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: [
          ActionChip(
            avatar: Icon(
              AppIcons.lightbulbOutline,
              size: 16,
              color: isSelected
                  ? context.colors.onPrimary
                  : context.colors.primary,
            ),
            label: Text(
              '${_formatWeight(weight)} ${widget.measurementUnit}'
              '${label.isNotEmpty ? ' · $label' : ''}',
            ),
            labelStyle: context.textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? context.colors.onPrimary
                  : context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: isSelected
                ? context.colors.primary
                : context.colors.primary.withValues(alpha: 0.12),
            side: BorderSide(
              color: context.colors.primary.withValues(alpha: 0.4),
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _weight = weight);
              _weightTextController.text = _formatWeight(weight);
              final weightIndex = ((weight - _minWeight) / _weightStep)
                  .round()
                  .clamp(0, _weightItemCount - 1);
              _weightController.jumpToItem(weightIndex);
            },
          ),
        ],
      ),
    );
  }

  /// Builds chips row with recent weights for quick selection
  Widget _buildRecentWeightsChips() {
    final weights = widget.recentWeights!;
    // Remove duplicates and sort by most recent (first = most recent)
    final uniqueWeights = weights.toSet().take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.recentWeights,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: uniqueWeights.map((weight) {
                final isSelected = (_weight - weight).abs() < 0.01;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _weight = weight);
                      _weightTextController.text = _formatWeight(weight);
                      // Update wheel position
                      final weightIndex = ((weight - _minWeight) / _weightStep)
                          .round()
                          .clamp(0, _weightItemCount - 1);
                      _weightController.animateToItem(
                        weightIndex,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(50, 36),
                      backgroundColor: isSelected
                          ? context.colors.primary.withValues(alpha: 0.1)
                          : null,
                      side: BorderSide(
                        color: isSelected
                            ? context.colors.primary
                            : context.colors.outline,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      '${_formatWeight(weight)} ${widget.measurementUnit}',
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? context.colors.primary
                            : context.colors.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Extension to easily show the minimal set edit sheet
extension MinimalSetEditSheetExtension on BuildContext {
  Future<void> showMinimalSetEditSheet({
    required ExerciseSet exerciseSet,
    required Function(ExerciseSet) onSave,
    int? currentSetIndex,
    int? totalSets,
    Function(ExerciseSet)? onSaveAndNext,
    Function(ExerciseSet)? onSaveAndPrevious,
    Function(ExerciseSet)? onApplyToAll,
    Function(ExerciseSet)? onCopyPrevious,
    ExerciseSet? previousSet,
    List<ExerciseSet>? allSets,
    String measurementUnit = 'kg',
    List<double>? recentWeights,
    double? suggestedWeight,
    String? suggestedSource,
  }) {
    return showModalBottomSheet<void>(
      context: this,
      isScrollControlled: true,
      backgroundColor: colors.surface.withValues(alpha: 0),
      builder: (context) => MinimalSetEditSheet(
        exerciseSet: exerciseSet,
        onSave: onSave,
        currentSetIndex: currentSetIndex,
        totalSets: totalSets,
        onSaveAndNext: onSaveAndNext,
        onSaveAndPrevious: onSaveAndPrevious,
        onApplyToAll: onApplyToAll,
        onCopyPrevious: onCopyPrevious,
        previousSet: previousSet,
        allSets: allSets,
        measurementUnit: measurementUnit,
        recentWeights: recentWeights,
        suggestedWeight: suggestedWeight,
        suggestedSource: suggestedSource,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/providers/app_config_provider.dart';

class WeightPickerModal extends ConsumerStatefulWidget {
  final double initialWeight;
  final String unit;
  final Function(double) onWeightSelected;

  const WeightPickerModal({
    super.key,
    required this.initialWeight,
    required this.unit,
    required this.onWeightSelected,
  });

  @override
  ConsumerState<WeightPickerModal> createState() => _WeightPickerModalState();
}

class _WeightPickerModalState extends ConsumerState<WeightPickerModal> {
  late FixedExtentScrollController _controller;
  late double _selectedWeight;
  
  // Generate weight options from 0 to 500 with 0.5 increments
  static const double _minWeight = 0.0;
  static const double _maxWeight = 500.0;
  static const double _increment = 0.5;
  
  late List<double> _weightOptions;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    
    // Generate weight options
    _weightOptions = [];
    for (double weight = _minWeight; weight <= _maxWeight; weight += _increment) {
      _weightOptions.add(weight);
    }
    
    // Find initial weight index
    _selectedWeight = widget.initialWeight;
    _selectedIndex = _findClosestWeightIndex(_selectedWeight);
    
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  int _findClosestWeightIndex(double weight) {
    int closestIndex = 0;
    double closestDiff = double.infinity;
    
    for (int i = 0; i < _weightOptions.length; i++) {
      double diff = (_weightOptions[i] - weight).abs();
      if (diff < closestDiff) {
        closestDiff = diff;
        closestIndex = i;
      }
    }
    
    return closestIndex;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Weight',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Scroll to select weight in ${widget.unit}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: _selectWeight,
                  child: const Text('Select'),
                ),
              ],
            ),
          ),
          
          // Current selection display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_selectedWeight.toStringAsFixed(_selectedWeight % 1 == 0 ? 0 : 1)} ${widget.unit}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Weight picker wheel
          Expanded(
            child: Stack(
              children: [
                // Selection indicator overlay
                Center(
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                
                // ListWheelScrollView for weight selection
                ListWheelScrollView.useDelegate(
                  controller: _controller,
                  itemExtent: 60,
                  perspective: 0.003,
                  diameterRatio: 1.5,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                      _selectedWeight = _weightOptions[index];
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      if (index < 0 || index >= _weightOptions.length) {
                        return null;
                      }
                      
                      final weight = _weightOptions[index];
                      final isSelected = index == _selectedIndex;
                      
                      return Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Text(
                            weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              fontSize: isSelected ? 24 : 20,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _weightOptions.length,
                  ),
                ),
              ],
            ),
          ),
          
          // Quick selection buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Select',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _getQuickSelectWeights().map((weight) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} ${widget.unit}'),
                          selected: _selectedWeight == weight,
                          onSelected: (selected) {
                            if (selected) {
                              _jumpToWeight(weight);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  List<double> _getQuickSelectWeights() {
    // Common weight plates and increments
    if (widget.unit == 'kg') {
      return [0, 5, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100];
    } else {
      // lbs
      return [0, 10, 25, 45, 65, 85, 115, 135, 155, 185, 205, 225];
    }
  }

  void _jumpToWeight(double weight) {
    final index = _findClosestWeightIndex(weight);
    _controller.animateToItem(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _selectWeight() {
    widget.onWeightSelected(_selectedWeight);
    Navigator.pop(context);
  }
}

// Extension for easy modal showing
extension WeightPickerModalExtension on BuildContext {
  Future<void> showWeightPicker({
    required double initialWeight,
    required String unit,
    required Function(double) onWeightSelected,
  }) {
    return showModalBottomSheet(
      context: this,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => WeightPickerModal(
        initialWeight: initialWeight,
        unit: unit,
        onWeightSelected: onWeightSelected,
      ),
    );
  }
}
import 'package:flutter/material.dart';

class RepsPickerModal extends StatefulWidget {
  final int initialReps;
  final Function(int) onRepsSelected;

  const RepsPickerModal({
    super.key,
    required this.initialReps,
    required this.onRepsSelected,
  });

  @override
  State<RepsPickerModal> createState() => _RepsPickerModalState();
}

class _RepsPickerModalState extends State<RepsPickerModal> {
  late FixedExtentScrollController _controller;
  late int _selectedReps;
  
  // Generate reps options from 1 to 100
  static const int _minReps = 1;
  static const int _maxReps = 100;
  
  late List<int> _repsOptions;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    
    // Generate reps options
    _repsOptions = List.generate(_maxReps - _minReps + 1, (index) => _minReps + index);
    
    // Find initial reps index
    _selectedReps = widget.initialReps.clamp(_minReps, _maxReps);
    _selectedIndex = _selectedReps - _minReps;
    
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);
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
                        'Select Reps',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Scroll to select repetitions',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: _selectReps,
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
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.repeat,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  '$_selectedReps reps',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Reps picker wheel
          Expanded(
            child: Stack(
              children: [
                // Selection indicator overlay
                Center(
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                
                // ListWheelScrollView for reps selection
                ListWheelScrollView.useDelegate(
                  controller: _controller,
                  itemExtent: 60,
                  perspective: 0.003,
                  diameterRatio: 1.5,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                      _selectedReps = _repsOptions[index];
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      if (index < 0 || index >= _repsOptions.length) {
                        return null;
                      }
                      
                      final reps = _repsOptions[index];
                      final isSelected = index == _selectedIndex;
                      
                      return Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Text(
                            '$reps',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              fontSize: isSelected ? 24 : 20,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _repsOptions.length,
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
                    children: _getQuickSelectReps().map((reps) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('$reps'),
                          selected: _selectedReps == reps,
                          onSelected: (selected) {
                            if (selected) {
                              _jumpToReps(reps);
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

  List<int> _getQuickSelectReps() {
    // Common rep ranges
    return [1, 3, 5, 6, 8, 10, 12, 15, 20, 25, 30];
  }

  void _jumpToReps(int reps) {
    final index = reps - _minReps;
    if (index >= 0 && index < _repsOptions.length) {
      _controller.animateToItem(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _selectReps() {
    widget.onRepsSelected(_selectedReps);
    Navigator.pop(context);
  }
}

// Extension for easy modal showing
extension RepsPickerModalExtension on BuildContext {
  Future<void> showRepsPicker({
    required int initialReps,
    required Function(int) onRepsSelected,
  }) {
    return showModalBottomSheet(
      context: this,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => RepsPickerModal(
        initialReps: initialReps,
        onRepsSelected: onRepsSelected,
      ),
    );
  }
}
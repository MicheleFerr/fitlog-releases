import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/widgets/plate_calculator_widget.dart';

class HybridQuickEditOverlay extends ConsumerStatefulWidget {
  final ExerciseSet exerciseSet;
  final Function(ExerciseSet) onSave;
  final VoidCallback onCancel;
  final Offset position;
  final ExerciseSet? previousSet;
  final List<double>? recentWeights;

  const HybridQuickEditOverlay({
    super.key,
    required this.exerciseSet,
    required this.onSave,
    required this.onCancel,
    required this.position,
    this.previousSet,
    this.recentWeights,
  });

  @override
  ConsumerState<HybridQuickEditOverlay> createState() => _HybridQuickEditOverlayState();
}

class _HybridQuickEditOverlayState extends ConsumerState<HybridQuickEditOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late FixedExtentScrollController _weightController;
  late FixedExtentScrollController _repsController;
  late TextEditingController _weightTextController;
  late TextEditingController _repsTextController;
  
  double _selectedWeight = 0.0;
  int _selectedReps = 0;
  bool _isManualWeightEntry = false;
  bool _isManualRepsEntry = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing values
    _selectedWeight = widget.exerciseSet.weight ?? 20.0;
    _selectedReps = widget.exerciseSet.reps ?? 10;
    
    _weightTextController = TextEditingController(text: _selectedWeight.toString());
    _repsTextController = TextEditingController(text: _selectedReps.toString());
    
    // Calculate initial scroll positions - 0.5kg increments
    final weightIndex = (_selectedWeight * 2).round();
    final repsIndex = _selectedReps - 1;
    
    _weightController = FixedExtentScrollController(initialItem: weightIndex);
    _repsController = FixedExtentScrollController(initialItem: repsIndex.clamp(0, 49));

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _weightTextController.dispose();
    _repsTextController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate position to keep overlay on screen
    double left = widget.position.dx - 180;
    double top = widget.position.dy - 150;
    
    // Keep within screen bounds
    left = left.clamp(16.0, screenSize.width - 376.0);
    top = top.clamp(50.0, screenSize.height - 450.0);

    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: theme.colorScheme.surface,
                shadowColor: Colors.black.withOpacity(0.3),
                child: Container(
                  width: 360,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Quick Edit Set ${widget.exerciseSet.setNumber}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Copy from previous button
                          if (widget.previousSet != null)
                            IconButton(
                              icon: const Icon(Icons.copy, size: 16),
                              onPressed: _copyFromPreviousSet,
                              style: IconButton.styleFrom(
                                backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
                                padding: const EdgeInsets.all(6),
                              ),
                              tooltip: 'Copy from Set ${widget.previousSet!.setNumber}',
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Recent weights chips (if available)
                      if (widget.recentWeights != null && widget.recentWeights!.isNotEmpty) ...[
                        SizedBox(
                          height: 32,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.recentWeights!.length,
                            itemBuilder: (context, index) {
                              final weight = widget.recentWeights![index];
                              final isSelected = (_selectedWeight - weight).abs() < 0.1;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () => _setWeight(weight),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? theme.colorScheme.primary 
                                          : theme.colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.outline.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      '${weight}kg',
                                      style: TextStyle(
                                        color: isSelected
                                            ? theme.colorScheme.onPrimary
                                            : theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // Pickers row
                      Row(
                        children: [
                          // Weight picker
                          Expanded(
                            child: _buildWeightPicker(context, config),
                          ),
                          const SizedBox(width: 16),
                          // Reps picker  
                          Expanded(
                            child: _buildRepsPicker(context),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Quick adjust buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildQuickButton('-2.5', () => _adjustWeight(-2.5), theme.colorScheme.error),
                          const SizedBox(width: 8),
                          _buildQuickButton('+2.5', () => _adjustWeight(2.5), theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          _buildQuickButton('+5', () => _adjustWeight(5), theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          _buildQuickButton('+25', () => _adjustWeight(25), theme.colorScheme.tertiary),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Plate Calculator button
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () => _showPlateCalculator(context),
                          icon: const Icon(Icons.circle_outlined, size: 16),
                          label: const Text('Plate Calculator'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.secondary,
                            side: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.5)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _cancel,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: _save,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeightPicker(BuildContext context, config) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Weight (${config.measurementUnit})',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            // Toggle to manual entry
            IconButton(
              icon: Icon(
                _isManualWeightEntry ? Icons.dialpad : Icons.keyboard,
                size: 16,
              ),
              onPressed: () {
                setState(() {
                  _isManualWeightEntry = !_isManualWeightEntry;
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: _isManualWeightEntry ? 'Use wheel' : 'Type manually',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: _isManualWeightEntry
              ? Center(
                  child: TextField(
                    controller: _weightTextController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0.0',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                    onChanged: (value) {
                      final weight = double.tryParse(value) ?? 0;
                      setState(() => _selectedWeight = weight);
                    },
                  ),
                )
              : ListWheelScrollView.useDelegate(
                  controller: _weightController,
                  itemExtent: 40,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 401, // 0 to 200kg in 0.5kg increments
                    builder: (context, index) {
                      final weight = index / 2.0;
                      final isSelected = (weight - _selectedWeight).abs() < 0.1;
                      return Container(
                        alignment: Alignment.center,
                        child: Text(
                          weight % 1 == 0 ? weight.toInt().toString() : weight.toString(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected 
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      );
                    },
                  ),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedWeight = index / 2.0;
                      _weightTextController.text = _selectedWeight.toString();
                    });
                    HapticFeedback.selectionClick();
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRepsPicker(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.repeat,
              size: 16,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              'Reps',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 4),
            // Toggle to manual entry
            IconButton(
              icon: Icon(
                _isManualRepsEntry ? Icons.dialpad : Icons.keyboard,
                size: 16,
              ),
              onPressed: () {
                setState(() {
                  _isManualRepsEntry = !_isManualRepsEntry;
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: _isManualRepsEntry ? 'Use wheel' : 'Type manually',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.secondary.withOpacity(0.3),
            ),
          ),
          child: _isManualRepsEntry
              ? Center(
                  child: TextField(
                    controller: _repsTextController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                    onChanged: (value) {
                      final reps = int.tryParse(value) ?? 0;
                      setState(() => _selectedReps = reps);
                    },
                  ),
                )
              : ListWheelScrollView.useDelegate(
                  controller: _repsController,
                  itemExtent: 40,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 50, // 1 to 50 reps
                    builder: (context, index) {
                      final reps = index + 1;
                      final isSelected = reps == _selectedReps;
                      return Container(
                        alignment: Alignment.center,
                        child: Text(
                          reps.toString(),
                          style: theme.textTheme.titleMedium?.copyWith(
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
                    setState(() {
                      _selectedReps = index + 1;
                      _repsTextController.text = _selectedReps.toString();
                    });
                    HapticFeedback.selectionClick();
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQuickButton(String label, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _setWeight(double weight) {
    setState(() {
      _selectedWeight = weight;
      _weightTextController.text = weight.toString();
      // Scroll to the weight in the picker
      final index = (weight * 2).round();
      _weightController.animateToItem(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    HapticFeedback.selectionClick();
  }

  void _adjustWeight(double increment) {
    final newWeight = ((_selectedWeight + increment).clamp(0, 500)).toDouble();
    _setWeight(newWeight);
  }

  void _save() {
    final updatedSet = widget.exerciseSet.copyWith(
      weight: _selectedWeight > 0 ? _selectedWeight : null,
      reps: _selectedReps > 0 ? _selectedReps : null,
    );

    HapticFeedback.lightImpact();
    widget.onSave(updatedSet);
    _animateOut();
  }

  void _cancel() {
    widget.onCancel();
    _animateOut();
  }

  void _animateOut() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _copyFromPreviousSet() {
    if (widget.previousSet == null) return;
    
    if (widget.previousSet!.weight != null) {
      _setWeight(widget.previousSet!.weight!);
    }
    
    if (widget.previousSet!.reps != null) {
      setState(() {
        _selectedReps = widget.previousSet!.reps!;
        _repsTextController.text = _selectedReps.toString();
        // Scroll to the reps in the picker
        final repsIndex = (_selectedReps - 1).clamp(0, 49);
        _repsController.animateToItem(
          repsIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
    
    HapticFeedback.lightImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copied: ${widget.previousSet!.weight?.toString() ?? "--"}kg × ${widget.previousSet!.reps?.toString() ?? "--"}',
        ),
        duration: const Duration(milliseconds: 800),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showPlateCalculator(BuildContext context) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Title
                Row(
                  children: [
                    Icon(
                      Icons.circle_outlined,
                      color: theme.colorScheme.secondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Plate Calculator',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Plate calculator widget
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: PlateCalculatorWidget(
                      targetWeight: _selectedWeight,
                      onWeightChanged: (weight) {
                        Navigator.pop(context);
                        _setWeight(weight);
                      },
                      unit: ref.read(appConfigProvider).measurementUnit,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    
    HapticFeedback.lightImpact();
  }
}

// Extension for easy overlay showing
extension HybridQuickEditOverlayExtension on BuildContext {
  Future<void> showHybridQuickEditOverlay({
    required ExerciseSet exerciseSet,
    required Function(ExerciseSet) onSave,
    required Offset position,
    ExerciseSet? previousSet,
    List<double>? recentWeights,
  }) {
    return showDialog(
      context: this,
      barrierColor: Colors.black26,
      builder: (context) => Stack(
        children: [
          // Transparent barrier that closes overlay when tapped
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
          HybridQuickEditOverlay(
            exerciseSet: exerciseSet,
            onSave: onSave,
            onCancel: () => Navigator.of(context).pop(),
            position: position,
            previousSet: previousSet,
            recentWeights: recentWeights,
          ),
        ],
      ),
    );
  }
}
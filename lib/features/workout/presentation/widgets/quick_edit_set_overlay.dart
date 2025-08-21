import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise.dart';
import '../../../../shared/presentation/providers/app_config_provider.dart';

class QuickEditSetOverlay extends ConsumerStatefulWidget {
  final ExerciseSet exerciseSet;
  final Function(ExerciseSet) onSave;
  final VoidCallback onCancel;
  final Offset position;
  final ExerciseSet? previousSet; // Set precedente per copiare i valori

  const QuickEditSetOverlay({
    super.key,
    required this.exerciseSet,
    required this.onSave,
    required this.onCancel,
    required this.position,
    this.previousSet,
  });

  @override
  ConsumerState<QuickEditSetOverlay> createState() => _QuickEditSetOverlayState();
}

class _QuickEditSetOverlayState extends ConsumerState<QuickEditSetOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late FixedExtentScrollController _weightController;
  late FixedExtentScrollController _repsController;
  
  double _selectedWeight = 0.0;
  int _selectedReps = 0;

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing values
    _selectedWeight = widget.exerciseSet.weight ?? 20.0;
    _selectedReps = widget.exerciseSet.reps ?? 10;
    
    // Calculate initial scroll positions - simple 0.5kg increments
    final weightIndex = (_selectedWeight * 2).round(); // 0.5kg increments
    final repsIndex = _selectedReps - 1; // 1-based to 0-based
    
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate position to keep overlay on screen
    double left = widget.position.dx - 160; // Center the overlay (320/2)
    double top = widget.position.dy - 120;
    
    // Keep within screen bounds
    left = left.clamp(16.0, screenSize.width - 336.0);
    top = top.clamp(50.0, screenSize.height - 280.0);

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
                color: Theme.of(context).colorScheme.surface,
                shadowColor: Colors.black.withValues(alpha: 0.3),
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Quick Edit Set ${widget.exerciseSet.setNumber}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Pulsante per copiare dal set precedente
                          if (widget.previousSet != null &&
                              (widget.previousSet!.weight != null || widget.previousSet!.reps != null))
                            InkWell(
                              onTap: _copyFromPreviousSet,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.copy,
                                      size: 12,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Set ${widget.previousSet!.setNumber}',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Number pickers row
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Weight (${config.measurementUnit})',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: ListWheelScrollView.useDelegate(
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              },
            ),
            onSelectedItemChanged: (index) {
              setState(() {
                _selectedWeight = index / 2.0;
              });
              HapticFeedback.selectionClick();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRepsPicker(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.repeat,
              size: 16,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              'Reps',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
            ),
          ),
          child: ListWheelScrollView.useDelegate(
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              },
            ),
            onSelectedItemChanged: (index) {
              setState(() {
                _selectedReps = index + 1;
              });
              HapticFeedback.selectionClick();
            },
          ),
        ),
      ],
    );
  }

  void _save() {
    final updatedSet = widget.exerciseSet.copyWith(
      weight: _selectedWeight > 0 ? _selectedWeight : null,
      reps: _selectedReps > 0 ? _selectedReps : null,
    );

    // Haptic feedback
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
    
    // Copia peso dal set precedente
    if (widget.previousSet!.weight != null) {
      final previousWeight = widget.previousSet!.weight!;
      final weightIndex = (previousWeight * 2).round();
      _weightController.animateToItem(
        weightIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() {
        _selectedWeight = previousWeight;
      });
    }
    
    // Copia reps dal set precedente
    if (widget.previousSet!.reps != null) {
      final previousReps = widget.previousSet!.reps!;
      final repsIndex = (previousReps - 1).clamp(0, 49);
      _repsController.animateToItem(
        repsIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() {
        _selectedReps = previousReps;
      });
    }
    
    // Feedback tattile e visivo
    HapticFeedback.lightImpact();
    
    // Mostra conferma
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copiato: ${widget.previousSet!.weight?.toString() ?? "--"}kg × ${widget.previousSet!.reps?.toString() ?? "--"}',
        ),
        duration: const Duration(milliseconds: 800),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

// Extension for easy overlay showing
extension QuickEditOverlayExtension on BuildContext {
  Future<void> showQuickEditOverlay({
    required ExerciseSet exerciseSet,
    required Function(ExerciseSet) onSave,
    required Offset position,
    ExerciseSet? previousSet,
  }) {
    return showDialog(
      context: this,
      barrierColor: Colors.transparent,
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
          QuickEditSetOverlay(
            exerciseSet: exerciseSet,
            onSave: onSave,
            onCancel: () => Navigator.of(context).pop(),
            position: position,
            previousSet: previousSet,
          ),
        ],
      ),
    );
  }
}
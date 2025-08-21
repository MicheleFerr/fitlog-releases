import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

class SimpleEnhancedQuickEdit extends ConsumerStatefulWidget {
  final ExerciseSet exerciseSet;
  final Function(ExerciseSet) onSave;
  final VoidCallback onCancel;
  final Offset position;
  final ExerciseSet? previousSet;

  const SimpleEnhancedQuickEdit({
    super.key,
    required this.exerciseSet,
    required this.onSave,
    required this.onCancel,
    required this.position,
    this.previousSet,
  });

  @override
  ConsumerState<SimpleEnhancedQuickEdit> createState() => _SimpleEnhancedQuickEditState();
}

class _SimpleEnhancedQuickEditState extends ConsumerState<SimpleEnhancedQuickEdit> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  
  @override
  void initState() {
    super.initState();
    
    _weightController = TextEditingController(
      text: widget.exerciseSet.weight?.toString() ?? '0'
    );
    _repsController = TextEditingController(
      text: widget.exerciseSet.reps?.toString() ?? '10'
    );
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = ref.watch(appConfigProvider);
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate position to keep overlay on screen
    double left = widget.position.dx - 160;
    double top = widget.position.dy - 100;
    
    // Keep within screen bounds
    left = left.clamp(16.0, screenSize.width - 336.0);
    top = top.clamp(50.0, screenSize.height - 400.0);
    
    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              color: theme.colorScheme.surface,
              child: Container(
                width: 320,
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
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Quick Edit Set ${widget.exerciseSet.setNumber}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (widget.previousSet != null)
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            onPressed: _copyFromPrevious,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Weight input with number pad
                    Row(
                      children: [
                        // Weight display and input
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.fitness_center, size: 16, 
                                       color: theme.colorScheme.primary),
                                  const SizedBox(width: 4),
                                  Text('Weight', 
                                       style: theme.textTheme.labelMedium),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  '${_weightController.text} ${config.measurementUnit}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Reps display and input
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.repeat, size: 16,
                                       color: theme.colorScheme.secondary),
                                  const SizedBox(width: 4),
                                  Text('Reps',
                                       style: theme.textTheme.labelMedium),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.colorScheme.secondary.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  _repsController.text,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Number pad
                    SizedBox(
                      height: 200,
                      child: GridView.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          ...[7, 8, 9, 4, 5, 6, 1, 2, 3].map((num) => 
                            _buildNumberButton(num.toString())
                          ),
                          _buildNumberButton('.'),
                          _buildNumberButton('0'),
                          _buildNumberButton('⌫', isDelete: true),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Quick adjust buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () => _adjustWeight(-2.5),
                          child: const Text('-2.5'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => _adjustWeight(2.5),
                          child: const Text('+2.5'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => _adjustWeight(5),
                          child: const Text('+5'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: _switchToReps,
                          child: const Text('Reps'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
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
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: _save,
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildNumberButton(String text, {bool isDelete = false}) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        
        if (isDelete) {
          if (_weightController.text.isNotEmpty && _weightController.text != '0') {
            _weightController.text = _weightController.text.substring(
              0, _weightController.text.length - 1
            );
            if (_weightController.text.isEmpty) {
              _weightController.text = '0';
            }
          }
        } else {
          if (_weightController.text == '0') {
            _weightController.text = text;
          } else {
            _weightController.text += text;
          }
        }
        setState(() {});
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: isDelete 
              ? theme.colorScheme.errorContainer.withOpacity(0.3)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: isDelete
              ? Icon(Icons.backspace, size: 18, color: theme.colorScheme.error)
              : Text(
                  text,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
  
  void _adjustWeight(double increment) {
    final current = double.tryParse(_weightController.text) ?? 0;
    final newWeight = (current + increment).clamp(0, 500);
    _weightController.text = newWeight.toString();
    setState(() {});
    HapticFeedback.selectionClick();
  }
  
  void _switchToReps() {
    // Simple toggle to edit reps with number pad
    // TODO: Implement reps editing mode
    HapticFeedback.selectionClick();
  }
  
  void _copyFromPrevious() {
    if (widget.previousSet == null) return;
    
    _weightController.text = widget.previousSet!.weight?.toString() ?? '0';
    _repsController.text = widget.previousSet!.reps?.toString() ?? '10';
    setState(() {});
    
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied from Set ${widget.previousSet!.setNumber}'),
        duration: const Duration(milliseconds: 800),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
  
  void _save() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final reps = int.tryParse(_repsController.text) ?? 0;
    
    final updatedSet = widget.exerciseSet.copyWith(
      weight: weight > 0 ? weight : null,
      reps: reps > 0 ? reps : null,
    );
    
    HapticFeedback.mediumImpact();
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
}

// Extension for easy overlay showing
extension SimpleEnhancedQuickEditExtension on BuildContext {
  Future<void> showSimpleEnhancedQuickEdit({
    required ExerciseSet exerciseSet,
    required Function(ExerciseSet) onSave,
    required Offset position,
    ExerciseSet? previousSet,
  }) {
    return showDialog(
      context: this,
      barrierColor: Colors.black26,
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
          SimpleEnhancedQuickEdit(
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
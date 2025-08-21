import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

class WarmupSuggestionCard extends ConsumerStatefulWidget {
  final double workingWeight;
  final int targetReps;
  final Function(List<ExerciseSet>) onAddWarmupSets;
  final VoidCallback? onDismiss;
  final String exerciseName;
  
  const WarmupSuggestionCard({
    super.key,
    required this.workingWeight,
    required this.targetReps,
    required this.onAddWarmupSets,
    this.onDismiss,
    required this.exerciseName,
  });

  @override
  ConsumerState<WarmupSuggestionCard> createState() => _WarmupSuggestionCardState();
}

class _WarmupSuggestionCardState extends ConsumerState<WarmupSuggestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isExpanded = false;
  List<WarmupSet> _warmupSets = [];
  
  // Warmup calculation parameters
  static const double barbellWeight = 20.0;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0),
    ));
    
    _calculateWarmupSets();
    
    // Auto-show if it's a heavy compound movement
    if (widget.workingWeight >= 60 && _shouldAutoShow()) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _toggleExpanded();
        }
      });
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  bool _shouldAutoShow() {
    // Smart logic to determine if warmup should auto-show
    final exerciseLower = widget.exerciseName.toLowerCase();
    final isCompound = exerciseLower.contains('squat') ||
        exerciseLower.contains('bench') ||
        exerciseLower.contains('deadlift') ||
        exerciseLower.contains('press') ||
        exerciseLower.contains('row');
    
    return isCompound && widget.workingWeight >= 60;
  }
  
  void _calculateWarmupSets() {
    _warmupSets.clear();
    
    final config = ref.read(appConfigProvider);
    final unit = config.measurementUnit;
    
    if (widget.workingWeight <= 0) return;
    
    // Intelligent warmup progression
    if (widget.workingWeight >= 60) {
      // Set 1: Empty bar (if using barbell)
      if (widget.workingWeight >= barbellWeight * 2) {
        _warmupSets.add(WarmupSet(
          weight: barbellWeight,
          reps: 10,
          percentage: 0,
        ));
      }
      
      // Set 2: 40% of working weight
      final weight40 = (widget.workingWeight * 0.4).roundToDouble();
      if (weight40 > barbellWeight) {
        _warmupSets.add(WarmupSet(
          weight: _roundToPlate(weight40),
          reps: 8,
          percentage: 40,
        ));
      }
      
      // Set 3: 60% of working weight
      final weight60 = (widget.workingWeight * 0.6).roundToDouble();
      _warmupSets.add(WarmupSet(
        weight: _roundToPlate(weight60),
        reps: 5,
        percentage: 60,
      ));
      
      // Set 4: 80% of working weight
      final weight80 = (widget.workingWeight * 0.8).roundToDouble();
      _warmupSets.add(WarmupSet(
        weight: _roundToPlate(weight80),
        reps: 3,
        percentage: 80,
      ));
      
      // Set 5: 90% for heavy lifts
      if (widget.workingWeight >= 100) {
        final weight90 = (widget.workingWeight * 0.9).roundToDouble();
        _warmupSets.add(WarmupSet(
          weight: _roundToPlate(weight90),
          reps: 1,
          percentage: 90,
        ));
      }
    } else if (widget.workingWeight >= 30) {
      // Lighter warmup for medium weights
      _warmupSets.add(WarmupSet(
        weight: _roundToPlate(widget.workingWeight * 0.5),
        reps: 10,
        percentage: 50,
      ));
      
      _warmupSets.add(WarmupSet(
        weight: _roundToPlate(widget.workingWeight * 0.75),
        reps: 5,
        percentage: 75,
      ));
    }
  }
  
  double _roundToPlate(double weight) {
    // Round to nearest 2.5kg increment
    return (weight / 2.5).round() * 2.5;
  }
  
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    
    HapticFeedback.lightImpact();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = ref.watch(appConfigProvider);
    
    if (_warmupSets.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Collapsed indicator
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riscaldamento consigliato',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          '${_warmupSets.length} sets progressivi',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isExpanded)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Tap to view',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Progressione Riscaldamento',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _toggleExpanded();
                            widget.onDismiss?.call();
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Warmup sets list
                    ..._warmupSets.asMap().entries.map((entry) {
                      final index = entry.key;
                      final warmupSet = entry.value;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _getSetColor(warmupSet.percentage).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getSetColor(warmupSet.percentage),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    warmupSet.weight == barbellWeight 
                                        ? 'Bilanciere vuoto'
                                        : '${warmupSet.weight} ${config.measurementUnit}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (warmupSet.percentage > 0)
                                    Text(
                                      '${warmupSet.percentage}% del carico',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '× ${warmupSet.reps}',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    
                    const SizedBox(height: 16),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _customizeWarmup,
                            icon: const Icon(Icons.tune, size: 16),
                            label: const Text('Personalizza'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: _addAllWarmupSets,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Aggiungi tutti'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getSetColor(int percentage) {
    if (percentage <= 40) return Colors.green;
    if (percentage <= 60) return Colors.blue;
    if (percentage <= 80) return Colors.orange;
    return Colors.red;
  }
  
  void _addAllWarmupSets() {
    final sets = _warmupSets.map((warmup) {
      return ExerciseSet(
        setNumber: 0, // Will be assigned by parent
        reps: warmup.reps,
        weight: warmup.weight,
        isCompleted: false,
        isWarmup: true,
      );
    }).toList();
    
    widget.onAddWarmupSets(sets);
    _toggleExpanded();
    
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Aggiunti ${sets.length} set di riscaldamento'),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
  
  void _customizeWarmup() {
    // TODO: Show customization dialog
    HapticFeedback.selectionClick();
  }
}

class WarmupSet {
  final double weight;
  final int reps;
  final int percentage;
  
  const WarmupSet({
    required this.weight,
    required this.reps,
    required this.percentage,
  });
}
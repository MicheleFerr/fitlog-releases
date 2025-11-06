import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

class WarmupSuggestionCard extends ConsumerStatefulWidget {
  
  const WarmupSuggestionCard({
    super.key,
    required this.workingWeight,
    required this.targetReps,
    required this.onAddWarmupSets,
    this.onDismiss,
    required this.exerciseName,
  });
  final double workingWeight;
  final int targetReps;
  final Function(List<ExerciseSet>) onAddWarmupSets;
  final VoidCallback? onDismiss;
  final String exerciseName;

  @override
  ConsumerState<WarmupSuggestionCard> createState() => _WarmupSuggestionCardState();
}

class _WarmupSuggestionCardState extends ConsumerState<WarmupSuggestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isExpanded = false;
  final List<WarmupSet> _warmupSets = [];
  
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
        _warmupSets.add(const WarmupSet(
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
    final l10n = AppLocalizations.of(context);

    if (_warmupSets.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Simplified collapsed indicator
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.workout,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.recommendedWarmup,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_warmupSets.length} sets · ${widget.workingWeight}kg target',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded ? AppIcons.expandLess : AppIcons.expandMore,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Simplified expanded content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Simple header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.warmupIntelligentProgression,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _toggleExpanded();
                            widget.onDismiss?.call();
                          },
                          icon: Icon(
                            AppIcons.close,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Simple warmup sets list
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: _warmupSets.asMap().entries.map((entry) {
                        final index = entry.key;
                        final warmupSet = entry.value;
                        final isEmptyBar = warmupSet.weight == barbellWeight;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isEmptyBar
                                    ? '${l10n.emptyBarbell} × ${warmupSet.reps}'
                                    : '${warmupSet.weight}kg × ${warmupSet.reps}',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Simple action button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: FilledButton.icon(
                      onPressed: _addAllWarmupSets,
                      icon: const Icon(AppIcons.add, size: 16),
                      label: Text(l10n.addAll),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  


  void _addAllWarmupSets() {
    final l10n = AppLocalizations.of(context);
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
        content: Text(l10n.warmupSetsAdded('${sets.length}')),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
  
}

class WarmupSet {

  const WarmupSet({
    required this.weight,
    required this.reps,
    required this.percentage,
  });
  final double weight;
  final int reps;
  final int percentage;
}


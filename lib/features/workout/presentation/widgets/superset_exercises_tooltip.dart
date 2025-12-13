import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Tooltip overlay showing exercises in a superset with detailed info
class SupersetExercisesTooltip extends ConsumerStatefulWidget {
  
  const SupersetExercisesTooltip({
    super.key,
    required this.supersetExercise,
    this.onClose,
    this.onExerciseInfo,
    this.onWarmupPrevention,
    this.onTechniqueTips,
  });
  final SupersetExercise supersetExercise;
  final VoidCallback? onClose;
  final Function(Exercise)? onExerciseInfo;
  final Function(Exercise)? onWarmupPrevention;
  final Function(Exercise)? onTechniqueTips;

  static Future<void> show({
    required BuildContext context,
    required SupersetExercise supersetExercise,
    Function(Exercise)? onExerciseInfo,
    Function(Exercise)? onWarmupPrevention,
    Function(Exercise)? onTechniqueTips,
  }) {
    return showDialog(
      context: context,
      barrierColor: context.colors.onSurface26,
      builder: (context) => SupersetExercisesTooltip(
        supersetExercise: supersetExercise,
        onExerciseInfo: onExerciseInfo,
        onWarmupPrevention: onWarmupPrevention,
        onTechniqueTips: onTechniqueTips,
      ),
    );
  }

  @override
  ConsumerState<SupersetExercisesTooltip> createState() => _SupersetExercisesTooltipState();
}

class _SupersetExercisesTooltipState extends ConsumerState<SupersetExercisesTooltip>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    _animationController.dispose();
    super.dispose();
  }
  
  void _showExerciseMenu(BuildContext context, Exercise exercise, Offset tapPosition) {
    HapticFeedback.mediumImpact();
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx + 1,
        tapPosition.dy + 1,
      ),
      items: [
        // Header with exercise name
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14,
                ),
              ),
              Text(
                'Category: ${_getCategoryName(exercise.category)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Divider(),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'info',
          child: Row(
            children: [
              Icon(
                AppIcons.info,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Exercise Info'),
                    Text(
                      'Detailed exercise information',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'warmup',
          child: Row(
            children: [
              Icon(
                AppIcons.healing,
                size: 18,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Warmup & Prevention'),
                    Text(
                      'Injury prevention tips',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'technique',
          child: Row(
            children: [
              Icon(
                AppIcons.education,
                size: 18,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Technique Tips'),
                    Text(
                      'Form and execution guidance',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'info') {
        widget.onExerciseInfo?.call(exercise);
      } else if (value == 'warmup') {
        widget.onWarmupPrevention?.call(exercise);
      } else if (value == 'technique') {
        widget.onTechniqueTips?.call(exercise);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: GestureDetector(
                    onTap: () {}, // Prevent closing when tapping inside
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.85,
                        maxHeight: MediaQuery.of(context).size.height * 0.75,
                      ),
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.onSurface.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.secondary.withValues(alpha: 0.1),
                                  colorScheme.primary.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    AppIcons.link,
                                    color: colorScheme.secondary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Superset Exercises',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${widget.supersetExercise.exercises.length} exercises in this superset',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(AppIcons.close),
                                  style: IconButton.styleFrom(
                                    backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Instructions
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  AppIcons.info,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Long press on any exercise for warmup & injury prevention tips',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Exercises list
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(16),
                              itemCount: widget.supersetExercise.exercises.length,
                              itemBuilder: (context, index) {
                                final exercise = widget.supersetExercise.exercises[index];
                                return _buildExerciseCard(
                                  context,
                                  exercise,
                                  index,
                                  theme,
                                  colorScheme,
                                );
                              },
                            ),
                          ),
                          
                          // Footer with execution tips
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      AppIcons.tipsAndUpdates,
                                      size: 18,
                                      color: colorScheme.tertiary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Superset Execution Tips',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.tertiary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '• Perform exercises back-to-back with no rest\n'
                                  '• Rest only after completing all exercises\n'
                                  '• Focus on form over speed\n'
                                  '• Track RPE for each exercise separately',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildExerciseCard(
    BuildContext context,
    Exercise exercise,
    int index,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onLongPressStart: (details) {
        _showExerciseMenu(context, exercise, details.globalPosition);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: context.colors.onSurface.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise header
            Row(
              children: [
                // Exercise number
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Exercise name and category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(exercise.category).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getCategoryName(exercise.category),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _getCategoryColor(exercise.category),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Info button
                IconButton(
                  onPressed: () => widget.onExerciseInfo?.call(exercise),
                  icon: const Icon(AppIcons.info),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Exercise details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current set info if available
                  if (exercise.sets.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          AppIcons.workout,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Last set: ${exercise.sets.last.weight?.toStringAsFixed(1) ?? '-'} kg × ${exercise.sets.last.reps} reps',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Muscle groups (if available)
                  Row(
                    children: [
                      Icon(
                        AppIcons.accessible,
                        size: 16,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Primary: ${_getCategoryName(exercise.category)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Long press instruction
                  Row(
                    children: [
                      Icon(
                        AppIcons.touchApp,
                        size: 14,
                        color: colorScheme.tertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Long press for warmup & injury prevention',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.tertiary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getCategoryColor(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return context.colors.error;
      case ExerciseCategory.back:
        return context.colors.primary;
      case ExerciseCategory.shoulders:
        return context.colors.secondary;
      case ExerciseCategory.arms:
        return context.colors.tertiary;
      case ExerciseCategory.legs:
        return context.colors.success;
      case ExerciseCategory.abs:
        return context.colors.warning;
      case ExerciseCategory.cardio:
        return context.colors.error;
      case ExerciseCategory.other:
        return context.colors.surfaceContainerHighest;
    }
  }
  
  String _getCategoryName(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.chest:
        return 'Chest';
      case ExerciseCategory.back:
        return 'Back';
      case ExerciseCategory.shoulders:
        return 'Shoulders';
      case ExerciseCategory.arms:
        return 'Arms';
      case ExerciseCategory.legs:
        return 'Legs';
      case ExerciseCategory.abs:
        return 'Abs';
      case ExerciseCategory.cardio:
        return 'Cardio';
      case ExerciseCategory.other:
        return 'Other';
    }
  }
}

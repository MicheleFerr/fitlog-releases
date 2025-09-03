/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation
 * 🎯 Feature: workout
 * 🔧 Type: widget
 * 🌍 Localization: ✅ AppLocalizations used
 * 🎨 Theme: ✅ ColorScheme responsive
 * 📱 Platform: iOS/Android/Universal
 * 
 * Dependencies:
 * - Riverpod: StateProvider for minimize state
 * - Flutter: Material widgets
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/l10n/generated/app_localizations.dart';
import '../../domain/entities/exercise.dart';
import 'exercise_list_item.dart';

// Provider for managing minimize state of exercises
final exerciseMinimizeStateProvider = StateProvider.family<bool, String>((ref, exerciseId) => false);

class MinimizableExerciseCard extends ConsumerWidget {
  final Exercise exercise;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(ExerciseSet)? onSetUpdate;
  final Function(ExerciseSet)? onSetToggleComplete;
  final Function(Exercise)? onExerciseUpdate;
  final int index;

  const MinimizableExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
    required this.onDelete,
    required this.index,
    this.onSetUpdate,
    this.onSetToggleComplete,
    this.onExerciseUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    // Check if all sets are completed
    final isExerciseCompleted = exercise.sets.isNotEmpty && 
        exercise.sets.every((set) => set.isCompleted);
    
    // Get minimize state for this exercise
    final isMinimized = ref.watch(exerciseMinimizeStateProvider(exercise.id));
    
    // Auto-minimize if completed (optional feature)
    // Uncomment this if you want auto-minimize
    // if (isExerciseCompleted && !isMinimized) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     ref.read(exerciseMinimizeStateProvider(exercise.id).notifier).state = true;
    //   });
    // }

    if (isMinimized && isExerciseCompleted) {
      // Minimized view
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.tertiary.withOpacity(0.3),
            width: 1,
          ),
        ),
        color: theme.colorScheme.tertiary.withOpacity(0.05),
        child: InkWell(
          onTap: () {
            // Expand the card
            ref.read(exerciseMinimizeStateProvider(exercise.id).notifier).state = false;
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Exercise number
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Exercise name and summary
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: theme.colorScheme.tertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              exercise.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _buildCompletedSummary(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Expand icon
                IconButton(
                  icon: Icon(
                    Icons.expand_more,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    ref.read(exerciseMinimizeStateProvider(exercise.id).notifier).state = false;
                  },
                  tooltip: l10n.expand,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Full view with minimize button if completed
    return Stack(
      children: [
        // Original exercise list item
        ExerciseListItem(
          exercise: exercise,
          onTap: onTap,
          onDelete: onDelete,
          onSetUpdate: onSetUpdate,
          onSetToggleComplete: onSetToggleComplete,
          onExerciseUpdate: onExerciseUpdate,
        ),
        
        // Minimize button (only show if exercise is completed)
        if (isExerciseCompleted)
          Positioned(
            top: 8,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ref.read(exerciseMinimizeStateProvider(exercise.id).notifier).state = true;
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.tertiary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.minimize,
                        size: 16,
                        color: theme.colorScheme.tertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.minimize,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _buildCompletedSummary() {
    if (exercise.sets.isEmpty) return '';
    
    final completedSets = exercise.sets.where((s) => s.isCompleted).toList();
    if (completedSets.isEmpty) return '';
    
    // Group sets by weight/reps for summary
    final setGroups = <String, int>{};
    for (final set in completedSets) {
      final key = '${set.actualReps ?? set.reps} × ${set.weight}kg';
      setGroups[key] = (setGroups[key] ?? 0) + 1;
    }
    
    // Build summary string
    final summaryParts = setGroups.entries.map((entry) {
      return entry.value > 1 
        ? '${entry.value} × ${entry.key}' 
        : entry.key;
    }).toList();
    
    // Calculate total volume
    final totalVolume = completedSets.fold<double>(
      0, 
      (sum, set) => sum + (set.weight * (set.actualReps ?? set.reps))
    );
    
    return '${summaryParts.join(', ')} • ${totalVolume.toStringAsFixed(0)}kg total';
  }
}
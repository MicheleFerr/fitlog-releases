import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/l10n/generated/app_localizations.dart';

/// Compact exercise card for edit mode - shows minimal info
class CompactExerciseCard extends ConsumerWidget {
  final Exercise exercise;
  final int index;
  final VoidCallback onTap;
  final VoidCallback? onReorderStart;

  const CompactExerciseCard({
    super.key,
    required this.exercise,
    required this.index,
    required this.onTap,
    this.onReorderStart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Calculate summary text
    final summaryText = _buildSummaryText(exercise);
    
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Drag handle
                ReorderableDragStartListener(
                  index: index,
                  child: GestureDetector(
                    onTapDown: (_) {
                      HapticFeedback.selectionClick();
                      onReorderStart?.call();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Icon(
                        Icons.drag_handle,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Exercise number badge
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Exercise info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise name
                      Text(
                        exercise.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Summary (sets x reps @ weight)
                      if (summaryText.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          summaryText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Action buttons for reordering
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Insert above button
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showInsertMenu(context, index, true);
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.add_circle_outline,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    
                    // Insert below button
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showInsertMenu(context, index, false);
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.add_circle,
                          size: 18,
                          color: theme.colorScheme.primary,
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
    );
  }
  
  String _buildSummaryText(Exercise exercise) {
    if (exercise.sets.isEmpty) return '';
    
    // Group sets by weight/reps
    final setGroups = <String, int>{};
    for (final set in exercise.sets) {
      if (!set.isCompleted) continue;
      
      final key = '${set.reps ?? 0}@${set.weight ?? 0}kg';
      setGroups[key] = (setGroups[key] ?? 0) + 1;
    }
    
    if (setGroups.isEmpty) {
      // Show planned sets if no completed ones
      final plannedSets = exercise.sets.length;
      if (plannedSets > 0) {
        final firstSet = exercise.sets.first;
        return '$plannedSets × ${firstSet.reps ?? 0} reps @ ${firstSet.weight ?? 0}kg';
      }
      return '';
    }
    
    // Build summary string
    final summaryParts = setGroups.entries.map((entry) {
      final parts = entry.key.split('@');
      final reps = parts[0];
      final weight = parts[1];
      return entry.value > 1 
        ? '${entry.value}×$reps @ $weight' 
        : '$reps @ $weight';
    }).toList();
    
    return summaryParts.join(', ');
  }
  
  void _showInsertMenu(BuildContext context, int currentIndex, bool insertAbove) {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                insertAbove ? l10n.insertExerciseAbove : l10n.insertExerciseBellow,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(l10n.addNewExercise),
              onTap: () {
                Navigator.pop(context);
                // Show add exercise modal at specific position
                _showAddExerciseAtPosition(context, insertAbove ? currentIndex : currentIndex + 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(l10n.duplicateExercise),
              onTap: () {
                Navigator.pop(context);
                // Duplicate current exercise at position
                _duplicateExerciseAtPosition(context, currentIndex, insertAbove);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
  
  void _showAddExerciseAtPosition(BuildContext context, int position) {
    // This will be implemented to show add exercise modal
    // and insert at specific position
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add exercise at position ${position + 1}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _duplicateExerciseAtPosition(BuildContext context, int currentIndex, bool insertAbove) {
    // This will be implemented to duplicate exercise
    final position = insertAbove ? currentIndex : currentIndex + 1;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Duplicate exercise at position ${position + 1}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
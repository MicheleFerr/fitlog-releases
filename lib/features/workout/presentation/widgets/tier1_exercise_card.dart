import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise.dart';
import '../../../../shared/presentation/l10n/generated/app_localizations.dart';

/// 🎯 TIER-1 EXERCISE CARD - Multiple Design Mockups
/// Performance-optimized with modern, compact design

// ============= MOCKUP 1: Ultra Compact Two-Line =============
class Tier1ExerciseCardV1 extends ConsumerWidget {
  final Exercise exercise;
  final VoidCallback onTap;
  final int index;
  
  const Tier1ExerciseCardV1({
    super.key,
    required this.exercise,
    required this.onTap,
    required this.index,
  });
  
  String _getTypeAbbreviation() {
    switch (exercise.type) {
      case ExerciseType.single: return 'S';
      case ExerciseType.superset: return 'SS';
      case ExerciseType.dropset: return 'DS';
      case ExerciseType.restPause: return 'RS';
    }
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isDark 
          ? theme.colorScheme.surface.withValues(alpha: 0.8)
          : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: isDark ? 0 : 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== FIRST LINE: Name - Type - Rest =====
                Row(
                  children: [
                    // Exercise number badge (minimal)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Exercise Name
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getTypeAbbreviation(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Rest Time
                    if (exercise.restTime != null) ...[
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${exercise.restTime! ~/ 60}:${(exercise.restTime! % 60).toString().padLeft(2, '0')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // ===== SECOND LINE: Last Weight - Time Ago - TUT =====
                Row(
                  children: [
                    // Last weight & time ago
                    Icon(
                      Icons.fitness_center,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '85kg • Ieri',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // TUT with tooltip
                    Row(
                      children: [
                        Text(
                          'TUT: 3-1-1-0',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Tooltip(
                          message: 'Tempo Under Tension\nEcc-Basso-Conc-Alto',
                          child: Icon(
                            Icons.info_outline,
                            size: 12,
                            color: theme.colorScheme.primary.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Completed sets indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: exercise.isCompleted 
                          ? Colors.green.withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${exercise.sets.where((s) => s.isCompleted).length}/${exercise.sets.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: exercise.isCompleted 
                            ? Colors.green 
                            : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // ===== NOTES (if present) =====
                if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            exercise.notes!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============= MOCKUP 2: Material You Style =============
class Tier1ExerciseCardV2 extends ConsumerWidget {
  final Exercise exercise;
  final VoidCallback onTap;
  final int index;
  
  const Tier1ExerciseCardV2({
    super.key,
    required this.exercise,
    required this.onTap,
    required this.index,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Number in a pill shape
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    
                    // Exercise name with type
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              exercise.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildTypeChip(context),
                        ],
                      ),
                    ),
                    
                    // Rest indicator
                    if (exercise.restTime != null)
                      _buildRestChip(context),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Stats Row
                Row(
                  children: [
                    // Previous performance
                    _buildStatChip(
                      context,
                      icon: Icons.trending_up,
                      label: '85kg',
                      sublabel: 'Ieri',
                      color: Colors.blue,
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // TUT Info
                    _buildStatChip(
                      context,
                      icon: Icons.speed,
                      label: '3-1-1-0',
                      sublabel: 'TUT',
                      color: Colors.orange,
                    ),
                    
                    const Spacer(),
                    
                    // Progress indicator
                    _buildProgressIndicator(context),
                  ],
                ),
                
                // Notes section
                if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildNotesSection(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTypeChip(BuildContext context) {
    final theme = Theme.of(context);
    final colors = {
      ExerciseType.single: Colors.blue,
      ExerciseType.superset: Colors.orange,
      ExerciseType.dropset: Colors.red,
      ExerciseType.restPause: Colors.purple,
    };
    
    final labels = {
      ExerciseType.single: 'S',
      ExerciseType.superset: 'SS',
      ExerciseType.dropset: 'DS',
      ExerciseType.restPause: 'RS',
    };
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors[exercise.type]?.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colors[exercise.type]?.withValues(alpha: 0.5) ?? theme.colorScheme.outline,
          width: 0.5,
        ),
      ),
      child: Text(
        labels[exercise.type] ?? '',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: colors[exercise.type],
        ),
      ),
    );
  }
  
  Widget _buildRestChip(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = exercise.restTime! ~/ 60;
    final seconds = exercise.restTime! % 60;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 12,
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(width: 4),
          Text(
            '$minutes:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 9,
                  color: color.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final completed = exercise.sets.where((s) => s.isCompleted).length;
    final total = exercise.sets.length;
    final progress = total > 0 ? completed / total : 0.0;
    
    return Container(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              exercise.isCompleted ? Colors.green : theme.colorScheme.primary,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$completed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '/ $total',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotesSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.edit_note,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              exercise.notes!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ============= MOCKUP 3: Minimal iOS Style =============
class Tier1ExerciseCardV3 extends ConsumerWidget {
  final Exercise exercise;
  final VoidCallback onTap;
  final int index;
  
  const Tier1ExerciseCardV3({
    super.key,
    required this.exercise,
    required this.onTap,
    required this.index,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark 
            ? Colors.grey[900] 
            : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main info line
            Row(
              children: [
                // Index
                Text(
                  '${index + 1}.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                
                // Name
                Expanded(
                  child: Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Type & Rest inline
                Text(
                  _getTypeLabel(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _getTypeColor(),
                  ),
                ),
                
                if (exercise.restTime != null) ...[
                  Text(
                    ' • ',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${exercise.restTime! ~/ 60}m ${exercise.restTime! % 60}s',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 6),
            
            // Secondary info line
            Row(
              children: [
                // Last performance
                Icon(
                  Icons.show_chart,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '85kg Yesterday',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                
                Text(
                  ' • ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
                
                // TUT
                Text(
                  'TUT: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '3-1-1-0',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                
                const Spacer(),
                
                // Sets done
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getProgressColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${exercise.sets.where((s) => s.isCompleted).length}/${exercise.sets.length} sets',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getProgressColor(),
                    ),
                  ),
                ),
              ],
            ),
            
            // Notes (editable appearance)
            if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark 
                    ? Colors.grey[850] 
                    : Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark 
                      ? Colors.grey[800]! 
                      : Colors.grey[200]!,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  exercise.notes!,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark 
                      ? Colors.grey[400] 
                      : Colors.grey[700],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  String _getTypeLabel() {
    switch (exercise.type) {
      case ExerciseType.single: return 'S';
      case ExerciseType.superset: return 'SS';
      case ExerciseType.dropset: return 'DS';
      case ExerciseType.restPause: return 'RS';
    }
  }
  
  Color _getTypeColor() {
    switch (exercise.type) {
      case ExerciseType.single: return Colors.blue;
      case ExerciseType.superset: return Colors.orange;
      case ExerciseType.dropset: return Colors.red;
      case ExerciseType.restPause: return Colors.purple;
    }
  }
  
  Color _getProgressColor() {
    if (exercise.isCompleted) return Colors.green;
    if (exercise.sets.any((s) => s.isCompleted)) return Colors.orange;
    return Colors.grey;
  }
}

// Example mock data for preview
class ExerciseSet {
  final bool isCompleted;
  final int? reps;
  final double? weight;
  
  const ExerciseSet({
    this.isCompleted = false,
    this.reps,
    this.weight,
  });
}
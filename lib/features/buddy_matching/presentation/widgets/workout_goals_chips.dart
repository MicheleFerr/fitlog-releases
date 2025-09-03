/**
 * 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
 * 
 * 📁 Layer: presentation
 * 🎯 Feature: buddy_matching
 * 🔧 Type: widget
 * 🌍 Localization: ✅ AppLocalizations used
 * 🎨 Theme: ✅ ColorScheme responsive
 * 📱 Platform: Universal
 * 
 * Dependencies:
 * - Riverpod: None
 * - Firebase: None
 * - Hive: None
 */

import 'package:flutter/material.dart';
import '../../domain/entities/buddy_preferences.dart';

class WorkoutGoalsChips extends StatelessWidget {
  final List<WorkoutGoal> goals;
  final bool compact;
  final int? maxDisplay;

  const WorkoutGoalsChips({
    super.key,
    required this.goals,
    this.compact = false,
    this.maxDisplay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayGoals = maxDisplay != null 
        ? goals.take(maxDisplay!).toList() 
        : goals;
    final remainingCount = maxDisplay != null && goals.length > maxDisplay! 
        ? goals.length - maxDisplay! 
        : 0;

    return Wrap(
      spacing: compact ? 6 : 8,
      runSpacing: compact ? 4 : 6,
      children: [
        ...displayGoals.map((goal) => _buildGoalChip(context, theme, goal)),
        if (remainingCount > 0)
          _buildMoreChip(context, theme, remainingCount),
      ],
    );
  }

  Widget _buildGoalChip(BuildContext context, ThemeData theme, WorkoutGoal goal) {
    final color = _getGoalColor(goal);
    final icon = _getGoalIcon(goal);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: compact ? 12 : 14,
            color: color,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            goal.displayName,
            style: (compact ? theme.textTheme.labelSmall : theme.textTheme.labelMedium)?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreChip(BuildContext context, ThemeData theme, int count) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        '+$count',
        style: (compact ? theme.textTheme.labelSmall : theme.textTheme.labelMedium)?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getGoalColor(WorkoutGoal goal) {
    switch (goal) {
      case WorkoutGoal.weightLoss:
        return Colors.red;
      case WorkoutGoal.muscleGain:
        return Colors.blue;
      case WorkoutGoal.strength:
        return Colors.deepOrange;
      case WorkoutGoal.endurance:
        return Colors.green;
      case WorkoutGoal.flexibility:
        return Colors.purple;
      case WorkoutGoal.general:
        return Colors.grey;
    }
  }

  IconData _getGoalIcon(WorkoutGoal goal) {
    switch (goal) {
      case WorkoutGoal.weightLoss:
        return Icons.trending_down;
      case WorkoutGoal.muscleGain:
        return Icons.fitness_center;
      case WorkoutGoal.strength:
        return Icons.sports_gymnastics;
      case WorkoutGoal.endurance:
        return Icons.directions_run;
      case WorkoutGoal.flexibility:
        return Icons.self_improvement;
      case WorkoutGoal.general:
        return Icons.sports;
    }
  }
}
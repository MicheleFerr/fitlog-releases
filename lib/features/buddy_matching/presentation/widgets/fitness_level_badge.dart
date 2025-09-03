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

class FitnessLevelBadge extends StatelessWidget {
  final FitnessLevel level;
  final bool compact;
  final bool showIcon;

  const FitnessLevelBadge({
    super.key,
    required this.level,
    this.compact = false,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getLevelColor(level);
    final icon = _getLevelIcon(level);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
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
          if (showIcon) ...[
            Icon(
              icon,
              size: compact ? 14 : 16,
              color: color,
            ),
            SizedBox(width: compact ? 4 : 6),
          ],
          Text(
            level.displayName,
            style: (compact ? theme.textTheme.labelSmall : theme.textTheme.labelMedium)?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(FitnessLevel level) {
    switch (level) {
      case FitnessLevel.beginner:
        return Colors.green;
      case FitnessLevel.intermediate:
        return Colors.orange;
      case FitnessLevel.advanced:
        return Colors.red;
      case FitnessLevel.expert:
        return Colors.purple;
    }
  }

  IconData _getLevelIcon(FitnessLevel level) {
    switch (level) {
      case FitnessLevel.beginner:
        return Icons.fitness_center;
      case FitnessLevel.intermediate:
        return Icons.trending_up;
      case FitnessLevel.advanced:
        return Icons.local_fire_department;
      case FitnessLevel.expert:
        return Icons.emoji_events;
    }
  }
}
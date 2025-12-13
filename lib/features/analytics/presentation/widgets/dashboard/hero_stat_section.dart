/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/widgets/dashboard
/// 🎯 Feature: analytics
/// 🔧 Type: widget
///
/// Hero stat section that prominently displays workout count with delta comparison.
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/semantic_icon.dart';

/// Hero stat section showing weekly workout count with delta comparison
///
/// Displays:
/// - Large workout count number
/// - Workout label
/// - Delta indicator with icon and comparison text
/// - Optional progress bar toward weekly goal
///
/// Example:
/// ```dart
/// HeroStatSection(
///   workoutCount: 4,
///   previousWeekCount: 2,
///   weeklyGoal: 5,
///   onTap: () => navigateToWorkouts(),
/// )
/// ```
class HeroStatSection extends StatelessWidget {
  const HeroStatSection({
    required this.workoutCount,
    required this.previousWeekCount,
    this.weeklyGoal,
    this.onTap,
    super.key,
  });

  /// Current week workout count
  final int workoutCount;

  /// Previous week workout count for comparison
  final int previousWeekCount;

  /// Optional weekly goal for progress bar
  final int? weeklyGoal;

  /// Optional tap callback
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final delta = workoutCount - previousWeekCount;
    final hasGoal = weeklyGoal != null && weeklyGoal! > 0;
    final progress = hasGoal ? (workoutCount / weeklyGoal!).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.primary,
              context.colors.primary.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large workout count
            Text(
              '$workoutCount',
              style: context.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onPrimary,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),

            // Workout label
            Text(
              workoutCount == 1 ? context.l10n.workout : context.l10n.workouts,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onPrimary.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Delta indicator
            _buildDeltaIndicator(context, delta),

            // Progress bar (if goal is set)
            if (hasGoal) ...[
              const SizedBox(height: 16),
              _buildProgressBar(context, progress),
              const SizedBox(height: 8),
              Text(
                context.l10n.workoutsWeekGoal(workoutCount, weeklyGoal!),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeltaIndicator(BuildContext context, int delta) {
    final IconData icon;
    final Color color;
    final String deltaText;
    final String semanticLabel;

    if (delta > 0) {
      icon = AppIcons.trendingUp;
      color = context.colors.success;
      deltaText = '+$delta';
      semanticLabel = 'Increased by $delta workouts';
    } else if (delta < 0) {
      icon = AppIcons.trendingDown;
      color = context.colors.error;
      deltaText = '$delta';
      semanticLabel = 'Decreased by ${delta.abs()} workouts';
    } else {
      icon = AppIcons.remove;
      color = context.colors.onPrimary.withValues(alpha: 0.6);
      deltaText = '0';
      semanticLabel = 'No change in workouts';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SemanticIcon(
            icon: icon,
            color: color,
            size: 18,
            semanticLabel: semanticLabel,
          ),
          const SizedBox(width: 6),
          Text(
            deltaText,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.vsLastWeek,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8,
        backgroundColor: context.colors.onPrimary.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation<Color>(
          context.colors.onPrimary.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

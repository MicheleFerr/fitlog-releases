/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/profile/presentation/widgets
/// Feature: Profile Hub - Modern Workout Card
/// Type: Widget
///
/// Apple Fitness+ style workout card with exercise preview chips,
/// relative dates, and intensity indicators.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:intl/intl.dart';

/// Modern workout card for Profile Hub
///
/// Features:
/// - Exercise preview chips (max 3)
/// - Relative date display (Today, Yesterday, X days ago)
/// - Intensity badge
/// - Tap to navigate to workout detail
class ModernWorkoutCard extends StatefulWidget {
  const ModernWorkoutCard({
    required this.workout,
    required this.onTap,
    this.animationDelay = Duration.zero,
    super.key,
  });

  final WorkoutHistoryDetail workout;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  State<ModernWorkoutCard> createState() => _ModernWorkoutCardState();
}

class _ModernWorkoutCardState extends State<ModernWorkoutCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start animation after delay (for stagger effect)
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildCard(context),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final workout = widget.workout;
    final emoji = _getWorkoutEmoji(workout.name);
    final intensity = _getIntensityBadge(workout);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          // ✨ Material 3 2025: Elevated surface with defined border
          color: context.colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
          // ✨ Material 3 2025: Subtle shadow for depth
          boxShadow: [
            BoxShadow(
              color: context.colors.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Emoji + Name + Duration
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Workout emoji
                  Text(emoji, style: context.textTheme.titleLarge),
                  const SizedBox(width: 12),

                  // Name and date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_getTimeOfDayEmoji(workout.completedAt)} ${_getRelativeDate(context, workout.completedAt)}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Duration
                  Text(
                    context.l10n.minWorkout(workout.duration.inMinutes),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Exercise chips row
              _ExerciseChipsRow(exercises: workout.exercises),
              const SizedBox(height: 12),

              // Progress bar + intensity badge
              Row(
                children: [
                  Expanded(
                    child: _IntensityBar(
                      intensity: _calculateIntensity(workout),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(intensity, style: context.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getWorkoutEmoji(String workoutName) {
    final nameLower = workoutName.toLowerCase();

    if (nameLower.contains('push') ||
        nameLower.contains('chest') ||
        nameLower.contains('petto')) {
      return '🏋️';
    } else if (nameLower.contains('pull') ||
        nameLower.contains('back') ||
        nameLower.contains('schiena')) {
      return '🔙';
    } else if (nameLower.contains('leg') || nameLower.contains('gamb')) {
      return '🦵';
    } else if (nameLower.contains('arm') || nameLower.contains('bracc')) {
      return '💪';
    } else if (nameLower.contains('shoulder') || nameLower.contains('spall')) {
      return '🤷';
    } else if (nameLower.contains('core') ||
        nameLower.contains('abs') ||
        nameLower.contains('addom')) {
      return '🎯';
    } else if (nameLower.contains('full') || nameLower.contains('total')) {
      return '⚡';
    } else if (nameLower.contains('cardio')) {
      return '🏃';
    }

    return '🏋️'; // Default
  }

  String _getRelativeDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final workoutDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(workoutDay).inDays;

    final timeFormat = DateFormat.Hm(context.l10n.localeName);
    final timeString = timeFormat.format(date);

    if (difference == 0) {
      return context.l10n.todayAt(timeString);
    } else if (difference == 1) {
      return context.l10n.yesterdayAt(timeString);
    } else {
      return context.l10n.daysAgo(difference);
    }
  }

  /// Returns emoji based on time of day
  /// 🌅 Morning (5-11), ☀️ Afternoon (12-16), 🌆 Evening (17-20), 🌙 Night (21-4)
  String _getTimeOfDayEmoji(DateTime date) {
    final hour = date.hour;
    if (hour >= 5 && hour < 12) {
      return '🌅'; // Morning
    } else if (hour >= 12 && hour < 17) {
      return '☀️'; // Afternoon
    } else if (hour >= 17 && hour < 21) {
      return '🌆'; // Evening
    } else {
      return '🌙'; // Late night (21-4)
    }
  }

  String _getIntensityBadge(WorkoutHistoryDetail workout) {
    // Calculate intensity based on volume and duration
    final intensity = _calculateIntensity(workout);
    if (intensity > 0.8) return '🔥';
    if (intensity > 0.6) return '⚡';

    return '💪';
  }

  double _calculateIntensity(WorkoutHistoryDetail workout) {
    // Simple intensity calculation based on sets per minute
    final totalSets = workout.exercises.fold<int>(
      0,
      (sum, e) => sum + e.sets.length,
    );

    final durationMinutes = workout.duration.inMinutes;
    if (durationMinutes == 0) return 0.5;

    // Assume 1 set per 2 minutes is average (0.5 intensity)
    // 1 set per minute is high (1.0 intensity)
    final setsPerMinute = totalSets / durationMinutes;
    return (setsPerMinute * 2).clamp(0.0, 1.0);
  }
}

/// Row of exercise preview chips
class _ExerciseChipsRow extends StatelessWidget {
  const _ExerciseChipsRow({required this.exercises});

  final List<ExerciseHistoryDetail> exercises;

  @override
  Widget build(BuildContext context) {
    final visibleExercises = exercises.take(3).toList();
    final remainingCount = exercises.length - 3;

    return Row(
      children: [
        ...visibleExercises.map((exercise) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _ExerciseChip(name: exercise.name),
          );
        }),
        if (remainingCount > 0)
          Text(
            context.l10n.andNMore(remainingCount),
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

/// Small chip showing exercise name
class _ExerciseChip extends StatelessWidget {
  const _ExerciseChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    // Abbreviate name to max 8 characters
    final displayName = name.length > 8 ? '${name.substring(0, 7)}…' : name;

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          displayName,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// Horizontal intensity bar
class _IntensityBar extends StatelessWidget {
  const _IntensityBar({required this.intensity});

  final double intensity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: intensity,
        minHeight: 4,
        backgroundColor: context.colors.surfaceContainerLow,
        valueColor: AlwaysStoppedAnimation<Color>(
          _getIntensityColor(context, intensity),
        ),
      ),
    );
  }

  Color _getIntensityColor(BuildContext context, double intensity) {
    if (intensity > 0.8) {
      return context.colors.error; // High intensity - red/orange
    } else if (intensity > 0.5) {
      return context.colors.primary; // Medium intensity - primary
    }
    return context.colors.tertiary; // Low intensity - tertiary
  }
}

/// List of modern workout cards with staggered animation
class ModernWorkoutCardsList extends StatelessWidget {
  const ModernWorkoutCardsList({
    required this.workouts,
    required this.onWorkoutTap,
    this.maxItems = 3,
    super.key,
  });

  final List<WorkoutHistoryDetail> workouts;
  final void Function(WorkoutHistoryDetail) onWorkoutTap;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final displayWorkouts = workouts.take(maxItems).toList();

    return Column(
      children: [
        for (int i = 0; i < displayWorkouts.length; i++)
          ModernWorkoutCard(
            workout: displayWorkouts[i],
            onTap: () => onWorkoutTap(displayWorkouts[i]),
            animationDelay: Duration(milliseconds: 100 * i),
          ),
      ],
    );
  }
}

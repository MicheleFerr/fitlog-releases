import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Card widget for sharing workout progress as an image.
///
/// This widget is designed to be rendered off-screen and captured
/// as an image using the screenshot package.
///
/// Features:
/// - Header with workout name, user name, duration, volume
/// - Exercise list with completed sets (weight, reps, RPE)
/// - Pending exercises shown in compact form
/// - FitLog Pro branding footer
class WorkoutShareCard extends StatelessWidget {
  const WorkoutShareCard({
    super.key,
    required this.workout,
    required this.userName,
    required this.elapsedDuration,
  });

  final Workout workout;
  final String userName;
  final Duration elapsedDuration;

  @override
  Widget build(BuildContext context) {
    // Use fixed dark theme for consistent sharing appearance
    const backgroundColor = Color(0xFF1A1A2E);
    const surfaceColor = Color(0xFF252542);
    const primaryColor = Color(0xFF6C63FF);
    const successColor = Color(0xFF4CAF50);
    const textColor = Colors.white;
    const subtextColor = Colors.white70;
    const mutedColor = Colors.white38;

    return Container(
      width: 400,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _ShareHeader(
            workoutName: workout.name,
            userName: userName,
            duration: elapsedDuration,
            totalVolume: _calculateTotalVolume(),
            primaryColor: primaryColor,
            textColor: textColor,
            subtextColor: subtextColor,
          ),

          const SizedBox(height: 20),

          // Exercise list
          ...workout.exercises.map(
            (exercise) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ShareExerciseItem(
                exercise: exercise,
                surfaceColor: surfaceColor,
                successColor: successColor,
                textColor: textColor,
                subtextColor: subtextColor,
                mutedColor: mutedColor,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Footer with branding
          const _ShareFooter(
            primaryColor: primaryColor,
            mutedColor: mutedColor,
          ),
        ],
      ),
    );
  }

  double _calculateTotalVolume() {
    double totalVolume = 0.0;
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        if (set.isCompleted && set.weight != null && set.reps != null) {
          totalVolume += set.weight! * set.reps!;
        }
      }
    }
    return totalVolume;
  }
}

/// Header section of the share card
class _ShareHeader extends StatelessWidget {
  const _ShareHeader({
    required this.workoutName,
    required this.userName,
    required this.duration,
    required this.totalVolume,
    required this.primaryColor,
    required this.textColor,
    required this.subtextColor,
  });

  final String workoutName;
  final String userName;
  final Duration duration;
  final double totalVolume;
  final Color primaryColor;
  final Color textColor;
  final Color subtextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.3),
            primaryColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout name with icon
          Row(
            children: [
              Icon(
                AppIcons.workout,
                color: primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  workoutName.toUpperCase(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Stats line: user · duration · volume
          Text(
            '$userName · ${_formatDuration(duration)} · ${_formatVolume(totalVolume)}',
            style: TextStyle(
              color: subtextColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '$minutes min';
    }
  }

  String _formatVolume(double volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}t';
    }
    return '${volume.toInt()} kg';
  }
}

/// Exercise item in the share card
class _ShareExerciseItem extends StatelessWidget {
  const _ShareExerciseItem({
    required this.exercise,
    required this.surfaceColor,
    required this.successColor,
    required this.textColor,
    required this.subtextColor,
    required this.mutedColor,
  });

  final Exercise exercise;
  final Color surfaceColor;
  final Color successColor;
  final Color textColor;
  final Color subtextColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final isCompleted = exercise.sets.every((s) => s.isCompleted);
    final hasCompletedSets = exercise.sets.any((s) => s.isCompleted);
    final completedSets = exercise.sets.where((s) => s.isCompleted).toList();
    final pendingSetsCount = exercise.sets.where((s) => !s.isCompleted).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCompleted
              ? successColor.withValues(alpha: 0.5)
              : mutedColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise name with status icon
          Row(
            children: [
              Icon(
                isCompleted
                    ? AppIcons.checkCircle
                    : hasCompletedSets
                        ? AppIcons.timerOutlined
                        : AppIcons.radioButtonUnchecked,
                color: isCompleted
                    ? successColor
                    : hasCompletedSets
                        ? subtextColor
                        : mutedColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  exercise.name,
                  style: TextStyle(
                    color: isCompleted || hasCompletedSets
                        ? textColor
                        : mutedColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Show completed sets with details
          if (completedSets.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...completedSets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              return Padding(
                padding: const EdgeInsets.only(left: 26, top: 2),
                child: Text(
                  _formatSet(index + 1, set),
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
              );
            }),
          ],

          // Show pending sets count if any
          if (pendingSetsCount > 0) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Text(
                '$pendingSetsCount set rimanenti',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatSet(int setNumber, ExerciseSet set) {
    final weight = set.weight != null ? '${set.weight}kg' : '-';
    final repsStr = set.actualReps?.toString() ?? set.repsDisplay;
    final rpeStr = set.rpe != null ? '  RPE ${set.rpe}' : '';

    return 'Set $setNumber:  $weight × $repsStr$rpeStr';
  }
}

/// Footer with FitLog Pro branding
/// Logo on the left, "Generato da FitLog Pro" on the right
class _ShareFooter extends StatelessWidget {
  const _ShareFooter({
    required this.primaryColor,
    required this.mutedColor,
  });

  final Color primaryColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo on the left
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/splash_logo.png',
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
        ),

        // "Generato da FitLog Pro" on the right
        Text(
          'Generato da FitLog Pro',
          style: TextStyle(
            color: mutedColor,
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

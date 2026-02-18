/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/history/presentation/widgets
/// 🎯 Feature: workout_history
/// 🔧 Type: widget (off-screen share card)
/// 🌍 Localization: N/A (hardcoded strings for consistent sharing)
/// 🎨 Theme: Fixed dark theme for shareable image
/// 📱 Platform: Universal
///
/// HISTORY SHARE CARD - Off-screen widget captured as PNG for sharing
///
/// Generates a branded workout summary image from WorkoutHistoryDetail.
/// Shows only working sets (warmup excluded) for cleaner output.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gymbro_flutter_new/features/history/domain/entities/workout_history_detail.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Off-screen card for sharing a completed workout as a PNG image.
/// Rendered with a fixed dark theme for consistent appearance across devices.
class HistoryShareCard extends StatelessWidget {
  const HistoryShareCard({super.key, required this.workout});

  final WorkoutHistoryDetail workout;

  // Fixed dark palette — consistent regardless of device theme
  static const _bg = Color(0xFF1A1A2E);
  static const _surface = Color(0xFF252542);
  static const _primary = Color(0xFF6C63FF);
  static const _success = Color(0xFF4CAF50);
  static const _text = Colors.white;
  static const _subtext = Colors.white70;
  static const _muted = Colors.white38;

  double get _workingVolume {
    return workout.exercises.fold(0.0, (sum, ex) {
      return sum +
          ex.sets
              .where((s) => !s.isWarmup)
              .fold(0.0, (setSum, s) => setSum + s.volume);
    });
  }

  int get _workingSetsCount {
    return workout.exercises.fold(0, (sum, ex) {
      return sum + ex.sets.where((s) => !s.isWarmup).length;
    });
  }

  double get _workingAverageRPE {
    final sets = workout.exercises
        .expand((e) => e.sets)
        .where((s) => !s.isWarmup && s.rpe > 0)
        .toList();
    if (sets.isEmpty) return 0.0;
    return sets.map((s) => s.rpe).reduce((a, b) => a + b) / sets.length;
  }

  String _formatVolume(double volume) {
    if (volume >= 1000) return '${(volume / 1000).toStringAsFixed(1)}t';
    return '${volume.toInt()} kg';
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _ShareHeader(
            workout: workout,
            workingVolume: _workingVolume,
            workingSetsCount: _workingSetsCount,
            workingAverageRPE: _workingAverageRPE,
            formatVolume: _formatVolume,
            formatDuration: _formatDuration,
          ),

          const SizedBox(height: 16),

          // Exercise list (working sets only)
          ...workout.exercises.map((exercise) {
            final workingSets =
                exercise.sets.where((s) => !s.isWarmup).toList();
            if (workingSets.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ShareExerciseItem(
                exerciseName: exercise.name,
                sets: workingSets,
              ),
            );
          }),

          const SizedBox(height: 14),

          // Footer
          _ShareFooter(
            date: DateFormat('dd MMM yyyy').format(workout.completedAt),
          ),
        ],
      ),
    );
  }
}

class _ShareHeader extends StatelessWidget {
  const _ShareHeader({
    required this.workout,
    required this.workingVolume,
    required this.workingSetsCount,
    required this.workingAverageRPE,
    required this.formatVolume,
    required this.formatDuration,
  });

  final WorkoutHistoryDetail workout;
  final double workingVolume;
  final int workingSetsCount;
  final double workingAverageRPE;
  final String Function(double) formatVolume;
  final String Function(Duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            HistoryShareCard._primary.withValues(alpha: 0.35),
            HistoryShareCard._primary.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout name
          Row(
            children: [
              const Icon(
                AppIcons.workout,
                color: HistoryShareCard._primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  workout.name.toUpperCase(),
                  style: const TextStyle(
                    color: HistoryShareCard._text,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stats row
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _HeaderStat(
                icon: AppIcons.workout,
                label: formatVolume(workingVolume),
              ),
              _HeaderStat(
                icon: AppIcons.timerOutlined,
                label: formatDuration(workout.duration),
              ),
              _HeaderStat(
                icon: AppIcons.fitnessCenterOutlined,
                label: '$workingSetsCount set',
              ),
              if (workingAverageRPE > 0)
                _HeaderStat(
                  icon: AppIcons.localFireDepartment,
                  label: 'RPE ${workingAverageRPE.toStringAsFixed(1)}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: HistoryShareCard._subtext),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: HistoryShareCard._subtext,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ShareExerciseItem extends StatelessWidget {
  const _ShareExerciseItem({
    required this.exerciseName,
    required this.sets,
  });

  final String exerciseName;
  final List<SetHistoryDetail> sets;

  Color _rpeColor(int rpe) {
    if (rpe <= 6) return const Color(0xFF4CAF50).withValues(alpha: 0.25);
    if (rpe <= 8) return const Color(0xFFFF9800).withValues(alpha: 0.25);
    return const Color(0xFFF44336).withValues(alpha: 0.25);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HistoryShareCard._surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: HistoryShareCard._success.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise name
          Row(
            children: [
              const Icon(
                AppIcons.checkCircle,
                color: HistoryShareCard._success,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  exerciseName,
                  style: const TextStyle(
                    color: HistoryShareCard._text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Sets
          ...sets.asMap().entries.map((entry) {
            final i = entry.key + 1;
            final s = entry.value;
            return Padding(
              padding: const EdgeInsets.only(left: 22, top: 3),
              child: Row(
                children: [
                  Text(
                    'Set $i:  ${s.weight.toInt()}kg × ${s.reps} reps',
                    style: const TextStyle(
                      color: HistoryShareCard._subtext,
                      fontSize: 13,
                    ),
                  ),
                  if (s.rpe > 0) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _rpeColor(s.rpe),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'RPE ${s.rpe}',
                        style: const TextStyle(
                          color: HistoryShareCard._subtext,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ShareFooter extends StatelessWidget {
  const _ShareFooter({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/splash_logo.png',
            width: 36,
            height: 36,
            fit: BoxFit.contain,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'FitLog Pro',
              style: TextStyle(
                color: HistoryShareCard._primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              date,
              style: const TextStyle(
                color: HistoryShareCard._muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation
/// 🎯 Feature: analytics
/// 🔧 Type: widget
/// 🌍 Localization: ✅ AppLocalizations used
/// 🎨 Theme: ✅ ColorScheme responsive
/// 📱 Platform: Universal
///
/// **Volume Progression Chart - Priority 1 Feature**
/// Evidence: Visual progress = top retention predictor
/// Shows: Weekly/monthly volume with % growth trend
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/shared/presentation/extensions/build_context_extensions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icon_size.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/color_scheme_extensions.dart';

/// Volume progression bar chart showing weekly volume with growth trend
class VolumeProgressionChart extends StatelessWidget {
  const VolumeProgressionChart({
    required this.workouts,
    super.key,
  });

  final List<Workout> workouts;

  @override
  Widget build(BuildContext context) {
    final weeklyData = _calculateWeeklyVolume();

    if (weeklyData.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                Icon(
                  AppIcons.barChart,
                  size: AppIconSize.xxlarge,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(128),
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.noDataAvailable,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final growthTrend = _calculateGrowthTrend(weeklyData);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with growth indicator
            Row(
              children: [
                Icon(
                  AppIcons.barChart,
                  color: context.colors.primary,
                  size: AppIconSize.large,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.volumeProgression,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            growthTrend >= 0 ? AppIcons.trendUp : AppIcons.trendDown,
                            size: AppIconSize.tiny,
                            color: growthTrend >= 0 ? context.colors.success : context.colors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${growthTrend >= 0 ? '+' : ''}${growthTrend.toStringAsFixed(1)}% ${context.l10n.trend}',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: growthTrend >= 0 ? context.colors.success : context.colors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bar chart
            SizedBox(
              height: 180,
              child: _buildVolumeBarChart(context, weeklyData),
            ),

            const SizedBox(height: 16),

            // Summary stats
            _buildSummaryStats(context, weeklyData),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeBarChart(BuildContext context, List<WeeklyVolumeData> data) {
    final maxValue = data.map((d) => d.volume).reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) {
      return Center(
        child: Text(
          context.l10n.noWorkoutsYet,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: data.map((weekData) {
        final height = (weekData.volume / maxValue) * 140;
        final isCurrentWeek = _isCurrentWeek(weekData.weekStart);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: weekData.volume > 0
                  ? () => HapticFeedback.lightImpact()
                  : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: height.clamp(8.0, 140.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isCurrentWeek
                            ? [
                                context.colors.success,
                                context.colors.success.withAlpha(204),
                              ]
                            : [
                                context.colors.primary,
                                context.colors.primary.withAlpha(179),
                              ],
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      boxShadow: weekData.volume > 0
                          ? [
                              BoxShadow(
                                color: (isCurrentWeek ? context.colors.success : context.colors.primary)
                                    .withAlpha(77),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Week label
                  Text(
                    _formatWeekLabel(weekData.weekStart),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: isCurrentWeek
                          ? context.colors.success
                          : Theme.of(context).colorScheme.onSurface.withAlpha(179),
                      fontWeight: isCurrentWeek ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Volume value (in tons if > 1000kg)
                  Text(
                    _formatVolume(weekData.volume),
                    style: context.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCurrentWeek ? context.colors.success : context.colors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryStats(BuildContext context, List<WeeklyVolumeData> data) {
    final totalVolume = data.fold(0.0, (sum, d) => sum + d.volume);
    final avgVolume = totalVolume / data.length;
    final peakWeek = data.reduce((a, b) => a.volume > b.volume ? a : b);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            icon: AppIcons.trendUp,
            label: context.l10n.peak,
            value: _formatVolume(peakWeek.volume),
          ),
          _buildStatItem(
            context,
            icon: AppIcons.barChart,
            label: context.l10n.average,
            value: _formatVolume(avgVolume),
          ),
          _buildStatItem(
            context,
            icon: AppIcons.workout,
            label: context.l10n.total,
            value: _formatVolume(totalVolume),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: AppIconSize.small,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // =============================================================================
  // CALCULATION LOGIC
  // =============================================================================

  List<WeeklyVolumeData> _calculateWeeklyVolume() {
    if (workouts.isEmpty) return [];

    // Group by week
    final Map<DateTime, double> weeklyVolume = {};

    for (final workout in workouts) {
      final weekStart = _getWeekStart(workout.createdAt);
      final volume = _calculateWorkoutVolume(workout);
      weeklyVolume[weekStart] = (weeklyVolume[weekStart] ?? 0) + volume;
    }

    // Convert to list and sort
    final data = weeklyVolume.entries
        .map((e) => WeeklyVolumeData(weekStart: e.key, volume: e.value))
        .toList()
      ..sort((a, b) => a.weekStart.compareTo(b.weekStart));

    // Return last 8 weeks only
    return data.length > 8 ? data.sublist(data.length - 8) : data;
  }

  double _calculateWorkoutVolume(Workout workout) {
    return workout.exercises.fold(0.0, (sum, exercise) {
      return sum +
          exercise.sets.where((s) => s.isCompleted && !s.isWarmup).fold(0.0, (setSum, set) {
            final weight = set.weight ?? 0.0;
            final reps = set.reps ?? 0;
            return setSum + (weight * reps);
          });
    });
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: weekday - 1));
  }

  bool _isCurrentWeek(DateTime weekStart) {
    final now = DateTime.now();
    final currentWeekStart = _getWeekStart(now);
    return weekStart.year == currentWeekStart.year &&
        weekStart.month == currentWeekStart.month &&
        weekStart.day == currentWeekStart.day;
  }

  String _formatWeekLabel(DateTime weekStart) {
    final month = weekStart.month;
    final day = weekStart.day;
    return '$day/${month.toString().padLeft(2, '0')}';
  }

  String _formatVolume(double volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}t';
    }
    return '${volume.toStringAsFixed(0)}kg';
  }

  double _calculateGrowthTrend(List<WeeklyVolumeData> data) {
    if (data.length < 2) return 0;

    final firstHalf = data.take(data.length ~/ 2).toList();
    final secondHalf = data.skip(data.length ~/ 2).toList();

    final firstAvg = firstHalf.fold(0.0, (sum, d) => sum + d.volume) / firstHalf.length;
    final secondAvg = secondHalf.fold(0.0, (sum, d) => sum + d.volume) / secondHalf.length;

    if (firstAvg == 0) return secondAvg > 0 ? 100.0 : 0.0;
    return ((secondAvg - firstAvg) / firstAvg) * 100;
  }
}

// =============================================================================
// DATA CLASSES
// =============================================================================

class WeeklyVolumeData {
  const WeeklyVolumeData({
    required this.weekStart,
    required this.volume,
  });

  final DateTime weekStart;
  final double volume;
}

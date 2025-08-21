import 'package:flutter/material.dart';
import '../../../workout/domain/entities/exercise_activity.dart';

class WorkoutFrequencyChart extends StatelessWidget {
  final List<ExerciseActivity> activities;

  const WorkoutFrequencyChart({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    final weeklyData = _calculateWeeklyFrequency();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.show_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekly Frequency',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Simple bar chart representation
            SizedBox(
              height: 200,
              child: weeklyData.isEmpty
                  ? const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : _buildSimpleBarChart(context, weeklyData),
            ),
            
            const SizedBox(height: 12),
            
            // Legend
            _buildLegend(context, weeklyData),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleBarChart(BuildContext context, List<WeeklyData> data) {
    final maxValue = data.map((d) => d.workoutCount).reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return const Center(child: Text('No workouts yet'));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: data.map((weekData) {
        final height = (weekData.workoutCount / maxValue) * 150;
        final isCurrentWeek = _isCurrentWeek(weekData.weekStart);
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Bar
                Container(
                  height: height.clamp(4.0, 150.0),
                  decoration: BoxDecoration(
                    color: isCurrentWeek
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Week label
                Text(
                  _formatWeekLabel(weekData.weekStart),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isCurrentWeek
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: isCurrentWeek ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                // Count
                Text(
                  weekData.workoutCount.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegend(BuildContext context, List<WeeklyData> data) {
    final currentWeekCount = data.where((d) => _isCurrentWeek(d.weekStart)).firstOrNull?.workoutCount ?? 0;
    final lastWeekCount = data.length > 1 ? data[data.length - 2].workoutCount : 0;
    final avgCount = data.isEmpty ? 0 : (data.map((d) => d.workoutCount).reduce((a, b) => a + b) / data.length);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          context,
          'This Week',
          currentWeekCount.toString(),
          Theme.of(context).colorScheme.primary,
        ),
        _buildLegendItem(
          context,
          'Last Week',
          lastWeekCount.toString(),
          Theme.of(context).colorScheme.secondary,
        ),
        _buildLegendItem(
          context,
          'Average',
          avgCount.toStringAsFixed(1),
          Theme.of(context).colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  List<WeeklyData> _calculateWeeklyFrequency() {
    if (activities.isEmpty) return [];

    // Group activities by workout sessions (schedaName + date)
    final Map<String, DateTime> workoutSessions = {};
    for (final activity in activities) {
      final sessionKey = '${activity.schedaName}_${_formatDateKey(activity.createdAt)}';
      workoutSessions.putIfAbsent(sessionKey, () => activity.createdAt);
    }

    // Group sessions by week
    final Map<String, int> weeklyWorkouts = {};
    for (final sessionDate in workoutSessions.values) {
      final weekStart = _getWeekStart(sessionDate);
      final weekKey = _formatDateKey(weekStart);
      weeklyWorkouts[weekKey] = (weeklyWorkouts[weekKey] ?? 0) + 1;
    }

    // Convert to list and sort by date
    final List<WeeklyData> result = [];
    for (final entry in weeklyWorkouts.entries) {
      final weekStart = DateTime.parse(entry.key);
      result.add(WeeklyData(
        weekStart: weekStart,
        workoutCount: entry.value,
      ));
    }

    result.sort((a, b) => a.weekStart.compareTo(b.weekStart));

    // Ensure we have at least the last 8 weeks
    final now = DateTime.now();
    for (int i = 7; i >= 0; i--) {
      final weekStart = _getWeekStart(now.subtract(Duration(days: i * 7)));
      final exists = result.any((data) => _isSameWeek(data.weekStart, weekStart));
      if (!exists) {
        result.add(WeeklyData(weekStart: weekStart, workoutCount: 0));
      }
    }

    result.sort((a, b) => a.weekStart.compareTo(b.weekStart));
    return result.length > 8 ? result.sublist(result.length - 8) : result;
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  bool _isCurrentWeek(DateTime weekStart) {
    final now = DateTime.now();
    final currentWeekStart = _getWeekStart(now);
    return _isSameWeek(weekStart, currentWeekStart);
  }

  bool _isSameWeek(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  String _formatWeekLabel(DateTime weekStart) {
    return '${weekStart.day}/${weekStart.month}';
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class WeeklyData {
  final DateTime weekStart;
  final int workoutCount;

  WeeklyData({
    required this.weekStart,
    required this.workoutCount,
  });
}
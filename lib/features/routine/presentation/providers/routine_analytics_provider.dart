/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/presentation/providers
/// 🎯 Feature: flexible_routine
/// 🔧 Type: provider
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// ROUTINE ANALYTICS PROVIDER - Calculate and provide routine metrics
///
/// Provides:
/// - Adherence metrics calculation
/// - Schedule vs actual comparison
/// - Weekly/monthly trend analysis
/// - Day of week patterns
/// - Automated insights generation
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_analytics.dart';
import 'package:gymbro_flutter_new/features/routine/presentation/providers/flexible_routine_provider.dart';

/// Provider for routine analytics of the active routine
final activeRoutineAnalyticsProvider =
    FutureProvider<RoutineAnalyticsState?>((ref) async {
  final activeRoutine = await ref.watch(
    activeFlexibleRoutineProvider.future,
  );

  if (activeRoutine == null) {
    return null;
  }

  return ref.watch(
    routineAnalyticsProvider(activeRoutine.id).future,
  );
});

/// Family provider for routine analytics by routine ID
final routineAnalyticsProvider = FutureProvider.family<RoutineAnalyticsState, String>(
  (ref, routineId) async {
    try {
      // Get the routine
      final routine = await ref.watch(routineByIdProvider(routineId).future);

      if (routine == null) {
        throw Exception('Routine not found');
      }

      // Calculate adherence metrics
      final adherenceMetrics = _calculateAdherenceMetrics(routine);

      // Calculate schedule match data
      final scheduleMatchData = _calculateScheduleMatchData(routine);

      // Calculate weekly summaries
      final weeklySummaries = _calculateWeeklySummaries(
        routine,
        scheduleMatchData,
      );

      // Calculate day of week patterns
      final dayOfWeekPatterns = _calculateDayOfWeekPatterns(scheduleMatchData);

      // Generate insights
      final insights = _generateInsights(
        routine,
        adherenceMetrics,
        scheduleMatchData,
        dayOfWeekPatterns,
      );

      return RoutineAnalyticsState(
        routineId: routine.id,
        routineName: routine.name,
        adherenceMetrics: adherenceMetrics,
        scheduleMatchData: scheduleMatchData,
        weeklySummaries: weeklySummaries,
        dayOfWeekPatterns: dayOfWeekPatterns,
        insights: insights,
        lastUpdated: DateTime.now(),
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error calculating routine analytics: $e');
        debugPrint('Stack trace: $stackTrace');
      }

      return RoutineAnalyticsState.empty(routineId, 'Unknown');
    }
  },
);

/// Calculate overall adherence metrics for a routine
RoutineAdherenceMetrics _calculateAdherenceMetrics(FlexibleRoutine routine) {
  final schedule = routine.schedule;
  final skipTracker = routine.skipTracker;

  // Calculate total planned days (non-rest days in schedule)
  int totalPlannedDays = 0;
  int completedDays = 0;
  final int skippedDays = skipTracker.skippedDays.length;
  final int recoveredDays = skipTracker.recoveredDays.length;

  // Count template distribution
  final Map<String, int> templateCounts = {};
  final Map<String, double> templateDistribution = {};

  for (final entry in schedule.entries) {
    final daySchedule = entry.value;

    if (daySchedule.isRestDay) continue;

    totalPlannedDays++;

    // Check if day is completed
    if (daySchedule.status == DayStatus.completed) {
      completedDays++;

      // Track template usage
      final templateId = daySchedule.templateId;
      if (templateId != null) {
        templateCounts[templateId] = (templateCounts[templateId] ?? 0) + 1;
      }
    }
  }

  // Calculate template distribution percentages
  if (completedDays > 0) {
    for (final entry in templateCounts.entries) {
      templateDistribution[entry.key] = entry.value / completedDays;
    }
  }

  // Calculate rates
  final adherenceRate = totalPlannedDays > 0
      ? completedDays / totalPlannedDays
      : 0.0;

  final skipRate = totalPlannedDays > 0
      ? skippedDays / totalPlannedDays
      : 0.0;

  final recoveryRate = skippedDays > 0
      ? recoveredDays / skippedDays
      : 0.0;

  // Calculate streaks
  final currentStreak = _calculateCurrentStreak(routine);
  final longestStreak = _calculateLongestStreak(routine);

  // Calculate average days between workouts
  final avgDaysBetweenWorkouts = _calculateAvgDaysBetweenWorkouts(routine);

  return RoutineAdherenceMetrics(
    adherenceRate: adherenceRate,
    totalPlannedDays: totalPlannedDays,
    completedDays: completedDays,
    skippedDays: skippedDays,
    recoveredDays: recoveredDays,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    templateDistribution: templateDistribution,
    skipRate: skipRate,
    recoveryRate: recoveryRate,
    avgDaysBetweenWorkouts: avgDaysBetweenWorkouts,
  );
}

/// Calculate schedule match data points
List<ScheduleMatchData> _calculateScheduleMatchData(FlexibleRoutine routine) {
  final schedule = routine.schedule;
  final List<ScheduleMatchData> matchData = [];

  final now = DateTime.now();
  final startDate = routine.startDate;

  // Only analyze days up to today
  for (final entry in schedule.entries) {
    final dayKey = entry.key;
    final daySchedule = entry.value;

    // Parse day from key (format: "YYYY-MM-DD")
    try {
      final date = DateTime.parse(dayKey);

      // Skip future dates
      if (date.isAfter(now)) continue;

      // Check if date is before start date
      if (date.isBefore(startDate)) continue;

      final scheduledTemplateId = daySchedule.templateId;
      // If completed and has a scheduled template, assume it was used
      final actualTemplateId = daySchedule.status == DayStatus.completed && daySchedule.templateId != null
          ? daySchedule.templateId
          : null;

      final isMatch = scheduledTemplateId != null &&
          actualTemplateId != null &&
          scheduledTemplateId == actualTemplateId;

      final isCompleted = daySchedule.status == DayStatus.completed;
      // Convert DateTime to string key format for Map lookup
      final dateKey = date.toIso8601String().split('T')[0];
      final isSkipped = routine.skipTracker.skippedDays.containsKey(dateKey);
      final isRecovered = routine.skipTracker.recoveredDays.containsKey(dateKey);

      matchData.add(
        ScheduleMatchData(
          date: date,
          scheduledTemplateId: scheduledTemplateId,
          actualTemplateId: actualTemplateId,
          isMatch: isMatch,
          isCompleted: isCompleted,
          isSkipped: isSkipped,
          isRecovered: isRecovered,
          dayOfWeek: date.weekday,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error parsing date from key: $dayKey');
      }
    }
  }

  // Sort by date
  matchData.sort((a, b) => a.date.compareTo(b.date));

  return matchData;
}

/// Calculate weekly adherence summaries
List<WeeklyAdherenceSummary> _calculateWeeklySummaries(
  FlexibleRoutine routine,
  List<ScheduleMatchData> scheduleMatchData,
) {
  if (scheduleMatchData.isEmpty) return [];

  final Map<DateTime, List<ScheduleMatchData>> weekGroups = {};

  // Group data by week (Monday as start of week)
  for (final data in scheduleMatchData) {
    final weekStart = _getWeekStart(data.date);

    if (!weekGroups.containsKey(weekStart)) {
      weekGroups[weekStart] = [];
    }
    weekGroups[weekStart]!.add(data);
  }

  // Calculate metrics for each week
  final List<WeeklyAdherenceSummary> summaries = [];

  for (final entry in weekGroups.entries) {
    final weekStart = entry.key;
    final weekData = entry.value;

    final plannedWorkouts = weekData.where((d) => !d.isSkipped).length;
    final completedWorkouts = weekData.where((d) => d.isCompleted).length;
    final skippedDays = weekData.where((d) => d.isSkipped).length;
    final recoveredDays = weekData.where((d) => d.isRecovered).length;

    final adherenceRate = plannedWorkouts > 0
        ? completedWorkouts / plannedWorkouts
        : 0.0;

    summaries.add(
      WeeklyAdherenceSummary(
        weekStart: weekStart,
        weekEnd: weekStart.add(const Duration(days: 6)),
        adherenceRate: adherenceRate,
        plannedWorkouts: plannedWorkouts,
        completedWorkouts: completedWorkouts,
        skippedDays: skippedDays,
        recoveredDays: recoveredDays,
      ),
    );
  }

  // Sort by date
  summaries.sort((a, b) => a.weekStart.compareTo(b.weekStart));

  return summaries;
}

/// Calculate day of week adherence patterns
List<DayOfWeekPattern> _calculateDayOfWeekPatterns(
  List<ScheduleMatchData> scheduleMatchData,
) {
  final Map<int, DayOfWeekStats> dayStats = {};

  // Initialize stats for each day of week (1-7)
  for (int i = 1; i <= 7; i++) {
    dayStats[i] = DayOfWeekStats();
  }

  // Aggregate data by day of week
  for (final data in scheduleMatchData) {
    final dayOfWeek = data.dayOfWeek;
    final stats = dayStats[dayOfWeek]!;

    stats.timesScheduled++;
    if (data.isCompleted) {
      stats.timesCompleted++;
    }
    if (data.isSkipped) {
      stats.timesSkipped++;
    }
  }

  // Convert to patterns
  final List<DayOfWeekPattern> patterns = [];

  for (final entry in dayStats.entries) {
    final dayOfWeek = entry.key;
    final stats = entry.value;

    final adherenceRate = stats.timesScheduled > 0
        ? stats.timesCompleted / stats.timesScheduled
        : 0.0;

    final skipRate = stats.timesScheduled > 0
        ? stats.timesSkipped / stats.timesScheduled
        : 0.0;

    patterns.add(
      DayOfWeekPattern(
        dayOfWeek: dayOfWeek,
        timesScheduled: stats.timesScheduled,
        timesCompleted: stats.timesCompleted,
        adherenceRate: adherenceRate,
        skipRate: skipRate,
      ),
    );
  }

  return patterns;
}

/// Helper class for day of week statistics
class DayOfWeekStats {
  int timesScheduled = 0;
  int timesCompleted = 0;
  int timesSkipped = 0;
}

/// Generate automated insights based on analytics
List<RoutineInsight> _generateInsights(
  FlexibleRoutine routine,
  RoutineAdherenceMetrics metrics,
  List<ScheduleMatchData> scheduleMatchData,
  List<DayOfWeekPattern> dayOfWeekPatterns,
) {
  final List<RoutineInsight> insights = [];

  // 1. Adherence insights
  if (metrics.adherenceRate >= 0.9) {
    insights.add(
      const RoutineInsight(
        type: RoutineInsightType.consistency,
        priority: 10,
        message: 'Outstanding! Your adherence is above 90% 🎯',
        icon: '🎯',
        isPositive: true,
      ),
    );
  } else if (metrics.adherenceRate >= 0.75) {
    insights.add(
      const RoutineInsight(
        type: RoutineInsightType.consistency,
        priority: 8,
        message: 'Great job! You\'re maintaining good consistency 💪',
        icon: '💪',
        isPositive: true,
      ),
    );
  } else if (metrics.adherenceRate < 0.5) {
    insights.add(
      const RoutineInsight(
        type: RoutineInsightType.warning,
        priority: 15,
        message: 'Your adherence is below 50%. Consider reviewing your routine schedule.',
        actionLabel: 'Adjust Schedule',
        icon: '⚠️',
        isPositive: false,
      ),
    );
  }

  // 2. Streak insights
  if (metrics.currentStreak >= 7) {
    insights.add(
      RoutineInsight(
        type: RoutineInsightType.motivation,
        priority: 12,
        message: 'Amazing! ${metrics.currentStreak} days streak! 🔥',
        icon: '🔥',
        isPositive: true,
      ),
    );
  }

  if (metrics.currentStreak == metrics.longestStreak && metrics.currentStreak >= 5) {
    insights.add(
      const RoutineInsight(
        type: RoutineInsightType.motivation,
        priority: 13,
        message: 'New personal record! Keep it going! 🏆',
        icon: '🏆',
        isPositive: true,
      ),
    );
  }

  // 3. Recovery insights
  if (metrics.recoveryRate >= 0.8 && metrics.recoveredDays > 0) {
    insights.add(
      const RoutineInsight(
        type: RoutineInsightType.recovery,
        priority: 9,
        message: 'Excellent recovery rate! You\'re making up for missed days 💯',
        icon: '💯',
        isPositive: true,
      ),
    );
  } else if (metrics.skippedDays > 3 && metrics.recoveryRate < 0.3) {
    insights.add(
      const RoutineInsight(
        type: RoutineInsightType.recovery,
        priority: 11,
        message: 'You have unrecovered skipped days. Consider catching up when possible.',
        actionLabel: 'View Recovery',
        icon: '📅',
        isPositive: false,
      ),
    );
  }

  // 4. Day of week insights
  final bestDay = dayOfWeekPatterns
      .where((p) => p.timesScheduled > 0)
      .fold<DayOfWeekPattern?>(
        null,
        (best, pattern) =>
            best == null || pattern.adherenceRate > best.adherenceRate
                ? pattern
                : best,
      );

  final worstDay = dayOfWeekPatterns
      .where((p) => p.timesScheduled > 0)
      .fold<DayOfWeekPattern?>(
        null,
        (worst, pattern) =>
            worst == null || pattern.adherenceRate < worst.adherenceRate
                ? pattern
                : worst,
      );

  if (bestDay != null && bestDay.adherenceRate >= 0.8) {
    final dayName = _getDayName(bestDay.dayOfWeek);
    insights.add(
      RoutineInsight(
        type: RoutineInsightType.consistency,
        priority: 7,
        message: 'You\'re most consistent on ${dayName}s!',
        icon: '📊',
        isPositive: true,
      ),
    );
  }

  if (worstDay != null && worstDay.skipRate > 0.5 && worstDay.timesScheduled >= 3) {
    final dayName = _getDayName(worstDay.dayOfWeek);
    insights.add(
      RoutineInsight(
        type: RoutineInsightType.warning,
        priority: 10,
        message: '${dayName}s are challenging. Consider rescheduling or adjusting intensity.',
        icon: '💡',
        isPositive: false,
      ),
    );
  }

  // Sort insights by priority (highest first)
  insights.sort((a, b) => b.priority.compareTo(a.priority));

  return insights;
}

/// Calculate current consecutive streak
int _calculateCurrentStreak(FlexibleRoutine routine) {
  final schedule = routine.schedule;
  final now = DateTime.now();

  // Get all non-rest days, sorted by date descending
  final scheduledDays = schedule.entries
      .where((e) => !e.value.isRestDay)
      .map((e) {
        try {
          return MapEntry(DateTime.parse(e.key), e.value);
        } catch (e) {
          return null;
        }
      })
      .whereType<MapEntry<DateTime, ScheduledDay>>()
      .where((e) => e.key.isBefore(now) || e.key.isAtSameMomentAs(now))
      .toList()
    ..sort((a, b) => b.key.compareTo(a.key));

  int streak = 0;

  for (final entry in scheduledDays) {
    if (entry.value.status == DayStatus.completed) {
      streak++;
    } else {
      // Streak broken
      break;
    }
  }

  return streak;
}

/// Calculate longest streak in routine history
int _calculateLongestStreak(FlexibleRoutine routine) {
  final schedule = routine.schedule;

  // Get all non-rest days, sorted by date
  final scheduledDays = schedule.entries
      .where((e) => !e.value.isRestDay)
      .map((e) {
        try {
          return MapEntry(DateTime.parse(e.key), e.value);
        } catch (e) {
          return null;
        }
      })
      .whereType<MapEntry<DateTime, ScheduledDay>>()
      .toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  int currentStreak = 0;
  int longestStreak = 0;

  for (final entry in scheduledDays) {
    if (entry.value.status == DayStatus.completed) {
      currentStreak++;
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
    } else {
      currentStreak = 0;
    }
  }

  return longestStreak;
}

/// Calculate average days between workouts
double _calculateAvgDaysBetweenWorkouts(FlexibleRoutine routine) {
  final schedule = routine.schedule;

  // Get all completed workout dates
  final completedDates = schedule.entries
      .where((e) => e.value.status == DayStatus.completed)
      .map((e) {
        try {
          return DateTime.parse(e.key);
        } catch (e) {
          return null;
        }
      })
      .whereType<DateTime>()
      .toList()
    ..sort();

  if (completedDates.length < 2) return 0.0;

  int totalDays = 0;
  for (int i = 1; i < completedDates.length; i++) {
    final diff = completedDates[i].difference(completedDates[i - 1]).inDays;
    totalDays += diff;
  }

  return totalDays / (completedDates.length - 1);
}

/// Get Monday of the week containing the given date
DateTime _getWeekStart(DateTime date) {
  final dayOfWeek = date.weekday;
  final daysToSubtract = dayOfWeek - 1; // Monday is 1
  return DateTime(date.year, date.month, date.day)
      .subtract(Duration(days: daysToSubtract));
}

/// Get localized day name (1 = Monday, 7 = Sunday)
String _getDayName(int dayOfWeek) {
  switch (dayOfWeek) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    case 7:
      return 'Sunday';
    default:
      return 'Unknown';
  }
}

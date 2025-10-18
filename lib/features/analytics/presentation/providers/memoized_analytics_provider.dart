/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/presentation/providers
/// 🎯 Feature: analytics
/// 🔧 Type: provider
///
/// Provider con memoization per calcoli analytics
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/workout.dart';
import 'package:gymbro_flutter_new/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:intl/intl.dart';

/// Stats calcolate e memoized
class AnalyticsStats {

  const AnalyticsStats({
    required this.totalWorkouts,
    required this.totalVolume,
    required this.currentStreak,
    required this.consistency,
    required this.volumeTrend,
    required this.workoutTrend,
  });
  final int totalWorkouts;
  final double totalVolume;
  final int currentStreak;
  final int consistency;
  final double volumeTrend;
  final double workoutTrend;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsStats &&
          runtimeType == other.runtimeType &&
          totalWorkouts == other.totalWorkouts &&
          totalVolume == other.totalVolume &&
          currentStreak == other.currentStreak &&
          consistency == other.consistency &&
          volumeTrend == other.volumeTrend &&
          workoutTrend == other.workoutTrend;

  @override
  int get hashCode =>
      totalWorkouts.hashCode ^
      totalVolume.hashCode ^
      currentStreak.hashCode ^
      consistency.hashCode ^
      volumeTrend.hashCode ^
      workoutTrend.hashCode;
}

/// Provider per stats memoized globali (tutti i workout)
final globalAnalyticsStatsProvider = Provider<AnalyticsStats>((ref) {
  final workoutsAsync = ref.watch(historicalWorkoutsProvider);

  return workoutsAsync.when(
    data: (workouts) => _calculateGlobalStats(workouts),
    loading: () => const AnalyticsStats(
      totalWorkouts: 0,
      totalVolume: 0,
      currentStreak: 0,
      consistency: 0,
      volumeTrend: 0,
      workoutTrend: 0,
    ),
    error: (_, __) => const AnalyticsStats(
      totalWorkouts: 0,
      totalVolume: 0,
      currentStreak: 0,
      consistency: 0,
      volumeTrend: 0,
      workoutTrend: 0,
    ),
  );
});

/// Provider per stats filtrate per periodo
final periodAnalyticsStatsProvider = Provider.family<AnalyticsStats, TimePeriod>((ref, period) {
  final workoutsAsync = ref.watch(historicalWorkoutsProvider);

  return workoutsAsync.when(
    data: (workouts) {
      final filteredWorkouts = _filterWorkoutsByPeriod(workouts, period);
      return _calculatePeriodStats(workouts, filteredWorkouts, period);
    },
    loading: () => const AnalyticsStats(
      totalWorkouts: 0,
      totalVolume: 0,
      currentStreak: 0,
      consistency: 0,
      volumeTrend: 0,
      workoutTrend: 0,
    ),
    error: (_, __) => const AnalyticsStats(
      totalWorkouts: 0,
      totalVolume: 0,
      currentStreak: 0,
      consistency: 0,
      volumeTrend: 0,
      workoutTrend: 0,
    ),
  );
});

/// Provider per personal records memoized
final personalRecordsProvider = Provider<Map<String, Map<String, dynamic>>>((ref) {
  final workoutsAsync = ref.watch(historicalWorkoutsProvider);

  return workoutsAsync.when(
    data: (workouts) => _calculatePersonalRecords(workouts),
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Provider per muscle data memoized
final muscleDataProvider = Provider<Map<MuscleGroup, MuscleStrengthData>>((ref) {
  final workoutsAsync = ref.watch(historicalWorkoutsProvider);

  return workoutsAsync.when(
    data: (workouts) => _generateMuscleData(workouts),
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Provider per workout timeline data memoized
final workoutTimelineProvider = Provider<Map<DateTime, WorkoutDayData>>((ref) {
  final workoutsAsync = ref.watch(historicalWorkoutsProvider);

  return workoutsAsync.when(
    data: (workouts) => _generateWorkoutData(workouts),
    loading: () => {},
    error: (_, __) => {},
  );
});

// ==================== Helper Functions ====================

enum TimePeriod { week, month, year, all }

List<Workout> _filterWorkoutsByPeriod(List<Workout> workouts, TimePeriod period) {
  final now = DateTime.now();

  switch (period) {
    case TimePeriod.week:
      final weekAgo = now.subtract(const Duration(days: 7));
      return workouts.where((w) => (w.endTime ?? w.createdAt).isAfter(weekAgo)).toList();
    case TimePeriod.month:
      final monthAgo = now.subtract(const Duration(days: 30));
      return workouts.where((w) => (w.endTime ?? w.createdAt).isAfter(monthAgo)).toList();
    case TimePeriod.year:
      final yearAgo = now.subtract(const Duration(days: 365));
      return workouts.where((w) => (w.endTime ?? w.createdAt).isAfter(yearAgo)).toList();
    case TimePeriod.all:
      return workouts;
  }
}

AnalyticsStats _calculateGlobalStats(List<Workout> workouts) {
  final now = DateTime.now();
  final totalWorkouts = workouts.length;
  final totalVolume = _calculateTotalVolume(workouts);
  final currentStreak = _calculateStreak(workouts);

  // Consistency (last 30 days)
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
  final last30DaysWorkouts = workouts.where((w) =>
    (w.endTime ?? w.createdAt).isAfter(thirtyDaysAgo)).toList();
  final daysWithWorkout = _countUniqueWorkoutDays(last30DaysWorkouts);
  final consistency = (daysWithWorkout / 30 * 100).round();

  return AnalyticsStats(
    totalWorkouts: totalWorkouts,
    totalVolume: totalVolume,
    currentStreak: currentStreak,
    consistency: consistency,
    volumeTrend: 0,
    workoutTrend: 0,
  );
}

AnalyticsStats _calculatePeriodStats(
  List<Workout> allWorkouts,
  List<Workout> periodWorkouts,
  TimePeriod period,
) {
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final monthStart = DateTime(now.year, now.month, 1);

  final periodWorkoutCount = periodWorkouts.length;
  final periodVolume = _calculateTotalVolume(periodWorkouts);

  // Calcola trend confrontando con periodo precedente
  List<Workout> prevPeriodWorkouts;
  switch (period) {
    case TimePeriod.week:
      final prevWeekStart = weekStart.subtract(const Duration(days: 7));
      prevPeriodWorkouts = allWorkouts.where((w) =>
        (w.endTime ?? w.createdAt).isAfter(prevWeekStart) &&
        (w.endTime ?? w.createdAt).isBefore(weekStart)).toList();
      break;
    case TimePeriod.month:
      final prevMonthStart = monthStart.subtract(const Duration(days: 30));
      prevPeriodWorkouts = allWorkouts.where((w) =>
        (w.endTime ?? w.createdAt).isAfter(prevMonthStart) &&
        (w.endTime ?? w.createdAt).isBefore(monthStart)).toList();
      break;
    case TimePeriod.year:
      final prevYearStart = DateTime(now.year - 1);
      prevPeriodWorkouts = allWorkouts.where((w) =>
        (w.endTime ?? w.createdAt).isAfter(prevYearStart) &&
        (w.endTime ?? w.createdAt).isBefore(DateTime(now.year))).toList();
      break;
    case TimePeriod.all:
      prevPeriodWorkouts = [];
      break;
  }

  final prevPeriodVolume = _calculateTotalVolume(prevPeriodWorkouts);
  final volumeTrend = prevPeriodVolume > 0
      ? ((periodVolume - prevPeriodVolume) / prevPeriodVolume * 100)
      : periodVolume > 0 ? 100.0 : 0.0;

  final prevPeriodWorkoutCount = prevPeriodWorkouts.length;
  final workoutTrend = prevPeriodWorkoutCount > 0
      ? ((periodWorkoutCount - prevPeriodWorkoutCount) / prevPeriodWorkoutCount * 100)
      : periodWorkoutCount > 0 ? 100.0 : 0.0;

  final currentStreak = _calculateStreak(allWorkouts);

  // Consistency (last 30 days)
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
  final last30DaysWorkouts = allWorkouts.where((w) =>
    (w.endTime ?? w.createdAt).isAfter(thirtyDaysAgo)).toList();
  final daysWithWorkout = _countUniqueWorkoutDays(last30DaysWorkouts);
  final consistency = (daysWithWorkout / 30 * 100).round();

  return AnalyticsStats(
    totalWorkouts: periodWorkoutCount,
    totalVolume: periodVolume,
    currentStreak: currentStreak,
    consistency: consistency,
    volumeTrend: volumeTrend,
    workoutTrend: workoutTrend,
  );
}

double _calculateTotalVolume(List<Workout> workouts) {
  double total = 0;
  for (final workout in workouts) {
    total += workout.exercises.fold(0.0, (sum, exercise) => sum + exercise.totalVolume);
  }
  return total;
}

int _calculateStreak(List<Workout> workouts) {
  if (workouts.isEmpty) return 0;

  final sortedWorkouts = [...workouts]..sort((a, b) =>
    (b.endTime ?? b.createdAt).compareTo(a.endTime ?? a.createdAt));

  final today = DateTime.now();
  final lastWorkoutDate = sortedWorkouts.first.endTime ?? sortedWorkouts.first.createdAt;

  // Check if last workout was today or yesterday
  final daysSinceLastWorkout = today.difference(lastWorkoutDate).inDays;
  if (daysSinceLastWorkout > 1) return 0;

  int streak = 0;
  DateTime currentDate = DateTime(today.year, today.month, today.day);

  final workoutDays = sortedWorkouts
      .map((w) => DateTime(
        (w.endTime ?? w.createdAt).year,
        (w.endTime ?? w.createdAt).month,
        (w.endTime ?? w.createdAt).day,
      ))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));

  for (final workoutDay in workoutDays) {
    if (workoutDay.isAtSameMomentAs(currentDate) ||
        workoutDay.isAtSameMomentAs(currentDate.subtract(const Duration(days: 1)))) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }

  return streak;
}

int _countUniqueWorkoutDays(List<Workout> workouts) {
  final uniqueDays = <String>{};
  for (final workout in workouts) {
    uniqueDays.add(DateFormat('yyyy-MM-dd').format(workout.endTime ?? workout.createdAt));
  }
  return uniqueDays.length;
}

Map<String, Map<String, dynamic>> _calculatePersonalRecords(List<Workout> workouts) {
  final records = <String, Map<String, dynamic>>{};

  for (final workout in workouts) {
    for (final exercise in workout.exercises) {
      final exerciseName = exercise.name;

      if (!records.containsKey(exerciseName)) {
        records[exerciseName] = {
          'maxWeight': 0.0,
          'maxVolume': 0.0,
          'maxReps': 0,
          'maxDate': workout.createdAt,
        };
      }

      final currentMax = records[exerciseName]!['maxWeight'] as double;
      final maxSetWeight = exercise.sets.fold(0.0, (max, set) =>
        (set.weight ?? 0.0) > max ? (set.weight ?? 0.0) : max);

      if (maxSetWeight > currentMax) {
        records[exerciseName]!['maxWeight'] = maxSetWeight;
        records[exerciseName]!['maxDate'] = workout.createdAt;
      }

      final currentMaxVolume = records[exerciseName]!['maxVolume'] as double;
      if (exercise.totalVolume > currentMaxVolume) {
        records[exerciseName]!['maxVolume'] = exercise.totalVolume;
      }

      final currentMaxReps = records[exerciseName]!['maxReps'] as int;
      final maxSetReps = exercise.sets.fold(0, (max, set) =>
        (set.reps ?? 0) > max ? (set.reps ?? 0) : max);

      if (maxSetReps > currentMaxReps) {
        records[exerciseName]!['maxReps'] = maxSetReps;
      }
    }
  }

  return records;
}

// Placeholder per muscle data e workout data - da implementare se necessario
Map<MuscleGroup, MuscleStrengthData> _generateMuscleData(List<Workout> workouts) {
  // TODO: Implementare se necessario
  return {};
}

Map<DateTime, WorkoutDayData> _generateWorkoutData(List<Workout> workouts) {
  // TODO: Implementare se necessario
  return {};
}

// Placeholder classes - da importare dai file originali
class MuscleGroup {}
class MuscleStrengthData {}
class WorkoutDayData {}

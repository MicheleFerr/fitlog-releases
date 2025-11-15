import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_streak.freezed.dart';

/// Represents user's workout streak statistics
@freezed
class WorkoutStreak with _$WorkoutStreak {
  const factory WorkoutStreak({
    required int currentStreak,
    required int longestStreak,
    required bool isActive,
    required DateTime? lastWorkoutDate,
    required int totalWorkoutDays,
  }) = _WorkoutStreak;

  const WorkoutStreak._();

  /// Calculate streak from list of workout dates
  factory WorkoutStreak.fromWorkoutDates(
    List<DateTime> workoutDates,
    DateTime referenceDate,
  ) {
    if (workoutDates.isEmpty) {
      return const WorkoutStreak(
        currentStreak: 0,
        longestStreak: 0,
        isActive: false,
        lastWorkoutDate: null,
        totalWorkoutDays: 0,
      );
    }

    // Sort dates in descending order (most recent first)
    final sortedDates = workoutDates.map((d) => _dateOnly(d)).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    // Calculate current streak
    int currentStreak = 0;
    final today = _dateOnly(referenceDate);
    DateTime checkDate = today;

    for (final date in sortedDates) {
      if (_isSameDay(date, checkDate) || _isSameDay(date, checkDate.subtract(const Duration(days: 1)))) {
        currentStreak++;
        checkDate = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 1;

    for (int i = 0; i < sortedDates.length - 1; i++) {
      final daysDiff = sortedDates[i].difference(sortedDates[i + 1]).inDays;
      if (daysDiff == 1) {
        tempStreak++;
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
      } else {
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
        tempStreak = 1;
      }
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    return WorkoutStreak(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      isActive: currentStreak > 0 && _isSameDay(sortedDates.first, today),
      lastWorkoutDate: sortedDates.first,
      totalWorkoutDays: sortedDates.length,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

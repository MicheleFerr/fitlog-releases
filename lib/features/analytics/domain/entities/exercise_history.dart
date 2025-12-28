/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/entities
/// 🎯 Feature: analytics
/// 🔧 Type: entity
///
/// ExerciseHistory Entity - Tracks all sessions for a single exercise
///
/// **Properties**:
/// - exerciseName: Name of the exercise
/// - sessions: All sessions performed for this exercise
///
/// **Computed Properties**:
/// - personalRecord: Highest estimated 1RM ever achieved
/// - weeklyVolumeProgression: % change in volume (this week vs last week)
///
/// **Methods**:
/// - getSessionsByTimeframe: Filter sessions by date range
///
/// **Usage**:
/// ```dart
/// final history = ExerciseHistory(
///   exerciseName: 'Bench Press',
///   sessions: [
///     ExerciseSession(...), // Week 1
///     ExerciseSession(...), // Week 2
///     ExerciseSession(...), // Week 3
///   ],
/// );
///
/// print(history.personalRecord);          // 125.0 kg
/// print(history.weeklyVolumeProgression); // +15.5%
/// ```
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';

part 'exercise_history.freezed.dart';
part 'exercise_history.g.dart';

@freezed
abstract class ExerciseHistory with _$ExerciseHistory {

  const factory ExerciseHistory({
    /// Unique identifier for the exercise (from database)
    /// Used for exact matching in suggestion engine
    required String exerciseId,

    /// Name of the exercise (e.g., "Bench Press", "Squat")
    required String exerciseName,

    /// Target muscle group (e.g., "chest", "back", "legs")
    required String muscleGroup,

    /// All sessions performed for this exercise (sorted by date)
    required List<ExerciseSession> sessions,
  }) = _ExerciseHistory;
  const ExerciseHistory._();

  /// Create from JSON (Firestore deserialization)
  factory ExerciseHistory.fromJson(Map<String, dynamic> json) =>
      _$ExerciseHistoryFromJson(json);

  /// Personal Record - highest estimated 1RM ever achieved
  ///
  /// **Logic**:
  /// - Calculate estimated 1RM for each session
  /// - Return the highest value across all sessions
  ///
  /// Returns 0 if no sessions
  double get personalRecord {
    if (sessions.isEmpty) return 0;
    return sessions
        .map((s) => s.highestEstimated1RM)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Weekly volume progression (% change: this week vs last week)
  ///
  /// **Formula**: ((thisWeekVolume - lastWeekVolume) / lastWeekVolume) × 100
  ///
  /// **Examples**:
  /// - This week: 3000 kg, Last week: 2500 kg → +20%
  /// - This week: 2000 kg, Last week: 2500 kg → -20%
  /// - Last week: 0 kg → returns 0 (no baseline)
  ///
  /// Returns 0 if:
  /// - No sessions in last 2 weeks
  /// - Previous week had 0 volume (no baseline)
  double get weeklyVolumeProgression {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    // Calculate this week's volume
    final thisWeekVolume = sessions
        .where((s) => s.date.isAfter(lastWeek))
        .fold<double>(0, (sum, s) => sum + s.totalVolume);

    // Calculate last week's volume
    final previousWeekVolume = sessions
        .where((s) => s.date.isAfter(twoWeeksAgo) && s.date.isBefore(lastWeek))
        .fold<double>(0, (sum, s) => sum + s.totalVolume);

    // No baseline → can't calculate progression
    if (previousWeekVolume == 0) return 0;

    // Calculate percentage change
    return ((thisWeekVolume - previousWeekVolume) / previousWeekVolume) * 100;
  }

  /// Filter sessions by date range
  ///
  /// **Usage**:
  /// ```dart
  /// // Get sessions from last 30 days
  /// final lastMonth = history.getSessionsByTimeframe(
  ///   DateTime.now().subtract(Duration(days: 30)),
  ///   DateTime.now(),
  /// );
  /// ```
  ///
  /// Returns sessions where: start <= session.date <= end
  List<ExerciseSession> getSessionsByTimeframe(
    DateTime start,
    DateTime end,
  ) {
    return sessions
        .where((s) => s.date.isAfter(start) && s.date.isBefore(end))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // Sort by date ascending
  }

  /// Get all sessions sorted by date (newest first)
  List<ExerciseSession> get sessionsSortedByDate {
    return [...sessions]..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get all sessions sorted by date (oldest first)
  List<ExerciseSession> get sessionsSortedByDateAscending {
    return [...sessions]..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Calculate total volume for a specific timeframe
  ///
  /// **Usage**:
  /// ```dart
  /// // Total volume in last 7 days
  /// final weekVolume = history.getTotalVolumeForTimeframe(
  ///   DateTime.now().subtract(Duration(days: 7)),
  ///   DateTime.now(),
  /// );
  /// ```
  double getTotalVolumeForTimeframe(DateTime start, DateTime end) {
    return getSessionsByTimeframe(start, end)
        .fold<double>(0, (sum, s) => sum + s.totalVolume);
  }

  /// Find the session with the highest 1RM
  ///
  /// Returns null if no sessions
  ExerciseSession? get personalRecordSession {
    if (sessions.isEmpty) return null;

    return sessions.reduce(
      (best, current) => current.highestEstimated1RM > best.highestEstimated1RM
          ? current
          : best,
    );
  }
}

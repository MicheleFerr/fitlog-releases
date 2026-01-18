/// Aggregate Sets By Session Use Case
///
/// Aggregates individual sets into session-level data points for charts.
/// Solves the problem of multiple sets with nearly-identical timestamps
/// causing overlapping/invisible chart elements.
library;

import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_progress_metrics.dart';

/// Aggregated session data for charting
class SessionDataPoint {
  SessionDataPoint({
    required this.date,
    required this.maxWeight,
    required this.avgWeight,
    required this.totalVolume,
    required this.maxReps,
    required this.avgReps,
    required this.avgRpe,
    required this.setCount,
  });

  /// Session date (day only, no time component)
  final DateTime date;

  /// Maximum weight lifted in this session
  final double maxWeight;

  /// Average weight lifted in this session
  final double avgWeight;

  /// Total volume (weight × reps) for this session
  final double totalVolume;

  /// Maximum reps in this session
  final int maxReps;

  /// Average reps in this session
  final double avgReps;

  /// Average RPE in this session (null if no RPE data)
  final double? avgRpe;

  /// Number of sets in this session
  final int setCount;
}

/// Aggregates individual sets into session-level data points
///
/// Groups sets by day and calculates:
/// - Max/avg weight per session
/// - Total volume per session
/// - Max/avg reps per session
/// - Avg RPE per session
///
/// Returns one [SessionDataPoint] per unique day, sorted by date.
List<SessionDataPoint> aggregateSetsBySession(List<ExerciseSetData> sets) {
  if (sets.isEmpty) return [];

  // Group sets by day
  final Map<String, List<ExerciseSetData>> sessionsByDay = {};

  for (final set in sets) {
    final dayKey = _dateKey(set.date);
    sessionsByDay.putIfAbsent(dayKey, () => []).add(set);
  }

  // Convert to SessionDataPoint
  final sessions = <SessionDataPoint>[];

  for (final entry in sessionsByDay.entries) {
    final daySets = entry.value;
    if (daySets.isEmpty) continue;

    // Calculate aggregates
    final maxWeight = daySets.fold<double>(
      0,
      (max, s) => s.weight > max ? s.weight : max,
    );

    final avgWeight = daySets.fold<double>(
      0,
      (sum, s) => sum + s.weight,
    ) / daySets.length;

    final totalVolume = daySets.fold<double>(
      0,
      (sum, s) => sum + s.volume,
    );

    final maxReps = daySets.fold<int>(
      0,
      (max, s) => s.reps > max ? s.reps : max,
    );

    final avgReps = daySets.fold<double>(
      0,
      (sum, s) => sum + s.reps,
    ) / daySets.length;

    // Calculate average RPE (only for sets with RPE data)
    final setsWithRpe = daySets.where((s) => s.rpe != null).toList();
    final avgRpe = setsWithRpe.isNotEmpty
        ? setsWithRpe.fold<double>(0, (sum, s) => sum + (s.rpe ?? 0)) /
            setsWithRpe.length
        : null;

    // Use the first set's date (with time stripped to midnight)
    final sessionDate = _dateOnly(daySets.first.date);

    sessions.add(SessionDataPoint(
      date: sessionDate,
      maxWeight: maxWeight,
      avgWeight: avgWeight,
      totalVolume: totalVolume,
      maxReps: maxReps,
      avgReps: avgReps,
      avgRpe: avgRpe,
      setCount: daySets.length,
    ));
  }

  // Sort by date (oldest first)
  sessions.sort((a, b) => a.date.compareTo(b.date));

  return sessions;
}

/// Helper to create a unique key for a day
String _dateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';

/// Helper to strip time component from DateTime
DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

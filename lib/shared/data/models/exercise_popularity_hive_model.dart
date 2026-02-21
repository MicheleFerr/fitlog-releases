import 'package:hive_ce/hive.dart';

part 'exercise_popularity_hive_model.g.dart';

/// Hive model for caching exercise popularity data locally
///
/// Used for zero-latency search boost without network access.
/// Data is synced from Firebase Data Bundle (generated daily by Cloud Functions).
///
/// TTL: 24 hours (soft expiration - not auto-deleted, checked on read)
///
/// @see docs/design/EXERCISE_POPULARITY_RANKING.md
@HiveType(typeId: 111)
class ExercisePopularityHiveModel extends HiveObject {

  ExercisePopularityHiveModel({
    required this.exerciseId,
    required this.count,
    required this.lastUpdated,
  });

  /// Create from domain entity
  factory ExercisePopularityHiveModel.fromDomain(
    String exerciseId,
    int count,
    DateTime lastUpdated,
  ) {
    return ExercisePopularityHiveModel(
      exerciseId: exerciseId,
      count: count,
      lastUpdated: lastUpdated,
    );
  }
  /// Unique exercise identifier
  @HiveField(0)
  final String exerciseId;

  /// Global usage count (number of times used in templates)
  @HiveField(1)
  final int count;

  /// Timestamp of last update (for TTL check)
  @HiveField(2)
  final DateTime lastUpdated;

  /// Check if cache entry is expired (>24h old)
  bool isExpired() {
    return DateTime.now().difference(lastUpdated) > const Duration(days: 1);
  }

  @override
  String toString() {
    return 'ExercisePopularityHiveModel(exerciseId: $exerciseId, count: $count, lastUpdated: $lastUpdated)';
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_popularity_data.freezed.dart';
part 'exercise_popularity_data.g.dart';

/// Domain entity for exercise popularity data
///
/// Represents the global usage count for an exercise across all users.
/// Used for boosting search results based on community popularity.
///
/// Data flow:
/// - Cloud Functions generate bundle from Firestore
/// - Flutter downloads bundle and caches locally
/// - Search service reads from cache for zero-latency boost
///
/// @see docs/design/EXERCISE_POPULARITY_RANKING.md
@freezed
sealed class ExercisePopularityData with _$ExercisePopularityData {
  const factory ExercisePopularityData({
    /// Unique exercise identifier
    required String exerciseId,

    /// Global usage count (number of times used in templates)
    required int count,

    /// Timestamp of last update (from Firestore server)
    required DateTime lastUpdated,
  }) = _ExercisePopularityData;

  /// Create from Firestore document JSON
  factory ExercisePopularityData.fromJson(Map<String, dynamic> json) =>
      _$ExercisePopularityDataFromJson(json);
}

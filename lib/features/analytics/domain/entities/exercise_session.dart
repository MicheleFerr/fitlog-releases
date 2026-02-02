/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/entities
/// 🎯 Feature: analytics
/// 🔧 Type: entity
///
/// ExerciseSession Entity - Represents a complete exercise session (all sets)
///
/// **Properties**:
/// - exerciseName: Name of the exercise (e.g., "Bench Press")
/// - muscleGroup: Target muscle group (e.g., "chest", "back")
/// - sets: List of all sets performed in this session
/// - date: When the session was performed
///
/// **Computed Properties**:
/// - totalVolume: Sum of volume for all sets
/// - maxWeight: Heaviest weight lifted in any set
/// - maxReps: Maximum reps performed in any set
/// - highestEstimated1RM: Best estimated 1RM across all sets
///
/// **Usage**:
/// ```dart
/// final session = ExerciseSession(
///   exerciseName: 'Bench Press',
///   muscleGroup: 'chest',
///   sets: [
///     AnalyticsSet(weight: 80, reps: 10, date: DateTime.now()),
///     AnalyticsSet(weight: 90, reps: 8, date: DateTime.now()),
///     AnalyticsSet(weight: 100, reps: 6, date: DateTime.now()),
///   ],
///   date: DateTime.now(),
/// );
///
/// print(session.totalVolume);          // 2340.0 kg
/// print(session.maxWeight);            // 100.0 kg
/// print(session.highestEstimated1RM);  // ~116.0 kg
/// ```
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';

part 'exercise_session.freezed.dart';
part 'exercise_session.g.dart';

@freezed
abstract class ExerciseSession with _$ExerciseSession {
  const factory ExerciseSession({
    /// Name of the exercise (e.g., "Bench Press", "Squat")
    required String exerciseName,

    /// Target muscle group (e.g., "chest", "back", "legs")
    required String muscleGroup,

    /// All sets performed in this session
    required List<AnalyticsSet> sets,

    /// When the session was performed
    required DateTime date,
  }) = _ExerciseSession;
  const ExerciseSession._();

  /// Create from JSON (Firestore deserialization)
  factory ExerciseSession.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSessionFromJson(json);

  /// Total volume for this session (sum of all set volumes)
  ///
  /// Example:
  /// - Set 1: 80 kg × 10 reps = 800 kg
  /// - Set 2: 90 kg × 8 reps = 720 kg
  /// - Set 3: 100 kg × 6 reps = 600 kg
  /// - Total: 2120 kg
  double get totalVolume {
    return sets.fold<double>(0, (sum, set) => sum + set.volume);
  }

  /// Maximum weight lifted in any set
  ///
  /// Returns 0 if no sets
  double get maxWeight {
    if (sets.isEmpty) return 0;
    return sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
  }

  /// Maximum reps performed in any set
  ///
  /// Returns 0 if no sets
  int get maxReps {
    if (sets.isEmpty) return 0;
    return sets.map((s) => s.reps).reduce((a, b) => a > b ? a : b);
  }

  /// Best estimated 1RM across all sets in this session
  ///
  /// **Logic**:
  /// - Calculate estimated 1RM for each set
  /// - Return the highest value
  ///
  /// Example:
  /// - Set 1: 80 kg × 10 → ~106.7 kg 1RM
  /// - Set 2: 90 kg × 8 → ~109.2 kg 1RM
  /// - Set 3: 100 kg × 6 → ~116.0 kg 1RM ← Best
  double get highestEstimated1RM {
    if (sets.isEmpty) return 0;
    return sets.map((s) => s.estimatedOneRM).reduce((a, b) => a > b ? a : b);
  }

  /// Validate session data
  ///
  /// **Constraints**:
  /// - Must have at least 1 set
  /// - All sets must be valid (weight > 0, reps > 0)
  ///
  /// Throws [ArgumentError] if validation fails
  void validate() {
    if (sets.isEmpty) {
      throw ArgumentError('Session must have at least 1 set');
    }
    for (final set in sets) {
      set.validate();
    }
  }
}

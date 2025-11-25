/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/data/models
/// 🎯 Feature: analytics
/// 🔧 Type: data model
///
/// ExerciseHistoryModel - Firestore data model for ExerciseHistory entity
///
/// **Purpose**: Bridge between Firestore document and domain ExerciseHistory entity
///
/// **Firestore Document Path**: `users/{userId}/analytics/{exerciseName}`
///
/// **Document Structure**:
/// ```json
/// {
///   "exerciseName": "Bench Press",
///   "muscleGroup": "chest",
///   "lastUpdated": "2025-01-15T14:30:00.000Z",
///   "sessions": [
///     {
///       "exerciseName": "Bench Press",
///       "muscleGroup": "chest",
///       "date": "2025-01-15T14:30:00.000Z",
///       "sets": [
///         {"weight": 80.0, "reps": 10, "date": "2025-01-15T14:30:00.000Z"},
///         {"weight": 90.0, "reps": 8, "date": "2025-01-15T14:35:00.000Z"}
///       ]
///     },
///     {
///       "exerciseName": "Bench Press",
///       "muscleGroup": "chest",
///       "date": "2025-01-14T10:00:00.000Z",
///       "sets": [...]
///     }
///   ]
/// }
/// ```
///
/// **Usage**:
/// ```dart
/// // From Firestore document
/// final docSnapshot = await _firestore
///     .collection('users')
///     .doc(userId)
///     .collection('analytics')
///     .doc('Bench Press')
///     .get();
///
/// final model = ExerciseHistoryModel.fromJson(docSnapshot.data()!);
/// final entity = model.toDomain();
///
/// // To Firestore document
/// final model = ExerciseHistoryModel.fromDomain(entity);
/// await _firestore
///     .collection('users')
///     .doc(userId)
///     .collection('analytics')
///     .doc(entity.exerciseName)
///     .set(model.toJson());
/// ```
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/analytics/data/models/exercise_session_model.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_history.dart';

part 'exercise_history_model.freezed.dart';

@freezed
class ExerciseHistoryModel with _$ExerciseHistoryModel {

  const factory ExerciseHistoryModel({
    /// Name of the exercise (also the document ID)
    required String exerciseName,

    /// Target muscle group (e.g., "chest", "back", "legs")
    required String muscleGroup,

    /// All sessions for this exercise (sorted by date descending)
    required List<ExerciseSessionModel> sessions,

    /// When this document was last updated (for cache invalidation)
    required DateTime lastUpdated,
  }) = _ExerciseHistoryModel;

  /// Create from domain entity
  factory ExerciseHistoryModel.fromDomain(ExerciseHistory entity) {
    return ExerciseHistoryModel(
      exerciseName: entity.exerciseName,
      muscleGroup: entity.muscleGroup,
      sessions: entity.sessions
          .map((session) => ExerciseSessionModel.fromDomain(session))
          .toList(),
      lastUpdated: DateTime.now(), // Update timestamp on write
    );
  }

  /// Create from Firestore DocumentSnapshot (convenience method)
  ///
  /// **Usage**:
  /// ```dart
  /// final docSnapshot = await _firestore
  ///     .collection('users/$userId/analytics')
  ///     .doc('Bench Press')
  ///     .get();
  ///
  /// final model = ExerciseHistoryModel.fromFirestore(docSnapshot);
  /// ```
  factory ExerciseHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Document ${doc.id} does not exist');
    }

    // Ensure exerciseName matches document ID (consistency check)
    final dataCopy = Map<String, dynamic>.from(data);
    if (!dataCopy.containsKey('exerciseName')) {
      dataCopy['exerciseName'] = doc.id; // Use document ID as exerciseName
    }

    return ExerciseHistoryModel.fromJson(dataCopy);
  }
  const ExerciseHistoryModel._();

  /// Create from Firestore JSON
  factory ExerciseHistoryModel.fromJson(Map<String, dynamic> json) {
    return ExerciseHistoryModel(
      exerciseName: json['exerciseName'] as String,
      muscleGroup: json['muscleGroup'] as String,
      sessions: (json['sessions'] as List<dynamic>)
          .map((sessionJson) => ExerciseSessionModel.fromJson(
              sessionJson as Map<String, dynamic>))
          .toList(),
      lastUpdated: _timestampFromJson(json['lastUpdated']),
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'muscleGroup': muscleGroup,
      'sessions': sessions.map((session) => session.toJson()).toList(),
      'lastUpdated': _timestampToJson(lastUpdated),
    };
  }

  /// Convert to domain entity
  ExerciseHistory toDomain() {
    return ExerciseHistory(
      exerciseName: exerciseName,
      muscleGroup: muscleGroup,
      sessions: sessions.map((sessionModel) => sessionModel.toDomain()).toList(),
    );
  }

  /// Convert to Firestore map (convenience method)
  ///
  /// **Usage**:
  /// ```dart
  /// final model = ExerciseHistoryModel.fromDomain(entity);
  /// await _firestore
  ///     .collection('users/$userId/analytics')
  ///     .doc(entity.exerciseName)
  ///     .set(model.toFirestore());
  /// ```
  Map<String, dynamic> toFirestore() {
    return toJson();
  }
}

/// Convert Firestore Timestamp to DateTime
DateTime _timestampFromJson(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is String) {
    return DateTime.parse(value);
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  throw ArgumentError('Cannot convert $value to DateTime');
}

/// Convert DateTime to Firestore Timestamp
dynamic _timestampToJson(DateTime date) {
  return Timestamp.fromDate(date);
}

/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/data/models
/// 🎯 Feature: analytics
/// 🔧 Type: data model
///
/// ExerciseSessionModel - Firestore data model for ExerciseSession entity
///
/// **Purpose**: Bridge between Firestore JSON and domain ExerciseSession entity
///
/// **Firestore Structure** (embedded in analytics document):
/// ```json
/// {
///   "exerciseName": "Bench Press",
///   "muscleGroup": "chest",
///   "date": "2025-01-15T14:30:00.000Z",
///   "sets": [
///     {"weight": 80.0, "reps": 10, "date": "2025-01-15T14:30:00.000Z"},
///     {"weight": 90.0, "reps": 8, "date": "2025-01-15T14:35:00.000Z"}
///   ]
/// }
/// ```
///
/// **Usage**:
/// ```dart
/// // From Firestore
/// final model = ExerciseSessionModel.fromJson(sessionJson);
/// final entity = model.toDomain();
///
/// // To Firestore
/// final model = ExerciseSessionModel.fromDomain(entity);
/// final json = model.toJson();
/// ```
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/analytics/data/models/analytics_set_model.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/exercise_session.dart';

part 'exercise_session_model.freezed.dart';

@freezed
abstract class ExerciseSessionModel with _$ExerciseSessionModel {
  const factory ExerciseSessionModel({
    /// Name of the exercise (e.g., "Bench Press", "Squat")
    required String exerciseName,

    /// Target muscle group (e.g., "chest", "back", "legs")
    required String muscleGroup,

    /// All sets performed in this session
    required List<AnalyticsSetModel> sets,

    /// When the session was performed (Firestore Timestamp)
    required DateTime date,
  }) = _ExerciseSessionModel;

  /// Create from domain entity
  factory ExerciseSessionModel.fromDomain(ExerciseSession entity) {
    return ExerciseSessionModel(
      exerciseName: entity.exerciseName,
      muscleGroup: entity.muscleGroup,
      sets: entity.sets
          .map((set) => AnalyticsSetModel.fromDomain(set))
          .toList(),
      date: entity.date,
    );
  }
  const ExerciseSessionModel._();

  /// Create from Firestore JSON
  factory ExerciseSessionModel.fromJson(Map<String, dynamic> json) {
    return ExerciseSessionModel(
      exerciseName: json['exerciseName'] as String,
      muscleGroup: json['muscleGroup'] as String,
      sets: (json['sets'] as List<dynamic>)
          .map(
            (setJson) =>
                AnalyticsSetModel.fromJson(setJson as Map<String, dynamic>),
          )
          .toList(),
      date: _timestampFromJson(json['date']),
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'muscleGroup': muscleGroup,
      'sets': sets.map((set) => set.toJson()).toList(),
      'date': _timestampToJson(date),
    };
  }

  /// Convert to domain entity
  ExerciseSession toDomain() {
    return ExerciseSession(
      exerciseName: exerciseName,
      muscleGroup: muscleGroup,
      sets: sets.map((setModel) => setModel.toDomain()).toList(),
      date: date,
    );
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

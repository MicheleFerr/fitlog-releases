/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/data/models
/// 🎯 Feature: analytics
/// 🔧 Type: model
///
/// ExercisePreferencesModel - Firestore model for user exercise preferences
///
/// **Purpose**: Store all user preferences for exercises in a SINGLE document
/// to minimize Firestore reads/writes.
///
/// **Firestore Structure**:
/// ```
/// userExercisePreferences/{userId}
/// {
///   favorites: ['Bench Press', 'Squat', 'Deadlift'],
///   lastUpdated: Timestamp
/// }
/// ```
///
/// **Why single document**:
/// - ✅ 1 read to load all favorites (instead of N reads)
/// - ✅ 1 write to update (instead of N writes)
/// - ✅ Reduced Firestore costs
/// - ⚠️ Document size limit: 1MB (sufficient for ~10,000 exercise names)
///
/// **Usage**:
/// ```dart
/// // From Firestore
/// final model = ExercisePreferencesModel.fromJson(docSnapshot.data()!);
///
/// // To Firestore
/// await docRef.set(model.toJson());
/// ```
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_preferences_model.freezed.dart';
part 'exercise_preferences_model.g.dart';

/// Firestore model for user exercise preferences
///
/// **Fields**:
/// - favorites: Set of exercise names marked as favorite
/// - lastUpdated: Timestamp of last modification
///
/// **Firestore Cost Optimization**:
/// - Single document per user (not per exercise)
/// - Batch writes to reduce write operations
/// - Local caching to minimize reads
@freezed
class ExercisePreferencesModel with _$ExercisePreferencesModel {
  /// Create from Firestore document
  factory ExercisePreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$ExercisePreferencesModelFromJson(json);

  const ExercisePreferencesModel._();

  const factory ExercisePreferencesModel({
    /// Set of exercise names marked as favorite
    ///
    /// Stored as List in Firestore, converted to Set for O(1) lookup
    @Default([]) List<String> favorites,

    /// Timestamp of last update
    ///
    /// Used for sync conflict resolution and cache invalidation
    @TimestampConverter() DateTime? lastUpdated,
  }) = _ExercisePreferencesModel;

  /// Convert favorites List to Set for O(1) lookup
  ///
  /// Use this in provider to avoid repeated conversions
  Set<String> get favoritesSet => favorites.toSet();
}

/// Timestamp converter for Firestore Timestamp ↔ DateTime
///
/// Handles null safety and Firestore Timestamp conversion
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return null;
  }

  @override
  Object? toJson(DateTime? date) {
    if (date == null) return null;
    return Timestamp.fromDate(date);
  }
}

/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/data/models
/// 🎯 Feature: analytics
/// 🔧 Type: data model
///
/// AnalyticsSetModel - Firestore data model for AnalyticsSet entity
///
/// **Purpose**: Bridge between Firestore JSON and domain AnalyticsSet entity
///
/// **Firestore Structure**:
/// ```json
/// {
///   "weight": 100.0,
///   "reps": 8,
///   "date": "2025-01-15T14:30:00.000Z"
/// }
/// ```
///
/// **Mapping**:
/// - Firestore Timestamp → DateTime (automatic conversion)
/// - Double/Int preserved as-is
///
/// **Usage**:
/// ```dart
/// // From Firestore
/// final model = AnalyticsSetModel.fromJson(firestoreDoc.data());
/// final entity = model.toDomain();
///
/// // To Firestore
/// final model = AnalyticsSetModel.fromDomain(entity);
/// final json = model.toJson();
/// ```
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/analytics_set.dart';

part 'analytics_set_model.freezed.dart';

@freezed
abstract class AnalyticsSetModel with _$AnalyticsSetModel {
  const factory AnalyticsSetModel({
    /// Weight lifted in kg
    required double weight,

    /// Number of repetitions performed
    required int reps,

    /// When the set was performed (Firestore Timestamp)
    required DateTime date,
  }) = _AnalyticsSetModel;

  /// Create from domain entity
  factory AnalyticsSetModel.fromDomain(AnalyticsSet entity) {
    return AnalyticsSetModel(
      weight: entity.weight,
      reps: entity.reps,
      date: entity.date,
    );
  }
  const AnalyticsSetModel._();

  /// Create from Firestore JSON
  factory AnalyticsSetModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsSetModel(
      weight: (json['weight'] as num).toDouble(),
      reps: json['reps'] as int,
      date: _timestampFromJson(json['date']),
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {'weight': weight, 'reps': reps, 'date': _timestampToJson(date)};
  }

  /// Convert to domain entity
  AnalyticsSet toDomain() {
    return AnalyticsSet(weight: weight, reps: reps, date: date);
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
